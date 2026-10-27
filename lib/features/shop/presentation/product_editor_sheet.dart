import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/design/azm_tokens.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/theme/app_typography.dart';
import '../data/shop_models.dart';
import '../providers/shop_providers.dart';

/// AZM — محرّر المنتج
///
/// ورقة واحدة للإنشاء والتعديل: الحقول نفسها، والفارق أن التعديل
/// يُرسل **ما تغيّر فقط**.
///
/// ## لماذا التعديل تفاضلي
///
/// `PATCH` بكل الحقول يكتب فوق ما لم يلمسه المستخدم. ولو حرّر تاجران
/// المنتج نفسه — أو حرّره التاجر من هاتفه وموظفه من حاسبه — لمحا كلٌّ
/// تعديل الآخر بقيم لم يقصد إرسالها. إرسال المتغيّر وحده يجعل
/// التعديلين يتعايشان ما لم يلمسا الحقل نفسه.
///
/// والسعر عدد صحيح بأصغر وحدة للعملة لا كسر عائم: الكسر العائم يجعل
/// ٠٫١ + ٠٫٢ لا يساوي ٠٫٣، وهو خطأ لا يُقبل في مبلغ.
class ProductEditorSheet extends ConsumerStatefulWidget {
  const ProductEditorSheet({
    super.key,
    required this.storeId,
    required this.store,
    this.product,
  });

  final String storeId;
  final ShopStore store;

  /// `null` = منتج جديد.
  final ShopProduct? product;

  @override
  ConsumerState<ProductEditorSheet> createState() =>
      _ProductEditorSheetState();
}

class _ProductEditorSheetState extends ConsumerState<ProductEditorSheet> {
  late final TextEditingController _name;
  late final TextEditingController _summary;
  late final TextEditingController _price;
  late final TextEditingController _oldPrice;
  late final TextEditingController _qty;
  late final TextEditingController _lowStock;
  late final TextEditingController _brand;

  late bool _live;
  String? _categoryId;

  bool _saving = false;
  String? _error;

