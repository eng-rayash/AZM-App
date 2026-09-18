import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/hrm_repository.dart';

/// Evaluations List Screen — employee performance evaluations.
class EvaluationsListScreen extends ConsumerWidget {
  const EvaluationsListScreen({super.key});

  static const _gradeNames = ['استثنائي', 'ممتاز', 'جيد', 'مرضف', 'يحتاج تحسين'];
  static const _statusNames = ['مسودة', 'مقدمة', 'معترف بها'];

  Color _gradeColor(int? g) {
    switch (g) {
      case 0: return NeuColors.goldDark;
      case 1: return NeuColors.success;
      case 2: return NeuColors.info;
      case 3: return NeuColors.warning;
      case 4: return NeuColors.danger;
      default: return NeuColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final textSecondary = NeuColors.textSecondaryFor(Theme.of(context).brightness);
    final async = ref.watch(evaluationsListProvider);

    return Scaffold(
      backgroundColor: NeuColors.background(Theme.of(context).brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
        ),
        title: Text('تقييم الأداء',
            style: AppTypography.headingSmall.copyWith(
                color: textPrimary, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (evals) {
            if (evals.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.star_rounded, size: 64, color: NeuColors.textHint),
                    const SizedBox(height: 16),
                    Text('لا توجد تقييمات بعد',
                        style: AppTypography.bodyMedium.copyWith(color: NeuColors.textHint)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: AppSpacing.screen,
              itemCount: evals.length,
              itemBuilder: (_, i) {
                final e = evals[i];
                final gradeName = (e.grade != null && e.grade! < _gradeNames.length)
                    ? _gradeNames[e.grade!] : 'غير محدد';
                final statusName = e.status < _statusNames.length
                    ? _statusNames[e.status] : '—';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NeuCard(
                    isDark: isDark,
                    child: Row(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: _gradeColor(e.grade).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.star_rounded, color: _gradeColor(e.grade), size: 20),
                              if (e.percentage != null)
                                Text('${e.percentage!.toInt()}%',
                                    style: AppTypography.labelSmall.copyWith(
                                        color: _gradeColor(e.grade),
                                        fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                e.employeeName ?? 'موظف #${e.employeeId}',
                                style: AppTypography.bodyMedium.copyWith(
                                    color: textPrimary, fontWeight: FontWeight.w700),
                              ),
                              const SizedBox(height: 2),
                              Text('الفترة: ${e.period}',
                                  style: AppTypography.bodySmall.copyWith(color: textSecondary)),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _gradeColor(e.grade).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(gradeName,
                                        style: AppTypography.labelSmall.copyWith(
                                            color: _gradeColor(e.grade),
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(statusName,
                                      style: AppTypography.labelSmall.copyWith(
                                          color: NeuColors.textHint)),
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
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateEvalDialog(context, isDark, ref),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('تقييم جديد',
            style: AppTypography.buttonLabel.copyWith(color: Colors.white)),
      ),
    );
  }

  void _showCreateEvalDialog(BuildContext context, bool isDark, WidgetRef ref) {
    final empCtrl = TextEditingController();
    final periodCtrl = TextEditingController(
        text: 'سنوي-${DateTime.now().year}');
    int grade = 2;
    double percentage = 75;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            backgroundColor: isDark ? NeuColors.surfaceDark : NeuColors.surface,
            title: Text('تقييم أداء جديد',
                style: AppTypography.headingSmall.copyWith(color: textPrimary)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: empCtrl,
                  decoration: const InputDecoration(
                      labelText: 'اسم الموظف', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: periodCtrl,
                  decoration: const InputDecoration(
                      labelText: 'الفترة', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: grade,
                  decoration: const InputDecoration(
                      labelText: 'التقدير', border: OutlineInputBorder()),
                  items: List.generate(_gradeNames.length,
                      (i) => DropdownMenuItem(value: i, child: Text(_gradeNames[i]))),
                  onChanged: (v) => setState(() => grade = v ?? 2),
                ),
                const SizedBox(height: 12),
                Text('النسبة: ${percentage.toInt()}%',
                    style: AppTypography.bodySmall),
                Slider(
                  value: percentage,
                  min: 0,
                  max: 100,
                  divisions: 20,
                  label: '${percentage.toInt()}%',
                  onChanged: (v) => setState(() => percentage = v),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => ctx.pop(), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () async {
                  if (empCtrl.text.isEmpty) return;
                  await ref.read(hrmRepositoryProvider).createEvaluation(
                        employeeId: 1,
                        employeeName: empCtrl.text,
                        period: periodCtrl.text,
                        grade: grade,
                        percentage: percentage,
                      );
                  if (ctx.mounted) ctx.pop();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFE17055), foregroundColor: Colors.white),
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
