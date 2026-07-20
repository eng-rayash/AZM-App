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
import '../../../core/constants/enums.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Attendance Screen — Daily attendance/leave tracking
// ─────────────────────────────────────────────────────────────────────────────
class AttendanceScreen extends ConsumerStatefulWidget {
  const AttendanceScreen({super.key});

  @override
  ConsumerState<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends ConsumerState<AttendanceScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;
  DateTime _selectedDate = DateTime.now();
  final _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final employeesAsync = ref.watch(employeesListProvider);
    final attendanceAsync = ref.watch(
        attendanceByDateProvider(_dateFormat.format(_selectedDate)));
    final leavesAsync = ref.watch(pendingLeavesProvider);

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        title: const Text('الحضور والإجازات',
            style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
        backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.navyDeep,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white54,
          indicatorColor: NeuColors.goldAccent,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'الحضور اليومي'),
            Tab(text: 'طلبات الإجازة'),
          ],
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: TabBarView(
          controller: _tabCtrl,
          children: [
            // ── Tab 1: Daily Attendance ─────────────────────
            _AttendanceTab(
              isDark: isDark,
              selectedDate: _selectedDate,
              onDateChanged: (d) => setState(() => _selectedDate = d),
              employeesAsync: employeesAsync,
              attendanceAsync: attendanceAsync,
              dateFormat: _dateFormat,
            ),

            // ── Tab 2: Leave Requests ───────────────────────
            _LeavesTab(
              isDark: isDark,
              leavesAsync: leavesAsync,
              employeesAsync: employeesAsync,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Attendance Tab
// ─────────────────────────────────────────────────────────────────────────────
class _AttendanceTab extends StatelessWidget {
  const _AttendanceTab({
    required this.isDark,
    required this.selectedDate,
    required this.onDateChanged,
    required this.employeesAsync,
    required this.attendanceAsync,
    required this.dateFormat,
  });

  final bool isDark;
  final DateTime selectedDate;
  final void Function(DateTime) onDateChanged;
  final AsyncValue<List<Employee>> employeesAsync;
  final AsyncValue<List<AttendanceRecord>> attendanceAsync;
  final DateFormat dateFormat;

  @override
  Widget build(BuildContext context) {
    final employees = employeesAsync.valueOrNull ?? [];
    final attendance = attendanceAsync.valueOrNull ?? [];
    final active = employees.where((e) => e.status == 0).toList();

    final presentIds = attendance
        .where((a) => a.status == 0 || a.status == 2 || a.status == 3)
        .map((a) => a.employeeId)
        .toSet();
    final absentIds = active
        .where((e) => !presentIds.contains(e.id))
        .map((e) => e.id)
        .toSet();

    return Column(children: [
      // Date selector
      Container(
        color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(children: [
          IconButton(
            icon: Icon(Icons.chevron_right_rounded,
                color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep),
            onPressed: () => onDateChanged(
                selectedDate.subtract(const Duration(days: 1))),
          ),
          Expanded(
            child: Center(
              child: Text(
                DateFormat('EEEE، d MMMM yyyy', 'ar').format(selectedDate),
                style: AppTypography.label.copyWith(
                  color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          IconButton(
            icon: Icon(Icons.chevron_left_rounded,
                color: selectedDate.day == DateTime.now().day
                    ? (isDark ? NeuColors.textHintDark : NeuColors.textHint)
                    : (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)),
            onPressed: selectedDate.day == DateTime.now().day
                ? null
                : () => onDateChanged(
                    selectedDate.add(const Duration(days: 1))),
          ),
        ]),
      ),

      // Summary chips
      Padding(
        padding: const EdgeInsets.all(12),
        child: Row(children: [
          _StatusChip(
            label: 'حاضر', count: presentIds.length,
            color: NeuColors.success, isDark: isDark,
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: 'غائب', count: absentIds.length,
            color: NeuColors.danger, isDark: isDark,
          ),
          const SizedBox(width: 8),
          _StatusChip(
            label: 'الكل', count: active.length,
            color: NeuColors.navyDeep, isDark: isDark,
          ),
        ]),
      ),

      // Employee list
      Expanded(
        child: active.isEmpty
            ? Center(child: Text('لا يوجد موظفون',
                style: AppTypography.bodySmall.copyWith(
                    color: isDark ? NeuColors.textHintDark : NeuColors.textHint)))
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                itemCount: active.length,
                separatorBuilder: (_, _) => const SizedBox(height: 6),
                itemBuilder: (ctx, i) {
                  final emp = active[i];
                  final rec = attendance.where((a) => a.employeeId == emp.id).firstOrNull;
                  final isPresent = presentIds.contains(emp.id);
                  return _AttendanceTile(
                    employee: emp,
                    record: rec,
                    isPresent: isPresent,
                    isDark: isDark,
                    onTap: () => context.push(RouteNames.employeeDetailPath(emp.id)),
                  );
                },
              ),
      ),
    ]);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Leave Requests Tab
// ─────────────────────────────────────────────────────────────────────────────
class _LeavesTab extends StatelessWidget {
  const _LeavesTab({
    required this.isDark, required this.leavesAsync, required this.employeesAsync,
  });

  final bool isDark;
  final AsyncValue<List<LeaveRequest>> leavesAsync;
  final AsyncValue<List<Employee>> employeesAsync;

  @override
  Widget build(BuildContext context) {
    final leaves = leavesAsync.valueOrNull ?? [];
    final employees = employeesAsync.valueOrNull ?? [];

    if (leaves.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.beach_access_rounded, size: 64,
              color: NeuColors.navyDeep.withOpacity(0.25)),
          const SizedBox(height: 12),
          Text('لا توجد طلبات إجازة معلقة',
              style: AppTypography.bodySmall.copyWith(
                  color: isDark ? NeuColors.textHintDark : NeuColors.textHint)),
        ]),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: leaves.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final leave = leaves[i];
        final emp = employees.firstWhere(
          (e) => e.id == leave.employeeId,
          orElse: () => employees.isNotEmpty ? employees.first : throw Exception('no emp'),
        );
        return _LeaveCard(leave: leave, employee: emp, isDark: isDark);
      },
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Helper Widgets
// ─────────────────────────────────────────────────────────────────────────────
class _AttendanceTile extends StatelessWidget {
  const _AttendanceTile({
    required this.employee, required this.record,
    required this.isPresent, required this.isDark, required this.onTap,
  });

  final Employee employee;
  final AttendanceRecord? record;
  final bool isPresent, isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tp = isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary;
    final th = isDark ? NeuColors.textHintDark : NeuColors.textHint;
    final color = isPresent ? NeuColors.success : NeuColors.danger;
    final statusText = isPresent ? 'حاضر' : 'غائب';

    return NeuCard(
      isDark: isDark, radius: 12,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Row(children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.15),
            child: Text(employee.name[0], style: TextStyle(
                color: color, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(employee.name, style: AppTypography.body.copyWith(
                color: tp, fontWeight: FontWeight.w600)),
            Text(employee.positionName ?? '',
                style: AppTypography.caption.copyWith(color: th)),
          ])),
          if (record?.checkIn != null)
            Text(record!.checkIn!, style: AppTypography.caption.copyWith(
                color: NeuColors.success, fontWeight: FontWeight.w700)),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(statusText, style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: color, fontFamily: 'Cairo')),
          ),
        ]),
      ),
    );
  }
}

