import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/providers/database_providers.dart';

/// Trainings List Screen — employee training programs.
class TrainingsListScreen extends ConsumerWidget {
  const TrainingsListScreen({super.key});

  static const _typeNames = ['داخلي', 'خارجي', 'عبر الإنترنت', 'مؤتمر'];
  static const _statusNames = ['مخطط', 'جارٍ', 'مكتمل', 'ملغى'];

  Color _statusColor(int s) {
    switch (s) {
      case 0: return NeuColors.info;
      case 1: return NeuColors.warning;
      case 2: return NeuColors.success;
      case 3: return NeuColors.danger;
      default: return NeuColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final textSecondary = NeuColors.textSecondaryFor(Theme.of(context).brightness);
    final async = ref.watch(_trainingsStreamProvider);

    return Scaffold(
      backgroundColor: NeuColors.background(Theme.of(context).brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
        ),
        title: Text('برامج التدريب',
            style: AppTypography.headingSmall.copyWith(
                color: textPrimary, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (trainings) {
            if (trainings.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.school_rounded, size: 64, color: NeuColors.textHint),
                    const SizedBox(height: 16),
                    Text('لا توجد برامج تدريبية',
                        style: AppTypography.bodyMedium.copyWith(color: NeuColors.textHint)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: AppSpacing.screen,
              itemCount: trainings.length,
              itemBuilder: (_, i) {
                final t = trainings[i];
                final typeName = t.trainingType < _typeNames.length
                    ? _typeNames[t.trainingType] : '—';
                final statusName = t.status < _statusNames.length
                    ? _statusNames[t.status] : '—';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NeuCard(
                    isDark: isDark,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _statusColor(t.status).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.school_rounded,
                              color: _statusColor(t.status), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(t.trainingName,
                                        style: AppTypography.bodyMedium.copyWith(
                                            color: textPrimary, fontWeight: FontWeight.w700)),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _statusColor(t.status).withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(statusName,
                                        style: AppTypography.labelSmall.copyWith(
                                            color: _statusColor(t.status),
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text('${t.employeeName ?? '—'}  •  $typeName',
                                  style: AppTypography.bodySmall.copyWith(color: textSecondary)),
                              if (t.startDate != null)
                                Text('${t.startDate}${t.endDate != null ? ' ← ${t.endDate}' : ''}',
                                    style: AppTypography.bodySmall.copyWith(color: NeuColors.textHint)),
                              if (t.hours != null)
                                Text('${t.hours} ساعة${t.cost != null ? '  •  ${t.cost!.toStringAsFixed(0)} ريال' : ''}',
                                    style: AppTypography.bodySmall.copyWith(color: NeuColors.navyDeep)),
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
        onPressed: () => _showCreateTrainingDialog(context, isDark, ref),
        backgroundColor: const Color(0xFF00B894),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('تدريب جديد',
            style: AppTypography.buttonLabel.copyWith(color: Colors.white)),
      ),
    );
  }

  void _showCreateTrainingDialog(BuildContext context, bool isDark, WidgetRef ref) {
    final nameCtrl = TextEditingController();
    final empCtrl = TextEditingController();
    final providerCtrl = TextEditingController();
    final startCtrl = TextEditingController(
        text: DateTime.now().toIso8601String().substring(0, 10));
    int selectedType = 0;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            backgroundColor: isDark ? NeuColors.surfaceDark : NeuColors.surface,
            title: Text('إضافة تدريب',
                style: AppTypography.headingSmall.copyWith(color: textPrimary)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: nameCtrl,
                    decoration: const InputDecoration(
                        labelText: 'اسم البرنامج التدريبي', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: empCtrl,
                    decoration: const InputDecoration(
                        labelText: 'اسم الموظف', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: providerCtrl,
                    decoration: const InputDecoration(
                        labelText: 'الجهة المنفذة', border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<int>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                        labelText: 'نوع التدريب', border: OutlineInputBorder()),
                    items: List.generate(_typeNames.length,
                        (i) => DropdownMenuItem(value: i, child: Text(_typeNames[i]))),
                    onChanged: (v) => setState(() => selectedType = v ?? 0),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: startCtrl,
                    decoration: const InputDecoration(
                        labelText: 'تاريخ البدء (YYYY-MM-DD)', border: OutlineInputBorder()),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => ctx.pop(), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () async {
                  if (nameCtrl.text.isEmpty) return;
                  final db = ref.read(databaseProvider);
                  await db.hrmDao.insertTraining(TrainingRecordsCompanion(
                    employeeId: const Value(1),
                    employeeName: Value(empCtrl.text.isEmpty ? null : empCtrl.text),
                    trainingName: Value(nameCtrl.text),
                    provider: Value(providerCtrl.text.isEmpty ? null : providerCtrl.text),
                    trainingType: Value(selectedType),
                    startDate: Value(startCtrl.text),
                    status: const Value(0),
                  ));
                  if (ctx.mounted) ctx.pop();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00B894), foregroundColor: Colors.white),
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final _trainingsStreamProvider = StreamProvider<List<TrainingRecord>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.trainingRecords)
        ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
      .watch();
});
