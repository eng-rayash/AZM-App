import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/enums.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../core/database/app_database.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/hrm_repository.dart';

/// Employees List Screen — displays all employees with search and filters.
class EmployeesListScreen extends ConsumerStatefulWidget {
  const EmployeesListScreen({super.key});

  @override
  ConsumerState<EmployeesListScreen> createState() =>
      _EmployeesListScreenState();
}

class _EmployeesListScreenState extends ConsumerState<EmployeesListScreen>
    with SingleTickerProviderStateMixin {
  final _searchCtrl = TextEditingController();
  String _query = '';
  int? _deptFilter;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);

    final employeesAsync = ref.watch(employeesListProvider);
    final deptsAsync = ref.watch(departmentsListProvider);

    return Scaffold(
      backgroundColor: NeuColors.background(Theme.of(context).brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: textPrimary),
        ),
        title: Text(
          'الموظفون',
          style: AppTypography.headingSmall.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () => context.push(RouteNames.employeeCreate),
            icon: Icon(Icons.person_add_rounded, color: NeuColors.navyDeep),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Search ──────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: NeuCard(
              isDark: isDark,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _query = v.trim()),
                decoration: InputDecoration(
                  hintText: 'بحث عن موظف...',
                  hintStyle: AppTypography.bodySmall
                      .copyWith(color: NeuColors.textHint),
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: NeuColors.textHint,
                  ),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.clear_rounded),
                        )
                      : null,
                ),
              ),
            ),
          ),

          // ── Dept Filter chips ────────────────────────────────────
          deptsAsync.when(
            data: (depts) => depts.isEmpty
                ? const SizedBox.shrink()
                : SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _DeptChip(
                          label: 'الكل',
                          selected: _deptFilter == null,
                          onTap: () => setState(() => _deptFilter = null),
                          isDark: isDark,
                        ),
                        ...depts.map((d) => _DeptChip(
                              label: d.name,
                              selected: _deptFilter == d.id,
                              onTap: () =>
                                  setState(() => _deptFilter = d.id),
                              isDark: isDark,
                            )),
                      ],
                    ),
                  ),
            loading: () => const SizedBox(height: 40),
            error: (err, stack) => const SizedBox(height: 40),
          ),

          const SizedBox(height: 8),

          // ── Employees List ───────────────────────────────────────
          Expanded(
            child: employeesAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(
                child: Text('خطأ: $e',
                    style: AppTypography.bodyMedium
                        .copyWith(color: NeuColors.danger)),
              ),
              data: (employees) {
                // Apply filters
                var filtered = employees.where((e) {
                  final matchQuery = _query.isEmpty ||
                      e.name
                          .toLowerCase()
                          .contains(_query.toLowerCase()) ||
                      (e.employeeCode?.contains(_query) ?? false) ||
                      (e.phone?.contains(_query) ?? false);
                  final matchDept =
                      _deptFilter == null || e.departmentId == _deptFilter;
                  return matchQuery && matchDept;
                }).toList();

                if (filtered.isEmpty) {
                  return _EmptyState(isDark: isDark);
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 4),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) => _EmployeeCard(
                    employee: filtered[i],
                    isDark: isDark,
                    onTap: () => context.push(
                      RouteNames.employeeDetailPath(filtered[i].id),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(RouteNames.employeeCreate),
        icon: const Icon(Icons.person_add_rounded, color: Colors.white),
        label: Text(
          'موظف جديد',
          style:
              AppTypography.buttonLabel.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}

// ── Supporting Widgets ─────────────────────────────────────────────

class _DeptChip extends StatelessWidget {
  const _DeptChip({
    required this.label,
    required this.selected,
    required this.onTap,
    required this.isDark,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsetsDirectional.only(end: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected
              ? (isDark ? NeuColors.goldAccent : NeuColors.navyDeep)
              : (isDark ? NeuColors.surfaceDark : NeuColors.surface),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: selected
                ? Colors.white
                : NeuColors.textSecondaryFor(
                    isDark ? Brightness.dark : Brightness.light),
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _EmployeeCard extends StatelessWidget {
  const _EmployeeCard({
    required this.employee,
    required this.isDark,
    required this.onTap,
  });
  final Employee employee;
  final bool isDark;
  final VoidCallback onTap;

  Color get _statusColor {
    final s = EmployeeStatus.fromValue(employee.status);
    switch (s) {
      case EmployeeStatus.active:
        return NeuColors.success;
      case EmployeeStatus.onLeave:
        return NeuColors.info;
      case EmployeeStatus.suspended:
        return NeuColors.warning;
      default:
        return NeuColors.danger;
    }
  }

  String get _initials {
    final parts = employee.name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}';
    }
    return parts[0].isNotEmpty ? parts[0][0] : '?';
  }

  @override
  Widget build(BuildContext context) {
    final textPrimary =
        NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final textSecondary =
        NeuColors.textSecondaryFor(Theme.of(context).brightness);

    return GestureDetector(
      onTap: onTap,
      child: NeuCard(
        isDark: isDark,
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            // Avatar
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    NeuColors.navyDeep,
                    NeuColors.navyMid,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  _initials,
                  style: AppTypography.headingSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    employee.name,
                    style: AppTypography.bodyMedium.copyWith(
                      color: textPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (employee.positionName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      employee.positionName!,
                      style: AppTypography.bodySmall
                          .copyWith(color: textSecondary),
                    ),
                  ],
                  if (employee.departmentName != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.account_tree_rounded,
                          size: 12,
                          color: NeuColors.textHint,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          employee.departmentName!,
                          style: AppTypography.labelSmall.copyWith(
                            color: NeuColors.textHint,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),

            // Status badge
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: _statusColor.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    EmployeeStatus.fromValue(employee.status).arabicLabel,
                    style: AppTypography.labelSmall.copyWith(
                      color: _statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (employee.employeeCode != null) ...[
                  const SizedBox(height: 6),
                  Text(
                    '#${employee.employeeCode}',
                    style: AppTypography.labelSmall
                        .copyWith(color: NeuColors.textHint),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: NeuColors.navyDeep.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.badge_rounded,
              size: 56,
              color: NeuColors.navyDeep.withValues(alpha: 0.4),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'لا يوجد موظفون',
            style: AppTypography.headingSmall.copyWith(
              color: NeuColors.textHint,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'أضف أول موظف بالضغط على الزر أدناه',
            style: AppTypography.bodySmall.copyWith(
              color: NeuColors.textHint,
            ),
          ),
        ],
      ),
    );
  }
}