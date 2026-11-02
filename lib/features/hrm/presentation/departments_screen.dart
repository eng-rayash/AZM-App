import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/neu_card.dart';
import '../domain/hrm_repository.dart';
import '../../../core/database/app_database.dart';
import '../../../core/router/route_names.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../core/design/azm_tokens.dart';

/// حوار إنشاء قسم.
///
/// كان زرّا «قسم جديد» يقودان إلى مسار غير مسجّل في الراوتر فتظهر صفحة خطأ.
/// المستودع يملك `createDepartment` أصلًا، فالناقص كان واجهة إدخال لا منطقًا.
Future<void> _showCreateDepartment(
  BuildContext context,
  WidgetRef ref,
  bool isDark,
) async {
  final created = await showDialog<bool>(
    context: context,
    builder: (_) => CreateDepartmentDialog(isDark: isDark),
  );

  if (created == true && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('أُضيف القسم.')),
    );
  }
}

/// محتوى حوار الإنشاء.
///
/// مكوّن ذو حالة عمدًا: المتحكّمات النصّية يجب أن يملكها من يعيش ويموت
/// مع الحقول نفسها. التخلّص منها بعد عودة `showDialog` مباشرة يقع بينما
/// حركة إغلاق الحوار لم تنتهِ والحقول ما زالت مركَّبة، فيفشل التأكيد
/// `_dependents.isEmpty` وتتعطّل الشاشة.
@visibleForTesting
class CreateDepartmentDialog extends ConsumerStatefulWidget {
  const CreateDepartmentDialog({super.key, required this.isDark});

  final bool isDark;

  @override
  ConsumerState<CreateDepartmentDialog> createState() =>
      _CreateDepartmentDialogState();
}

