import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/enums.dart';
import '../../../core/database/app_database.dart';
import '../../tasks/domain/tasks_repository.dart';
import '../../tasks/providers/tasks_provider.dart';
import '../../routine_tasks/providers/routine_tasks_provider.dart';
import '../../routine_tasks/domain/routine_task_model.dart';

/// نظام المهام الدورية — يجمع مهام العمل + مهام الروتين في لوحة التحكم

enum TaskPeriod { daily, weekly, monthly }

extension TaskPeriodArabic on TaskPeriod {
  String get arabicLabel {
    switch (this) {
      case TaskPeriod.daily:
        return 'اليوم';
      case TaskPeriod.weekly:
        return 'الأسبوع';
      case TaskPeriod.monthly:
        return 'الشهر';
    }
  }

  String get iconLabel {
    switch (this) {
      case TaskPeriod.daily:
        return '☀️';
      case TaskPeriod.weekly:
        return '📅';
      case TaskPeriod.monthly:
        return '🗓️';
    }
  }
}

/// Unified task item — wraps either a work task or a routine task
class PeriodicTaskItem {
  final Task? task;               // Work task from Tasks table
  final RoutineTask? routineTask; // Routine task from RoutineTasks table
  final bool isCompleted;
  final bool isRoutine;

  const PeriodicTaskItem({
    this.task,
    this.routineTask,
    required this.isCompleted,
    required this.isRoutine,
  });

  String get title => isRoutine ? (routineTask?.title ?? '') : (task?.title ?? '');

  int get priorityIndex =>
      isRoutine ? (routineTask?.priority.index ?? 2) : (task?.priority ?? 2);

  String get uniqueId =>
      isRoutine ? 'routine_${routineTask?.id}' : 'task_${task?.id}';
}

/// Periodic tasks state
class PeriodicTasksState {
  final List<PeriodicTaskItem> items;
  final TaskPeriod period;
  final int completedCount;
  final int totalCount;

  const PeriodicTasksState({
    required this.items,
    required this.period,
    required this.completedCount,
    required this.totalCount,
  });

  double get completionRatio => totalCount > 0 ? completedCount / totalCount : 0.0;
  int get completionPercent => (completionRatio * 100).round();
}

/// Filter work tasks by period
List<Task> _filterByPeriod(List<Task> tasks, TaskPeriod period) {
  final now = DateTime.now();
  return tasks.where((task) {
    DateTime taskDate;
    if (task.dueDate != null && task.dueDate!.isNotEmpty) {
      taskDate = DateTime.tryParse(task.dueDate!) ??
          DateTime.fromMillisecondsSinceEpoch(task.createdAt);
    } else {
      taskDate = DateTime.fromMillisecondsSinceEpoch(task.createdAt);
    }
    switch (period) {
      case TaskPeriod.daily:
        return taskDate.year == now.year &&
            taskDate.month == now.month &&
            taskDate.day == now.day;
      case TaskPeriod.weekly:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6));
        final start = DateTime(weekStart.year, weekStart.month, weekStart.day);
        final end = DateTime(weekEnd.year, weekEnd.month, weekEnd.day, 23, 59, 59);
        return !taskDate.isBefore(start) && !taskDate.isAfter(end);
      case TaskPeriod.monthly:
        return taskDate.year == now.year && taskDate.month == now.month;
    }
  }).toList();
}

// ─── Selected period tab ───

class SelectedPeriodNotifier extends StateNotifier<TaskPeriod> {
  SelectedPeriodNotifier() : super(TaskPeriod.daily);
  void setPeriod(TaskPeriod period) => state = period;
}

final selectedPeriodProvider =
    StateNotifierProvider<SelectedPeriodNotifier, TaskPeriod>(
  (ref) => SelectedPeriodNotifier(),
);

// ─── Main merged provider ───

final periodicTasksProvider = Provider<PeriodicTasksState>((ref) {
  final allWorkTasks = ref.watch(tasksListProvider).valueOrNull ?? [];
  final routineState = ref.watch(routineTasksProvider);
  final period = ref.watch(selectedPeriodProvider);
  final now = DateTime.now();

  // Work tasks filtered by period
  final filteredWork = _filterByPeriod(allWorkTasks, period);
  final workItems = filteredWork.map((task) => PeriodicTaskItem(
        task: task,
        isCompleted: task.status == UnifiedStatus.completed.value,
        isRoutine: false,
      )).toList();

  // Routine tasks
  List<PeriodicTaskItem> routineItems = [];
  if (!routineState.isLoading) {
    final routineTasks = switch (period) {
      TaskPeriod.daily => routineState.tasksForDate(now),
      TaskPeriod.weekly => routineState.tasks.where((t) => t.isActive).toList(),
      TaskPeriod.monthly => routineState.tasks.where((t) => t.isActive).toList(),
    };
    routineItems = routineTasks
        .map((rt) => PeriodicTaskItem(
              routineTask: rt,
              isCompleted: routineState.isCompletedOn(rt.id, now),
              isRoutine: true,
            ))
        .toList();
  }

  // Merge & sort: incomplete first, then by priority
  final allItems = [...workItems, ...routineItems];
  allItems.sort((a, b) {
    if (a.isCompleted != b.isCompleted) return a.isCompleted ? 1 : -1;
    return a.priorityIndex.compareTo(b.priorityIndex);
  });

  final completedCount = allItems.where((i) => i.isCompleted).length;

  return PeriodicTasksState(
    items: allItems,
    period: period,
    completedCount: completedCount,
    totalCount: allItems.length,
  );
});

// ─── Actions ───

/// Toggle completion for a work task
final periodicTaskCompletionProvider =
    Provider<Future<void> Function(int taskId, bool markComplete)>((ref) {
  final repo = ref.watch(tasksRepositoryProvider);
  return (int taskId, bool markComplete) async {
    final status =
        markComplete ? UnifiedStatus.completed : UnifiedStatus.inProgress;
    await repo.updateStatus(taskId, status);
  };
});

/// Toggle completion for a routine task
final periodicRoutineCompletionProvider =
    Provider<Future<void> Function(String taskId, DateTime date)>((ref) {
  return (String taskId, DateTime date) async {
    await ref.read(routineTasksProvider.notifier).toggleTask(taskId, date);
  };
});
