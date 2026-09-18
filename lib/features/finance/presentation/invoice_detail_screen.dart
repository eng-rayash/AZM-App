import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/related_entities_widget.dart';
import '../domain/finance_repository.dart';
import '../../../core/database/app_database.dart';
import '../../../core/constants/app_currencies.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../core/constants/enums.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Invoice Detail Screen
// ─────────────────────────────────────────────────────────────────────────────

class InvoiceDetailScreen extends ConsumerWidget {
  const InvoiceDetailScreen({super.key, required this.invoiceId});
  final int invoiceId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final invoicesAsync = ref.watch(invoicesListProvider);

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      body: invoicesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(error: e),
        data: (invoices) {
          final invoice = invoices.firstWhere(
            (i) => i.id == invoiceId,
            orElse: () => invoices.first,
          );
          return _InvoiceDetailBody(invoice: invoice, isDark: isDark);
        },
      ),
    );
  }
}

class _InvoiceDetailBody extends StatelessWidget {
  const _InvoiceDetailBody({required this.invoice, required this.isDark});
  final Invoice invoice;
  final bool isDark;

  Color get _statusColor {
    switch (invoice.status) {
      case 1: return NeuColors.success;
      case 2: return NeuColors.danger;
      default: return NeuColors.warning;
    }
  }

  String get _statusLabel {
    switch (invoice.status) {
      case 1: return 'مدفوعة ✓';
      case 2: return 'متأخرة ⚠';
      default: return 'معلقة ⏳';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tp = isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary;
    final CurrencyInfo currency = AppCurrencies.fromCode(invoice.currency);
    final fmt = NumberFormat('#,##0.00');

    return CustomScrollView(
      slivers: [
        // ── AppBar ─────────────────────────────────────────────────
        SliverAppBar(
          expandedHeight: 200,
          pinned: true,
          backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.navyDeep,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isDark
                      ? [const Color(0xFF241416), NeuColors.primary]
                      : [NeuColors.navyDeep, NeuColors.navyMid],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 80, 20, 20),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: _statusColor.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: _statusColor),
                            ),
                            child: Text(_statusLabel,
                                style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'Panorama')),
                          ),
                          const Spacer(),
                          Text(
                            currency.symbol,
                            style: const TextStyle(color: Colors.white70, fontSize: 14, fontFamily: 'Panorama'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        invoice.clientName ?? 'فاتورة',
                        style: const TextStyle(color: Colors.white, fontSize: 20,
                            fontWeight: FontWeight.w700, fontFamily: 'Panorama'),
                      ),
                      Text(
                        'رقم: ${invoice.invoiceNumber}',
                        style: const TextStyle(color: Colors.white70, fontSize: 13, fontFamily: 'Panorama'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── Body ───────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                // ── Amount Summary ──────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Expanded(child: _AmountCard(
                      label: 'الإجمالي', isDark: isDark,
                      value: '${fmt.format(invoice.total)} ${currency.symbol}',
                      color: NeuColors.navyDeep,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _AmountCard(
                      label: 'المدفوع', isDark: isDark,
                      value: '${fmt.format(invoice.paidAmount)} ${currency.symbol}',
                      color: NeuColors.success,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _AmountCard(
                      label: 'المتبقي', isDark: isDark,
                      value: '${fmt.format(invoice.remainingAmount)} ${currency.symbol}',
                      color: NeuColors.danger,
                    )),
                  ]),
                ),