class _CreateDepartmentDialogState
    extends ConsumerState<CreateDepartmentDialog> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _saving = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    try {
      await ref.read(hrmRepositoryProvider).createDepartment(
            name: _nameCtrl.text.trim(),
            description:
                _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          );
      if (mounted) Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تعذّر حفظ القسم: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = widget.isDark;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        backgroundColor: isDark ? NeuColors.surfaceDark : NeuColors.surface,
        title: Text(
          'قسم جديد',
          style: AppTypography.h3.copyWith(
            color:
                isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
          ),
        ),
        content: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameCtrl,
                autofocus: true,
                enabled: !_saving,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  labelText: 'اسم القسم',
                  hintText: 'المبيعات',
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'اسم القسم مطلوب' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descCtrl,
                enabled: !_saving,
                onFieldSubmitted: (_) => _save(),
                decoration: const InputDecoration(
                  labelText: 'الوصف (اختياري)',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : () => Navigator.of(context).pop(false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}


// ─────────────────────────────────────────────────────────────────────────────
// Departments Screen
// ─────────────────────────────────────────────────────────────────────────────
class DepartmentsScreen extends ConsumerWidget {
  const DepartmentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final deptsAsync = ref.watch(departmentsListProvider);
    final employeesAsync = ref.watch(employeesListProvider);

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        title: const Text('الأقسام', style: TextStyle(fontFamily: 'Panorama', fontWeight: FontWeight.w700)),
        backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.navyDeep,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            onPressed: () => _showCreateDepartment(context, ref, isDark),
            tooltip: 'قسم جديد',
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: deptsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => ErrorState(error: e),
          data: (depts) {
            final employees = employeesAsync.valueOrNull ?? [];
            if (depts.isEmpty) {
              return _EmptyDepts(isDark: isDark);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: depts.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (_, i) {
                final dept = depts[i];
                final count = employees
                    .where((e) => e.departmentId == dept.id && e.status == 0)
                    .length;
                return _DeptCard(
                  dept: dept,
                  employeeCount: count,
                  isDark: isDark,
                  onTap: () => _showDeptDetails(context, dept, employees, isDark),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showDeptDetails(
    BuildContext context,
    Department dept,
    List<Employee> employees,
    bool isDark,
  ) {
    final deptEmployees = employees
        .where((e) => e.departmentId == dept.id && e.status == 0)
        .toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? NeuColors.surfaceDark : NeuColors.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Directionality(
        textDirection: TextDirection.rtl,
        child: DraggableScrollableSheet(
          initialChildSize: 0.6,
          maxChildSize: 0.9,
          minChildSize: 0.4,
          expand: false,
          builder: (ctx, ctrl) => Column(children: [
            // Handle
            const SizedBox(height: 12),
            Center(child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[700] : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            )),
            const SizedBox(height: 16),
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(children: [
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [NeuColors.moduleDelivery, NeuColors.info],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.domain_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(dept.name, style: AppTypography.h4.copyWith(
                      color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary)),
                  if (dept.description != null)
                    Text(dept.description!, style: AppTypography.caption.copyWith(
                        color: isDark ? NeuColors.textHintDark : NeuColors.textHint)),
                ])),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: NeuColors.navyDeep.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text('${deptEmployees.length} موظف',
                      style: AppTypography.caption.copyWith(
                          color: NeuColors.navyDeep, fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
            const SizedBox(height: 16),
            Divider(height: 1, color: isDark ? NeuColors.dividerDark : NeuColors.divider),
            // Employees list
            Expanded(
              child: deptEmployees.isEmpty
                  ? Center(child: Text('لا يوجد موظفون في هذا القسم',
                      style: AppTypography.bodySmall.copyWith(
                          color: isDark ? NeuColors.textHintDark : NeuColors.textHint)))
                  : ListView.builder(
                      controller: ctrl,
                      padding: const EdgeInsets.all(16),
                      itemCount: deptEmployees.length,
                      itemBuilder: (_, i) {
                        final emp = deptEmployees[i];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundColor: NeuColors.navyDeep.withValues(alpha: 0.15),
                            child: Text(emp.name[0],
                                style: const TextStyle(
                                    color: NeuColors.navyDeep,
                                    fontWeight: FontWeight.w700,
                                    fontFamily: 'Panorama')),
                          ),
                          title: Text(emp.name, style: AppTypography.body.copyWith(
                              color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
                              fontWeight: FontWeight.w600)),
                          subtitle: Text(emp.positionName ?? 'موظف',
                              style: AppTypography.caption.copyWith(
                                  color: isDark ? NeuColors.textHintDark : NeuColors.textHint)),
                          trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                          onTap: () {
                            Navigator.pop(ctx);
                            context.push(RouteNames.employeeDetailPath(emp.id));
                          },
                        );
                      },
                    ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _DeptCard extends StatelessWidget {
  const _DeptCard({
    required this.dept, required this.employeeCount,
    required this.isDark, required this.onTap,
  });

  final Department dept;
  final int employeeCount;
  final bool isDark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tp = isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary;
    final th = isDark ? NeuColors.textHintDark : NeuColors.textHint;

    return NeuCard(
      isDark: isDark, radius: AzmRadius.sm,
      padding: const EdgeInsets.all(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Row(children: [
          Container(
            width: 48, height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [NeuColors.moduleDelivery, NeuColors.info],
                begin: Alignment.topRight, end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.domain_rounded, color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(dept.name, style: AppTypography.body.copyWith(
                color: tp, fontWeight: FontWeight.w700)),
            if (dept.description != null)
              Text(dept.description!, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: AppTypography.caption.copyWith(color: th)),
          ])),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text('$employeeCount', style: TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800,
                color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                fontFamily: 'Panorama')),
            Text('موظف', style: AppTypography.caption.copyWith(color: th)),
          ]),
          const SizedBox(width: 8),
          Icon(Icons.chevron_right_rounded, color: th),
        ]),
      ),
    );
  }
}

class _EmptyDepts extends StatelessWidget {
  const _EmptyDepts({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final th = isDark ? NeuColors.textHintDark : NeuColors.textHint;
    return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
      Icon(Icons.domain_rounded, size: 64,
          color: NeuColors.navyDeep.withValues(alpha: 0.25)),
      const SizedBox(height: 16),
      Text('لا توجد أقسام بعد', style: AppTypography.bodySmall.copyWith(color: th)),
      const SizedBox(height: 8),
      // الحالة الفارغة مكوّن بلا `ref` — يُلتقط من `Consumer` هنا وحده
      Consumer(
        builder: (ctx, ref, _) => ElevatedButton.icon(
        onPressed: () => _showCreateDepartment(ctx, ref, isDark),
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('إضافة قسم', style: TextStyle(color: Colors.white, fontFamily: 'Panorama')),
        style: ElevatedButton.styleFrom(
          backgroundColor: NeuColors.navyDeep,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        ),
      ),
    ]));
  }
}