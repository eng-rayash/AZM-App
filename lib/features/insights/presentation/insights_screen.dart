import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/azm_tokens.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/azm_list.dart';
import '../../../shared/widgets/azm_screen.dart';
import '../../dashboard/providers/dashboard_metrics_provider.dart';

/// AZM — الذكاء
///
/// عمود INTELLIGENCE. يجيب عن: **ماذا يحدث ولماذا؟**
///
/// مؤشر صحة الأعمال يتصدّر لأنه الرقم الوحيد الذي يلخّص البقية. وحين
/// لا تكفي البيانات لحسابه، تُعرض العبارة صراحةً بدل رقم مُختلق — قاعدة
/// عزم: لا مؤشر بلا بيانات.
class InsightsScreen extends ConsumerWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final metricsAsync = ref.watch(dashboardMetricsProvider);

    return AzmScreen(
      title: 'الذكاء',
      caption: 'ماذا يحدث ولماذا',
      slivers: [
        SliverToBoxAdapter(
          child: metricsAsync.when(
            loading: () => const _HealthSkeleton(),
            error: (_, _) => const _HealthUnavailable(
              reason: 'تعذّرت قراءة البيانات',
            ),
            data: (m) {
              final score = m.healthScore;
              if (score == null) {
                return const _HealthUnavailable(
                  reason: 'بيانات غير كافية',
                  hint: 'سجّل إيرادًا أو متابعة ليبدأ حساب المؤشر',
                );
              }
              return _HealthBlock(
                score: score,
                label: m.healthLabel ?? '',
                factors: m.healthFactors,
              );
            },
          ),
        ),

        // ── التقارير ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'التقارير',
            caption: 'ما جرى، مجمَّعًا',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(rows: [
            AzmNavRow(
              title: 'التقارير العامة',
              subtitle: 'الاجتماعات والمتابعات والتوجيهات',
              icon: Icons.summarize_outlined,
              onTap: () => context.push(RouteNames.reports),
            ),
            AzmNavRow(
              title: 'التقارير المالية',
              subtitle: 'الإيراد والمصروف والربح',
              icon: Icons.query_stats_rounded,
              onTap: () => context.push(RouteNames.financeReports),
            ),
            AzmNavRow(
              title: 'تقارير الموارد البشرية',
              subtitle: 'الحضور والإجازات والقوى العاملة',
              icon: Icons.groups_outlined,
              onTap: () => context.push(RouteNames.hrmReports),
            ),
          ]),
        ),

        // ── المحاسبة ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: AzmSectionHeader(
            title: 'المحاسبة',
            caption: 'الدفاتر التي تُبنى عليها الأرقام',
          ),
        ),
        SliverToBoxAdapter(
          child: AzmRowGroup(rows: [
            AzmNavRow(
              title: 'دليل الحسابات',
              icon: Icons.account_tree_outlined,
              onTap: () => context.push(RouteNames.chartOfAccounts),
            ),
            AzmNavRow(
              title: 'القيود اليومية',
              icon: Icons.menu_book_outlined,
              onTap: () => context.push(RouteNames.journalEntries),
            ),
            AzmNavRow(
              title: 'السندات',
              subtitle: 'القبض والصرف',
              icon: Icons.receipt_outlined,
              onTap: () => context.push(RouteNames.paymentVouchersList),
            ),
            AzmNavRow(
              title: 'الحسابات البنكية',
              icon: Icons.account_balance_wallet_outlined,
              onTap: () => context.push(RouteNames.bankAccountsList),
            ),
          ]),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Business Health
// ─────────────────────────────────────────────────────────────

/// مؤشر صحة الأعمال — رقم واحد كبير، ثم ما يفسّره.
class _HealthBlock extends StatelessWidget {
  const _HealthBlock({
    required this.score,
    required this.label,
    required this.factors,
  });

  final int score;
  final String label;
  final List<HealthFactor> factors;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    // أضعف عامل هو ما يستحق الانتباه — لا أقواها.
    final weakest = factors.isEmpty
        ? null
        : (List<HealthFactor>.from(factors)
              ..sort((a, b) => a.ratio.compareTo(b.ratio)))
            .first;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AzmSpace.screenGutter,
        AzmSpace.lg,
        AzmSpace.screenGutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$score',
                style: AppTypography.statNumber.copyWith(
                  color: p.ink,
                  fontSize: 68,
                  height: 1.0,
                ),
              ),
              const SizedBox(width: AzmSpace.sm),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  label,
                  style: AppTypography.body.copyWith(
                    color: p.inkMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AzmSpace.xxs),
          Text(
            'صحة الأعمال — من ١٠٠',
            style: AppTypography.caption.copyWith(color: p.inkFaint),
          ),
          const SizedBox(height: AzmSpace.xl),

          // عوامل المؤشر — كل عامل شريط أفقي بنسبته
          for (final f in factors) ...[
            _FactorBar(factor: f),
            const SizedBox(height: AzmSpace.md),
          ],

          if (weakest != null) ...[
            const SizedBox(height: AzmSpace.xs),
            Container(
              padding: const EdgeInsets.all(AzmSpace.md),
              decoration: BoxDecoration(
                color: p.surfaceSunken,
                border: Border(
                  right: BorderSide(color: p.ink, width: 2),
                ),
              ),
              child: Text(
                'أكثر ما يخفض المؤشر الآن: ${weakest.label}.',
                style: AppTypography.bodySmall.copyWith(
                  color: p.inkMuted,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// عامل واحد من عوامل المؤشر — اسم، نسبة، شريط.
class _FactorBar extends StatelessWidget {
  const _FactorBar({required this.factor});

  final HealthFactor factor;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final ratio = factor.ratio.clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                factor.label,
                style: AppTypography.bodySmall.copyWith(color: p.inkMuted),
              ),
            ),
            Text(
              '${factor.points} / ${factor.weight}',
              style: AppTypography.bodySmall.copyWith(
                color: p.inkFaint,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: AzmSpace.sm),
        // الشريط: أرض شعرية بارتفاع ٣، وحبر يملأ النسبة
        SizedBox(
          height: 3,
          child: Stack(
            children: [
              Container(color: p.hairline),
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(color: p.ink),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// حين لا تكفي البيانات — نقول ذلك، ولا نعرض رقمًا.
class _HealthUnavailable extends StatelessWidget {
  const _HealthUnavailable({required this.reason, this.hint});

  final String reason;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AzmSpace.screenGutter,
        AzmSpace.lg,
        AzmSpace.screenGutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            reason,
            style: AppTypography.h3.copyWith(color: p.inkMuted),
          ),
          if (hint != null) ...[
            const SizedBox(height: AzmSpace.xs),
            Text(
              hint!,
              style: AppTypography.bodySmall.copyWith(
                color: p.inkFaint,
                height: 1.6,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// هيكل انتظار — يحجز مكان الرقم بلا وميض ولا دوران.
class _HealthSkeleton extends StatelessWidget {
  const _HealthSkeleton();

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AzmSpace.screenGutter,
        AzmSpace.lg,
        AzmSpace.screenGutter,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 96, height: 60, color: p.surfaceSunken),
          const SizedBox(height: AzmSpace.md),
          Container(width: 150, height: 12, color: p.surfaceSunken),
        ],
      ),
    );
  }
}
