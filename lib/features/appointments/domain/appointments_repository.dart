import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/enums.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/security/security_logger.dart';

/// Repository for handling Appointments logic.
class AppointmentsRepository {
  AppointmentsRepository(this._db, this._logger);

  final AppDatabase _db;
  final SecurityLogger _logger;
  static const _uuid = Uuid();

  /// Watch all active appointments
  Stream<List<Appointment>> watchAll() => _db.appointmentsDao.watchAllActive();

  /// Watch today's appointments
  Stream<List<Appointment>> watchToday() {
    final today = DateTime.now().toIso8601String().split('T').first;
    return _db.appointmentsDao.watchByDate(today);
  }

  /// Create a new appointment
  Future<int> createAppointment({
    required String title,
    required DateTime date,
    required String time,
    int? contactId,
    int durationMinutes = 30,
    String? location,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final id = await _db.appointmentsDao.insertAppointment(
      AppointmentsCompanion.insert(
        syncId: _uuid.v4(),
        title: title,
        date: date.toIso8601String().split('T').first,
        time: time,
        durationMinutes: drift.Value(durationMinutes),
        contactId: drift.Value(contactId),
        location: drift.Value(location),
        status: drift.Value(UnifiedStatus.newItem.value),
        createdAt: now,
        updatedAt: now,
      ),
    );

    return id;
  }

  /// Update appointment
  Future<bool> updateAppointment({
    required int id,
    required String title,
    required DateTime date,
    required String time,
    int? contactId,
    int durationMinutes = 30,
    String? location,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    return await _db.appointmentsDao.updateAppointment(
      AppointmentsCompanion(
        title: drift.Value(title),
        date: drift.Value(date.toIso8601String().split('T').first),
        time: drift.Value(time),
        durationMinutes: drift.Value(durationMinutes),
        contactId: drift.Value(contactId),
        location: drift.Value(location),
        updatedAt: drift.Value(now),
      ),
      id,
    );
  }

  /// Update status
  Future<void> updateStatus(int id, UnifiedStatus status) async {
    await _db.appointmentsDao.updateStatus(id, status.value);
  }

  /// Delete (soft)
  Future<void> deleteAppointment(int id) async {
    await _db.appointmentsDao.softDelete(id);
    await _logger.logRecordDeleted('موعد', id);
  }
}

/// Provider for AppointmentsRepository
final appointmentsRepositoryProvider = Provider<AppointmentsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final logger = SecurityLogger(db.securityLogsDao);
  return AppointmentsRepository(db, logger);
});

/// Provider for appointments stream
final appointmentsListProvider = StreamProvider<List<Appointment>>((ref) {
  return ref.watch(appointmentsRepositoryProvider).watchAll();
});