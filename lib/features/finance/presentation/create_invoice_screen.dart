import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/app_currencies.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../../../shared/widgets/neu_input.dart';
import '../domain/finance_repository.dart';

/// Invoice Item model (line item).
class InvoiceItem {
  InvoiceItem({
    required this.id,
    this.description = '',
    this.quantity = 1,
    this.unitPrice = 0,
    this.discount = 0,
  });
  final String id;
  String description;
  double quantity;
  double unitPrice;
  double discount;

  double get total => (quantity * unitPrice) * (1 - discount / 100);
}

/// Create Invoice Screen — full invoice builder with line items.
class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({super.key, this.invoiceId});
  final int? invoiceId;

  @override
  ConsumerState<CreateInvoiceScreen> createState() =>
      _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  final _formKey = GlobalKey<FormState>();
  final _invoiceNumberCtrl = TextEditingController();
  final _clientNameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  final _footerCtrl = TextEditingController();

  String _currency = AppCurrencies.sar;
  String _issueDate = DateTime.now().toIso8601String().split('T').first;
  String? _dueDate;
  double _taxPercent = 0;
  double _discountAmount = 0;
  int? _clientId;
  int? _projectId;
  String? _projectName;
  bool _isSubmitting = false;

  final List<InvoiceItem> _items = [
    InvoiceItem(id: const Uuid().v4()),
  ];

  // ── Computed totals ──────────────────────────────────────────────
  double get _subtotal => _items.fold(0, (s, item) => s + item.total);
  double get _taxAmount => _subtotal * _taxPercent / 100;
  double get _total => _subtotal - _discountAmount + _taxAmount;

  @override
  void dispose() {
    _invoiceNumberCtrl.dispose();
    _clientNameCtrl.dispose();
    _notesCtrl.dispose();
    _footerCtrl.dispose();
    super.dispose();
  }

  void _addItem() {
    setState(() => _items.add(InvoiceItem(id: const Uuid().v4())));
  }

  void _removeItem(String id) {
    if (_items.length > 1) {
      setState(() => _items.removeWhere((i) => i.id == id));
    }
  }

  Future<void> _pickDate({required bool isIssue}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      locale: const Locale('ar'),
    );
    if (picked != null) {
      final str = picked.toIso8601String().split('T').first;
      setState(() {
        if (isIssue) {
          _issueDate = str;
        } else {
          _dueDate = str;
        }
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_items.every((i) => i.description.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('أضف بنداً واحداً على الأقل')),
      );
      return;
    }
    setState(() => _isSubmitting = true);

    try {
      final repo = ref.read(financeRepositoryProvider);
      final itemsJson = jsonEncode(_items.map((i) => {
        'description': i.description,
        'quantity': i.quantity,
        'unitPrice': i.unitPrice,
        'discount': i.discount,
        'total': i.total,
      }).toList());

      await repo.createInvoice(
        invoiceNumber: _invoiceNumberCtrl.text.trim().isEmpty
            ? 'INV-${DateTime.now().millisecondsSinceEpoch}'
            : _invoiceNumberCtrl.text.trim(),
        clientId: _clientId,
        clientName: _clientNameCtrl.text.trim().isEmpty ? null : _clientNameCtrl.text.trim(),
        projectId: _projectId,
        projectName: _projectName,
        issueDate: _issueDate,
        dueDate: _dueDate,
        itemsJson: itemsJson,
        subtotal: _subtotal,
        discountAmount: _discountAmount,
        taxPercent: _taxPercent,
        taxAmount: _taxAmount,
        total: _total,
        currency: _currency,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        footer: _footerCtrl.text.trim().isEmpty ? null : _footerCtrl.text.trim(),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء الفاتورة بنجاح ✓')),
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
        title: Text('فاتورة جديدة',
            style: AppTypography.headingSmall.copyWith(
                color: textPrimary, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: Text('حفظ',
                style: AppTypography.labelMedium.copyWith(
                    color: NeuColors.success, fontWeight: FontWeight.w700)),
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
              // ── Invoice Info ─────────────────────────────────────
              _SectionTitle(title: 'بيانات الفاتورة', icon: Icons.receipt_rounded),
              AppSpacing.gapMd,

              Row(
                children: [
                  Expanded(
                    child: NeuInput(
                      controller: _invoiceNumberCtrl,
                      label: 'رقم الفاتورة',
                      hint: 'INV-001',
                      prefixIcon: Icons.tag_rounded,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _CurrencyPicker(
                      value: _currency,
                      onChanged: (v) => setState(() => _currency = v),
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              AppSpacing.gapMd,

              NeuInput(
                controller: _clientNameCtrl,
                label: 'اسم العميل',
                hint: 'اسم الشركة أو الشخص',
                prefixIcon: Icons.supervisor_account_rounded,
              ),
              AppSpacing.gapMd,

              // Dates
              Row(
                children: [
                  Expanded(
                    child: _DatePicker(
                      label: 'تاريخ الإصدار',
                      value: _issueDate,
                      onTap: () => _pickDate(isIssue: true),
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _DatePicker(
                      label: 'تاريخ الاستحقاق',
                      value: _dueDate ?? '— اختياري —',
                      onTap: () => _pickDate(isIssue: false),
                      isDark: isDark,
                      optional: true,
                    ),
                  ),
                ],
              ),
              AppSpacing.gapXl,

              // ── Line Items ───────────────────────────────────────
              _SectionTitle(title: 'البنود والخدمات', icon: Icons.list_rounded),
              AppSpacing.gapMd,

              ..._items.asMap().entries.map((entry) => _InvoiceItemRow(
                    item: entry.value,
                    index: entry.key,
                    isDark: isDark,
                    canRemove: _items.length > 1,
                    onRemove: () => _removeItem(entry.value.id),
                    onChanged: () => setState(() {}),
                  )),

              // Add Item button
              GestureDetector(
                onTap: _addItem,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: NeuColors.success.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: NeuColors.success.withValues(alpha: 0.3),
                      style: BorderStyle.solid,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_rounded, color: NeuColors.success, size: 20),
                      const SizedBox(width: 8),
                      Text('إضافة بند',
                          style: AppTypography.labelMedium.copyWith(
                              color: NeuColors.success, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
              AppSpacing.gapXl,

              // ── Totals ───────────────────────────────────────────
              _SectionTitle(title: 'الإجماليات', icon: Icons.calculate_rounded),
              AppSpacing.gapMd,

              NeuCard(
                isDark: isDark,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _TotalRow(label: 'المجموع الفرعي',
                        value: AppCurrencies.formatAmount(_subtotal, _currency),
                        isDark: isDark),
                    const Divider(height: 20),

                    // Discount
                    Row(
                      children: [
                        Expanded(
                          child: Text('الخصم',
                              style: AppTypography.bodySmall.copyWith(
                                  color: NeuColors.textSecondary)),
                        ),
                        SizedBox(
                          width: 100,
                          child: TextField(
                            onChanged: (v) => setState(
                                () => _discountAmount = double.tryParse(v) ?? 0),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.end,
                            decoration: InputDecoration(
                              hintText: '0',
                              isDense: true,
                              border: InputBorder.none,
                              hintStyle: AppTypography.bodySmall
                                  .copyWith(color: NeuColors.textHint),
                            ),
                            style: AppTypography.bodySmall.copyWith(
                                color: NeuColors.danger, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),

                    // Tax
                    Row(
                      children: [
                        Expanded(
                          child: Text('الضريبة %',
                              style: AppTypography.bodySmall.copyWith(
                                  color: NeuColors.textSecondary)),
                        ),
                        SizedBox(
                          width: 60,
                          child: TextField(
                            onChanged: (v) => setState(
                                () => _taxPercent = double.tryParse(v) ?? 0),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            textAlign: TextAlign.end,
                            decoration: const InputDecoration(
                              hintText: '0',
                              isDense: true,
                              border: InputBorder.none,
                            ),
                            style: AppTypography.bodySmall.copyWith(
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                        Text(' %', style: AppTypography.bodySmall),
                      ],
                    ),
                    const Divider(height: 16),

                    // Total
                    _TotalRow(
                      label: 'الإجمالي',
                      value: AppCurrencies.formatAmount(_total, _currency),
                      isDark: isDark,
                      isTotal: true,
                    ),
                  ],
                ),
              ),
              AppSpacing.gapXl,

              // ── Notes & Footer ────────────────────────────────────
              NeuInput(
                controller: _notesCtrl,
                label: 'ملاحظات',
                hint: 'ملاحظات داخلية',
                maxLines: 2,
                prefixIcon: Icons.notes_rounded,
              ),
              AppSpacing.gapMd,
              NeuInput(
                controller: _footerCtrl,
                label: 'نص التذييل',
                hint: 'شروط الدفع / شكر للعميل',
                maxLines: 2,
                prefixIcon: Icons.text_snippet_rounded,
              ),
              AppSpacing.gapXxl,

              NeuButton(
                label: 'إنشاء الفاتورة',
                onPressed: _isSubmitting ? null : _submit,
                isLoading: _isSubmitting,
                icon: Icons.receipt_long_rounded,
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: NeuColors.navyDeep, size: 18),
        const SizedBox(width: 8),
        Text(title,
            style: AppTypography.labelMedium.copyWith(
                color: NeuColors.navyDeep, fontWeight: FontWeight.w700)),
        const SizedBox(width: 12),
        Expanded(
          child: Divider(color: NeuColors.navyDeep.withValues(alpha: 0.2), thickness: 1),
        ),
      ],
    );
  }
}

class _DatePicker extends StatelessWidget {
  const _DatePicker({
    required this.label,
    required this.value,
    required this.onTap,
    required this.isDark,
    this.optional = false,
  });
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isDark;
  final bool optional;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTypography.labelSmall.copyWith(color: NeuColors.textHint)),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: isDark ? NeuColors.dividerDark : NeuColors.divider),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_rounded,
                    size: 16,
                    color: isDark ? NeuColors.goldAccent : NeuColors.navyMid),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(value,
                      style: AppTypography.bodySmall.copyWith(
                          color: optional && value.contains('—')
                              ? NeuColors.textHint
                              : NeuColors.textPrimaryFor(
                                  Theme.of(context).brightness))),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencyPicker extends StatelessWidget {
  const _CurrencyPicker({
    required this.value,
    required this.onChanged,
    required this.isDark,
  });
  final String value;
  final ValueChanged<String> onChanged;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('العملة',
            style: AppTypography.labelSmall.copyWith(color: NeuColors.textHint)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: isDark ? NeuColors.dividerDark : NeuColors.divider),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              dropdownColor: isDark ? NeuColors.surfaceDark : NeuColors.bgColor,
              style: AppTypography.bodySmall.copyWith(color: textPrimary),
              onChanged: (v) => onChanged(v!),
              items: AppCurrencies.all.map((c) => DropdownMenuItem(
                value: c.code,
                child: Text('${c.flag} ${c.code}',
                    style: AppTypography.bodySmall.copyWith(color: textPrimary)),
              )).toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class _InvoiceItemRow extends StatelessWidget {
  const _InvoiceItemRow({
    required this.item,
    required this.index,
    required this.isDark,
    required this.canRemove,
    required this.onRemove,
    required this.onChanged,
  });
  final InvoiceItem item;
  final int index;
  final bool isDark;
  final bool canRemove;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);

    return NeuCard(
      isDark: isDark,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('بند ${index + 1}',
                  style: AppTypography.labelSmall.copyWith(
                      color: NeuColors.navyDeep, fontWeight: FontWeight.w700)),
              const Spacer(),
              if (canRemove)
                GestureDetector(
                  onTap: onRemove,
                  child: Icon(Icons.delete_outline_rounded,
                      color: NeuColors.danger, size: 20),
                ),
            ],
          ),
          const SizedBox(height: 8),
          TextField(
            onChanged: (v) { item.description = v; onChanged(); },
            decoration: InputDecoration(
              hintText: 'وصف البند / الخدمة',
              hintStyle: AppTypography.bodySmall.copyWith(color: NeuColors.textHint),
              isDense: true,
              border: InputBorder.none,
            ),
            style: AppTypography.bodySmall.copyWith(color: textPrimary),
          ),
          const Divider(height: 12),
          Row(
            children: [
              _ItemField(label: 'الكمية', hint: '1',
                  onChanged: (v) { item.quantity = double.tryParse(v) ?? 1; onChanged(); }),
              const SizedBox(width: 8),
              _ItemField(label: 'السعر', hint: '0.00',
                  onChanged: (v) { item.unitPrice = double.tryParse(v) ?? 0; onChanged(); }),
              const SizedBox(width: 8),
              _ItemField(label: 'خصم %', hint: '0',
                  onChanged: (v) { item.discount = double.tryParse(v) ?? 0; onChanged(); }),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('الإجمالي', style: AppTypography.labelSmall
                        .copyWith(color: NeuColors.textHint)),
                    Text(item.total.toStringAsFixed(2),
                        style: AppTypography.bodySmall.copyWith(
                            color: NeuColors.navyDeep, fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ItemField extends StatelessWidget {
  const _ItemField({required this.label, required this.hint, required this.onChanged});
  final String label;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.labelSmall.copyWith(color: NeuColors.textHint)),
          TextField(
            onChanged: onChanged,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              hintText: hint,
              isDense: true,
              border: InputBorder.none,
              hintStyle: AppTypography.bodySmall.copyWith(color: NeuColors.textHint),
            ),
            style: AppTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({required this.label, required this.value,
      required this.isDark, this.isTotal = false});
  final String label;
  final String value;
  final bool isDark;
  final bool isTotal;

  @override
  Widget build(BuildContext context) {
    final textPrimary = NeuColors.textPrimaryFor(Theme.of(context).brightness);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: (isTotal ? AppTypography.bodyMedium : AppTypography.bodySmall)
                .copyWith(
                    color: isTotal ? textPrimary : NeuColors.textSecondary,
                    fontWeight: isTotal ? FontWeight.w800 : FontWeight.normal)),
        Text(value,
            style: (isTotal ? AppTypography.bodyMedium : AppTypography.bodySmall)
                .copyWith(
                    color: isTotal ? NeuColors.navyDeep : textPrimary,
                    fontWeight: isTotal ? FontWeight.w800 : FontWeight.w600)),
      ],
    );
  }
}