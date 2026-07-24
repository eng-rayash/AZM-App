import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_currencies.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/finance_repository.dart';

/// Expenses/Revenues List Screen (shared via [isExpense] flag).
class ExpensesRevenuesListScreen extends ConsumerStatefulWidget {
  const ExpensesRevenuesListScreen({super.key, required this.isExpense});
  final bool isExpense;

  @override
  ConsumerState<ExpensesRevenuesListScreen> createState() =>
      _ExpensesRevenuesListScreenState();
}

class _ExpensesRevenuesListScreenState
    extends ConsumerState<ExpensesRevenuesListScreen> {
  String _query = '';
  String? _categoryFilter;
  final _searchCtrl = TextEditingController();

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final accentColor = widget.isExpense ? NeuColors.danger : NeuColors.success;
    final title = widget.isExpense ? 'المصروفات' : 'الإيرادات';
    final createRoute =
        widget.isExpense ? RouteNames.expenseCreate : RouteNames.revenueCreate;

    final listAsync = widget.isExpense
        ? ref.watch(expensesListProvider)
        : ref.watch(revenuesListProvider);

    // Monthly totals
    final now = DateTime.now();
    final thisMonth =
        '${now.year}-${now.month.toString().padLeft(2, '0')}';

    return Scaffold(
      backgroundColor: NeuColors.background(Theme.of(context).brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
        ),
        title: Text(title,
            style: AppTypography.headingSmall.copyWith(
                color: textPrimary, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push(createRoute),
            icon: Icon(Icons.add_rounded, color: accentColor),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Monthly Summary ──────────────────────────────────────
          listAsync.when(
            data: (items) {
              double monthTotal = 0;
              double allTotal = 0;
              final categories = <String>{};

              if (widget.isExpense) {
                final expenses = items as List<Expense>;
                for (final e in expenses) {
                  allTotal += e.amount;
                  if ((e.date).startsWith(thisMonth)) monthTotal += e.amount;
                  if (e.category != null) categories.add(e.category!);
                }
              } else {
                final revenues = items as List<Revenue>;
                for (final r in revenues) {
                  allTotal += r.amount;
                  if ((r.date).startsWith(thisMonth)) monthTotal += r.amount;
                  if (r.category != null) categories.add(r.category!);
                }
              }

              return Column(
                children: [
                  // Summary strip
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: NeuCard(
                            isDark: isDark,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('هذا الشهر',
                                  style: AppTypography.labelSmall.copyWith(color: NeuColors.textHint)),
                              const SizedBox(height: 4),
                              Text(AppCurrencies.formatAmount(monthTotal, AppCurrencies.sar),
                                  style: AppTypography.bodyMedium.copyWith(
                                      color: accentColor, fontWeight: FontWeight.w800)),
                            ]),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: NeuCard(
                            isDark: isDark,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('الإجمالي',
                                  style: AppTypography.labelSmall.copyWith(color: NeuColors.textHint)),
                              const SizedBox(height: 4),
                              Text(AppCurrencies.formatAmount(allTotal, AppCurrencies.sar),
                                  style: AppTypography.bodyMedium.copyWith(
                                      color: textPrimary, fontWeight: FontWeight.w800)),
                            ]),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: NeuCard(
                            isDark: isDark,
                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('العدد',
                                  style: AppTypography.labelSmall.copyWith(color: NeuColors.textHint)),
                              const SizedBox(height: 4),
                              Text('${items.length} سجل',
                                  style: AppTypography.bodyMedium.copyWith(
                                      color: textPrimary, fontWeight: FontWeight.w700)),
                            ]),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Category chips
                  if (categories.isNotEmpty)
                    SizedBox(
                      height: 36,
                      child: ListView(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        children: [
                          _CatChip(
                            label: 'الكل', selected: _categoryFilter == null,
                            color: accentColor, isDark: isDark,
                            onTap: () => setState(() => _categoryFilter = null),
                          ),
                          ...categories.map((cat) => _CatChip(
                            label: cat, selected: _categoryFilter == cat,
                            color: accentColor, isDark: isDark,
                            onTap: () => setState(() =>
                                _categoryFilter = _categoryFilter == cat ? null : cat),
                          )),
                        ],
                      ),
                    ),
                ],
              );
            },
            loading: () => const SizedBox(height: 80, child: Center(child: CircularProgressIndicator())),
            error: (_, _) => const SizedBox(height: 80),
          ),

          const SizedBox(height: 8),

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
                  hintText: 'بحث...',
                  hintStyle: AppTypography.bodySmall.copyWith(color: NeuColors.textHint),
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.search_rounded, color: NeuColors.textHint),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // ── List ────────────────────────────────────────────────
          Expanded(
            child: listAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('خطأ: $e',
                    style: AppTypography.bodyMedium.copyWith(color: NeuColors.danger))),
              data: (items) {
                List<dynamic> filtered;
                if (widget.isExpense) {
                  final expenses = items as List<Expense>;
                  filtered = expenses.where((e) {
                    final matchQ = _query.isEmpty || e.title.toLowerCase().contains(_query.toLowerCase());
                    final matchC = _categoryFilter == null || e.category == _categoryFilter;
                    return matchQ && matchC;
                  }).toList();
                } else {
                  final revenues = items as List<Revenue>;
                  filtered = revenues.where((r) {
                    final matchQ = _query.isEmpty || r.title.toLowerCase().contains(_query.toLowerCase());
                    final matchC = _categoryFilter == null || r.category == _categoryFilter;
                    return matchQ && matchC;
                  }).toList();
                }

                if (filtered.isEmpty) return _EmptyList(isExpense: widget.isExpense, isDark: isDark);

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final item = filtered[i];
                    if (item is Expense) {
                      return _TransactionCard(
                        title: item.title,
                        amount: item.amount,
                        currency: item.currency,
                        category: item.category,
                        date: item.date,
                        party: item.supplierName ?? item.employeeName,
                        isExpense: true,
                        isDark: isDark,
                      );
                    } else {
                      final r = item as Revenue;
                      return _TransactionCard(
                        title: r.title,
                        amount: r.amount,
                        currency: r.currency,
                        category: r.category,
                        date: r.date,
                        party: r.clientName,
                        isExpense: false,
                        isDark: isDark,
                      );
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(createRoute),
        backgroundColor: accentColor,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          widget.isExpense ? 'مصروف جديد' : 'إيراد جديد',
          style: AppTypography.buttonLabel.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

// ── Supporting Widgets ─────────────────────────────────────────────

class _TransactionCard extends StatelessWidget {
  const _TransactionCard({
    required this.title,
    required this.amount,
    required this.currency,
    required this.date,
    required this.isExpense,
    required this.isDark,
    this.category,
    this.party,
  });
  final String title;
  final double amount;
  final String currency;
  final String date;
  final bool isExpense;
  final bool isDark;
  final String? category;
  final String? party;

  @override
  Widget build(BuildContext context) {
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final textSecondary = NeuColors.textSecondaryFor(Theme.of(context).brightness);
    final color = isExpense ? NeuColors.danger : NeuColors.success;

    return NeuCard(
      isDark: isDark,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42, height: 42,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isExpense ? Icons.money_off_rounded : Icons.attach_money_rounded,
              color: color, size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.bodyMedium.copyWith(
                        color: textPrimary, fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                if (category != null || party != null)
                  Text(
                    [?category, ?party].join(' · '),
                    style: AppTypography.bodySmall.copyWith(color: textSecondary),
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                  ),
                Text(date,
                    style: AppTypography.labelSmall.copyWith(color: NeuColors.textHint)),
              ],
            ),
          ),
          Text(
            '${isExpense ? '−' : '+'}${AppCurrencies.formatAmount(amount, currency)}',
            style: AppTypography.bodyMedium.copyWith(
                color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _CatChip extends StatelessWidget {
  const _CatChip({
    required this.label, required this.selected, required this.color,
    required this.isDark, required this.onTap,
  });
  final String label;
  final bool selected;
  final Color color;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
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

class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.isExpense, required this.isDark});
  final bool isExpense;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = isExpense ? NeuColors.danger : NeuColors.success;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: color.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: Icon(
              isExpense ? Icons.money_off_rounded : Icons.attach_money_rounded,
              size: 56, color: color.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(isExpense ? 'لا توجد مصروفات' : 'لا توجد إيرادات',
              style: AppTypography.headingSmall.copyWith(color: NeuColors.textHint)),
          const SizedBox(height: 8),
          Text('ابدأ بتسجيل أول ${isExpense ? 'مصروف' : 'إيراد'}',
              style: AppTypography.bodySmall.copyWith(color: NeuColors.textHint)),
        ],
      ),
    );
  }
}