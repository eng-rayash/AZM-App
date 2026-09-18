import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/hrm/organization_tables.dart';
import '../tables/hrm/payroll_tables.dart';
import '../tables/hrm/attendance_leave_tables.dart';
import '../tables/hrm/performance_training_tables.dart';

part 'hrm_dao.g.dart';

/// Unified HRM DAO covering Departments, Branches, Positions,
/// EmployeeContracts, SalaryRecords, AttendanceRecords,
/// LeaveRequests, LeaveBalances, EmployeeAdvances,
/// PerformanceEvaluations, TrainingRecords, EmployeeAssets,
/// RewardsPenalties.
@DriftAccessor(tables: [
  Departments,
  Branches,
  Positions,
  EmployeeContracts,
  SalaryRecords,
  AttendanceRecords,
  LeaveRequests,
  LeaveBalances,
  EmployeeAdvances,
  PerformanceEvaluations,
  TrainingRecords,
  EmployeeAssets,
  RewardsPenalties,
])
class HrmDao extends DatabaseAccessor<AppDatabase> with _$HrmDaoMixin {
  HrmDao(super.db);

  // ── Departments ──────────────────────────────────────────────────
  Stream<List<Department>> watchDepartments() =>
      (select(departments)..orderBy([(d) => OrderingTerm.asc(d.name)])).watch();

  Future<List<Department>> getAllDepartments() =>
      (select(departments)..orderBy([(d) => OrderingTerm.asc(d.name)])).get();

  Future<int> insertDepartment(DepartmentsCompanion entry) =>
      into(departments).insert(entry);

  Future<bool> updateDepartment(DepartmentsCompanion entry) =>
      update(departments).replace(entry);

  Future<int> deleteDepartment(int id) =>
      (delete(departments)..where((d) => d.id.equals(id))).go();

  // ── Branches ─────────────────────────────────────────────────────
  Stream<List<Branche>> watchBranches() =>
      (select(branches)..orderBy([(b) => OrderingTerm.asc(b.name)])).watch();

  Future<List<Branche>> getAllBranches() =>
      (select(branches)..orderBy([(b) => OrderingTerm.asc(b.name)])).get();

  Future<int> insertBranch(BranchesCompanion entry) =>
      into(branches).insert(entry);

  Future<bool> updateBranch(BranchesCompanion entry) =>
      update(branches).replace(entry);

  // ── Positions ────────────────────────────────────────────────────
  Stream<List<Position>> watchPositions() =>
      (select(positions)..orderBy([(p) => OrderingTerm.asc(p.title)])).watch();

  Future<List<Position>> getAllPositions() =>
      (select(positions)..orderBy([(p) => OrderingTerm.asc(p.title)])).get();

  Future<int> insertPosition(PositionsCompanion entry) =>
      into(positions).insert(entry);

  // ── Contracts ────────────────────────────────────────────────────
  Stream<List<EmployeeContract>> watchContractsByEmployee(int employeeId) =>
      (select(employeeContracts)
            ..where((c) => c.employeeId.equals(employeeId))
            ..orderBy([(c) => OrderingTerm.desc(c.startDate)]))
          .watch();

  Future<List<EmployeeContract>> getActiveContracts() =>
      (select(employeeContracts)
            ..where((c) => c.status.equals(0))
            ..orderBy([(c) => OrderingTerm.asc(c.endDate)]))
          .get();

  /// Get contracts expiring within N days (for alerts).
  Future<List<EmployeeContract>> getExpiringContracts(int days) async {
    final now = DateTime.now();
    final limit = now.add(Duration(days: days));
    final nowStr = now.toIso8601String().split('T').first;
    final limitStr = limit.toIso8601String().split('T').first;
    return (select(employeeContracts)
          ..where(
            (c) =>
                c.status.equals(0) &
                c.endDate.isBetweenValues(nowStr, limitStr),
          ))
        .get();
  }

  Future<int> insertContract(EmployeeContractsCompanion entry) =>
      into(employeeContracts).insert(entry);

  Future<bool> updateContract(EmployeeContractsCompanion entry) =>
      update(employeeContracts).replace(entry);

  // ── Salary Records ───────────────────────────────────────────────
  Stream<List<SalaryRecord>> watchSalariesByEmployee(int employeeId) =>
      (select(salaryRecords)
            ..where((s) => s.employeeId.equals(employeeId))
            ..orderBy([
              (s) => OrderingTerm.desc(s.year),
              (s) => OrderingTerm.desc(s.month),
            ]))
          .watch();

  Future<List<SalaryRecord>> getSalariesForMonth(int month, int year) =>
      (select(salaryRecords)
            ..where((s) => s.month.equals(month) & s.year.equals(year)))
          .get();

  Future<int> insertSalary(SalaryRecordsCompanion entry) =>
      into(salaryRecords).insert(entry);

  Future<bool> updateSalary(SalaryRecordsCompanion entry) =>
      update(salaryRecords).replace(entry);

