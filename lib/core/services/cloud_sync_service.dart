import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_constants.dart';

/// RVIOS — Cloud Sync Service
///
/// Manages bidirectional data synchronization between:
///   - Local Drift SQLite database (offline-first)
///   - Supabase PostgreSQL (cloud storage)
///
/// Strategy: Local-first. All writes go to local DB first,
/// then sync to cloud when connection is available.
class CloudSyncService {
  CloudSyncService._();
  static final CloudSyncService instance = CloudSyncService._();

  SupabaseClient get _client => Supabase.instance.client;

  // ─────────────────────────────────────────────
  // Company Sync
  // ─────────────────────────────────────────────

  /// Creates a company in Supabase and returns the server-assigned ID.
  ///
  /// Called after creating a company locally — syncs the record up.
  Future<String?> createCompanyInCloud({
    required String companyCode,
    required String name,
    required String workspaceSlug,
    required int planType,
    required String ownerSupabaseUid,
    String? country,
    String? currency,
    String? industry,
    int? expectedEmployeeCount,
    String? defaultLanguage,
    String? defaultTimezone,
  }) async {
    try {
      final response = await _client.from('companies').insert({
        'company_code': companyCode,
        'name': name,
        'workspace_slug': workspaceSlug,
        'plan_type': planType,
        'subscription_status': 0, // trial
        'trial_ends_at': DateTime.now()
            .add(const Duration(days: AppConstants.trialDays))
            .toIso8601String(),
        'owner_id': ownerSupabaseUid,
        'country': country,
        'currency': currency,
        'industry': industry,
        'expected_employee_count': expectedEmployeeCount,
        'default_language': defaultLanguage ?? 'ar',
        'default_timezone': defaultTimezone ?? 'Asia/Riyadh',
      }).select('id').single();

      return response['id'] as String?;
    } catch (e) {
      debugPrint('[CloudSync] createCompanyInCloud error: $e');
      return null;
    }
  }

  /// Adds the owner as a member of the company (role = 0 = owner)
  Future<bool> addOwnerAsMember({
    required String companyId,
    required String userId,
  }) async {
    try {
      await _client.from('company_members').insert({
        'company_id': companyId,
        'user_id': userId,
        'role': 0, // owner
        'is_active': true,
        'joined_at': DateTime.now().toIso8601String(),
        'onboarding_completed': false,
      });
      return true;
    } catch (e) {
      debugPrint('[CloudSync] addOwnerAsMember error: $e');
      return false;
    }
  }

  /// Fetches the company record from Supabase by workspace slug
  Future<Map<String, dynamic>?> fetchCompanyBySlug(String slug) async {
    try {
      final response = await _client
          .from('companies')
          .select()
          .eq('workspace_slug', slug)
          .eq('is_deleted', false)
          .single();
      return response;
    } catch (e) {
      debugPrint('[CloudSync] fetchCompanyBySlug error: $e');
      return null;
    }
  }

