import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/services/audit_service.dart';

/// HRM Repository — all employee & HR business logic.
class HrmRepository {
  HrmRepository(this._db, [this._audit]);

  final AppDatabase _db;

  /// اختياري حتى تبقى الاختبارات قادرة على بناء المستودع بلا سياق.
  final AuditService? _audit;
  static const _uuid = Uuid();

  // ── Employees ──────────────────────────────────────────────────

  Stream<List<Employee>> watchAllEmployees() =>
      _db.employeesDao.watchAllEmployees();

  Stream<List<Employee>> watchByDepartment(int departmentId) =>
      _db.employeesDao.watchByDepartment(departmentId);

  Future<Employee?> getEmployeeById(int id) =>
      _db.employeesDao.getById(id);

  Future<List<Employee>> searchEmployees(String query) =>
      _db.employeesDao.search(query);

  Future<int> createEmployee({
    required String name,
    String? nameEn,
    String? phone,
    String? email,
    String? nationalId,
    int? departmentId,
    String? departmentName,
    int? positionId,
    String? positionTitle,
    int? branchId,
    String? branchName,
    String? hireDate,
    String? nationality,
    String? gender,
    double? basicSalary,
    String? currency,
    String? notes,
  }) async {
    return _db.employeesDao.insertEmployee(
      EmployeesCompanion.insert(
        syncId: _uuid.v4(),
        name: name,
        nameEn: drift.Value(nameEn),
        phone: drift.Value(phone),
        email: drift.Value(email),
        nationalId: drift.Value(nationalId),
        departmentId: drift.Value(departmentId),
        departmentName: drift.Value(departmentName),
        positionId: drift.Value(positionId),
        positionName: drift.Value(positionTitle),
        branchId: drift.Value(branchId),
        branchName: drift.Value(branchName),
        hiringDate: drift.Value(hireDate),
        nationality: drift.Value(nationality),
        gender: drift.Value(gender == 'أنثى' || gender?.toLowerCase() == 'female' ? 1 : 0),
        basicSalary: drift.Value(basicSalary ?? 0.0),
        status: const drift.Value(0), // active
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
        notes: drift.Value(notes),
      ),
    );
  }

  Future<bool> updateEmployee(EmployeesCompanion entry) =>
      _db.employeesDao.updateEmployee(entry);

  Future<int> deleteEmployee(int id) =>
      _db.employeesDao.deleteEmployee(id);

  // ── Departments ────────────────────────────────────────────────

  Stream<List<Department>> watchDepartments() =>
      _db.hrmDao.watchDepartments();

  Future<List<Department>> getAllDepartments() =>
      _db.hrmDao.getAllDepartments();

