import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/dao/calls_dao.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/security/security_logger.dart';
import '../../../core/constants/enums.dart';

/// Repository for Calls — Phase 4
class CallsRepository {
  final CallsDao _dao;
  final SecurityLogger _logger;
  final _uuid = const Uuid();

  CallsRepository(this._dao, this._logger);

  Future<void> logCall({
    required String callerName,
    required int callType, // 0: Incoming, 1: Outgoing, 2: Missed
    required String date,
    required String time,
    String? phoneNumber,
    String? summary,
    bool isImportant = false,
  }) async {
    final companion = CallsCompanion.insert(
      syncId: _uuid.v4(),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      callerName: callerName,
      callType: Value(callType),
      date: date,
      time: time,
      phoneNumber: Value(phoneNumber),
      summary: Value(summary),
      isImportant: Value(isImportant),
    );

    await _dao.insertCall(companion);

    if (isImportant) {
      await _logger.log(
        SecurityAction.settingsChanged,
        details: 'تم تسجيل مكالمة هامة من/إلى $callerName',
      );
    }
  }

  Stream<List<CallItem>> watchAllCalls() => _dao.watchAllCalls();

  Future<bool> updateCall({
    required int id,
    required String callerName,
    required int callType,
    required String date,
    required String time,
    String? phoneNumber,
    String? summary,
    bool isImportant = false,
  }) async {
    final companion = CallsCompanion(
      callerName: Value(callerName),
      callType: Value(callType),
      date: Value(date),
      time: Value(time),
      phoneNumber: Value(phoneNumber),
      summary: Value(summary),
      isImportant: Value(isImportant),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    );
    return await _dao.updateCall(companion, id);
  }

  Future<void> deleteCall(int id) async {
    await _dao.softDelete(id);
    await _logger.logRecordDeleted('مكالمة', id);
  }
}

final callsRepositoryProvider = Provider<CallsRepository>((ref) {
  final dao = ref.watch(callsDaoProvider);
  final db = ref.watch(databaseProvider);
  final logger = SecurityLogger(db.securityLogsDao);
  return CallsRepository(dao, logger);
});

final callsListProvider = StreamProvider<List<CallItem>>((ref) {
  final repo = ref.watch(callsRepositoryProvider);
  return repo.watchAllCalls();
});