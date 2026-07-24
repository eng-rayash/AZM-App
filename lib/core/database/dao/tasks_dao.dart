import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/tasks_table.dart';

part 'tasks_dao.g.dart';

/// Data Access Object for the Tasks table.
@DriftAccessor(tables: [Tasks])
class TasksDao extends DatabaseAccessor<AppDatabase> with _$TasksDaoMixin {
  TasksDao(super.db);

  /// Get all active tasks
  Future<List<Task>> getAllActive() => (select(tasks)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([
          (t) => OrderingTerm.asc(t.status), // New & InProgress first
          (t) => OrderingTerm.asc(t.priority), // Critical first
        ]))
      .get();

  /// Watch all active tasks
  Stream<List<Task>> watchAllActive() => (select(tasks)
        ..where((t) => t.isDeleted.equals(false))
        ..orderBy([
          (t) => OrderingTerm.asc(t.status),
          (t) => OrderingTerm.asc(t.priority),
        ]))
      .watch();

  /// Watch tasks by status
  Stream<List<Task>> watchByStatus(int status) => (select(tasks)
        ..where((t) => t.isDeleted.equals(false) & t.status.equals(status))
        ..orderBy([
          (t) => OrderingTerm.asc(t.priority),
          (t) => OrderingTerm.desc(t.createdAt),
        ]))
      .watch();

  /// Watch tasks linked to a specific meeting
  Stream<List<Task>> watchByMeetingId(int meetingId) => (select(tasks)
        ..where((t) => t.isDeleted.equals(false) & t.linkedMeetingId.equals(meetingId))
        ..orderBy([(t) => OrderingTerm.asc(t.createdAt)]))
      .watch();

  /// Get task by ID
  Future<Task?> getById(int id) =>
      (select(tasks)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Watch task by ID
  Stream<Task?> watchById(int id) =>
      (select(tasks)..where((t) => t.id.equals(id))).watchSingleOrNull();

  /// Insert a new task
  Future<int> insertTask(TasksCompanion task) => into(tasks).insert(task);

  /// Update task
  Future<bool> updateTask(TasksCompanion task, int id) =>
      (update(tasks)..where((t) => t.id.equals(id)))
          .write(task)
          .then((rows) => rows > 0);

  /// Update task status
  Future<void> updateStatus(int id, int status) =>
      (update(tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Soft delete task
  Future<void> softDelete(int id) =>
      (update(tasks)..where((t) => t.id.equals(id))).write(
        TasksCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Get total active tasks count
  Future<int> countAll() async {
    final count = await (selectOnly(tasks)
          ..addColumns([tasks.id.count()])
          ..where(tasks.isDeleted.equals(false)))
        .map((row) => row.read(tasks.id.count()))
        .getSingle();
    return count ?? 0;
  }
}