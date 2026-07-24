import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/supabase/base_repository.dart';
import '../../../core/supabase/supabase_client_provider.dart';
import '../../../core/supabase/supabase_config.dart';

// ─────────────────────────────────────────────
// Company Model
// ─────────────────────────────────────────────

class CompanyModel {
  const CompanyModel({
    required this.id,
    required this.syncId,
    required this.name,
    required this.planType,
    required this.subscriptionStatus,
    required this.maxUsers,
    this.logo,
    this.industry,
    this.country,
    this.ownerUserId,
    this.trialEndsAt,
    this.createdAt,
  });

  final String id;
  final String syncId;
  final String name;
  final int planType;
  final int subscriptionStatus;
  final int maxUsers;
  final String? logo;
  final String? industry;
  final String? country;
  final String? ownerUserId;
  final DateTime? trialEndsAt;
  final DateTime? createdAt;

  factory CompanyModel.fromJson(Map<String, dynamic> json) => CompanyModel(
        id:                 json['id'] as String,
        syncId:             json['sync_id'] as String,
        name:               json['name'] as String,
        planType:           (json['plan_type'] as num?)?.toInt() ?? 0,
        subscriptionStatus: (json['subscription_status'] as num?)?.toInt() ?? 0,
        maxUsers:           (json['max_users'] as num?)?.toInt() ?? 1,
        logo:               json['logo'] as String?,
        industry:           json['industry'] as String?,
        country:            json['country'] as String?,
        ownerUserId:        json['owner_user_id'] as String?,
        trialEndsAt: json['trial_ends_at'] != null
            ? DateTime.tryParse(json['trial_ends_at'] as String)
            : null,
        createdAt: json['created_at'] != null
            ? DateTime.tryParse(json['created_at'] as String)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'sync_id':              syncId,
        'name':                 name,
        'plan_type':            planType,
        'subscription_status':  subscriptionStatus,
        'max_users':            maxUsers,
        if (logo != null)       'logo': logo,
        if (industry != null)   'industry': industry,
        if (country != null)    'country': country,
        if (ownerUserId != null)'owner_user_id': ownerUserId,
        if (trialEndsAt != null)'trial_ends_at': trialEndsAt!.toIso8601String(),
      };
}

// ─────────────────────────────────────────────
// Member Model
// ─────────────────────────────────────────────

class MemberModel {
  const MemberModel({
    required this.id,
    required this.companySyncId,
    required this.userSupabaseId,
    required this.role,
    required this.status,
    this.joinedAt,
    this.displayName,
    this.email,
    this.avatarUrl,
  });

  final String id;
  final String companySyncId;
  final String userSupabaseId;
  final int role;
  final int status;
  final DateTime? joinedAt;
  final String? displayName;
  final String? email;
  final String? avatarUrl;

  factory MemberModel.fromJson(Map<String, dynamic> json) => MemberModel(
        id:              json['id'] as String,
        companySyncId:   json['company_sync_id'] as String,
        userSupabaseId:  json['user_supabase_id'] as String,
        role:            (json['role'] as num?)?.toInt() ?? 8,
        status:          (json['status'] as num?)?.toInt() ?? 1,
        joinedAt: json['joined_at'] != null
            ? DateTime.tryParse(json['joined_at'] as String)
            : null,
        displayName: json['display_name'] as String?,
        email:       json['email'] as String?,
        avatarUrl:   json['avatar_url'] as String?,
      );
}

// ─────────────────────────────────────────────
// Company Repository
// ─────────────────────────────────────────────

class CompanyRepository extends SupabaseRepository {
  const CompanyRepository(super.client);

  // ── Get companies for current user ──────────
  Future<List<CompanyModel>> getMyCompanies() async {
    return guard(() async {
      final userId = client.auth.currentUser?.id;
      if (userId == null) return [];

      // Get company sync_ids via members table
      final memberships = await client
          .from(SupabaseConfig.tableMembers)
          .select('company_sync_id')
          .eq('user_supabase_id', userId)
          .eq('status', 1); // active

      final syncIds = (memberships as List)
          .map((m) => m['company_sync_id'] as String)
          .toList();

      if (syncIds.isEmpty) return [];

      final data = await client
          .from(SupabaseConfig.tableCompanies)
          .select()
          .inFilter('sync_id', syncIds);

      return (data as List)
          .map((json) => CompanyModel.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  // ── Create company ───────────────────────────
  Future<CompanyModel> createCompany({
    required String syncId,
    required String name,
    String? industry,
    String? country,
  }) async {
    return guard(() async {
      final userId = client.auth.currentUser!.id;

      // Calculate trial end (14 days)
      final trialEnd = DateTime.now().add(const Duration(days: 14));

      final data = await client
          .from(SupabaseConfig.tableCompanies)
          .insert({
            'sync_id':              syncId,
            'name':                 name,
            'owner_user_id':        userId,
            'plan_type':            0, // free
            'subscription_status':  1, // trial
            'max_users':            1,
            'trial_ends_at':        trialEnd.toIso8601String(),
            'industry': ?industry,
            'country': ?country,
          })
          .select()
          .single();

      // Add owner as member
      await client.from(SupabaseConfig.tableMembers).insert({
        'company_sync_id': syncId,
        'user_supabase_id': userId,
        'role': 0, // owner
        'status': 1,
        'joined_at': DateTime.now().toIso8601String(),
      });

      return CompanyModel.fromJson(data);
    });
  }

  // ── Get members ──────────────────────────────
  Future<List<MemberModel>> getMembers(String companySyncId) async {
    return guard(() async {
      final data = await client
          .from(SupabaseConfig.tableMembers)
          .select()
          .eq('company_sync_id', companySyncId)
          .eq('status', 1);

      return (data as List)
          .map((json) => MemberModel.fromJson(json as Map<String, dynamic>))
          .toList();
    });
  }

  // ── Watch members (Realtime) ─────────────────
  Stream<List<MemberModel>> watchMembers(String companySyncId) {
    return client
        .from(SupabaseConfig.tableMembers)
        .stream(primaryKey: ['id'])
        .eq('company_sync_id', companySyncId)
        .map((rows) => rows
            .map((json) => MemberModel.fromJson(json))
            .toList());
  }

  // ── Update company ───────────────────────────
  Future<void> updateCompany(String syncId, Map<String, dynamic> updates) async {
    return guard(() async {
      await client
          .from(SupabaseConfig.tableCompanies)
          .update({...updates, 'updated_at': DateTime.now().toIso8601String()})
          .eq('sync_id', syncId);
    });
  }
}

// ─────────────────────────────────────────────
// Riverpod Providers
// ─────────────────────────────────────────────

final companyRepositoryProvider = Provider<CompanyRepository>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return CompanyRepository(client);
});

/// All companies the current user belongs to (Supabase)
final myCompaniesProvider = FutureProvider<List<CompanyModel>>((ref) async {
  final repo = ref.watch(companyRepositoryProvider);
  return repo.getMyCompanies();
});

/// Members of active company (Supabase)
final supabaseMembersProvider =
    StreamProvider.family<List<MemberModel>, String>((ref, companySyncId) {
  final repo = ref.watch(companyRepositoryProvider);
  return repo.watchMembers(companySyncId);
});