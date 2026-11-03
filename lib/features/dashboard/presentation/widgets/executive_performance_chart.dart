import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/neu_colors.dart';
import '../../../../shared/widgets/neu_card.dart';
import '../../providers/dashboard_metrics_provider.dart';
import '../../../../core/design/azm_tokens.dart';
import '../../../../core/utils/arabic_numerals.dart';

/// RVIOS dual-line performance chart — revenue against expenses.
///
/// Every point comes from stored revenue and expense records. The month labels
/// follow the calendar (the last six months ending with the current one), and
/// the vertical axis is scaled to the data instead of a fixed range.
class ExecutivePerformanceChart extends ConsumerWidget {
  final bool isDark;

  const ExecutivePerformanceChart({super.key, required this.isDark});

  static final _money = NumberFormat('#,##0', 'en');

  /// Rounds the axis maximum up to a readable step so gridlines land on round
  /// numbers whatever the magnitude of the data.
  static ({double max, double interval}) _axis(double dataMax) {
    if (dataMax <= 0) return (max: 100, interval: 25);
    final magnitude = math.pow(10, (math.log(dataMax) / math.ln10).floor());
    final step = (magnitude / 2).toDouble().clamp(1.0, double.infinity);
    final max = ((dataMax / step).ceil() * step).toDouble();
    return (max: max, interval: max / 4);
  }

  static String _compactAxis(double v) {
    if (v >= 1000000) {
      final m = v / 1000000;
      return '${m % 1 == 0 ? m.toInt() : m.toStringAsFixed(1)}م';
    }
    if (v >= 1000) {
      final k = v / 1000;
      return '${k % 1 == 0 ? k.toInt() : k.toStringAsFixed(1)}ألف';
    }
    return v.toInt().toString();
  }

  static String? _growthLabel(double? change) {
    if (change == null) return null;
    final pct = (change * 100).abs();
    final sign = change >= 0 ? '+' : '−';
    return '$sign${pct.toStringAsFixed(pct >= 10 ? 0 : 1)}٪ عن الشهر الماضي';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);

    return metricsAsync.when(
      loading: () => _ChartShell(
        isDark: isDark,
        monthsLabel: 'آخر ${toArabicDigits('$kDashboardSeriesMonths')} أشهر',
        body: const SizedBox(
          height: 155,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
          ),
        ),
      ),
      error: (err, _) => _ChartShell(
        isDark: isDark,
        monthsLabel: 'آخر ${toArabicDigits('$kDashboardSeriesMonths')} أشهر',
        body: _ChartNotice(
          icon: Icons.cloud_off_rounded,
          message: 'تعذّر تحميل بيانات الأداء.',
          isDark: isDark,
        ),
      ),
      data: (m) {
        final series = m.series;
        final hasMovement = series.any((p) => p.revenue > 0 || p.expenses > 0);

        final dataMax = series.fold<double>(
          0,
          (max, p) => math.max(max, math.max(p.revenue, p.expenses)),
        );
        final axis = _axis(dataMax);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _ChartShell(
              isDark: isDark,
              monthsLabel: 'آخر ${toArabicDigits('${series.length}')} أشهر',
              body: hasMovement
                  ? SizedBox(
                      height: 175,
                      child: LineChart(
                        _chartData(series, axis),
                        duration: const Duration(milliseconds: 450),
                      ),
                    )
                  : _ChartNotice(
                      icon: Icons.show_chart_rounded,
                      message:
                          'لا توجد حركات مالية مسجّلة في آخر ${toArabicDigits('${series.length}')} أشهر.',
                      isDark: isDark,
                    ),
            ),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _SummaryCard(
                      title: 'إجمالي الإيرادات',
                      amount: _money.format(m.totalRevenue),
                      currency: 'ريال سعودي',
                      growth: _growthLabel(m.revenueChange),
                      isPositive: (m.revenueChange ?? 0) >= 0,
                      icon: Icons.trending_up_rounded,
                      accentColor: NeuColors.success,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SummaryCard(
                      title: 'إجمالي المصروفات',
                      amount: _money.format(m.totalExpenses),
                      currency: 'ريال سعودي',
                      growth: _growthLabel(m.expensesChange),
                      // Rising expenses read as negative.
                      isPositive: (m.expensesChange ?? 0) < 0,
                      icon: Icons.trending_down_rounded,
                      accentColor: NeuColors.primary,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  LineChartData _chartData(
    List<MonthlyPoint> series,
    ({double max, double interval}) axis,
  ) {
    final gridColor = isDark
        ? Colors.white.withValues(alpha: 0.05)
        : Colors.black.withValues(alpha: 0.04);

    LineChartBarData bar(List<double> values, Color color, double fillAlpha) =>
        LineChartBarData(
          spots: [
            for (var i = 0; i < values.length; i++)
              FlSpot(i.toDouble(), values[i]),
          ],
          isCurved: true,
          curveSmoothness: 0.28,
          preventCurveOverShooting: true,
          color: color,
          barWidth: 2.5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (spot, percent, barData, index) =>
                FlDotCirclePainter(
                  radius: 3.5,
                  color: isDark ? NeuColors.surfaceDark : Colors.white,
                  strokeWidth: 2,
                  strokeColor: color,
                ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: LinearGradient(
              colors: [
                color.withValues(alpha: fillAlpha),
                color.withValues(alpha: 0.0),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        );

    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: false,
        horizontalInterval: axis.interval,
        getDrawingHorizontalLine: (value) =>
            FlLine(color: gridColor, strokeWidth: 1, dashArray: [5, 5]),
      ),
      titlesData: FlTitlesData(
        show: true,
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            // Wide enough for compact labels such as "1.5م" without clipping.
            reservedSize: 44,
            interval: axis.interval,
            getTitlesWidget: (value, meta) => Padding(
              padding: const EdgeInsetsDirectional.only(end: 6),
              child: Text(
                _compactAxis(value),
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 9,
                  fontFamily: AppTypography.fontFamilyBody,
                  color: isDark ? NeuColors.textHintDark : NeuColors.textHint,
                ),
              ),
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 24,
            interval: 1,
            getTitlesWidget: (value, meta) {
              final idx = value.round();
              if (idx < 0 || idx >= series.length) {
                return const SizedBox.shrink();
              }
              return Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  series[idx].label,
                  style: TextStyle(
                    fontSize: 9,
                    fontFamily: AppTypography.fontFamilyBody,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? NeuColors.textSecondaryDark
                        : NeuColors.textSecondary,
                  ),
                ),
              );
            },
          ),
        ),
      ),
      borderData: FlBorderData(show: false),
      minX: 0,
      maxX: (series.length - 1).toDouble(),
      minY: 0,
      maxY: axis.max,
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) =>
              isDark ? NeuColors.surfaceElevatedDark : NeuColors.textPrimary,
          getTooltipItems: (spots) => [
            for (final s in spots)
              LineTooltipItem(
                '${s.barIndex == 0 ? 'الإيرادات' : 'المصروفات'} '
                '${_money.format(s.y)}',
                TextStyle(
                  fontFamily: AppTypography.fontFamilyBody,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: s.barIndex == 0
                      ? NeuColors.success
                      : NeuColors.primaryLight,
                ),
              ),
          ],
        ),
      ),
      lineBarsData: [
        bar([for (final p in series) p.revenue], NeuColors.success, 0.20),
        bar([for (final p in series) p.expenses], NeuColors.primary, 0.14),
      ],
    );
  }
}

