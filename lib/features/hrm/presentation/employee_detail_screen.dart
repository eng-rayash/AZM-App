import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;

import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/related_entities_widget.dart';
import '../domain/hrm_repository.dart';
import '../../../core/database/app_database.dart';
import '../../../core/router/route_names.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Employee Detail Screen
// ─────────────────────────────────────────────────────────────────────────────
class EmployeeDetailScreen extends ConsumerWidget {
  const EmployeeDetailScreen({super.key, required this.employeeId});
  final int employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final employeesAsync = ref.watch(employeesListProvider);
    final contractsAsync = ref.watch(contractsByEmployeeProvider(employeeId));

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      body: employeesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (employees) {
          final employee = employees.firstWhere(
            (e) => e.id == employeeId,
            orElse: () => employees.first,
          );
          final contracts = contractsAsync.valueOrNull ?? [];
          return _EmployeeDetailBody(
              employee: employee, contracts: contracts, isDark: isDark);
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _EmployeeDetailBody extends StatelessWidget {
  const _EmployeeDetailBody({
    required this.employee,
    required this.contracts,
    required this.isDark,
  });

  final Employee employee;
  final List<EmployeeContract> contracts;
  final bool isDark;

  static const _statusLabels = ['نشط', 'غير نشط', 'موقوف', 'منتهي', 'مستقيل'];
  static const _statusColors = [
    NeuColors.success, NeuColors.textHint, NeuColors.warning,
    NeuColors.danger, NeuColors.textSecondary,
  ];
  static const _genderLabels = ['ذكر', 'أنثى'];
  static const _employmentTypes = ['دوام كامل', 'دوام جزئي', 'متعاقد', 'متدرب', 'عمل حر'];
  static const _maritalLabels = ['أعزب', 'متزوج', 'مطلق', 'أرمل'];

  Color get _empColor =>
      _statusColors[employee.status.clamp(0, _statusColors.length - 1)];
  String get _empStatus =>
      _statusLabels[employee.status.clamp(0, _statusLabels.length - 1)];

  @override
  Widget build(BuildContext context) {
    final tp = isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary;
    final fmt = NumberFormat('#,##0.00');

    return CustomScrollView(
      slivers: [
        // ── SliverAppBar ──────────────────────────────────────────
        SliverAppBar(
          pinned: true,
          expandedHeight: 240,
          backgroundColor: const Color(0xFF6C5CE7),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
            onPressed: () => context.pop(),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_rounded, color: Colors.white),
              onPressed: () =>
                  context.push(RouteNames.employeeEditPath(employee.id)),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF6C5CE7), Color(0xFF0984E3)],
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
                      Row(children: [
                        // Avatar
                        CircleAvatar(
                          radius: 35,
                          backgroundColor: Colors.white24,
                          child: Text(
                            employee.name.isNotEmpty ? employee.name[0] : '?',
                            style: const TextStyle(fontSize: 28,
                                fontWeight: FontWeight.w700, color: Colors.white),
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(employee.name, style: const TextStyle(
                                color: Colors.white, fontSize: 20,
                                fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
                            if (employee.positionName != null)
                              Text(employee.positionName!, style: const TextStyle(
                                  color: Colors.white70, fontSize: 13, fontFamily: 'Cairo')),
                            if (employee.departmentName != null)
                              Text(employee.departmentName!, style: const TextStyle(
                                  color: Colors.white60, fontSize: 12, fontFamily: 'Cairo')),
                            const SizedBox(height: 6),
                            // Status badge
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 3),
                              decoration: BoxDecoration(
                                color: _empColor.withValues(alpha: 0.25),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: Colors.white38),
                              ),
                              child: Text(_empStatus, style: const TextStyle(
                                  color: Colors.white, fontSize: 12, fontFamily: 'Cairo')),
                            ),
                          ],
                        )),
                      ]),
                      const SizedBox(height: 12),
                      // Salary strip
                      Row(children: [
                        const Icon(Icons.payments_rounded, color: Colors.white60, size: 16),
                        const SizedBox(width: 6),
                        Text(
                          'الراتب الأساسي: ${fmt.format(employee.basicSalary)} ر.ي',
                          style: const TextStyle(color: Colors.white70,
                              fontSize: 13, fontFamily: 'Cairo'),
                        ),
                        const Spacer(),
                        if (employee.employeeCode != null)
                          Text('#${employee.employeeCode}',
                              style: const TextStyle(color: Colors.white54,
                                  fontSize: 12, fontFamily: 'Cairo')),
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
            child: Column(children: [
              // ── Contact Info ──────────────────────────────────
              _SectionCard(
                title: 'معلومات التواصل',
                icon: Icons.contact_phone_rounded,
                isDark: isDark,
                children: [
                  if (employee.phone != null)
                    _row(Icons.phone_rounded, 'الهاتف', employee.phone!, isDark),
                  if (employee.alternativePhone != null)
                    _row(Icons.phone_android_rounded, 'هاتف بديل',
                        employee.alternativePhone!, isDark),
                  if (employee.email != null)
                    _row(Icons.email_rounded, 'البريد', employee.email!, isDark),
                  if (employee.address != null)
                    _row(Icons.location_on_rounded, 'العنوان', employee.address!, isDark),
                ],
              ),

              // ── Personal Info ──────────────────────────────────
              _SectionCard(
                title: 'المعلومات الشخصية',
                icon: Icons.person_rounded,
                isDark: isDark,
                children: [
                  _row(Icons.wc_rounded, 'الجنس',
                      _genderLabels[employee.gender.clamp(0, 1)], isDark),
                  if (employee.dateOfBirth != null)
                    _row(Icons.cake_rounded, 'تاريخ الميلاد', employee.dateOfBirth!, isDark),
                  if (employee.nationality != null)
                    _row(Icons.flag_rounded, 'الجنسية', employee.nationality!, isDark),
                  _row(Icons.favorite_rounded, 'الحالة الاجتماعية',
                      _maritalLabels[employee.maritalStatus.clamp(0, 3)], isDark),
                  if (employee.nationalId != null)
                    _row(Icons.badge_rounded, 'رقم الهوية', employee.nationalId!, isDark),
                ],
              ),

              // ── Employment Info ────────────────────────────────
              _SectionCard(
                title: 'بيانات التوظيف',
                icon: Icons.work_rounded,
                isDark: isDark,
                children: [
                  if (employee.hiringDate != null)
                    _row(Icons.event_rounded, 'تاريخ التعيين', employee.hiringDate!, isDark),
                  _row(Icons.category_rounded, 'نوع التوظيف',
                      _employmentTypes[employee.employmentType.clamp(0, 4)], isDark),
                  if (employee.branchName != null)
                    _row(Icons.business_rounded, 'الفرع', employee.branchName!, isDark),
                  if (employee.managerName != null)
                    _row(Icons.manage_accounts_rounded, 'المدير المباشر',
                        employee.managerName!, isDark),
                ],
              ),

              // ── Emergency Contact ──────────────────────────────
              if (employee.emergencyContactName != null)
                _SectionCard(
                  title: 'جهة الطوارئ',
                  icon: Icons.emergency_rounded,
                  isDark: isDark,
                  children: [
                    _row(Icons.person_rounded, 'الاسم',
                        employee.emergencyContactName!, isDark),
                    if (employee.emergencyContactPhone != null)
                      _row(Icons.phone_rounded, 'الهاتف',
                          employee.emergencyContactPhone!, isDark),
                    if (employee.emergencyContactRelation != null)
                      _row(Icons.people_rounded, 'صلة القرابة',
                          employee.emergencyContactRelation!, isDark),
                  ],
                ),

              // ── Active Contract ────────────────────────────────
              if (contracts.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Text('العقد الحالي',
                      style: AppTypography.h4.copyWith(color: tp)),
                ),
                NeuCard(
                  isDark: isDark, radius: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.all(14),
                  child: Column(children: [
                    _row(Icons.description_rounded, 'نوع العقد',
                        contracts.first.contractType == 0 ? 'محدد المدة' :
                        contracts.first.contractType == 1 ? 'غير محدد المدة' :
                        contracts.first.contractType == 2 ? 'دوام جزئي' :
                        contracts.first.contractType == 3 ? 'عمل حر' : 'غير محدد', isDark),
                    _row(Icons.calendar_today_rounded, 'بداية العقد',
                        contracts.first.startDate, isDark),
                    _row(Icons.event_busy_rounded, 'نهاية العقد',
                        contracts.first.endDate ?? 'مفتوح', isDark),
                    _row(Icons.payments_rounded, 'الراتب المتفق',
                        '${fmt.format(contracts.first.salary)} ر.ي', isDark),
                  ]),
                ),
              ],

              // ── Notes ─────────────────────────────────────────
              if (employee.notes != null && employee.notes!.isNotEmpty)
                NeuCard(
                  isDark: isDark, radius: 16,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ملاحظات', style: AppTypography.label.copyWith(
                          color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                          fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Text(employee.notes!,
                          style: AppTypography.bodySmall.copyWith(color: tp)),
                    ],
                  ),
                ),

              // ── Related Entities ───────────────────────────────
              const SizedBox(height: 8),
              RelatedEntitiesWidget(
                sourceType: EntityLinkType.employee,
                sourceId: employee.id,
                sourceLabel: employee.name,
              ),
              const SizedBox(height: 100),
            ]),
          ),
        ),
      ],
    );
  }

  Widget _row(IconData icon, String label, String value, bool isDark) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 7),
    child: Row(children: [
      Icon(icon, size: 17,
          color: isDark ? NeuColors.goldAccent.withValues(alpha: 0.7) : NeuColors.navyDeep.withValues(alpha: 0.6)),
      const SizedBox(width: 10),
      Text('$label: ', style: AppTypography.caption.copyWith(
          color: isDark ? NeuColors.textHintDark : NeuColors.textHint)),
      Expanded(child: Text(value, style: AppTypography.bodySmall.copyWith(
          color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
          fontWeight: FontWeight.w600))),
    ]),
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Card Helper
// ─────────────────────────────────────────────────────────────────────────────
class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.isDark,
    required this.children,
  });

  final String title;
  final IconData icon;
  final bool isDark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return NeuCard(
      isDark: isDark, radius: 16,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 18,
                color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
            const SizedBox(width: 8),
            Text(title, style: AppTypography.label.copyWith(
                color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
                fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 10),
          Divider(height: 1,
              color: isDark ? NeuColors.dividerDark : NeuColors.divider),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }
}