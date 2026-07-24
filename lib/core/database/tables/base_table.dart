import 'package:drift/drift.dart';

/// Base mixin providing mandatory fields for all Drift tables.
///
/// Every table in Mudiri MUST include these fields for:
/// - Unique identification (id)
/// - Future sync support (syncId)
/// - Audit trail (createdAt, updatedAt)
/// - Soft delete (isDeleted)
/// - Multi-user readiness (createdBy)
mixin BaseTableMixin on Table {
  /// Auto-increment primary key
  IntColumn get id => integer().autoIncrement()();

  /// UUID for future cloud sync
  TextColumn get syncId => text().withLength(min: 36, max: 36)();

  /// Unix timestamp (milliseconds) of creation
  IntColumn get createdAt => integer()();

  /// Unix timestamp (milliseconds) of last update
  IntColumn get updatedAt => integer()();

  /// Soft delete flag — records are never hard-deleted
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();

  /// Creator identifier (for multi-user support in the future)
  TextColumn get createdBy => text().nullable()();
}