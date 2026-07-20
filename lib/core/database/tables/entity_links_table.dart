import 'package:drift/drift.dart';
import 'base_table.dart';

/// Entity types for universal linking.
///
/// Used by EntityLinks, FollowUps.linkedEntityType, etc.
/// 0 = none
/// 1 = meeting       (Meetings)
/// 2 = followup      (FollowUps)
/// 3 = client        (Clients)
/// 4 = project       (Projects)
/// 5 = employee      (Employees)
/// 6 = invoice       (Invoices)
/// 7 = expense       (Expenses)
/// 8 = revenue       (Revenues)
/// 9 = contract      (EmployeeContracts)
/// 10 = directive    (Directives)
/// 11 = contact      (Contacts)
/// 12 = supplier     (Suppliers)
/// 13 = document     (Archive)
/// 14 = appointment  (Appointments)
/// 15 = note         (Notes)
/// 16 = other

/// Universal Entity Links table.
///
/// Allows ANY record to be linked to ANY other record.
/// This powers the "Smart Relations" feature across all modules.
class EntityLinks extends Table with BaseTableMixin {
  /// Source entity type (see enum above)
  IntColumn get sourceType => integer()();

  /// Source entity ID
  IntColumn get sourceId => integer()();

  /// Target entity type (see enum above)
  IntColumn get targetType => integer()();

  /// Target entity ID
  IntColumn get targetId => integer()();

  /// Optional: description of the relationship
  TextColumn get relation => text().nullable()();

  /// Optional: cached label of source (for display without extra query)
  TextColumn get sourceLabel => text().nullable()();

  /// Optional: cached label of target (for display without extra query)
  TextColumn get targetLabel => text().nullable()();

  /// Who created this link
  @override
  TextColumn get createdBy => text().nullable()();
}
