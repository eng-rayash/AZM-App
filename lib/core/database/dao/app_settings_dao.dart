import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/app_settings_table.dart';

part 'app_settings_dao.g.dart';

/// Data Access Object for App Settings — key-value store.
///
/// Used for theme preference, language, notification settings, etc.
@DriftAccessor(tables: [AppSettings])
class AppSettingsDao extends DatabaseAccessor<AppDatabase>
    with _$AppSettingsDaoMixin {
  AppSettingsDao(super.db);

  /// Get setting value by key
  Future<String?> getValue(String key) async {
    final setting = await (select(appSettings)
          ..where((s) => s.key.equals(key) & s.isDeleted.equals(false)))
        .getSingleOrNull();
    return setting?.value;
  }

  /// Watch a setting value by key
  Stream<String?> watchValue(String key) => (select(appSettings)
        ..where((s) => s.key.equals(key) & s.isDeleted.equals(false)))
      .watchSingleOrNull()
      .map((setting) => setting?.value);

  /// Set or update a setting
  Future<void> setValue(String key, String value, {String? category}) async {
    final existing = await (select(appSettings)
          ..where((s) => s.key.equals(key)))
        .getSingleOrNull();

    final now = DateTime.now().millisecondsSinceEpoch;

    if (existing != null) {
      await (update(appSettings)..where((s) => s.key.equals(key))).write(
        AppSettingsCompanion(
          value: Value(value),
          isDeleted: const Value(false),
          updatedAt: Value(now),
        ),
      );
    } else {
      await into(appSettings).insert(
        AppSettingsCompanion.insert(
          syncId: _generateSyncId(),
          key: key,
          value: value,
          category: Value(category),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }
  }

  /// Get all settings in a category
  Future<Map<String, String>> getByCategory(String category) async {
    final settings = await (select(appSettings)
          ..where((s) =>
              s.category.equals(category) & s.isDeleted.equals(false)))
        .get();
    return {for (final s in settings) s.key: s.value};
  }

  /// Delete a setting (soft)
  Future<void> removeSetting(String key) async {
    await (update(appSettings)..where((s) => s.key.equals(key))).write(
      AppSettingsCompanion(
        isDeleted: const Value(true),
        updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
      ),
    );
  }

  String _generateSyncId() {
    // Simple UUID v4 generation without external dependency in DAO
    final now = DateTime.now().millisecondsSinceEpoch;
    return '$now-${now.hashCode.toRadixString(16)}';
  }
}