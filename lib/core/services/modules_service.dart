import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../constants/enums.dart';

/// RVIOS — Modules Service
///
/// Manages which modules are active for the current company/plan.
/// Provides plan-based filtering and module enable/disable logic.
///
/// Module availability is determined by:
/// 1. Plan type (Free → Enterprise)
/// 2. Company custom module overrides (stored in company.settingsJson)
/// 3. User role (some modules are role-restricted even if plan allows them)
class ModulesService {
  const ModulesService._();
  static const ModulesService instance = ModulesService._();

  // ─────────────────────────────────────────────
  // Plan-based module availability
  // ─────────────────────────────────────────────

  /// Returns all modules available for the given plan
  List<AppModule> getAvailableModules(PlanType plan) {
    return AppModule.values
        .where((m) => m.isAvailableFor(plan))
        .toList();
  }

  /// Returns modules NOT available for the given plan (upgrade required)
  List<AppModule> getLockedModules(PlanType plan) {
    return AppModule.values
        .where((m) => !m.isAvailableFor(plan))
        .toList();
  }

  /// Checks if a specific module is available
  bool isModuleAvailable(AppModule module, PlanType plan) {
    return module.isAvailableFor(plan);
  }

  // ─────────────────────────────────────────────
  // Navigation modules (for building bottom nav + sidebar)
  // ─────────────────────────────────────────────

  /// Returns the navigation tabs to show based on plan and role.
  ///
  /// Always shows: Dashboard, More
  /// Plan-dependent: Tasks, Finance, HRM, Meetings, etc.
  List<NavModule> getNavigationModules({
    required PlanType plan,
    required UserRole role,
  }) {
    final modules = <NavModule>[];

    // Always visible
    modules.add(NavModule.dashboard);

    // Follow-ups (Free+)
    modules.add(NavModule.followups);

    // HRM (Business+, HR role or above)
    if (plan.value >= 2 && role.hasHrAccess) {
      modules.add(NavModule.hrm);
    }

    // Finance (Professional+, Finance role or above)
    if (plan.value >= 1 && role.hasFinanceAccess) {
      modules.add(NavModule.finance);
    }

    // More — always last
    modules.add(NavModule.more);

    return modules;
  }

  // ─────────────────────────────────────────────
  // Module groups for settings screen
  // ─────────────────────────────────────────────

  static const Map<String, List<AppModule>> moduleGroups = {
    'الأساسيات': [
      AppModule.dashboard,
      AppModule.tasks,
      AppModule.meetings,
      AppModule.calendar,
      AppModule.notes,
      AppModule.archive,
      AppModule.reminders,
    ],
    'الأعمال المحترفة': [
      AppModule.finance,
      AppModule.projects,
      AppModule.clients,
      AppModule.invoices,
      AppModule.reports,
    ],
    'إدارة الفريق': [
      AppModule.hrm,
      AppModule.payroll,
      AppModule.attendance,
      AppModule.followUps,
      AppModule.directives,
      AppModule.approvals,
      AppModule.contacts,
    ],
    'المؤسسة': [
      AppModule.branches,
      AppModule.auditLogs,
      AppModule.api,
      AppModule.sso,
    ],
  };
}

// ─────────────────────────────────────────────
// Navigation Module Enum
// ─────────────────────────────────────────────

/// Represents a main navigation tab in the app shell.
enum NavModule {
  dashboard('الرئيسية', '/home/dashboard'),
  followups('المتابعات', '/home/followups'),
  hrm('العاملون', '/home/hrm'),
  finance('المالية', '/home/finance'),
  more('المزيد', '/home/more');

  const NavModule(this.arabicLabel, this.route);
  final String arabicLabel;
  final String route;
}

// ─────────────────────────────────────────────
// Riverpod Providers
// ─────────────────────────────────────────────

/// Provides the ModulesService singleton
final modulesServiceProvider = Provider<ModulesService>((ref) {
  return ModulesService.instance;
});

/// Provides available modules for a given plan type
final availableModulesForPlanProvider =
    Provider.family<List<AppModule>, PlanType>((ref, plan) {
  return ModulesService.instance.getAvailableModules(plan);
});

/// Provides locked modules for a given plan type
final lockedModulesForPlanProvider =
    Provider.family<List<AppModule>, PlanType>((ref, plan) {
  return ModulesService.instance.getLockedModules(plan);
});