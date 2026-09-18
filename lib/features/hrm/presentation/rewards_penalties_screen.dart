import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/hrm_repository.dart';

/// Rewards & Penalties Screen — employee rewards and disciplinary actions.
class RewardsPenaltiesScreen extends ConsumerStatefulWidget {
  const RewardsPenaltiesScreen({super.key});

  @override
  ConsumerState<RewardsPenaltiesScreen> createState() =>
      _RewardsPenaltiesScreenState();
}

class _RewardsPenaltiesScreenState extends ConsumerState<RewardsPenaltiesScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);

    return Scaffold(
      backgroundColor: NeuColors.background(Theme.of(context).brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
        ),
        title: Text('المكافآت والجزاءات',
            style: AppTypography.headingSmall.copyWith(
                color: textPrimary, fontWeight: FontWeight.w700)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: NeuColors.navyDeep,
          unselectedLabelColor: NeuColors.textHint,
          indicatorColor: NeuColors.navyDeep,
          tabs: const [
            Tab(text: 'الكل', icon: Icon(Icons.list_rounded, size: 18)),
            Tab(text: 'مكافآت', icon: Icon(Icons.emoji_events_rounded, size: 18)),
            Tab(text: 'جزاءات', icon: Icon(Icons.gavel_rounded, size: 18)),
          ],
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: TabBarView(
          controller: _tabCtrl,
          children: [
            _RPContent(typeFilter: null, isDark: isDark),
            _RPContent(typeFilter: 0, isDark: isDark),
            _RPContent(typeFilter: 1, isDark: isDark),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context, isDark),
        foregroundColor: Colors.black87,
        icon: const Icon(Icons.add_rounded),
        label: Text('إضافة',
            style: AppTypography.buttonLabel.copyWith(color: Colors.black87)),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, bool isDark) {
    final empCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    int type = 0;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            backgroundColor: isDark ? NeuColors.surfaceDark : NeuColors.surface,
            title: Text('إضافة مكافأة / جزاء',
                style: AppTypography.headingSmall.copyWith(color: textPrimary)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: 0, label: Text('مكافأة'), icon: Icon(Icons.emoji_events_rounded)),
                    ButtonSegment(value: 1, label: Text('جزاء'), icon: Icon(Icons.gavel_rounded)),
                  ],
                  selected: {type},
                  onSelectionChanged: (s) => setState(() => type = s.first),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: empCtrl,
                  decoration: const InputDecoration(
                      labelText: 'اسم الموظف', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: reasonCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'السبب', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'المبلغ (اختياري)', border: OutlineInputBorder()),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => ctx.pop(), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () async {
                  if (empCtrl.text.isEmpty || reasonCtrl.text.isEmpty) return;
                  await ref
                      .read(hrmRepositoryProvider)
                      .createRewardPenalty(
                        employeeId: 1,
                        employeeName: empCtrl.text,
                        type: type,
                        reason: reasonCtrl.text,
                        amount: double.tryParse(amountCtrl.text),
                        date: DateTime.now()
                            .toIso8601String()
                            .substring(0, 10),
                      );
                  if (ctx.mounted) ctx.pop();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFDCB6E),
                    foregroundColor: Colors.black87),
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RPContent extends ConsumerWidget {
  const _RPContent({required this.typeFilter, required this.isDark});
  final int? typeFilter;
  final bool isDark;

  static const _statusNames = ['معلق', 'موافق عليه', 'مطبق'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final textSecondary = NeuColors.textSecondaryFor(Theme.of(context).brightness);
    final async = ref.watch(rewardsPenaltiesListProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (all) {
        final list = typeFilter == null
            ? all
            : all.where((r) => r.type == typeFilter).toList();

        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events_rounded, size: 64, color: NeuColors.textHint),
                const SizedBox(height: 16),
                Text('لا يوجد سجلات',
                    style: AppTypography.bodyMedium.copyWith(color: NeuColors.textHint)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: AppSpacing.screen,
          itemCount: list.length,
          itemBuilder: (_, i) {
            final r = list[i];
            final isReward = r.type == 0;
            final color = isReward ? NeuColors.goldDark : NeuColors.danger;
            final icon = isReward ? Icons.emoji_events_rounded : Icons.gavel_rounded;
            final statusName = r.status < _statusNames.length ? _statusNames[r.status] : '—';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeuCard(
                isDark: isDark,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(icon, color: color, size: 22),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(r.employeeName ?? 'موظف #${r.employeeId}',
                                    style: AppTypography.bodyMedium.copyWith(
                                        color: textPrimary, fontWeight: FontWeight.w700)),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: color.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(isReward ? 'مكافأة' : 'جزاء',
                                    style: AppTypography.labelSmall.copyWith(
                                        color: color, fontWeight: FontWeight.w600)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(r.reason,
                              style: AppTypography.bodySmall.copyWith(color: textSecondary),
                              maxLines: 2),
                          Row(
                            children: [
                              if (r.amount != null && r.amount! > 0)
                                Text('${r.amount!.toStringAsFixed(0)} ريال  •  ',
                                    style: AppTypography.bodySmall.copyWith(color: color)),
                              Text(r.date,
                                  style: AppTypography.bodySmall.copyWith(color: NeuColors.textHint)),
                              Text('  •  $statusName',
                                  style: AppTypography.bodySmall.copyWith(color: NeuColors.textHint)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}

