import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/database/app_database.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/related_entities_widget.dart';
import '../domain/finance_repository.dart';
import '../../../core/router/route_names.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Client Detail Screen
// ─────────────────────────────────────────────────────────────────────────────
class ClientDetailScreen extends ConsumerWidget {
  const ClientDetailScreen({super.key, required this.clientId});
  final int clientId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final clientsAsync = ref.watch(clientsListProvider);
    final invoicesAsync = ref.watch(invoicesListProvider);

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      body: clientsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (clients) {
          final client = clients.firstWhere(
            (c) => c.id == clientId,
            orElse: () => clients.first,
          );
          final clientInvoices = invoicesAsync.whenData(
            (inv) => inv.where((i) => i.clientId == clientId).toList(),
          ).valueOrNull ?? [];
          return _ClientDetailBody(
              client: client, invoices: clientInvoices, isDark: isDark);
        },
      ),
    );
  }
}

class _ClientDetailBody extends StatelessWidget {
  const _ClientDetailBody({
    required this.client,
    required this.invoices,
    required this.isDark,
  });

  final Client client;
  final List<Invoice> invoices;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tp = isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary;
    final fmt = NumberFormat('#,##0.00');

    final totalInvoiced = invoices.fold<double>(0, (s, i) => s + i.total);
    final totalPaid = invoices.fold<double>(0, (s, i) => s + i.paidAmount);
    final totalDue = totalInvoiced - totalPaid;
    final paidCount = invoices.where((i) => i.status == 2).length; // 2=paid
    final pendingCount = invoices.where((i) => i.status == 0).length; // 0=draft

