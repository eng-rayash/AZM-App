import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/follow_ups_table.dart';

part 'follow_ups_dao.g.dart';

/// Data Access Object for the Follow-ups table.
@DriftAccessor(tables: [FollowUps])
class FollowUpsDao extends DatabaseAccessor<AppDatabase> with _$FollowUpsDaoMixin {
  FollowUpsDao(super.db);

  /// Get all active follow-ups
  Future<List<FollowUp>> getAllActive() => (select(followUps)
        ..where((f) => f.isDeleted.equals(false))
        ..orderBy([
          (f) => OrderingTerm.asc(f.status),
          (f) => OrderingTerm.asc(f.priority),
        ]))
      .get();

  /// Watch all active follow-ups
  Stream<List<FollowUp>> watchAllActive() => (select(followUps)
        ..where((f) => f.isDeleted.equals(false))
        ..orderBy([
          (f) => OrderingTerm.asc(f.status),
          (f) => OrderingTerm.asc(f.priority),
        ]))
      .watch();

  /// Watch follow-ups by status
  Stream<List<FollowUp>> watchByStatus(int status) => (select(followUps)
        ..where((f) => f.isDeleted.equals(false) & f.status.equals(status))
        ..orderBy([(f) => OrderingTerm.desc(f.createdAt)]))
      .watch();

  /// Watch follow-ups for a specific entity
  Stream<List<FollowUp>> watchByEntity(int entityType, int entityId) => (select(followUps)
        ..where((f) => f.isDeleted.equals(false) & f.entityType.equals(entityType) & f.entityId.equals(entityId))
        ..orderBy([(f) => OrderingTerm.desc(f.createdAt)]))
      .watch();

  /// Insert a new follow-up
  Future<int> insertFollowUp(FollowUpsCompanion followUp) => into(followUps).insert(followUp);

  /// Update follow-up
  Future<bool> updateFollowUp(FollowUpsCompanion followUp, int id) =>
      (update(followUps)..where((f) => f.id.equals(id)))
          .write(followUp)
          .then((rows) => rows > 0);

  /// Update status
  Future<void> updateStatus(int id, int status) =>
      (update(followUps)..where((f) => f.id.equals(id))).write(
        FollowUpsCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Soft delete
  Future<void> softDelete(int id) =>
      (update(followUps)..where((f) => f.id.equals(id))).write(
        FollowUpsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Get follow-up by id
  Future<FollowUp?> getById(int id) =>
      (select(followUps)..where((f) => f.id.equals(id))).getSingleOrNull();
}