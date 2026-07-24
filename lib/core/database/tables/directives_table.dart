import 'package:drift/drift.dart';

import 'base_table.dart';

/// Directives table — stores executive orders and directives.
class Directives extends Table with BaseTableMixin {
  /// Directive title or subject
  TextColumn get title => text().withLength(min: 1, max: 200)();

  /// Detailed instructions
  TextColumn get details => text().nullable()();

  /// Directive source / authority (e.g., 'CEO', 'Board')
  TextColumn get source => text().nullable()();

  /// Assigned to (department or individual)
  TextColumn get assignedTo => text().nullable()();

  /// Target deadline
  TextColumn get deadline => text().nullable()();

  /// Priority level (critical=0, high=1, medium=2, low=3)
  IntColumn get priority => integer().withDefault(const Constant(1))();

  /// Status using UnifiedStatus
  IntColumn get status => integer().withDefault(const Constant(0))();
}