/// Card chrome shared by the loaded, loading, empty and error states.
class _ChartShell extends StatelessWidget {
  const _ChartShell({
    required this.body,
    required this.isDark,
    required this.monthsLabel,
  });

  final Widget body;
  final bool isDark;
  final String monthsLabel;

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      radius: AzmRadius.sm,
      elevation: 2,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      margin: EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'نظرة عامة على الأداء',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamilyHeading,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? NeuColors.textPrimaryDark
                            : NeuColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'الإيرادات مقابل المصروفات',
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamilyBody,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark
                            ? NeuColors.textSecondaryDark
                            : NeuColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              _PeriodPill(isDark: isDark, label: monthsLabel),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _LegendDot(
                color: NeuColors.success,
                label: 'الإيرادات',
                isDark: isDark,
              ),
              const SizedBox(width: 20),
              _LegendDot(
                color: NeuColors.primary,
                label: 'المصروفات',
                isDark: isDark,
              ),
            ],
          ),
          const SizedBox(height: 14),
          body,
        ],
      ),
    );
  }
}

class _ChartNotice extends StatelessWidget {
  const _ChartNotice({
    required this.icon,
    required this.message,
    required this.isDark,
  });

  final IconData icon;
  final String message;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final hint = isDark ? NeuColors.textHintDark : NeuColors.textHint;
    return SizedBox(
      height: 155,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 30, color: hint),
            const SizedBox(height: 10),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTypography.fontFamilyBody,
                fontSize: 12,
                height: 1.5,
                color: hint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Period label pill. The window is fixed, so this reports rather than selects.
class _PeriodPill extends StatelessWidget {
  const _PeriodPill({required this.isDark, required this.label});

  final bool isDark;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.06)
            : Colors.black.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.06),
          width: 0.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 12,
            color: isDark
                ? NeuColors.textSecondaryDark
                : NeuColors.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamilyBody,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? NeuColors.textSecondaryDark
                  : NeuColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Legend dot + label.
class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  final bool isDark;

  const _LegendDot({
    required this.color,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 28,
          height: 3,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTypography.fontFamilyBody,
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: isDark
                ? NeuColors.textSecondaryDark
                : NeuColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

/// Financial summary card below the chart.
class _SummaryCard extends StatelessWidget {
  final String title;
  final String amount;
  final String currency;

  /// Month-over-month text, or null when there is no prior month to compare.
  final String? growth;
  final bool isPositive;
  final IconData icon;
  final Color accentColor;
  final bool isDark;

  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.currency,
    required this.growth,
    required this.isPositive,
    required this.icon,
    required this.accentColor,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final trendColor = isPositive ? NeuColors.success : NeuColors.danger;

    return NeuCard(
      radius: AzmRadius.sm,
      padding: const EdgeInsets.all(14),
      margin: EdgeInsets.zero,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: accentColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamilyBody,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? NeuColors.textSecondaryDark
                        : NeuColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    amount,
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamilyHeading,
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                      height: 1.1,
                    ),
                  ),
                ),
                Text(
                  currency,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamilyBody,
                    fontSize: 9.5,
                    color: isDark ? NeuColors.textHintDark : NeuColors.textHint,
                  ),
                ),
                const SizedBox(height: 6),
                if (growth != null)
                  Row(
                    children: [
                      Icon(
                        isPositive
                            ? Icons.arrow_upward_rounded
                            : Icons.arrow_downward_rounded,
                        size: 11,
                        color: trendColor,
                      ),
                      const SizedBox(width: 2),
                      Flexible(
                        child: Text(
                          growth!,
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamilyBody,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                            color: trendColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                else
                  Text(
                    'لا توجد مقارنة بعد',
                    style: TextStyle(
                      fontFamily: AppTypography.fontFamilyBody,
                      fontSize: 9.5,
                      color: isDark
                          ? NeuColors.textHintDark
                          : NeuColors.textHint,
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
