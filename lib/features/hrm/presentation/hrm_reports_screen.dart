import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/hrm_repository.dart';

/// HRM Reports Screen — HR analytics and statistics dashboard.
class HrmReportsScreen extends ConsumerWidget {
  const HrmReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final textSecondary = NeuColors.textSecondaryFor(Theme.of(context).brightness);

    final kpisAsync = ref.watch(hrmKpisProvider);
    final employeesAsync = ref.watch(employeesListProvider);
    final leavesAsync = ref.watch(pendingLeavesProvider);

    return Scaffold(
      backgroundColor: NeuColors.background(Theme.of(context).brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
        ),
        title: Text('تقارير الموارد البشرية',
            style: AppTypography.headingSmall.copyWith(
                color: textPrimary, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: AppSpacing.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── KPI Summary ──────────────────────────────────────
              _SectionTitle(title: 'مؤشرات الأداء', icon: Icons.insights_rounded, isDark: isDark),
              AppSpacing.gapMd,
              kpisAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => const SizedBox.shrink(),
                data: (kpis) => Row(
                  children: [
                    Expanded(
                      child: _KpiTile(
                        label: 'الموظفون النشطون',
                        value: '${kpis.activeEmployees}',
                        icon: Icons.badge_rounded,
                        color: NeuColors.navyDeep,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _KpiTile(
                        label: 'إجازات معلقة',
                        value: '${kpis.pendingLeaves}',
                        icon: Icons.beach_access_rounded,
                        color: NeuColors.warning,
                        isDark: isDark,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _KpiTile(
                        label: 'عقود تنتهي',
                        value: '${kpis.expiringContracts}',
                        icon: Icons.assignment_late_rounded,
                        color: kpis.expiringContracts > 0 ? NeuColors.danger : NeuColors.success,
                        isDark: isDark,
                      ),
                    ),
                  ],
                ),
              ),

              AppSpacing.gapLg,

              // ── Gender Distribution Chart ─────────────────────────
              _SectionTitle(title: 'توزيع الموظفين', icon: Icons.pie_chart_rounded, isDark: isDark),
              AppSpacing.gapMd,
              employeesAsync.when(
                loading: () => const SizedBox(height: 180, child: Center(child: CircularProgressIndicator())),
                error: (err, stack) => const SizedBox.shrink(),
                data: (employees) {
                  final male = employees.where((e) => e.gender == 0).length;
                  final female = employees.where((e) => e.gender == 1).length;
                  final active = employees.where((e) => e.status == 0).length;
                  final inactive = employees.length - active;

                  return Row(
                    children: [
                      Expanded(
                        child: NeuCard(
                          isDark: isDark,
                          child: Column(
                            children: [
                              Text('حسب الجنس',
                                  style: AppTypography.bodySmall.copyWith(
                                      color: textSecondary, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 120,
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      if (male > 0) PieChartSectionData(
                                        value: male.toDouble(),
                                        color: NeuColors.navyDeep,
                                        title: 'ذكر\n$male',
                                        titleStyle: const TextStyle(
                                            fontSize: 10, color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                        radius: 50,
                                      ),
                                      if (female > 0) PieChartSectionData(
                                        value: female.toDouble(),
                                        color: const Color(0xFFE84393),
                                        title: 'أنثى\n$female',
                                        titleStyle: const TextStyle(
                                            fontSize: 10, color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                        radius: 50,
                                      ),
                                    ],
                                    centerSpaceRadius: 0,
                                    sectionsSpace: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: NeuCard(
                          isDark: isDark,
                          child: Column(
                            children: [
                              Text('حسب الحالة',
                                  style: AppTypography.bodySmall.copyWith(
                                      color: textSecondary, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 12),
                              SizedBox(
                                height: 120,
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      if (active > 0) PieChartSectionData(
                                        value: active.toDouble(),
                                        color: NeuColors.success,
                                        title: 'نشط\n$active',
                                        titleStyle: const TextStyle(
                                            fontSize: 10, color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                        radius: 50,
                                      ),
                                      if (inactive > 0) PieChartSectionData(
                                        value: inactive.toDouble(),
                                        color: NeuColors.danger,
                                        title: 'غير نشط\n$inactive',
                                        titleStyle: const TextStyle(
                                            fontSize: 10, color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                        radius: 50,
                                      ),
                                    ],
                                    centerSpaceRadius: 0,
                                    sectionsSpace: 2,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),

              AppSpacing.gapLg,

              // ── Leave Types Analysis ───────────────────────────────
              _SectionTitle(title: 'تحليل الإجازات', icon: Icons.beach_access_rounded, isDark: isDark),
              AppSpacing.gapMd,
              leavesAsync.when(
                loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
                error: (err, stack) => const SizedBox.shrink(),
                data: (leaves) {
                  final typeCount = <int, int>{};
                  for (final l in leaves) {
                    typeCount[l.leaveType] = (typeCount[l.leaveType] ?? 0) + 1;
                  }
                  const typeNames = ['سنوية', 'مرضية', 'طارئة', 'أمومة', 'غير مدفوعة', 'تعويضية', 'أخرى'];
                  final colors = [NeuColors.info, NeuColors.success, NeuColors.warning,
                    const Color(0xFFE84393), NeuColors.textHint, NeuColors.goldDark, NeuColors.navyMid];

                  return NeuCard(
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (leaves.isEmpty)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Text('لا توجد بيانات إجازات',
                                  style: AppTypography.bodySmall.copyWith(color: NeuColors.textHint)),
                            ),
                          )
                        else
                          ...typeCount.entries.map((e) {
                            final name = e.key < typeNames.length ? typeNames[e.key] : '—';
                            final color = e.key < colors.length ? colors[e.key] : NeuColors.navyDeep;
                            final pct = leaves.isNotEmpty
                                ? (e.value / leaves.length * 100).toInt() : 0;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: 80,
                                    child: Text(name,
                                        style: AppTypography.bodySmall.copyWith(color: textSecondary)),
                                  ),
                                  Expanded(
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: e.value / leaves.length,
                                        backgroundColor: color.withOpacity(0.12),
                                        valueColor: AlwaysStoppedAnimation(color),
                                        minHeight: 10,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text('${e.value} ($pct%)',
                                      style: AppTypography.labelSmall.copyWith(
                                          color: textSecondary, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            );
                          }),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon, required this.isDark});
  final String title;
  final IconData icon;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    return Row(
      children: [
        Icon(icon, color: NeuColors.navyDeep, size: 20),
        const SizedBox(width: 8),
        Text(title,
            style: AppTypography.headingSmall.copyWith(
                color: textPrimary, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
  });
  final String label, value;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      isDark: isDark,
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(value,
              style: AppTypography.headingMedium.copyWith(
                  color: color, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTypography.labelSmall.copyWith(color: NeuColors.textHint),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}
