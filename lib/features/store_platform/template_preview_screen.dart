import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../store_app/kit.dart';
import 'platform_catalog.dart';
import 'platform_widgets.dart';

/// معاينة القالب داخل التطبيق: متجر العرض الحقيقي يعمل في إطار هاتف، يُتصفَّح ويُجرَّب
/// كما يراه العميل. التنقّل بين القوالب بالأسهم، واختيار القالب من الأسفل.
class TemplatePreviewScreen extends StatefulWidget {
  const TemplatePreviewScreen({
    super.key,
    required this.templates,
    required this.initial,
    this.onPick,
    this.pickLabel = 'اختر هذا القالب',
    this.priceOf,
    this.currency = 'USD',
    this.pickLabelOf,
  });

  final List<StoreTemplate> templates;
  final String Function(StoreTemplate)? pickLabelOf;
  final StoreTemplate initial;
  final ValueChanged<StoreTemplate>? onPick;
  final String pickLabel;
  final num? Function(StoreTemplate)? priceOf;
  final String currency;

  static Future<void> open(
    BuildContext context, {
    required List<StoreTemplate> templates,
    required StoreTemplate initial,
    ValueChanged<StoreTemplate>? onPick,
    String pickLabel = 'اختر هذا القالب',
    num? Function(StoreTemplate)? priceOf,
    String currency = 'USD',
    String Function(StoreTemplate)? pickLabelOf,
  }) =>
      Navigator.of(context).push(PageRouteBuilder<void>(
        transitionDuration: const Duration(milliseconds: 420),
        reverseTransitionDuration: const Duration(milliseconds: 300),
        pageBuilder: (_, _, _) => TemplatePreviewScreen(templates: templates, initial: initial, onPick: onPick, pickLabel: pickLabel, priceOf: priceOf, currency: currency, pickLabelOf: pickLabelOf),
        transitionsBuilder: (_, a, _, child) => FadeTransition(
          opacity: CurvedAnimation(parent: a, curve: Curves.easeOut),
          child: ScaleTransition(scale: Tween(begin: .96, end: 1.0).animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)), child: child),
        ),
      ));

  @override
  State<TemplatePreviewScreen> createState() => _TemplatePreviewScreenState();
}

class _TemplatePreviewScreenState extends State<TemplatePreviewScreen> {
  late StoreTemplate _t = widget.initial;
  late final WebViewController _web;
  int _progress = 0;
  bool _live = true;
  bool _details = false;

