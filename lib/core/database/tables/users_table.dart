import 'package:drift/drift.dart';

import 'base_table.dart';

/// RVIOS — Users Table
///
/// Stores user profile, authentication credentials, and account context.
/// Updated in v11 for RVIOS Multi-Tenant support.
///
/// A user can be:
///   - A solo personal user (account_type = 0 or 1)
///   - An owner who created a company (account_type = 2 or 3)
///   - An employee who joined a company via invitation
class Users extends Table with BaseTableMixin {
  // ── Identity ────────────────────────────────────────────────────

  /// Display name shown on dashboard
  TextColumn get displayName => text().withLength(min: 1, max: 100)();

  /// First name
  TextColumn get firstName => text().nullable()();

  /// Last name / family name
  TextColumn get lastName => text().nullable()();

  /// Username for login (unique, e.g. "ahmed.saleh")
  TextColumn get username => text().nullable()();

  /// Email address (used for cloud auth + invitations)
  TextColumn get email => text().nullable()();

  /// Hashed password for cloud authentication (bcrypt)
  TextColumn get passwordHash => text().nullable()();

  /// Phone number
  TextColumn get phone => text().nullable()();

  // ── Account Type ────────────────────────────────────────────────

  /// Account type:
  ///   0 = free_personal
  ///   1 = professional (solo business)
  ///   2 = business (company owner/member)
  ///   3 = enterprise
  IntColumn get accountType => integer().withDefault(const Constant(0))();

  // ── Company / Tenant Context ─────────────────────────────────────

  /// The company this user currently operates in (FK → companies.sync_id)
  /// Null for personal-only accounts
  TextColumn get activeCompanySyncId => text().nullable()();

  /// Employee code assigned by the company, e.g. "EMP-00215"
  TextColumn get employeeCode => text().nullable()();

  /// Workspace slug for quick login (matches companies.workspace_slug)
  TextColumn get workspaceSlug => text().nullable()();

  // ── Local Authentication (PIN + Biometric) ───────────────────────

  /// Hashed PIN code (never stored in plain text)
  TextColumn get pinHash => text().nullable()();

  /// Preferred authentication method (biometric=0, pin=1, password=2)
  IntColumn get authMethod => integer().withDefault(const Constant(0))();

  /// Whether biometric authentication is enabled
  BoolColumn get isBiometricEnabled =>
      boolean().withDefault(const Constant(false))();

  // ── Profile ──────────────────────────────────────────────────────

  /// Local avatar image path (for offline/desktop)
  TextColumn get avatarPath => text().nullable()();

  /// Cloud avatar URL (Supabase Storage / S3)
  TextColumn get avatarUrl => text().nullable()();

  /// User's preferred language ("ar" or "en")
  TextColumn get language => text().withDefault(const Constant('ar'))();

  /// User's timezone (IANA, e.g. "Asia/Riyadh")
  TextColumn get timezone =>
      text().withDefault(const Constant('Asia/Riyadh'))();

  /// User's country code (ISO 3166-1 alpha-2)
  TextColumn get country => text().nullable()();

  // ── Onboarding ───────────────────────────────────────────────────

  /// Whether the user completed the first-time setup wizard
  BoolColumn get onboardingCompleted =>
      boolean().withDefault(const Constant(false))();

  /// Whether the user must change their password on next login
  BoolColumn get mustChangePassword =>
      boolean().withDefault(const Constant(false))();

  // ── Cloud Sync ───────────────────────────────────────────────────

  /// Supabase Auth UID (from auth.users table)
  TextColumn get supabaseUid => text().nullable()();

  /// Last time this user's data was synced to the cloud
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}
