import 'package:drift/drift.dart';
import '../base_table.dart';
import '../tenant_scoped.dart';

/// Departments table — organizational units within the company.
class Departments extends Table with BaseTableMixin, TenantScoped {
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get description => text().nullable()();
  IntColumn get managerId => integer().nullable()();
  TextColumn get managerName => text().nullable()(); // cached
  IntColumn get parentDepartmentId => integer().nullable()();
  TextColumn get parentDepartmentName => text().nullable()(); // cached
  IntColumn get branchId => integer().nullable()();
  TextColumn get branchName => text().nullable()(); // cached
  TextColumn get costCenter => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
}

/// Branches table — physical locations / offices.
class Branches extends Table with BaseTableMixin, TenantScoped {
  TextColumn get name => text().withLength(min: 1, max: 100)();
  TextColumn get address => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get country => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  BoolColumn get isMainBranch => boolean().withDefault(const Constant(false))();
  IntColumn get managerId => integer().nullable()();
  TextColumn get managerName => text().nullable()(); // cached
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
}

/// Positions table — job titles / roles.
class Positions extends Table with BaseTableMixin, TenantScoped {
  TextColumn get title => text().withLength(min: 1, max: 100)();
  TextColumn get titleEn => text().nullable()();
  /// level: 0=executive, 1=senior, 2=mid, 3=junior, 4=intern
  IntColumn get level => integer().withDefault(const Constant(2))();
  IntColumn get departmentId => integer().nullable()();
  TextColumn get departmentName => text().nullable()(); // cached
  TextColumn get description => text().nullable()();
  TextColumn get responsibilities => text().nullable()(); // JSON array
  TextColumn get requirements => text().nullable()();
  RealColumn get minSalary => real().nullable()();
  RealColumn get maxSalary => real().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}