  Future<int> createDepartment({
    required String name,
    String? description,
    int? managerId,
    String? managerName,
  }) =>
      _db.hrmDao.insertDepartment(
        DepartmentsCompanion.insert(
          syncId: _uuid.v4(),
          name: name,
          description: drift.Value(description),
          managerId: drift.Value(managerId),
          managerName: drift.Value(managerName),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  // ── Branches ───────────────────────────────────────────────────

  Stream<List<Branche>> watchBranches() => _db.hrmDao.watchBranches();

  Future<int> createBranch({
    required String name,
    String? city,
    String? address,
    String? phone,
    bool isMain = false,
  }) =>
      _db.hrmDao.insertBranch(
        BranchesCompanion.insert(
          syncId: _uuid.v4(),
          name: name,
          city: drift.Value(city),
          address: drift.Value(address),
          phone: drift.Value(phone),
          isMainBranch: drift.Value(isMain),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  // ── Positions ──────────────────────────────────────────────────

  Stream<List<Position>> watchPositions() => _db.hrmDao.watchPositions();

  Future<int> createPosition({
    required String title,
    int? departmentId,
    String? departmentName,
    String? description,
    double? minSalary,
    double? maxSalary,
  }) =>
      _db.hrmDao.insertPosition(
        PositionsCompanion.insert(
          syncId: _uuid.v4(),
          title: title,
          departmentId: drift.Value(departmentId),
          departmentName: drift.Value(departmentName),
          description: drift.Value(description),
          minSalary: drift.Value(minSalary),
          maxSalary: drift.Value(maxSalary),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  // ── Contracts ──────────────────────────────────────────────────

  Stream<List<EmployeeContract>> watchContractsByEmployee(int empId) =>
      _db.hrmDao.watchContractsByEmployee(empId);

  Future<List<EmployeeContract>> getActiveContracts() =>
      _db.hrmDao.getActiveContracts();

  Future<List<EmployeeContract>> getExpiringContracts({int days = 30}) =>
      _db.hrmDao.getExpiringContracts(days);

  Future<int> createContract({
    required int employeeId,
    required String employeeName,
    required int contractType,
    required String startDate,
    String? endDate,
    required double basicSalary,
    String? currency,
    double? housingAllowance,
    double? transportAllowance,
    double? otherAllowances,
    String? jobTitle,
    String? notes,
  }) {
    // Serialize allowances into JSON array of objects e.g. [{"name": "housing", "amount": 100}]
    final allowanceList = <Map<String, dynamic>>[];
    if (housingAllowance != null && housingAllowance > 0) {
      allowanceList.add({'name': 'housing', 'amount': housingAllowance});
    }
    if (transportAllowance != null && transportAllowance > 0) {
      allowanceList.add({'name': 'transport', 'amount': transportAllowance});
    }
    if (otherAllowances != null && otherAllowances > 0) {
      allowanceList.add({'name': 'other', 'amount': otherAllowances});
    }
    final allowancesJson = allowanceList.isNotEmpty ? jsonEncode(allowanceList) : null;

    return _db.hrmDao.insertContract(
      EmployeeContractsCompanion.insert(
        syncId: _uuid.v4(),
        employeeId: employeeId,
        employeeName: drift.Value(employeeName),
        contractType: drift.Value(contractType),
        startDate: startDate,
        endDate: drift.Value(endDate),
        salary: drift.Value(basicSalary),
        allowances: drift.Value(allowancesJson),
        status: const drift.Value(0),
        notes: drift.Value(notes),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  // ── Salaries ───────────────────────────────────────────────────

  Stream<List<SalaryRecord>> watchSalariesByEmployee(int empId) =>
      _db.hrmDao.watchSalariesByEmployee(empId);

  Future<List<SalaryRecord>> getSalariesForMonth(int month, int year) =>
      _db.hrmDao.getSalariesForMonth(month, year);

  Future<int> createSalaryRecord({
    required int employeeId,
    required String employeeName,
    required int month,
    required int year,
    required double basicSalary,
    String? currency,
    double? totalAllowances,
    double? totalDeductions,
    double? netSalary,
    String? paymentDate,
  }) =>
      _db.hrmDao.insertSalary(
        SalaryRecordsCompanion.insert(
          syncId: _uuid.v4(),
          employeeId: employeeId,
          employeeName: drift.Value(employeeName),
          month: month,
          year: year,
          basicSalary: drift.Value(basicSalary),
          totalGross: drift.Value(basicSalary + (totalAllowances ?? 0)),
          totalDeductions: drift.Value(totalDeductions ?? 0),
          netSalary: drift.Value(
            netSalary ?? (basicSalary + (totalAllowances ?? 0) - (totalDeductions ?? 0)),
          ),
          paymentDate: drift.Value(paymentDate),
          status: const drift.Value(0),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  // ── Attendance ─────────────────────────────────────────────────

  Stream<List<AttendanceRecord>> watchAttendanceByDate(String date) =>
      _db.hrmDao.watchAttendanceByDate(date);

  Future<int> recordAttendance({
    required int employeeId,
    required String employeeName,
    required String date,
    String? checkIn,
    String? checkOut,
    int attendanceStatus = 0,
    String? notes,
  }) =>
      _db.hrmDao.insertAttendance(
        AttendanceRecordsCompanion.insert(
          syncId: _uuid.v4(),
          employeeId: employeeId,
          employeeName: drift.Value(employeeName),
          date: date,
          checkIn: drift.Value(checkIn),
          checkOut: drift.Value(checkOut),
          status: drift.Value(attendanceStatus),
          notes: drift.Value(notes),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  // ── Leaves ────────────────────────────────────────────────────

  Stream<List<LeaveRequest>> watchLeavesByEmployee(int empId) =>
      _db.hrmDao.watchLeavesByEmployee(empId);

  Stream<List<LeaveRequest>> watchPendingLeaves() =>
      _db.hrmDao.watchPendingLeaves();

  Future<int> createLeaveRequest({
    required int employeeId,
    required String employeeName,
    required int leaveType,
    required String startDate,
    required String endDate,
    required int daysCount,
    String? reason,
    String? notes,
  }) =>
      _db.hrmDao.insertLeave(
        LeaveRequestsCompanion.insert(
          syncId: _uuid.v4(),
          employeeId: employeeId,
          employeeName: drift.Value(employeeName),
          leaveType: drift.Value(leaveType),
          startDate: startDate,
          endDate: endDate,
          days: drift.Value(daysCount),
          reason: drift.Value(reason),
          status: const drift.Value(0), // pending
          notes: drift.Value(notes),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  Future<bool> updateLeaveStatus({
    required LeaveRequest leave,
    required int newStatus,
    String? approverName,
    int? approverId,
  }) async {
    final ok = await _db.hrmDao.updateLeave(
      leave.toCompanion(true).copyWith(
        status: drift.Value(newStatus),
        approvedById: drift.Value(approverId),
        approvedByName: drift.Value(approverName),
        updatedAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );

    // قرار يمسّ رصيد الموظف وأجره — يجب أن يُعرف من اتّخذه
    await _audit?.log(
      action: newStatus == 1 ? 'leave.approved' : 'leave.rejected',
      entityType: 'leave_request',
      entitySyncId: leave.syncId,
      description: '${leave.employeeName ?? 'موظف'} — ${leave.days} يوم',
      oldValue: {'status': leave.status},
      newValue: {'status': newStatus, 'approvedBy': approverName},
      severity: AuditSeverity.warning,
    );
    return ok;
  }

  // ── Advances ───────────────────────────────────────────────────

  Stream<List<EmployeeAdvance>> watchAdvances() => _db.hrmDao.watchAdvances();

  /// يسجّل طلب سلفة.
  ///
  /// الأعمدة الأساسية (`syncId` و`createdAt` و`updatedAt`) تُملأ هنا لا في
  /// الشاشة: كانت الشاشة تبني `Companion` بدونها فيرفض Drift الإدراج
  /// بـ`InvalidDataException` — أي أن زرّ «تقديم» لم يكن يحفظ شيئًا.
  Future<int> createAdvance({
    required int employeeId,
    required double amount,
    required String requestDate,
    String? employeeName,
    String? reason,
  }) =>
      _db.hrmDao.insertAdvance(
        EmployeeAdvancesCompanion.insert(
          syncId: _uuid.v4(),
          employeeId: employeeId,
          employeeName: drift.Value(employeeName),
          amount: drift.Value(amount),
          requestDate: requestDate,
          reason: drift.Value(reason),
          status: const drift.Value(0),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  // ── Performance Evaluations ────────────────────────────────────

  Stream<List<PerformanceEvaluation>> watchEvaluations() =>
      _db.hrmDao.watchEvaluations();

  Future<int> createEvaluation({
    required int employeeId,
    required String period,
    String? employeeName,
    double? totalScore,
    double? maxPossibleScore,
    double? percentage,
    int? grade,
    int status = 0,
    String? strengths,
    String? areasForImprovement,
  }) {
    // النسبة تُحسب من الدرجات حين تتوفّر، وإلا تُؤخذ كما مرّرها المستدعي
    final pct = percentage ??
        ((totalScore != null &&
                maxPossibleScore != null &&
                maxPossibleScore > 0)
            ? (totalScore / maxPossibleScore) * 100
            : null);

    return _db.hrmDao.insertEvaluation(
      PerformanceEvaluationsCompanion.insert(
        syncId: _uuid.v4(),
        employeeId: employeeId,
        employeeName: drift.Value(employeeName),
        period: period,
        totalScore: drift.Value(totalScore),
        maxPossibleScore: drift.Value(maxPossibleScore),
        percentage: drift.Value(pct),
        grade: drift.Value(grade),
        status: drift.Value(status),
        strengths: drift.Value(strengths),
        areasForImprovement: drift.Value(areasForImprovement),
        createdAt: DateTime.now().millisecondsSinceEpoch,
        updatedAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  // ── Training Records ───────────────────────────────────────────

  Stream<List<TrainingRecord>> watchTrainings() => _db.hrmDao.watchTrainings();

  Future<int> createTraining({
    required int employeeId,
    required String trainingName,
    String? employeeName,
    String? provider,
    String? startDate,
    String? endDate,
    int trainingType = 0,
    int status = 0,
    int? hours,
    double? cost,
  }) =>
      _db.hrmDao.insertTraining(
        TrainingRecordsCompanion.insert(
          syncId: _uuid.v4(),
          employeeId: employeeId,
          employeeName: drift.Value(employeeName),
          trainingName: trainingName,
          provider: drift.Value(provider),
          trainingType: drift.Value(trainingType),
          status: drift.Value(status),
          startDate: drift.Value(startDate),
          endDate: drift.Value(endDate),
          hours: drift.Value(hours),
          cost: drift.Value(cost),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  // ── Rewards & Penalties ────────────────────────────────────────

  Stream<List<RewardsPenalty>> watchRewardsPenalties() =>
      _db.hrmDao.watchRewardsPenalties();

  /// [type] — 0 مكافأة · 1 جزاء
  Future<int> createRewardPenalty({
    required int employeeId,
    required int type,
    required String reason,
    required String date,
    String? employeeName,
    double? amount,
    String? notes,
  }) async {
    final id = await _db.hrmDao.insertRewardPenalty(
        RewardsPenaltiesCompanion.insert(
          syncId: _uuid.v4(),
          employeeId: employeeId,
          type: drift.Value(type),
          reason: reason,
          date: date,
          employeeName: drift.Value(employeeName),
          amount: drift.Value(amount),
          notes: drift.Value(notes),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

    // الجزاء يمسّ سجلّ الموظف وقد يُخصم من أجره
    await _audit?.log(
      action: type == 0 ? 'reward.created' : 'penalty.created',
      entityType: 'reward_penalty',
      description: '${employeeName ?? 'موظف'} — $reason',
      newValue: {'type': type, 'amount': amount, 'reason': reason},
      severity: type == 1 ? AuditSeverity.warning : AuditSeverity.info,
    );
    return id;
  }

  // ── Stats for Dashboard ────────────────────────────────────────

  Future<int> countActiveEmployees() => _db.employeesDao.countActive();

  Future<int> countPendingLeaves() async {
    final list = await _db.hrmDao.watchPendingLeaves().first;
    return list.length;
  }

  Future<List<EmployeeContract>> getExpiringContractsSoon() =>
      _db.hrmDao.getExpiringContracts(30);
}

/// Provider for HrmRepository
final hrmRepositoryProvider = Provider<HrmRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return HrmRepository(db, ref.watch(auditServiceProvider));
});

// ── Stream Providers ───────────────────────────────────────────────

/// All employees stream
final employeesListProvider = StreamProvider<List<Employee>>((ref) {
  return ref.watch(hrmRepositoryProvider).watchAllEmployees();
});

/// Employees by department
final employeesByDepartmentProvider =
    StreamProvider.family<List<Employee>, int>((ref, deptId) {
  return ref.watch(hrmRepositoryProvider).watchByDepartment(deptId);
});

/// Departments stream
final departmentsListProvider = StreamProvider<List<Department>>((ref) {
  return ref.watch(hrmRepositoryProvider).watchDepartments();
});

/// Branches stream
final branchesListProvider = StreamProvider<List<Branche>>((ref) {
  return ref.watch(hrmRepositoryProvider).watchBranches();
});

/// Positions stream
final positionsListProvider = StreamProvider<List<Position>>((ref) {
  return ref.watch(hrmRepositoryProvider).watchPositions();
});

/// Pending leaves stream
final pendingLeavesProvider = StreamProvider<List<LeaveRequest>>((ref) {
  return ref.watch(hrmRepositoryProvider).watchPendingLeaves();
});

/// كل السلف — كانت شاشة السلف تبني هذا التدفّق بنفسها من `databaseProvider`
final advancesListProvider = StreamProvider<List<EmployeeAdvance>>((ref) {
  return ref.watch(hrmRepositoryProvider).watchAdvances();
});

/// كل تقييمات الأداء
final evaluationsListProvider =
    StreamProvider<List<PerformanceEvaluation>>((ref) {
  return ref.watch(hrmRepositoryProvider).watchEvaluations();
});

/// كل سجلات التدريب
final trainingsListProvider = StreamProvider<List<TrainingRecord>>((ref) {
  return ref.watch(hrmRepositoryProvider).watchTrainings();
});

/// كل المكافآت والجزاءات
final rewardsPenaltiesListProvider =
    StreamProvider<List<RewardsPenalty>>((ref) {
  return ref.watch(hrmRepositoryProvider).watchRewardsPenalties();
});

/// Contracts by employee
final contractsByEmployeeProvider =
    StreamProvider.family<List<EmployeeContract>, int>((ref, empId) {
  return ref.watch(hrmRepositoryProvider).watchContractsByEmployee(empId);
});

/// Salaries by employee
final salariesByEmployeeProvider =
    StreamProvider.family<List<SalaryRecord>, int>((ref, empId) {
  return ref.watch(hrmRepositoryProvider).watchSalariesByEmployee(empId);
});

/// Attendance by date
final attendanceByDateProvider =
    StreamProvider.family<List<AttendanceRecord>, String>((ref, date) {
  return ref.watch(hrmRepositoryProvider).watchAttendanceByDate(date);
});

/// HRM Dashboard KPIs
final hrmKpisProvider = FutureProvider<HrmKpis>((ref) async {
  final repo = ref.watch(hrmRepositoryProvider);
  final activeCount = await repo.countActiveEmployees();
  final pendingLeaves = await repo.countPendingLeaves();
  final expiringContracts = await repo.getExpiringContractsSoon();
  return HrmKpis(
    activeEmployees: activeCount,
    pendingLeaves: pendingLeaves,
    expiringContracts: expiringContracts.length,
  );
});

/// KPIs data class
class HrmKpis {
  const HrmKpis({
    required this.activeEmployees,
    required this.pendingLeaves,
    required this.expiringContracts,
  });
  final int activeEmployees;
  final int pendingLeaves;
  final int expiringContracts;
}