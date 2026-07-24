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

/// Advances List Screen — manage employee salary advances.
class AdvancesListScreen extends ConsumerWidget {
  const AdvancesListScreen({super.key});

  static const _statusNames = ['معلق', 'موافق عليه', 'مرفوض', 'مسدد'];

  Color _statusColor(int s) {
    switch (s) {
      case 0: return NeuColors.warning;
      case 1: return NeuColors.success;
      case 2: return NeuColors.danger;
      case 3: return NeuColors.textHint;
      default: return NeuColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final textSecondary = NeuColors.textSecondaryFor(Theme.of(context).brightness);

    // Watch all advances via DB stream
    final advancesAsync = ref.watch(_advancesStreamProvider);

    return Scaffold(
      backgroundColor: NeuColors.background(Theme.of(context).brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
        ),
        title: Text(
          'سلف الموظفين',
          style: AppTypography.headingSmall.copyWith(
              color: textPrimary, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: advancesAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (advances) {
            if (advances.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.account_balance_wallet_rounded, size: 64, color: NeuColors.textHint),
                    const SizedBox(height: 16),
                    Text('لا توجد سلف مسجلة',
                        style: AppTypography.bodyMedium.copyWith(color: NeuColors.textHint)),
                  ],
                ),
              );
            }
            return ListView.builder(
              padding: AppSpacing.screen,
              itemCount: advances.length,
              itemBuilder: (_, i) {
                final a = advances[i];
                final statusName = a.status < _statusNames.length
                    ? _statusNames[a.status] : '—';
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NeuCard(
                    isDark: isDark,
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: _statusColor(a.status).withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(Icons.account_balance_wallet_rounded,
                              color: _statusColor(a.status), size: 22),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      a.employeeName ?? 'موظف #${a.employeeId}',
                                      style: AppTypography.bodyMedium.copyWith(
                                          color: textPrimary, fontWeight: FontWeight.w700),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: _statusColor(a.status).withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Text(statusName,
                                        style: AppTypography.labelSmall.copyWith(
                                            color: _statusColor(a.status),
                                            fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${a.amount.toStringAsFixed(0)} ريال',
                                style: AppTypography.bodyMedium.copyWith(
                                    color: NeuColors.navyDeep, fontWeight: FontWeight.w700),
                              ),
                              Text(
                                'تاريخ الطلب: ${a.requestDate}',
                                style: AppTypography.bodySmall.copyWith(color: textSecondary),
                              ),
                              if (a.repaidAmount > 0)
                                Text(
                                  'المسدد: ${a.repaidAmount.toStringAsFixed(0)} ريال',
                                  style: AppTypography.bodySmall.copyWith(color: NeuColors.success),
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
        onPressed: () => _showCreateAdvanceDialog(context, isDark, ref),
        backgroundColor: const Color(0xFFE84393),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('سلفة جديدة',
            style: AppTypography.buttonLabel.copyWith(color: Colors.white)),
      ),
    );
  }

  void _showCreateAdvanceDialog(BuildContext context, bool isDark, WidgetRef ref) {
    final empCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final reasonCtrl = TextEditingController();
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? NeuColors.surfaceDark : NeuColors.surface,
          title: Text('طلب سلفة جديدة',
              style: AppTypography.headingSmall.copyWith(color: textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: empCtrl,
                decoration: const InputDecoration(labelText: 'اسم الموظف', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'المبلغ (ريال)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: reasonCtrl,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'السبب', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => ctx.pop(), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(amountCtrl.text) ?? 0;
                if (empCtrl.text.isEmpty || amount <= 0) return;
                final db = ref.read(databaseProvider);
                await db.hrmDao.insertAdvance(EmployeeAdvancesCompanion(
                  employeeId: const Value(1),
                  employeeName: Value(empCtrl.text),
                  amount: Value(amount),
                  requestDate: Value(DateTime.now().toIso8601String().substring(0, 10)),
                  reason: Value(reasonCtrl.text.isEmpty ? null : reasonCtrl.text),
                  status: const Value(0),
                ));
                if (ctx.mounted) ctx.pop();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE84393), foregroundColor: Colors.white),
              child: const Text('تقديم'),
            ),
          ],
        ),
      ),
    );
  }
}

// Stream provider for all advances
final _advancesStreamProvider = StreamProvider<List<EmployeeAdvance>>((ref) {
  final db = ref.watch(databaseProvider);
  return (db.select(db.employeeAdvances)
        ..orderBy([(a) => OrderingTerm.desc(a.requestDate)]))
      .watch();
});