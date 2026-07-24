import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../constants/app_constants.dart';
import '../constants/enums.dart';
import '../database/app_database.dart';
import '../database/dao/security_logs_dao.dart';

/// Security Logger — records all security-sensitive actions.
///
/// Append-only log that cannot be cleared from the UI.
/// Automatically trims entries beyond [AppConstants.maxSecurityLogEntries].
class SecurityLogger {
  final SecurityLogsDao _dao;

  SecurityLogger(this._dao);

  static const _uuid = Uuid();

  /// Log a security action
  Future<void> log(
    SecurityAction action, {
    String? details,
    String? deviceInfo,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await _dao.insertLog(
      SecurityLogsCompanion.insert(
        syncId: _uuid.v4(),
        action: action.value,
        details: Value(details),
        deviceInfo: Value(deviceInfo),
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Trim old entries periodically
    await _dao.trimOldEntries(AppConstants.maxSecurityLogEntries);
  }

  /// Log a successful login
  Future<void> logLogin({String? method}) =>
      log(SecurityAction.login, details: 'طريقة الدخول: $method');

  /// Log a failed login attempt
  Future<void> logFailedLogin({String? reason}) =>
      log(SecurityAction.failedLogin, details: reason);

  /// Log app lock
  Future<void> logAppLocked() => log(SecurityAction.appLocked);

  /// Log app unlock
  Future<void> logAppUnlocked() => log(SecurityAction.appUnlocked);

  /// Log record deletion
  Future<void> logRecordDeleted(String recordType, int recordId) =>
      log(SecurityAction.deleteRecord,
          details: 'حذف $recordType رقم $recordId');

  /// Log data export
  Future<void> logDataExport(String exportType) =>
      log(SecurityAction.exportData, details: 'تصدير $exportType');

  /// Log backup creation
  Future<void> logBackupCreated() => log(SecurityAction.backupCreated);

  /// Log backup restoration
  Future<void> logBackupRestored() => log(SecurityAction.backupRestored);

  /// Log settings change
  Future<void> logSettingsChanged(String setting) =>
      log(SecurityAction.settingsChanged, details: 'تعديل: $setting');

  /// Get recent failed login count (for lockout logic)
  Future<int> getRecentFailedLoginCount() {
    final threshold = DateTime.now()
        .subtract(Duration(minutes: AppConstants.lockoutMinutes))
        .millisecondsSinceEpoch;
    return _dao.countRecentFailedLogins(threshold);
  }
}