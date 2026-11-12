import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';

import '../store_app/kit.dart';

/// شكل المعاينة: هاتف أو متصفح سطح المكتب.
enum PreviewDevice { phone, desktop }

/// إطار معاينة حيّ لمتجر: هاتف بنتوئه، أو نافذة متصفح بشريط عنوان.
///
/// معاينة المتصفح حقيقية لا صورة مكبّرة: الصفحة تُرسم بعرض ١٢٨٠ بكسل (كشاشة حاسوب)
/// بوكيل مستخدم سطح المكتب، ثم تُصغَّر لتملأ الإطار — فتظهر تخطيطات سطح المكتب كما هي.
class LiveStoreFrame extends StatefulWidget {
  const LiveStoreFrame({
    super.key,
    required this.url,
    required this.device,
    this.placeholder,
    this.address,
  });

  final String url;
  final PreviewDevice device;

  /// ما يظهر حتى تكتمل الصفحة (لقطة القالب مثلًا)
  final Widget? placeholder;

  /// نص شريط العنوان في إطار المتصفح
  final String? address;

  @override
  State<LiveStoreFrame> createState() => _LiveStoreFrameState();
}

const _desktopWidth = 1280.0;
const _desktopUa = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/126.0.0.0 Safari/537.36';

class _LiveStoreFrameState extends State<LiveStoreFrame> {
  late final WebViewController _web = WebViewController();
  int _progress = 0;
  bool _ready = false;
  double _width = 360;

  bool get _desktop => widget.device == PreviewDevice.desktop;

  @override
  void initState() {
    super.initState();
    _web
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) => mounted ? setState(() => _progress = p) : null,
        onPageStarted: (_) {
          if (mounted) setState(() => _ready = false);
          _fit();
        },
        onPageFinished: (_) async {
          await _fit();
          // وقت قصير لإعادة التخطيط بعرض سطح المكتب قبل الإظهار
          if (_desktop) await Future<void>.delayed(const Duration(milliseconds: 250));
          if (mounted) setState(() => _ready = true);
        },
        // المعاينة لمتاجر المنصة وحدها: روابط واتساب وإنستغرام لا تُفتح داخل الإطار
        onNavigationRequest: (r) => r.url.contains('rvios') ? NavigationDecision.navigate : NavigationDecision.prevent,
      ));
    if (_desktop) {
      _web.setUserAgent(_desktopUa);
      final android = _web.platform;
      if (android is AndroidWebViewController) android.setUseWideViewPort(true);
    }
    _web.loadRequest(Uri.parse(widget.url));
  }

  @override
  void didUpdateWidget(LiveStoreFrame old) {
    super.didUpdateWidget(old);
    if (old.url != widget.url) _web.loadRequest(Uri.parse(widget.url));
  }

  /// يرسم الصفحة بعرض ١٢٨٠ ويصغّرها إلى عرض الإطار
  Future<void> _fit() async {
    if (!_desktop) return;
    final s = (_width / _desktopWidth).toStringAsFixed(4);
    final content = 'width=${_desktopWidth.toInt()}, initial-scale=$s, minimum-scale=$s, maximum-scale=$s, user-scalable=no';
    try {
      await _web.runJavaScript(
          "(function(){var m=document.querySelector('meta[name=viewport]');if(!m){m=document.createElement('meta');m.name='viewport';(document.head||document.documentElement).appendChild(m);}m.setAttribute('content','$content');})();");
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final page = LayoutBuilder(builder: (context, c) {
      if ((c.maxWidth - _width).abs() > 1) {
        _width = c.maxWidth;
        WidgetsBinding.instance.addPostFrameCallback((_) => _fit());
      }
      return Stack(fit: StackFit.expand, children: [
        if (widget.placeholder != null) widget.placeholder! else const ColoredBox(color: Colors.white),
        AnimatedOpacity(opacity: _ready || (!_desktop && _progress > 60) ? 1 : 0, duration: const Duration(milliseconds: 350), child: WebViewWidget(controller: _web)),
        if (_progress < 100)
          Align(alignment: Alignment.topCenter, child: LinearProgressIndicator(value: _progress / 100, minHeight: 3, color: Rv.gold, backgroundColor: Colors.transparent)),
      ]);
    });

    if (_desktop) {
      return Container(
        decoration: BoxDecoration(
          color: const Color(0xFF2A2321),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .45), blurRadius: 30, offset: const Offset(0, 14))],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(children: [
          // شريط المتصفح
          Container(
            height: 30,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            color: const Color(0xFF2A2321),
            child: Row(textDirection: TextDirection.ltr, children: [
              for (final c in const [Color(0xFFFF5F57), Color(0xFFFEBC2E), Color(0xFF28C840)])
                Container(width: 9, height: 9, margin: const EdgeInsets.only(right: 5), decoration: BoxDecoration(color: c, shape: BoxShape.circle)),
              const SizedBox(width: 8),
              Expanded(
                child: Container(
                  height: 20,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: Colors.white.withValues(alpha: .1), borderRadius: BorderRadius.circular(99)),
                  child: Row(mainAxisSize: MainAxisSize.min, textDirection: TextDirection.ltr, children: [
                    const Icon(Icons.lock_rounded, size: 10, color: Colors.white54),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(widget.address ?? Uri.parse(widget.url).host, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.white70, fontSize: 10.5)),
                    ),
                  ]),
                ),
              ),
              const SizedBox(width: 40),
            ]),
          ),
          Expanded(child: page),
        ]),
      );
    }

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: const Color(0xFF050404),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: Colors.white24, width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: .5), blurRadius: 34, offset: const Offset(0, 16))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Stack(fit: StackFit.expand, children: [
          page,
          Align(
            alignment: Alignment.topCenter,
            child: Container(margin: const EdgeInsets.only(top: 7), width: 74, height: 20, decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(99))),
          ),
        ]),
      ),
    );
  }
}

/// مبدّل «جوال | متصفح»
class DeviceSwitch extends StatelessWidget {
  const DeviceSwitch({super.key, required this.value, required this.onChanged, this.dark = true});
  final PreviewDevice value;
  final ValueChanged<PreviewDevice> onChanged;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    Widget b(PreviewDevice d, IconData icon, String label) {
      final on = value == d;
      return GestureDetector(
        onTap: () => onChanged(d),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(color: on ? Colors.white : Colors.transparent, borderRadius: BorderRadius.circular(99)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(icon, size: 14, color: on ? Colors.black : Colors.white70),
            const SizedBox(width: 4),
            Text(label, style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: on ? Colors.black : Colors.white70)),
          ]),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: .1), borderRadius: BorderRadius.circular(99)),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        b(PreviewDevice.phone, Icons.phone_iphone_rounded, 'جوال'),
        b(PreviewDevice.desktop, Icons.desktop_windows_rounded, 'متصفح'),
      ]),
    );
  }
}
