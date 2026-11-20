import 'package:flutter/material.dart';
import '../store_app/store_help.dart';
import '../../shared/widgets/help_tips.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/design/azm_tokens.dart';
import '../../core/network/api_exception.dart';
import '../../core/theme/app_typography.dart';
import '../shop/providers/shop_providers.dart';
import '../store_app/kit.dart';
import '../store_app/store_api.dart';
import '../store_app/store_gate.dart';
import '../store_tools/store_tools_api.dart' show storefrontUrl, storePublicUrl;
import 'live_store_frame.dart';
import 'platform_api.dart';
import 'platform_catalog.dart';
import 'platform_widgets.dart';
import 'store_templates_screen.dart';
import 'visual_editor_screen.dart';

/// استوديو تصميم المتجر: متجرك الحي في إطار هاتف أعلى الشاشة، وتحته كل ما يُعدَّل —
/// الهوية (الشعار والغلاف واللون والاسم)، القالب، شريط الإعلان، زر واتساب، الظهور في
/// Google، السياسات — والمحرر المرئي الكامل للنصوص والصور بالنقر. كل حفظ يحدّث المعاينة.
class DesignStudioScreen extends ConsumerWidget {
  const DesignStudioScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final p = AzmPalette.of(context);
    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(backgroundColor: p.ground, title: const Text('تصميم المتجر'), actions: const [HelpButton(StoreHelp.design)]),
      body: StoreGate(builder: (context, store, _) => WithHelp(tip: StoreHelp.design, child: _Studio(key: ValueKey(store.id), storeId: store.id))),
    );
  }
}

class _Studio extends ConsumerStatefulWidget {
  const _Studio({super.key, required this.storeId});
  final String storeId;
  @override
  ConsumerState<_Studio> createState() => _StudioState();
}

const _swatches = [Color(0xFFC1272D), Color(0xFF1F3C88), Color(0xFF2F4A3A), Color(0xFFB08D57), Color(0xFF6B2D5C), Color(0xFF111111), Color(0xFFE59A12), Color(0xFF0E7C86), Color(0xFFDB2777), Color(0xFF7C3AED)];

class _StudioState extends ConsumerState<_Studio> {
  Map<String, dynamic>? _s;
  String? _loadError;
  PreviewDevice _device = PreviewDevice.phone;

  /// يتغيّر مع كل حفظ فتُعاد المعاينة بلا نسخة مخزّنة
  int _version = DateTime.now().millisecondsSinceEpoch;
  bool _busy = false;
  bool _expanded = false;

