import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../core/design/azm_tokens.dart';
import '../../core/network/auth_token_store.dart';
import '../store_app/kit.dart';
import '../store_app/store_api.dart';
import '../store_tools/store_tools_api.dart' show azmWebUrl;

/// المحرر المرئي الكامل داخل التطبيق: محرر «شكل المتجر» نفسه في RVIOS OS — تنقر النص
/// أو الصورة في متجرك فتعدّلها، وتخفي الأقسام، وتغيّر الخطوط وروابط التواصل.
///
/// يُفتح بجلسة التطبيق نفسها: صفحة خفيفة من نطاق اللوحة تُحمَّل أولًا فيُكتب فيها الرمز
/// والهوية في التخزين المحلي، ثم ينتقل إلى المحرر — فلا دخول ثانٍ ولا رمز في الرابط.
class VisualEditorScreen extends ConsumerStatefulWidget {
  const VisualEditorScreen({super.key, required this.storeId});
  final String storeId;

  @override
  ConsumerState<VisualEditorScreen> createState() => _VisualEditorScreenState();
}

/// يُخفي إطار اللوحة (الشريط الجانبي والرأس) فيبقى المحرر وحده بعرض الجوال
const _embedCss = '''
header.sticky, [data-slot="sidebar"], [data-slot="sidebar-gap"], [data-slot="sidebar-container"] { display: none !important; }
.app-main { padding: 10px !important; }
''';

class _VisualEditorScreenState extends ConsumerState<VisualEditorScreen> {
  late final WebViewController _web;
  bool _ready = false;
  bool _handedOff = false;
  int _progress = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) => mounted ? setState(() => _progress = p) : null,
        onPageFinished: (url) async {
          if (!_handedOff) return _handoff();
          await _web.runJavaScript(
              "document.documentElement.dataset.embed='1';var s=document.getElementById('rv-embed')||document.createElement('style');s.id='rv-embed';s.textContent=${jsonEncode(_embedCss)};document.head.appendChild(s);");
          if (mounted) setState(() => _ready = true);
        },
        onWebResourceError: (e) {
          if (e.isForMainFrame == true && mounted) setState(() => _error = 'تعذّر فتح المحرر — تحقّق من الاتصال');
        },
      ))
      ..loadRequest(Uri.parse('$azmWebUrl/robots.txt'));
  }

  Future<void> _handoff() async {
    try {
      final token = await AuthTokenStore().readToken();
      final ctx = await ref.read(storeDataApiProvider).context();
      if (token == null) throw Exception('لا جلسة');
      final js = [
        "localStorage.setItem('azm_access_token', ${jsonEncode(token)});",
        "localStorage.setItem('azm_user', ${jsonEncode(jsonEncode(ctx['user']))});",
        "localStorage.setItem('azm_company', ${jsonEncode(jsonEncode(ctx['company']))});",
        "localStorage.setItem('azm_active_store', ${jsonEncode(widget.storeId)});",
        "localStorage.setItem('rv_embed', '1');",
        "location.replace('/store/appearance?embed=1');",
      ].join();
      _handedOff = true;
      await _web.runJavaScript(js);
    } catch (e) {
      if (mounted) setState(() => _error = 'تعذّر فتح المحرر بجلستك — سجّل الدخول من جديد');
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    return Scaffold(
      backgroundColor: p.ground,
      appBar: AppBar(
        backgroundColor: p.ground,
        title: const Text('المحرر المرئي'),
        actions: [IconButton(tooltip: 'تحديث', onPressed: () => _web.reload(), icon: const Icon(Icons.refresh_rounded))],
        bottom: _progress < 100 ? PreferredSize(preferredSize: const Size.fromHeight(3), child: LinearProgressIndicator(value: _progress / 100, minHeight: 3, color: Rv.red)) : null,
      ),
      body: _error != null
          ? RvEmpty(icon: Icons.wifi_off_rounded, title: 'المحرر لم يُفتح', body: _error, action: 'إعادة المحاولة', onAction: () {
              setState(() {
                _error = null;
                _handedOff = false;
              });
              _web.loadRequest(Uri.parse('$azmWebUrl/robots.txt'));
            })
          : Stack(children: [
              WebViewWidget(controller: _web),
              if (!_ready)
                ColoredBox(
                  color: p.ground,
                  child: const Center(
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      CircularProgressIndicator(color: Rv.red),
                      SizedBox(height: 14),
                      Text('نفتح محرر متجرك…'),
                    ]),
                  ),
                ),
            ]),
    );
  }
}
