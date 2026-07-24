import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/constants/enums.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/dao/companies_dao.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/services/code_generator_service.dart';

// ─────────────────────────────────────────────
// DAO Provider
// ─────────────────────────────────────────────

final companiesDaoProvider = Provider<CompaniesDao>((ref) {
  final db = ref.watch(databaseProvider);
  return db.companiesDao;
});

// ─────────────────────────────────────────────
// Active Company State
// ─────────────────────────────────────────────

/// Holds the currently active company context for the logged-in user.
///
/// Null = personal mode (no company selected)
class ActiveCompanyNotifier extends StateNotifier<Company?> {
  ActiveCompanyNotifier() : super(null);

  void setCompany(Company? company) => state = company;
  void clearCompany() => state = null;

  /// Quick accessor for the current company's syncId
  String? get companySyncId => state?.syncId;

  /// Current plan type
  PlanType get planType =>
      state != null ? PlanType.fromValue(state!.planType) : PlanType.freePersonal;

  /// Subscription status
  SubscriptionStatus get subscriptionStatus => state != null
      ? SubscriptionStatus.fromValue(state!.subscriptionStatus)
      : SubscriptionStatus.trial;

  /// Whether the trial is still valid
  bool get isTrialActive {
    if (state == null) return false;
    final trialEnd = state!.trialEndsAt;
    if (trialEnd == null) return false;
    return DateTime.now().isBefore(trialEnd);
  }

  /// Whether the subscription is active (or in valid trial)
  bool get isSubscriptionValid =>
      subscriptionStatus == SubscriptionStatus.active || isTrialActive;
}

final activeCompanyProvider =
    StateNotifierProvider<ActiveCompanyNotifier, Company?>((ref) {
  return ActiveCompanyNotifier();
});

// ─────────────────────────────────────────────
// Active Member Role State
// ─────────────────────────────────────────────

/// The current user's role in the active company
final activeMemberRoleProvider = StateProvider<UserRole>((ref) {
  return UserRole.employee; // default; updated when switching company
});

/// Loads the actual role of the currently logged-in user
/// from the CompanyMembers table for the active company.
///
/// Returns [UserRole.employee] if the user has no explicit membership record.
final userRoleInCompanyProvider =
    FutureProvider.autoDispose<UserRole>((ref) async {
  final company = ref.watch(activeCompanyProvider);
  if (company == null) return UserRole.employee;

  // Get the current Supabase user's UID
  final supabaseUser = Supabase.instance.client.auth.currentUser;
  final userSyncId = supabaseUser?.id;
  if (userSyncId == null) return UserRole.owner; // guest/local mode — treat as owner

  final dao = ref.watch(companiesDaoProvider);
  final membership = await dao.getMembership(
    companySyncId: company.syncId,
    userSyncId: userSyncId,
  );

  if (membership == null) return UserRole.owner; // creator has no membership row → owner
  return UserRole.fromValue(membership.role);
});

// ─────────────────────────────────────────────
// Module Toggle State (company-level disabled modules)
// ─────────────────────────────────────────────

/// Set of modules that the company admin has manually disabled.
/// By default all plan-available modules are enabled.
final disabledModulesProvider =
    StateProvider<Set<AppModule>>((ref) => {});

// ─────────────────────────────────────────────
// Available Modules
// ─────────────────────────────────────────────

/// Modules available to the current user based on company plan + role,
/// minus any modules manually disabled by the admin.
final availableModulesProvider = Provider<List<AppModule>>((ref) {
  final company = ref.watch(activeCompanyProvider);
  final role = ref.watch(activeMemberRoleProvider);
  final disabledModules = ref.watch(disabledModulesProvider);

  final plan = company != null
      ? PlanType.fromValue(company.planType)
      : PlanType.freePersonal;

  final all = CodeGeneratorService.getAvailableModules(plan, role);
  // Remove any modules the admin has explicitly disabled
  return all.where((m) => !disabledModules.contains(m)).toList();
});

/// Whether a specific module is available
final isModuleAvailableProvider =
    Provider.family<bool, AppModule>((ref, module) {
  final modules = ref.watch(availableModulesProvider);
  return modules.contains(module);
});

// ─────────────────────────────────────────────
// Companies List
// ─────────────────────────────────────────────

/// All companies (for company switcher / multi-company support)
final companiesListProvider = StreamProvider<List<Company>>((ref) {
  final dao = ref.watch(companiesDaoProvider);
  return dao.watchAllCompanies();
});

// ─────────────────────────────────────────────
// Company Members
// ─────────────────────────────────────────────

/// Members of the active company
final companyMembersProvider = FutureProvider<List<CompanyMember>>((ref) async {
  final company = ref.watch(activeCompanyProvider);
  if (company == null) return [];
  final dao = ref.watch(companiesDaoProvider);
  return dao.getMembersOfCompany(company.syncId);
});

/// Watch members stream for real-time updates
final companyMembersStreamProvider =
    StreamProvider<List<CompanyMember>>((ref) {
  final company = ref.watch(activeCompanyProvider);
  if (company == null) return const Stream.empty();
  final dao = ref.watch(companiesDaoProvider);
  return dao.watchMembersOfCompany(company.syncId);
});

// ─────────────────────────────────────────────
// Pending Invitations
// ─────────────────────────────────────────────

/// Pending invitations for the active company (for admin view)
final pendingInvitationsProvider = FutureProvider<List<Invitation>>((ref) async {
  final company = ref.watch(activeCompanyProvider);
  if (company == null) return [];
  final dao = ref.watch(companiesDaoProvider);
  return dao.getPendingInvitations(company.syncId);
});

// ─────────────────────────────────────────────
// Computed Helpers
// ─────────────────────────────────────────────

/// Is the user in company mode (not personal)?
final isCompanyModeProvider = Provider<bool>((ref) {
  return ref.watch(activeCompanyProvider) != null;
});

/// Can the current user manage other users?
final canManageUsersProvider = Provider<bool>((ref) {
  final role = ref.watch(activeMemberRoleProvider);
  return role.canManageUsers;
});

/// Can the current user access HR module?
final canAccessHrProvider = Provider<bool>((ref) {
  final role = ref.watch(activeMemberRoleProvider);
  return role.hasHrAccess && ref.watch(isModuleAvailableProvider(AppModule.hrm));
});

/// Can the current user access Finance module?
final canAccessFinanceProvider = Provider<bool>((ref) {
  final role = ref.watch(activeMemberRoleProvider);
  return role.hasFinanceAccess &&
      ref.watch(isModuleAvailableProvider(AppModule.finance));
});

/// Is the current user the company owner?
final isCompanyOwnerProvider = Provider<bool>((ref) {
  return ref.watch(activeMemberRoleProvider).isOwner;
});