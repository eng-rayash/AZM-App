import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/routine_tasks_table.dart';

part 'routine_tasks_dao.g.dart';

/// Data Access Object for RoutineTasks and RoutineCompletions tables.
@DriftAccessor(tables: [RoutineTasks, RoutineCompletions])
class RoutineTasksDao extends DatabaseAccessor<AppDatabase>
    with _$RoutineTasksDaoMixin {
  RoutineTasksDao(super.db);

  // ─── Routine Tasks CRUD ───────────────────────────────────────

  /// Watch all active (non-deleted) routine tasks
  Stream<List<RoutineTaskData>> watchAllActive() =>
      (select(routineTasks)
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.priority)]))
          .watch();

  /// Get all active routine tasks (one-shot)
  Future<List<RoutineTaskData>> getAllActive() =>
      (select(routineTasks)
            ..where((t) => t.isDeleted.equals(false))
            ..orderBy([(t) => OrderingTerm.asc(t.priority)]))
          .get();

  /// Insert a new routine task
  Future<int> insertRoutineTask(RoutineTasksCompanion task) =>
      into(routineTasks).insert(task);

  /// Update a routine task
  Future<bool> updateRoutineTask(RoutineTasksCompanion task, int id) =>
      (update(routineTasks)..where((t) => t.id.equals(id)))
          .write(task)
          .then((rows) => rows > 0);

  /// Soft-delete a routine task and its completions
  Future<void> softDeleteRoutineTask(int id) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await (update(routineTasks)..where((t) => t.id.equals(id))).write(
      RoutineTasksCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(now),
      ),
    );
  }

  /// Reorder tasks by updating their updatedAt (order is managed in memory)
  Future<void> updateTask(int id, RoutineTasksCompanion companion) =>
      (update(routineTasks)..where((t) => t.id.equals(id))).write(companion);

  // ─── Completions ─────────────────────────────────────────────

  /// Watch all completions
  Stream<List<RoutineCompletionData>> watchAllCompletions() =>
      select(routineCompletions).watch();

  /// Get all completions (one-shot)
  Future<List<RoutineCompletionData>> getAllCompletions() =>
      select(routineCompletions).get();

  /// Insert a completion record
  Future<int> insertCompletion(RoutineCompletionsCompanion completion) =>
      into(routineCompletions).insert(completion);

  /// Delete a specific completion (un-check)
  Future<int> deleteCompletion(String taskSyncId, String dateKey) =>
      (delete(routineCompletions)
            ..where((c) =>
                c.routineTaskSyncId.equals(taskSyncId) &
                c.dateKey.equals(dateKey)))
          .go();

  /// Check if a task is completed on a given date
  Future<bool> isCompleted(String taskSyncId, String dateKey) async {
    final row = await (select(routineCompletions)
          ..where((c) =>
              c.routineTaskSyncId.equals(taskSyncId) &
              c.dateKey.equals(dateKey)))
        .getSingleOrNull();
    return row != null;
  }

  /// Delete completions older than [cutoffDate] to keep storage lean
  Future<int> deleteOldCompletions(String cutoffDateKey) =>
      (delete(routineCompletions)
            ..where((c) => c.dateKey.isSmallerThanValue(cutoffDateKey)))
          .go();

  /// Delete all completions for a deleted task
  Future<int> deleteCompletionsForTask(String taskSyncId) =>
      (delete(routineCompletions)
            ..where((c) => c.routineTaskSyncId.equals(taskSyncId)))
          .go();
}
