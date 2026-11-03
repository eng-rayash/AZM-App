import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/enums.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/dao/companies_dao.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/services/code_generator_service.dart';
import '../../auth/providers/auth_providers.dart';

// ─────────────────────────────────────────────
// DAO Provider
// ─────────────────────────────────────────────

/// جدول الشركات والعضويات يُقرأ من **قاعدة السجلّ** لا من قاعدة
/// الشركة النشطة.
///
/// لكل شركة ملفها منذ أن صار العزل حقيقة في نظام الملفات؛ ولو كانت
/// قائمة الشركات داخل ملف الشركة، لاحتجنا أن نعرف الشركة النشطة لنعرف
/// أي الشركات متاحة — ولتعذّر الخروج من شركة إلى أخرى.
final companiesDaoProvider = Provider<CompaniesDao>((ref) {
  return ref.watch(registryDatabaseProvider).companiesDao;
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
      state != null ? PlanType.fromValue(state!.planType) : PlanType.free;

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

/// معرّف المستخدم المسجَّل — مُحقَن لا مقروء من عالميّ.
///
/// معرّف الحساب في النظام الموحّد (نفسه على الويب والتطبيق). المزوّد يفصل
/// «من المستخدم» عن «ماذا يحقّ له»، ويُستبدَل في الاختبار بسطر واحد.
///
/// `null` تعني الوضع المحلي: ضيف بلا حساب، والجهاز جهازك.
final currentUserSyncIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateNotifierProvider).user?.id;
});

/// دور المستخدم في الشركة النشطة — **مشتقّ لا مخزَّن**.
///
/// كان `StateProvider` يحمل نسخة من حقيقة في القاعدة، ويحدّثها ودجت
/// واحد (مبدّل الشركات) عند التبديل. أي مسار آخر يضبط الشركة دون أن
/// يتذكّر ضبط الدور كان يترك المستخدم على آخر دور — أو على القيمة
/// الابتدائية `employee` — بلا أي إشارة. نسخة مكرّرة يحرسها انتباه
/// المطوّر هي نفس شكل العطب الذي رفضناه على الخادم.
///
/// الآن يُشتقّ من [userRoleInCompanyProvider]، فيستحيل أن يتخلّف عن
/// الشركة النشطة: تغيّرها يُعيد حسابه.
///
/// ⚠ هذا **عرض لا حماية**. إخفاء زرّ ليس منعًا، والمنع يقع على
/// الخادم في `TenantGuard` الذي يقرأ الدور من القاعدة في كل طلب.
final activeMemberRoleProvider = Provider<UserRole>((ref) {
  return ref.watch(userRoleInCompanyProvider).when(
        data: (role) => role,
        // أثناء التحميل: القيمة الابتدائية نفسها التي كانت قبل الاشتقاق
        loading: () => UserRole.employee,
        // عند الخطأ: أدنى لا أعلى. كان المبدّل يقع على `owner` في
        // `catch` — ومنح أعلى صلاحية لأن استعلامًا فشل لا يُدافَع عنه.
        error: (_, _) => UserRole.employee,
      );
});

/// يقرأ دور المستخدم الحالي من `CompanyMembers` للشركة النشطة.
///
/// الحالات الثلاث مقصودة ومتمايزة:
///   • لا شركة → الوضع الشخصي، و[UserRole.employee] كما كان
///   • لا مستخدم مسجَّل → الوضع المحلي: الجهاز جهازك فلا أحد تُحمى منه
///   • شركة ولا صفّ عضوية → منشئ الشركة، إذ لا يكتب المعالج صفًّا بعد
final userRoleInCompanyProvider = FutureProvider<UserRole>((ref) async {
  final company = ref.watch(activeCompanyProvider);
  if (company == null) return UserRole.employee;

  final userSyncId = ref.watch(currentUserSyncIdProvider);
  if (userSyncId == null) return UserRole.owner;

  final dao = ref.watch(companiesDaoProvider);
  final membership = await dao.getMembership(
    companySyncId: company.syncId,
    userSyncId: userSyncId,
  );

  if (membership == null) return UserRole.owner;
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
      : PlanType.free;

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