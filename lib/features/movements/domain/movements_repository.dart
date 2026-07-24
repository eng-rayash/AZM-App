import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/providers/database_providers.dart';

/// Provider for MovementsRepository
final movementsRepositoryProvider = Provider<MovementsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return MovementsRepository(db);
});

/// Provider for active movements list
final activeMovementsProvider = StreamProvider<List<Movement>>((ref) {
  final repository = ref.watch(movementsRepositoryProvider);
  return repository.watchActiveMovements();
});

/// Repository for managing movements
class MovementsRepository {
  MovementsRepository(this._db);

  final AppDatabase _db;

  /// Watch active movements
  Stream<List<Movement>> watchActiveMovements() {
    return _db.movementsDao.watchActiveMovements();
  }

  /// Create a new movement
  Future<int> createMovement({
    required String destination,
    String? purpose,
    required String date,
    required String time,
    required int type,
    String? notes,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    const uuid = Uuid();
    
    return _db.movementsDao.insertMovement(
      MovementsCompanion.insert(
        destination: destination,
        purpose: Value(purpose),
        date: date,
        time: time,
        type: Value(type),
        notes: Value(notes),
        syncId: uuid.v4(),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  /// Update movement
  Future<bool> updateMovement({
    required int id,
    required String destination,
    String? purpose,
    required String date,
    required String time,
    required int type,
    String? notes,
  }) {
    final now = DateTime.now().millisecondsSinceEpoch;
    return _db.movementsDao.updateMovement(
      MovementsCompanion(
        destination: Value(destination),
        purpose: Value(purpose),
        date: Value(date),
        time: Value(time),
        type: Value(type),
        notes: Value(notes),
        updatedAt: Value(now),
      ),
      id,
    );
  }

  /// Soft delete a movement
  Future<bool> deleteMovement(int id) {
    return _db.movementsDao.deleteMovement(id);
  }

  /// Get movement by ID
  Future<Movement?> getById(int id) => _db.movementsDao.getById(id);
}