    return CustomScrollView(
      slivers: [
        // ── SliverAppBar ──────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          expandedHeight: 220,
          backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.navyDeep,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.white),
              onPressed: () => context.push(RouteNames.clientEditPath(client.id)),
              tooltip: 'تعديل',
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [NeuColors.navyDeep, const Color(0xFF00B894)],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 90, 20, 20),
                child: Directionality(
                  textDirection: TextDirection.rtl,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar
                      Row(children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Colors.white24,
                          child: Text(
                            client.name.isNotEmpty ? client.name[0] : '?',
                            style: const TextStyle(fontSize: 24,
                                fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(client.name, style: const TextStyle(
                                color: Colors.white, fontSize: 20,
                                fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                            if (client.phone != null)
                              Text(client.phone!, style: const TextStyle(
                                  color: Colors.white70, fontSize: 13, fontFamily: 'Cairo')),
                            if (client.email != null)
                              Text(client.email!, style: const TextStyle(
                                  color: Colors.white70, fontSize: 13, fontFamily: 'Cairo')),
                          ],
                        )),
                      ]),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── Body ──────────────────────────────────────────────────
        SliverToBoxAdapter(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              children: [
                // ── Financial Summary ─────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(children: [
                    Expanded(child: _StatCard(
                      label: 'إجمالي الفواتير',
                      value: fmt.format(totalInvoiced),
                      icon: Icons.receipt_long_rounded,
                      color: NeuColors.navyDeep, isDark: isDark,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _StatCard(
                      label: 'المدفوع',
                      value: fmt.format(totalPaid),
                      icon: Icons.check_circle_rounded,
                      color: NeuColors.success, isDark: isDark,
                    )),
                    const SizedBox(width: 10),
                    Expanded(child: _StatCard(
                      label: 'المتبقي',
                      value: fmt.format(totalDue),
                      icon: Icons.pending_rounded,
                      color: totalDue > 0 ? NeuColors.danger : NeuColors.success,
                      isDark: isDark,
                    )),
                  ]),
                ),

                // ── Client Info ───────────────────────────────────
                NeuCard(
                  isDark: isDark, radius: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.all(16),
                  child: Column(children: [
                    if (client.address != null)
                      _InfoRow(icon: Icons.location_on_rounded, label: 'العنوان',
                          value: client.address!, isDark: isDark),
                    if (client.taxNumber != null)
                      _InfoRow(icon: Icons.numbers_rounded, label: 'الرقم الضريبي',
                          value: client.taxNumber!, isDark: isDark),
                    if (client.notes != null && client.notes!.isNotEmpty)
                      _InfoRow(icon: Icons.notes_rounded, label: 'ملاحظات',
                          value: client.notes!, isDark: isDark),
                    _InfoRow(
                      icon: Icons.bar_chart_rounded, label: 'الفواتير',
                      value: '${invoices.length} فاتورة ($paidCount مدفوعة / $pendingCount معلقة)',
                      isDark: isDark,
                    ),
                  ]),
                ),

                // ── Invoices List ─────────────────────────────────
                if (invoices.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('فواتير العميل',
                            style: AppTypography.h4.copyWith(color: tp)),
                        TextButton.icon(
                          onPressed: () => context.push(
                              '${RouteNames.invoiceCreate}?clientId=${client.id}'),
                          icon: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('فاتورة جديدة',
                              style: TextStyle(fontFamily: 'Cairo')),
                        ),
                      ],
                    ),
                  ),
                  ...invoices.take(5).map((inv) => _InvoiceTile(
                      invoice: inv, isDark: isDark, fmt: fmt)),
                  if (invoices.length > 5)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      child: TextButton(
                        onPressed: () => context.push(RouteNames.invoicesList),
                        child: Text('عرض كل الفواتير (${invoices.length})',
                            style: const TextStyle(fontFamily: 'Cairo')),
                      ),
                    ),
                ],

                // ── Related Entities ───────────────────────────────
                const SizedBox(height: 8),
                RelatedEntitiesWidget(
                  sourceType: EntityLinkType.client,
                  sourceId: client.id,
                  sourceLabel: client.name,
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
// Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label, required this.value,
    required this.icon, required this.color, required this.isDark,
  });
  final String label, value;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) => NeuCard(
    isDark: isDark, radius: 16, padding: const EdgeInsets.all(12),
    child: Column(children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 6),
      FittedBox(child: Text(value, style: TextStyle(
          fontSize: 14, fontWeight: FontWeight.w700,
          color: color, fontFamily: 'Cairo'))),
      const SizedBox(height: 2),
      Text(label, style: AppTypography.caption.copyWith(
          color: isDark ? NeuColors.textHintDark : NeuColors.textHint),
          textAlign: TextAlign.center),
    ]),
  );
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon, required this.label,
    required this.value, required this.isDark,
  });
  final IconData icon;
  final String label, value;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      Icon(icon, size: 18,
          color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTypography.caption.copyWith(
            color: isDark ? NeuColors.textHintDark : NeuColors.textHint)),
        Text(value, style: AppTypography.bodySmall.copyWith(
            color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
            fontWeight: FontWeight.w600)),
      ])),
    ]),
  );
}

class _InvoiceTile extends StatelessWidget {
  const _InvoiceTile({
    required this.invoice, required this.isDark, required this.fmt,
  });
  final Invoice invoice;
  final bool isDark;
  final NumberFormat fmt;

  @override
  Widget build(BuildContext context) {
    final statusColor = invoice.status == 1
        ? NeuColors.success
        : invoice.status == 2
            ? NeuColors.danger
            : NeuColors.warning;

    return NeuCard(
      isDark: isDark, radius: 14,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(children: [
        Container(
          width: 8, height: 8,
          decoration: BoxDecoration(color: statusColor, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(invoice.invoiceNumber ?? 'فاتورة', style: AppTypography.bodySmall.copyWith(
              color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
              fontWeight: FontWeight.w600)),
          if (invoice.dueDate != null)
            Text('استحقاق: ${invoice.dueDate}',
                style: AppTypography.caption.copyWith(
                    color: isDark ? NeuColors.textHintDark : NeuColors.textHint)),
        ])),
        Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
          Text(fmt.format(invoice.total),
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
                  color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                  fontFamily: 'Cairo')),
          Text(invoice.currency, style: AppTypography.caption.copyWith(
              color: isDark ? NeuColors.textHintDark : NeuColors.textHint)),
        ]),
        const SizedBox(width: 8),
        Icon(Icons.arrow_forward_ios_rounded, size: 14,
            color: isDark ? NeuColors.textHintDark : NeuColors.textHint),
      ]),
    );
  }
}
