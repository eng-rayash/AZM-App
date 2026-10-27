import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'api_config.dart';
import 'api_exception.dart';
import 'auth_token_store.dart';

/// AZM — عميل الـAPI
///
/// طبقة واحدة بين التطبيق والخادم، ومسؤوليتها أربع:
///   ١. إلحاق رمز الجلسة بكل طلب — فلا ينساه مستدعٍ
///   ٢. ترجمة حالات HTTP إلى أخطاء مصنَّفة (`api_exception.dart`)
///   ٣. فرض مهلة — تطبيق دون اتصال لا يجوز أن ينتظر إلى ما لا نهاية
///   ٤. إعلام الطبقة الأعلى عند ٤٠١ لتُخرج المستخدم مرّة واحدة
///
/// ما **ليست** مسؤوليته: إعادة المحاولة. القرار يعتمد على نوع الفشل
/// وعلى العملية — المزامنة تؤجّل وتعيد، وزرّ يضغطه المستخدم لا يُعيد
/// بصمت. إخفاء الإعادة هنا يجعل زرًّا واحدًا يُنشئ ثلاث فواتير.
class ApiClient {
  ApiClient({
    http.Client? httpClient,
    AuthTokenStore? tokens,
    this.onUnauthenticated,
    String? baseUrl,
  })  : _http = httpClient ?? http.Client(),
        _tokens = tokens ?? AuthTokenStore(),
        _baseUrl = baseUrl ?? apiBaseUrl;

  final http.Client _http;
  final AuthTokenStore _tokens;
  final String _baseUrl;

  /// يُنادى مرّة عند ٤٠١ — الرمز انتهى أو سُحب.
  ///
  /// رُدَّ الاستجابة إلى الطبقة الأعلى بدل التعامل معها هنا: العميل لا
  /// يعرف شيئًا عن التوجيه ولا عن حالة الواجهة، وجعله يقرّر «اذهب إلى
  /// شاشة الدخول» يربط الشبكة بالملاحة.
  final void Function()? onUnauthenticated;

  // ─────────────────────────────────────────────
  // الأفعال
  // ─────────────────────────────────────────────

  Future<T> get<T>(
    String path, {
    Map<String, String>? query,
    T Function(dynamic json)? decode,
  }) =>
      _send(
        'GET',
        path,
        query: query,
        decode: decode,
      );

  Future<T> post<T>(
    String path, {
    Object? body,
    T Function(dynamic json)? decode,
    bool authenticated = true,
  }) =>
      _send(
        'POST',
        path,
        body: body,
        decode: decode,
        authenticated: authenticated,
      );

  Future<T> patch<T>(
    String path, {
    Object? body,
    T Function(dynamic json)? decode,

    /// النسخة المتوقَّعة للقفل التفاؤلي — تُرسل في `If-Match`.
    ///
    /// في الترويسة لا في الجسم: النسخة خاصّية بالطلب لا بالمورد
    /// المُعدَّل. والخادم يقرؤها من هناك.
    int? expectedVersion,
  }) =>
      _send(
        'PATCH',
        path,
        body: body,
        decode: decode,
        extraHeaders: expectedVersion == null
            ? null
            : {'If-Match': '$expectedVersion'},
      );

  Future<T> delete<T>(
    String path, {
    T Function(dynamic json)? decode,
  }) =>
      _send('DELETE', path, decode: decode);

  void close() => _http.close();

  // ─────────────────────────────────────────────
  // التنفيذ
  // ─────────────────────────────────────────────

