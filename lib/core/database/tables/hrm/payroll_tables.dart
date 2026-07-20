import 'package:drift/drift.dart';
import '../base_table.dart';

/// Employee Contracts table.
class EmployeeContracts extends Table with BaseTableMixin {
  IntColumn get employeeId => integer()();
  TextColumn get employeeName => text().nullable()(); // cached
  /// contractType: 0=fixed-term, 1=open-ended, 2=part-time, 3=freelance
  IntColumn get contractType => integer().withDefault(const Constant(0))();
  TextColumn get startDate => text()();
  TextColumn get endDate => text().nullable()();
  RealColumn get salary => real().withDefault(const Constant(0.0))();
  TextColumn get allowances => text().nullable()(); // JSON [{name, amount}]
  TextColumn get filePath => text().nullable()();
  /// status: 0=active, 1=expired, 2=terminated, 3=suspended
  IntColumn get status => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  TextColumn get renewalReminderDate => text().nullable()();
}

/// Monthly Salary Records table.
class SalaryRecords extends Table with BaseTableMixin {
  IntColumn get employeeId => integer()();
  TextColumn get employeeName => text().nullable()(); // cached
  IntColumn get month => integer()(); // 1–12
  IntColumn get year => integer()();
  RealColumn get basicSalary => real().withDefault(const Constant(0.0))();
  TextColumn get allowances => text().nullable()(); // JSON [{name, amount}]
  TextColumn get deductions => text().nullable()(); // JSON [{name, amount}]
  RealColumn get advances => real().withDefault(const Constant(0.0))();
  RealColumn get totalGross => real().withDefault(const Constant(0.0))();
  RealColumn get totalDeductions => real().withDefault(const Constant(0.0))();
  RealColumn get netSalary => real().withDefault(const Constant(0.0))();
  TextColumn get paymentDate => text().nullable()();
  /// paymentMethod: 0=bank-transfer, 1=cash, 2=check
  IntColumn get paymentMethod => integer().withDefault(const Constant(0))();
  /// status: 0=draft, 1=pending, 2=paid
  IntColumn get status => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
}

/// Salary Allowances Catalog (reusable allowance types).
class SalaryAllowanceTypes extends Table with BaseTableMixin {
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get nameEn => text().nullable()();
  /// isPercentage: if true, amount is % of basic salary
  BoolColumn get isPercentage => boolean().withDefault(const Constant(false))();
  RealColumn get defaultValue => real().withDefault(const Constant(0.0))();
  BoolColumn get isTaxable => boolean().withDefault(const Constant(false))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}

/// Salary Deduction Types (reusable deduction types).
class SalaryDeductionTypes extends Table with BaseTableMixin {
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get nameEn => text().nullable()();
  BoolColumn get isPercentage => boolean().withDefault(const Constant(false))();
  RealColumn get defaultValue => real().withDefault(const Constant(0.0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}
