import 'package:drift/drift.dart';

import 'base_table.dart';


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

  /// نوع المتابعة — القيَم في `FollowupType` وهي المرجع الوحيد.
  ///
  /// كان هنا سرد للقيَم يخالف التعداد: يذكر ثماني قيَم (اتصال، زيارة،
  /// تذكير…) والتعداد يعرّف سبعًا مختلفة. السرد في تعليق يتخلّف عن
  /// التعريف بلا أن يلاحظ أحد؛ والإشارة إليه لا تتخلّف.
  IntColumn get followupType => integer().withDefault(const Constant(0))();

  /// قديم: نوع الكيان المتابَع — القيَم في `FollowUpEntityType`.
  ///
  /// ⚠ ترقيمه يختلف عن `EntityLinkType` المستخدَم في [linkedEntityType]:
  /// هنا `meeting = 0` وهناك `meeting = 1`. العمودان لا يُترجم أحدهما
  /// إلى الآخر. مُبقى لأن فيه بيانات؛ والسجلات الجديدة تستخدم
  /// [linkedEntityType].
  IntColumn get entityType => integer().withDefault(const Constant(0))();

  /// Legacy: ID of the entity being followed up
  IntColumn get entityId => integer().nullable()();

  /// نوع الكيان المرتبط — القيَم في `EntityLinkType`.
  ///
  /// كان هنا سرد لعشر قيَم لا يطابق التعداد ذا السبع عشرة قيمة.
  IntColumn get linkedEntityType => integer().nullable()();

  /// Universal linked entity ID (FK to any table based on linkedEntityType)
  IntColumn get linkedEntityId => integer().nullable()();

  /// Human-readable label for the linked entity (e.g. client name, project name)
  TextColumn get linkedEntityLabel => text().nullable()();

  /// Priority level (critical=0, high=1, medium=2, low=3)
  IntColumn get priority => integer().withDefault(const Constant(2))();

  /// الحالة — القيَم في `UnifiedStatus`.
  ///
  /// كان هنا سرد خاطئ: `pendingReview=2` والتعداد يقول
  /// `awaitingResponse=2`، و`cancelled=5` والتعداد يقول `stalled=5`
  /// و`cancelled=6`. من كتب `5` قاصدًا «ملغي» كان يحفظ «متعثر».
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