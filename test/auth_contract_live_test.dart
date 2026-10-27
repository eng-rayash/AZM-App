@TestOn('vm')
library;

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:azm/core/network/api_client.dart';
import 'package:azm/core/network/api_config.dart';
import 'package:azm/core/network/api_exception.dart';
import 'package:azm/core/network/auth_token_store.dart';
import 'package:azm/core/security/secure_storage_service.dart';
import 'package:azm/features/auth/data/azm_auth_api.dart';

/// عقد العميل والخادم — على خادم يعمل فعلًا.
///
/// `api_client_test.dart` يثبت أن العميل يترجم HTTP صحيحًا، لكنه يترجم
/// **ردودًا كتبتُها أنا**. وهذا لا يثبت أن شكل JSON الذي يفكّه العميل
/// هو ما يرسله الخادم: حقل أُعيد تسميته على الخادم يُمرّر كل اختبارات
/// الطرفين منفردين، ويفشل في الإنتاج وحده.
///
/// هذا الملف هو ما كشف أن `companyCode` و`workspaceSlug` لم يكونا في
/// ردّ التسجيل أصلًا، بينما يعرضهما معالج الإنشاء للمستخدم.
///
/// ⚠ يتطلّب خادمًا على `127.0.0.1:3000` وقاعدة تعمل. حين لا يتوفّران
/// **تُتجاوَز** الاختبارات ولا تفشل: مطوّر يعمل على الواجهة لا يجب أن
/// تُحمَّل عليه تهيئة خادم كي تمرّ اختباراته. التجاوز معلَن في المخرجات
/// لا صامت.
void main() {
  final baseUrl = Platform.environment['AZM_API_BASE_URL'] ??
      'http://127.0.0.1:3099';
  late bool serverUp;

  setUpAll(() async {
    serverUp = await _reachable(baseUrl);
    if (!serverUp) {
      // ignore: avoid_print
      print(
        '⏭ تُتجاوَز اختبارات العقد: لا خادم على $baseUrl. '
        'شغّله بـ`cd api && npm start` ثم أعد التشغيل.',
      );
    }
  });

  ApiClient freshClient() => ApiClient(
        tokens: _MemoryTokenStore(),
        baseUrl: baseUrl,
      );

  /// بريد فريد لكل تشغيل — الخادم يرفض المكرّر بـ٤٠٩ بحقّ.
  String uniqueEmail() =>
      'contract-${DateTime.now().microsecondsSinceEpoch}@azm.test';

  test('التسجيل يعيد جلسة كاملة — بالحقول التي يعرضها المعالج', () async {
    if (!serverUp) return;

    final api = AzmAuthApi(freshClient());
    final session = await api.registerWithCompany(
      email: uniqueEmail(),
      password: 'contract-pass-1234',
      displayName: 'مالك العقد',
      companyName: 'شركة العقد للتقنية',
    );

    expect(session.accessToken, isNotEmpty);
    expect(session.user.displayName, 'مالك العقد');
    expect(session.company.name, 'شركة العقد للتقنية');

    // الحقلان اللذان كان المعالج يولّدهما محليًا
    expect(session.company.companyCode, startsWith('CMP-'));
    expect(session.company.workspaceSlug, isNotEmpty);

    // معرّف الشركة هو اسم ملف قاعدتها المحلية
    expect(session.company.id, isNotEmpty);
  });

  test('الدخول يعيد الجلسة وقائمة العضويات', () async {
    if (!serverUp) return;

    final email = uniqueEmail();
    const password = 'contract-pass-1234';
    final api = AzmAuthApi(freshClient());

    await api.registerWithCompany(
      email: email,
      password: password,
      displayName: 'عائد',
      companyName: 'شركة العودة',
    );

    final session = await api.login(email: email, password: password);

    expect(session.accessToken, isNotEmpty);
    expect(session.company.name, 'شركة العودة');
    // `companies` تخدم مبدّل الشركات
    expect(session.companies, hasLength(1));
    expect(session.companies.single.role, 0); // مالك
    expect(session.companies.single.companyCode, startsWith('CMP-'));
  });

  test('`me` يعيد الدور من القاعدة', () async {
    if (!serverUp) return;

    final tokens = _MemoryTokenStore();
    final client = ApiClient(tokens: tokens, baseUrl: baseUrl);
    final api = AzmAuthApi(client);

    final session = await api.registerWithCompany(
      email: uniqueEmail(),
      password: 'contract-pass-1234',
      displayName: 'صاحب الدور',
      companyName: 'شركة الدور',
    );
    await tokens.save(
      token: session.accessToken,
      companyId: session.company.id,
    );

    final identity = await api.me();

    expect(identity.role, 0); // Owner
    expect(identity.companyId, session.company.id);
    expect(identity.userId, session.user.id);
    expect(identity.membershipId, isNotEmpty);
  });

  test('بريد مكرّر ⇐ AlreadyExists لا VersionConflict', () async {
    if (!serverUp) return;

    final email = uniqueEmail();
    final api = AzmAuthApi(freshClient());

    await api.registerWithCompany(
      email: email,
      password: 'contract-pass-1234',
      displayName: 'الأول',
      companyName: 'شركة الأول',
    );

    // ٤٠٩ بلا `currentVersion` — خلطها بتعارض النسخ يجعل المزامنة
    // تُسقط تعديلًا كان يجب دمجه
    await expectLater(
      api.registerWithCompany(
        email: email,
        password: 'other-pass-1234',
        displayName: 'الثاني',
        companyName: 'شركة الثاني',
      ),
      throwsA(isA<AlreadyExists>()),
    );
  });

  test('كلمة مرور خاطئة ⇐ Unauthenticated برسالة لا تكشف وجود البريد',
      () async {
    if (!serverUp) return;

    final email = uniqueEmail();
    final api = AzmAuthApi(freshClient());

    await api.registerWithCompany(
      email: email,
      password: 'contract-pass-1234',
      displayName: 'صاحب الحساب',
      companyName: 'شركة الحساب',
    );

    final wrongPassword = await _capture(
      () => api.login(email: email, password: 'wrong-pass-9999'),
    );
    final unknownEmail = await _capture(
      () => api.login(email: uniqueEmail(), password: 'contract-pass-1234'),
    );

    expect(wrongPassword, isA<Unauthenticated>());
    expect(unknownEmail, isA<Unauthenticated>());
    // الرسالة نفسها: التفريق يكشف أي البُرد مسجَّلة
    expect(wrongPassword.message, unknownEmail.message);
  });

  test('كلمة مرور قصيرة ⇐ BadRequest بأخطاء حقول', () async {
    if (!serverUp) return;

    final api = AzmAuthApi(freshClient());
    final e = await _capture(
      () => api.registerWithCompany(
        email: uniqueEmail(),
        password: 'قصيرة',
        displayName: 'أحد',
        companyName: 'شركة',
      ),
    );

    expect(e, isA<BadRequest>());
    expect((e as BadRequest).fieldErrors, isNotEmpty);
  });

  test('طلب محمي بلا رمز ⇐ Unauthenticated', () async {
    if (!serverUp) return;

    // خزانة فارغة: العميل يفشل قبل الشبكة
    await expectLater(
      AzmAuthApi(freshClient()).me(),
      throwsA(isA<Unauthenticated>()),
    );
  });
}

