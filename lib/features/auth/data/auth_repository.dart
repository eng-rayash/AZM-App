import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/api/api_client.dart';

/// حساب المستخدم في النظام الموحّد — نفسه الذي يدخل به منصة عزم سمارت على الويب.
class AzmAccount {
  const AzmAccount({required this.id, required this.email, required this.displayName, this.avatarUrl});

  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;

  factory AzmAccount.fromJson(Map<String, dynamic> j) => AzmAccount(
        id: j['id'] as String,
        email: (j['email'] as String?) ?? '',
        displayName: (j['displayName'] as String?) ?? '',
        avatarUrl: j['avatarUrl'] as String?,
      );

  Map<String, dynamic> toJson() => {'id': id, 'email': email, 'displayName': displayName, 'avatarUrl': avatarUrl};
}

/// شركة ينتمي إليها المستخدم. `role` رقم الدور في الخادم (0 مالك … 9 ضيف).
class AzmCompany {
  const AzmCompany({required this.id, required this.name, this.role});

  final String id;
  final String name;
  final int? role;

  factory AzmCompany.fromJson(Map<String, dynamic> j) => AzmCompany(
        id: j['id'] as String,
        name: (j['name'] as String?) ?? '',
        role: (j['role'] as num?)?.toInt(),
      );

  Map<String, dynamic> toJson() => {'id': id, 'name': name, 'role': role};
}

/// جلسة قائمة: من المستخدم، وفي أي شركة، وبأي دور.
class AzmSession {
  const AzmSession({
    required this.account,
    required this.company,
    required this.role,
    this.companies = const [],
    this.offline = false,
  });

  final AzmAccount account;
  final AzmCompany company;
  final int role;

  /// كل شركات المستخدم — يُملأ عند الدخول، وفارغ عند استعادة الجلسة.
  final List<AzmCompany> companies;

  /// استُعيدت من نسخة الجهاز لأن الخادم لم يُطَل — تعمل البيانات المحلية،
  /// وتنتظر المزامنة والتحقق حتى يعود الاتصال.
  final bool offline;

  Map<String, dynamic> toJson() => {'account': account.toJson(), 'company': company.toJson(), 'role': role};

  factory AzmSession.fromJson(Map<String, dynamic> j, {bool offline = false}) => AzmSession(
        account: AzmAccount.fromJson(j['account'] as Map<String, dynamic>),
        company: AzmCompany.fromJson(j['company'] as Map<String, dynamic>),
        role: (j['role'] as num).toInt(),
        offline: offline,
      );
}

/// المصادقة عبر الباكند الموحّد (بريد وكلمة مرور → رمز JWT).
///
/// الرمز في التخزين الآمن ([TokenStore])، والجلسة تُستعاد عند الإقلاع بسؤال
/// الخادم (`GET /auth/context`) لا بالثقة في رمز محفوظ: حساب أوقفه مدير
/// الشركة يخرج من التطبيق في الإقلاع التالي.
///
/// ووضع الضيف (بلا حساب، على الجهاز وحده) باقٍ كما هو.
class AuthRepository {
  AuthRepository([ApiClient? api]) : _api = api ?? ApiClient();

  static const _guestKey = 'rvios_guest_mode';
  static const _sessionKey = 'azm.lastSession';
  final ApiClient _api;

  ApiClient get api => _api;

  // ── وضع الضيف ────────────────────────────────────────────

  Future<bool> isGuestModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guestKey) ?? false;
  }

  Future<void> setGuestMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestKey, value);
  }

  // ── الجلسة ───────────────────────────────────────────────

  /// يستعيد الجلسة من الرمز المحفوظ، أو `null` إن لم يوجد أو رفضه الخادم.
  ///
  /// انقطاع الإنترنت ليس خروجًا من الحساب: حين لا يُطال الخادم تُستعاد آخر
  /// جلسة محفوظة على الجهاز (`offline`) — التطبيق يعمل على بياناته المحلية.
  /// أما رفض الخادم للرمز (٤٠١) فخروج فعلي يمسح الرمز والنسخة معًا.
  Future<AzmSession?> restore() async {
    if (await _api.tokens.read() == null) return null;
    try {
      final ctx = await _api.get('/auth/context');
      final session = AzmSession(
        account: AzmAccount.fromJson(ctx['user'] as Map<String, dynamic>),
        company: AzmCompany.fromJson(ctx['company'] as Map<String, dynamic>),
        role: (ctx['role'] as num).toInt(),
      );
      await _remember(session);
      return session;
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        await signOut();
        return null;
      }
      if (e.isNetwork) {
        final cached = await _cached();
        if (cached != null) return cached;
      }
      rethrow;
    }
  }

  Future<AzmSession> signIn({required String email, required String password, String? companyId}) async {
    final r = await _api.post('/auth/login', {
      'email': email,
      'password': password,
      'companyId': ?companyId,
    });
    return _open(r);
  }

  /// حساب جديد وشركته معًا — كما في التسجيل من الويب.
  Future<AzmSession> signUp({
    required String email,
    required String password,
    required String displayName,
    required String companyName,
  }) async {
    final r = await _api.post('/auth/register', {
      'email': email,
      'password': password,
      'displayName': displayName,
      'companyName': companyName,
    });
    return _open(r, ownerOfNewCompany: true);
  }

  /// ينتقل إلى شركة أخرى ينتمي إليها المستخدم (رمز جديد لتلك الشركة).
  Future<AzmSession> switchCompany(String companyId) async {
    final r = await _api.post('/auth/switch', {'companyId': companyId});
    await _api.tokens.write(r['accessToken'] as String);
    final session = await restore();
    if (session == null) throw const ApiException('تعذّر فتح الشركة المختارة.');
    return session;
  }

  Future<void> signOut() async {
    await setGuestMode(false);
    await _api.tokens.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_sessionKey);
  }

  /// نسخة الجلسة على الجهاز — هوية للعرض فقط، لا صلاحية: الخادم يعيد
  /// التحقق من الرمز في كل طلب حين يعود الاتصال.
  Future<void> _remember(AzmSession s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_sessionKey, jsonEncode(s.toJson()));
  }

  Future<AzmSession?> _cached() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionKey);
    if (raw == null) return null;
    try {
      return AzmSession.fromJson(jsonDecode(raw) as Map<String, dynamic>, offline: true);
    } catch (_) {
      return null;
    }
  }

  /// لا استعادة لكلمة المرور بالبريد في النظام بعد — يعيد مدير الشركة ضبطها.
  Future<void> sendPasswordReset(String email) async {
    throw const ApiException(
      'استعادة كلمة المرور غير متاحة من التطبيق بعد — اطلب من مدير شركتك إعادة ضبطها.',
    );
  }

  Future<AzmSession> _open(Map<String, dynamic> r, {bool ownerOfNewCompany = false}) async {
    await _api.tokens.write(r['accessToken'] as String);
    await setGuestMode(false);
    final company = AzmCompany.fromJson(r['company'] as Map<String, dynamic>);
    final companies = (r['companies'] as List?)
            ?.map((c) => AzmCompany.fromJson(c as Map<String, dynamic>))
            .toList() ??
        [company];
    final role = ownerOfNewCompany
        ? 0
        : companies.firstWhere((c) => c.id == company.id, orElse: () => company).role ?? 8;
    final session = AzmSession(
      account: AzmAccount.fromJson(r['user'] as Map<String, dynamic>),
      company: company,
      role: role,
      companies: companies,
    );
    await _remember(session);
    return session;
  }
}
