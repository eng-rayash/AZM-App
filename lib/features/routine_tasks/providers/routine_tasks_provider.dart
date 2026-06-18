import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/providers/database_providers.dart';
import '../domain/routine_task_model.dart';

const _uuid = Uuid();

// ─────────────────────────────────────────────────────────────────
// State
// ─────────────────────────────────────────────────────────────────

class RoutineTasksState {
  final List<RoutineTask> tasks;
  final List<RoutineCompletion> completions;
  final bool isLoading;

  const RoutineTasksState({
    this.tasks = const [],
    this.completions = const [],
    this.isLoading = true,
  });

  RoutineTasksState copyWith({
    List<RoutineTask>? tasks,
    List<RoutineCompletion>? completions,
    bool? isLoading,
  }) =>
      RoutineTasksState(
        tasks: tasks ?? this.tasks,
        completions: completions ?? this.completions,
        isLoading: isLoading ?? this.isLoading,
      );

  /// Returns tasks visible for [date] based on their repeat schedule.
  List<RoutineTask> tasksForDate(DateTime date) {
    final weekday = date.weekday; // 1=Mon..7=Sun
    return tasks
        .where((t) => t.isActive && t.repeat.isActiveOn(weekday, t.daysOfWeek))
        .toList()
      ..sort((a, b) {
        final aCompleted = isCompletedOn(a.id, date);
        final bCompleted = isCompletedOn(b.id, date);
        if (aCompleted != bCompleted) return aCompleted ? 1 : -1;
        final priorityCompare =
            a.priority.index.compareTo(b.priority.index);
        if (priorityCompare != 0) return priorityCompare;
        return (a.time ?? '').compareTo(b.time ?? '');
      });
  }

  bool isCompletedOn(String taskId, DateTime date) {
    final key = _dateKey(date);
    return completions
        .any((c) => c.taskId == taskId && c.dateKey == key);
  }

  int totalForDate(DateTime date) => tasksForDate(date).length;
  int completedForDate(DateTime date) =>
      tasksForDate(date).where((t) => isCompletedOn(t.id, date)).length;
  double completionRatioForDate(DateTime date) {
    final total = totalForDate(date);
    if (total == 0) return 0.0;
    return completedForDate(date) / total;
  }

