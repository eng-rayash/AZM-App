import 'package:drift/drift.dart';

import 'base_table.dart';

/// Appointments table — for personal scheduling, visits, and short meetings.
class Appointments extends Table with BaseTableMixin {
  /// Appointment title
  TextColumn get title => text().withLength(min: 1, max: 200)();

  /// Optional link to a contact
  IntColumn get contactId => integer().nullable()();

  /// Date of the appointment (ISO 8601)
  TextColumn get date => text()();

  /// Time of the appointment
  TextColumn get time => text()();

  /// Expected duration in minutes
  IntColumn get durationMinutes => integer().withDefault(const Constant(30))();

  /// Location
  TextColumn get location => text().nullable()();

  /// Status using UnifiedStatus
  IntColumn get status => integer().withDefault(const Constant(0))();
}