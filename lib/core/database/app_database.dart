import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

// Platform-conditional connection:
//   web    → connection/web.dart    (drift/wasm.dart — no dart:ffi)
//   native → connection/native.dart (drift_flutter   — uses sqlite3)
import 'connection/shared.dart'
    if (dart.library.html) 'connection/web.dart'
    if (dart.library.io)   'connection/native.dart';

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

// ── Phase 7b — Finance ───────────────────────────────────────────────
import 'tables/finance/parties_tables.dart';
import 'tables/finance/transactions_tables.dart';
import 'tables/finance/accounting_tables.dart';
import 'tables/projects_table.dart';
import 'tables/entity_links_table.dart';
import 'dao/finance_dao.dart';

// ── Phase 8 — RVIOS Multi-Tenant ───────────────────────────────────
import 'tables/tenant/companies_table.dart';
import 'tables/tenant/company_members_table.dart';
import 'tables/tenant/invitations_table.dart';
import 'tables/tenant/audit_logs_table.dart';
import 'dao/companies_dao.dart';

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
/// v6  — Phase 6a: FollowUps new columns, Meetings new columns
/// v7  — Phase 6b: HRM core tables
/// v8  — Phase 6c: HRM extended tables
/// v9  — Phase 7: Finance tables
/// v10 — Phase 7b: Projects, EntityLinks
/// v11 — RVIOS Platform: Companies, CompanyMembers, Invitations, AuditLogs
///        Users table extended (accountType, employeeCode, email, username...)
/// v12 — AZM: عمود `companyId` على ٤١ جدول أعمال + شركة محلية افتراضية
///        تُملأ بها الصفوف القائمة، فلا تُيتَّم بيانات مستخدم قائم.
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
    // ── Projects & Links ───────────────────────────────────────────
    Projects,
    EntityLinks,
    // ── RVIOS Multi-Tenant ──────────────────────────────────────────
    Companies,
    CompanyMembers,
    Invitations,
    AuditLogs,
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
    // RVIOS Multi-Tenant
    CompaniesDao,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Named constructor for testing with a custom executor
  AppDatabase.forTesting(super.e);


  @override
  int get schemaVersion => 12; // AZM v12 — tenant scope

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
          // ── v9 → v10: Projects + Entity Links ────────────────────────
          if (from < 10) {
            try { await m.createTable(projects); } catch (_) {}
            try { await m.createTable(entityLinks); } catch (_) {}
          }
          // ── v10 → v11: RVIOS Multi-Tenant ────────────────────────
          if (from < 11) {
            // New tenant tables
            try { await m.createTable(companies); } catch (_) {}
            try { await m.createTable(companyMembers); } catch (_) {}
            try { await m.createTable(invitations); } catch (_) {}
            try { await m.createTable(auditLogs); } catch (_) {}
            // Users table extended columns
            try { await m.addColumn(users, users.firstName); } catch (_) {}
            try { await m.addColumn(users, users.lastName); } catch (_) {}
            try { await m.addColumn(users, users.username); } catch (_) {}
            try { await m.addColumn(users, users.email); } catch (_) {}
            try { await m.addColumn(users, users.passwordHash); } catch (_) {}
            try { await m.addColumn(users, users.phone); } catch (_) {}
            try { await m.addColumn(users, users.accountType); } catch (_) {}
            try { await m.addColumn(users, users.activeCompanySyncId); } catch (_) {}
            try { await m.addColumn(users, users.employeeCode); } catch (_) {}
            try { await m.addColumn(users, users.workspaceSlug); } catch (_) {}
            try { await m.addColumn(users, users.avatarUrl); } catch (_) {}
            try { await m.addColumn(users, users.language); } catch (_) {}
            try { await m.addColumn(users, users.timezone); } catch (_) {}
            try { await m.addColumn(users, users.country); } catch (_) {}
            try { await m.addColumn(users, users.onboardingCompleted); } catch (_) {}
            try { await m.addColumn(users, users.mustChangePassword); } catch (_) {}
            try { await m.addColumn(users, users.supabaseUid); } catch (_) {}
            try { await m.addColumn(users, users.lastSyncedAt); } catch (_) {}
          }
          // ── v11 → v12: نطاق المستأجر ──────────────────────────────
          //
          // عمود `companyId` على كل جدول أعمال. الصفوف القائمة تُملأ
          // بشركة محلية افتراضية في `beforeOpen` بعد اكتمال الهجرة —
          // لا هنا، لأن `Migrator` لا يضمن جاهزية الجداول للقراءة أثناءه.
          if (from < 12) {
            for (final table in _tenantScopedTables) {
              try {
                await m.addColumn(
                  table,
                  table.columnsByName['company_id']!,
                );
              } catch (_) {
                // العمود موجود سلفًا — هجرة أُعيد تشغيلها
              }
            }
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
          // ينسب كل صفّ بلا مالك إلى الشركة المحلية — عند الترقية
          // وعند الإنشاء معًا، فقاعدة جديدة تحتاجها أيضًا.
          await _backfillLocalTenant();
        },
      );

  /// الجداول التي تحمل [TenantScoped] — تُشتقّ من المخطط لا تُعدَّد يدويًا.
  ///
  /// قائمة مكتوبة بخطّ اليد تتخلّف عن المخطط بصمت: يُضاف جدول جديد
  /// فيُنسى من الهجرة ومن مرشّح العزل معًا.
  List<TableInfo<Table, dynamic>> get _tenantScopedTables => allTables
      .where((t) => t.columnsByName.containsKey('company_id'))
      .toList();

  /// الشركة المحلية الافتراضية.
  ///
  /// قواعد المستخدمين القائمة فيها صفوف سابقة على تعدّد المستأجرين.
  /// تُنسب إلى هذه الشركة بدل أن تُترك بلا مالك فتختفي عن كل استعلام
  /// مُقيَّد. تُستبدل بشركة حقيقية عند أول إنشاء أو انضمام.
  static const String localCompanyId = 'local-company-default---------------';

  /// ينشئ الشركة المحلية إن غابت، ثم ينسب إليها كل صفّ بلا مالك.
  ///
  /// يعمل بعد اكتمال الهجرة لا أثناءها: `Migrator` لا يضمن جاهزية
  /// الجداول للقراءة، وتنفيذ `UPDATE` داخله سلوك غير معرَّف.
  Future<void> _backfillLocalTenant() async {
    try {
      final existing = await (select(companies)
            ..where((c) => c.syncId.equals(localCompanyId))
            ..limit(1))
          .getSingleOrNull();

      if (existing == null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        await into(companies).insert(
          CompaniesCompanion.insert(
            syncId: localCompanyId,
            companyCode: 'LOCAL',
            name: 'مساحة العمل المحلية',
            workspaceSlug: 'local',
            ownerSyncId: localCompanyId,
            createdAt: now,
            updatedAt: now,
          ),
          mode: InsertMode.insertOrIgnore,
        );
      }

      for (final table in _tenantScopedTables) {
        await customUpdate(
          'UPDATE "${table.actualTableName}" '
          'SET company_id = ? WHERE company_id IS NULL',
          variables: [Variable.withString(localCompanyId)],
          updates: {table},
        );
      }
    } catch (e) {
      // الملء أفضل جهد: فشله يترك صفوفًا بلا مالك، ولا يمنع الإقلاع.
      debugPrint('[DB] backfill local tenant: $e');
    }
  }

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

/// Opens a platform-appropriate database connection.
/// - Web builds: uses WasmDatabase.inMemory() — no dart:ffi
/// - Native builds: uses drift_flutter (sqlite3 file) — works on Android/iOS/Desktop
QueryExecutor _openConnection() {
  return connectDb(AppConstants.dbName);
}
