import '../../../core/network/api_client.dart';

/// AZM — المصادقة على الخادم
///
/// يستبدل مسار Supabase لإنشاء الحساب والشركة. الفارق الجوهري ليس
/// الخادم بل ما يحدث: `_createCompany` في معالج الإنشاء كان
/// `Future.delayed` ثم عرض كود مولَّد — أربع خطوات يكملها المستخدم
/// فيخرج بكود لشركة غير موجودة في أي قاعدة.
///
/// الآن `POST /auth/register` ينشئ المستخدم والشركة وعضوية المالك في
/// **معاملة واحدة**: مستخدم بلا شركة لا يستطيع شيئًا، وشركة بلا مالك
/// لا يملك أحد إدارتها.
class AzmAuthApi {
  AzmAuthApi(this._client);

  final ApiClient _client;

  /// ينشئ حسابًا وشركةً ويعيد جلسة جاهزة.
  ///
  /// `authenticated: false` لأن المسار عامّ — ولولاها لطُلب رمز لا
  /// يوجد بعد، وفشل الطلب قبل أن يصل.
  Future<AuthSession> registerWithCompany({
    required String email,
    required String password,
    required String displayName,
    required String companyName,
  }) =>
      _client.post(
        '/auth/register',
        authenticated: false,
        body: {
          'email': email.trim(),
          'password': password,
          'displayName': displayName.trim(),
          'companyName': companyName.trim(),
        },
        decode: (json) => AuthSession.fromJson(json as Map<String, dynamic>),
      );

  /// يسجّل الدخول.
  ///
  /// [companyId] يُرسل حين ينتمي المستخدم لأكثر من شركة. تركه يجعل
  /// الخادم يختار أول عضوية فعّالة.
  Future<AuthSession> login({
    required String email,
    required String password,
    String? companyId,
  }) =>
      _client.post(
        '/auth/login',
        authenticated: false,
        body: {
          'email': email.trim(),
          'password': password,
          'companyId': ?companyId,
        },
        decode: (json) => AuthSession.fromJson(json as Map<String, dynamic>),
      );

  /// من أنا في الشركة النشطة — والدور من القاعدة لا من الرمز.
  Future<SessionIdentity> me() => _client.get(
        '/auth/me',
        decode: (json) =>
            SessionIdentity.fromJson(json as Map<String, dynamic>),
      );
}

/// جلسة ناتجة عن تسجيل أو دخول.
class AuthSession {
  const AuthSession({
    required this.accessToken,
    required this.user,
    required this.company,
    this.companies = const [],
  });

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        accessToken: json['accessToken'] as String,
        user: AuthUser.fromJson(json['user'] as Map<String, dynamic>),
        company: AuthCompany.fromJson(json['company'] as Map<String, dynamic>),
        companies: (json['companies'] as List<dynamic>? ?? const [])
            .map((c) => AuthCompany.fromJson(c as Map<String, dynamic>))
            .toList(),
      );

  final String accessToken;
  final AuthUser user;

  /// الشركة التي أُصدر الرمز لها — وهي التي يُفتح ملف قاعدتها.
  final AuthCompany company;

  /// بقية عضويات المستخدم، لمبدّل الشركات.
  final List<AuthCompany> companies;
}

class AuthUser {
  const AuthUser({
    required this.id,
    required this.email,
    required this.displayName,
    this.avatarUrl,
  });

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: json['id'] as String,
        email: json['email'] as String,
        displayName: json['displayName'] as String,
        avatarUrl: json['avatarUrl'] as String?,
      );

  final String id;
  final String email;
  final String displayName;
  final String? avatarUrl;
}

class AuthCompany {
  const AuthCompany({
    required this.id,
    required this.name,
    required this.companyCode,
    required this.workspaceSlug,
    this.trialEndsAt,
    this.role,
  });

  factory AuthCompany.fromJson(Map<String, dynamic> json) => AuthCompany(
        id: json['id'] as String,
        name: json['name'] as String,
        companyCode: json['companyCode'] as String? ?? '',
        workspaceSlug: json['workspaceSlug'] as String? ?? '',
        trialEndsAt: _parseDate(json['trialEndsAt']),
        role: json['role'] as int?,
      );

  /// معرّف الشركة — وهو أيضًا اسم ملف قاعدتها المحلية.
  final String id;
  final String name;

  /// كود الانضمام الذي يعطيه المالك لمن يدعوه.
  ///
  /// يأتي من الخادم لا يُولَّد محليًا: كود يولّده العميل لا يعرفه
  /// الخادم، ولا ينضمّ به أحد.
  final String companyCode;

  /// عنوان مساحة العمل.
  final String workspaceSlug;

  final DateTime? trialEndsAt;

  /// الدور في هذه الشركة — يرسله الخادم في قائمة `companies` فقط.
  final int? role;
}

/// يفكّ تاريخ ISO متسامحًا: حقل غائب أو مشوَّه يعيد `null` لا يرمي.
///
/// تاريخ انتهاء التجربة ليس حرجًا بما يبرّر إفشال تسجيل الدخول كلّه.
DateTime? _parseDate(dynamic raw) {
  if (raw is! String || raw.isEmpty) return null;
  return DateTime.tryParse(raw);
}

/// ردّ `/auth/me`.
class SessionIdentity {
  const SessionIdentity({
    required this.userId,
    required this.companyId,
    required this.role,
    required this.membershipId,
  });

  factory SessionIdentity.fromJson(Map<String, dynamic> json) =>
      SessionIdentity(
        userId: json['userId'] as String,
        companyId: json['companyId'] as String,
        role: json['role'] as int,
        membershipId: json['membershipId'] as String,
      );

  final String userId;
  final String companyId;

  /// الدور كما قرأه الخادم من القاعدة في **هذا** الطلب.
  ///
  /// يُستخدم لرسم الواجهة لا لحراستها: الحراسة على الخادم في
  /// `TenantGuard` على كل مسار.
  final int role;
  final String membershipId;
}
