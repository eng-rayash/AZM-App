import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';

// ── Core / Existing Tables ────────────────────────────────────────
import 'dao/app_settings_dao.dart';
import 'dao/appointments_dao.dart';
import 'dao/archive_dao.dart';
import 'dao/contacts_dao.dart';
import 'dao/directives_dao.dart';
import 'dao/follow_ups_dao.dart';
import 'dao/meetings_dao.dart';
import 'dao/security_logs_dao.dart';
import 'dao/tasks_dao.dart';
import 'dao/users_dao.dart';
import 'tables/app_settings_table.dart';
import 'tables/appointments_table.dart';
import 'tables/archive_table.dart';
import 'tables/contacts_table.dart';
import 'tables/directives_table.dart';
import 'tables/follow_ups_table.dart';
import 'tables/meetings_table.dart';
import 'tables/security_logs_table.dart';
import 'tables/tasks_table.dart';
import 'tables/users_table.dart';

// ── Phase 4 Tables ────────────────────────────────────────────────
import 'tables/calls_table.dart';
import 'tables/visitors_table.dart';
import 'tables/notes_table.dart';
import 'tables/movements_table.dart';
import 'dao/calls_dao.dart';
import 'dao/visitors_dao.dart';
import 'dao/notes_dao.dart';
import 'dao/movements_dao.dart';

// ── Phase 5 — Routine Tasks ───────────────────────────────────────
import 'tables/routine_tasks_table.dart';
import 'dao/routine_tasks_dao.dart';

// ── Phase 6 — HRM ─────────────────────────────────────────────────
import 'tables/hrm/employees_table.dart';
import 'tables/hrm/organization_tables.dart';
import 'tables/hrm/payroll_tables.dart';
import 'tables/hrm/attendance_leave_tables.dart';
import 'tables/hrm/performance_training_tables.dart';
import 'dao/employees_dao.dart';
import 'dao/hrm_dao.dart';

// ── Phase 7 — Finance ─────────────────────────────────────────────
import 'tables/finance/parties_tables.dart';
import 'tables/finance/transactions_tables.dart';
import 'tables/finance/accounting_tables.dart';
import 'tables/projects_table.dart';
import 'tables/entity_links_table.dart';
import 'dao/finance_dao.dart';

part 'app_database.g.dart';

