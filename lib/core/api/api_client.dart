import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;

/// عنوان الباكند الموحّد — النظام نفسه الذي تعمل عليه منصة عزم سمارت على الويب:
/// الحسابات والشركات والصلاحيات واحدة في الاثنين.
///
/// يُضبط وقت البناء: `--dart-define=AZM_API_URL=https://api.rvios.com/api/v1`.
/// والافتراض للتطوير المحلي؛ محاكي أندرويد يرى جهازك على `10.0.2.2` لا `localhost`.
String get azmApiUrl {
  const fromEnv = String.fromEnvironment('AZM_API_URL');
  if (fromEnv.isNotEmpty) return fromEnv.replaceAll(RegExp(r'/+$'), '');
  final host = !kIsWeb && defaultTargetPlatform == TargetPlatform.android ? '10.0.2.2' : 'localhost';
  return 'http://$host:3002/api/v1';
}

/// خطأ من الباكند برسالته العربية كما كتبها (`{ message }`)، أو رسالة
/// شبكة واضحة حين لا يصل الطلب أصلًا.
class ApiException implements Exception {
  const ApiException(this.message, {this.status});

  final String message;

  /// `null` حين لم يصل الطلب (لا شبكة، مهلة).
  final int? status;

  bool get isUnauthorized => status == 401;
  bool get isNetwork => status == null;

  @override
  String toString() => message;
}

/// رمز الدخول في التخزين الآمن للجهاز (Keychain / Keystore) — لا في
/// `SharedPreferences` المقروءة نصًّا.
class TokenStore {
  TokenStore([FlutterSecureStorage? storage]) : _storage = storage ?? const FlutterSecureStorage();

  static const _key = 'azm.accessToken';
  final FlutterSecureStorage _storage;
  String? _cached;
  bool _loaded = false;

  Future<String?> read() async {
    if (_loaded) return _cached;
    try {
      _cached = await _storage.read(key: _key);
    } catch (_) {
      _cached = null; // تخزين تالف أو غير متاح — نبدأ بلا جلسة
    }
    _loaded = true;
    return _cached;
  }

  Future<void> write(String token) async {
    _cached = token;
    _loaded = true;
    await _storage.write(key: _key, value: token);
  }

  Future<void> clear() async {
    _cached = null;
    _loaded = true;
    await _storage.delete(key: _key);
  }
}

/// عميل JSON للباكند الموحّد: يضيف رمز الدخول، ويحوّل الأخطاء إلى
/// [ApiException] برسالة تُعرض للمستخدم كما هي.
class ApiClient {
  ApiClient({http.Client? client, TokenStore? tokens, String? baseUrl})
      : _http = client ?? http.Client(),
        tokens = tokens ?? TokenStore(),
        baseUrl = baseUrl ?? azmApiUrl;

  final http.Client _http;
  final TokenStore tokens;
  final String baseUrl;

  static const _timeout = Duration(seconds: 20);

  Future<Map<String, dynamic>> get(String path) => _send('GET', path);
  Future<Map<String, dynamic>> post(String path, [Object? body]) => _send('POST', path, body);
  Future<Map<String, dynamic>> patch(String path, [Object? body]) => _send('PATCH', path, body);

  Future<Map<String, dynamic>> _send(String method, String path, [Object? body]) async {
    final token = await tokens.read();
    final req = http.Request(method, Uri.parse('$baseUrl$path'))
      ..headers['accept'] = 'application/json';
    if (token != null) req.headers['authorization'] = 'Bearer $token';
    if (body != null) {
      req.headers['content-type'] = 'application/json';
      req.body = jsonEncode(body);
    }

    final http.Response res;
    try {
      res = await http.Response.fromStream(await _http.send(req).timeout(_timeout));
    } on TimeoutException {
      throw const ApiException('انتهت مهلة الاتصال بالخادم — تحقّق من الإنترنت ثم أعد المحاولة.');
    } catch (_) {
      throw const ApiException('تعذّر الاتصال بالخادم — تحقّق من الإنترنت ثم أعد المحاولة.');
    }

    final decoded = res.body.isEmpty ? null : _tryJson(res.body);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    }
    throw ApiException(_messageOf(decoded, res.statusCode), status: res.statusCode);
  }

  static Object? _tryJson(String body) {
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  static String _messageOf(Object? body, int status) {
    if (body is Map) {
      final m = body['message'];
      if (m is String && m.isNotEmpty) return m;
      if (m is List && m.isNotEmpty) return m.first.toString();
    }
    return switch (status) {
      401 => 'انتهت الجلسة — سجّل الدخول من جديد.',
      403 => 'لا تملك صلاحية هذا الإجراء.',
      404 => 'غير موجود.',
      429 => 'محاولات كثيرة — انتظر قليلًا ثم أعد المحاولة.',
      >= 500 => 'عطل مؤقت في الخادم — أعد المحاولة بعد قليل.',
      _ => 'تعذّر إتمام الطلب ($status).',
    };
  }
}
