import 'package:drift/drift.dart';
import '../base_table.dart';

/// RVIOS — Employee Invitations Table
///
/// Stores pending invitations sent by company admins to employees.
/// Tokens are used for secure one-time activation of accounts.
///
/// Schema added in v11.
class Invitations extends Table with BaseTableMixin {
  // ── References ──────────────────────────────────────────────────

  /// The company sending this invitation (FK → companies.sync_id)
  TextColumn get companySyncId => text().withLength(min: 36, max: 36)();

  /// Who sent the invitation (FK → users.sync_id)
  TextColumn get invitedBySyncId => text().withLength(min: 36, max: 36)();

  // ── Invitation Details ───────────────────────────────────────────

  /// Unique token for the invitation link (UUID v4)
  TextColumn get token => text().withLength(min: 36, max: 36)();

  /// Target employee email (for email-based invitations)
  TextColumn get email => text().nullable()();

  /// Pre-assigned username (for code-based onboarding)
  TextColumn get preAssignedUsername => text().nullable()();

  /// Pre-assigned temporary password (hashed, for code-based onboarding)
  TextColumn get tempPasswordHash => text().nullable()();

  /// Human-readable Employee Code generated at invite time, e.g. "EMP-00215"
  TextColumn get employeeCode => text().nullable()();

  // ── Role / Position ──────────────────────────────────────────────

  /// Role to assign when invitation is accepted (mirrors CompanyMembers.role)
  IntColumn get role => integer().withDefault(const Constant(8))();

  /// Department (FK → departments.sync_id), optional
  TextColumn get departmentSyncId => text().nullable()();

  /// Position (FK → positions.sync_id), optional
  TextColumn get positionSyncId => text().nullable()();

  // ── Status ───────────────────────────────────────────────────────

  /// Status:
  ///   0 = pending
  ///   1 = accepted
  ///   2 = expired
  ///   3 = cancelled
  IntColumn get status => integer().withDefault(const Constant(0))();

  /// When this invitation expires
  DateTimeColumn get expiresAt => dateTime()();

  /// When the invitation was accepted/used
  DateTimeColumn get usedAt => dateTime().nullable()();

  /// The user account created from this invitation (FK → users.sync_id)
  TextColumn get resultingUserSyncId => text().nullable()();

  @override
  List<String> get customConstraints => [
        'UNIQUE(token)',
      ];
}