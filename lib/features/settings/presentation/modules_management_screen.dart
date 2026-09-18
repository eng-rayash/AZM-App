import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/enums.dart';
import '../../../core/services/modules_service.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../features/company/providers/company_providers.dart';

/// RVIOS — Modules Management Screen
///
/// Allows company owners/admins to view and toggle which modules
/// are active in their workspace. Shows lock state for plan-restricted modules.
class ModulesManagementScreen extends ConsumerWidget {
  const ModulesManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final company = ref.watch(activeCompanyProvider);
    final activeModules = ref.watch(availableModulesProvider);

    final currentPlan = company != null
        ? PlanType.fromValue(company.planType)
        : PlanType.freePersonal;

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: isDark ? NeuColors.surfaceDark : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_rounded,
            color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'إدارة الوحدات',
          style: TextStyle(
            fontFamily: 'Panorama',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Plan Info Card ────────────────────────────────────
            _PlanInfoCard(plan: currentPlan, isDark: isDark),
            const SizedBox(height: 20),

            // ── Module Groups ─────────────────────────────────────
            ...ModulesService.moduleGroups.entries.map((entry) {
              return _ModuleGroupSection(
                title: entry.key,
                modules: entry.value,
                currentPlan: currentPlan,
                activeModules: activeModules,
                isDark: isDark,
              );
            }),

            const SizedBox(height: 32),

            // ── Upgrade CTA ───────────────────────────────────────
            if (currentPlan != PlanType.enterprise)
              _UpgradeCta(currentPlan: currentPlan, isDark: isDark),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Plan Info Card
// ─────────────────────────────────────────────

class _PlanInfoCard extends StatelessWidget {
  const _PlanInfoCard({required this.plan, required this.isDark});
  final PlanType plan;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [NeuColors.primary, NeuColors.primaryDark],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.layers_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'باقتك الحالية',
                  style: TextStyle(
                    fontFamily: 'Panorama',
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
                Text(
                  plan.arabicLabel,
                  style: const TextStyle(
                    fontFamily: 'Panorama',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: NeuColors.accentMuted,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              plan.isUnlimited ? 'âˆ‍ مستخدم' : '${plan.maxUsers} مستخدم',
              style: const TextStyle(
                fontFamily: 'Panorama',
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Module Group Section
// ─────────────────────────────────────────────

class _ModuleGroupSection extends StatelessWidget {
  const _ModuleGroupSection({
    required this.title,
    required this.modules,
    required this.currentPlan,
    required this.activeModules,
    required this.isDark,
  });

  final String title;
  final List<AppModule> modules;
  final PlanType currentPlan;
  final List<AppModule> activeModules;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 10, top: 4),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Panorama',
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? NeuColors.surfaceDark : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? NeuColors.borderDark : NeuColors.border,
            ),
          ),
          child: Column(
            children: modules.asMap().entries.map((entry) {
              final idx = entry.key;
              final module = entry.value;
              final isAvailable = module.isAvailableFor(currentPlan);
              final isActive = activeModules.contains(module);
              final isLast = idx == modules.length - 1;

              return Column(
                children: [
                  _ModuleRow(
                    module: module,
                    isAvailable: isAvailable,
                    isActive: isActive,
                    isDark: isDark,
                  ),
                  if (!isLast)
                    Divider(
                      height: 1,
                      color: isDark ? NeuColors.borderDark : NeuColors.border,
                      indent: 56,
                    ),
                ],
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

// ─────────────────────────────────────────────
// Module Row
// ─────────────────────────────────────────────

class _ModuleRow extends ConsumerWidget {
  const _ModuleRow({
    required this.module,
    required this.isAvailable,
    required this.isActive,
    required this.isDark,
  });

  final AppModule module;
  final bool isAvailable;
  final bool isActive;
  final bool isDark;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          // Module icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: isAvailable
                  ? NeuColors.primaryTint
                  : (isDark ? NeuColors.bgColorDark : NeuColors.bgColor),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              _moduleIcon(module),
              color: isAvailable ? NeuColors.primary : NeuColors.textHint,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),

          // Module name and plan requirement
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.arabicLabel,
                  style: TextStyle(
                    fontFamily: 'Panorama',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isAvailable
                        ? (isDark
                            ? NeuColors.textPrimaryDark
                            : NeuColors.textPrimary)
                        : NeuColors.textHint,
                  ),
                ),
                if (!isAvailable)
                  Text(
                    _minPlanLabel(module.minPlanIndex),
                    style: const TextStyle(
                      fontFamily: 'Panorama',
                      fontSize: 11,
                      color: NeuColors.accentMuted,
                    ),
                  ),
              ],
            ),
          ),

          // Toggle or lock
          if (isAvailable)
            Switch(
              value: isActive,
              onChanged: (enabled) {
                final notifier =
                    ref.read(disabledModulesProvider.notifier);
                notifier.update((current) {
                  final updated = Set<AppModule>.from(current);
                  if (enabled) {
                    updated.remove(module);
                  } else {
                    updated.add(module);
                  }
                  return updated;
                });
                final label = module.arabicLabel;
                final msg = enabled ? 'تم تفعيل “$label”' : 'تم إيقاف “$label”';
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    backgroundColor:
                        enabled ? NeuColors.success : NeuColors.textHint,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
              activeThumbColor: NeuColors.primary,
            )
          else
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: NeuColors.goldTint,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: NeuColors.accentMuted.withValues(alpha: 0.4)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.lock_outlined, size: 12, color: NeuColors.goldDark),
                  SizedBox(width: 4),
                  Text(
                    'ترقية',
                    style: TextStyle(
                      fontFamily: 'Panorama',
                      fontSize: 11,
                      color: NeuColors.goldDark,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  String _minPlanLabel(int planIndex) {
    switch (planIndex) {
      case 1: return 'متاح في Professional+';
      case 2: return 'متاح في Business+';
      case 3: return 'متاح في Enterprise';
      default: return '';
    }
  }

  IconData _moduleIcon(AppModule module) {
    switch (module) {
      case AppModule.dashboard: return Icons.dashboard_rounded;
      case AppModule.tasks: return Icons.task_alt_rounded;
      case AppModule.meetings: return Icons.groups_rounded;
      case AppModule.calendar: return Icons.calendar_month_rounded;
      case AppModule.notes: return Icons.note_rounded;
      case AppModule.archive: return Icons.archive_rounded;
      case AppModule.reminders: return Icons.alarm_rounded;
      case AppModule.finance: return Icons.account_balance_wallet_rounded;
      case AppModule.projects: return Icons.folder_special_rounded;
      case AppModule.clients: return Icons.people_alt_rounded;
      case AppModule.invoices: return Icons.receipt_long_rounded;
      case AppModule.reports: return Icons.bar_chart_rounded;
      case AppModule.hrm: return Icons.badge_rounded;
      case AppModule.payroll: return Icons.payments_rounded;
      case AppModule.attendance: return Icons.fingerprint_rounded;
      case AppModule.followUps: return Icons.track_changes_rounded;
      case AppModule.directives: return Icons.announcement_rounded;
      case AppModule.approvals: return Icons.approval_rounded;
      case AppModule.contacts: return Icons.contacts_rounded;
      case AppModule.branches: return Icons.account_tree_rounded;
      case AppModule.auditLogs: return Icons.security_rounded;
      case AppModule.api: return Icons.api_rounded;
      case AppModule.sso: return Icons.vpn_key_rounded;
    }
  }
}

// ─────────────────────────────────────────────
// Upgrade CTA
// ─────────────────────────────────────────────

class _UpgradeCta extends StatelessWidget {
  const _UpgradeCta({required this.currentPlan, required this.isDark});
  final PlanType currentPlan;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final nextPlan = _nextPlan(currentPlan);
    if (nextPlan == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: NeuColors.goldTint,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: NeuColors.accentMuted.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          const Icon(Icons.rocket_launch_rounded,
              color: NeuColors.accentMuted, size: 36),
          const SizedBox(height: 12),
          Text(
            'ترقية إلى ${nextPlan.arabicLabel}',
            style: const TextStyle(
              fontFamily: 'Panorama',
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: NeuColors.goldDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'احصل على وصول كامل لجميع الوحدات وإدارة ${nextPlan.isUnlimited ? "عدد غير محدود" : "حتى ${nextPlan.maxUsers}"} من المستخدمين',
            style: const TextStyle(
              fontFamily: 'Panorama',
              fontSize: 13,
              color: NeuColors.goldDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              key: const Key('btn_upgrade_plan'),
              onPressed: () => context.push('/subscription/pricing'),
              style: ElevatedButton.styleFrom(
                backgroundColor: NeuColors.accentMuted,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'اشترك الآن',
                style: TextStyle(
                  fontFamily: 'Panorama',
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  PlanType? _nextPlan(PlanType current) {
    final plans = PlanType.values;
    final idx = plans.indexOf(current);
    if (idx < plans.length - 1) return plans[idx + 1];
    return null;
  }
}