import 'package:drift/drift.dart';

import 'base_table.dart';

/// Security Logs table — append-only audit trail.
///
/// Records all security-sensitive actions. Cannot be deleted from the UI.
/// Retains the last [AppConstants.maxSecurityLogEntries] entries.
class SecurityLogs extends Table with BaseTableMixin {
  /// Action type (login=0, failedLogin=1, exportData=7, etc.)
  IntColumn get action => integer()();

  /// Action details (human-readable description)
  TextColumn get details => text().nullable()();

  /// Device information (model, OS version)
  TextColumn get deviceInfo => text().nullable()();

  /// IP address (for future sync scenarios)
  TextColumn get ipAddress => text().nullable()();
}