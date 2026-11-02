import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/neu_colors.dart';
import '../../../../shared/widgets/neu_card.dart';
import '../../providers/dashboard_metrics_provider.dart';
import '../../../../core/design/azm_tokens.dart';

/// RVIOS Business Health Score — a single figure derived from real records.
///
/// The score is the weighted average of the factors in [DashboardMetrics]
/// (profit margin, follow-up completion, on-time rate, collection). Each
/// factor is listed under the gauge so the number is auditable rather than
/// decorative, and the card falls back to an onboarding state when there is
/// nothing recorded yet.
class ExecutiveHealthCard extends ConsumerWidget {
  final bool isDark;

  const ExecutiveHealthCard({super.key, required this.isDark});

  static Color scoreColor(int score) {
    if (score >= 85) return NeuColors.success;
    if (score >= 70) return const Color(0xFF3BA55D);
    if (score >= 50) return NeuColors.warning;
    return NeuColors.danger;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);

    return metricsAsync.when(
      loading: () => _HealthShell(
        isDark: isDark,
        child: const SizedBox(
          height: 96,
          child: Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2.2),
            ),
          ),
        ),
      ),
      error: (err, _) => _HealthShell(
        isDark: isDark,
        child: _HealthMessage(
          icon: Icons.cloud_off_rounded,
          title: 'تعذّر حساب مؤشر الصحة',
          subtitle: 'لم يتم الوصول إلى بيانات الأعمال.',
          isDark: isDark,
        ),
      ),
      data: (m) {
        final score = m.healthScore;
        if (score == null) {
          return _HealthShell(
            isDark: isDark,
            child: _HealthMessage(
              icon: Icons.insights_rounded,
              title: 'مؤشر الصحة غير متاح بعد',
              subtitle:
                  'سجّل إيراداً أو متابعة ليبدأ المؤشر بقياس أداء أعمالك.',
              isDark: isDark,
            ),
          );
        }

        final color = scoreColor(score);
        return _HealthShell(
          isDark: isDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Gauge(score: score, color: color, isDark: isDark),
                  const SizedBox(width: 18),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'مؤشر الصحة العامة',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamilyBody,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? NeuColors.textSecondaryDark
                                : NeuColors.textSecondary,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: color.withValues(alpha: 0.25),
                              width: 1,
                            ),
                          ),
                          child: Text(
                            m.healthLabel ?? '',
                            style: TextStyle(
                              fontFamily: AppTypography.fontFamilyBody,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'محسوب من ${m.healthFactors.length} عوامل قياس',
                          style: TextStyle(
                            fontFamily: AppTypography.fontFamilyBody,
                            fontSize: 11,
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
              const SizedBox(height: 16),
              Divider(
                height: 1,
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.06),
              ),
              const SizedBox(height: 14),
              // Factor breakdown — what actually moved the number.
              for (final f in m.healthFactors) ...[
                _FactorRow(factor: f, isDark: isDark),
                if (f != m.healthFactors.last) const SizedBox(height: 10),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _HealthShell extends StatelessWidget {
  const _HealthShell({required this.child, required this.isDark});

  final Widget child;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      radius: AzmRadius.sm,
      elevation: 2,
      padding: const EdgeInsets.all(20),
      gradientColors:
          isDark ? [const Color(0xFF1C1F24), const Color(0xFF1A1D20)] : null,
      backgroundColor: isDark ? null : NeuColors.surfaceElevated,
      child: child,
    );
  }
}

class _HealthMessage extends StatelessWidget {
  const _HealthMessage({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isDark,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final hint = isDark ? NeuColors.textHintDark : NeuColors.textHint;
    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: hint.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, color: hint, size: 22),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamilyHeading,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? NeuColors.textPrimaryDark
                      : NeuColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamilyBody,
                  fontSize: 11.5,
                  height: 1.5,
                  color: hint,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// One factor with its contribution rendered as a slim progress track.
class _FactorRow extends StatelessWidget {
  const _FactorRow({required this.factor, required this.isDark});

  final HealthFactor factor;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final ratio = factor.ratio.clamp(0.0, 1.0);
    final color = ExecutiveHealthCard.scoreColor((ratio * 100).round());

    return Row(
      children: [
        SizedBox(
          width: 96,
          child: Text(
            factor.label,
            style: TextStyle(
              fontFamily: AppTypography.fontFamilyBody,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? NeuColors.textSecondaryDark
                  : NeuColors.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ratio,
              minHeight: 6,
              backgroundColor: isDark
                  ? Colors.white.withValues(alpha: 0.07)
                  : Colors.black.withValues(alpha: 0.06),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 34,
          child: Text(
            '${(ratio * 100).round()}٪',
            textAlign: TextAlign.end,
            style: TextStyle(
              fontFamily: AppTypography.fontFamilyHeading,
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color:
                  isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}

/// Circular arc gauge. The score appears once, in the centre of the ring.
class _Gauge extends StatelessWidget {
  const _Gauge({
    required this.score,
    required this.color,
    required this.isDark,
  });

  final int score;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 88,
      height: 88,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 88,
            height: 88,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 8,
              backgroundColor: Colors.transparent,
              valueColor: AlwaysStoppedAnimation<Color>(
                isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : Colors.black.withValues(alpha: 0.06),
              ),
            ),
          ),
          SizedBox(
            width: 88,
            height: 88,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: score / 100.0),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) => CircularProgressIndicator(
                value: value,
                strokeWidth: 8,
                backgroundColor: Colors.transparent,
                strokeCap: StrokeCap.round,
                valueColor: AlwaysStoppedAnimation<Color>(color),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$score',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamilyHeading,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? NeuColors.textPrimaryDark
                      : NeuColors.textPrimary,
                  height: 1.0,
                ),
              ),
              Text(
                '٪',
                style: TextStyle(
                  fontFamily: AppTypography.fontFamilyBody,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