  int streakForToday() {
    final today = DateTime.now();
    int streak = 0;
    DateTime cursor = today;
    for (int i = 0; i < 365; i++) {
      final dayTasks = tasksForDate(cursor);
      if (dayTasks.isEmpty) {
        cursor = cursor.subtract(const Duration(days: 1));
        continue;
      }
      final allCompleted =
          dayTasks.every((t) => isCompletedOn(t.id, cursor));
      if (!allCompleted) break;
      streak++;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }
}

String _dateKey(DateTime d) => DateFormat('yyyy-MM-dd').format(d);

// ─────────────────────────────────────────────────────────────────
// Helpers: DB ↔ Domain conversion
// ─────────────────────────────────────────────────────────────────

RoutineTask _dbRowToModel(RoutineTaskData row) => RoutineTask(
      id: row.syncId,
      title: row.title,
      description: row.description,
      category: RoutineCategory.values.firstWhere(
        (c) => c.name == row.category,
        orElse: () => RoutineCategory.personal,
      ),
      priority: row.priority >= 0 && row.priority < RoutinePriority.values.length
          ? RoutinePriority.values[row.priority]
          : RoutinePriority.medium,
      repeat: RoutineRepeat.values.firstWhere(
        (r) => r.name == row.repeat,
        orElse: () => RoutineRepeat.daily,
      ),
      time: row.time,
      daysOfWeek: _parseDaysOfWeek(row.daysOfWeek),
      isActive: row.isActive,
      createdAt: DateTime.fromMillisecondsSinceEpoch(row.createdAt),
    );

List<int> _parseDaysOfWeek(String raw) {
  try {
    final list = (raw.replaceAll('[', '').replaceAll(']', '').split(','))
        .where((s) => s.trim().isNotEmpty)
        .map((s) => int.parse(s.trim()))
        .toList();
    return list;
  } catch (_) {
    return [];
  }
}

String _encodeDaysOfWeek(List<int> days) =>
    '[${days.join(',')}]';

RoutineCompletion _completionRow(RoutineCompletionData row) =>
    RoutineCompletion(taskId: row.routineTaskSyncId, dateKey: row.dateKey);

// ─────────────────────────────────────────────────────────────────
// Notifier
// ─────────────────────────────────────────────────────────────────

class RoutineTasksNotifier extends StateNotifier<RoutineTasksState> {
  RoutineTasksNotifier(this._ref) : super(const RoutineTasksState()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final db = _ref.read(databaseProvider);
    final rows = await db.routineTasksDao.getAllActive();
    final completionRows = await db.routineTasksDao.getAllCompletions();

    List<RoutineTask> tasks;
    if (rows.isEmpty) {
      // First launch: seed default tasks
      await _seedDefaultTasks(db);
      final seeded = await db.routineTasksDao.getAllActive();
      tasks = seeded.map(_dbRowToModel).toList();
    } else {
      tasks = rows.map(_dbRowToModel).toList();
    }

    // Prune completions older than 60 days
    final cutoff = DateTime.now().subtract(const Duration(days: 60));
    final cutoffKey = _dateKey(cutoff);
    await db.routineTasksDao.deleteOldCompletions(cutoffKey);

    final completions = completionRows
        .where((c) {
          final date = DateTime.tryParse(c.dateKey);
          return date != null && date.isAfter(cutoff);
        })
        .map(_completionRow)
        .toList();

    state = RoutineTasksState(
      tasks: tasks,
      completions: completions,
      isLoading: false,
    );
  }

  Future<void> _seedDefaultTasks(AppDatabase db) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    final defaults = [
      (
        title: 'مراجعة البريد الإلكتروني',
        desc: 'قراءة والرد على الرسائل الضرورية',
        cat: 'work',
        pri: 'high',
        rep: 'weekdays',
        time: '08:00',
      ),
      (
        title: 'قراءة التقارير اليومية',
        desc: 'مراجعة أهم المستجدات والتقارير',
        cat: 'work',
        pri: 'high',
        rep: 'weekdays',
        time: '09:00',
      ),
      (
        title: 'ممارسة الرياضة',
        desc: '30 دقيقة مشي أو تمارين',
        cat: 'health',
        pri: 'medium',
        rep: 'daily',
        time: '07:00',
      ),
      (
        title: 'قراءة مفيدة',
        desc: 'قراءة كتاب أو مقالة متخصصة',
        cat: 'learning',
        pri: 'low',
        rep: 'daily',
        time: '21:00',
      ),
    ];

