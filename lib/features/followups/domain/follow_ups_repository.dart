import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/enums.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/security/security_logger.dart';

/// Repository for handling Follow-up business logic.
class FollowUpsRepository {
  FollowUpsRepository(this._db, this._logger);

  final AppDatabase _db;
  final SecurityLogger _logger;
  static const _uuid = Uuid();

  /// Watch all active follow-ups
  Stream<List<FollowUp>> watchAll() => _db.followUpsDao.watchAllActive();

  /// Create a new follow-up
  Future<int> createFollowUp({
    required String title,
    required FollowUpEntityType type,
    required Priority priority,
    String? notes,
    String? targetDate,
    int? entityId,
    String? assignedTo,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final id = await _db.followUpsDao.insertFollowUp(
      FollowUpsCompanion.insert(
        syncId: _uuid.v4(),
        title: title,
        notes: drift.Value(notes),
        targetDate: drift.Value(targetDate),
        entityType: drift.Value(type.value),
        entityId: drift.Value(entityId),
        priority: drift.Value(priority.value),
        status: drift.Value(UnifiedStatus.newItem.value),
        assignedTo: drift.Value(assignedTo),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await _logger.log(SecurityAction.settingsChanged, details: 'تم إنشاء متابعة جديدة: $title');
    return id;
  }

  /// Update status — when completed, also update the linked entity (task/directive/meeting)
  Future<void> updateStatus(int id, UnifiedStatus status) async {
    await _db.followUpsDao.updateStatus(id, status.value);
    await _logger.log(SecurityAction.settingsChanged, details: 'تحديث حالة المتابعة #$id إلى ${status.arabicLabel}');

    // If marking as completed, sync status to linked entity
    if (status == UnifiedStatus.completed) {
      await _syncLinkedEntityStatus(id);
    }
  }

  /// Sync the linked entity status when a follow-up is completed
  Future<void> _syncLinkedEntityStatus(int followUpId) async {
    try {
      final followUp = await _db.followUpsDao.getById(followUpId);
      if (followUp == null || followUp.entityId == null) return;

      final entityType = FollowUpEntityType.fromValue(followUp.entityType);
      final entityId = followUp.entityId!;

      switch (entityType) {
        case FollowUpEntityType.task:
          // Update task status to completed (UnifiedStatus.completed = 3)
          await _db.tasksDao.updateStatus(entityId, UnifiedStatus.completed.value);
          await _logger.log(
            SecurityAction.settingsChanged,
            details: 'تم تحديث حالة المهمة #$entityId إلى مكتمل (مزامنة مع المتابعة #$followUpId)',
          );
          break;

        case FollowUpEntityType.directive:
          // Update directive status to completed (UnifiedStatus.completed = 3)
          await _db.directivesDao.updateStatus(entityId, UnifiedStatus.completed.value);
          await _logger.log(
            SecurityAction.settingsChanged,
            details: 'تم تحديث حالة التوجيه #$entityId إلى مكتمل (مزامنة مع المتابعة #$followUpId)',
          );
          break;

        case FollowUpEntityType.meeting:
          // Update meeting status to completed (MeetingStatus.completed = 2)
          await _db.meetingsDao.updateStatus(entityId, MeetingStatus.completed.value);
          await _logger.log(
            SecurityAction.settingsChanged,
            details: 'تم تحديث حالة الاجتماع #$entityId إلى مكتمل (مزامنة مع المتابعة #$followUpId)',
          );
          break;

        case FollowUpEntityType.other:
          // No linked entity to sync
          break;
      }
    } catch (e) {
      // Log but don't fail the main status update
      await _logger.log(
        SecurityAction.settingsChanged,
        details: 'خطأ في مزامنة حالة الكيان المرتبط بالمتابعة #$followUpId: $e',
      );
    }
  }

  /// Update follow-up
  Future<bool> updateFollowUp({
    required int id,
    required String title,
    required FollowUpEntityType type,
    required Priority priority,
    String? notes,
    String? targetDate,
    int? entityId,
    String? assignedTo,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final success = await _db.followUpsDao.updateFollowUp(
      FollowUpsCompanion(
        title: drift.Value(title),
        entityType: drift.Value(type.value),
        priority: drift.Value(priority.value),
        notes: drift.Value(notes),
        targetDate: drift.Value(targetDate),
        entityId: drift.Value(entityId),
        assignedTo: drift.Value(assignedTo),
        updatedAt: drift.Value(now),
      ),
      id,
    );

    if (success) {
      await _logger.log(SecurityAction.settingsChanged, details: 'تعديل المتابعة: $title');
    }

    return success;
  }

  /// Delete (soft)
  Future<void> deleteFollowUp(int id) async {
    await _db.followUpsDao.softDelete(id);
    await _logger.logRecordDeleted('متابعة', id);
  }

  /// Get follow-up by ID
  Future<FollowUp?> getById(int id) => _db.followUpsDao.getById(id);
}

/// Provider for FollowUpsRepository
final followUpsRepositoryProvider = Provider<FollowUpsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final logger = SecurityLogger(db.securityLogsDao);
  return FollowUpsRepository(db, logger);
});