// ─────────────────────────────────────────────
// أدوات
// ─────────────────────────────────────────────

/// هل على [baseUrl] خادم **عزم** فعلًا؟
///
/// فحص اتصال TCP وحده لا يكفي، وهذا ليس احتمالًا نظريًا: المنفذان
/// ٣٠٠٠ و٣٠٠١ مأخوذان على جهاز التطوير بخادمَي Next، فنجح الاتصال
/// وذهبت طلبات الاختبار إلى خادم غريب ردّ ٥٠٠ — فبدا الخطأ في خادمنا.
///
/// التحقّق هنا بالبصمة: `/auth/me` محميّ بالحارس العامّ، فخادم عزم
/// يردّ عليه ٤٠١ بلا رمز. أي ردّ آخر يعني أن المنفذ ليس لنا.
Future<bool> _reachable(String baseUrl) async {
  final uri = Uri.tryParse('$baseUrl$apiPrefix/auth/me');
  if (uri == null) return false;

  final client = HttpClient()
    ..connectionTimeout = const Duration(seconds: 2);
  try {
    final response = await client.getUrl(uri).then((r) => r.close());
    await response.drain<void>();
    return response.statusCode == 401;
  } catch (_) {
    return false;
  } finally {
    client.close(force: true);
  }
}

Future<ApiException> _capture(Future<void> Function() body) async {
  try {
    await body();
  } on ApiException catch (e) {
    return e;
  }
  fail('توقّعنا ApiException ولم يُرمَ شيء');
}

/// خزانة في الذاكرة — التخزين الآمن يحتاج منصّة.
class _MemoryTokenStore extends AuthTokenStore {
  _MemoryTokenStore() : super(_UnusedStorage());

  String? _token;
  String? _companyId;

  @override
  Future<String?> readToken() async => _token;

  @override
  Future<String?> readCompanyId() async => _companyId;

  @override
  Future<void> save({required String token, required String companyId}) async {
    _token = token;
    _companyId = companyId;
  }

  @override
  Future<void> clear() async {
    _token = null;
    _companyId = null;
  }

  @override
  Future<bool> get hasSession async => _token != null;
}

class _UnusedStorage implements SecureStorageService {
  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw StateError('لا يجوز أن يصل الاختبار إلى التخزين الآمن');
}
