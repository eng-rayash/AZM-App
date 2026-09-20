import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/hrm/employees_table.dart';
import '../../utils/arabic_normalizer.dart';

part 'employees_dao.g.dart';

@DriftAccessor(tables: [Employees])
class EmployeesDao extends DatabaseAccessor<AppDatabase>
    with _$EmployeesDaoMixin {
  EmployeesDao(super.db);

  // ── Queries ──────────────────────────────────────────────────────

  /// كل الموظفين غير المحذوفين، مرتَّبين بالاسم.
  Future<List<Employee>> getAllEmployees() => (select(employees)
        ..where((e) => e.isDeleted.equals(false))
        ..orderBy([(e) => OrderingTerm.asc(e.name)]))
      .get();

  /// مراقبة الموظفين على رأس العمل.
  Stream<List<Employee>> watchAllEmployees() => (select(employees)
        ..where((e) => e.isDeleted.equals(false) & e.status.isIn([0, 1, 2]))
        ..orderBy([(e) => OrderingTerm.asc(e.name)]))
      .watch();

  /// مراقبة موظفي قسم.
  Stream<List<Employee>> watchByDepartment(int departmentId) =>
      (select(employees)
            ..where((e) =>
                e.isDeleted.equals(false) &
                e.departmentId.equals(departmentId))
            ..orderBy([(e) => OrderingTerm.asc(e.name)]))
          .watch();

  /// موظف بمعرّفه — يعيد `null` للمحذوف.
  Future<Employee?> getById(int id) => (select(employees)
        ..where((e) => e.id.equals(id) & e.isDeleted.equals(false)))
      .getSingleOrNull();

  /// بحث في الموظفين بالاسم أو الرقم الوظيفي أو الهاتف.
  ///
  /// المطابقة مطبَّعة — انظر [filterNormalized]. وللتطبيع فائدة هنا
  /// تتجاوز الأسماء: من يكتب رقمًا بالأرقام العربية-الهندية يجده
  /// مخزَّنًا باللاتينية.
  ///
  /// `isDeleted` كان غائبًا عن الشرط، فكان البحث يعيد موظفين محذوفين.
  Future<List<Employee>> search(String query) async {
    final rows = await (select(employees)
          ..where((e) => e.isDeleted.equals(false))
          ..orderBy([(e) => OrderingTerm.asc(e.name)]))
        .get();

    return filterNormalized(
      rows,
      query,
      (e) => [e.name, e.employeeCode, e.phone],
    );
  }

  /// عدد الموظفين بحالة معيّنة.
  Future<int> countByStatus(int status) async {
    final count = employees.id.count();
    final query = selectOnly(employees)
      ..addColumns([count])
      ..where(employees.status.equals(status) &
          employees.isDeleted.equals(false));
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

  /// حذف ناعم — الحذف حدث يُزامَن لا غياب صفّ.
  ///
  /// كان حذفًا صلبًا رغم وجود `isDeleted` وقاعدة المشروع، وكلفته تظهر
  /// عند المزامنة: الصفّ يختفي من هذا الجهاز ويبقى على جهاز لم يتزامن
  /// بعد، فيعود في أول دفع. نظيره على الخادم في `MeetingsService.remove`.
  ///
  /// ⚠ التحويل وحده لم يكن ليكفي: **لا قراءة في هذا الملف كانت تصفّي
  /// `isDeleted`** رغم أن توثيقها يقول «active»، فكان الحذف الناعم
  /// يُظهر المحذوفين في كل قائمة. القراءات أعلاه صُحِّحت معه.
  Future<int> deleteEmployee(int id) =>
      (update(employees)..where((e) => e.id.equals(id))).write(
        EmployeesCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
}