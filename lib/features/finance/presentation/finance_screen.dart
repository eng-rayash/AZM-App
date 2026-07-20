import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_currencies.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/finance_repository.dart';


/// Finance Dashboard Screen — main hub for all financial operations.
///
/// Shows KPIs (revenue, expenses, profit) and quick access to all
/// financial modules: clients, suppliers, invoices, expenses,
/// revenues, accounts, vouchers, checks, and reports.
class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(context.brightness);
    final textSecondary = NeuColors.textSecondaryFor(context.brightness);

    return Scaffold(
      backgroundColor: NeuColors.background(context.brightness),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00B894), Color(0xFF00CEC9)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'المالية والحسابات',
                            style: AppTypography.headingMedium.copyWith(
                              color: textPrimary,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            'النظام المالي والمحاسبي',
                            style: AppTypography.bodySmall.copyWith(
                              color: textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.push(RouteNames.globalSearch),
                      icon: Icon(
                        Icons.search_rounded,
                        color: const Color(0xFF00B894),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ── KPI Row (بيانات الشهر الحالي) ───────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ref.watch(financeSummaryProvider).when(
                  loading: () => Row(children: [
                    Expanded(child: _FinKpiCard(label: 'الإيرادات', value: '...', icon: Icons.trending_up_rounded, color: NeuColors.success, isDark: isDark)),
                    const SizedBox(width: 10),
                    Expanded(child: _FinKpiCard(label: 'المصروفات', value: '...', icon: Icons.trending_down_rounded, color: NeuColors.danger, isDark: isDark)),
                    const SizedBox(width: 10),
                    Expanded(child: _FinKpiCard(label: 'الربح', value: '...', icon: Icons.savings_rounded, color: NeuColors.info, isDark: isDark)),
                  ]),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (summary) => Row(
                    children: [
                      Expanded(
                        child: _FinKpiCard(
                          label: 'الإيرادات',
                          value: AppCurrencies.formatCompact(summary.totalRevenue, AppCurrencies.sar),
                          icon: Icons.trending_up_rounded,
                          color: NeuColors.success,
                          isDark: isDark,
                          onTap: () => context.push(RouteNames.revenuesList),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FinKpiCard(
                          label: 'المصروفات',
                          value: AppCurrencies.formatCompact(summary.totalExpenses, AppCurrencies.sar),
                          icon: Icons.trending_down_rounded,
                          color: NeuColors.danger,
                          isDark: isDark,
                          onTap: () => context.push(RouteNames.expensesList),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _FinKpiCard(
                          label: 'صافي الربح',
                          value: AppCurrencies.formatCompact(summary.netProfit, AppCurrencies.sar),
                          icon: Icons.savings_rounded,
                          color: summary.netProfit >= 0 ? NeuColors.info : NeuColors.danger,
                          isDark: isDark,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Alerts Strip ─────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: NeuColors.warning.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: NeuColors.warning.withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.warning_amber_rounded,
                        color: NeuColors.warning,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'تحقق من الفواتير المستحقة والشيكات القادمة',
                          style: AppTypography.bodySmall.copyWith(
                            color: NeuColors.warning,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => context.push(RouteNames.invoicesList),
                        child: Text(
                          'عرض',
                          style: AppTypography.bodySmall.copyWith(
                            color: NeuColors.navyDeep,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Module Grid ──────────────────────────────────────────
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              sliver: SliverGrid(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                ),
                delegate: SliverChildListDelegate([
                  _FinModuleCard(
                    title: 'العملاء',
                    subtitle: 'إدارة العملاء',
                    icon: Icons.supervisor_account_rounded,
                    color: NeuColors.navyDeep,
                    onTap: () => context.push(RouteNames.clientsList),
                    isDark: isDark,
                  ),
                  _FinModuleCard(
                    title: 'الموردون',
                    subtitle: 'إدارة الموردين',
                    icon: Icons.local_shipping_rounded,
                    color: const Color(0xFF6C5CE7),
                    onTap: () => context.push(RouteNames.suppliersList),
                    isDark: isDark,
                  ),
                  _FinModuleCard(
                    title: 'الفواتير',
                    subtitle: 'فواتير المبيعات',
                    icon: Icons.receipt_long_rounded,
                    color: NeuColors.success,
                    onTap: () => context.push(RouteNames.invoicesList),
                    isDark: isDark,
                  ),
                  _FinModuleCard(
                    title: 'المصروفات',
                    subtitle: 'تتبع المصروفات',
                    icon: Icons.money_off_rounded,
                    color: NeuColors.danger,
                    onTap: () => context.push(RouteNames.expensesList),
                    isDark: isDark,
                  ),
                  _FinModuleCard(
                    title: 'الإيرادات',
                    subtitle: 'سجل الإيرادات',
                    icon: Icons.attach_money_rounded,
                    color: const Color(0xFF00B894),
                    onTap: () => context.push(RouteNames.revenuesList),
                    isDark: isDark,
                  ),
                  _FinModuleCard(
                    title: 'المشاريع',
                    subtitle: 'إدارة المشاريع',
                    icon: Icons.work_rounded,
                    color: const Color(0xFFE17055),
                    onTap: () => context.push(RouteNames.projectsList),
                    isDark: isDark,
                  ),
                  _FinModuleCard(
                    title: 'دليل الحسابات',
                    subtitle: 'شجرة الحسابات',
                    icon: Icons.account_tree_rounded,
                    color: const Color(0xFF0984E3),
                    onTap: () => context.push(RouteNames.chartOfAccounts),
                    isDark: isDark,
                  ),
                  _FinModuleCard(
                    title: 'القيود',
                    subtitle: 'القيود اليومية',
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFFFF7675),
                    onTap: () => context.push(RouteNames.journalEntries),
                    isDark: isDark,
                  ),
                  _FinModuleCard(
                    title: 'الحسابات البنكية',
                    subtitle: 'الأرصدة البنكية',
                    icon: Icons.account_balance_rounded,
                    color: const Color(0xFF55EFC4).withOpacity(0.8),
                    onTap: () => context.push(RouteNames.bankAccountsList),
                    isDark: isDark,
                  ),
                  _FinModuleCard(
                    title: 'سندات',
                    subtitle: 'قبض وصرف',
                    icon: Icons.receipt_rounded,
                    color: const Color(0xFFFDCB6E),
                    onTap: () =>
                        context.push(RouteNames.paymentVouchersList),
                    isDark: isDark,
                  ),
                  _FinModuleCard(
                    title: 'الشيكات',
                    subtitle: 'متابعة الشيكات',
                    icon: Icons.check_box_rounded,
                    color: const Color(0xFFE84393),
                    onTap: () => context.push(RouteNames.checksList),
                    isDark: isDark,
                  ),
                  _FinModuleCard(
                    title: 'التقارير',
                    subtitle: 'التحليل المالي',
                    icon: Icons.bar_chart_rounded,
                    color: NeuColors.navyDeep,
                    onTap: () => context.push(RouteNames.financeReports),
                    isDark: isDark,
                  ),
                ]),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.invoiceCreate),
        backgroundColor: const Color(0xFF00B894),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: Text(
          'فاتورة جديدة',
          style: AppTypography.buttonLabel.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

// ── Supporting Widgets ─────────────────────────────────────────────

class _FinKpiCard extends StatelessWidget {
  const _FinKpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.isDark,
    this.onTap,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool isDark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: NeuCard(
        isDark: isDark,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Column(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(
              value,
              style: AppTypography.headingSmall.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              label,
              style: AppTypography.labelSmall.copyWith(
                color: NeuColors.textHint,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _FinModuleCard extends StatelessWidget {
  const _FinModuleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
    required this.isDark,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textPrimary = NeuColors.textPrimaryFor(context.brightness);
    final textSecondary = NeuColors.textSecondaryFor(context.brightness);

    return GestureDetector(
      onTap: onTap,
      child: NeuCard(
        isDark: isDark,
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: AppTypography.bodyMedium.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: AppTypography.bodySmall.copyWith(
                      color: textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: NeuColors.textHint,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }
}

extension on BuildContext {
  Brightness get brightness => Theme.of(this).brightness;
}
