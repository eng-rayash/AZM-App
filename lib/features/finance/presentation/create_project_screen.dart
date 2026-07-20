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
import '../domain/finance_repository.dart';

/// Create / Edit Project Screen.
class CreateProjectScreen extends ConsumerStatefulWidget {
  const CreateProjectScreen({super.key, this.projectId});
  final int? projectId;

  @override
  ConsumerState<CreateProjectScreen> createState() =>
      _CreateProjectScreenState();
}

class _CreateProjectScreenState extends ConsumerState<CreateProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _clientCtrl = TextEditingController();
  final _managerCtrl = TextEditingController();
  final _valueCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _tagsCtrl = TextEditingController();

  int _status = 0; // planning
  String _currency = AppCurrencies.sar;
  String? _startDate;
  String? _endDate;
  double _progress = 0;
  int _priority = 1; // medium
  bool _isSubmitting = false;

  static const _statuses = [
    (0, 'تخطيط', Color(0xFF0984E3)),
    (1, 'نشط', Color(0xFF00B894)),
    (2, 'متوقف', Color(0xFFFDCB6E)),
    (3, 'مكتمل', Color(0xFF6C5CE7)),
    (4, 'ملغي', Color(0xFFD63031)),
  ];

  static const _priorities = [
    (0, 'منخفضة', Icons.arrow_downward_rounded, Color(0xFF636E72)),
    (1, 'متوسطة', Icons.remove_rounded, Color(0xFF0984E3)),
    (2, 'عالية', Icons.arrow_upward_rounded, Color(0xFFE17055)),
    (3, 'عاجلة', Icons.priority_high_rounded, Color(0xFFD63031)),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose(); _descCtrl.dispose(); _clientCtrl.dispose();
    _managerCtrl.dispose(); _valueCtrl.dispose(); _locationCtrl.dispose();
    _tagsCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1825)),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      final str = picked.toIso8601String().split('T').first;
      setState(() {
        if (isStart) {
          _startDate = str;
        } else {
          _endDate = str;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(financeRepositoryProvider).createProject(
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        clientName: _clientCtrl.text.trim().isEmpty ? null : _clientCtrl.text.trim(),
        managerName: _managerCtrl.text.trim().isEmpty ? null : _managerCtrl.text.trim(),
        status: _status,
        priority: _priority,
        startDate: _startDate,
        endDate: _endDate,
        contractValue: double.tryParse(_valueCtrl.text.trim()) ?? 0.0,
        currency: _currency,
        progress: _progress.toInt(),
        location: _locationCtrl.text.trim().isEmpty ? null : _locationCtrl.text.trim(),
        tags: _tagsCtrl.text.trim().isEmpty ? null : _tagsCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء المشروع بنجاح ✓')),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    final accent = const Color(0xFFE17055);

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
          widget.projectId != null ? 'تعديل المشروع' : 'مشروع جديد',
          style: AppTypography.headingSmall.copyWith(
              color: textPrimary, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: Text('حفظ',
                style: AppTypography.labelMedium.copyWith(
                    color: accent, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: AppSpacing.screen,
            children: [
              // ── Basic Info ───────────────────────────────────────
              NeuInput(
                controller: _nameCtrl,
                label: 'اسم المشروع *',
                hint: 'عنوان المشروع',
                prefixIcon: Icons.work_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              ),
              AppSpacing.gapMd,

              NeuInput(
                controller: _descCtrl,
                label: 'الوصف',
                hint: 'تفاصيل ونطاق المشروع',
                prefixIcon: Icons.description_rounded,
                maxLines: 3,
              ),
              AppSpacing.gapMd,

              Row(children: [
                Expanded(
                  child: NeuInput(
                    controller: _clientCtrl,
                    label: 'العميل',
                    hint: 'اسم العميل',
                    prefixIcon: Icons.supervisor_account_rounded,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeuInput(
                    controller: _managerCtrl,
                    label: 'مدير المشروع',
                    hint: 'الاسم الكامل',
                    prefixIcon: Icons.manage_accounts_rounded,
                  ),
                ),
              ]),
              AppSpacing.gapLg,

              // ── Status & Priority ─────────────────────────────────
              Text('الحالة',
                  style: AppTypography.labelSmall.copyWith(color: NeuColors.textHint)),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _statuses.map((s) {
                    final selected = _status == s.$1;
                    return GestureDetector(
                      onTap: () => setState(() => _status = s.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsetsDirectional.only(end: 8),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected ? s.$3 : (isDark ? NeuColors.surfaceDark : NeuColors.surface),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: selected ? s.$3 : s.$3.withOpacity(0.3)),
                        ),
                        child: Text(s.$2,
                            style: AppTypography.bodySmall.copyWith(
                              color: selected ? Colors.white : s.$3,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                            )),
                      ),
                    );
                  }).toList(),
                ),
              ),
              AppSpacing.gapMd,

              Text('الأولوية',
                  style: AppTypography.labelSmall.copyWith(color: NeuColors.textHint)),
              const SizedBox(height: 8),
              Row(
                children: _priorities.map((p) {
                  final selected = _priority == p.$1;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = p.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsetsDirectional.only(end: 6),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected ? p.$4 : (isDark ? NeuColors.surfaceDark : NeuColors.surface),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(children: [
                          Icon(p.$3,
                              color: selected ? Colors.white : p.$4, size: 18),
                          const SizedBox(height: 4),
                          Text(p.$2, style: AppTypography.labelSmall.copyWith(
                              color: selected ? Colors.white : p.$4,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
                        ]),
                      ),
                    ),
                  );
                }).toList(),
              ),
              AppSpacing.gapLg,

              // ── Dates ────────────────────────────────────────────
              Row(children: [
                Expanded(
                  child: _DateField(
                    label: 'تاريخ البداية',
                    value: _startDate,
                    onTap: () => _pickDate(isStart: true),
                    isDark: isDark,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _DateField(
                    label: 'تاريخ الانتهاء',
                    value: _endDate,
                    onTap: () => _pickDate(isStart: false),
                    isDark: isDark,
                  ),
                ),
              ]),
              AppSpacing.gapLg,

              // ── Financial ────────────────────────────────────────
              Row(children: [
                Expanded(
                  flex: 2,
                  child: NeuInput(
                    controller: _valueCtrl,
                    label: 'قيمة العقد',
                    hint: '0.00',
                    prefixIcon: Icons.monetization_on_rounded,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('العملة',
                          style: AppTypography.labelSmall.copyWith(color: NeuColors.textHint)),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        decoration: BoxDecoration(
                          color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: isDark ? NeuColors.dividerDark : NeuColors.divider),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: _currency,
                            isExpanded: true,
                            dropdownColor: isDark ? NeuColors.surfaceDark : NeuColors.bgColor,
                            onChanged: (v) => setState(() => _currency = v!),
                            items: AppCurrencies.all.map((c) => DropdownMenuItem(
                              value: c.code,
                              child: Text('${c.flag} ${c.code}',
                                  style: AppTypography.bodySmall.copyWith(color: textPrimary)),
                            )).toList(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ]),
              AppSpacing.gapLg,

              // ── Progress ─────────────────────────────────────────
              NeuCard(
                isDark: isDark,
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('نسبة الإنجاز',
                          style: AppTypography.labelMedium.copyWith(color: NeuColors.navyDeep)),
                      Text('${_progress.toInt()}%',
                          style: AppTypography.headingSmall.copyWith(
                              color: accent, fontWeight: FontWeight.w800)),
                    ]),
                    const SizedBox(height: 10),
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor: accent,
                        thumbColor: accent,
                        inactiveTrackColor: accent.withOpacity(0.2),
                        overlayColor: accent.withOpacity(0.15),
                      ),
                      child: Slider(
                        value: _progress,
                        min: 0,
                        max: 100,
                        divisions: 20,
                        onChanged: (v) => setState(() => _progress = v),
                      ),
                    ),
                  ],
                ),
              ),
              AppSpacing.gapMd,

              NeuInput(
                controller: _locationCtrl,
                label: 'الموقع / المنطقة',
                hint: 'مدينة، عنوان',
                prefixIcon: Icons.location_on_rounded,
              ),
              AppSpacing.gapMd,

              NeuInput(
                controller: _tagsCtrl,
                label: 'العلامات (tags)',
                hint: 'بناء، تصميم، تطوير...',
                prefixIcon: Icons.label_rounded,
              ),
              AppSpacing.gapXxl,

              NeuButton(
                label: widget.projectId != null ? 'حفظ التعديلات' : 'إنشاء المشروع',
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

class _DateField extends StatelessWidget {
  const _DateField({
    required this.label, required this.onTap,
    required this.isDark, this.value,
  });
  final String label;
  final String? value;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelSmall.copyWith(color: NeuColors.textHint)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: isDark ? NeuColors.dividerDark : NeuColors.divider),
            ),
            child: Row(children: [
              Icon(Icons.calendar_today_rounded,
                  size: 16, color: isDark ? NeuColors.goldAccent : NeuColors.navyMid),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  value ?? '— اختر تاريخاً —',
                  style: AppTypography.bodySmall.copyWith(
                    color: value != null ? textPrimary : NeuColors.textHint,
                  ),
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }
}
