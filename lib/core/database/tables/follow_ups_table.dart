import 'package:drift/drift.dart';

import 'base_table.dart';

/// Follow-up type enum values:
/// 0 = متابعة (Follow-up)
/// 1 = مهمة (Task)
/// 2 = اتصال (Call)
/// 3 = زيارة (Visit)
/// 4 = تذكير (Reminder)
/// 5 = مراجعة (Review)
/// 6 = إجراء (Action)
/// 7 = أخرى (Other)

/// Follow-ups table — unified action item model.
///
/// Merges the old Tasks module into FollowUps.
/// Supports all action types: follow-ups, tasks, calls, visits, reminders, etc.
/// Universal entity linking allows attachment to any record in the system.
class FollowUps extends Table with BaseTableMixin {
  /// Follow-up title
  TextColumn get title => text().withLength(min: 1, max: 200)();

  /// Follow-up description / notes
  TextColumn get notes => text().nullable()();

  /// Target date for the follow-up (ISO 8601 string: YYYY-MM-DD)
  TextColumn get targetDate => text().nullable()();

  /// Follow-up type (0=متابعة, 1=مهمة, 2=اتصال, 3=زيارة,
  ///                  4=تذكير, 5=مراجعة, 6=إجراء, 7=أخرى)
  IntColumn get followupType => integer().withDefault(const Constant(0))();

  /// Legacy: Type of entity being followed up (0=Meeting, 1=Task, 2=Directive)
  /// Kept for backward compatibility — use linkedEntityType for new records.
  IntColumn get entityType => integer().withDefault(const Constant(0))();

  /// Legacy: ID of the entity being followed up
  IntColumn get entityId => integer().nullable()();

  /// Universal linked entity type (enum EntityLinkType):
  /// 0=None, 1=Meeting, 2=Client, 3=Project, 4=Employee,
  /// 5=Invoice, 6=Contract, 7=Directive, 8=Contact, 9=Other
  IntColumn get linkedEntityType => integer().nullable()();

  /// Universal linked entity ID (FK to any table based on linkedEntityType)
  IntColumn get linkedEntityId => integer().nullable()();

  /// Human-readable label for the linked entity (e.g. client name, project name)
  TextColumn get linkedEntityLabel => text().nullable()();

  /// Priority level (critical=0, high=1, medium=2, low=3)
  IntColumn get priority => integer().withDefault(const Constant(2))();

  /// Status using UnifiedStatus
  /// (newItem=0, inProgress=1, pendingReview=2, completed=3, overdue=4, cancelled=5)
  IntColumn get status => integer().withDefault(const Constant(0))();

  /// Assigned entity/person handling the follow-up
  TextColumn get assignedTo => text().nullable()();

  /// Estimated duration in minutes (for tasks / timed actions)
  IntColumn get estimatedMinutes => integer().nullable()();

  /// Actual completion timestamp (ISO 8601)
  TextColumn get completedAt => text().nullable()();

  /// Tags (stored as JSON array of strings, e.g. ["urgent","finance"])
  TextColumn get tags => text().nullable()();

  /// Reminder time (ISO 8601 datetime string for local notification)
  TextColumn get reminderAt => text().nullable()();

  /// Repeat rule (daily/weekly/monthly/none — for recurring follow-ups)
  TextColumn get repeatRule => text().nullable()();

  /// Source: was this migrated from the old Tasks table?
  BoolColumn get migratedFromTask =>
      boolean().withDefault(const Constant(false))();
}
