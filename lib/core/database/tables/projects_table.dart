import 'package:drift/drift.dart';
import 'base_table.dart';
import 'tenant_scoped.dart';

/// Supported currencies in the system.
///
/// YER = Yemeni Rial  (﷼ يمني)
/// SAR = Saudi Riyal  (﷼ سعودي)
/// USD = US Dollar    ($ دولار)
///
/// Default: SAR

/// Projects table — work projects linking clients, employees, and finances.
class Projects extends Table with BaseTableMixin, TenantScoped {
  TextColumn get name => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  TextColumn get code => text().nullable()();

  // ── Client Link ──────────────────────────────────────────────────
  IntColumn get clientId => integer().nullable()();
  TextColumn get clientName => text().nullable()(); // cached

  // ── Dates ────────────────────────────────────────────────────────
  TextColumn get startDate => text().nullable()();
  TextColumn get endDate => text().nullable()();
  TextColumn get actualEndDate => text().nullable()();

  // ── Financial ────────────────────────────────────────────────────
  RealColumn get budget => real().withDefault(const Constant(0.0))();
  RealColumn get actualCost => real().withDefault(const Constant(0.0))();
  RealColumn get contractValue => real().withDefault(const Constant(0.0))();
  /// currency: 'YER', 'SAR', 'USD'
  TextColumn get currency => text().withDefault(const Constant('SAR'))();

  // ── Status & Progress ────────────────────────────────────────────
  /// status: 0=planning, 1=active, 2=on-hold, 3=completed, 4=cancelled
  IntColumn get status => integer().withDefault(const Constant(0))();
  IntColumn get progress => integer().withDefault(const Constant(0))(); // 0–100

  // ── Team ─────────────────────────────────────────────────────────
  IntColumn get managerId => integer().nullable()();
  TextColumn get managerName => text().nullable()(); // cached
  TextColumn get teamIds => text().nullable()(); // JSON array of employee IDs

  // ── Categories / Tags ────────────────────────────────────────────
  TextColumn get category => text().nullable()();
  TextColumn get tags => text().nullable()(); // JSON array

  // ── Extras ──────────────────────────────────────────────────────
  TextColumn get location => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get attachments => text().nullable()(); // JSON
  TextColumn get logo => text().nullable()(); // file path
  IntColumn get priority => integer().withDefault(const Constant(2))();
}