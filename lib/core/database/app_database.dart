import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../constants/app_constants.dart';
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

// Phase 4 Tables
import 'tables/calls_table.dart';
import 'tables/visitors_table.dart';
import 'tables/notes_table.dart';
import 'tables/movements_table.dart';

// Phase 4 DAOs
import 'dao/calls_dao.dart';
import 'dao/visitors_dao.dart';
import 'dao/notes_dao.dart';
import 'dao/movements_dao.dart';

// Phase 5 — Routine Tasks
import 'tables/routine_tasks_table.dart';
import 'dao/routine_tasks_dao.dart';

part 'app_database.g.dart';

/// Main Drift database for the Mudiri application.
///
/// All tables are registered here with their DAOs.
/// Uses native SQLite (SQLCipher integration is configured via
/// the sqlite3_flutter_libs / sqlcipher_flutter_libs package).
@DriftDatabase(
  tables: [
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
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Named constructor for testing with a custom executor
  AppDatabase.forTesting(super.e);

  late final $RoutineTasksTable routineTasks = $RoutineTasksTable(this);
  late final $RoutineCompletionsTable routineCompletions = $RoutineCompletionsTable(this);
  late final RoutineTasksDao routineTasksDao = RoutineTasksDao(this);

  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        ...super.allSchemaEntities,
        routineTasks,
        routineCompletions,
      ];


  @override
  int get schemaVersion => AppConstants.dbVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
        },
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            try { await m.createTable(movements); } catch (_) {}
            try { await m.createTable(calls); } catch (_) {}
            try { await m.createTable(visitors); } catch (_) {}
            try { await m.createTable(notes); } catch (_) {}
          }
          if (from < 3) {
            try {
              await m.addColumn(archive, archive.hijriDate);
              await m.addColumn(archive, archive.documentDate);
              await m.addColumn(archive, archive.directedEntity);
              await m.addColumn(archive, archive.notes);
            } catch (_) {}
          }
          if (from < 4) {
            try {
              await m.addColumn(meetings, meetings.customMeetingType);
            } catch (_) {}
          }
          if (from < 5) {
            // Phase 5: Routine Tasks DB tables
            try { await m.createTable(routineTasks); } catch (_) {}
            try { await m.createTable(routineCompletions); } catch (_) {}
          }
        },
        beforeOpen: (details) async {
          // Enable foreign keys
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );
}

/// Opens a connection to the SQLite database file.
///
/// The database is stored in the app's documents directory.
/// In production, this will be wrapped with SQLCipher encryption.
LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, AppConstants.dbName));
    return NativeDatabase.createInBackground(file);
  });
}
