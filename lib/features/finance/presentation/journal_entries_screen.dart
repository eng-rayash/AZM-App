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

/// Journal Entries Screen — القيود اليومية المحاسبية.
class JournalEntriesScreen extends ConsumerWidget {
  const JournalEntriesScreen({super.key});

  static const _typeNames = ['يدوي', 'فاتورة', 'دفع', 'راتب', 'مصروف', 'إيراد'];
  static const _statusNames = ['مسودة', 'مرحّل', 'معكوس'];

  Color _statusColor(int s) {
    switch (s) {
      case 0: return NeuColors.warning;
      case 1: return NeuColors.success;
      case 2: return NeuColors.danger;
      default: return NeuColors.textHint;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final textSecondary = NeuColors.textSecondaryFor(Theme.of(context).brightness);
    final async = ref.watch(_journalEntriesProvider);

    return Scaffold(
      backgroundColor: NeuColors.background(Theme.of(context).brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
        ),
        title: Text('القيود اليومية',
            style: AppTypography.headingSmall.copyWith(
                color: textPrimary, fontWeight: FontWeight.w700)),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: async.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (entries) {
            if (entries.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.receipt_long_rounded, size: 64, color: NeuColors.textHint),
                    const SizedBox(height: 16),
                    Text('لا توجد قيود يومية',
                        style: AppTypography.bodyMedium.copyWith(color: NeuColors.textHint)),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: AppSpacing.screen,
              itemCount: entries.length,
              itemBuilder: (_, i) {
                final e = entries[i];
                final typeName = e.type < _typeNames.length ? _typeNames[e.type] : '—';
                final statusName = e.status < _statusNames.length ? _statusNames[e.status] : '—';

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: NeuCard(
                    isDark: isDark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: _statusColor(e.status).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.receipt_long_rounded,
                                  color: _statusColor(e.status), size: 20),
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
                                          e.entryNumber != null ? 'قيد #${e.entryNumber}' : e.description,
                                          style: AppTypography.bodyMedium.copyWith(
                                              color: textPrimary, fontWeight: FontWeight.w700),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: _statusColor(e.status).withValues(alpha: 0.12),
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(statusName,
                                            style: AppTypography.labelSmall.copyWith(
                                                color: _statusColor(e.status),
                                                fontWeight: FontWeight.w600)),
                                      ),
                                    ],
                                  ),
                                  Text('$typeName  •  ${e.date}',
                                      style: AppTypography.bodySmall.copyWith(color: textSecondary)),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _LedgerAmount(label: 'مدين', amount: e.totalDebit, color: NeuColors.danger),
                            _LedgerAmount(label: 'دائن', amount: e.totalCredit, color: NeuColors.success),
                            _LedgerAmount(
                              label: 'الفرق',
                              amount: (e.totalDebit - e.totalCredit).abs(),
                              color: (e.totalDebit - e.totalCredit).abs() < 0.01
                                  ? NeuColors.success
                                  : NeuColors.warning,
                            ),
                          ],
                        ),
                        if (e.description.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(e.description,
                              style: AppTypography.bodySmall.copyWith(color: NeuColors.textHint),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ],
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
        onPressed: () => _showCreateDialog(context, isDark, ref),
        backgroundColor: NeuColors.navyDeep,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('قيد جديد',
            style: AppTypography.buttonLabel.copyWith(color: Colors.white)),
      ),
    );
  }

  void _showCreateDialog(BuildContext context, bool isDark, WidgetRef ref) {
    final descCtrl = TextEditingController();
    final debitCtrl = TextEditingController();
    final creditCtrl = TextEditingController();
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: isDark ? NeuColors.surfaceDark : NeuColors.surface,
          title: Text('قيد يومي جديد',
              style: AppTypography.headingSmall.copyWith(color: textPrimary)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: descCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                    labelText: 'البيان', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: debitCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'المدين (ريال)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: creditCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    labelText: 'الدائن (ريال)', border: OutlineInputBorder()),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => ctx.pop(), child: const Text('إلغاء')),
            ElevatedButton(
              onPressed: () async {
                if (descCtrl.text.isEmpty) return;
                final debit = double.tryParse(debitCtrl.text) ?? 0;
                final credit = double.tryParse(creditCtrl.text) ?? 0;
                final db = ref.read(databaseProvider);
                await db.financeDao.insertJournalEntry(JournalEntriesCompanion(
                  date: Value(DateTime.now().toIso8601String().substring(0, 10)),
                  description: Value(descCtrl.text),
                  lines: const Value('[]'),
                  totalDebit: Value(debit),
                  totalCredit: Value(credit),
                  type: const Value(0),
                  status: const Value(0),
                ));
                if (ctx.mounted) ctx.pop();
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: NeuColors.navyDeep, foregroundColor: Colors.white),
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LedgerAmount extends StatelessWidget {
  const _LedgerAmount({required this.label, required this.amount, required this.color});
  final String label;
  final double amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: AppTypography.labelSmall.copyWith(color: NeuColors.textHint)),
        const SizedBox(height: 2),
        Text('${amount.toStringAsFixed(2)} ر.س',
            style: AppTypography.bodySmall.copyWith(
                color: color, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

final _journalEntriesProvider = StreamProvider<List<JournalEntry>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.financeDao.watchJournalEntries();
});