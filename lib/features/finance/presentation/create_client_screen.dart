import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_input.dart';
import '../domain/finance_repository.dart';

/// Create Client Screen.
class CreateClientScreen extends ConsumerStatefulWidget {
  const CreateClientScreen({super.key, this.clientId});
  final int? clientId;

  @override
  ConsumerState<CreateClientScreen> createState() => _CreateClientScreenState();
}

class _CreateClientScreenState extends ConsumerState<CreateClientScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _cityCtrl = TextEditingController();
  final _taxNumberCtrl = TextEditingController();
  final _contactCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  int _type = 1; // 0=individual, 1=company, 2=government, 3=ngo
  bool _isSubmitting = false;

  static const _types = [
    (0, 'فرد', Icons.person_rounded),
    (1, 'شركة', Icons.business_rounded),
    (2, 'حكومي', Icons.account_balance_rounded),
    (3, 'منظمة', Icons.volunteer_activism_rounded),
  ];

  @override
  void dispose() {
    _nameCtrl.dispose(); _phoneCtrl.dispose(); _emailCtrl.dispose();
    _addressCtrl.dispose(); _cityCtrl.dispose(); _taxNumberCtrl.dispose();
    _contactCtrl.dispose(); _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      await ref.read(financeRepositoryProvider).createClient(
        name: _nameCtrl.text.trim(),
        type: _type,
        phone: _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        email: _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        address: _addressCtrl.text.trim().isEmpty ? null : _addressCtrl.text.trim(),
        city: _cityCtrl.text.trim().isEmpty ? null : _cityCtrl.text.trim(),
        taxNumber: _taxNumberCtrl.text.trim().isEmpty ? null : _taxNumberCtrl.text.trim(),
        contactPersonName: _contactCtrl.text.trim().isEmpty ? null : _contactCtrl.text.trim(),
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إضافة العميل بنجاح ✓')),
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
          widget.clientId != null ? 'تعديل العميل' : 'عميل جديد',
          style: AppTypography.headingSmall.copyWith(
              color: textPrimary, fontWeight: FontWeight.w700),
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
              // ── Type selector ─────────────────────────────────────
              Text('نوع العميل',
                  style: AppTypography.labelMedium.copyWith(color: NeuColors.navyDeep)),
              AppSpacing.gapSm,
              Row(
                children: _types.map((t) {
                  final selected = _type == t.$1;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _type = t.$1),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsetsDirectional.only(end: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: selected
                              ? const Color(0xFF00B894)
                              : (isDark ? NeuColors.surfaceDark : NeuColors.surface),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: selected
                                ? const Color(0xFF00B894)
                                : Colors.transparent,
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(t.$3,
                                color: selected ? Colors.white : NeuColors.textHint,
                                size: 18),
                            const SizedBox(height: 4),
                            Text(t.$2,
                                style: AppTypography.labelSmall.copyWith(
                                  color: selected ? Colors.white : NeuColors.textHint,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                )),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              AppSpacing.gapLg,

              NeuInput(
                controller: _nameCtrl,
                label: 'الاسم / اسم الشركة *',
                hint: 'الاسم الكامل',
                prefixIcon: Icons.business_rounded,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'مطلوب' : null,
              ),
              AppSpacing.gapMd,

              Row(children: [
                Expanded(
                  child: NeuInput(
                    controller: _phoneCtrl,
                    label: 'رقم الجوال',
                    hint: '+967 xxx xxx',
                    prefixIcon: Icons.phone_rounded,
                    keyboardType: TextInputType.phone,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: NeuInput(
                    controller: _cityCtrl,
                    label: 'المدينة',
                    hint: 'صنعاء، الرياض...',
                    prefixIcon: Icons.location_city_rounded,
                  ),
                ),
              ]),
              AppSpacing.gapMd,

              NeuInput(
                controller: _emailCtrl,
                label: 'البريد الإلكتروني',
                hint: 'example@email.com',
                prefixIcon: Icons.email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              AppSpacing.gapMd,

              NeuInput(
                controller: _addressCtrl,
                label: 'العنوان',
                hint: 'العنوان التفصيلي',
                prefixIcon: Icons.location_on_rounded,
                maxLines: 2,
              ),
              AppSpacing.gapMd,

              NeuInput(
                controller: _taxNumberCtrl,
                label: 'الرقم الضريبي',
                hint: 'رقم التسجيل الضريبي',
                prefixIcon: Icons.receipt_rounded,
              ),
              AppSpacing.gapMd,

              NeuInput(
                controller: _contactCtrl,
                label: 'شخص الاتصال',
                hint: 'اسم ممثل الشركة',
                prefixIcon: Icons.contact_phone_rounded,
              ),
              AppSpacing.gapMd,

              NeuInput(
                controller: _notesCtrl,
                label: 'ملاحظات',
                hint: 'أي ملاحظات إضافية',
                prefixIcon: Icons.notes_rounded,
                maxLines: 3,
              ),
              AppSpacing.gapXxl,

              NeuButton(
                label: 'حفظ العميل',
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