    for (final d in defaults) {
      await db.routineTasksDao.insertRoutineTask(
        RoutineTasksCompanion.insert(
          syncId: _uuid.v4(),
          title: d.title,
          description: Value(d.desc),
          category: Value(d.cat),
          priority: Value(RoutinePriority.values
              .firstWhere((p) => p.name == d.pri,
                  orElse: () => RoutinePriority.medium)
              .index),
          repeat: Value(d.rep),
          time: Value(d.time),
          daysOfWeek: const Value('[]'),
          isActive: const Value(true),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  // ─── CRUD ───

  Future<void> addTask(RoutineTask task) async {
    final db = _ref.read(databaseProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.routineTasksDao.insertRoutineTask(
      RoutineTasksCompanion.insert(
        syncId: task.id,
        title: task.title,
        description: Value(task.description),
        category: Value(task.category.name),
        priority: Value(task.priority.index),
        repeat: Value(task.repeat.name),
        time: Value(task.time),
        daysOfWeek: Value(_encodeDaysOfWeek(task.daysOfWeek)),
        isActive: Value(task.isActive),
        createdAt: now,
        updatedAt: now,
      ),
    );
    state = state.copyWith(tasks: [...state.tasks, task]);
  }

  Future<void> updateTask(RoutineTask updated) async {
    final db = _ref.read(databaseProvider);
    final now = DateTime.now().millisecondsSinceEpoch;
    // Find the DB id by syncId
    final all = await db.routineTasksDao.getAllActive();
    final row = all.firstWhere((r) => r.syncId == updated.id,
        orElse: () => throw StateError('Task not found: ${updated.id}'));
    await db.routineTasksDao.updateTask(
      row.id,
      RoutineTasksCompanion(
        title: Value(updated.title),
        description: Value(updated.description),
        category: Value(updated.category.name),
        priority: Value(updated.priority.index),
        repeat: Value(updated.repeat.name),
        time: Value(updated.time),
        daysOfWeek: Value(_encodeDaysOfWeek(updated.daysOfWeek)),
        isActive: Value(updated.isActive),
        updatedAt: Value(now),
      ),
    );
    final tasks =
        state.tasks.map((t) => t.id == updated.id ? updated : t).toList();
    state = state.copyWith(tasks: tasks);
  }

  Future<void> deleteTask(String id) async {
    final db = _ref.read(databaseProvider);
    final all = await db.routineTasksDao.getAllActive();
    final row = all.firstWhere((r) => r.syncId == id,
        orElse: () => throw StateError('Task not found: $id'));
    await db.routineTasksDao.softDeleteRoutineTask(row.id);
    await db.routineTasksDao.deleteCompletionsForTask(id);

    final tasks = state.tasks.where((t) => t.id != id).toList();
    final completions =
        state.completions.where((c) => c.taskId != id).toList();
    state = state.copyWith(tasks: tasks, completions: completions);
  }

  Future<void> toggleTask(String taskId, DateTime date) async {
    final db = _ref.read(databaseProvider);
    final key = _dateKey(date);
    final now = DateTime.now().millisecondsSinceEpoch;

    List<RoutineCompletion> completions;
    if (state.isCompletedOn(taskId, date)) {
      await db.routineTasksDao.deleteCompletion(taskId, key);
      completions = state.completions
          .where((c) => !(c.taskId == taskId && c.dateKey == key))
          .toList();
    } else {
      await db.routineTasksDao.insertCompletion(
        RoutineCompletionsCompanion.insert(
          syncId: _uuid.v4(),
          routineTaskSyncId: taskId,
          dateKey: key,
          createdAt: now,
          updatedAt: now,
        ),
      );
      completions = [
        ...state.completions,
        RoutineCompletion(taskId: taskId, dateKey: key),
      ];
    }
    state = state.copyWith(completions: completions);
  }

  Future<void> reorderTasks(List<RoutineTask> reordered) async {
    state = state.copyWith(tasks: reordered);
    // Order is managed in-memory; no DB change needed for reorder
  }
}

// ─────────────────────────────────────────────────────────────────
// Providers
// ─────────────────────────────────────────────────────────────────

final routineTasksProvider =
    StateNotifierProvider<RoutineTasksNotifier, RoutineTasksState>(
  (ref) => RoutineTasksNotifier(ref),
);

/// Selected date for the routine tasks screen
final routineSelectedDateProvider =
    StateProvider<DateTime>((ref) => DateTime.now());

/// New task form factory helper
RoutineTask buildNewRoutineTask({
  required String title,
  String? description,
  required RoutineCategory category,
  required RoutinePriority priority,
  required RoutineRepeat repeat,
  String? time,
  List<int> daysOfWeek = const [],
}) {
  return RoutineTask(
    id: const Uuid().v4(),
    title: title,
    description: description,
    category: category,
    priority: priority,
    repeat: repeat,
    time: time,
    daysOfWeek: daysOfWeek,
    createdAt: DateTime.now(),
  );
}
