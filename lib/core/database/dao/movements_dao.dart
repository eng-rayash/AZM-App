import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/movements_table.dart';

part 'movements_dao.g.dart';

/// DAO for Movements Table
@DriftAccessor(tables: [Movements])
class MovementsDao extends DatabaseAccessor<AppDatabase>
    with _$MovementsDaoMixin {
  MovementsDao(super.attachedDatabase);

  /// Get all active movements
  Future<List<Movement>> getActiveMovements() =>
      (select(movements)..where((t) => t.isDeleted.equals(false))).get();

  /// Watch active movements
  Stream<List<Movement>> watchActiveMovements() =>
      (select(movements)..where((t) => t.isDeleted.equals(false))).watch();

  /// Create a new movement
  Future<int> insertMovement(MovementsCompanion movement) =>
      into(movements).insert(movement);

  /// Soft delete a movement
  Future<bool> deleteMovement(int id) async {
    return await (update(movements)..where((t) => t.id.equals(id))).write(
          MovementsCompanion(
            isDeleted: const Value(true),
            updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
          ),
        ) >
        0;
  }

  /// Get movement by ID
  Future<Movement?> getById(int id) =>
      (select(movements)..where((t) => t.id.equals(id))).getSingleOrNull();

  /// Update movement
  Future<bool> updateMovement(MovementsCompanion movement, int id) =>
      (update(movements)..where((t) => t.id.equals(id)))
          .write(movement)
          .then((rows) => rows > 0);
}