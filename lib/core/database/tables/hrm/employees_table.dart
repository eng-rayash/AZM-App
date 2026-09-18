import 'package:drift/drift.dart';
import '../base_table.dart';
import '../tenant_scoped.dart';

/// Employees table — core HRM entity.
///
/// Stores all personal, professional, financial, and contact data for employees.
class Employees extends Table with BaseTableMixin, TenantScoped {
  // ── Identity ────────────────────────────────────────────────────
  TextColumn get name => text().withLength(min: 1, max: 150)();
  TextColumn get nameEn => text().nullable()();
  TextColumn get employeeCode => text().nullable()();
  TextColumn get nationalId => text().nullable()();
  TextColumn get photo => text().nullable()(); // file path

  // ── Personal Info ────────────────────────────────────────────────
  /// gender: 0=male, 1=female
  IntColumn get gender => integer().withDefault(const Constant(0))();
  TextColumn get dateOfBirth => text().nullable()();
  TextColumn get nationality => text().nullable()();
  /// maritalStatus: 0=single, 1=married, 2=divorced, 3=widowed
  IntColumn get maritalStatus => integer().withDefault(const Constant(0))();
  IntColumn get childrenCount => integer().withDefault(const Constant(0))();
  TextColumn get religion => text().nullable()();
  TextColumn get bloodType => text().nullable()();

  // ── Contact Info ─────────────────────────────────────────────────
  TextColumn get phone => text().nullable()();
  TextColumn get alternativePhone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get country => text().nullable()();

  // ── Emergency Contact ────────────────────────────────────────────
  TextColumn get emergencyContactName => text().nullable()();
  TextColumn get emergencyContactPhone => text().nullable()();
  TextColumn get emergencyContactRelation => text().nullable()();

  // ── Employment Info ──────────────────────────────────────────────
  IntColumn get departmentId => integer().nullable()();
  TextColumn get departmentName => text().nullable()(); // cached
  IntColumn get positionId => integer().nullable()();
  TextColumn get positionName => text().nullable()(); // cached
  IntColumn get branchId => integer().nullable()();
  TextColumn get branchName => text().nullable()(); // cached
  IntColumn get managerId => integer().nullable()();
  TextColumn get managerName => text().nullable()(); // cached
  TextColumn get hiringDate => text().nullable()();
  TextColumn get probationEndDate => text().nullable()();
  /// employmentType: 0=full-time, 1=part-time, 2=contract, 3=intern, 4=freelance
  IntColumn get employmentType => integer().withDefault(const Constant(0))();
  /// status: 0=active, 1=inactive, 2=suspended, 3=terminated, 4=resigned
  IntColumn get status => integer().withDefault(const Constant(0))();
  TextColumn get terminationDate => text().nullable()();
  TextColumn get terminationReason => text().nullable()();

  // ── Financial Info ───────────────────────────────────────────────
  RealColumn get basicSalary => real().withDefault(const Constant(0.0))();
  /// salaryType: 0=monthly, 1=hourly, 2=daily, 3=commission
  IntColumn get salaryType => integer().withDefault(const Constant(0))();
  TextColumn get iban => text().nullable()();
  TextColumn get bankName => text().nullable()();
  TextColumn get bankAccountNumber => text().nullable()();

  // ── Documents ────────────────────────────────────────────────────
  TextColumn get passportNumber => text().nullable()();
  TextColumn get passportExpiry => text().nullable()();
  TextColumn get residenceNumber => text().nullable()(); // iqama
  TextColumn get residenceExpiry => text().nullable()();
  TextColumn get workPermitNumber => text().nullable()();
  TextColumn get workPermitExpiry => text().nullable()();

  // ── Notes ────────────────────────────────────────────────────────
  TextColumn get notes => text().nullable()();
  TextColumn get qualifications => text().nullable()();
  TextColumn get skills => text().nullable()(); // JSON array
  TextColumn get attachments => text().nullable()(); // JSON array
}