import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/hrm_repository.dart';
import '../../../core/database/app_database.dart';
import '../../../core/router/route_names.dart';
import '../../../shared/widgets/error_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Payroll Screen
// ─────────────────────────────────────────────────────────────────────────────
class PayrollScreen extends ConsumerStatefulWidget {
  const PayrollScreen({super.key});

  @override
  ConsumerState<PayrollScreen> createState() => _PayrollScreenState();
}

class _PayrollScreenState extends ConsumerState<PayrollScreen> {
  String _selectedMonth = DateFormat('yyyy-MM').format(DateTime.now());

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final employeesAsync = ref.watch(employeesListProvider);
    final fmt = NumberFormat('#,##0.00');

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        title: const Text('كشف الرواتب',
            style: TextStyle(fontFamily: 'Panorama', fontWeight: FontWeight.w700)),
        backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.navyDeep,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_rounded),
            onPressed: () => _exportPdf(context),
            tooltip: 'تصدير PDF',
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(children: [
          // ── Month Selector ────────────────────────────────
          Container(
            color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: Row(children: [
              IconButton(
                icon: Icon(Icons.chevron_right_rounded,
                    color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
                onPressed: () => _changeMonth(-1),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    _monthLabel(_selectedMonth),
                    style: AppTypography.label.copyWith(
                      color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(Icons.chevron_left_rounded,
                    color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
                onPressed: () => _changeMonth(1),
              ),
            ]),
          ),

          // ── Content ───────────────────────────────────────
          Expanded(
            child: employeesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorState(error: e),
              data: (employees) {
                final active = employees.where((e) => e.status == 0).toList();
                if (active.isEmpty) {
                  return Center(
                    child: Text('لا يوجد موظفون نشطون',
                        style: AppTypography.bodySmall.copyWith(
                            color: isDark ? NeuColors.textHintDark : NeuColors.textHint)),
                  );
                }

                final totalSalary = active.fold<double>(0, (s, e) => s + e.basicSalary);

                return Column(children: [
                  // ── Summary Banner ─────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(children: [
                      Expanded(child: _SummaryCard(
                        label: 'عدد الموظفين', value: '${active.length}',
                        icon: Icons.people_rounded, color: NeuColors.navyDeep, isDark: isDark,
                      )),
                      const SizedBox(width: 10),
                      Expanded(child: _SummaryCard(
                        label: 'إجمالي الرواتب',
                        value: fmt.format(totalSalary),
                        icon: Icons.payments_rounded, color: NeuColors.success, isDark: isDark,
                      )),
                    ]),
                  ),

                  // ── Payroll List ───────────────────────────
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: active.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 6),
                      itemBuilder: (_, i) => _PayrollRow(
                        employee: active[i],
                        isDark: isDark,
                        fmt: fmt,
                        month: _selectedMonth,
                        onTap: () => context.push(RouteNames.employeeDetailPath(active[i].id)),
                      ),
                    ),
                  ),
                ]);
              },
            ),
          ),
        ]),
      ),
    );
  }

  void _changeMonth(int direction) {
    final parts = _selectedMonth.split('-');
    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    final next = DateTime(dt.year, dt.month + direction);
    setState(() => _selectedMonth = DateFormat('yyyy-MM').format(next));
  }

  String _monthLabel(String ym) {
    final parts = ym.split('-');
    final dt = DateTime(int.parse(parts[0]), int.parse(parts[1]));
    return DateFormat('MMMM yyyy', 'ar').format(dt);
  }

  void _exportPdf(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('جارف تصدير كشف الرواتب PDF...',
            textDirection: TextDirection.rtl),
        backgroundColor: NeuColors.navyDeep,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Payroll Row
// ─────────────────────────────────────────────────────────────────────────────
class _PayrollRow extends StatelessWidget {
  const _PayrollRow({
    required this.employee, required this.isDark,
    required this.fmt, required this.month, required this.onTap,
  });

  final Employee employee;
  final bool isDark;
  final NumberFormat fmt;
  final String month;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tp = isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary;
    final th = isDark ? NeuColors.textHintDark : NeuColors.textHint;

    // Simulate deductions (10% social insurance, 5% tax)
    final basic = employee.basicSalary;
    final social = basic * 0.10;
    final tax = basic * 0.05;
    final net = basic - social - tax;

    return NeuCard(
      isDark: isDark, radius: 14,
      padding: const EdgeInsets.all(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(children: [
          Row(children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: NeuColors.navyDeep.withValues(alpha: 0.15),
              child: Text(employee.name[0], style: const TextStyle(
                  color: NeuColors.navyDeep, fontWeight: FontWeight.w700, fontFamily: 'Panorama')),
            ),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(employee.name, style: AppTypography.body.copyWith(
                  color: tp, fontWeight: FontWeight.w600)),
              Text(employee.positionName ?? employee.departmentName ?? '',
                  style: AppTypography.caption.copyWith(color: th)),
            ])),
            Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(fmt.format(net), style: TextStyle(
                  fontSize: 15, fontWeight: FontWeight.w800,
                  color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                  fontFamily: 'Panorama')),
              Text('صافي', style: AppTypography.caption.copyWith(color: th)),
            ]),
          ]),
          const SizedBox(height: 8),
          Divider(height: 1, color: isDark ? NeuColors.dividerDark : NeuColors.divider),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(child: _Deduction(
              label: 'الأساسي', value: fmt.format(basic),
              color: NeuColors.navyDeep, isDark: isDark,
            )),
            Expanded(child: _Deduction(
              label: 'تأمين', value: '−${fmt.format(social)}',
              color: NeuColors.warning, isDark: isDark,
            )),
            Expanded(child: _Deduction(
              label: 'ضريبة', value: '−${fmt.format(tax)}',
              color: NeuColors.danger, isDark: isDark,
            )),
          ]),
        ]),
      ),
    );
  }
}

class _Deduction extends StatelessWidget {
  const _Deduction({required this.label, required this.value, required this.color, required this.isDark});
  final String label, value;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Column(children: [
    Text(label, style: AppTypography.caption.copyWith(
        color: isDark ? NeuColors.textHintDark : NeuColors.textHint)),
    const SizedBox(height: 2),
    Text(value, style: TextStyle(
        fontSize: 12, fontWeight: FontWeight.w600,
        color: color, fontFamily: 'Panorama')),
  ]);
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label, required this.value,
    required this.icon, required this.color, required this.isDark,
  });
  final String label, value;
  final IconData icon;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) => NeuCard(
    isDark: isDark, radius: 16, padding: const EdgeInsets.all(14),
    child: Row(children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: AppTypography.caption.copyWith(
            color: isDark ? NeuColors.textHintDark : NeuColors.textHint)),
        Text(value, style: TextStyle(
            fontSize: 16, fontWeight: FontWeight.w800,
            color: color, fontFamily: 'Panorama')),
      ])),
    ]),
  );
}