                // ── Details Card ─────────────────────────────────
                NeuCard(
                  isDark: isDark,
                  radius: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    _DetailRow(label: 'تاريخ الإصدار',
                        value: invoice.issueDate, isDark: isDark),
                    _DetailRow(label: 'تاريخ الاستحقاق',
                        value: invoice.dueDate ?? 'غير محدد', isDark: isDark),
                    _DetailRow(label: 'العملة',
                        value: '${currency.nameAr} (${currency.code})', isDark: isDark),
                    if (invoice.taxAmount > 0)
                      _DetailRow(
                          label: 'الضريبة',
                          value: '${fmt.format(invoice.taxAmount)} ${currency.symbol}',
                          isDark: isDark),
                    if (invoice.discountAmount > 0)
                      _DetailRow(
                          label: 'الخصم',
                          value: '${fmt.format(invoice.discountAmount)} ${currency.symbol}',
                          isDark: isDark),
                    if (invoice.notes != null && invoice.notes!.isNotEmpty)
                      _DetailRow(label: 'ملاحظات', value: invoice.notes!, isDark: isDark),
                  ]),
                ),

                // ── Invoice Items ────────────────────────────────
                if (invoice.items != null && invoice.items!.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Text('بنود الفاتورة',
                        style: AppTypography.h4.copyWith(color: tp)),
                  ),
                  NeuCard(
                    isDark: isDark,
                    radius: 20,
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    padding: const EdgeInsets.all(0),
                    child: _InvoiceItemsTable(
                        itemsJson: invoice.items!, currency: currency, isDark: isDark),
                  ),
                ],

                // ── Related Entities ────────────────────────────
                const SizedBox(height: 8),
                RelatedEntitiesWidget(
                  sourceType: EntityLinkType.invoice,
                  sourceId: invoice.id,
                  sourceLabel: invoice.invoiceNumber ?? 'فاتورة #${invoice.id}',
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Invoice Items Table
// ─────────────────────────────────────────────────────────────────────────────
class _InvoiceItemsTable extends StatelessWidget {
  const _InvoiceItemsTable({
    required this.itemsJson,
    required this.currency,
    required this.isDark,
  });

  final String itemsJson;
  final CurrencyInfo currency;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final items = _parseItems(itemsJson);
    final tp = isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary;
    final th = isDark ? NeuColors.textHintDark : NeuColors.textHint;
    final fmt = NumberFormat('#,##0.00');

    return Column(
      children: [
        // Header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isDark ? NeuColors.surfaceDark : NeuColors.navyTint,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Row(children: [
            Expanded(flex: 3, child: Text('البند',
                style: AppTypography.caption.copyWith(
                    color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                    fontWeight: FontWeight.w700))),
            Expanded(child: Text('الكمية', textAlign: TextAlign.center,
                style: AppTypography.caption.copyWith(
                    color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                    fontWeight: FontWeight.w700))),
            Expanded(flex: 2, child: Text('الإجمالي', textAlign: TextAlign.end,
                style: AppTypography.caption.copyWith(
                    color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                    fontWeight: FontWeight.w700))),
          ]),
        ),
        // Rows
        ...items.asMap().entries.map((entry) {
          final i = entry.key;
          final item = entry.value;
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: i % 2 == 0
                  ? Colors.transparent
                  : (isDark ? Colors.white.withValues(alpha: 0.02) : Colors.black.withValues(alpha: 0.02)),
              border: i < items.length - 1
                  ? Border(bottom: BorderSide(
                      color: isDark ? NeuColors.dividerDark : NeuColors.divider))
                  : null,
            ),
            child: Row(children: [
              Expanded(flex: 3, child: Text(item['name'] ?? '',
                  style: AppTypography.bodySmall.copyWith(color: tp))),
              Expanded(child: Text('${item['qty'] ?? 1}', textAlign: TextAlign.center,
                  style: AppTypography.bodySmall.copyWith(color: th))),
              Expanded(flex: 2, child: Text(
                  '${fmt.format((item['qty'] ?? 1) * (item['price'] ?? 0.0))} ${currency.symbol}',
                  textAlign: TextAlign.end,
                  style: AppTypography.bodySmall.copyWith(
                      color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                      fontWeight: FontWeight.w600))),
            ]),
          );
        }),
      ],
    );
  }

  static List<Map<String, dynamic>> _parseItems(String json) {
    try {
      final list = jsonDecode(json) as List;
      return list.cast<Map<String, dynamic>>();
    } catch (_) {
      return [];
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _AmountCard extends StatelessWidget {
  const _AmountCard({
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
  });

  final String label;
  final String value;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return NeuCard(
      isDark: isDark,
      radius: 16,
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Text(label, style: AppTypography.caption.copyWith(
            color: isDark ? NeuColors.textHintDark : NeuColors.textHint)),
        const SizedBox(height: 6),
        FittedBox(
          child: Text(value, style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
            fontFamily: 'Panorama',
          )),
        ),
      ]),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value, required this.isDark});
  final String label;
  final String value;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: AppTypography.caption.copyWith(
              color: isDark ? NeuColors.textHintDark : NeuColors.textHint)),
          Text(value, style: AppTypography.bodySmall.copyWith(
              color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
              fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}