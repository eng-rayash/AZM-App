import 'dart:convert';

import 'package:azm/core/api/api_client.dart';
import 'package:azm/features/auth/data/auth_repository.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// المصادقة على الباكند الموحّد: الدخول يحفظ الرمز، والاستعادة تسأل الخادم،
/// و٤٠١ خروج فعلي، وانقطاع الشبكة ليس خروجًا (تُستعاد نسخة الجهاز).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const loginBody = {
    'accessToken': 'jwt-abc',
    'user': {'id': 'u1', 'email': 'a@azm.test', 'displayName': 'أحمد', 'avatarUrl': null},
    'company': {'id': 'c1', 'name': 'شركة الأمل'},
    'companies': [
      {'id': 'c1', 'name': 'شركة الأمل', 'role': 2},
      {'id': 'c2', 'name': 'فرع عدن', 'role': 5},
    ],
  };
  const contextBody = {
    'user': {'id': 'u1', 'email': 'a@azm.test', 'displayName': 'أحمد', 'avatarUrl': null},
    'company': {'id': 'c1', 'name': 'شركة الأمل'},
    'role': 2,
  };

  late List<http.Request> calls;

  AuthRepository repoWith(Future<http.Response> Function(http.Request) handler) {
    calls = [];
    final client = MockClient((req) {
      calls.add(req);
      return handler(req);
    });
    return AuthRepository(ApiClient(client: client, tokens: TokenStore(), baseUrl: 'http://api.test/api/v1'));
  }

  http.Response json(Object body, [int status = 200]) =>
      http.Response.bytes(utf8.encode(jsonEncode(body)), status, headers: {'content-type': 'application/json'});

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    FlutterSecureStorage.setMockInitialValues({});
  });

  test('الدخول يحفظ الرمز ويرسله مع الطلبات التالية، ويقرأ الدور من الشركة', () async {
    final repo = repoWith((req) async => req.url.path.endsWith('/auth/login') ? json(loginBody) : json(contextBody));

    final s = await repo.signIn(email: 'a@azm.test', password: 'secret-123');
    expect(s.account.displayName, 'أحمد');
    expect(s.company.id, 'c1');
    expect(s.role, 2);
    expect(s.companies, hasLength(2));

    final restored = await repo.restore();
    expect(restored?.company.name, 'شركة الأمل');
    expect(restored?.offline, isFalse);
    expect(calls.last.headers['authorization'], 'Bearer jwt-abc');
  });

  test('رسالة الخادم العربية تصل كما هي', () async {
    final repo = repoWith((_) async => json({'message': 'بيانات الدخول غير صحيحة'}, 401));
    expect(
      () => repo.signIn(email: 'a@azm.test', password: 'wrong-pass'),
      throwsA(isA<ApiException>().having((e) => e.message, 'message', 'بيانات الدخول غير صحيحة')),
    );
  });

  test('التسجيل يرسل اسم الشركة، والمسجِّل مالكها', () async {
    final repo = repoWith((_) async => json({
          'accessToken': 'jwt-new',
          'user': loginBody['user'],
          'company': {'id': 'c9', 'name': 'مؤسسة جديدة'},
        }, 201));

    final s = await repo.signUp(email: 'n@azm.test', password: 'secret-123', displayName: 'نور', companyName: 'مؤسسة جديدة');
    expect(jsonDecode(calls.single.body)['companyName'], 'مؤسسة جديدة');
    expect(s.role, 0);
  });

  test('رفض الخادم للرمز (٤٠١) يُخرج ويمسح الرمز والنسخة', () async {
    var reject = false;
    final repo = repoWith((req) async {
      if (req.url.path.endsWith('/auth/login')) return json(loginBody);
      return reject ? json({'message': 'غير مصرّح'}, 401) : json(contextBody);
    });
    await repo.signIn(email: 'a@azm.test', password: 'secret-123');

    reject = true;
    expect(await repo.restore(), isNull);
    expect(await repo.api.tokens.read(), isNull);
  });

  test('انقطاع الشبكة ليس خروجًا — تُستعاد آخر جلسة من الجهاز', () async {
    var offline = false;
    final repo = repoWith((req) async {
      if (offline) throw http.ClientException('no network');
      return req.url.path.endsWith('/auth/login') ? json(loginBody) : json(contextBody);
    });
    await repo.signIn(email: 'a@azm.test', password: 'secret-123');

    offline = true;
    final s = await repo.restore();
    expect(s, isNotNull);
    expect(s!.offline, isTrue);
    expect(s.account.email, 'a@azm.test');
    expect(await repo.api.tokens.read(), 'jwt-abc');
  });

  test('بلا رمز محفوظ لا طلب ولا جلسة', () async {
    final repo = repoWith((_) async => json(contextBody));
    expect(await repo.restore(), isNull);
    expect(calls, isEmpty);
  });
}
