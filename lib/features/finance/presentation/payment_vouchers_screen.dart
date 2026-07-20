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

/// Payment Vouchers Screen — سندات القبض والصرف.
class PaymentVouchersScreen extends ConsumerStatefulWidget {
  const PaymentVouchersScreen({super.key});

  @override
  ConsumerState<PaymentVouchersScreen> createState() =>
      _PaymentVouchersScreenState();
}

class _PaymentVouchersScreenState extends ConsumerState<PaymentVouchersScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;

  static const _paymentMethods = ['نقداً', 'تحويل بنكي', 'شيك'];

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
        title: Text('السندات',
            style: AppTypography.headingSmall.copyWith(
                color: textPrimary, fontWeight: FontWeight.w700)),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: NeuColors.navyDeep,
          unselectedLabelColor: NeuColors.textHint,
          indicatorColor: NeuColors.navyDeep,
          tabs: const [
            Tab(text: 'الكل', icon: Icon(Icons.receipt_rounded, size: 16)),
            Tab(text: 'قبض', icon: Icon(Icons.arrow_downward_rounded, size: 16)),
            Tab(text: 'صرف', icon: Icon(Icons.arrow_upward_rounded, size: 16)),
          ],
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: TabBarView(
          controller: _tabCtrl,
          children: [
            _VouchersContent(typeFilter: null, isDark: isDark),
            _VouchersContent(typeFilter: 0, isDark: isDark),
            _VouchersContent(typeFilter: 1, isDark: isDark),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.extended(
            heroTag: 'receipt_fab',
            onPressed: () => _showCreateDialog(context, isDark, 0),
            backgroundColor: NeuColors.success,
            icon: const Icon(Icons.arrow_downward_rounded, color: Colors.white),
            label: Text('سند قبض',
                style: AppTypography.buttonLabel.copyWith(color: Colors.white)),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            heroTag: 'payment_fab',
            onPressed: () => _showCreateDialog(context, isDark, 1),
            backgroundColor: NeuColors.danger,
            icon: const Icon(Icons.arrow_upward_rounded, color: Colors.white),
            label: Text('سند صرف',
                style: AppTypography.buttonLabel.copyWith(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showCreateDialog(BuildContext context, bool isDark, int voucherType) {
    final partyCtrl = TextEditingController();
    final amountCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    int paymentMethod = 0;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final title = voucherType == 0 ? 'سند قبض جديد' : 'سند صرف جديد';
    final color = voucherType == 0 ? NeuColors.success : NeuColors.danger;

    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: StatefulBuilder(
          builder: (ctx, setState) => AlertDialog(
            backgroundColor: isDark ? NeuColors.surfaceDark : NeuColors.surface,
            title: Text(title,
                style: AppTypography.headingSmall.copyWith(color: textPrimary)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: partyCtrl,
                  decoration: InputDecoration(
                    labelText: voucherType == 0 ? 'الجهة المدفوعة منها' : 'الجهة المدفوع إليها',
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: amountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'المبلغ (ريال)', border: OutlineInputBorder()),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<int>(
                  initialValue: paymentMethod,
                  decoration: const InputDecoration(
                      labelText: 'طريقة الدفع', border: OutlineInputBorder()),
                  items: List.generate(_paymentMethods.length,
                      (i) => DropdownMenuItem(value: i, child: Text(_paymentMethods[i]))),
                  onChanged: (v) => setState(() => paymentMethod = v ?? 0),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descCtrl,
                  decoration: const InputDecoration(
                      labelText: 'البيان', border: OutlineInputBorder()),
                ),
              ],
            ),
            actions: [
              TextButton(onPressed: () => ctx.pop(), child: const Text('إلغاء')),
              ElevatedButton(
                onPressed: () async {
                  final amount = double.tryParse(amountCtrl.text) ?? 0;
                  if (amount <= 0) return;
                  final db = ref.read(databaseProvider);
                  await db.financeDao.insertVoucher(PaymentVouchersCompanion(
                    type: Value(voucherType),
                    date: Value(DateTime.now().toIso8601String().substring(0, 10)),
                    amount: Value(amount),
                    partyName: Value(partyCtrl.text.isEmpty ? null : partyCtrl.text),
                    description: Value(descCtrl.text.isEmpty ? null : descCtrl.text),
                    paymentMethod: Value(paymentMethod),
                    status: const Value(0),
                  ));
                  if (ctx.mounted) ctx.pop();
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: color, foregroundColor: Colors.white),
                child: const Text('حفظ'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _VouchersContent extends ConsumerWidget {
  const _VouchersContent({required this.typeFilter, required this.isDark});
  final int? typeFilter;
  final bool isDark;

  static const _statusNames = ['مسودة', 'مؤكد', 'ملغى'];
  static const _paymentMethods = ['نقداً', 'تحويل بنكي', 'شيك'];

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
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final textSecondary = NeuColors.textSecondaryFor(Theme.of(context).brightness);
    final async = ref.watch(_vouchersProvider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('$e')),
      data: (all) {
        final list = typeFilter == null
            ? all
            : all.where((v) => v.type == typeFilter).toList();

        if (list.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.receipt_rounded, size: 64, color: NeuColors.textHint),
                const SizedBox(height: 16),
                Text('لا توجد سندات',
                    style: AppTypography.bodyMedium.copyWith(color: NeuColors.textHint)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: AppSpacing.screen,
          itemCount: list.length,
          itemBuilder: (_, i) {
            final v = list[i];
            final isReceipt = v.type == 0;
            final color = isReceipt ? NeuColors.success : NeuColors.danger;
            final icon = isReceipt ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded;
            final typeLabel = isReceipt ? 'سند قبض' : 'سند صرف';
            final statusName = v.status < _statusNames.length ? _statusNames[v.status] : '—';
            final methodName = v.paymentMethod < _paymentMethods.length
                ? _paymentMethods[v.paymentMethod] : '—';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: NeuCard(
                isDark: isDark,
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: color.withOpacity(0.12),
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
                                child: Text(
                                  v.voucherNumber != null
                                      ? '$typeLabel #${v.voucherNumber}'
                                      : typeLabel,
                                  style: AppTypography.bodyMedium.copyWith(
                                      color: textPrimary, fontWeight: FontWeight.w700),
                                ),
                              ),
                              Text('${v.amount.toStringAsFixed(2)} ر.س',
                                  style: AppTypography.bodyMedium.copyWith(
                                      color: color, fontWeight: FontWeight.w700)),
                            ],
                          ),
                          if (v.partyName != null)
                            Text(v.partyName!,
                                style: AppTypography.bodySmall.copyWith(color: textSecondary)),
                          Row(
                            children: [
                              Text('$methodName  •  ${v.date}',
                                  style: AppTypography.bodySmall.copyWith(color: NeuColors.textHint)),
                              const Spacer(),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                decoration: BoxDecoration(
                                  color: _statusColor(v.status).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(statusName,
                                    style: AppTypography.labelSmall.copyWith(
                                        color: _statusColor(v.status),
                                        fontWeight: FontWeight.w600)),
                              ),
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

final _vouchersProvider = StreamProvider<List<PaymentVoucher>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.financeDao.watchVouchers();
});
