import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_database.dart';
import '../dao/app_settings_dao.dart';
import '../dao/directives_dao.dart';
import '../dao/follow_ups_dao.dart';
import '../dao/meetings_dao.dart';
import '../dao/security_logs_dao.dart';
import '../dao/tasks_dao.dart';
import '../dao/users_dao.dart';

/// Core Database Provider
/// 
/// Provides the single instance of AppDatabase.
final databaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

/// DAO Providers
final usersDaoProvider = Provider<UsersDao>((ref) {
  return ref.watch(databaseProvider).usersDao;
});

final meetingsDaoProvider = Provider<MeetingsDao>((ref) {
  return ref.watch(databaseProvider).meetingsDao;
});

final securityLogsDaoProvider = Provider<SecurityLogsDao>((ref) {
  return ref.watch(databaseProvider).securityLogsDao;
});

final appSettingsDaoProvider = Provider<AppSettingsDao>((ref) {
  return ref.watch(databaseProvider).appSettingsDao;
});

final tasksDaoProvider = Provider<TasksDao>((ref) {
  return ref.watch(databaseProvider).tasksDao;
});

final followUpsDaoProvider = Provider<FollowUpsDao>((ref) {
  return ref.watch(databaseProvider).followUpsDao;
});

final directivesDaoProvider = Provider<DirectivesDao>((ref) {
  return ref.watch(databaseProvider).directivesDao;
});

// Phase 3
final archiveDaoProvider = Provider((ref) => ref.watch(databaseProvider).archiveDao);
final appointmentsDaoProvider = Provider((ref) => ref.watch(databaseProvider).appointmentsDao);
final contactsDaoProvider = Provider((ref) => ref.watch(databaseProvider).contactsDao);

// Phase 4
final callsDaoProvider = Provider((ref) => ref.watch(databaseProvider).callsDao);
final visitorsDaoProvider = Provider((ref) => ref.watch(databaseProvider).visitorsDao);
final notesDaoProvider = Provider((ref) => ref.watch(databaseProvider).notesDao);