import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/enums.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/security/security_logger.dart';

/// Repository for handling Directives logic.
class DirectivesRepository {
  DirectivesRepository(this._db, this._logger);

  final AppDatabase _db;
  final SecurityLogger _logger;
  static const _uuid = Uuid();

  /// Watch all active directives
  Stream<List<Directive>> watchAll() => _db.directivesDao.watchAllActive();

  /// Create a new directive
  Future<int> createDirective({
    required String title,
    required Priority priority,
    String? details,
    String? source,
    String? assignedTo,
    String? deadline,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final id = await _db.directivesDao.insertDirective(
      DirectivesCompanion.insert(
        syncId: _uuid.v4(),
        title: title,
        details: drift.Value(details),
        source: drift.Value(source),
        assignedTo: drift.Value(assignedTo),
        deadline: drift.Value(deadline),
        priority: drift.Value(priority.value),
        status: drift.Value(UnifiedStatus.newItem.value),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await _logger.log(SecurityAction.settingsChanged, details: 'تم إصدار توجيه جديد: $title');
    return id;
  }

  /// Update status
  Future<void> updateStatus(int id, UnifiedStatus status) async {
    await _db.directivesDao.updateStatus(id, status.value);
    await _logger.log(SecurityAction.settingsChanged, details: 'تحديث حالة التوجيه #$id');
  }

  /// Update directive
  Future<bool> updateDirective({
    required int id,
    required String title,
    required Priority priority,
    String? details,
    String? source,
    String? assignedTo,
    String? deadline,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final success = await _db.directivesDao.updateDirective(
      DirectivesCompanion(
        title: drift.Value(title),
        priority: drift.Value(priority.value),
        details: drift.Value(details),
        source: drift.Value(source),
        assignedTo: drift.Value(assignedTo),
        deadline: drift.Value(deadline),
        updatedAt: drift.Value(now),
      ),
      id,
    );

    if (success) {
      await _logger.log(SecurityAction.settingsChanged, details: 'تعديل التوجيه: $title');
    }

    return success;
  }

  /// Delete (soft)
  Future<void> deleteDirective(int id) async {
    await _db.directivesDao.softDelete(id);
    await _logger.logRecordDeleted('توجيه', id);
  }

  /// Get directive by ID
  Future<Directive?> getById(int id) => _db.directivesDao.getById(id);
}

/// Provider for DirectivesRepository
final directivesRepositoryProvider = Provider<DirectivesRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final logger = SecurityLogger(db.securityLogsDao);
  return DirectivesRepository(db, logger);
});