  final _name = TextEditingController();
  final _tagline = TextEditingController();
  final _announce = TextEditingController();
  final _seoTitle = TextEditingController();
  final _seoDesc = TextEditingController();
  final _policies = {for (final k in const ['shipping', 'returns', 'privacy', 'terms']) k: TextEditingController()};
  bool _announceOn = false;
  bool _waFloat = true;
  String _color = '#C1272D';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    for (final c in [_name, _tagline, _announce, _seoTitle, _seoDesc, ..._policies.values]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final s = await ref.read(platformApiProvider).store(widget.storeId);
      final extras = ((s['appearance'] as Map?)?['extras'] as Map?) ?? const {};
      final announce = (extras['announce'] as Map?) ?? const {};
      final pol = (extras['policies'] as Map?) ?? const {};
      setState(() {
        _s = s;
        _name.text = '${s['name'] ?? ''}';
        _tagline.text = '${s['tagline'] ?? ''}';
        _color = '${s['color'] ?? '#C1272D'}';
        _announceOn = announce['on'] == true;
        _announce.text = '${announce['text'] ?? ''}';
        _waFloat = extras['waFloat'] != false;
        _seoTitle.text = '${extras['seoTitle'] ?? ''}';
        _seoDesc.text = '${extras['seoDescription'] ?? ''}';
        for (final e in _policies.entries) {
          e.value.text = '${pol[e.key] ?? ''}';
        }
      });
      _reloadPreview();
    } catch (e) {
      setState(() => _loadError = e is ApiException ? e.message : '$e');
    }
  }

  String get _slug => '${_s?['slug'] ?? ''}';
  bool get _pending => _s?['status'] == 2;

  void _reloadPreview() {
    if (_slug.isEmpty || _pending) return;
    if (mounted) setState(() => _version = DateTime.now().millisecondsSinceEpoch);
  }

  void _snack(String m, {bool error = false}) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: error ? AzmPalette.of(context).danger : null));

  Future<void> _run(Future<void> Function() fn, String ok) async {
    FocusScope.of(context).unfocus();
    setState(() => _busy = true);
    try {
      await fn();
      HapticFeedback.mediumImpact();
      _snack(ok);
      ref.invalidate(storeListProvider);
      await _load();
    } on ApiException catch (e) {
      _snack(e.message, error: true);
    } catch (e) {
      _snack('$e', error: true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _patch(Map<String, Object?> patch, String ok) => _run(() => ref.read(platformApiProvider).update(widget.storeId, patch), ok);

  Future<void> _image(String field, String label) async {
    final img = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 88, maxWidth: field == 'logo' ? 800 : 2000);
    if (img == null) return;
    await _run(() async {
      final url = await ref.read(storeDataApiProvider).uploadImage(widget.storeId, await img.readAsBytes(), img.name);
      await ref.read(platformApiProvider).update(widget.storeId, {field: url});
    }, 'حُفظ $label ✓');
  }

  Future<void> _saveExtras() => _run(
        () => ref.read(platformApiProvider).saveExtras(widget.storeId, {
          'announce': {'on': _announceOn, 'text': _announce.text.trim(), 'link': '', 'color': _color},
          'waFloat': _waFloat,
          'seoTitle': _seoTitle.text.trim(),
          'seoDescription': _seoDesc.text.trim(),
          'policies': {for (final e in _policies.entries) e.key: e.value.text.trim()},
        }),
        'حُفظت الإضافات ✓',
      );

  Color _hex(String h) => Color(int.tryParse('FF${h.replaceAll('#', '')}', radix: 16) ?? 0xFFC1272D);

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    if (_loadError != null) return RvEmpty(icon: Icons.wifi_off_rounded, title: 'تعذّر التحميل', body: _loadError, action: 'إعادة المحاولة', onAction: _load);
    final s = _s;
    if (s == null) return const Center(child: CircularProgressIndicator(color: Rv.red));
    final tpl = StoreTemplate.byId('${s['template'] ?? 'essential'}');
    final h = MediaQuery.sizeOf(context).height;

    return Stack(children: [
      ListView(padding: const EdgeInsets.fromLTRB(16, 0, 16, 40), children: [
        // ── المعاينة الحية ──
        AnimatedContainer(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic,
          height: _expanded ? h * .72 : h * .42,
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            gradient: const LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFF1C1311), Color(0xFF0E0908)]),
            borderRadius: BorderRadius.circular(28),
          ),
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Column(children: [
            Row(children: [
              const Icon(Icons.circle, size: 9, color: Color(0xFF34D399)),
              const SizedBox(width: 6),
              Expanded(child: Text(_pending ? 'يظهر بعد التفعيل' : 'معاينة حية', style: const TextStyle(color: Colors.white70, fontSize: 12))),
              DeviceSwitch(value: _device, onChanged: (d) => setState(() => _device = d)),
              const SizedBox(width: 4),
              _MiniBtn(icon: Icons.refresh_rounded, onTap: _reloadPreview),
              _MiniBtn(icon: _expanded ? Icons.close_fullscreen_rounded : Icons.open_in_full_rounded, onTap: () => setState(() => _expanded = !_expanded)),
              _MiniBtn(icon: Icons.open_in_new_rounded, onTap: () => launchUrl(Uri.parse(storePublicUrl(_slug)), mode: LaunchMode.externalApplication)),
            ]),
            const SizedBox(height: 8),
            Expanded(
              child: Center(
                child: _pending
                    ? AspectRatio(aspectRatio: 390 / 780, child: TemplateShot(tpl, radius: 26))
                    : _device == PreviewDevice.phone
                        ? AspectRatio(
                            aspectRatio: 390 / 780,
                            child: LiveStoreFrame(
                              key: ValueKey('p$_version'),
                              url: '$storefrontUrl/s/$_slug?v=$_version',
                              device: PreviewDevice.phone,
                              placeholder: TemplateShot(tpl, frame: false, radius: 26),
                            ),
                          )
                        : LiveStoreFrame(
                            key: ValueKey('d$_version'),
                            url: '$storefrontUrl/s/$_slug?v=$_version',
                            device: PreviewDevice.desktop,
                            address: '$_slug.rvios.com',
                            placeholder: Image.network(tpl.shotDesk, fit: BoxFit.cover, alignment: Alignment.topCenter, errorBuilder: (_, _, _) => const SizedBox()),
                          ),
              ),
            ),
          ]),
        ),

        // ── المحرر المرئي ──
        _Feature(
          icon: Icons.touch_app_rounded,
          title: 'المحرر المرئي الكامل',
          body: 'انقر أي نص أو صورة في متجرك لتعدّله، أخفِ الأقسام، وغيّر الخطوط وروابط التواصل.',
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => VisualEditorScreen(storeId: widget.storeId))).then((_) => _load()),
        ),
        const SizedBox(height: 10),

        // ── القالب ──
        RvCard(
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const StoreTemplatesScreen())).then((_) => _load()),
          padding: const EdgeInsets.all(12),
          child: Row(children: [
            SizedBox(width: 46, height: 86, child: TemplateShot(tpl, radius: 10)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('القالب', style: AppTypography.caption.copyWith(color: p.inkMuted)),
                Text(tpl.name, style: TextStyle(fontFamily: 'Zain', fontSize: 24, fontWeight: FontWeight.w800, color: p.ink, height: 1.1)),
                Text('غيّره أو جرّب قوالب أخرى بمعاينة حية', style: AppTypography.caption.copyWith(color: p.inkMuted)),
              ]),
            ),
            const Icon(Icons.chevron_left_rounded),
          ]),
        ),

        // ── الهوية ──
        _Section(icon: Icons.badge_outlined, title: 'الهوية', initiallyExpanded: true, children: [
          Row(children: [
            Expanded(child: _ImageTile(label: 'الشعار', url: '${s['logo'] ?? ''}', square: true, onTap: () => _image('logo', 'الشعار'))),
            const SizedBox(width: 10),
            Expanded(flex: 2, child: _ImageTile(label: 'صورة الغلاف', url: '${s['banner'] ?? ''}', onTap: () => _image('banner', 'الغلاف'))),
          ]),
          const SizedBox(height: 14),
          _Input(_name, 'اسم المتجر'),
          const SizedBox(height: 10),
          _Input(_tagline, 'العبارة التعريفية', hint: 'مثال: عطور فاخرة بأسعار تناسبك'),
          const SizedBox(height: 14),
          Text('لون المتجر', style: TextStyle(fontWeight: FontWeight.w700, color: p.ink)),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: [
            for (final c in _swatches)
              GestureDetector(
                onTap: () => setState(() => _color = '#${c.toARGB32().toRadixString(16).substring(2).toUpperCase()}'),
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: c, shape: BoxShape.circle, border: Border.all(color: _hex(_color) == c ? p.ink : Colors.transparent, width: 3)),
                  child: _hex(_color) == c ? const Icon(Icons.check_rounded, color: Colors.white, size: 18) : null,
                ),
              ),
          ]),
          const SizedBox(height: 14),
          _SaveBtn(busy: _busy, onPressed: () => _patch({'name': _name.text.trim(), 'tagline': _tagline.text.trim(), 'color': _color}, 'حُفظت الهوية ✓')),
        ]),

        // ── شريط الإعلان ──
        _Section(icon: Icons.campaign_outlined, title: 'شريط الإعلان', subtitle: _announceOn ? 'ظاهر' : 'مخفي', children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: Rv.red,
            value: _announceOn,
            onChanged: (v) => setState(() => _announceOn = v),
            title: const Text('إظهار الشريط أعلى المتجر'),
          ),
          _Input(_announce, 'نص الإعلان', hint: 'توصيل مجاني للطلبات فوق ٥٠ ألف'),
          const SizedBox(height: 12),
          _SaveBtn(busy: _busy, onPressed: _saveExtras),
        ]),

        // ── زر واتساب ──
        _Section(icon: Icons.chat_outlined, title: 'زر واتساب العائم', subtitle: _waFloat ? 'ظاهر' : 'مخفي', children: [
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: waGreen,
            value: _waFloat,
            onChanged: (v) => setState(() => _waFloat = v),
            title: const Text('زر محادثة دائم في زاوية المتجر'),
            subtitle: Text('يفتح واتساب على ${s['whatsapp'] ?? 'رقم متجرك'}', textDirection: TextDirection.rtl),
          ),
          _SaveBtn(busy: _busy, onPressed: _saveExtras),
        ]),

        // ── Google ──
        _Section(icon: Icons.travel_explore_rounded, title: 'الظهور في Google', children: [
          _Input(_seoTitle, 'عنوان الصفحة في نتائج البحث', max: 70),
          const SizedBox(height: 10),
          _Input(_seoDesc, 'وصف المتجر في نتائج البحث', max: 170, lines: 3),
          const SizedBox(height: 10),
          // معاينة نتيجة البحث
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.hairline)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('$_slug.rvios.com', textDirection: TextDirection.ltr, style: const TextStyle(color: Color(0xFF1E6B34), fontSize: 12)),
              Text(_seoTitle.text.isEmpty ? _name.text : _seoTitle.text, style: const TextStyle(color: Color(0xFF1A0DAB), fontSize: 16, fontWeight: FontWeight.w600)),
              Text(_seoDesc.text.isEmpty ? (_tagline.text.isEmpty ? 'وصف متجرك كما يظهر في Google' : _tagline.text) : _seoDesc.text,
                  maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Color(0xFF4D5156), fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 12),
          _SaveBtn(busy: _busy, onPressed: _saveExtras),
        ]),

        // ── السياسات ──
        _Section(icon: Icons.policy_outlined, title: 'سياسات المتجر', subtitle: 'الشحن، الاسترجاع، الخصوصية، الشروط', children: [
          for (final (k, label) in const [('shipping', 'سياسة الشحن والتوصيل'), ('returns', 'الاستبدال والاسترجاع'), ('privacy', 'الخصوصية'), ('terms', 'الشروط والأحكام')]) ...[
            _Input(_policies[k]!, label, lines: 3),
            const SizedBox(height: 10),
          ],
          _SaveBtn(busy: _busy, onPressed: _saveExtras),
        ]),
      ]),
      if (_busy) const Positioned(top: 0, left: 0, right: 0, child: LinearProgressIndicator(minHeight: 3, color: Rv.red)),
    ]);
  }
}

