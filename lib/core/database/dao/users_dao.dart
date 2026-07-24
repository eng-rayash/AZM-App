import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/users_table.dart';

part 'users_dao.g.dart';

/// Data Access Object for the Users table.
///
/// Provides CRUD operations with soft delete support.
@DriftAccessor(tables: [Users])
class UsersDao extends DatabaseAccessor<AppDatabase> with _$UsersDaoMixin {
  UsersDao(super.db);

  /// Get all active (non-deleted) users
  Future<List<User>> getAllActive() =>
      (select(users)..where((u) => u.isDeleted.equals(false))).get();

  /// Get user by ID
  Future<User?> getById(int id) =>
      (select(users)..where((u) => u.id.equals(id))).getSingleOrNull();

  /// Get the current (primary) user — in single-user mode, returns first user
  Future<User?> getCurrentUser() => (select(users)
        ..where((u) => u.isDeleted.equals(false))
        ..limit(1))
      .getSingleOrNull();

  /// Watch the current user for reactive updates
  Stream<User?> watchCurrentUser() => (select(users)
        ..where((u) => u.isDeleted.equals(false))
        ..limit(1))
      .watchSingleOrNull();

  /// Insert a new user
  Future<int> insertUser(UsersCompanion user) => into(users).insert(user);

  /// Update user
  Future<bool> updateUser(UsersCompanion user, int id) =>
      (update(users)..where((u) => u.id.equals(id))).write(user).then(
            (rows) => rows > 0,
          );

  /// Update PIN hash
  Future<void> updatePinHash(int userId, String pinHash) =>
      (update(users)..where((u) => u.id.equals(userId))).write(
        UsersCompanion(
          pinHash: Value(pinHash),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Update biometric setting
  Future<void> updateBiometricSetting(int userId, bool enabled) =>
      (update(users)..where((u) => u.id.equals(userId))).write(
        UsersCompanion(
          isBiometricEnabled: Value(enabled),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Soft delete user
  Future<void> softDelete(int id) =>
      (update(users)..where((u) => u.id.equals(id))).write(
        UsersCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Check if any user exists (first launch detection)
  Future<bool> hasAnyUser() async {
    final count = await (selectOnly(users)
          ..addColumns([users.id.count()])
          ..where(users.isDeleted.equals(false)))
        .map((row) => row.read(users.id.count()))
        .getSingle();
    return (count ?? 0) > 0;
  }
}