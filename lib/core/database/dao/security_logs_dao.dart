import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/security_logs_table.dart';

part 'security_logs_dao.g.dart';

/// Data Access Object for Security Logs — append-only audit trail.
///
/// Security logs cannot be deleted from the UI. Only the system
/// can trim old entries beyond [AppConstants.maxSecurityLogEntries].
@DriftAccessor(tables: [SecurityLogs])
class SecurityLogsDao extends DatabaseAccessor<AppDatabase>
    with _$SecurityLogsDaoMixin {
  SecurityLogsDao(super.db);

  /// Insert a new security log entry
  Future<int> insertLog(SecurityLogsCompanion log) =>
      into(securityLogs).insert(log);

  /// Get all logs, newest first
  Future<List<SecurityLog>> getAll({int limit = 100}) => (select(securityLogs)
        ..orderBy([(l) => OrderingTerm.desc(l.createdAt)])
        ..limit(limit))
      .get();

  /// Watch all logs (reactive)
  Stream<List<SecurityLog>> watchAll({int limit = 100}) =>
      (select(securityLogs)
            ..orderBy([(l) => OrderingTerm.desc(l.createdAt)])
            ..limit(limit))
          .watch();

  /// Get logs by action type
  Future<List<SecurityLog>> getByAction(int action) => (select(securityLogs)
        ..where((l) => l.action.equals(action))
        ..orderBy([(l) => OrderingTerm.desc(l.createdAt)]))
      .get();

  /// Get recent failed login attempts (for lockout logic)
  Future<int> countRecentFailedLogins(int sinceTimestamp) async {
    final count = await (selectOnly(securityLogs)
          ..addColumns([securityLogs.id.count()])
          ..where(securityLogs.action.equals(1) & // failedLogin
              securityLogs.createdAt.isBiggerOrEqualValue(sinceTimestamp)))
        .map((row) => row.read(securityLogs.id.count()))
        .getSingle();
    return count ?? 0;
  }

  /// Trim old entries, keeping only the most recent N entries
  Future<void> trimOldEntries(int maxEntries) async {
    final count = await (selectOnly(securityLogs)
          ..addColumns([securityLogs.id.count()]))
        .map((row) => row.read(securityLogs.id.count()))
        .getSingle();

    if ((count ?? 0) > maxEntries) {
      final idsToKeep = await (selectOnly(securityLogs)
            ..addColumns([securityLogs.id])
            ..orderBy([OrderingTerm.desc(securityLogs.createdAt)])
            ..limit(maxEntries))
          .map((row) => row.read(securityLogs.id)!)
          .get();

      if (idsToKeep.isNotEmpty) {
        await (delete(securityLogs)
              ..where((l) => l.id.isNotIn(idsToKeep)))
            .go();
      }
    }
  }
}