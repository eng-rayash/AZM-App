import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/enums.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/security/security_logger.dart';

/// Repository for handling Task business logic.
class TasksRepository {
  TasksRepository(this._db, this._logger);

  final AppDatabase _db;
  final SecurityLogger _logger;
  static const _uuid = Uuid();

  /// Watch all active tasks
  Stream<List<Task>> watchAll() => _db.tasksDao.watchAllActive();

  /// Watch tasks by status
  Stream<List<Task>> watchByStatus(UnifiedStatus status) =>
      _db.tasksDao.watchByStatus(status.value);

  /// Watch a specific task by ID
  Stream<Task?> watchById(int id) => _db.tasksDao.watchById(id);

  /// Create a new task
  Future<int> createTask({
    required String title,
    required Priority priority,
    String? description,
    String? dueDate,
    String? assignedTo,
    int? linkedMeetingId,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final taskId = await _db.tasksDao.insertTask(
      TasksCompanion.insert(
        syncId: _uuid.v4(),
        title: title,
        description: drift.Value(description),
        dueDate: drift.Value(dueDate),
        assignedTo: drift.Value(assignedTo),
        priority: drift.Value(priority.value),
        status: drift.Value(UnifiedStatus.newItem.value),
        linkedMeetingId: drift.Value(linkedMeetingId),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await _logger.log(SecurityAction.settingsChanged, details: 'تم إنشاء مهمة جديدة: $title');
    return taskId;
  }

  /// Update task details
  Future<void> updateTaskDetails({
    required int id,
    required String title,
    required Priority priority,
    String? description,
    String? dueDate,
    String? assignedTo,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    await _db.tasksDao.updateTask(
      TasksCompanion(
        title: drift.Value(title),
        description: drift.Value(description),
        dueDate: drift.Value(dueDate),
        assignedTo: drift.Value(assignedTo),
        priority: drift.Value(priority.value),
        updatedAt: drift.Value(now),
      ),
      id,
    );

    await _logger.log(SecurityAction.settingsChanged, details: 'تم تعديل المهمة #$id: $title');
  }

  /// Update task status
  Future<void> updateStatus(int id, UnifiedStatus status) async {
    await _db.tasksDao.updateStatus(id, status.value);
    await _logger.log(SecurityAction.settingsChanged, details: 'تحديث حالة المهمة #$id');
  }

  /// Delete task (soft)
  Future<void> deleteTask(int id) async {
    await _db.tasksDao.softDelete(id);
    await _logger.logRecordDeleted('مهمة', id);
  }
}

/// Provider for TasksRepository
final tasksRepositoryProvider = Provider<TasksRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final logger = SecurityLogger(db.securityLogsDao);
  return TasksRepository(db, logger);
});