  Future<T> _send<T>(
    String method,
    String path, {
    Object? body,
    Map<String, String>? query,
    Map<String, String>? extraHeaders,
    T Function(dynamic json)? decode,
    bool authenticated = true,
  }) async {
    final uri = Uri.parse('$_baseUrl$apiPrefix$path').replace(
      queryParameters: query?.isEmpty ?? true ? null : query,
    );

    final headers = <String, String>{
      'Accept': 'application/json',
      if (body != null) 'Content-Type': 'application/json',
      ...?extraHeaders,
    };

    if (authenticated) {
      final token = await _tokens.readToken();
      if (token == null) {
        // فشل قبل الشبكة: طلب يحتاج رمزًا ولا رمز. الرحلة إلى الخادم
        // لتعود بـ٤٠١ هدر ووقت انتظار بلا فائدة.
        throw const Unauthenticated('لا جلسة — سجّل الدخول');
      }
      headers['Authorization'] = 'Bearer $token';
    }

    final request = http.Request(method, uri)..headers.addAll(headers);
    if (body != null) request.body = jsonEncode(body);

    final http.Response response;
    try {
      final streamed = await _http.send(request).timeout(apiTimeout);
      response = await http.Response.fromStream(streamed);
    } on TimeoutException {
      throw const NetworkUnreachable('انتهت مهلة الاتصال بالخادم');
    } on http.ClientException {
      // تكفي وحدها على المنصّتين: `IOClient` يلفّ `SocketException` في
      // `ClientException`، والويب لا يملك `SocketException` أصلًا.
      // استيراد `dart:io` هنا كان سيكسر بناء الويب بلا مقابل.
      throw const NetworkUnreachable();
    }

    return _handle(response, decode);
  }

  T _handle<T>(http.Response response, T Function(dynamic json)? decode) {
    final status = response.statusCode;
    final json = _tryDecode(response.body);

    if (status >= 200 && status < 300) {
      if (decode != null) return decode(json);
      // `T` قد يكون `void` حين لا يهمّ الجسم
      return json as T;
    }

    if (status == 401) {
      onUnauthenticated?.call();
      throw Unauthenticated(_message(json, 'انتهت الجلسة — سجّل الدخول'));
    }

    throw switch (status) {
      400 || 422 => BadRequest(
          _message(json, 'طلب غير صالح'),
          fieldErrors: _fieldErrors(json),
        ),
      403 => Forbidden(_message(json, 'صلاحيتك لا تكفي لهذا الإجراء')),
      404 => NotFound(_message(json, 'السجلّ غير موجود')),
      409 => _conflict(json),
      >= 500 => ServerFailure(_message(json, 'خطأ في الخادم — جرّب لاحقًا')),
      _ => UnexpectedResponse(
          _message(json, 'ردّ غير متوقَّع من الخادم'),
          statusCode: status,
        ),
    };
  }

  /// ٤٠٩ حالتان مختلفتان، ولا تُخلطان.
  ///
  /// `DomainErrorFilter` على الخادم يُرفق `currentVersion` لتعارض
  /// النسخ، ولا يُرفقها لتكرار بريد. وجودها هو ما يفرّق بين «أعد
  /// الجلب وادمج» و«غيّر المُدخَل».
  ApiException _conflict(dynamic json) {
    if (json is Map && json['currentVersion'] is int) {
      return VersionConflict(
        _message(json, 'تعارض نسخ'),
        currentVersion: json['currentVersion'] as int,
        expectedVersion: json['expectedVersion'] as int? ?? -1,
      );
    }
    return AlreadyExists(_message(json, 'القيمة مستخدَمة بالفعل'));
  }

  /// يفكّ JSON، ويعيد `null` إن لم يكن الجسم JSON.
  ///
  /// جسم غير JSON يعني وسيطًا يعترض (بوابة، صفحة خطأ من وكيل) لا
  /// خادمنا. لا نرمي هنا كي تصل الحالة إلى [_handle] فتُترجم برقمها.
  dynamic _tryDecode(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  /// رسالة الخادم إن وُجدت، وإلا [fallback].
  ///
  /// NestJS يرسل `message` نصًّا أو قائمة نصوص حسب مصدر الخطأ.
  /// ترجيح رسالته على رسالتنا مقصود: هي بالعربية وتعرف السبب.
  String _message(dynamic json, String fallback) {
    if (json is! Map) return fallback;
    final m = json['message'];
    if (m is String && m.isNotEmpty) return m;
    if (m is List && m.isNotEmpty) return m.first.toString();
    return fallback;
  }

  /// أخطاء التحقّق حين يرسلها `ValidationPipe` قائمةً.
  List<String> _fieldErrors(dynamic json) {
    if (json is! Map) return const [];
    final m = json['message'];
    if (m is List) return m.map((e) => e.toString()).toList();
    return const [];
  }
}
