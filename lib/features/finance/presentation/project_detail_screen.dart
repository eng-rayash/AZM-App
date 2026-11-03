import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/related_entities_widget.dart';
import '../domain/finance_repository.dart';
import '../../../core/router/route_names.dart';
import '../../../core/constants/app_currencies.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../core/constants/enums.dart';
import '../../../core/design/azm_tokens.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Project Detail Screen
// ─────────────────────────────────────────────────────────────────────────────
class ProjectDetailScreen extends ConsumerWidget {
  const ProjectDetailScreen({super.key, required this.projectId});
  final int projectId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final projectsAsync = ref.watch(projectsListProvider);

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      body: projectsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(error: e),
        data: (projects) {
          final project = projects.firstWhere(
            (p) => p.id == projectId,
            orElse: () => projects.first,
          );
          return _ProjectDetailBody(project: project, isDark: isDark);
        },
      ),
    );
  }
}

class _ProjectDetailBody extends StatelessWidget {
  const _ProjectDetailBody({required this.project, required this.isDark});
  final Project project;
  final bool isDark;

  static const _statusLabels = ['جديد', 'نشط', 'مكتمل', 'مؤجل', 'ملغي'];
  static const _statusColors = [
    NeuColors.info, NeuColors.success, NeuColors.navyDeep,
    NeuColors.warning, NeuColors.danger,
  ];

  Color get _statusColor =>
      _statusColors[project.status.clamp(0, _statusColors.length - 1)];
  String get _statusLabel =>
      _statusLabels[project.status.clamp(0, _statusLabels.length - 1)];

  @override
  Widget build(BuildContext context) {
    final CurrencyInfo currency = AppCurrencies.fromCode(project.currency);
    final budget = project.budget;
    final spent = project.actualCost;
    final progress = budget > 0 ? (spent / budget).clamp(0.0, 1.0) : 0.0;
    final progressPct = (progress * 100).toInt();

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          expandedHeight: 230,
          backgroundColor: isDark ? NeuColors.bgColorDark : const Color(0xFFE17055),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.white),
              onPressed: () => context.push(RouteNames.projectEditPath(project.id)),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFE17055), Color(0xFFD63031)],
                  begin: Alignment.topRight, end: Alignment.bottomLeft,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _statusColor.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: Colors.white54),
                          ),
                          child: Text(_statusLabel,
                              style: const TextStyle(color: Colors.white,
                                  fontSize: 12, fontFamily: 'Panorama')),
                        ),
                        const Spacer(),
                        if (project.endDate != null)
                          Text('⏰ ${project.endDate}',
                              style: const TextStyle(color: Colors.white70,
                                  fontSize: 12, fontFamily: 'Panorama')),
                      ]),
                      const SizedBox(height: 10),
                      Text(project.name, style: const TextStyle(
                          color: Colors.white, fontSize: 22,
                          fontWeight: FontWeight.w800, fontFamily: 'Panorama')),
                      if (project.description != null)
                        Text(project.description!,
                            maxLines: 2, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white70,
                                fontSize: 13, fontFamily: 'Panorama')),
                      // Progress bar
                      const SizedBox(height: 12),
                      Row(children: [
                        Text('$progressPct%', style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w700,
                            fontSize: 13, fontFamily: 'Panorama')),
                        const SizedBox(width: 10),
                        Expanded(child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            backgroundColor: Colors.white24,
                            valueColor: const AlwaysStoppedAnimation(Colors.white),
                            minHeight: 6,
                          ),
                        )),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        SliverToBoxAdapter(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(children: [
              // ── Budget Cards ──────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(children: [
                  Expanded(child: _BudgetCard(
                    label: 'الميزانية', value: budget,
                    currency: currency, isDark: isDark,
                    color: NeuColors.navyDeep,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _BudgetCard(
                    label: 'المنفق', value: spent,
                    currency: currency, isDark: isDark,
                    color: NeuColors.warning,
                  )),
                  const SizedBox(width: 10),
                  Expanded(child: _BudgetCard(
                    label: 'المتبقي', value: (budget - spent).clamp(0, double.infinity),
                    currency: currency, isDark: isDark,
                    color: NeuColors.success,
                  )),
                ]),
              ),

              // ── Details Card ──────────────────────────────────
              NeuCard(
                isDark: isDark, radius: AzmRadius.sm,
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                padding: const EdgeInsets.all(16),
                child: Column(children: [
                  if (project.startDate != null)
                    _row('تاريخ البدء', project.startDate!, isDark),
                  if (project.endDate != null)
                    _row('تاريخ التسليم', project.endDate!, isDark),
                  _row('العملة', '${currency.nameAr} (${currency.code})', isDark),
                  if (project.notes != null && project.notes!.isNotEmpty)
                    _row('ملاحظات', project.notes!, isDark),
                ]),
              ),

              // ── Related Entities ──────────────────────────────
              const SizedBox(height: 8),
              RelatedEntitiesWidget(
                sourceType: EntityLinkType.project,
                sourceId: project.id,
                sourceLabel: project.name,
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value, bool isDark) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: AppTypography.caption.copyWith(
          color: isDark ? NeuColors.textHintDark : NeuColors.textHint)),
      Flexible(child: Text(value, style: AppTypography.bodySmall.copyWith(
          color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
          fontWeight: FontWeight.w600), textAlign: TextAlign.end)),
    ]),
  );
}

class _BudgetCard extends StatelessWidget {
  const _BudgetCard({
    required this.label, required this.value,
    required this.currency, required this.isDark, required this.color,
  });
  final String label;
  final double value;
  final CurrencyInfo currency;
  final bool isDark;
  final Color color;

  @override
  Widget build(BuildContext context) => NeuCard(
    isDark: isDark, radius: AzmRadius.sm, padding: const EdgeInsets.all(12),
    child: Column(children: [
      Text(label, style: AppTypography.caption.copyWith(
          color: isDark ? NeuColors.textHintDark : NeuColors.textHint)),
      const SizedBox(height: 6),
      FittedBox(child: Text(
        AppCurrencies.formatCompact(value, currency.code),
        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
            color: color, fontFamily: 'Panorama'),
      )),
      Text(currency.symbol, style: AppTypography.caption.copyWith(
          color: isDark ? NeuColors.textHintDark : NeuColors.textHint)),
    ]),
  );
}