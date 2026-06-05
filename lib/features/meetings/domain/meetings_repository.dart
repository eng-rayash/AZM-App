import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/enums.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/dao/meetings_dao.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/security/security_logger.dart';

/// Repository for handling Meeting business logic.
class MeetingsRepository {
  MeetingsRepository(this._db, this._logger);

  final AppDatabase _db;
  final SecurityLogger _logger;
  static const _uuid = Uuid();

  /// Get meetings DAO
  MeetingsDao get _dao => _db.meetingsDao;

  /// Watch all active meetings
  Stream<List<Meeting>> watchAll() => _dao.watchAllActive();

  /// Watch a specific meeting by ID
  Stream<Meeting?> watchById(int id) => _dao.watchById(id);

  /// Get a specific meeting by ID (future)
  Future<Meeting?> getById(int id) => _dao.getById(id);

  /// Watch today's meetings
  Stream<List<Meeting>> watchToday() {
    final today = DateTime.now().toIso8601String().split('T').first;
    return _dao.watchTodayMeetings(today);
  }

  /// Watch upcoming meetings
  Stream<List<Meeting>> watchUpcoming() {
    final today = DateTime.now().toIso8601String().split('T').first;
    return _dao.watchUpcoming(today);
  }

  /// Create a new meeting
  Future<int> createMeeting({
    required String title,
    required MeetingType type,
    String? customMeetingType,
    required DateTime date,
    required String time,
    required Priority priority,
    String? location,
    String? objective,
    String? notes,
    String? attendees,
    String? agenda,
    String? decisions,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final meetingId = await _dao.insertMeeting(
      MeetingsCompanion.insert(
        syncId: _uuid.v4(),
        title: title,
        meetingType: drift.Value(type.value),
        customMeetingType: drift.Value(customMeetingType),
        date: date.toIso8601String().split('T').first,
        time: time,
        location: drift.Value(location),
        objective: drift.Value(objective),
        notes: drift.Value(notes),
        attendees: drift.Value(attendees),
        agenda: drift.Value(agenda),
        decisions: drift.Value(decisions),
        priority: drift.Value(priority.value),
        status: drift.Value(MeetingStatus.scheduled.value),
        createdAt: now,
        updatedAt: now,
      ),
    );

    await _logger.log(SecurityAction.settingsChanged, details: 'تم إنشاء اجتماع جديد: $title');
    return meetingId;
  }

  /// Update meeting details
  Future<void> updateMeetingDetails({
    required int id,
    required String title,
    required MeetingType type,
    String? customMeetingType,
    required DateTime date,
    required String time,
    required Priority priority,
    String? location,
    String? objective,
    String? notes,
    String? attendees,
    String? agenda,
    String? decisions,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    await _dao.updateMeeting(
      MeetingsCompanion(
        title: drift.Value(title),
        meetingType: drift.Value(type.value),
        customMeetingType: drift.Value(customMeetingType),
        date: drift.Value(date.toIso8601String().split('T').first),
        time: drift.Value(time),
        location: drift.Value(location),
        objective: drift.Value(objective),
        notes: drift.Value(notes),
        priority: drift.Value(priority.value),
        attendees: drift.Value(attendees),
        agenda: drift.Value(agenda),
        decisions: drift.Value(decisions),
        updatedAt: drift.Value(now),
      ),
      id,
    );

    await _logger.log(SecurityAction.settingsChanged, details: 'تم تعديل الاجتماع #$id: $title');
  }

  /// Update meeting status
  Future<void> updateStatus(int id, MeetingStatus status) async {
    await _dao.updateStatus(id, status.value);
    await _logger.log(SecurityAction.settingsChanged, details: 'تحديث حالة الاجتماع #$id');
  }

  /// Delete meeting (soft)
  Future<void> deleteMeeting(int id) async {
    await _dao.softDelete(id);
    await _logger.logRecordDeleted('اجتماع', id);
  }
}

/// Provider for MeetingsRepository
final meetingsRepositoryProvider = Provider<MeetingsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final logger = SecurityLogger(db.securityLogsDao);
  return MeetingsRepository(db, logger);
});
