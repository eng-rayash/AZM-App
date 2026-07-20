import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/finance_repository.dart';
import '../../../core/database/providers/database_providers.dart';

/// Finance Reports Screen — comprehensive financial analytics dashboard.
class FinanceReportsScreen extends ConsumerWidget {
  const FinanceReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final textSecondary = NeuColors.textSecondaryFor(Theme.of(context).brightness);

    final now = DateTime.now();
    final from = DateTime(now.year, now.month, 1).toIso8601String().substring(0, 10);
    final to = now.toIso8601String().substring(0, 10);

    final summaryAsync = ref.watch(_financeSummaryProvider(
        _DateRange(from: from, to: to)));
    final invoicesAsync = ref.watch(invoicesListProvider);

    return Scaffold(
      backgroundColor: NeuColors.background(Theme.of(context).brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
        ),
        title: Text('التقارير المالية',
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
              // ── Period Header ─────────────────────────────────────
              NeuCard(
                isDark: isDark,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_rounded,
                        size: 18, color: NeuColors.navyDeep),
                    const SizedBox(width: 8),
                    Text('الشهر الحالي: $from ← $to',
                        style: AppTypography.bodySmall.copyWith(
                            color: textSecondary, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),

              AppSpacing.gapLg,

              // ── Revenue / Expenses / Profit KPIs ─────────────────
              _SectionTitle('ملخص الشهر', Icons.summarize_rounded, isDark: isDark),
              AppSpacing.gapMd,
              summaryAsync.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (_, _) => _buildManualSummary(ref, from, to, isDark),
                data: (s) => _buildKpiRow(s, isDark),
              ),

              AppSpacing.gapLg,

              // ── Revenue vs Expenses Chart ──────────────────────────
              _SectionTitle('الإيرادات مقابل المصروفات', Icons.bar_chart_rounded, isDark: isDark),
              AppSpacing.gapMd,
              summaryAsync.when(
                loading: () => const SizedBox(height: 200),
                error: (_, _) => const SizedBox.shrink(),
                data: (s) => NeuCard(
                  isDark: isDark,
                  child: SizedBox(
                    height: 200,
                    child: BarChart(
                      BarChartData(
                        alignment: BarChartAlignment.spaceAround,
                        maxY: [s['revenue'] ?? 0, s['expenses'] ?? 0]
                                .reduce((a, b) => a > b ? a : b) *
                            1.2,
                        barGroups: [
                          BarChartGroupData(x: 0, barRods: [
                            BarChartRodData(
                              toY: s['revenue'] ?? 0,
                              color: NeuColors.success,
                              width: 40,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ]),
                          BarChartGroupData(x: 1, barRods: [
                            BarChartRodData(
                              toY: s['expenses'] ?? 0,
                              color: NeuColors.danger,
                              width: 40,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ]),
                          BarChartGroupData(x: 2, barRods: [
                            BarChartRodData(
                              toY: (s['profit'] ?? 0) > 0 ? s['profit']! : 0,
                              color: (s['profit'] ?? 0) >= 0
                                  ? NeuColors.navyDeep
                                  : NeuColors.danger,
                              width: 40,
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                            ),
                          ]),
                        ],
                        titlesData: FlTitlesData(
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              getTitlesWidget: (val, _) {
                                switch (val.toInt()) {
                                  case 0: return const Text('إيرادات', style: TextStyle(fontSize: 10));
                                  case 1: return const Text('مصروفات', style: TextStyle(fontSize: 10));
                                  case 2: return const Text('صافي', style: TextStyle(fontSize: 10));
                                  default: return const SizedBox.shrink();
                                }
                              },
                            ),
                          ),
                          leftTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          topTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                          rightTitles: const AxisTitles(
                              sideTitles: SideTitles(showTitles: false)),
                        ),
                        gridData: FlGridData(
                          drawVerticalLine: false,
                          getDrawingHorizontalLine: (v) => FlLine(
                            color: NeuColors.divider.withOpacity(0.5),
                            strokeWidth: 1,
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                      ),
                    ),
                  ),
                ),
              ),

              AppSpacing.gapLg,

              // ── Invoice Status Distribution ────────────────────────
              _SectionTitle('حالة الفواتير', Icons.receipt_long_rounded, isDark: isDark),
              AppSpacing.gapMd,
              invoicesAsync.when(
                loading: () => const SizedBox(height: 120, child: Center(child: CircularProgressIndicator())),
                error: (_, _) => const SizedBox.shrink(),
                data: (invoices) {
                  final total = invoices.length;
                  if (total == 0) {
                    return NeuCard(
                      isDark: isDark,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text('لا توجد فواتير',
                              style: AppTypography.bodySmall.copyWith(
                                  color: NeuColors.textHint)),
                        ),
                      ),
                    );
                  }

                  final statusCount = <int, int>{};
                  for (final inv in invoices) {
                    statusCount[inv.status] = (statusCount[inv.status] ?? 0) + 1;
                  }

                  const statusNames = ['مسودة', 'مرسلة', 'مقبولة', 'مدفوعة', 'متأخرة', 'ملغاة'];
                  final statusColors = [
                    NeuColors.textHint,
                    NeuColors.info,
                    NeuColors.navyDeep,
                    NeuColors.success,
                    NeuColors.danger,
                    NeuColors.warning,
                  ];

                  return NeuCard(
                    isDark: isDark,
                    child: Column(
                      children: statusCount.entries.map((e) {
                        final name = e.key < statusNames.length ? statusNames[e.key] : '—';
                        final color = e.key < statusColors.length ? statusColors[e.key] : NeuColors.navyDeep;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 70,
                                child: Text(name,
                                    style: AppTypography.bodySmall.copyWith(color: textSecondary)),
                              ),
                              Expanded(
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: e.value / total,
                                    backgroundColor: color.withOpacity(0.1),
                                    valueColor: AlwaysStoppedAnimation(color),
                                    minHeight: 10,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text('${e.value}',
                                  style: AppTypography.bodySmall.copyWith(
                                      color: textSecondary, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        );
                      }).toList(),
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

  Widget _buildKpiRow(Map<String, double> s, bool isDark) {
    return Row(
      children: [
        Expanded(child: _KpiCard(
          label: 'إيرادات',
          value: '${(s['revenue'] ?? 0).toStringAsFixed(0)} ر.س',
          icon: Icons.trending_up_rounded,
          color: NeuColors.success,
          isDark: isDark,
        )),
        const SizedBox(width: 10),
        Expanded(child: _KpiCard(
          label: 'مصروفات',
          value: '${(s['expenses'] ?? 0).toStringAsFixed(0)} ر.س',
          icon: Icons.trending_down_rounded,
          color: NeuColors.danger,
          isDark: isDark,
        )),
        const SizedBox(width: 10),
        Expanded(child: _KpiCard(
          label: 'الصافي',
          value: '${(s['profit'] ?? 0).toStringAsFixed(0)} ر.س',
          icon: Icons.account_balance_rounded,
          color: (s['profit'] ?? 0) >= 0 ? NeuColors.navyDeep : NeuColors.danger,
          isDark: isDark,
        )),
      ],
    );
  }

  Widget _buildManualSummary(WidgetRef ref, String from, String to, bool isDark) {
    return FutureBuilder<Map<String, double>>(
      future: ref.read(databaseProvider).financeDao.getFinanceSummary(from, to),
      builder: (context, snap) {
        if (!snap.hasData) return const Center(child: CircularProgressIndicator());
        return _buildKpiRow(snap.data!, isDark);
      },
    );
  }
}

// ── Supporting Widgets ─────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.icon, {required this.isDark});
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

class _KpiCard extends StatelessWidget {
  const _KpiCard({
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
              style: AppTypography.bodySmall.copyWith(
                  color: color, fontWeight: FontWeight.w800),
              textAlign: TextAlign.center),
          const SizedBox(height: 2),
          Text(label,
              style: AppTypography.labelSmall.copyWith(color: NeuColors.textHint),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// Provider helpers
class _DateRange {
  const _DateRange({required this.from, required this.to});
  final String from, to;
}

final _financeSummaryProvider =
    FutureProvider.family<Map<String, double>, _DateRange>((ref, range) {
  final db = ref.watch(databaseProvider);
  return db.financeDao.getFinanceSummary(range.from, range.to);
});
