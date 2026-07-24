import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/appointments_table.dart';

part 'appointments_dao.g.dart';

/// Data Access Object for Appointments
@DriftAccessor(tables: [Appointments])
class AppointmentsDao extends DatabaseAccessor<AppDatabase> with _$AppointmentsDaoMixin {
  AppointmentsDao(super.db);

  /// Watch all active appointments
  Stream<List<Appointment>> watchAllActive() => (select(appointments)
        ..where((a) => a.isDeleted.equals(false))
        ..orderBy([
          (a) => OrderingTerm.asc(a.date),
          (a) => OrderingTerm.asc(a.time),
        ]))
      .watch();

  /// Watch appointments for a specific date
  Stream<List<Appointment>> watchByDate(String date) => (select(appointments)
        ..where((a) => a.isDeleted.equals(false) & a.date.equals(date))
        ..orderBy([(a) => OrderingTerm.asc(a.time)]))
      .watch();

  /// Insert appointment
  Future<int> insertAppointment(AppointmentsCompanion appointment) => into(appointments).insert(appointment);

  /// Update status
  Future<void> updateStatus(int id, int status) =>
      (update(appointments)..where((a) => a.id.equals(id))).write(
        AppointmentsCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Soft delete
  Future<void> softDelete(int id) =>
      (update(appointments)..where((a) => a.id.equals(id))).write(
        AppointmentsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Get single appointment by ID
  Future<Appointment?> getById(int id) =>
      (select(appointments)..where((a) => a.id.equals(id))).getSingleOrNull();

  /// Update appointment
  Future<bool> updateAppointment(AppointmentsCompanion appointment, int id) =>
      (update(appointments)..where((a) => a.id.equals(id)))
          .write(appointment)
          .then((rows) => rows > 0);
}