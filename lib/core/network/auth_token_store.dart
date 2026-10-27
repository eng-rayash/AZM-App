import '../security/secure_storage_service.dart';

/// AZM — خزانة رمز الجلسة
///
/// الرمز في التخزين الآمن (سلسلة مفاتيح iOS / تفضيلات مشفَّرة على
/// أندرويد) لا في `SharedPreferences`. الفارق ليس شكليًا:
/// `SharedPreferences` ملفّ XML عادي يقرؤه أي تطبيق بصلاحية root أو
/// نسخة احتياطية غير مشفَّرة، والرمز يكفي لانتحال الجلسة كاملة.
///
/// ما يُحفظ هنا: الرمز، ومعرّف الشركة النشطة في الجلسة. وما لا يُحفظ:
/// الدور. الدور يُقرأ من الخادم في كل طلب — رمز صالح لأسبوع لا يجوز
/// أن يحمل صلاحية سُحبت أمس.
class AuthTokenStore {
  AuthTokenStore([SecureStorageService? storage])
      : _storage = storage ?? SecureStorageService.instance;

  final SecureStorageService _storage;

  static const _tokenKey = 'azm.access_token';
  static const _companyKey = 'azm.session_company';

  /// رمز الجلسة، أو `null` إن لم يُسجَّل دخول.
  Future<String?> readToken() => _storage.read(_tokenKey);

  /// الشركة التي أُصدر الرمز لها.
  Future<String?> readCompanyId() => _storage.read(_companyKey);

  /// يحفظ رمزًا جديدًا مع شركته.
  ///
  /// الاثنان معًا في نداء واحد: رمز بلا شركته لا يُعرف لأي مستأجر
  /// يصلح، فيُفتح ملف قاعدة خطأ. الضمّ يمنع حالة نصفية.
  Future<void> save({
    required String token,
    required String companyId,
  }) async {
    await _storage.write(_tokenKey, token);
    await _storage.write(_companyKey, companyId);
  }

  /// يمحو الجلسة — الخروج، أو ردّ ٤٠١.
  ///
  /// البيانات المحلية **لا تُمحى** معها: المستخدم قد يخرج ويعود، أو
  /// يكون خروجه لأن الرمز انتهى لا لأنه أراد. محو قاعدة الشركة هنا
  /// يُفقد تعديلات لم تُزامَن بعد.
  Future<void> clear() async {
    await _storage.delete(_tokenKey);
    await _storage.delete(_companyKey);
  }

  Future<bool> get hasSession async => (await readToken()) != null;
}
