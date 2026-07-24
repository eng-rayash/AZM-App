import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/meetings_table.dart';

part 'meetings_dao.g.dart';

/// Data Access Object for the Meetings table.
///
/// Provides comprehensive CRUD, filtering, and search operations.
/// All queries exclude soft-deleted records by default.
@DriftAccessor(tables: [Meetings])
class MeetingsDao extends DatabaseAccessor<AppDatabase>
    with _$MeetingsDaoMixin {
  MeetingsDao(super.db);

  // ─────────────────────────────────────────────
  // Read Operations
  // ─────────────────────────────────────────────

  /// Get all active meetings, ordered by date descending
  Future<List<Meeting>> getAllActive() => (select(meetings)
        ..where((m) => m.isDeleted.equals(false))
        ..orderBy([
          (m) => OrderingTerm.desc(m.date),
          (m) => OrderingTerm.desc(m.time),
        ]))
      .get();

  /// Watch all active meetings (reactive)
  Stream<List<Meeting>> watchAllActive() => (select(meetings)
        ..where((m) => m.isDeleted.equals(false))
        ..orderBy([
          (m) => OrderingTerm.desc(m.date),
          (m) => OrderingTerm.desc(m.time),
        ]))
      .watch();

  /// Get meeting by ID
  Future<Meeting?> getById(int id) =>
      (select(meetings)..where((m) => m.id.equals(id))).getSingleOrNull();

  /// Watch single meeting by ID
  Stream<Meeting?> watchById(int id) =>
      (select(meetings)..where((m) => m.id.equals(id))).watchSingleOrNull();

  /// Get today's meetings
  Future<List<Meeting>> getTodayMeetings(String todayDate) => (select(meetings)
        ..where((m) =>
            m.isDeleted.equals(false) & m.date.equals(todayDate))
        ..orderBy([(m) => OrderingTerm.asc(m.time)]))
      .get();

  /// Watch today's meetings (reactive)
  Stream<List<Meeting>> watchTodayMeetings(String todayDate) =>
      (select(meetings)
            ..where((m) =>
                m.isDeleted.equals(false) & m.date.equals(todayDate))
            ..orderBy([(m) => OrderingTerm.asc(m.time)]))
          .watch();

  /// Get meetings by status
  Future<List<Meeting>> getByStatus(int status) => (select(meetings)
        ..where(
            (m) => m.isDeleted.equals(false) & m.status.equals(status))
        ..orderBy([
          (m) => OrderingTerm.desc(m.date),
        ]))
      .get();

  /// Get upcoming meetings (from today forward)
  Future<List<Meeting>> getUpcoming(String fromDate) => (select(meetings)
        ..where((m) =>
            m.isDeleted.equals(false) &
            m.date.isBiggerOrEqualValue(fromDate) &
            m.status.isIn([0, 1])) // scheduled or in progress
        ..orderBy([
          (m) => OrderingTerm.asc(m.date),
          (m) => OrderingTerm.asc(m.time),
        ])
        ..limit(10))
      .get();

  /// Watch upcoming meetings
  Stream<List<Meeting>> watchUpcoming(String fromDate) => (select(meetings)
        ..where((m) =>
            m.isDeleted.equals(false) &
            m.date.isBiggerOrEqualValue(fromDate) &
            m.status.isIn([0, 1]))
        ..orderBy([
          (m) => OrderingTerm.asc(m.date),
          (m) => OrderingTerm.asc(m.time),
        ])
        ..limit(10))
      .watch();

  /// Search meetings by title or notes
  Future<List<Meeting>> search(String query) => (select(meetings)
        ..where((m) =>
            m.isDeleted.equals(false) &
            (m.title.contains(query) |
                m.notes.contains(query) |
                m.objective.contains(query)))
        ..orderBy([(m) => OrderingTerm.desc(m.date)])
        ..limit(50))
      .get();

  /// Get meetings count by status (for stats)
  Future<int> countByStatus(int status) async {
    final count = await (selectOnly(meetings)
          ..addColumns([meetings.id.count()])
          ..where(meetings.isDeleted.equals(false) &
              meetings.status.equals(status)))
        .map((row) => row.read(meetings.id.count()))
        .getSingle();
    return count ?? 0;
  }

  /// Get total active meetings count
  Future<int> countAll() async {
    final count = await (selectOnly(meetings)
          ..addColumns([meetings.id.count()])
          ..where(meetings.isDeleted.equals(false)))
        .map((row) => row.read(meetings.id.count()))
        .getSingle();
    return count ?? 0;
  }

  // ─────────────────────────────────────────────
  // Write Operations
  // ─────────────────────────────────────────────

  /// Insert a new meeting
  Future<int> insertMeeting(MeetingsCompanion meeting) =>
      into(meetings).insert(meeting);

  /// Update meeting
  Future<bool> updateMeeting(MeetingsCompanion meeting, int id) =>
      (update(meetings)..where((m) => m.id.equals(id)))
          .write(meeting)
          .then((rows) => rows > 0);

  /// Update meeting status
  Future<void> updateStatus(int id, int status) =>
      (update(meetings)..where((m) => m.id.equals(id))).write(
        MeetingsCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Soft delete meeting
  Future<void> softDelete(int id) =>
      (update(meetings)..where((m) => m.id.equals(id))).write(
        MeetingsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Restore soft-deleted meeting
  Future<void> restore(int id) =>
      (update(meetings)..where((m) => m.id.equals(id))).write(
        MeetingsCompanion(
          isDeleted: const Value(false),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Get meetings in date range
  Future<List<Meeting>> getByDateRange(String from, String to) =>
      (select(meetings)
            ..where((m) =>
                m.isDeleted.equals(false) &
                m.date.isBiggerOrEqualValue(from) &
                m.date.isSmallerOrEqualValue(to))
            ..orderBy([(m) => OrderingTerm.asc(m.date)]))
          .get();
}