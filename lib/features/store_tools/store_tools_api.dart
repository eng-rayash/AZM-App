import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/network/api_config.dart';
import '../../core/network/auth_token_store.dart';

/// أدوات المتجر في التطبيق التي لا يغطيها `ShopApi`: بثّ مساعد RVIOS AI
/// (Server-Sent Events) وحسابات الدفع المعلنة للمنصة.
///
/// `ApiClient` يقرأ الرد كاملًا ثم يفكّه، والبثّ يحتاج قراءة الأحداث وهي
/// تصل — فهذا الملف يكلّم الخادم مباشرة بالرمز نفسه.
class StoreToolsApi {
  StoreToolsApi({AuthTokenStore? tokens, http.Client? client})
      : _tokens = tokens ?? AuthTokenStore(),
        _http = client ?? http.Client();

  final AuthTokenStore _tokens;
  final http.Client _http;

  String get _base => '$apiBaseUrl$apiPrefix';

  /// حدث من بثّ المساعد: start · delta · title · done · error
  Stream<AiEvent> chat(String storeId, {String? conversationId, required String message, String mode = 'chat'}) async* {
    final token = await _tokens.readToken();
    final req = http.Request('POST', Uri.parse('$_base/shop/stores/$storeId/ai/chat'))
      ..headers['content-type'] = 'application/json'
      ..headers['accept'] = 'text/event-stream'
      ..body = jsonEncode({
        'message': message,
        if (conversationId != null) 'conversationId': conversationId else 'mode': mode,
      });
    if (token != null) req.headers['authorization'] = 'Bearer $token';

    final res = await _http.send(req).timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) {
      final body = await res.stream.bytesToString();
      String msg = 'تعذّر الوصول إلى المساعد (${res.statusCode})';
      try {
        final j = jsonDecode(body);
        if (j is Map && j['message'] != null) msg = j['message'] is List ? '${(j['message'] as List).first}' : '${j['message']}';
      } catch (_) {}
      yield AiEvent('error', {'message': msg});
      return;
    }

    var buffer = '';
    await for (final chunk in res.stream.transform(utf8.decoder)) {
      buffer += chunk;
      var cut = buffer.indexOf('\n\n');
      while (cut >= 0) {
        final block = buffer.substring(0, cut);
        buffer = buffer.substring(cut + 2);
        String? type;
        final data = StringBuffer();
        for (final line in block.split('\n')) {
          if (line.startsWith('event:')) type = line.substring(6).trim();
          if (line.startsWith('data:')) data.write(line.substring(5).trim());
        }
        if (type != null && data.isNotEmpty) {
          try {
            yield AiEvent(type, jsonDecode(data.toString()) as Map<String, dynamic>);
          } catch (_) {}
        }
        cut = buffer.indexOf('\n\n');
      }
    }
  }

  /// حسابات الدفع المعلنة (الكريمي، جيب، جوالي…) — عامة بلا جلسة.
  Future<List<Map<String, dynamic>>> paymentAccounts() async {
    final res = await _http.get(Uri.parse('$_base/shop/public/payment-accounts')).timeout(const Duration(seconds: 20));
    if (res.statusCode != 200) throw Exception('تعذّر تحميل حسابات الدفع');
    final j = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    return ((j['accounts'] as List?) ?? const []).cast<Map<String, dynamic>>();
  }
}

class AiEvent {
  AiEvent(this.type, this.data);
  final String type;
  final Map<String, dynamic> data;
}

/// لوحة عزم سمارت على الويب — لما يحتاج شاشة كبيرة (محرر شكل المتجر).
const String azmWebUrl = String.fromEnvironment('AZM_WEB_URL', defaultValue: 'https://azm.rvios.com');
const String storefrontUrl = String.fromEnvironment('AZM_STORE_URL', defaultValue: 'https://store.rvios.com');
/// نطاق روابط المتاجر: اسم-المتجر.rvios.com (مثل madad.rvios.com)
const String storeDomain = String.fromEnvironment('AZM_STORE_DOMAIN', defaultValue: 'rvios.com');
/// الرابط العام لمتجر — وفي التطوير المحلي مسار /s/ على المنصة
String storePublicUrl(String slug) =>
    storefrontUrl.contains('localhost') || storefrontUrl.contains('10.0.2.2') || storefrontUrl.contains('127.0.0.1')
        ? '$storefrontUrl/s/$slug'
        : 'https://$slug.$storeDomain';