class _LeaveCard extends StatelessWidget {
  const _LeaveCard({required this.leave, required this.employee, required this.isDark});
  final LeaveRequest leave;
  final Employee employee;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final tp = isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary;
    final th = isDark ? NeuColors.textHintDark : NeuColors.textHint;

    return NeuCard(
      isDark: isDark, radius: 14, padding: const EdgeInsets.all(14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: NeuColors.warning.withOpacity(0.15),
            child: Text(employee.name[0], style: const TextStyle(
                color: NeuColors.warning, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(employee.name, style: AppTypography.body.copyWith(
                color: tp, fontWeight: FontWeight.w700)),
            Text(LeaveType.fromValue(leave.leaveType).arabicLabel,
                style: AppTypography.caption.copyWith(color: th)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: NeuColors.warning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('معلق', style: TextStyle(
                fontSize: 11, fontWeight: FontWeight.w700,
                color: NeuColors.warning, fontFamily: 'Cairo')),
          ),
        ]),
        const SizedBox(height: 10),
        Row(children: [
          Icon(Icons.date_range_rounded, size: 14, color: th),
          const SizedBox(width: 6),
          Text('${leave.startDate} → ${leave.endDate}',
              style: AppTypography.caption.copyWith(color: th)),
        ]),
        if (leave.reason != null && leave.reason!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(leave.reason!, style: AppTypography.caption.copyWith(color: th)),
        ],
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: NeuColors.success,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('قبول',
                  style: TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 13)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: NeuColors.danger,
                padding: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Text('رفض',
                  style: TextStyle(color: Colors.white, fontFamily: 'Cairo', fontSize: 13)),
            ),
          ),
        ]),
      ]),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.label, required this.count,
    required this.color, required this.isDark,
  });
  final String label;
  final int count;
  final Color color;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: color.withOpacity(0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      Container(width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
      const SizedBox(width: 6),
      Text('$label ($count)', style: TextStyle(
          fontSize: 12, fontWeight: FontWeight.w600,
          color: color, fontFamily: 'Cairo')),
    ]),
  );
}
