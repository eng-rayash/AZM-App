import 'package:drift/drift.dart';

import 'base_table.dart';

/// Routine Tasks table — stores recurring daily/weekly habits.
///
/// Each row is a routine task definition. Completions are tracked
/// in the separate [RoutineCompletions] table.
class RoutineTasks extends Table with BaseTableMixin {
  /// Task title
  TextColumn get title => text().withLength(min: 1, max: 200)();

  /// Optional description
  TextColumn get description => text().nullable()();

  /// Category (work, health, personal, learning, spiritual, finance)
  TextColumn get category => text().withDefault(const Constant('personal'))();

  /// Priority (critical=0, high=1, medium=2, low=3)
  IntColumn get priority => integer().withDefault(const Constant(2))();

  /// Repeat pattern (daily, weekly, weekdays, weekend)
  TextColumn get repeat => text().withDefault(const Constant('daily'))();

  /// Time of day in HH:mm format (nullable)
  TextColumn get time => text().nullable()();

  /// Days of week as JSON string (e.g. "[1,3,5]"), used for weekly repeat
  TextColumn get daysOfWeek =>
      text().withDefault(const Constant('[]'))();

  /// Whether this routine is active
  BoolColumn get isActive =>
      boolean().withDefault(const Constant(true))();
}

/// Routine Completions table — tracks which routine tasks were completed on which days.
class RoutineCompletions extends Table with BaseTableMixin {
  /// Foreign key to [RoutineTasks.syncId] (UUID string)
  TextColumn get routineTaskSyncId =>
      text().withLength(min: 36, max: 36)();

  /// Date key in yyyy-MM-dd format
  TextColumn get dateKey => text().withLength(min: 10, max: 10)();
}
