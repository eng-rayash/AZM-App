import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/dao/visitors_dao.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/security/security_logger.dart';
import '../../../core/constants/enums.dart';

/// Repository for Visitors — Phase 4
class VisitorsRepository {
  final VisitorsDao _dao;
  final SecurityLogger _logger;
  final _uuid = const Uuid();

  VisitorsRepository(this._dao, this._logger);

  Future<void> registerVisitor({
    required String visitorName,
    String? company,
    String? purpose,
    String? appointmentId,
  }) async {
    final entryTime = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    
    final companion = VisitorsCompanion.insert(
      syncId: _uuid.v4(),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      visitorName: visitorName,
      company: Value(company),
      purpose: Value(purpose),
      appointmentId: Value(appointmentId),
      entryTime: Value(entryTime),
      status: const Value(1), // 1: Inside
    );

    await _dao.insertVisitor(companion);

    await _logger.log(
      SecurityAction.settingsChanged,
      details: 'دخول زائر: $visitorName',
    );
  }

  Future<void> checkoutVisitor(int visitorId, String visitorName) async {
    final exitTime = '${DateTime.now().hour.toString().padLeft(2, '0')}:${DateTime.now().minute.toString().padLeft(2, '0')}';
    await _dao.updateVisitorStatus(visitorId, 2, exitTime); // 2: Left
    
    await _logger.log(
      SecurityAction.settingsChanged,
      details: 'مغادرة زائر: $visitorName',
    );
  }

  Stream<List<VisitorItem>> watchActiveVisitors() => _dao.watchActiveVisitors();

  Future<bool> updateVisitor({
    required int id,
    required String visitorName,
    String? company,
    String? purpose,
    String? appointmentId,
    String? entryTime,
    String? exitTime,
    int? status,
  }) async {
    final companion = VisitorsCompanion(
      visitorName: Value(visitorName),
      company: company != null ? Value(company) : const Value.absent(),
      purpose: purpose != null ? Value(purpose) : const Value.absent(),
      appointmentId: appointmentId != null ? Value(appointmentId) : const Value.absent(),
      entryTime: entryTime != null ? Value(entryTime) : const Value.absent(),
      exitTime: exitTime != null ? Value(exitTime) : const Value.absent(),
      status: status != null ? Value(status) : const Value.absent(),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    );
    return await _dao.updateVisitor(companion, id);
  }

  Future<void> deleteVisitor(int id) async {
    await _dao.softDelete(id);
    await _logger.logRecordDeleted('زائر', id);
  }
}

final visitorsRepositoryProvider = Provider<VisitorsRepository>((ref) {
  final dao = ref.watch(visitorsDaoProvider);
  final db = ref.watch(databaseProvider);
  final logger = SecurityLogger(db.securityLogsDao);
  return VisitorsRepository(dao, logger);
});

final activeVisitorsProvider = StreamProvider<List<VisitorItem>>((ref) {
  final repo = ref.watch(visitorsRepositoryProvider);
  return repo.watchActiveVisitors();
});