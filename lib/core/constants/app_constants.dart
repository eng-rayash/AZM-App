/// App-wide constants for the Mudiri Application
///
/// Centralized configuration values — no magic numbers.
class AppConstants {
  AppConstants._();

  // ─────────────────────────────────────────────
  // App Info
  // ─────────────────────────────────────────────

  static const String appName = 'مديري';
  static const String appNameEn = 'Mudiri';
  static const String appVersion = '0.1.0';
  static const String appDescription = 'نظام إدارة تنفيذي احترافي';

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

  static const String dbName = 'mudiri.db';
  static const int dbVersion = 5;

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
}
