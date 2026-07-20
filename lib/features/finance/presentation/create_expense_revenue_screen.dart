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

/// Shared screen for creating Expenses and Revenues.
/// [isExpense] = true → Expense, false → Revenue
class CreateExpenseRevenueScreen extends ConsumerStatefulWidget {
  const CreateExpenseRevenueScreen({super.key, required this.isExpense});
  final bool isExpense;

  @override
  ConsumerState<CreateExpenseRevenueScreen> createState() =>
      _CreateExpenseRevenueScreenState();
}

class _CreateExpenseRevenueScreenState
    extends ConsumerState<CreateExpenseRevenueScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  final _categoryCtrl = TextEditingController();
  final _partyCtrl = TextEditingController();
  final _refCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  String _currency = AppCurrencies.sar;
  String _date = DateTime.now().toIso8601String().split('T').first;
  int _paymentMethod = 0;
  bool _isSubmitting = false;

  // Expense categories
  static const _expenseCategories = [
    'رواتب', 'إيجار', 'مرافق', 'مواصلات', 'قرطاسية', 'صيانة',
    'تسويق', 'تدريب', 'ضرائب', 'بيمة', 'أخرى'
  ];
  // Revenue categories
  static const _revenueCategories = [
    'مبيعات', 'خدمات', 'مشاريع', 'استشارات', 'عمولات',
    'إيجار', 'فوائد', 'مكافآت', 'أخرى'
  ];

  List<String> get _categories =>
      widget.isExpense ? _expenseCategories : _revenueCategories;

  String? _selectedCategory;

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose(); _amountCtrl.dispose();
    _categoryCtrl.dispose(); _partyCtrl.dispose(); _refCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      setState(() => _date = picked.toIso8601String().split('T').first);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);
    try {
      final repo = ref.read(financeRepositoryProvider);
      final amount = double.tryParse(_amountCtrl.text.trim()) ?? 0;

      if (widget.isExpense) {
        await repo.createExpense(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          amount: amount,
          currency: _currency,
          category: _selectedCategory,
          date: _date,
          paymentMethod: _paymentMethod,
          referenceNumber: _refCtrl.text.trim().isEmpty ? null : _refCtrl.text.trim(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
      } else {
        await repo.createRevenue(
          title: _titleCtrl.text.trim(),
          description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
          amount: amount,
          currency: _currency,
          category: _selectedCategory,
          date: _date,
          paymentMethod: _paymentMethod,
          referenceNumber: _refCtrl.text.trim().isEmpty ? null : _refCtrl.text.trim(),
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.isExpense
                ? 'تم تسجيل المصروف بنجاح ✓'
                : 'تم تسجيل الإيراد بنجاح ✓'),
          ),
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
    final accentColor =
        widget.isExpense ? NeuColors.danger : NeuColors.success;

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
          widget.isExpense ? 'تسجيل مصروف' : 'تسجيل إيراد',
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
              // Amount Card (prominent)
              NeuCard(
                isDark: isDark,
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          widget.isExpense
                              ? Icons.money_off_rounded
                              : Icons.attach_money_rounded,
                          color: accentColor,
                          size: 28,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          widget.isExpense ? 'المبلغ المصروف' : 'المبلغ المُحصَّل',
                          style: AppTypography.bodyMedium.copyWith(
                              color: accentColor, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: NeuInput(
                            controller: _amountCtrl,
                            label: 'المبلغ *',
                            hint: '0.00',
                            prefixIcon: widget.isExpense
                                ? Icons.remove_circle_outline_rounded
                                : Icons.add_circle_outline_rounded,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (v) => (v == null || v.trim().isEmpty)
                                ? 'المبلغ مطلوب'
                                : (double.tryParse(v) == null ? 'رقم غير صحيح' : null),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Currency selector
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('العملة',
                                  style: AppTypography.labelSmall
                                      .copyWith(color: NeuColors.textHint)),
                              const SizedBox(height: 6),
                              Container(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? NeuColors.surfaceDark
                                      : NeuColors.surface,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: isDark
                                          ? NeuColors.dividerDark
                                          : NeuColors.divider),
                                ),
                                child: DropdownButtonHideUnderline(
                                  child: DropdownButton<String>(
                                    value: _currency,
                                    isExpanded: true,
                                    dropdownColor: isDark
                                        ? NeuColors.surfaceDark
                                        : NeuColors.bgColor,
                                    onChanged: (v) =>
                                        setState(() => _currency = v!),
                                    items: AppCurrencies.all
                                        .map((c) => DropdownMenuItem(
                                              value: c.code,
                                              child: Text('${c.flag} ${c.code}',
                                                  style: AppTypography.bodySmall
                                                      .copyWith(color: textPrimary)),
                                            ))
                                        .toList(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              AppSpacing.gapMd,

              NeuInput(
                controller: _titleCtrl,
                label: 'العنوان *',
                hint: widget.isExpense
                    ? 'مثال: فاتورة كهرباء يوليو'
                    : 'مثال: دفعة عميل ABC',
                prefixIcon: Icons.title_rounded,
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'العنوان مطلوب' : null,
              ),
              AppSpacing.gapMd,

              NeuInput(
                controller: _descCtrl,
                label: 'الوصف',
                hint: 'تفاصيل إضافية',
                prefixIcon: Icons.description_rounded,
                maxLines: 2,
              ),
              AppSpacing.gapMd,

              // Category
              Text('التصنيف',
                  style: AppTypography.labelSmall
                      .copyWith(color: NeuColors.textHint)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _categories.map((cat) {
                  final selected = _selectedCategory == cat;
                  return GestureDetector(
                    onTap: () =>
                        setState(() => _selectedCategory = selected ? null : cat),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: selected
                            ? accentColor
                            : (isDark ? NeuColors.surfaceDark : NeuColors.surface),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              selected ? accentColor : accentColor.withOpacity(0.3),
                        ),
                      ),
                      child: Text(cat,
                          style: AppTypography.bodySmall.copyWith(
                            color: selected ? Colors.white : accentColor,
                            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          )),
                    ),
                  );
                }).toList(),
              ),
              AppSpacing.gapMd,

              // Date
              GestureDetector(
                onTap: _pickDate,
                child: NeuCard(
                  isDark: isDark,
                  margin: EdgeInsets.zero,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  child: Row(children: [
                    Icon(Icons.calendar_today_rounded,
                        color: isDark ? NeuColors.goldAccent : NeuColors.navyMid,
                        size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(_date,
                          style: AppTypography.bodyMedium.copyWith(
                              color: textPrimary)),
                    ),
                    Icon(Icons.chevron_left_rounded,
                        color: NeuColors.textHint, size: 18),
                  ]),
                ),
              ),
              AppSpacing.gapMd,

              // Payment Method
              Text('طريقة الدفع',
                  style: AppTypography.labelSmall
                      .copyWith(color: NeuColors.textHint)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _PayMethodChip(
                      label: 'نقداً', icon: Icons.money_rounded,
                      selected: _paymentMethod == 0,
                      onTap: () => setState(() => _paymentMethod = 0), isDark: isDark),
                  _PayMethodChip(
                      label: 'تحويل', icon: Icons.account_balance_rounded,
                      selected: _paymentMethod == 1,
                      onTap: () => setState(() => _paymentMethod = 1), isDark: isDark),
                  _PayMethodChip(
                      label: 'بطاقة', icon: Icons.credit_card_rounded,
                      selected: _paymentMethod == 2,
                      onTap: () => setState(() => _paymentMethod = 2), isDark: isDark),
                  _PayMethodChip(
                      label: 'شيك', icon: Icons.receipt_rounded,
                      selected: _paymentMethod == 3,
                      onTap: () => setState(() => _paymentMethod = 3), isDark: isDark),
                ],
              ),
              AppSpacing.gapMd,

              NeuInput(
                controller: _partyCtrl,
                label: widget.isExpense ? 'المورّد / الجهة' : 'العميل / الجهة',
                hint: widget.isExpense ? 'اسم المورد' : 'اسم العميل',
                prefixIcon: Icons.supervisor_account_rounded,
              ),
              AppSpacing.gapMd,

              NeuInput(
                controller: _refCtrl,
                label: 'رقم المرجع',
                hint: 'رقم الإيصال / الفاتورة',
                prefixIcon: Icons.tag_rounded,
              ),
              AppSpacing.gapMd,

              NeuInput(
                controller: _notesCtrl,
                label: 'ملاحظات',
                hint: 'أي ملاحظات إضافية',
                prefixIcon: Icons.notes_rounded,
                maxLines: 2,
              ),
              AppSpacing.gapXxl,

              NeuButton(
                label: widget.isExpense ? 'حفظ المصروف' : 'حفظ الإيراد',
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

class _PayMethodChip extends StatelessWidget {
  const _PayMethodChip({
    required this.label, required this.icon, required this.selected,
    required this.onTap, required this.isDark,
  });
  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final bool isDark;

  @override
  Widget build(BuildContext context) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsetsDirectional.only(end: 6),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected
              ? NeuColors.navyDeep
              : (isDark ? NeuColors.surfaceDark : NeuColors.surface),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(children: [
          Icon(icon, color: selected ? Colors.white : NeuColors.textHint, size: 18),
          const SizedBox(height: 4),
          Text(label, style: AppTypography.labelSmall.copyWith(
              color: selected ? Colors.white : NeuColors.textHint,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500)),
        ]),
      ),
    ),
  );
}
