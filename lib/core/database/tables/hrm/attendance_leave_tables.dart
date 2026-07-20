import 'package:drift/drift.dart';
import '../base_table.dart';

/// Attendance Records table — daily employee check-in/out.
class AttendanceRecords extends Table with BaseTableMixin {
  IntColumn get employeeId => integer()();
  TextColumn get employeeName => text().nullable()(); // cached
  TextColumn get date => text()(); // YYYY-MM-DD
  TextColumn get checkIn => text().nullable()(); // HH:mm
  TextColumn get checkOut => text().nullable()(); // HH:mm
  RealColumn get workingHours => real().nullable()();
  /// status: 0=present, 1=absent, 2=late, 3=half-day, 4=on-leave, 5=holiday
  IntColumn get status => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  IntColumn get branchId => integer().nullable()();
}

/// Leave Requests table.
class LeaveRequests extends Table with BaseTableMixin {
  IntColumn get employeeId => integer()();
  TextColumn get employeeName => text().nullable()(); // cached
  /// leaveType: 0=annual, 1=sick, 2=emergency, 3=maternity/paternity,
  ///            4=unpaid, 5=compensatory, 6=other
  IntColumn get leaveType => integer().withDefault(const Constant(0))();
  TextColumn get startDate => text()();
  TextColumn get endDate => text()();
  IntColumn get days => integer().withDefault(const Constant(1))();
  TextColumn get reason => text().nullable()();
  /// status: 0=pending, 1=approved, 2=rejected, 3=cancelled
  IntColumn get status => integer().withDefault(const Constant(0))();
  IntColumn get approvedById => integer().nullable()();
  TextColumn get approvedByName => text().nullable()(); // cached
  TextColumn get approvalDate => text().nullable()();
  TextColumn get approvalNotes => text().nullable()();
  TextColumn get attachments => text().nullable()(); // JSON array
  TextColumn get notes => text().nullable()();
}

/// Employee Leave Balance table (annual balance tracking).
class LeaveBalances extends Table with BaseTableMixin {
  IntColumn get employeeId => integer()();
  IntColumn get year => integer()();
  /// leaveType: same as LeaveRequests.leaveType
  IntColumn get leaveType => integer().withDefault(const Constant(0))();
  RealColumn get totalDays => real().withDefault(const Constant(0.0))();
  RealColumn get usedDays => real().withDefault(const Constant(0.0))();
  RealColumn get remainingDays => real().withDefault(const Constant(0.0))();
}

/// Employee Advances (Salary Advances) table.
class EmployeeAdvances extends Table with BaseTableMixin {
  IntColumn get employeeId => integer()();
  TextColumn get employeeName => text().nullable()(); // cached
  RealColumn get amount => real().withDefault(const Constant(0.0))();
  TextColumn get requestDate => text()();
  TextColumn get reason => text().nullable()();
  /// repaymentPlan: JSON [{month, year, amount}]
  TextColumn get repaymentPlan => text().nullable()();
  RealColumn get repaidAmount => real().withDefault(const Constant(0.0))();
  /// status: 0=pending, 1=approved, 2=rejected, 3=fully-repaid
  IntColumn get status => integer().withDefault(const Constant(0))();
  TextColumn get approvalDate => text().nullable()();
  TextColumn get notes => text().nullable()();
}