  bool get _isNew => widget.product == null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name ?? '');
    _summary = TextEditingController(text: p?.summary ?? '');
    _price = TextEditingController(text: p == null ? '' : '${p.price}');
    _oldPrice =
        TextEditingController(text: p?.oldPrice == null ? '' : '${p!.oldPrice}');
    _qty = TextEditingController(text: p == null ? '0' : '${p.qty}');
    _lowStock = TextEditingController(text: p == null ? '0' : '${p.lowStock}');
    _brand = TextEditingController(text: p?.brand ?? '');
    _live = p?.live ?? true;
    _categoryId = p?.categoryId;
  }

  @override
  void dispose() {
    _name.dispose();
    _summary.dispose();
    _price.dispose();
    _oldPrice.dispose();
    _qty.dispose();
    _lowStock.dispose();
    _brand.dispose();
    super.dispose();
  }

  bool get _canSave =>
      !_saving &&
      _name.text.trim().isNotEmpty &&
      int.tryParse(_price.text.trim()) != null;

  /// الحمولة: كل الحقول للإنشاء، والمتغيّر وحده للتعديل.
  Map<String, Object?> _payload() {
    final name = _name.text.trim();
    final summary = _summary.text.trim();
    final brand = _brand.text.trim();
    final price = int.tryParse(_price.text.trim()) ?? 0;
    final oldPrice = int.tryParse(_oldPrice.text.trim());
    final qty = int.tryParse(_qty.text.trim()) ?? 0;
    final lowStock = int.tryParse(_lowStock.text.trim()) ?? 0;

    if (_isNew) {
      return {
        'name': name,
        'price': price,
        'qty': qty,
        'lowStock': lowStock,
        'live': _live,
        if (summary.isNotEmpty) 'summary': summary,
        if (brand.isNotEmpty) 'brand': brand,
        'oldPrice': ?oldPrice,
        'categoryId': ?_categoryId,
      };
    }

    final before = widget.product!;
    return {
      if (name != before.name) 'name': name,
      if (summary != before.summary) 'summary': summary,
      if (brand != before.brand) 'brand': brand,
      if (price != before.price) 'price': price,
      if (oldPrice != before.oldPrice) 'oldPrice': oldPrice,
      if (qty != before.qty) 'qty': qty,
      if (lowStock != before.lowStock) 'lowStock': lowStock,
      if (_live != before.live) 'live': _live,
      if (_categoryId != before.categoryId) 'categoryId': _categoryId,
    };
  }

  Future<void> _save() async {
    final payload = _payload();

    // لا تغيير ⇒ لا طلب. طلب فارغ يكلّف رحلة شبكة ويُحدِّث `updatedAt`
    // فيبدو المنتج معدَّلًا ولم يُعدَّل.
    if (!_isNew && payload.isEmpty) {
      Navigator.of(context).pop();
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final actions = ref.read(shopActionsProvider);
      if (_isNew) {
        await actions.createProduct(widget.storeId, payload);
      } else {
        await actions.updateProduct(
          widget.storeId,
          widget.product!.id,
          payload,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.message;
      });
    }
  }

  Future<void> _confirmDelete() async {
    final p = AzmPalette.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: p.surfaceRaised,
        title: Text('حذف ${widget.product!.name}؟',
            style: AppTypography.h3.copyWith(color: p.ink)),
        content: Text(
          // الحذف لا يُسترجَع، والإخفاء بديل كافٍ في أغلب الحالات
          'الحذف نهائي. إن كان المنتج نافدًا فقط فالإخفاء أنسب — يعود '
          'بلمسة حين يتوفّر.',
          style: AppTypography.body.copyWith(color: p.inkMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: p.danger),
            child: const Text('حذف'),
          ),
        ],
      ),
    );

    if (ok != true || !mounted) return;

    setState(() => _saving = true);
    try {
      await ref
          .read(shopActionsProvider)
          .deleteProduct(widget.storeId, widget.product!.id);
      if (mounted) Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.message;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final categories = ref.watch(categoriesProvider(widget.storeId));

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.92,
        ),
        decoration: BoxDecoration(
          color: p.surfaceRaised,
          borderRadius: AzmRadius.sheet,
        ),
        padding: const EdgeInsets.fromLTRB(
          AzmSpace.screenGutter,
          AzmSpace.md,
          AzmSpace.screenGutter,
          AzmSpace.xl,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: p.rule,
                    borderRadius: AzmRadius.pill,
                  ),
                ),
              ),
              const SizedBox(height: AzmSpace.xl),

              Row(
                children: [
                  Expanded(
                    child: Text(
                      _isNew ? 'منتج جديد' : 'تعديل المنتج',
                      style: AppTypography.h2.copyWith(color: p.ink),
                    ),
                  ),
                  if (!_isNew)
                    IconButton(
                      onPressed: _saving ? null : _confirmDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                      color: p.danger,
                      tooltip: 'حذف',
                    ),
                ],
              ),
              const SizedBox(height: AzmSpace.lg),

              _Text(controller: _name, label: 'الاسم', hint: 'عود كمبودي'),
              const SizedBox(height: AzmSpace.lg),
              _Text(
                controller: _summary,
                label: 'وصف مختصر',
                hint: 'تولة واحدة · عبوة زجاجية',
              ),
              const SizedBox(height: AzmSpace.lg),

              Row(
                children: [
                  Expanded(
                    child: _Text(
                      controller: _price,
                      label: 'السعر (${widget.store.currency})',
                      numeric: true,
                      onChanged: () => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: AzmSpace.md),
                  Expanded(
                    child: _Text(
                      controller: _oldPrice,
                      label: 'قبل الخصم',
                      hint: 'اختياري',
                      numeric: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AzmSpace.lg),

              Row(
                children: [
                  Expanded(
                    child: _Text(
                      controller: _qty,
                      label: 'الكمية',
                      numeric: true,
                    ),
                  ),
                  const SizedBox(width: AzmSpace.md),
                  Expanded(
                    child: _Text(
                      controller: _lowStock,
                      label: 'تنبيه عند',
                      numeric: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AzmSpace.xs),
              Text(
                'التنبيه يظهر في النظرة العامة حين تهبط الكمية إلى هذا '
                'الحدّ. صفر يعني لا تنبيه.',
                style: AppTypography.caption.copyWith(color: p.inkFaint),
              ),
              const SizedBox(height: AzmSpace.lg),

              _Text(controller: _brand, label: 'العلامة', hint: 'اختياري'),
              const SizedBox(height: AzmSpace.lg),

              categories.maybeWhen(
                data: (list) => list.isEmpty
                    ? const SizedBox.shrink()
                    : _CategoryPicker(
                        categories: list,
                        value: _categoryId,
                        onChanged: (v) => setState(() => _categoryId = v),
                      ),
                orElse: () => const SizedBox.shrink(),
              ),

              const SizedBox(height: AzmSpace.lg),
              SwitchListTile(
                value: _live,
                onChanged: (v) => setState(() => _live = v),
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'معروض في المتجر',
                  style: AppTypography.body.copyWith(color: p.ink),
                ),
                subtitle: Text(
                  _live
                      ? 'يراه زوّار متجرك'
                      : 'محفوظ لكن لا يظهر للزوّار',
                  style: AppTypography.caption.copyWith(color: p.inkFaint),
                ),
              ),

              if (_error != null) ...[
                const SizedBox(height: AzmSpace.lg),
                Container(
                  padding: const EdgeInsets.all(AzmSpace.md),
                  decoration: BoxDecoration(
                    color: p.dangerSubtle,
                    borderRadius: AzmRadius.control,
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline_rounded,
                          size: 18, color: p.danger),
                      const SizedBox(width: AzmSpace.sm),
                      Expanded(
                        child: Text(
                          _error!,
                          style: AppTypography.caption
                              .copyWith(color: p.danger),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: AzmSpace.xl),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _canSave ? _save : null,
                  child: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(_isNew ? 'إضافة المنتج' : 'حفظ التعديل'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────
// أجزاء
// ─────────────────────────────────────────────

class _Text extends StatelessWidget {
  const _Text({
    required this.controller,
    required this.label,
    this.hint,
    this.numeric = false,
    this.onChanged,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final bool numeric;
  final VoidCallback? onChanged;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.caption.copyWith(
            color: p.inkFaint,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AzmSpace.xs),
        TextField(
          controller: controller,
          keyboardType: numeric ? TextInputType.number : TextInputType.text,
          // أرقام لاتينية فقط: الخادم يتوقّع عددًا صحيحًا، والأرقام
          // العربية-الهندية تفشل في `int.parse` فيُرسل صفر بصمت.
          inputFormatters:
              numeric ? [FilteringTextInputFormatter.digitsOnly] : null,
          onChanged: onChanged == null ? null : (_) => onChanged!(),
          style: AppTypography.body.copyWith(color: p.ink),
          decoration: InputDecoration(
            hintText: hint,
            isDense: true,
            filled: true,
            fillColor: p.surfaceSunken,
            border: OutlineInputBorder(
              borderRadius: AzmRadius.control,
              borderSide: BorderSide(color: p.hairline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: AzmRadius.control,
              borderSide: BorderSide(color: p.hairline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: AzmRadius.control,
              borderSide: BorderSide(color: p.accent),
            ),
          ),
        ),
      ],
    );
  }
}

class _CategoryPicker extends StatelessWidget {
  const _CategoryPicker({
    required this.categories,
    required this.value,
    required this.onChanged,
  });

  final List<ShopCategory> categories;
  final String? value;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'التصنيف',
          style: AppTypography.caption.copyWith(
            color: p.inkFaint,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AzmSpace.sm),
        Wrap(
          spacing: AzmSpace.sm,
          runSpacing: AzmSpace.sm,
          children: [
            _Pill(
              label: 'بلا تصنيف',
              selected: value == null,
              onTap: () => onChanged(null),
            ),
            ...categories.map(
              (c) => _Pill(
                label: c.name,
                selected: c.id == value,
                onTap: () => onChanged(c.id),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);

    return InkWell(
      onTap: onTap,
      borderRadius: AzmRadius.pill,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AzmSpace.md,
          vertical: AzmSpace.sm,
        ),
        decoration: BoxDecoration(
          color: selected ? p.accent : p.surfaceSunken,
          borderRadius: AzmRadius.pill,
          border: Border.all(color: selected ? p.accent : p.hairline),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: selected ? p.onAccent : p.inkMuted,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
