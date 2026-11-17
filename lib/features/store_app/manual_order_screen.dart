import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/azm_tokens.dart';
import '../../core/theme/app_typography.dart';
import '../shop/data/shop_models.dart';
import '../shop/providers/shop_providers.dart';
import 'kit.dart';
import 'store_api.dart';

class _Line {
  _Line(this.product, this.variant);
  final ShopProduct product;
  ProductVariant? variant;
  int qty = 1;
  int get price => variant?.price ?? product.price;
  int get stock => variant?.qty ?? product.qty;
}

/// طلب يدوي — لطلب وصل بالهاتف أو واتساب أو في المحل. يمرّ بمحرك طلب المتجر نفسه في الخادم:
/// الأسعار من القاعدة، والمخزون يُحجز، والقسيمة تُحسب هناك.
class ManualOrderScreen extends ConsumerStatefulWidget {
  const ManualOrderScreen({super.key, required this.store});
  final ShopStore store;

  @override
  ConsumerState<ManualOrderScreen> createState() => _ManualOrderScreenState();
}

class _ManualOrderScreenState extends ConsumerState<ManualOrderScreen> {
  final _lines = <_Line>[];
  final _name = TextEditingController();
  final _phone = TextEditingController();
  final _address = TextEditingController();
  final _note = TextEditingController();
  final _fee = TextEditingController();
  final _discount = TextEditingController();
  final _coupon = TextEditingController();
  final _points = TextEditingController();
  List<Map> _customers = const [];
  bool _paid = false;
  bool _confirm = true;
  bool _saving = false;

  int _n(TextEditingController c) => int.tryParse(c.text.trim()) ?? 0;

  @override
  void initState() {
    super.initState();
    ref.read(storeDataApiProvider).customers(widget.store.id).then((d) {
      if (mounted) setState(() => _customers = ((d['customers'] as List?) ?? const []).cast<Map>());
    }).catchError((_) {});
  }

  /// صاحب الجوال من عملاء المتجر — آخر ٩ أرقام تكفي للمطابقة
  Map? get _known {
    final d = _phone.text.replaceAll(RegExp(r'\D'), '');
    if (d.length < 7) return null;
    final tail = d.length > 9 ? d.substring(d.length - 9) : d;
    for (final c in _customers) {
      if ('${c['phone']}'.replaceAll(RegExp(r'\D'), '').endsWith(tail)) return c;
    }
    return null;
  }
  int get _subtotal => _lines.fold(0, (a, l) => a + l.price * l.qty);