class _MiniBtn extends StatelessWidget {
  const _MiniBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => InkWell(
        borderRadius: BorderRadius.circular(99),
        onTap: onTap,
        child: Padding(padding: const EdgeInsets.all(6), child: Icon(icon, size: 18, color: Colors.white70)),
      );
}

class _Feature extends StatelessWidget {
  const _Feature({required this.icon, required this.title, required this.body, required this.onTap});
  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Material(
        borderRadius: BorderRadius.circular(22),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Ink(
            decoration: const BoxDecoration(gradient: Rv.heroGradient),
            padding: const EdgeInsets.all(16),
            child: Row(children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: .15), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                  const SizedBox(height: 2),
                  Text(body, style: TextStyle(color: Colors.white.withValues(alpha: .8), fontSize: 12.5, height: 1.45)),
                ]),
              ),
              const Icon(Icons.chevron_left_rounded, color: Colors.white),
            ]),
          ),
        ),
      );
}

class _Section extends StatelessWidget {
  const _Section({required this.icon, required this.title, required this.children, this.subtitle, this.initiallyExpanded = false});
  final IconData icon;
  final String title;
  final String? subtitle;
  final List<Widget> children;
  final bool initiallyExpanded;
  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return Container(
      margin: const EdgeInsets.only(top: 10),
      decoration: BoxDecoration(color: p.surfaceRaised, borderRadius: BorderRadius.circular(20), border: Border.all(color: p.hairline)),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          shape: const RoundedRectangleBorder(),
          collapsedShape: const RoundedRectangleBorder(),
          leading: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: Rv.red.withValues(alpha: .1), borderRadius: BorderRadius.circular(12)),
            child: Icon(icon, color: Rv.red, size: 20),
          ),
          title: Text(title, style: TextStyle(fontWeight: FontWeight.w800, color: p.ink)),
          subtitle: subtitle == null ? null : Text(subtitle!, style: AppTypography.caption.copyWith(color: p.inkMuted)),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}

