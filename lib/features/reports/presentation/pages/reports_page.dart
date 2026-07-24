import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/neu_colors.dart';
import '../../../../shared/widgets/neu_card.dart';
import '../../../../shared/widgets/neu_button.dart';
import '../../domain/export_service.dart';
import '../../providers/reports_provider.dart';

/// Reports Page — analytics dashboard with charts and exportable reports.
class ReportsPage extends ConsumerWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final analytics = ref.watch(reportsAnalyticsProvider);
    final completionRate = (analytics.taskCompletionRate * 100).toInt();

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor:
            isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        elevation: 0,
        title: Text(
          'التقارير والإحصائيات',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: AppSpacing.screen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // â”€â”€â”€ Quick Stats â”€â”€â”€
              _buildSectionTitle(
                  'إحصائيات سريعة', Icons.insights_rounded, isDark),
              AppSpacing.gapMd,

              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '${analytics.totalMeetings}',
                      'الاجتماعات',
                      Icons.groups_rounded,
                      NeuColors.info,
                      isDark,
                    ),
                  ),
                  AppSpacing.gapHMd,
                  Expanded(
                    child: _buildStatCard(
                      '${analytics.totalTasks}',
                      'المهام',
                      Icons.task_alt_rounded,
                      NeuColors.warning,
                      isDark,
                    ),
                  ),
                ],
              ),
              AppSpacing.gapMd,
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      '$completionRate%',
                      'نسبة الإنجاز',
                      Icons.trending_up_rounded,
                      NeuColors.success,
                      isDark,
                    ),
                  ),
                  AppSpacing.gapHMd,
                  Expanded(
                    child: _buildStatCard(
                      '${analytics.criticalDirectives}',
                      'توجيهات عاجلة',
                      Icons.priority_high_rounded,
                      NeuColors.danger,
                      isDark,
                    ),
                  ),
                ],
              ),

              AppSpacing.gapXxl,

              // â”€â”€â”€ Task Completion Pie Chart â”€â”€â”€
              _buildSectionTitle(
                  'توزيع حالات المهام', Icons.pie_chart_rounded, isDark),
              AppSpacing.gapMd,

              NeuCard(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: 200,
                  child: analytics.totalTasks > 0
                      ? PieChart(
                          PieChartData(
                            sectionsSpace: 3,
                            centerSpaceRadius: 40,
                            sections: [
                              PieChartSectionData(
                                value: analytics.completedTasks
                                    .toDouble(),
                                title: 'مكتمل',
                                color: NeuColors.success,
                                radius: 50,
                                titleStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: 'Panorama',
                                ),
                              ),
                              PieChartSectionData(
                                value: (analytics.totalTasks -
                                        analytics.completedTasks)
                                    .toDouble(),
                                title: 'متبقي',
                                color: NeuColors.warning,
                                radius: 50,
                                titleStyle: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  fontFamily: 'Panorama',
                                ),
                              ),
                            ],
                          ),
                        )
                      : Center(
                          child: Text(
                            'لا توجد بيانات كافية',
                            style: isDark
                                ? AppTypography.bodySmallDark
                                : AppTypography.bodySmall,
                          ),
                        ),
                ),
              ),

              AppSpacing.gapXxl,

              // â”€â”€â”€ Meetings Bar Chart â”€â”€â”€
              _buildSectionTitle(
                  'الاجتماعات (الأسبوع)', Icons.bar_chart_rounded, isDark),
              AppSpacing.gapMd,

              NeuCard(
                padding: const EdgeInsets.all(20),
                child: SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: 10,
                      barTouchData: BarTouchData(enabled: false),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final days = [
                                'أحد',
                                'إثنين',
                                'ثلاثا،',
                                'أربعا،',
                                'خميس',
                              ];
                              if (value.toInt() < days.length) {
                                return Text(
                                  days[value.toInt()],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontFamily: 'Panorama',
                                    color: isDark
                                        ? NeuColors.textHintDark
                                        : NeuColors.textHint,
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: const AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: false),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles:
                              SideTitles(showTitles: false),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      gridData: const FlGridData(show: false),
                      barGroups: List.generate(5, (i) {
                        return BarChartGroupData(
                          x: i,
                          barRods: [
                            BarChartRodData(
                              toY: (i + 1).toDouble() % 5 + 1,
                              color: isDark
                                  ? NeuColors.goldAccent
                                  : NeuColors.navyDeep,
                              width: 20,
                              borderRadius:
                                  const BorderRadius.vertical(
                                top: Radius.circular(6),
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                ),
              ),

              AppSpacing.gapXxl,

              // â”€â”€â”€ Exportable Reports â”€â”€â”€
              _buildSectionTitle(
                  'تقارير جاهزة', Icons.description_rounded, isDark),
              AppSpacing.gapMd,

              Row(
                children: [
                  Expanded(
                    child: NeuButton(
                      label: 'تقرير اليوم',
                      icon: Icons.today_rounded,
                      variant: NeuButtonVariant.primary,
                      onPressed: () async {
                        await ref
                            .read(exportServiceProvider)
                            .exportDailyReport(analytics);
                      },
                    ),
                  ),
                ],
              ),

              AppSpacing.gapXxl,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(
      String title, IconData icon, bool isDark) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
        ),
        AppSpacing.gapHSm,
        Text(
          title,
          style: isDark ? AppTypography.h4Dark : AppTypography.h4,
        ),
      ],
    );
  }

  Widget _buildStatCard(
    String value,
    String label,
    IconData icon,
    Color color,
    bool isDark,
  ) {
    return NeuCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.all(16),
      radius: 20,
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          AppSpacing.gapSm,
          Text(
            value,
            style: (isDark
                    ? AppTypography.statNumberDark
                    : AppTypography.statNumber)
                .copyWith(color: color, fontSize: 28),
          ),
          AppSpacing.gapXs,
          Text(
            label,
            style: isDark
                ? AppTypography.captionDark
                : AppTypography.caption,
          ),
        ],
      ),
    );
  }
}