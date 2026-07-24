import 'package:drift/drift.dart';
import '../base_table.dart';

/// RVIOS — Companies (Tenants) Table
///
/// Each row represents one company/organization registered on RVIOS.
/// This is the core multi-tenant anchor — every piece of data is
/// scoped to a company via [companyId] FK in related tables.
///
/// Schema added in v11.
class Companies extends Table with BaseTableMixin {
  // ── Identity ────────────────────────────────────────────────────

  /// Human-readable code shown to users, e.g. "CMP-8X7Q2K"
  TextColumn get companyCode => text().withLength(min: 3, max: 20)();

  /// Display name of the company
  TextColumn get name => text().withLength(min: 1, max: 200)();

  /// Slug used for workspace URL: {slug}.rvios.com or app.rvios.com/{slug}
  /// Unique, lowercase, URL-safe
  TextColumn get workspaceSlug => text().withLength(min: 2, max: 50)();

  // ── Subscription / Plan ─────────────────────────────────────────

  /// Plan type enum:
  ///   0 = free_personal
  ///   1 = professional
  ///   2 = business
  ///   3 = business_plus
  ///   4 = enterprise
  IntColumn get planType => integer().withDefault(const Constant(0))();

  /// Subscription status:
  ///   0 = trial
  ///   1 = active
  ///   2 = suspended
  ///   3 = cancelled
  IntColumn get subscriptionStatus => integer().withDefault(const Constant(0))();

  /// When the trial period ends (nullable = no trial)
  DateTimeColumn get trialEndsAt => dateTime().nullable()();

  /// When the current subscription period ends
  DateTimeColumn get subscriptionEndsAt => dateTime().nullable()();

  // ── Owner ────────────────────────────────────────────────────────

  /// syncId of the user who created/owns this company
  TextColumn get ownerSyncId => text().withLength(min: 36, max: 36)();

  // ── Company Details ──────────────────────────────────────────────

  /// Country code (ISO 3166-1 alpha-2), e.g. "SA", "AE", "EG"
  TextColumn get country => text().withLength(min: 2, max: 2).nullable()();

  /// Currency code (ISO 4217), e.g. "SAR", "AED", "USD"
  TextColumn get currency => text().withLength(min: 3, max: 3).nullable()();

  /// Industry / sector
  TextColumn get industry => text().nullable()();

  /// Expected/actual number of employees (for plan sizing)
  IntColumn get expectedEmployeeCount => integer().nullable()();

  /// Company logo URL (stored in cloud storage)
  TextColumn get logoUrl => text().nullable()();

  /// Official company website
  TextColumn get website => text().nullable()();

  /// Company phone
  TextColumn get phone => text().nullable()();

  /// Company address
  TextColumn get address => text().nullable()();

  /// Tax registration number
  TextColumn get taxNumber => text().nullable()();

  /// Commercial registration number
  TextColumn get commercialRegNumber => text().nullable()();

  // ── Settings ─────────────────────────────────────────────────────

  /// Default language for this company workspace (e.g. "ar", "en")
  TextColumn get defaultLanguage => text().withDefault(const Constant('ar'))();

  /// Default timezone (e.g. "Asia/Riyadh")
  TextColumn get defaultTimezone =>
      text().withDefault(const Constant('Asia/Riyadh'))();

  /// JSON blob for workspace-level feature flags/settings
  TextColumn get settingsJson => text().nullable()();

  @override
  List<String> get customConstraints => [
        'UNIQUE(workspace_slug)',
        'UNIQUE(company_code)',
      ];
}