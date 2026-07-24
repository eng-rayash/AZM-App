import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_currencies.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_input.dart';
import '../domain/hrm_repository.dart';

/// Create / Edit Employee Screen.
class CreateEmployeeScreen extends ConsumerStatefulWidget {
  const CreateEmployeeScreen({super.key, this.employeeId});
  final int? employeeId;

  @override
  ConsumerState<CreateEmployeeScreen> createState() =>
      _CreateEmployeeScreenState();
}

class _CreateEmployeeScreenState
    extends ConsumerState<CreateEmployeeScreen> {
  final _formKey = GlobalKey<FormState>();

  // Personal
  final _nameCtrl = TextEditingController();
  final _nameEnCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _nationalIdCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();

  // Job
  final _positionCtrl = TextEditingController();
  final _hireDateCtrl = TextEditingController();
  final _basicSalaryCtrl = TextEditingController();

  String _selectedGender = 'ذكر';
  String _selectedNationality = 'يمني';
  String _selectedCurrency = AppCurrencies.sar;
  int? _selectedDeptId;
  String? _selectedDeptName;
  int? _selectedBranchId;
  String? _selectedBranchName;

  bool _isSubmitting = false;

  static const _genders = ['ذكر', 'أنثى'];
  static const _nationalities = [
    'يمني', 'سعودي', 'إماراتي', 'مصري', 'سوداني',
    'أردني', 'سوري', 'لبناني', 'فلسطيني', 'عراقي', 'أخرى'
  ];

  @override
  void dispose() {
    _nameCtrl.dispose();
    _nameEnCtrl.dispose();
    _phoneCtrl.dispose();
    _emailCtrl.dispose();
    _nationalIdCtrl.dispose();
    _addressCtrl.dispose();
    _notesCtrl.dispose();
    _codeCtrl.dispose();
    _positionCtrl.dispose();
    _hireDateCtrl.dispose();
    _basicSalaryCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(hrmRepositoryProvider);
      await repo.createEmployee(
        name: _nameCtrl.text.trim(),
        nameEn: _nameEnCtrl.text.trim().isEmpty ? null : _nameEnCtrl.text.trim(),
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        nationalId: _nationalIdCtrl.text.trim().isEmpty ? null : _nationalIdCtrl.text.trim(),
        departmentId: _selectedDeptId,
        departmentName: _selectedDeptName,
        branchId: _selectedBranchId,
        branchName: _selectedBranchName,
        positionTitle: _positionCtrl.text.trim().isEmpty ? null : _positionCtrl.text.trim(),
        hireDate: _hireDateCtrl.text.trim().isEmpty ? null : _hireDateCtrl.text.trim(),
        nationality: _selectedNationality,
        gender: _selectedGender,
        basicSalary: double.tryParse(_basicSalaryCtrl.text.trim()),
        currency: _selectedCurrency,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة الموظف بنجاح ✓')),
        );
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('خطأ: $e'), backgroundColor: NeuColors.danger),
        );
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1990),
      lastDate: DateTime.now(),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      _hireDateCtrl.text = picked.toIso8601String().split('T').first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final deptsAsync = ref.watch(departmentsListProvider);
    final branchesAsync = ref.watch(branchesListProvider);

    return Scaffold(
      backgroundColor: NeuColors.background(Theme.of(context).brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(Icons.close_rounded, color: textPrimary),
        ),
        title: Text(
          widget.employeeId != null ? 'تعديل الموظف' : 'موظف جديد',
          style: AppTypography.headingSmall.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.screen,
            children: [
              // ── Section: Personal ──────────────────────────────
              _SectionHeader(title: 'البيانات الشخصية', icon: Icons.person_rounded),
              AppSpacing.gapMd,

              NeuInput(
                controller: _nameCtrl,
                label: 'الاسم الكامل *',
                hint: 'الاسم باللغة العربية',
                prefixIcon: Icons.badge_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null,
              ),
              AppSpacing.gapMd,

              NeuInput(
                controller: _nameEnCtrl,
                label: 'الاسم بالإنجليزية',
                hint: 'Full name in English',
                prefixIcon: Icons.translate_rounded,
              ),
              AppSpacing.gapMd,

              NeuInput(
                controller: _codeCtrl,
                label: 'رقم الموظف',
                hint: 'مثال: EMP-001',
                prefixIcon: Icons.numbers_rounded,
              ),
              AppSpacing.gapMd,

              // Gender & Nationality row
              Row(
                children: [
                  Expanded(
                    child: _DropdownField<String>(
                      label: 'الجنس',
                      value: _selectedGender,
                      items: _genders,
                      onChanged: (v) => setState(() => _selectedGender = v!),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DropdownField<String>(
                      label: 'الجنسية',
                      value: _selectedNationality,
                      items: _nationalities,
                      onChanged: (v) => setState(() => _selectedNationality = v!),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              AppSpacing.gapMd,

              NeuInput(
                controller: _nationalIdCtrl,
                label: 'رقم الهوية / الإقامة',
                hint: 'رقم الهوية الوطنية',
                prefixIcon: Icons.credit_card_rounded,
                keyboardType: TextInputType.number,
              ),
              AppSpacing.gapMd,

              NeuInput(
                controller: _phoneCtrl,
                label: 'رقم الجوال',
                hint: '+967 xxx xxx xxx',
                prefixIcon: Icons.phone_rounded,
                keyboardType: TextInputType.phone,
              ),
              AppSpacing.gapMd,

              NeuInput(
                controller: _emailCtrl,
                label: 'البريد الإلكتروني',
                hint: 'example@company.com',
                prefixIcon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              AppSpacing.gapXl,

              // ── Section: Job ───────────────────────────────────
              _SectionHeader(title: 'بيانات الوظيفة', icon: Icons.work_rounded),
              AppSpacing.gapMd,

              NeuInput(
                controller: _positionCtrl,
                label: 'المسمى الوظيفي',
                hint: 'مثال: مدير مبيعات',
                prefixIcon: Icons.work_outline_rounded,
              ),
              AppSpacing.gapMd,

              // Department dropdown
              deptsAsync.when(
                data: (depts) => _DropdownField<int?>(
                  label: 'القسم',
                  value: _selectedDeptId,
                  items: [null, ...depts.map((d) => d.id)],
                  itemLabels: ['— اختر القسم —', ...depts.map((d) => d.name)],
                  onChanged: (v) {
                    setState(() {
                      _selectedDeptId = v;
                      _selectedDeptName = v == null
                          ? null
                          : depts.firstWhere((d) => d.id == v).name;
                    });
                  },
                  isDark: isDark,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              AppSpacing.gapMd,

              // Branch dropdown
              branchesAsync.when(
                data: (branches) => _DropdownField<int?>(
                  label: 'الفرع / الموقع',
                  value: _selectedBranchId,
                  items: [null, ...branches.map((b) => b.id)],
                  itemLabels: ['— اختر الفرع —', ...branches.map((b) => b.name)],
                  onChanged: (v) {
                    setState(() {
                      _selectedBranchId = v;
                      _selectedBranchName = v == null
                          ? null
                          : branches.firstWhere((b) => b.id == v).name;
                    });
                  },
                  isDark: isDark,
                ),
                loading: () => const LinearProgressIndicator(),
                error: (_, _) => const SizedBox.shrink(),
              ),
              AppSpacing.gapMd,

              // Hire Date
              GestureDetector(
                onTap: _pickDate,
                child: NeuCard(
                  isDark: isDark,
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  child: Row(
                    children: [
                      Icon(Icons.calendar_today_rounded,
                          color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
                          size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _hireDateCtrl.text.isEmpty
                              ? 'تاريخ التعيين'
                              : _hireDateCtrl.text,
                          style: AppTypography.bodyMedium.copyWith(
                            color: _hireDateCtrl.text.isEmpty
                                ? NeuColors.textHint
                                : NeuColors.textPrimaryFor(
                                    Theme.of(context).brightness),
                          ),
                        ),
                      ),
                      Icon(Icons.chevron_left_rounded,
                          color: NeuColors.textHint, size: 18),
                    ],
                  ),
                ),
              ),
              AppSpacing.gapXl,

              // ── Section: Salary ────────────────────────────────
              _SectionHeader(title: 'الراتب', icon: Icons.payments_rounded),
              AppSpacing.gapMd,

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 3,
                    child: NeuInput(
                      controller: _basicSalaryCtrl,
                      label: 'الراتب الأساسي',
                      hint: '0.00',
                      prefixIcon: Icons.monetization_on_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _DropdownField<String>(
                      label: 'العملة',
                      value: _selectedCurrency,
                      items: AppCurrencies.all.map((c) => c.code).toList(),
                      itemLabels: AppCurrencies.all
                          .map((c) => '${c.flag} ${c.code}')
                          .toList(),
                      onChanged: (v) => setState(() => _selectedCurrency = v!),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              AppSpacing.gapXl,

              // ── Notes ──────────────────────────────────────────
              NeuInput(
                controller: _notesCtrl,
                label: 'ملاحظات',
                hint: 'أي ملاحظات إضافية',
                maxLines: 3,
                prefixIcon: Icons.notes_rounded,
              ),
              AppSpacing.gapXxl,

              NeuButton(
                label: 'حفظ الموظف',
                onPressed: _isSubmitting ? null : _submit,
                isLoading: _isSubmitting,
                icon: Icons.check_rounded,
              ),
              AppSpacing.gapXxl,
            ],
          ),
        ),
      ),
    );
  }
}

// ── Supporting Widgets ─────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: NeuColors.navyDeep, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: AppTypography.labelMedium.copyWith(
            color: NeuColors.navyDeep,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Divider(
            color: NeuColors.navyDeep.withValues(alpha: 0.2),
            thickness: 1,
          ),
        ),
      ],
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.isDark,
    this.itemLabels,
  });
  final String label;
  final T value;
  final List<T> items;
  final List<String>? itemLabels;
  final ValueChanged<T?> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: NeuColors.textHint,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? NeuColors.dividerDark
                  : NeuColors.divider,
            ),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<T>(
              value: value,
              isExpanded: true,
              dropdownColor:
                  isDark ? NeuColors.surfaceDark : NeuColors.bgColor,
              style: AppTypography.bodySmall.copyWith(color: textPrimary),
              onChanged: onChanged,
              items: items.asMap().entries.map((entry) {
                final label = itemLabels != null
                    ? itemLabels![entry.key]
                    : entry.value.toString();
                return DropdownMenuItem<T>(
                  value: entry.value,
                  child: Text(label,
                      style: AppTypography.bodySmall
                          .copyWith(color: textPrimary)),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}