  /// Fetches the company record by company code (CMP-XXXXXX)
  Future<Map<String, dynamic>?> fetchCompanyByCode(String code) async {
    try {
      final response = await _client
          .from('companies')
          .select()
          .eq('company_code', code)
          .eq('is_deleted', false)
          .single();
      return response;
    } catch (e) {
      debugPrint('[CloudSync] fetchCompanyByCode error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // User Profile Sync
  // ─────────────────────────────────────────────

  /// Updates the user profile in Supabase
  Future<bool> updateUserProfile({
    required String supabaseUid,
    String? displayName,
    String? firstName,
    String? lastName,
    String? username,
    String? phone,
    int? accountType,
    String? activeCompanyId,
    String? employeeCode,
    String? workspaceSlug,
    String? avatarUrl,
    String? language,
    String? country,
    bool? onboardingCompleted,
  }) async {
    try {
      final updates = <String, dynamic>{};
      if (displayName != null) updates['display_name'] = displayName;
      if (firstName != null) updates['first_name'] = firstName;
      if (lastName != null) updates['last_name'] = lastName;
      if (username != null) updates['username'] = username;
      if (phone != null) updates['phone'] = phone;
      if (accountType != null) updates['account_type'] = accountType;
      if (activeCompanyId != null) updates['active_company_id'] = activeCompanyId;
      if (employeeCode != null) updates['employee_code'] = employeeCode;
      if (workspaceSlug != null) updates['workspace_slug'] = workspaceSlug;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
      if (language != null) updates['language'] = language;
      if (country != null) updates['country'] = country;
      if (onboardingCompleted != null) {
        updates['onboarding_completed'] = onboardingCompleted;
      }

      if (updates.isEmpty) return true;

      await _client
          .from('user_profiles')
          .update(updates)
          .eq('id', supabaseUid);
      return true;
    } catch (e) {
      debugPrint('[CloudSync] updateUserProfile error: $e');
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // Invitation Sync
  // ─────────────────────────────────────────────

  /// Creates an invitation in Supabase
  Future<String?> createInvitation({
    required String companyId,
    required String invitedByUserId,
    required String token,
    required int role,
    required DateTime expiresAt,
    String? email,
    String? employeeCode,
    String? tempPasswordHash,
  }) async {
    try {
      final response = await _client.from('invitations').insert({
        'company_id': companyId,
        'invited_by': invitedByUserId,
        'token': token,
        'email': email,
        'employee_code': employeeCode,
        'temp_password_hash': tempPasswordHash,
        'role': role,
        'status': 0, // pending
        'expires_at': expiresAt.toIso8601String(),
      }).select('id').single();

      return response['id'] as String?;
    } catch (e) {
      debugPrint('[CloudSync] createInvitation error: $e');
      return null;
    }
  }

  /// Redeems an invitation token (joins the company)
  Future<Map<String, dynamic>?> redeemInvitation(String token) async {
    try {
      final response = await _client.rpc(
        'redeem_invitation',
        params: {'invitation_token': token},
      );
      return response as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('[CloudSync] redeemInvitation error: $e');
      return null;
    }
  }

  // ─────────────────────────────────────────────
  // Audit Log
  // ─────────────────────────────────────────────

  /// Logs an action to Supabase audit_logs
  Future<void> logAuditEvent({
    required String actorId,
    required String companyId,
    required String action,
    String? entityType,
    String? entityId,
    String? description,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
    String? platform,
    int severity = 0,
  }) async {
    try {
      await _client.from('audit_logs').insert({
        'actor_id': actorId,
        'company_id': companyId,
        'action': action,
        'entity_type': entityType,
        'entity_id': entityId,
        'description': description,
        'old_value': oldValue,
        'new_value': newValue,
        'platform': platform ?? (kIsWeb ? 'web' : 'mobile'),
        'severity': severity,
      });
    } catch (e) {
      // Audit logging failure should not block the user
      debugPrint('[CloudSync] logAuditEvent error (non-fatal): $e');
    }
  }

  // ─────────────────────────────────────────────
  // Members
  // ─────────────────────────────────────────────

  /// Fetches all members of a company from Supabase
  Future<List<Map<String, dynamic>>> fetchCompanyMembers(
      String companyId) async {
    try {
      final response = await _client
          .from('company_members')
          .select('*, user_profiles(display_name, avatar_url, email)')
          .eq('company_id', companyId)
          .eq('is_active', true)
          .eq('is_deleted', false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('[CloudSync] fetchCompanyMembers error: $e');
      return [];
    }
  }

  // ─────────────────────────────────────────────
  // Connectivity
  // ─────────────────────────────────────────────

  /// Checks if Supabase is reachable
  Future<bool> isCloudReachable() async {
    try {
      await _client.from('companies').select('id').limit(1);
      return true;
    } catch (_) {
      return false;
    }
  }
}