/// App-wide constants for the RVIOS Platform
///
/// Centralized configuration values — no magic numbers.
class AppConstants {
  AppConstants._();

  // ─────────────────────────────────────────────
  // App Info
  // ─────────────────────────────────────────────

  static const String appName = 'RVIOS';
  static const String appNameAr = 'منصة أعمال';
  static const String appNameEn = 'RVIOS';
  static const String appVersion = '1.0.0';
  static const String appDescription = 'One Platform. Complete Business Management.';
  static const String appDescriptionAr = 'منصة إدارة الأعمال المتكاملة';
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