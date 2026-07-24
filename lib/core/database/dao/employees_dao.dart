import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/hrm/employees_table.dart';

part 'employees_dao.g.dart';

@DriftAccessor(tables: [Employees])
class EmployeesDao extends DatabaseAccessor<AppDatabase>
    with _$EmployeesDaoMixin {
  EmployeesDao(super.db);

  // ── Queries ──────────────────────────────────────────────────────

  /// All active employees ordered by name.
  Future<List<Employee>> getAllEmployees() =>
      (select(employees)..orderBy([(e) => OrderingTerm.asc(e.name)])).get();

  /// Watch all active employees.
  Stream<List<Employee>> watchAllEmployees() =>
      (select(employees)
            ..where((e) => e.status.isIn([0, 1, 2]))
            ..orderBy([(e) => OrderingTerm.asc(e.name)]))
          .watch();

  /// Watch employees by department.
  Stream<List<Employee>> watchByDepartment(int departmentId) =>
      (select(employees)
            ..where((e) => e.departmentId.equals(departmentId))
            ..orderBy([(e) => OrderingTerm.asc(e.name)]))
          .watch();

  /// Get employee by ID.
  Future<Employee?> getById(int id) =>
      (select(employees)..where((e) => e.id.equals(id))).getSingleOrNull();

  /// Search employees by name or code.
  Future<List<Employee>> search(String query) =>
      (select(employees)
            ..where(
              (e) =>
                  e.name.like('%$query%') |
                  e.employeeCode.like('%$query%') |
                  e.phone.like('%$query%'),
            )
            ..orderBy([(e) => OrderingTerm.asc(e.name)]))
          .get();

  /// Count employees by status.
  Future<int> countByStatus(int status) async {
    final count = employees.id.count();
    final query = selectOnly(employees)
      ..addColumns([count])
      ..where(employees.status.equals(status));
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  /// Total active employee count.
  Future<int> countActive() => countByStatus(0);

  // ── Mutations ────────────────────────────────────────────────────

  Future<int> insertEmployee(EmployeesCompanion entry) =>
      into(employees).insert(entry);

  Future<bool> updateEmployee(EmployeesCompanion entry) =>
      update(employees).replace(entry);

  Future<int> deleteEmployee(int id) =>
      (delete(employees)..where((e) => e.id.equals(id))).go();
}