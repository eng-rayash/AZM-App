import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/neu_colors.dart';
import '../../../../shared/widgets/neu_card.dart';
import '../../providers/dashboard_metrics_provider.dart';
import '../../../../core/design/azm_tokens.dart';

/// RVIOS Executive KPI Grid — four headline figures, all from stored records.
///
/// Laid out 2×2 rather than as a single row of four: on a phone four columns
/// leave ~80 logical pixels per card, which forces 9–10pt type and truncated
/// values. Two columns give each figure room to be read at a glance.
class KpiQuickGrid extends ConsumerWidget {
  final bool isDark;

  const KpiQuickGrid({super.key, required this.isDark});

  /// Compact money formatting: 1.2م / 340ألف / 850.
  static String formatCompact(double amount) {
    if (amount <= 0) return '0';
    if (amount >= 1000000) {
      final v = amount / 1000000;
      return '${v % 1 == 0 ? v.toInt() : v.toStringAsFixed(1)} م';
    }
    if (amount >= 1000) {
      final v = amount / 1000;
      return '${v % 1 == 0 ? v.toInt() : v.toStringAsFixed(1)} ألف';
    }
    return amount.toStringAsFixed(0);
  }

  static String? _percent(double? change) {
    if (change == null) return null;
    final pct = (change * 100).abs();
    final sign = change >= 0 ? '+' : '−';
    return '$sign${pct.toStringAsFixed(pct >= 10 ? 0 : 1)}٪';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);

    return metricsAsync.when(
      loading: () => _KpiGridFrame(
        children: List.generate(4, (_) => _KpiSkeleton(isDark: isDark)),
      ),
      error: (err, _) => _KpiGridFrame(
        children: List.generate(4, (_) => _KpiUnavailable(isDark: isDark)),
      ),
      data: (m) => _KpiGridFrame(
        children: [
          _KpiCard(
            title: 'الإيرادات',
            value: formatCompact(m.totalRevenue),
            unit: 'ريال',
            icon: Icons.trending_up_rounded,
            accent: NeuColors.success,
            trend: _percent(m.revenueChange),
            // Growing revenue is good news.
            trendPositive: m.revenueChange == null
                ? null
                : m.revenueChange! >= 0,
            trendCaption: 'عن الشهر الماضي',
            isDark: isDark,
          ),
          _KpiCard(
            title: 'المصروفات',
            value: formatCompact(m.totalExpenses),
            unit: 'ريال',
            icon: Icons.receipt_long_rounded,
            accent: NeuColors.danger,
            trend: _percent(m.expensesChange),
            // Growing expenses is not.
            trendPositive: m.expensesChange == null
                ? null
                : m.expensesChange! < 0,
            trendCaption: 'عن الشهر الماضي',
            isDark: isDark,
          ),
          _KpiCard(
            title: 'المشاريع',
            value: '${m.activeProjects}',
            unit: 'نشط',
            icon: Icons.rocket_launch_rounded,
            accent: NeuColors.primary,
            trend: m.newProjectsThisMonth > 0
                ? '+${m.newProjectsThisMonth}'
                : null,
            trendPositive: true,
            trendCaption: 'هذا الشهر',
            isDark: isDark,
          ),
          _KpiCard(
            title: 'المتابعات',
            value: '${m.pendingFollowUps}',
            unit: 'معلّقة',
            icon: Icons.task_alt_rounded,
            accent: NeuColors.accentMuted,
            trend: m.overdueFollowUps > 0 ? '${m.overdueFollowUps}' : null,
            trendPositive: false,
            trendCaption: 'متأخّرة',
            isDark: isDark,
          ),
        ],
      ),
    );
  }
}

/// 2×2 layout shared by the loaded, loading and error states so the grid never
/// changes height as data arrives.
class _KpiGridFrame extends StatelessWidget {
  const _KpiGridFrame({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    // IntrinsicHeight gives the Row a concrete height first, so the two cards
    // can stretch to match each other. A bare `CrossAxisAlignment.stretch`
    // here sits under an unbounded vertical constraint, which asserts in debug
    // and lays out to nothing in release.
    Widget row(Widget start, Widget end) => IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: start),
          const SizedBox(width: 12),
          Expanded(child: end),
        ],
      ),
    );

    return Column(
      children: [
        row(children[0], children[1]),
        const SizedBox(height: 12),
        row(children[2], children[3]),
      ],
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.title,
    required this.value,
    required this.unit,
    required this.icon,
    required this.accent,
    required this.trend,
    required this.trendPositive,
    required this.trendCaption,
    required this.isDark,
  });

  final String title;
  final String value;
  final String unit;
  final IconData icon;
  final Color accent;

  /// Formatted delta, or null when there is nothing to compare against.
  final String? trend;
  final bool? trendPositive;
  final String trendCaption;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textPrimary = isDark
        ? NeuColors.textPrimaryDark
        : NeuColors.textPrimary;
    final textSecondary = isDark
        ? NeuColors.textSecondaryDark
        : NeuColors.textSecondary;

    final trendColor = trendPositive == null
        ? textSecondary
        : (trendPositive! ? NeuColors.success : NeuColors.danger);

    return NeuCard(
      radius: AzmRadius.sm,
      elevation: 1,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, color: accent, size: 18),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamilyBody,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamilyHeading,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: textPrimary,
                    height: 1.0,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 5),
              Text(
                unit,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamilyBody,
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Reserve the trend row's height even when there is no delta, so the
          // four cards stay aligned.
          SizedBox(
            height: 20,
            child: trend == null
                ? const SizedBox.shrink()
                : Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: trendColor.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          trend!,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamilyBody,
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: trendColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          trendCaption,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamilyBody,
                            fontSize: 10,
                            color: isDark
                                ? NeuColors.textHintDark
                                : NeuColors.textHint,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Placeholder bars shown while the first query is still running.
class _KpiSkeleton extends StatelessWidget {
  const _KpiSkeleton({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final base = isDark
        ? Colors.white.withValues(alpha: 0.06)
        : Colors.black.withValues(alpha: 0.05);

    Widget bar(double width, double height) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: base,
        borderRadius: BorderRadius.circular(6),
      ),
    );

    return NeuCard(
      radius: AzmRadius.sm,
      elevation: 1,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [bar(34, 34), const SizedBox(width: 10), bar(56, 10)]),
          const SizedBox(height: 14),
          bar(84, 22),
          const SizedBox(height: 14),
          bar(64, 10),
        ],
      ),
    );
  }
}

/// Shown when the query failed — an explicit "no value" instead of a
/// plausible-looking number.
class _KpiUnavailable extends StatelessWidget {
  const _KpiUnavailable({required this.isDark});

  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final hint = isDark ? NeuColors.textHintDark : NeuColors.textHint;
    return NeuCard(
      radius: AzmRadius.sm,
      elevation: 1,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off_rounded, size: 20, color: hint),
          const SizedBox(height: 12),
          Text(
            '—',
            style: TextStyle(
              fontFamily: AppTypography.fontFamilyHeading,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: hint,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 20,
            child: Text(
              'تعذّر التحميل',
              style: TextStyle(
                fontFamily: AppTypography.fontFamilyBody,
                fontSize: 10,
                color: hint,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
