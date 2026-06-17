import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/enums.dart';
import '../../../core/database/app_database.dart';
import '../../tasks/domain/tasks_repository.dart';
import '../../tasks/providers/tasks_provider.dart';

/// نظام المهام الدورية — يصنف المهام حسب الفترة الزمنية ويحسب نسبة الإنجاز
/// Daily / Weekly / Monthly task system

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

/// Represents a task item in the periodic system
class PeriodicTaskItem {
  final Task task;
  final bool isCompleted;
  final bool isRoutine; // routine vs achievement

  const PeriodicTaskItem({
    required this.task,
    required this.isCompleted,
    required this.isRoutine,
  });
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

/// Filter tasks by period using dueDate (falls back to createdAt)
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

/// Notifier for selected period tab
class SelectedPeriodNotifier extends StateNotifier<TaskPeriod> {
  SelectedPeriodNotifier() : super(TaskPeriod.daily);
  void setPeriod(TaskPeriod period) => state = period;
}

final selectedPeriodProvider =
    StateNotifierProvider<SelectedPeriodNotifier, TaskPeriod>(
  (ref) => SelectedPeriodNotifier(),
);

/// Provider for periodic tasks filtered by selected period
final periodicTasksProvider = Provider<PeriodicTasksState>((ref) {
  final allTasks = ref.watch(tasksListProvider).valueOrNull ?? [];
  final period = ref.watch(selectedPeriodProvider);

  final filtered = _filterByPeriod(allTasks, period);

  // Classify: routine = medium/low priority OR title contains keywords
  // Achievement = critical/high priority
  final items = filtered.map((task) {
    final titleLower = task.title;
    final isRoutine = task.priority >= 2 ||
        titleLower.contains('روتين') ||
        titleLower.contains('يومي') ||
        titleLower.contains('أسبوعي') ||
        titleLower.contains('شهري');

    return PeriodicTaskItem(
      task: task,
      isCompleted: task.status == UnifiedStatus.completed.value,
      isRoutine: isRoutine,
    );
  }).toList();

  // Sort: incomplete first (critical/high priority first), completed at end
  items.sort((a, b) {
    if (a.isCompleted != b.isCompleted) {
      return a.isCompleted ? 1 : -1;
    }
    return a.task.priority.compareTo(b.task.priority);
  });

  final completedCount = items.where((i) => i.isCompleted).length;

  return PeriodicTasksState(
    items: items,
    period: period,
    completedCount: completedCount,
    totalCount: items.length,
  );
});

/// Action: toggle task completion in periodic system
final periodicTaskCompletionProvider =
    Provider<Future<void> Function(int taskId, bool markComplete)>((ref) {
  final repo = ref.watch(tasksRepositoryProvider);
  return (int taskId, bool markComplete) async {
    final status = markComplete ? UnifiedStatus.completed : UnifiedStatus.inProgress;
    await repo.updateStatus(taskId, status);
  };
});
