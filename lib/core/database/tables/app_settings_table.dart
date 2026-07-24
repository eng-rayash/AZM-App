import 'package:drift/drift.dart';

import 'base_table.dart';

/// App Settings table — key-value configuration store.
///
/// Stores user preferences, theme settings, and app configuration.
class AppSettings extends Table with BaseTableMixin {
  /// Setting key (unique identifier)
  TextColumn get key => text().withLength(min: 1, max: 100)();

  /// Setting value (stored as string, parsed by consumer)
  TextColumn get value => text()();

  /// Setting category for grouping
  TextColumn get category => text().nullable()();

  @override
  List<Set<Column>> get uniqueKeys => [
        {key},
      ];
}