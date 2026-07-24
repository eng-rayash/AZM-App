import 'package:drift/drift.dart';

import 'base_table.dart';

/// Movements Table — stores executive movements (خروج، عودة، مهمة خارجية).
class Movements extends Table with BaseTableMixin {
  /// Destination or location
  TextColumn get destination => text()();

  /// Purpose of the movement
  TextColumn get purpose => text().nullable()();

  /// Date string (YYYY-MM-DD)
  TextColumn get date => text()();

  /// Time string (HH:MM)
  TextColumn get time => text()();

  /// Movement type: 0 = خروج, 1 = عودة, 2 = مهمة خارجية
  IntColumn get type => integer().withDefault(const Constant(0))();

  /// Additional notes
  TextColumn get notes => text().nullable()();
}