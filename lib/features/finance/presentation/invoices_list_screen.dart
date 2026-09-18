import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_currencies.dart';
import '../../../core/constants/enums.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/finance_repository.dart';

/// Invoices List Screen — shows all invoices with status filters.
class InvoicesListScreen extends ConsumerStatefulWidget {
  const InvoicesListScreen({super.key});

  @override
  ConsumerState<InvoicesListScreen> createState() => _InvoicesListScreenState();
}

class _InvoicesListScreenState extends ConsumerState<InvoicesListScreen> {
  String _query = '';
  final _searchCtrl = TextEditingController();
  int _statusFilter = -1; // -1 = all

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final invoicesAsync = ref.watch(invoicesListProvider);

    // Summary stats from data
    final invoices = invoicesAsync.valueOrNull ?? [];
    final totalPending = invoices
        .where((i) => i.status == 1 || i.status == 3)
        .fold<double>(0, (s, i) => s + i.remainingAmount);
    final totalOverdue = invoices
        .where((i) => i.status == 4)
        .fold<double>(0, (s, i) => s + i.remainingAmount);

    return Scaffold(
      backgroundColor: NeuColors.background(Theme.of(context).brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
        ),
        title: Text('الفواتير',
            style: AppTypography.headingSmall.copyWith(
                color: textPrimary, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push(RouteNames.invoiceCreate),
            icon: Icon(Icons.add_rounded, color: NeuColors.success),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Summary Strip ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: NeuCard(
                    isDark: isDark,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('مستحق', style: AppTypography.labelSmall
                            .copyWith(color: NeuColors.textHint)),
                        const SizedBox(height: 4),
                        Text(
                          AppCurrencies.formatAmount(totalPending, AppCurrencies.sar),
                          style: AppTypography.bodyMedium.copyWith(
                              color: NeuColors.info, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: NeuCard(
                    isDark: isDark,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('متأخر', style: AppTypography.labelSmall
                            .copyWith(color: NeuColors.textHint)),
                        const SizedBox(height: 4),
                        Text(
                          AppCurrencies.formatAmount(totalOverdue, AppCurrencies.sar),
                          style: AppTypography.bodyMedium.copyWith(
                              color: NeuColors.danger, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: NeuCard(
                    isDark: isDark,
                    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('الإجمالي', style: AppTypography.labelSmall
                            .copyWith(color: NeuColors.textHint)),
                        const SizedBox(height: 4),
                        Text(
                          '${invoices.length} فاتورة',
                          style: AppTypography.bodyMedium.copyWith(
                              color: textPrimary, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Search ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: NeuCard(
              isDark: isDark,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v.trim()),
                decoration: InputDecoration(
                  hintText: 'بحث في الفواتير...',
                  hintStyle: AppTypography.bodySmall.copyWith(color: NeuColors.textHint),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search_rounded, color: NeuColors.textHint),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── Status Filter ────────────────────────────────────────
          SizedBox(
            height: 36,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _StatusChip(label: 'الكل', value: -1, selected: _statusFilter == -1,
                    color: NeuColors.navyDeep, onTap: () => setState(() => _statusFilter = -1), isDark: isDark),
                _StatusChip(label: 'مسودة', value: 0, selected: _statusFilter == 0,
                    color: NeuColors.textHint, onTap: () => setState(() => _statusFilter = 0), isDark: isDark),
                _StatusChip(label: 'مُرسلة', value: 1, selected: _statusFilter == 1,
                    color: NeuColors.info, onTap: () => setState(() => _statusFilter = 1), isDark: isDark),
                _StatusChip(label: 'مدفوعة', value: 2, selected: _statusFilter == 2,
                    color: NeuColors.success, onTap: () => setState(() => _statusFilter = 2), isDark: isDark),
                _StatusChip(label: 'جزئي', value: 3, selected: _statusFilter == 3,
                    color: NeuColors.warning, onTap: () => setState(() => _statusFilter = 3), isDark: isDark),
                _StatusChip(label: 'متأخرة', value: 4, selected: _statusFilter == 4,
                    color: NeuColors.danger, onTap: () => setState(() => _statusFilter = 4), isDark: isDark),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── List ────────────────────────────────────────────────
          Expanded(
            child: invoicesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('خطأ: $e',
                    style: AppTypography.bodyMedium.copyWith(color: NeuColors.danger)),
              ),
              data: (list) {
                final filtered = list.where((inv) {
                  final matchQ = _query.isEmpty ||
                      (inv.invoiceNumber?.contains(_query) ?? false) ||
                      (inv.clientName?.toLowerCase().contains(_query.toLowerCase()) ?? false);
                  final matchS = _statusFilter == -1 || inv.status == _statusFilter;
                  return matchQ && matchS;
                }).toList();

                if (filtered.isEmpty) {
                  return _EmptyInvoices(isDark: isDark);
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => _InvoiceCard(
                    invoice: filtered[i], isDark: isDark,
                    onTap: () => context.push(RouteNames.invoiceDetailPath(filtered[i].id)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.invoiceCreate),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text('فاتورة جديدة',
            style: AppTypography.buttonLabel.copyWith(color: Colors.white)),
      ),
    );
  }
}

// ── Invoice Card ───────────────────────────────────────────────────

class _InvoiceCard extends StatelessWidget {
  const _InvoiceCard({required this.invoice, required this.isDark, required this.onTap});
  final Invoice invoice;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final textSecondary = NeuColors.textSecondaryFor(Theme.of(context).brightness);
    final status = InvoiceStatus.fromValue(invoice.status);
    final currency = invoice.currency;

    return GestureDetector(
      onTap: onTap,
      child: NeuCard(
        isDark: isDark,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                // Invoice icon
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.receipt_long_rounded,
                      color: status.color, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        invoice.invoiceNumber ?? 'بدون رقم',
                        style: AppTypography.bodyMedium.copyWith(
                            color: textPrimary, fontWeight: FontWeight.w700),
                      ),
                      if (invoice.clientName != null)
                        Text(invoice.clientName!,
                            style: AppTypography.bodySmall.copyWith(color: textSecondary)),
                      Text(
                        invoice.issueDate,
                        style: AppTypography.labelSmall.copyWith(color: NeuColors.textHint),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      AppCurrencies.formatAmount(invoice.total, currency),
                      style: AppTypography.bodyMedium.copyWith(
                          color: textPrimary, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: status.color.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: status.color.withValues(alpha: 0.3)),
                      ),
                      child: Text(status.arabicLabel,
                          style: AppTypography.labelSmall.copyWith(
                              color: status.color, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ],
            ),

            // Progress bar for partial payments
            if (status == InvoiceStatus.partial && invoice.total > 0) ...[
              const SizedBox(height: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('مدفوع: ${AppCurrencies.formatAmount(invoice.paidAmount, currency)}',
                          style: AppTypography.labelSmall.copyWith(color: NeuColors.success)),
                      Text('متبقي: ${AppCurrencies.formatAmount(invoice.remainingAmount, currency)}',
                          style: AppTypography.labelSmall.copyWith(color: NeuColors.danger)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  LinearProgressIndicator(
                    value: invoice.paidAmount / (invoice.total == 0 ? 1 : invoice.total),
                    backgroundColor: NeuColors.danger.withValues(alpha: 0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(NeuColors.success),
                    borderRadius: BorderRadius.circular(4),
                    minHeight: 6,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Supporting ─────────────────────────────────────────────────────

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label, required this.value, required this.selected,
    required this.color, required this.onTap, required this.isDark,
  });
  final String label;
  final int value;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsetsDirectional.only(end: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : (isDark ? NeuColors.surfaceDark : NeuColors.surface),
          borderRadius: BorderRadius.circular(16),
          border: selected ? null : Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Text(label,
            style: AppTypography.labelSmall.copyWith(
              color: selected ? Colors.white : color,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            )),
      ),
    );
  }
}

class _EmptyInvoices extends StatelessWidget {
  const _EmptyInvoices({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: NeuColors.success.withValues(alpha: 0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.receipt_long_rounded,
              size: 56, color: NeuColors.success.withValues(alpha: 0.4)),
        ),
        const SizedBox(height: 20),
        Text('لا توجد فواتير',
            style: AppTypography.headingSmall.copyWith(color: NeuColors.textHint)),
        const SizedBox(height: 8),
        Text('أنشئ أول فاتورة بالضغط على الزر أدناه',
            style: AppTypography.bodySmall.copyWith(color: NeuColors.textHint)),
      ],
    ),
  );
}