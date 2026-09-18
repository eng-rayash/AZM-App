import 'package:drift/drift.dart';

import 'base_table.dart';
import 'tenant_scoped.dart';

/// Tasks table — stores action items and tasks.
///
/// Can be standalone or linked to a specific meeting.
class Tasks extends Table with BaseTableMixin, TenantScoped {
  /// Task title
  TextColumn get title => text().withLength(min: 1, max: 200)();

  /// Task description / details
  TextColumn get description => text().nullable()();

  /// Due date (stored as ISO 8601 string: YYYY-MM-DD)
  TextColumn get dueDate => text().nullable()();

  /// Assigned to (name or role of the assignee)
  TextColumn get assignedTo => text().nullable()();

  /// Priority level (critical=0, high=1, medium=2, low=3)
  IntColumn get priority => integer().withDefault(const Constant(2))();

  /// الحالة — القيَم في `UnifiedStatus`.
  IntColumn get status => integer().withDefault(const Constant(0))();

  /// Optional: ID of the meeting this task originated from
  IntColumn get linkedMeetingId => integer().nullable()();
}