  Future<void> _pick(List<ShopProduct> all) async {
    final picked = await showModalBottomSheet<ShopProduct>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheet) {
        var q = '';
        return StatefulBuilder(
          builder: (sheet, set) {
            final list = all.where((p) => q.isEmpty || p.name.contains(q) || p.brand.contains(q)).toList();
            return SizedBox(
              height: MediaQuery.of(sheet).size.height * .75,
              child: Column(children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    autofocus: true,
                    decoration: const InputDecoration(hintText: 'ابحث باسم المنتج', prefixIcon: Icon(Icons.search)),
                    onChanged: (v) => set(() => q = v.trim()),
                  ),
                ),
                Expanded(
                  child: ListView(children: [
                    for (final p in list)
                      ListTile(
                        leading: p.image.isEmpty
                            ? const CircleAvatar(child: Icon(Icons.inventory_2_outlined))
                            : CircleAvatar(backgroundImage: NetworkImage(p.image)),
                        title: Text(p.name),
                        subtitle: Text('${Rv.money(p.price)} ${widget.store.currency} · متوفر ${p.qty}${p.live ? '' : ' · مخفي'}'),
                        trailing: const Icon(Icons.add_circle_outline),
                        onTap: () => Navigator.pop(sheet, p),
                      ),
                  ]),
                ),
              ]),
            );
          },
        );
      },
    );
    if (picked == null) return;
    setState(() => _lines.add(_Line(picked, picked.hasVariants && picked.variants.isNotEmpty ? picked.variants.first : null)));
  }

  Future<void> _save() async {
    if (_lines.isEmpty) return _snack('أضف منتجًا واحدًا على الأقل');
    if (_name.text.trim().isEmpty && _phone.text.trim().isEmpty) return _snack('اكتب اسم العميل أو جواله');
    setState(() => _saving = true);
    try {
      final o = await ref.read(storeDataApiProvider).createManualOrder(widget.store.id, {
        'lines': [
          for (final l in _lines) {'id': l.product.id, if (l.variant != null) 'variantId': l.variant!.id, 'qty': l.qty},
        ],
        'name': _name.text.trim(),
        'phone': _phone.text.trim(),
        'address': _address.text.trim(),
        'note': _note.text.trim(),
        if (_fee.text.trim().isNotEmpty) 'deliveryFee': _n(_fee),
        if (_n(_discount) > 0) 'extraDiscount': _n(_discount),
        if (_coupon.text.trim().isNotEmpty) 'coupon': _coupon.text.trim(),
        if (_n(_points) > 0) 'pointsUsed': _n(_points),
        'paid': _paid,
        'confirm': _confirm,
      });
      ref.invalidate(orderPageProvider(widget.store.id));
      ref.invalidate(storeOverviewProvider(widget.store.id));
      ref.invalidate(productsProvider(widget.store.id));
      if (!mounted) return;
      _snack('سُجّل الطلب ${o['ref']} — الإجمالي ${Rv.money((o['total'] as num?) ?? 0)} ${widget.store.currency}');
      Navigator.pop(context);
    } catch (e) {
      if (mounted) _snack('$e');
      setState(() => _saving = false);
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final products = ref.watch(productsProvider(widget.store.id));
    final cur = widget.store.currency;
    final fee = _fee.text.trim().isEmpty ? null : _n(_fee);
    final balance = ((_known?['points'] as num?) ?? 0).toInt();
    final total = (_subtotal + (fee ?? 0) - _n(_discount) - _n(_points)).clamp(0, 1 << 31);
    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(title: const Text('طلب يدوي'), backgroundColor: p.ground, surfaceTintColor: Colors.transparent),
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 4, 16, 120), children: [
        Text('لطلب وصلك بالهاتف أو واتساب أو في المحل — يحجز المخزون ويظهر مع طلبات المتجر.',
            style: AppTypography.bodySmall.copyWith(color: p.inkMuted)),
        const RvSection('المنتجات'),
        for (final l in _lines)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RvCard(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(l.product.name, style: AppTypography.body.copyWith(color: p.ink, fontWeight: FontWeight.w700))),
                  IconButton(icon: Icon(Icons.delete_outline, color: p.danger), onPressed: () => setState(() => _lines.remove(l))),
                ]),
                if (l.product.hasVariants && l.product.variants.isNotEmpty)
                  DropdownButton<ProductVariant>(
                    value: l.variant,
                    isExpanded: true,
                    items: [
                      for (final v in l.product.variants) DropdownMenuItem(value: v, child: Text('${v.label} (${v.qty})')),
                    ],
                    onChanged: (v) => setState(() => l.variant = v),
                  ),
                Row(children: [
                  Text('${Rv.money(l.price)} $cur · متوفر ${l.stock}', style: AppTypography.caption.copyWith(color: p.inkFaint)),
                  const Spacer(),
                  IconButton(icon: const Icon(Icons.remove_circle_outline), onPressed: () => setState(() => l.qty = (l.qty - 1).clamp(1, 99))),
                  Text('${l.qty}', style: AppTypography.body.copyWith(color: p.ink, fontWeight: FontWeight.w700)),
                  IconButton(icon: const Icon(Icons.add_circle_outline), onPressed: () => setState(() => l.qty = (l.qty + 1).clamp(1, 99))),
                ]),
              ]),
            ),
          ),
        OutlinedButton.icon(
          onPressed: products.hasValue ? () => _pick(products.value!.products) : null,
          icon: const Icon(Icons.add_rounded),
          label: Text(products.isLoading ? 'تحميل المنتجات…' : 'أضف منتجًا'),
        ),
        const RvSection('العميل'),
        TextField(controller: _name, decoration: const InputDecoration(labelText: 'الاسم')),
        const SizedBox(height: 10),
        TextField(controller: _phone, onChanged: (_) => setState(() {}), keyboardType: TextInputType.phone, textDirection: TextDirection.ltr, decoration: const InputDecoration(labelText: 'الجوال')),
        const SizedBox(height: 10),
        TextField(controller: _address, decoration: const InputDecoration(labelText: 'العنوان')),
        const SizedBox(height: 10),
        TextField(controller: _note, decoration: const InputDecoration(labelText: 'ملاحظة')),
        const RvSection('الدفع والتوصيل'),
        Row(children: [
          Expanded(
            child: TextField(
              controller: _fee,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: 'رسم التوصيل ($cur)', hintText: 'تلقائي'),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: _discount,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(labelText: 'خصم يدوي ($cur)'),
            ),
          ),
        ]),
        const SizedBox(height: 10),
        TextField(
          controller: _coupon,
          textDirection: TextDirection.ltr,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(labelText: 'رمز خصم (اختياري)'),
        ),
        if (balance > 0) ...[
          const SizedBox(height: 10),
          TextField(
            controller: _points,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              labelText: 'من رصيد المكافآت (متاح ${Rv.money(balance)} $cur)',
              suffixIcon: TextButton(onPressed: () => setState(() => _points.text = '$balance'), child: const Text('الكل')),
            ),
          ),
        ],
        SwitchListTile(contentPadding: EdgeInsets.zero, activeThumbColor: Rv.red, value: _paid, title: const Text('استُلم الدفع'), onChanged: (v) => setState(() => _paid = v)),
        SwitchListTile(contentPadding: EdgeInsets.zero, activeThumbColor: Rv.red, value: _confirm, title: const Text('الطلب مؤكد'), onChanged: (v) => setState(() => _confirm = v)),
        const SizedBox(height: 8),
        RvCard(
          child: Column(children: [
            _row(p, 'المجموع', '${Rv.money(_subtotal)} $cur'),
            _row(p, 'التوصيل', fee == null ? 'حسب المنطقة' : '${Rv.money(fee)} $cur'),
            if (_n(_discount) > 0) _row(p, 'خصم يدوي', '−${Rv.money(_n(_discount))} $cur'),
            if (_n(_points) > 0) _row(p, 'من رصيد المكافآت', '−${Rv.money(_n(_points))} $cur'),
            const Divider(),
            _row(p, 'الإجمالي', '${Rv.money(total)} $cur', bold: true),
            if (_coupon.text.trim().isNotEmpty)
              Text('خصم الرمز يُحسب عند الحفظ', style: AppTypography.caption.copyWith(color: p.inkFaint)),
          ]),
        ),
      ]),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Rv.red, minimumSize: const Size(0, 52)),
            onPressed: _saving || _lines.isEmpty ? null : _save,
            child: _saving ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('تسجيل الطلب'),
          ),
        ),
      ),
    );
  }

  Widget _row(AzmPalette p, String k, String v, {bool bold = false}) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          Text(k, style: AppTypography.body.copyWith(color: p.inkMuted, fontWeight: bold ? FontWeight.w800 : null)),
          const Spacer(),
          Text(v, style: AppTypography.body.copyWith(color: p.ink, fontWeight: bold ? FontWeight.w800 : FontWeight.w600)),
        ]),
      );
}
