import 'dart:convert';
import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/providers/database_providers.dart';

/// HRM Repository — all employee & HR business logic.
class HrmRepository {
  HrmRepository(this._db);

  final AppDatabase _db;
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
  }) =>
      _db.hrmDao.updateLeave(
        leave.toCompanion(true).copyWith(
          status: drift.Value(newStatus),
          approvedById: drift.Value(approverId),
          approvedByName: drift.Value(approverName),
          updatedAt: drift.Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

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
  return HrmRepository(db);
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
