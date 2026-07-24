import 'package:drift/drift.dart';
import '../base_table.dart';

/// RVIOS — Audit Logs Table
///
/// Records every significant action taken on the platform for compliance,
/// security, and accountability. Available on Business+ and Enterprise plans.
///
/// Schema added in v11.
class AuditLogs extends Table with BaseTableMixin {
  // ── Who ──────────────────────────────────────────────────────────

  /// Actor: user who performed the action (FK → users.sync_id)
  TextColumn get actorSyncId => text()();

  /// Tenant: company context (FK → companies.sync_id)
  TextColumn get companySyncId => text()();

  // ── What ─────────────────────────────────────────────────────────

  /// Action category, e.g. "user.login", "invoice.created", "employee.deleted"
  TextColumn get action => text()();

  /// Entity type affected, e.g. "invoice", "employee", "meeting"
  TextColumn get entityType => text().nullable()();

  /// Entity ID (sync_id of the affected record)
  TextColumn get entitySyncId => text().nullable()();

  /// Human-readable description of what changed
  TextColumn get description => text().nullable()();

  // ── Change Details ───────────────────────────────────────────────

  /// Previous state (JSON) — for update/delete actions
  TextColumn get oldValueJson => text().nullable()();

  /// New state (JSON) — for create/update actions
  TextColumn get newValueJson => text().nullable()();

  // ── Context ──────────────────────────────────────────────────────

  /// IP address of the request (stored as text for IPv4 + IPv6 support)
  TextColumn get ipAddress => text().nullable()();

  /// Device / user agent info
  TextColumn get deviceInfo => text().nullable()();

  /// Platform: "web", "android", "ios", "windows"
  TextColumn get platform => text().nullable()();

  /// Severity:
  ///   0 = info
  ///   1 = warning
  ///   2 = critical
  IntColumn get severity => integer().withDefault(const Constant(0))();
}