/// Main Drift database for the Mudiri ERP application.
///
/// Schema version history:
/// v1  — Initial (Users, Meetings, Tasks, FollowUps, Directives, Contacts,
///        Appointments, Archive, SecurityLogs, AppSettings)
/// v2  — Phase 4: Calls, Visitors, Notes, Movements
/// v3  — Archive columns (hijriDate, documentDate, directedEntity, notes)
/// v4  — Meetings.customMeetingType
/// v5  — Phase 5: RoutineTasks, RoutineCompletions
/// v6  — Phase 6a: FollowUps new columns (followupType, linkedEntity*, etc.)
///        Meetings new columns (meetingCategory, linkedClient*, linkedProject*, etc.)
/// v7  — Phase 6b: HRM tables
///        (Employees, Departments, Branches, Positions, EmployeeContracts,
///         SalaryRecords, SalaryAllowanceTypes, SalaryDeductionTypes,
///         AttendanceRecords, LeaveRequests, LeaveBalances, EmployeeAdvances)
/// v8  — Phase 6c: HRM continued
///        (PerformanceEvaluations, TrainingRecords, EmployeeAssets,
///         RewardsPenalties)
/// v9  — Phase 7: Finance tables
///        (Clients, Suppliers, Invoices, Expenses, Revenues,
///         ChartOfAccounts, JournalEntries, BankAccounts,
///         PaymentVouchers, Checks)
/// v10 — Phase 7b: Projects, EntityLinks
@DriftDatabase(
  tables: [
    // ── Existing ─────────────────────────────────────
    Users,
    Meetings,
    Tasks,
    FollowUps,
    Directives,
    Contacts,
    Appointments,
    Archive,
    SecurityLogs,
    AppSettings,
    Calls,
    Visitors,
    Notes,
    Movements,
    RoutineTasks,
    RoutineCompletions,
    // ── HRM ──────────────────────────────────────────
    Employees,
    Departments,
    Branches,
    Positions,
    EmployeeContracts,
    SalaryRecords,
    SalaryAllowanceTypes,
    SalaryDeductionTypes,
    AttendanceRecords,
    LeaveRequests,
    LeaveBalances,
    EmployeeAdvances,
    PerformanceEvaluations,
    TrainingRecords,
    EmployeeAssets,
    RewardsPenalties,
    // ── Finance ───────────────────────────────────────
    Clients,
    Suppliers,
    Invoices,
    Expenses,
    Revenues,
    ChartOfAccounts,
    JournalEntries,
    BankAccounts,
    PaymentVouchers,
    Checks,
    // ── Projects & Links ─────────────────────────────
    Projects,
    EntityLinks,
  ],
  daos: [
    UsersDao,
    MeetingsDao,
    TasksDao,
    FollowUpsDao,
    DirectivesDao,
    ContactsDao,
    AppointmentsDao,
    ArchiveDao,
    SecurityLogsDao,
    AppSettingsDao,
    CallsDao,
    VisitorsDao,
    NotesDao,
    MovementsDao,
    RoutineTasksDao,
    // HRM
    EmployeesDao,
    HrmDao,
    // Finance
    FinanceDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Named constructor for testing with a custom executor
  AppDatabase.forTesting(super.e);


  @override
  int get schemaVersion => AppConstants.dbVersion; // 10

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          // ── v1 → v2: Phase 4 tables ─────────────────────────────
          if (from < 2) {
            try { await m.createTable(movements); } catch (_) {}
            try { await m.createTable(calls); } catch (_) {}
            try { await m.createTable(visitors); } catch (_) {}
            try { await m.createTable(notes); } catch (_) {}
          }
          // ── v2 → v3: Archive columns ─────────────────────────────
          if (from < 3) {
            try {
              await m.addColumn(archive, archive.hijriDate);
              await m.addColumn(archive, archive.documentDate);
              await m.addColumn(archive, archive.directedEntity);
              await m.addColumn(archive, archive.notes);
            } catch (_) {}
          }
          // ── v3 → v4: Meetings.customMeetingType ──────────────────
          if (from < 4) {
            try {
              await m.addColumn(meetings, meetings.customMeetingType);
            } catch (_) {}
          }
          // ── v4 → v5: Routine Tasks ───────────────────────────────
          if (from < 5) {
            try { await m.createTable(routineTasks); } catch (_) {}
            try { await m.createTable(routineCompletions); } catch (_) {}
          }
          // ── v5 → v6: FollowUps & Meetings extended columns ───────
          if (from < 6) {
            // FollowUps new columns
            try {
              await m.addColumn(followUps, followUps.followupType);
            } catch (_) {}
            try {
              await m.addColumn(followUps, followUps.linkedEntityType);
            } catch (_) {}
            try {
              await m.addColumn(followUps, followUps.linkedEntityId);
            } catch (_) {}
            try {
              await m.addColumn(followUps, followUps.linkedEntityLabel);
            } catch (_) {}
            try {
              await m.addColumn(followUps, followUps.estimatedMinutes);
            } catch (_) {}
            try {
              await m.addColumn(followUps, followUps.completedAt);
            } catch (_) {}
            try { await m.addColumn(followUps, followUps.tags); } catch (_) {}
            try {
              await m.addColumn(followUps, followUps.reminderAt);
            } catch (_) {}
            try {
              await m.addColumn(followUps, followUps.repeatRule);
            } catch (_) {}
            try {
              await m.addColumn(followUps, followUps.migratedFromTask);
            } catch (_) {}
            // Meetings new columns
            try {
              await m.addColumn(meetings, meetings.meetingCategory);
            } catch (_) {}
            try {
              await m.addColumn(meetings, meetings.linkedClientId);
            } catch (_) {}
            try {
              await m.addColumn(meetings, meetings.linkedClientName);
            } catch (_) {}
            try {
              await m.addColumn(meetings, meetings.linkedProjectId);
            } catch (_) {}
            try {
              await m.addColumn(meetings, meetings.linkedProjectName);
            } catch (_) {}
            try {
              await m.addColumn(meetings, meetings.linkedEmployeeIds);
            } catch (_) {}
            try {
              await m.addColumn(meetings, meetings.migratedFromEncounter);
            } catch (_) {}
          }
          // ── v6 → v7: HRM Core tables ─────────────────────────────
          if (from < 7) {
            try { await m.createTable(employees); } catch (_) {}
            try { await m.createTable(departments); } catch (_) {}
            try { await m.createTable(branches); } catch (_) {}
            try { await m.createTable(positions); } catch (_) {}
            try { await m.createTable(employeeContracts); } catch (_) {}
            try { await m.createTable(salaryRecords); } catch (_) {}
            try { await m.createTable(salaryAllowanceTypes); } catch (_) {}
            try { await m.createTable(salaryDeductionTypes); } catch (_) {}
            try { await m.createTable(attendanceRecords); } catch (_) {}
            try { await m.createTable(leaveRequests); } catch (_) {}
            try { await m.createTable(leaveBalances); } catch (_) {}
            try { await m.createTable(employeeAdvances); } catch (_) {}
          }
          // ── v7 → v8: HRM Extended tables ─────────────────────────
          if (from < 8) {
            try { await m.createTable(performanceEvaluations); } catch (_) {}
            try { await m.createTable(trainingRecords); } catch (_) {}
            try { await m.createTable(employeeAssets); } catch (_) {}
            try { await m.createTable(rewardsPenalties); } catch (_) {}
          }
          // ── v8 → v9: Finance tables ───────────────────────────────
          if (from < 9) {
            try { await m.createTable(clients); } catch (_) {}
            try { await m.createTable(suppliers); } catch (_) {}
            try { await m.createTable(invoices); } catch (_) {}
            try { await m.createTable(expenses); } catch (_) {}
            try { await m.createTable(revenues); } catch (_) {}
            try { await m.createTable(chartOfAccounts); } catch (_) {}
            try { await m.createTable(journalEntries); } catch (_) {}
            try { await m.createTable(bankAccounts); } catch (_) {}
            try { await m.createTable(paymentVouchers); } catch (_) {}
            try { await m.createTable(checks); } catch (_) {}
          }
          // ── v9 → v10: Projects + Entity Links ────────────────────
          if (from < 10) {
            try { await m.createTable(projects); } catch (_) {}
            try { await m.createTable(entityLinks); } catch (_) {}
          }
        },
        beforeOpen: (details) async {
          // Enable foreign key enforcement
          await customStatement('PRAGMA foreign_keys = ON');
          // Migrate Tasks → FollowUps if upgrading to v10+ for first time
          if (details.wasCreated == false &&
              details.versionBefore != null &&
              details.versionBefore! < 10) {
            await _migrateTasksToFollowUps();
          }
        },
      );

  /// Migrates all existing Task records to FollowUps with followupType=1 (مهمة).
  ///
  /// This preserves all task data during the Tasks → FollowUps merge.
  Future<void> _migrateTasksToFollowUps() async {
    try {
      final taskRows = await customSelect(
        'SELECT * FROM tasks WHERE id NOT IN '
        '(SELECT entity_id FROM follow_ups WHERE migrated_from_task = 1 AND entity_id IS NOT NULL)',
      ).get();

      for (final row in taskRows) {
        await customInsert(
          'INSERT OR IGNORE INTO follow_ups '
          '(sync_id, created_at, updated_at, is_deleted, title, notes, '
          'target_date, followup_type, entity_type, entity_id, priority, '
          'status, assigned_to, migrated_from_task) '
          'VALUES (?, ?, ?, 0, ?, ?, ?, 1, 1, ?, ?, ?, ?, 1)',
          variables: [
            Variable.withString(
              row.data['sync_id']?.toString() ??
                  'migrated-${row.data['id']}',
            ),
            Variable.withString(
              row.data['created_at']?.toString() ??
                  DateTime.now().toIso8601String(),
            ),
            Variable.withString(DateTime.now().toIso8601String()),
            Variable.withString(row.data['title']?.toString() ?? ''),
            Variable.withString(row.data['description']?.toString() ?? ''),
            Variable.withString(row.data['due_date']?.toString() ?? ''),
            Variable.withInt(row.data['id'] as int? ?? 0),
            Variable.withInt(row.data['priority'] as int? ?? 2),
            Variable.withInt(row.data['status'] as int? ?? 0),
            Variable.withString(
              row.data['assigned_to']?.toString() ?? '',
            ),
          ],
        );
      }
    } catch (e) {
      // Migration is best-effort — do not block app startup
      debugPrint('[DB Migration] Tasks → FollowUps: $e');
    }
  }
}

/// Opens a connection to the SQLite database file.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.dbName));
    return NativeDatabase.createInBackground(file);
  });
}
