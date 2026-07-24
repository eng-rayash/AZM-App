import 'package:drift/drift.dart';
import '../base_table.dart';

/// RVIOS — Company Members Table
///
/// Links users to companies with their roles and permissions.
/// A user can belong to multiple companies (e.g. a consultant).
///
/// Schema added in v11.
class CompanyMembers extends Table with BaseTableMixin {
  // ── References ──────────────────────────────────────────────────

  /// The company this membership belongs to (FK → companies.sync_id)
  TextColumn get companySyncId => text().withLength(min: 36, max: 36)();

  /// The user this membership belongs to (FK → users.sync_id)
  TextColumn get userSyncId => text().withLength(min: 36, max: 36)();

  /// Corresponding employee record (FK → employees.sync_id), if any
  TextColumn get employeeSyncId => text().nullable()();

  // ── Role / Access ────────────────────────────────────────────────

  /// Role within the company:
  ///   0 = owner
  ///   1 = super_admin
  ///   2 = admin
  ///   3 = executive_manager
  ///   4 = hr_manager
  ///   5 = finance_manager
  ///   6 = department_manager
  ///   7 = team_leader
  ///   8 = employee
  ///   9 = guest
  IntColumn get role => integer().withDefault(const Constant(8))();

  /// Whether this membership is currently active
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  /// When the user first joined/activated their account
  DateTimeColumn get joinedAt => dateTime().nullable()();

  /// Whether the user has completed first-time onboarding wizard
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();

  // ── Permissions ──────────────────────────────────────────────────

  /// JSON blob for fine-grained module permissions override
  /// e.g. {"finance": {"read": true, "write": false}}
  TextColumn get permissionsJson => text().nullable()();

  /// List of enabled modules for this user (comma-separated keys)
  /// Overrides company-level defaults if set
  TextColumn get enabledModules => text().nullable()();

  @override
  List<String> get customConstraints => [
        'UNIQUE(company_sync_id, user_sync_id)',
      ];
}