  @override
  void initState() {
    super.initState();
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) => mounted ? setState(() => _progress = p) : null,
        onPageStarted: (_) => mounted ? setState(() => _progress = 5) : null,
        onPageFinished: (_) => mounted ? setState(() => _progress = 100) : null,
        // المعاينة لمتجر العرض وحده: الروابط الخارجية (واتساب، إنستغرام…) لا تُفتح داخل الإطار
        onNavigationRequest: (r) => r.url.contains('rvios') ? NavigationDecision.navigate : NavigationDecision.prevent,
      ))
      ..loadRequest(Uri.parse(_t.demoUrl));
  }

  void _go(int step) {
    final l = widget.templates;
    final i = (l.indexWhere((x) => x.id == _t.id) + step) % l.length;
    HapticFeedback.selectionClick();
    setState(() {
      _t = l[i < 0 ? i + l.length : i];
      _progress = 0;
    });
    _web.loadRequest(Uri.parse(_t.demoUrl));
  }

  @override
  Widget build(BuildContext context) {
    final price = widget.priceOf?.call(_t);
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF0E0908),
        body: Stack(children: [
          // توهّج بلون القالب خلف الهاتف
          AnimatedContainer(
            duration: const Duration(milliseconds: 600),
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: const Alignment(0, -.2),
                radius: 1.1,
                colors: [(_t.palette.length > 1 ? _t.palette[1] : Rv.red).withValues(alpha: .35), const Color(0xFF0E0908)],
              ),
            ),
          ),
          SafeArea(
            child: Column(children: [
              // ── الرأس ──
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 0),
                child: Row(children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close_rounded, color: Colors.white)),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Column(key: ValueKey(_t.id), children: [
                        Text('قالب ${_t.name}', style: const TextStyle(fontFamily: 'Zain', fontSize: 24, fontWeight: FontWeight.w800, color: Colors.white, height: 1.1)),
                        Text('${_t.sector} · ${_t.tierName} · متجر العرض: ${_t.demoStore}', style: const TextStyle(color: Colors.white60, fontSize: 11.5)),
                      ]),
                    ),
                  ),
                  _ModeSwitch(live: _live, onChanged: (v) => setState(() => _live = v)),
                ]),
              ),
              // ── الهاتف ──
              Expanded(
                child: Row(children: [
                  _Arrow(icon: Icons.chevron_right_rounded, onTap: () => _go(-1)),
                  Expanded(
                    child: Center(
                      child: AspectRatio(
                        aspectRatio: 390 / 820,
                        child: Container(
                          padding: const EdgeInsets.all(7),
                          decoration: BoxDecoration(
                            color: const Color(0xFF050404),
                            borderRadius: BorderRadius.circular(38),
                            border: Border.all(color: Colors.white24, width: 1.2),
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .6), blurRadius: 40, offset: const Offset(0, 20))],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(31),
                            child: Stack(fit: StackFit.expand, children: [
                              TemplateShot(_t, frame: false, radius: 31),
                              if (_live) AnimatedOpacity(opacity: _progress > 60 ? 1 : 0, duration: const Duration(milliseconds: 400), child: WebViewWidget(controller: _web)),
                              if (_live && _progress < 100)
                                Align(
                                  alignment: Alignment.topCenter,
                                  child: LinearProgressIndicator(value: _progress / 100, minHeight: 3, color: Rv.gold, backgroundColor: Colors.transparent),
                                ),
                              // نتوء الهاتف
                              Align(
                                alignment: Alignment.topCenter,
                                child: Container(margin: const EdgeInsets.only(top: 8), width: 84, height: 22, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(99))),
                              ),
                            ]),
                          ),
                        ),
                      ),
                    ),
                  ),
                  _Arrow(icon: Icons.chevron_left_rounded, onTap: () => _go(1)),
                ]),
              ),
              // ── التفاصيل والاختيار ──
              AnimatedSize(
                duration: const Duration(milliseconds: 280),
                curve: Curves.easeOutCubic,
                child: Container(
                  margin: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .07),
                    borderRadius: BorderRadius.circular(26),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
                    GestureDetector(
                      onTap: () => setState(() => _details = !_details),
                      child: Row(children: [
                        Expanded(child: Text(_t.tag, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700))),
                        TierBadge(_t, price: price, currency: widget.currency),
                        Icon(_details ? Icons.expand_more_rounded : Icons.expand_less_rounded, color: Colors.white54),
                      ]),
                    ),
                    if (_details) ...[
                      const SizedBox(height: 8),
                      Text(_t.desc, style: const TextStyle(color: Colors.white70, height: 1.6, fontSize: 13)),
                    ],
                    const SizedBox(height: 10),
                    Wrap(spacing: 6, runSpacing: 6, children: [
                      for (final f in _t.feats)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .08), borderRadius: BorderRadius.circular(99)),
                          child: Text(f, style: const TextStyle(color: Colors.white, fontSize: 11.5)),
                        ),
                    ]),
                    if (widget.onPick != null) ...[
                      const SizedBox(height: 14),
                      FilledButton.icon(
                        onPressed: () {
                          widget.onPick!(_t);
                          Navigator.pop(context);
                        },
                        icon: const Icon(Icons.check_rounded),
                        label: Text(widget.pickLabelOf?.call(_t) ?? widget.pickLabel, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                        style: FilledButton.styleFrom(backgroundColor: Rv.red, minimumSize: const Size(0, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                      ),
                    ],
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}

class _Arrow extends StatelessWidget {
  const _Arrow({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onTap,
        icon: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: .1), shape: BoxShape.circle),
          child: Icon(icon, color: Colors.white, size: 26),
        ),
      );
}

class _ModeSwitch extends StatelessWidget {
  const _ModeSwitch({required this.live, required this.onChanged});
  final bool live;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    Widget b(String t, bool v) => GestureDetector(
          onTap: () => onChanged(v),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(color: live == v ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(99)),
            child: Text(t, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: live == v ? Colors.black : Colors.white70)),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .1), borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [b('حي', true), b('لقطة', false)]),
    );
  }
}
