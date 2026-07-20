import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/hrm_repository.dart';


/// HRM Dashboard Screen — Human Resources Management main hub.
///
/// Entry point for all HR operations: employees, departments, payroll,
/// attendance, leaves, evaluations, and more.
class HrmScreen extends ConsumerWidget {
  const HrmScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(context.brightness);
    final textSecondary = NeuColors.textSecondaryFor(context.brightness);

    return Scaffold(
      backgroundColor: NeuColors.background(context.brightness),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            NeuColors.navyDeep,
                            NeuColors.navyMid,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.people_alt_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'شؤون العاملين',
                            style: AppTypography.headingMedium.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'إدارة الموارد البشرية',
                            style: AppTypography.bodySmall.copyWith(
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.push(RouteNames.globalSearch),
                      icon: Icon(
                        Icons.search_rounded,
                        color: NeuColors.navyDeep,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── KPI Cards (حية من قاعدة البيانات) ────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ref.watch(hrmKpisProvider).when(
                  loading: () => Row(
                    children: [
                      Expanded(child: _KpiCard(label: 'الموظفون', value: '...', icon: Icons.badge_rounded, color: NeuColors.navyDeep, isDark: isDark)),
                      const SizedBox(width: 10),
                      Expanded(child: _KpiCard(label: 'الحضور اليوم', value: '...', icon: Icons.how_to_reg_rounded, color: NeuColors.success, isDark: isDark)),
                      const SizedBox(width: 10),
                      Expanded(child: _KpiCard(label: 'إجازات معلقة', value: '...', icon: Icons.beach_access_rounded, color: NeuColors.warning, isDark: isDark)),
                    ],
                  ),
                  error: (err, stack) => const SizedBox.shrink(),
                  data: (kpis) => Row(
                    children: [
                      Expanded(
                        child: _KpiCard(
                          label: 'الموظفون',
                          value: '${kpis.activeEmployees}',
                          icon: Icons.badge_rounded,
                          color: NeuColors.navyDeep,
                          isDark: isDark,
                          onTap: () => context.push(RouteNames.employeesList),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _KpiCard(
                          label: 'إجازات معلقة',
                          value: '${kpis.pendingLeaves}',
                          icon: Icons.beach_access_rounded,
                          color: NeuColors.warning,
                          isDark: isDark,
                          onTap: () => context.push(RouteNames.leavesList),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _KpiCard(
                          label: 'عقود تنتهي',
                          value: '${kpis.expiringContracts}',
                          icon: Icons.assignment_late_rounded,
                          color: kpis.expiringContracts > 0 ? NeuColors.danger : NeuColors.success,
                          isDark: isDark,
                          onTap: () => context.push(RouteNames.contractsList),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Module Grid ──────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                delegate: SliverChildListDelegate([
                  _HrmModuleCard(
                    title: 'الموظفون',
                    subtitle: 'الملفات الشخصية',
                    icon: Icons.badge_rounded,
                    color: NeuColors.navyDeep,
                    onTap: () => context.push(RouteNames.employeesList),
                    isDark: isDark,
                  ),
                   _HrmModuleCard(
                    title: 'الحضور',
                    subtitle: 'التسجيل اليومي',
                    icon: Icons.fingerprint_rounded,
                    color: NeuColors.success,
                    onTap: () => context.push(RouteNames.attendance),
                    isDark: isDark,
                  ),
                  _HrmModuleCard(
                    title: 'الإجازات',
                    subtitle: 'طلبات الإجازة',
                    icon: Icons.beach_access_rounded,
                    color: NeuColors.info,
                    onTap: () => context.push(RouteNames.leavesList),
                    isDark: isDark,
                  ),
                  _HrmModuleCard(
                    title: 'الرواتب',
                    subtitle: 'مسير الرواتب',
                    icon: Icons.payments_rounded,
                    color: NeuColors.goldDark,
                    onTap: () => context.push(RouteNames.payroll),
                    isDark: isDark,
                  ),
                  _HrmModuleCard(
                    title: 'العقود',
                    subtitle: 'عقود العمل',
                    icon: Icons.description_rounded,
                    color: const Color(0xFF6C5CE7),
                    onTap: () => context.push(RouteNames.contractsList),
                    isDark: isDark,
                  ),
                  _HrmModuleCard(
                    title: 'الأقسام',
                    subtitle: 'الهيكل التنظيمي',
                    icon: Icons.account_tree_rounded,
                    color: NeuColors.navyMid,
                    onTap: () => context.push(RouteNames.departmentsList),
                    isDark: isDark,
                  ),
                  _HrmModuleCard(
                    title: 'التقييم',
                    subtitle: 'تقييم الأداء',
                    icon: Icons.star_rounded,
                    color: const Color(0xFFE17055),
                    onTap: () => context.push(RouteNames.evaluationsList),
                    isDark: isDark,
                  ),
                  _HrmModuleCard(
                    title: 'التدريب',
                    subtitle: 'برامج التطوير',
                    icon: Icons.school_rounded,
                    color: const Color(0xFF00B894),
                    onTap: () => context.push(RouteNames.trainingsList),
                    isDark: isDark,
                  ),
                  _HrmModuleCard(
                    title: 'السلف',
                    subtitle: 'سلف الموظفين',
                    icon: Icons.account_balance_wallet_rounded,
                    color: const Color(0xFFE84393),
                    onTap: () => context.push(RouteNames.advancesList),
                    isDark: isDark,
                  ),
                  _HrmModuleCard(
                    title: 'المكافآت',
                    subtitle: 'والجزاءات',
                    icon: Icons.emoji_events_rounded,
                    color: const Color(0xFFFDCB6E),
                    onTap: () =>
                        context.push(RouteNames.rewardsPenaltiesList),
                    isDark: isDark,
                  ),
                  _HrmModuleCard(
                    title: 'الفروع',
                    subtitle: 'المواقع والمكاتب',
                    icon: Icons.location_city_rounded,
                    color: const Color(0xFF74B9FF),
                    onTap: () => context.push(RouteNames.branchesList),
                    isDark: isDark,
                  ),
                  _HrmModuleCard(
                    title: 'التقارير',
                    subtitle: 'إحصائيات الموارد',
                    icon: Icons.analytics_rounded,
                    color: NeuColors.navyDeep,
                    onTap: () => context.push(RouteNames.hrmReports),
                    isDark: isDark,
                  ),
                ]),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),

      // FAB — Add Employee
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.employeeCreate),
        backgroundColor: NeuColors.navyDeep,
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(
          'موظف جديد',
          style: AppTypography.buttonLabel.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

// ── Supporting Widgets ─────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeuCard(
        isDark: isDark,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTypography.headingSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: NeuColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _HrmModuleCard extends StatelessWidget {
  const _HrmModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textPrimary = NeuColors.textPrimaryFor(context.brightness);
    final textSecondary = NeuColors.textSecondaryFor(context.brightness);

    return GestureDetector(
      onTap: onTap,
      child: NeuCard(
        isDark: isDark,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: NeuColors.textHint,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

extension on BuildContext {
  Brightness get brightness => Theme.of(this).brightness;
}
