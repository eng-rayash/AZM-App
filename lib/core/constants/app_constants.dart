/// App-wide constants for AZM — عزم
///
/// Centralized configuration values — no magic numbers.
class AppConstants {
  AppConstants._();

  // ─────────────────────────────────────────────
  // App Info
  // ─────────────────────────────────────────────
  //
  // عزم منتج مستقل تحت مظلة RVIOS Technologies. اسم المنتج هو ما يراه
  // المستخدم؛ واسم الشركة يظهر في الحقوق والوثائق القانونية وحدها.

  /// اسم المنتج كما يُعرض للمستخدم
  static const String appName = 'عزم';

  static const String appNameAr = 'عزم';
  static const String appNameEn = 'AZM';

  /// الشركة المالكة — المظلة، لا المنتج
  static const String companyName = 'RVIOS Technologies';

  static const String appVersion = '1.0.0';

  /// الفلسفة الداخلية للمنتج — دورة: فهم ← قرار ← تنفيذ
  static const String appDescription = 'Understand. Decide. Execute.';
  static const String appDescriptionAr = 'نظام تشغيل الأعمال الذكي';

  /// سطر العلامة الكامل
  static const String appTagline = 'افهم عملك · احسم ما يهم · نفّذ بعزم';

  /// النطاق والدعم — بنية RVIOS Technologies القائمة.
  /// نطاق خاص بـعزم قرارُ منتج لم يُحسم بعد؛ حتى ذلك الحين تبقى هذه
  /// القيم كما هي لأنها تشير إلى بنية تعمل فعلًا.
  static const String appDomain = 'rvios.com';
  static const String appWebUrl = 'https://app.rvios.com';
  static const String appSupportEmail = 'support@rvios.com';

  // ─────────────────────────────────────────────
  // Security
  // ─────────────────────────────────────────────

  /// Auto-lock after N seconds of inactivity
  static const int lockAfterSeconds = 60;

  /// Maximum wrong PIN attempts before lockout
  static const int maxWrongAttempts = 5;

  /// Lockout duration in minutes after max attempts
  static const int lockoutMinutes = 10;

  /// Require authentication on app start
  static const bool requireAuthOnStart = true;

  /// PIN code length
  static const int pinLength = 6;

  /// Database encryption key storage key
  static const String dbEncryptionKeyName = 'db_encryption_key';

  /// PIN hash storage key
  static const String pinHashKeyName = 'pin_hash';

  /// Auth method preference key
  static const String authMethodKeyName = 'auth_method';

  /// First launch flag key
  static const String isFirstLaunchKey = 'is_first_launch';

  // ─────────────────────────────────────────────
  // Database
  // ─────────────────────────────────────────────

  static const String dbName = 'rvios.db';
  static const int dbVersion = 10;


  // ─────────────────────────────────────────────
  // Security Log
  // ─────────────────────────────────────────────

  /// Maximum security log entries to keep
  static const int maxSecurityLogEntries = 500;

  // ─────────────────────────────────────────────
  // Pagination
  // ─────────────────────────────────────────────

  static const int defaultPageSize = 20;

  // ─────────────────────────────────────────────
  // Animation
  // ─────────────────────────────────────────────

  static const Duration splashDuration = Duration(milliseconds: 1500);
  static const Duration shortAnimation = Duration(milliseconds: 150);
  static const Duration mediumAnimation = Duration(milliseconds: 300);
  static const Duration longAnimation = Duration(milliseconds: 500);

  // ─────────────────────────────────────────────
  // RVIOS — Multi-Tenant & Accounts
  // ─────────────────────────────────────────────

  /// Prefix for generated Company IDs  e.g. CMP-8X7Q2K
  static const String companyIdPrefix = 'CMP';

  /// Prefix for generated Employee IDs  e.g. EMP-00215
  static const String employeeIdPrefix = 'EMP';

  /// Length of random part in Company/Employee codes
  static const int codeRandomLength = 6;

  /// Trial period in days for new companies
  static const int trialDays = 30;

  /// Max users per Business plan
  static const int businessPlanMaxUsers = 20;

  /// Max users per Business Plus plan
  static const int businessPlusPlanMaxUsers = 100;
}