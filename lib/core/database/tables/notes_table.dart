import 'package:drift/drift.dart';
import 'base_table.dart';

/// Notes Table — Phase 4
/// For quick executive notes and thoughts.
@DataClassName('NoteItem')
class Notes extends Table with BaseTableMixin {
  TextColumn get title => text().nullable()();
  TextColumn get content => text()();
  TextColumn get colorCode => text().nullable()();
  TextColumn get tags => text().nullable()();
}