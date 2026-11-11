import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/design/azm_tokens.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_typography.dart';
import '../shop/data/shop_models.dart';
import '../shop/providers/shop_providers.dart';

/// إعدادات المتجر من التطبيق: الهوية والنصوص، التواصل والعنوان، التوصيل والدفع.
/// الحفظ عبر `PATCH /shop/stores/:id` نفسه الذي تستعمله لوحة الويب.
class StoreSettingsScreen extends ConsumerStatefulWidget {
  const StoreSettingsScreen({super.key, required this.store});
  final ShopStore store;

  @override
  ConsumerState<StoreSettingsScreen> createState() => _StoreSettingsScreenState();
}

class _StoreSettingsScreenState extends ConsumerState<StoreSettingsScreen> {
  late final _f = <String, TextEditingController>{
    'name': TextEditingController(text: widget.store.name),
    'tagline': TextEditingController(text: widget.store.tagline),
    'about': TextEditingController(text: widget.store.about),
    'whatsapp': TextEditingController(text: widget.store.whatsapp),
    'city': TextEditingController(text: widget.store.city),
    'address': TextEditingController(text: widget.store.address),
    'hours': TextEditingController(text: widget.store.hours),
    'deliveryFee': TextEditingController(text: '${widget.store.deliveryFee}'),
    'deliveryFreeOver': TextEditingController(text: '${widget.store.deliveryFreeOver}'),
    'deliveryNote': TextEditingController(text: widget.store.deliveryNote),
    'payNote': TextEditingController(text: widget.store.payNote),
  };
  late final Set<String> _pay = {...widget.store.payMethods};
  bool _saving = false;

  static const _payLabels = {'cod': 'الدفع عند الاستلام', 'bank': 'تحويل بنكي', 'wallet': 'محفظة إلكترونية'};

  @override
  void dispose() {
    for (final c in _f.values) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final patch = <String, Object?>{
      for (final k in ['name', 'tagline', 'about', 'whatsapp', 'city', 'address', 'hours', 'deliveryNote', 'payNote']) k: _f[k]!.text.trim(),
      'deliveryFee': int.tryParse(_f['deliveryFee']!.text.trim()) ?? 0,
      'deliveryFreeOver': int.tryParse(_f['deliveryFreeOver']!.text.trim()) ?? 0,
      'payMethods': _pay.toList(),
    };
    try {
      await ref.read(shopApiProvider).updateStore(widget.store.id, patch);
      ref.invalidate(storeProvider(widget.store.id));
      ref.invalidate(storeListProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('حُفظت إعدادات المتجر')));
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _field(String key, String label, {int lines = 1, TextInputType? type, String? hint}) => Padding(
        padding: const EdgeInsets.only(bottom: AzmSpace.md),
        child: TextField(controller: _f[key], minLines: lines, maxLines: lines, keyboardType: type, decoration: InputDecoration(labelText: label, hintText: hint)),
      );

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    Widget section(String t) => Padding(
          padding: const EdgeInsets.fromLTRB(0, AzmSpace.lg, 0, AzmSpace.sm),
          child: Text(t, style: AppTypography.h4.copyWith(color: p.ink)),
        );
    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(backgroundColor: p.ground, title: const Text('إعدادات المتجر')),
      body: ListView(padding: const EdgeInsets.all(AzmSpace.screenGutter), children: [
        section('الهوية'),
        _field('name', 'اسم المتجر'),
        _field('tagline', 'الشعار النصي', hint: 'جملة قصيرة تحت الاسم'),
        _field('about', 'عن المتجر', lines: 4),
        section('التواصل والعنوان'),
        _field('whatsapp', 'واتساب الطلبات', type: TextInputType.phone),
        _field('city', 'المدينة'),
        _field('address', 'العنوان'),
        _field('hours', 'ساعات العمل', hint: 'يوميًا ٩ص – ١١م'),
        section('التوصيل'),
        Row(children: [
          Expanded(child: _field('deliveryFee', 'رسم التوصيل', type: TextInputType.number)),
          const SizedBox(width: AzmSpace.md),
          Expanded(child: _field('deliveryFreeOver', 'مجاني فوق', type: TextInputType.number)),
        ]),
        _field('deliveryNote', 'ملاحظة التوصيل', lines: 2),
        section('طرق الدفع للعملاء'),
        for (final e in _payLabels.entries)
          CheckboxListTile(
            contentPadding: EdgeInsets.zero,
            value: _pay.contains(e.key),
            title: Text(e.value),
            // «عند الاستلام» لا يُنزع: متجر بلا طريقة دفع لا يستقبل طلبًا
            onChanged: e.key == 'cod' ? null : (v) => setState(() => v == true ? _pay.add(e.key) : _pay.remove(e.key)),
          ),
        _field('payNote', 'تعليمات الدفع للعميل', lines: 3, hint: 'رقم الحساب أو المحفظة واسم صاحبه'),
        const SizedBox(height: AzmSpace.md),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('حفظ'),
        ),
        const SizedBox(height: AzmSpace.xxl),
      ]),
    );
  }
}
