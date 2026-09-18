import 'package:drift/drift.dart';

import 'base_table.dart';
import 'tenant_scoped.dart';

/// Meeting category enum:
/// 0 = اجتماع (Meeting) — formal meeting
/// 1 = لقاء (Encounter) — informal meeting / encounter
///
/// This merges the old separate Encounters module into Meetings.

/// Meetings table — full meeting model per Plan.md specifications.
///
/// Supports all meeting lifecycle states and links to tasks/follow-ups.
/// RTL-aware: All text fields support Arabic content.
class Meetings extends Table with BaseTableMixin, TenantScoped {
  /// Meeting title
  TextColumn get title => text().withLength(min: 1, max: 200)();

  /// Meeting category (0=اجتماع/Meeting, 1=لقاء/Encounter)
  /// Merges the old Encounters module into this table.
  IntColumn get meetingCategory => integer().withDefault(const Constant(0))();

  /// Meeting type (general=0, administrative=1, emergency=2, etc.)
  IntColumn get meetingType => integer().withDefault(const Constant(0))();

  /// Meeting date (stored as ISO 8601 string: YYYY-MM-DD)
  TextColumn get date => text()();

  /// Meeting time (stored as HH:mm)
  TextColumn get time => text()();

  /// Meeting end time (stored as HH:mm, nullable)
  TextColumn get endTime => text().nullable()();

  /// Meeting location
  TextColumn get location => text().nullable()();

  /// Meeting objective / purpose
  TextColumn get objective => text().nullable()();

  /// Agenda items (stored as JSON array of strings)
  TextColumn get agenda => text().nullable()();

  /// Decisions made (stored as JSON array of strings)
  TextColumn get decisions => text().nullable()();

  /// Meeting outcomes / outputs (stored as JSON array of strings)
  TextColumn get outcomes => text().nullable()();

  /// Attendees (stored as JSON array of objects: [{name, role}])
  TextColumn get attendees => text().nullable()();

  /// Attachments (stored as JSON array of file paths)
  TextColumn get attachments => text().nullable()();

  /// Meeting status (scheduled=0, inProgress=1, completed=2, postponed=3, cancelled=4)
  IntColumn get status => integer().withDefault(const Constant(0))();

  /// Priority level (critical=0, high=1, medium=2, low=3)
  IntColumn get priority => integer().withDefault(const Constant(2))();

  /// Additional notes
  TextColumn get notes => text().nullable()();

  /// Minutes of meeting (محضر الاجتماع) — full text
  TextColumn get minutes => text().nullable()();

  /// Recurrence rule (for repeating meetings, future use)
  TextColumn get recurrenceRule => text().nullable()();

  /// Custom dynamic meeting type (if the user overrides the standard enum)
  TextColumn get customMeetingType => text().nullable()();

  // ── Universal Linking Fields ─────────────────────────────────────

  /// Linked client ID (FK → clients table, nullable)
  IntColumn get linkedClientId => integer().nullable()();

  /// Linked client name (cached label for display)
  TextColumn get linkedClientName => text().nullable()();

  /// Linked project ID (FK → projects table, nullable)
  IntColumn get linkedProjectId => integer().nullable()();

  /// Linked project name (cached label for display)
  TextColumn get linkedProjectName => text().nullable()();

  /// Linked employee IDs (JSON array of employee IDs)
  TextColumn get linkedEmployeeIds => text().nullable()();

  /// Source: was this migrated from the old Encounters table?
  BoolColumn get migratedFromEncounter =>
      boolean().withDefault(const Constant(false))();
}
