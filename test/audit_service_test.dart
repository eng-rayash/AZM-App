@TestOn('vm')
library;

import 'dart:convert';

import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:azm/core/database/app_database.dart';
import 'package:azm/core/database/providers/database_providers.dart';
import 'package:azm/core/services/audit_service.dart';
import 'package:azm/features/hrm/domain/hrm_repository.dart';

/// اختبارات سجلّ التدقيق.
///
/// الجدول و`logAction` موجودان منذ v11 بلا مستدعٍ — ولم يكن ممكنًا
/// استدعاؤهما: `syncId` كان يُبنى من طابع زمني بستّ عشرة خانة والعمود
/// يشترط ٣٦، فكانت الدالة ترمي عند أي نداء.
void main() {
  late AppDatabase db;
  late ProviderContainer container;
  late AuditService audit;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
    audit = container.read(auditServiceProvider);
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  group('التسجيل', () {
    test('يكتب سجلًّا يمكن قراءته', () async {
      await audit.log(
        action: 'invoice.created',
        entityType: 'invoice',
        description: 'فاتورة تجريبية',
      );

      final rows = await audit.recent();
      expect(rows, hasLength(1));
      expect(rows.single.action, 'invoice.created');
      expect(rows.single.entityType, 'invoice');
    });

    test('syncId يطابق قيد العمود — العطب الذي كان يمنع أي استدعاء', () async {
      await audit.log(action: 'test.action');

      final row = (await audit.recent()).single;
      expect(row.syncId, hasLength(36));
    });

    test('يحلّ الفاعل والمستأجر حين لا مستخدم ولا شركة', () async {
      await audit.log(action: 'test.action');

      final row = (await audit.recent()).single;
      expect(row.actorSyncId, AuditService.localActor);
      expect(row.companySyncId, AuditService.personalTenant);
      // العمودان إلزاميّان بطول ٣٦ — البديلان يطابقانه
      expect(row.actorSyncId, hasLength(36));
      expect(row.companySyncId, hasLength(36));
    });

    test('القيَم المهيكلة تُحفظ JSON قابلًا للفكّ', () async {
      await audit.log(
        action: 'leave.approved',
        oldValue: {'status': 0},
        newValue: {'status': 1, 'approvedBy': 'المدير'},
      );

      final row = (await audit.recent()).single;
      expect(jsonDecode(row.oldValueJson!), {'status': 0});
      expect(
        jsonDecode(row.newValueJson!),
        {'status': 1, 'approvedBy': 'المدير'},
      );
    });

    test('الخطورة تُحفظ برقمها', () async {
      await audit.log(action: 'data.wiped', severity: AuditSeverity.critical);

      final row = (await audit.recent()).single;
      expect(row.severity, AuditSeverity.critical.value);
      expect(AuditSeverity.critical.value, 2);
    });

    test('الأحدث أولًا', () async {
      await audit.log(action: 'first.action');
      await Future<void>.delayed(const Duration(milliseconds: 5));
      await audit.log(action: 'second.action');

      final rows = await audit.recent();
      expect(rows.first.action, 'second.action');
    });
  });

  group('التدقيق يتبع الكتابة ولا يحرسها', () {
    test('إخفاق التسجيل لا يُفشل العملية الأصلية', () async {
      // قاعدة مغلقة: أي كتابة فيها ترمي
      final closed = AppDatabase.forTesting(NativeDatabase.memory());
      await closed.close();
      final broken = AuditService(closed);

      // لا يُعاد الرمي — سجلّ ناقص أهون من عملية لم تكتمل
      await expectLater(broken.log(action: 'x.y'), completes);
    });
  });

  group('التوصيل بمسارات الكتابة', () {
    test('اعتماد إجازة يترك أثرًا', () async {
      final repo = HrmRepository(db, audit);

      await repo.createLeaveRequest(
        employeeId: 1,
        employeeName: 'أحمد',
        leaveType: 0,
        startDate: '2026-10-01',
        endDate: '2026-10-05',
        daysCount: 5,
      );
      final leave = (await repo.watchPendingLeaves().first).single;

      await repo.updateLeaveStatus(
        leave: leave,
        newStatus: 1,
        approverName: 'المدير',
      );

      final rows = await audit.recent();
      final entry = rows.firstWhere((r) => r.action == 'leave.approved');
      expect(entry.entitySyncId, leave.syncId);
      expect(entry.severity, AuditSeverity.warning.value);
      expect(jsonDecode(entry.newValue()), containsPair('status', 1));
    });

    test('الجزاء يُسجَّل بخطورة أعلى من المكافأة', () async {
      final repo = HrmRepository(db, audit);

      await repo.createRewardPenalty(
        employeeId: 1,
        type: 0,
        reason: 'أداء متميز',
        date: '2026-09-18',
      );
      await repo.createRewardPenalty(
        employeeId: 2,
        type: 1,
        reason: 'تأخّر متكرر',
        date: '2026-09-18',
      );

      final rows = await audit.recent();
      final reward = rows.firstWhere((r) => r.action == 'reward.created');
      final penalty = rows.firstWhere((r) => r.action == 'penalty.created');

      expect(reward.severity, AuditSeverity.info.value);
      expect(penalty.severity, AuditSeverity.warning.value);
    });
  });
}

extension on AuditLog {
  String newValue() => newValueJson ?? '{}';
}
