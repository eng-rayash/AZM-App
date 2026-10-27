@TestOn('vm')
library;

import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:azm/core/network/api_client.dart';
import 'package:azm/core/network/api_config.dart';
import 'package:azm/core/network/api_exception.dart';
import 'package:azm/core/network/auth_token_store.dart';
import 'package:azm/core/security/secure_storage_service.dart';

/// عميل الـAPI — الترجمة من HTTP إلى أخطاء يُفعل بها شيء.
///
/// الاختبارات هنا تهمّ أكثر مما تبدو: محرّك المزامنة سيتصرّف بحسب
/// **نوع** الخطأ، فخطأ مُصنَّف خطأً يعني إمّا إعادة محاولة أبدية لطلب
/// معطوب، وإمّا إسقاط تعديل بسبب تعارض نسخ كان يجب دمجه.
void main() {
  /// خزانة رموز في الذاكرة — التخزين الآمن يحتاج منصّة.
  late _FakeTokenStore tokens;

  setUp(() => tokens = _FakeTokenStore());

  ApiClient clientReturning(
    int status,
    Object? body, {
    void Function()? onUnauthenticated,
    void Function(http.Request req)? inspect,
  }) {
    final mock = MockClient((request) async {
      inspect?.call(request);
      return http.Response(
        body == null ? '' : jsonEncode(body),
        status,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });

    return ApiClient(
      httpClient: mock,
      tokens: tokens,
      baseUrl: 'http://test.local',
      onUnauthenticated: onUnauthenticated,
    );
  }

  group('المسار الناجح', () {
    test('يفكّ الجسم ويمرّره للمحوّل', () async {
      tokens.token = 'tok';
      final client = clientReturning(200, {'id': 'abc', 'title': 'اجتماع'});

      final title = await client.get<String>(
        '/meetings/abc',
        decode: (json) => (json as Map)['title'] as String,
      );

      expect(title, 'اجتماع');
    });

    test('يلحق الرمز والبادئة بكل طلب', () async {
      tokens.token = 'tok-123';
      http.Request? seen;
      final client = clientReturning(200, {}, inspect: (r) => seen = r);

      await client.get<dynamic>('/meetings');

      expect(seen!.headers['Authorization'], 'Bearer tok-123');
      expect(seen!.url.path, '$apiPrefix/meetings');
    });

    test('`If-Match` في الترويسة لا في الجسم', () async {
      tokens.token = 'tok';
      http.Request? seen;
      final client = clientReturning(200, {}, inspect: (r) => seen = r);

      await client.patch<dynamic>(
        '/meetings/abc',
        body: {'title': 'جديد'},
        expectedVersion: 3,
      );

      expect(seen!.headers['If-Match'], '3');
      expect(jsonDecode(seen!.body), {'title': 'جديد'});
    });

    test('المسار العامّ لا يطلب رمزًا', () async {
      // tokens فارغة عمدًا
      final client = clientReturning(201, {'ok': true});

      await expectLater(
        client.post<dynamic>('/auth/login', authenticated: false, body: {}),
        completes,
      );
    });
  });

  group('التصنيف يحدّد ما يُفعل', () {
    test('٤٠٠ لا يُعاد — الطلب نفسه معطوب', () async {
      tokens.token = 'tok';
      final client = clientReturning(400, {'message': 'الصيغة YYYY-MM-DD'});

      final e = await _capture(() => client.post<dynamic>('/meetings'));
      expect(e, isA<BadRequest>());
      expect(e.isRetryable, isFalse);
      // رسالة الخادم تُرجَّح: هي بالعربية وتعرف السبب
      expect(e.message, 'الصيغة YYYY-MM-DD');
    });

    test('أخطاء التحقّق تُحفظ قائمةً للعرض عند الحقول', () async {
      tokens.token = 'tok';
      final client = clientReturning(400, {
        'message': ['الصيغة HH:MM', 'العنوان مطلوب'],
      });

      final e = await _capture(() => client.post<dynamic>('/meetings'));
      expect((e as BadRequest).fieldErrors, hasLength(2));
      expect(e.message, 'الصيغة HH:MM');
    });

    test('٥٠٠ يُعاد — الخادم متعب لا الطلب خاطئ', () async {
      tokens.token = 'tok';
      final client = clientReturning(500, {'message': 'خطأ داخلي'});

      final e = await _capture(() => client.get<dynamic>('/meetings'));
      expect(e, isA<ServerFailure>());
      expect(e.isRetryable, isTrue);
    });

    test('٤٠١ يُعلم الطبقة الأعلى مرّة ولا يُعاد', () async {
      tokens.token = 'expired';
      var signalled = 0;
      final client = clientReturning(
        401,
        {'message': 'رمز غير صالح'},
        onUnauthenticated: () => signalled++,
      );

      final e = await _capture(() => client.get<dynamic>('/meetings'));
      expect(e, isA<Unauthenticated>());
      expect(e.isRetryable, isFalse);
      expect(signalled, 1);
    });

    test('٤٠٣ تُفرَّق عن ٤٠٤ — الأولى ترقية صلاحية والثانية معرّف خاطئ',
        () async {
      tokens.token = 'tok';

      final forbidden = await _capture(
        () => clientReturning(403, null).delete<dynamic>('/meetings/x'),
      );
      final missing = await _capture(
        () => clientReturning(404, null).get<dynamic>('/meetings/x'),
      );

      expect(forbidden, isA<Forbidden>());
      expect(missing, isA<NotFound>());
    });

    test('٤٠٩ بنسخة ⇐ تعارض يُدمَج', () async {
      tokens.token = 'tok';
      final client = clientReturning(409, {
        'message': 'تعارض نسخ',
        'currentVersion': 5,
        'expectedVersion': 3,
      });

      final e = await _capture(() => client.patch<dynamic>('/meetings/x'));
      expect(e, isA<VersionConflict>());
      expect((e as VersionConflict).currentVersion, 5);
      expect(e.expectedVersion, 3);
      // لا إعادة بالحمولة نفسها — ستتعارض مرّة أخرى
      expect(e.isRetryable, isFalse);
    });

    test('٤٠٩ بلا نسخة ⇐ قيمة مكرّرة لا تعارض', () async {
      // خلط الحالتين يجعل المزامنة تُسقط تعديلًا كان يجب دمجه
      final client = clientReturning(409, {'message': 'هذا البريد مسجَّل'});

      final e = await _capture(
        () => client.post<dynamic>('/auth/register', authenticated: false),
      );
      expect(e, isA<AlreadyExists>());
    });

    test('انقطاع الاتصال يُعاد ولا يُعرض خطأً', () async {
      tokens.token = 'tok';
      final client = ApiClient(
        httpClient: MockClient(
          (_) async => throw http.ClientException('فشل الاتصال'),
        ),
        tokens: tokens,
        baseUrl: 'http://test.local',
      );

      final e = await _capture(() => client.get<dynamic>('/meetings'));
      expect(e, isA<NetworkUnreachable>());
      expect(e.isRetryable, isTrue);
    });

    test('المهلة تنتهي ولا ينتظر التطبيق إلى ما لا نهاية', () async {
      tokens.token = 'tok';
      final client = ApiClient(
        httpClient: MockClient((_) => Completer<http.Response>().future),
        tokens: tokens,
        baseUrl: 'http://test.local',
      );

      // المهلة الحقيقية ١٥ ثانية — نتحقّق من النوع لا من الزمن
      final e = await _capture(
        () => client.get<dynamic>('/meetings'),
        timeout: apiTimeout + const Duration(seconds: 5),
      );
      expect(e, isA<NetworkUnreachable>());
    }, timeout: const Timeout(Duration(seconds: 30)));

    test('حالة غير مُعالَجة لا تُبتلع', () async {
      tokens.token = 'tok';
      final client = clientReturning(418, null);

      final e = await _capture(() => client.get<dynamic>('/meetings'));
      expect(e, isA<UnexpectedResponse>());
      expect((e as UnexpectedResponse).statusCode, 418);
    });

    test('جسم ليس JSON يُترجَم بحالته لا يرمي عند الفكّ', () async {
      // صفحة خطأ من وكيل أو بوابة — ليست من خادمنا
      tokens.token = 'tok';
      final client = ApiClient(
        httpClient: MockClient(
          (_) async => http.Response('<html>502</html>', 502),
        ),
        tokens: tokens,
        baseUrl: 'http://test.local',
      );

      final e = await _capture(() => client.get<dynamic>('/meetings'));
      expect(e, isA<ServerFailure>());
    });
  });

  group('الجلسة', () {
    test('طلب محمي بلا رمز يفشل قبل الشبكة', () async {
      var reached = false;
      final client = ApiClient(
        httpClient: MockClient((_) async {
          reached = true;
          return http.Response('{}', 200);
        }),
        tokens: tokens,
        baseUrl: 'http://test.local',
      );

      final e = await _capture(() => client.get<dynamic>('/meetings'));
      expect(e, isA<Unauthenticated>());
      // الرحلة إلى الخادم لتعود بـ٤٠١ هدر ووقت انتظار
      expect(reached, isFalse);
    });

    test('الحفظ يضمّ الرمز وشركته', () async {
      await tokens.save(token: 'tok', companyId: 'cmp-1');

      expect(await tokens.readToken(), 'tok');
      expect(await tokens.readCompanyId(), 'cmp-1');
      expect(await tokens.hasSession, isTrue);
    });

    test('المحو يمسح الاثنين', () async {
      await tokens.save(token: 'tok', companyId: 'cmp-1');
      await tokens.clear();

      expect(await tokens.readToken(), isNull);
      expect(await tokens.readCompanyId(), isNull);
      expect(await tokens.hasSession, isFalse);
    });
  });

  group('إعداد العنوان', () {
    test('يرفض HTTP لمضيف بعيد ويقبله محليًا', () {
      // الرمز يمرّ في الترويسة؛ HTTP يعني أن أي وسيط يقرؤه
      expect(_insecure('http://api.azm.app'), isTrue);
      expect(_insecure('https://api.azm.app'), isFalse);
      expect(_insecure('http://10.0.2.2:3000'), isFalse);
      expect(_insecure('http://localhost:3000'), isFalse);
    });
  });
}

// ─────────────────────────────────────────────
// أدوات
// ─────────────────────────────────────────────

/// نسخة من منطق [isInsecureRemoteBaseUrl] تقبل عنوانًا — الأصل يقرأ
/// ثابتًا وقت البناء فلا يُمرَّر إليه شيء.
bool _insecure(String baseUrl) {
  final uri = Uri.parse(baseUrl);
  if (uri.scheme == 'https') return false;
  const local = {'localhost', '127.0.0.1', '10.0.2.2', '::1'};
  return !local.contains(uri.host);
}

Future<ApiException> _capture(
  Future<void> Function() body, {
  Duration? timeout,
}) async {
  try {
    final future = body();
    await (timeout == null ? future : future.timeout(timeout));
  } on ApiException catch (e) {
    return e;
  }
  fail('توقّعنا ApiException ولم يُرمَ شيء');
}

class _FakeTokenStore extends AuthTokenStore {
  _FakeTokenStore() : super(_UnusedStorage());

  String? token;
  String? companyId;

  @override
  Future<String?> readToken() async => token;

  @override
  Future<String?> readCompanyId() async => companyId;

  @override
  Future<void> save({required String token, required String companyId}) async {
    this.token = token;
    this.companyId = companyId;
  }

  @override
  Future<void> clear() async {
    token = null;
    companyId = null;
  }

  @override
  Future<bool> get hasSession async => token != null;
}

/// لا يُستدعى: كل الدوال مُستبدَلة أعلاه. موجود لأن المُنشئ يطلب خزانة.
class _UnusedStorage implements SecureStorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('لا يجوز أن يصل الاختبار إلى التخزين الآمن');
}