class _Input extends StatelessWidget {
  const _Input(this.c, this.label, {this.hint, this.max, this.lines = 1});
  final TextEditingController c;
  final String label;
  final String? hint;
  final int? max;
  final int lines;
  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return TextField(
      controller: c,
      maxLength: max,
      minLines: lines,
      maxLines: lines == 1 ? 1 : 6,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: p.surfaceSunken,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.hairline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.hairline)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Rv.red, width: 1.5)),
      ),
    );
  }
}

class _ImageTile extends StatelessWidget {
  const _ImageTile({required this.label, required this.url, required this.onTap, this.square = false});
  final String label;
  final String url;
  final VoidCallback onTap;
  final bool square;
  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AspectRatio(
        aspectRatio: square ? 1 : 2,
        child: Container(
          decoration: BoxDecoration(color: p.surfaceSunken, borderRadius: BorderRadius.circular(16), border: Border.all(color: p.hairline)),
          clipBehavior: Clip.antiAlias,
          child: Stack(fit: StackFit.expand, children: [
            if (url.isNotEmpty) Image.network(url, fit: square ? BoxFit.contain : BoxFit.cover, errorBuilder: (_, _, _) => const SizedBox()),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 5),
                color: Colors.black.withValues(alpha: .5),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.photo_camera_outlined, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  Text(url.isEmpty ? 'أضف $label' : 'غيّر $label', style: const TextStyle(color: Colors.white, fontSize: 11.5, fontWeight: FontWeight.w700)),
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class _SaveBtn extends StatelessWidget {
  const _SaveBtn({required this.busy, required this.onPressed});
  final bool busy;
  final VoidCallback onPressed;
  @override
  Widget build(BuildContext context) => FilledButton.icon(
        onPressed: busy ? null : onPressed,
        icon: const Icon(Icons.check_rounded, size: 18),
        label: const Text('حفظ ونشر', style: TextStyle(fontWeight: FontWeight.w800)),
        style: FilledButton.styleFrom(backgroundColor: Rv.red, minimumSize: const Size(0, 48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
      );
}