  // ── Attendance ───────────────────────────────────────────────────
  Stream<List<AttendanceRecord>> watchAttendanceByDate(String date) =>
      (select(attendanceRecords)
            ..where((a) => a.date.equals(date))
            ..orderBy([(a) => OrderingTerm.asc(a.employeeName)]))
          .watch();

  Future<List<AttendanceRecord>> getAttendanceForEmployee(
    int employeeId,
    String from,
    String to,
  ) =>
      (select(attendanceRecords)
            ..where(
              (a) =>
                  a.employeeId.equals(employeeId) &
                  a.date.isBetweenValues(from, to),
            ))
          .get();

  Future<int> insertAttendance(AttendanceRecordsCompanion entry) =>
      into(attendanceRecords).insert(entry);

  Future<bool> updateAttendance(AttendanceRecordsCompanion entry) =>
      update(attendanceRecords).replace(entry);

  // ── Leave Requests ───────────────────────────────────────────────
  Stream<List<LeaveRequest>> watchLeavesByEmployee(int employeeId) =>
      (select(leaveRequests)
            ..where((l) => l.employeeId.equals(employeeId))
            ..orderBy([(l) => OrderingTerm.desc(l.startDate)]))
          .watch();

  Stream<List<LeaveRequest>> watchPendingLeaves() =>
      (select(leaveRequests)
            ..where((l) => l.status.equals(0))
            ..orderBy([(l) => OrderingTerm.asc(l.startDate)]))
          .watch();

  Future<int> insertLeave(LeaveRequestsCompanion entry) =>
      into(leaveRequests).insert(entry);

  Future<bool> updateLeave(LeaveRequestsCompanion entry) =>
      update(leaveRequests).replace(entry);

  // ── Advances ─────────────────────────────────────────────────────
  Stream<List<EmployeeAdvance>> watchAdvancesByEmployee(int employeeId) =>
      (select(employeeAdvances)
            ..where((a) => a.employeeId.equals(employeeId))
            ..orderBy([(a) => OrderingTerm.desc(a.requestDate)]))
          .watch();

  /// كل السلف — تستخدمها شاشة السلف التي كانت تبني تدفّقها بنفسها.
  Stream<List<EmployeeAdvance>> watchAdvances() =>
      (select(employeeAdvances)
            ..where((a) => a.isDeleted.equals(false))
            ..orderBy([(a) => OrderingTerm.desc(a.requestDate)]))
          .watch();

  Future<int> insertAdvance(EmployeeAdvancesCompanion entry) =>
      into(employeeAdvances).insert(entry);

  Future<bool> updateAdvance(EmployeeAdvancesCompanion entry) =>
      update(employeeAdvances).replace(entry);

  // ── Evaluations ──────────────────────────────────────────────────
  Stream<List<PerformanceEvaluation>> watchEvaluationsByEmployee(
    int employeeId,
  ) =>
      (select(performanceEvaluations)
            ..where((e) => e.employeeId.equals(employeeId))
            ..orderBy([(e) => OrderingTerm.desc(e.evaluationDate)]))
          .watch();

  Stream<List<PerformanceEvaluation>> watchEvaluations() =>
      (select(performanceEvaluations)
            ..where((e) => e.isDeleted.equals(false))
            ..orderBy([(e) => OrderingTerm.desc(e.evaluationDate)]))
          .watch();

  Future<int> insertEvaluation(PerformanceEvaluationsCompanion entry) =>
      into(performanceEvaluations).insert(entry);

  // ── Training Records ─────────────────────────────────────────────
  Stream<List<TrainingRecord>> watchTrainingsByEmployee(int employeeId) =>
      (select(trainingRecords)
            ..where((t) => t.employeeId.equals(employeeId))
            ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
          .watch();

  Stream<List<TrainingRecord>> watchTrainings() =>
      (select(trainingRecords)
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.desc(t.startDate)]))
          .watch();

  Future<int> insertTraining(TrainingRecordsCompanion entry) =>
      into(trainingRecords).insert(entry);

  // ── Assets ───────────────────────────────────────────────────────
  Stream<List<EmployeeAsset>> watchAssetsByEmployee(int employeeId) =>
      (select(employeeAssets)
            ..where((a) => a.employeeId.equals(employeeId))
            ..orderBy([(a) => OrderingTerm.desc(a.assignedDate)]))
          .watch();

  Future<int> insertAsset(EmployeeAssetsCompanion entry) =>
      into(employeeAssets).insert(entry);

  // ── Rewards & Penalties ──────────────────────────────────────────
  Stream<List<RewardsPenalty>> watchRewardsByEmployee(int employeeId) =>
      (select(rewardsPenalties)
            ..where((r) => r.employeeId.equals(employeeId))
            ..orderBy([(r) => OrderingTerm.desc(r.date)]))
          .watch();

  Stream<List<RewardsPenalty>> watchRewardsPenalties() =>
      (select(rewardsPenalties)
            ..where((r) => r.isDeleted.equals(false))
            ..orderBy([(r) => OrderingTerm.desc(r.date)]))
          .watch();

  Future<int> insertRewardPenalty(RewardsPenaltiesCompanion entry) =>
      into(rewardsPenalties).insert(entry);
}