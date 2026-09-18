@TestOn('vm')
library;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:azm/core/database/app_database.dart';
import 'package:azm/features/backup/domain/backup_service.dart';
import 'package:azm/core/security/security_logger.dart';

/// اختبارات الحذف الشامل.
///
/// سببها: زرّ «حذف جميع البيانات» كان يعدّد ١٤ جدولًا من أصل ٤٨، فيترك
/// الموظفين والرواتب والفواتير والمشاريع خلفه ثم يخبر المستخدم أن كل
/// بياناته حُذفت. الادّعاء الكاذب في عملية مدمِّرة أسوأ من عدم وجودها.
void main() {
  late AppDatabase db;
  late BackupService service;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    service = BackupService(SecurityLogger(db.securityLogsDao), db);
  });

  tearDown(() async => db.close());

  test('يمرّ على كل جدول في المخطط لا على قائمة مكتوبة يدويًا', () async {
    final cleared = await service.wipeAllData();

    // العدد يساوي كل جداول المخطط — لو أُضيف جدول جديد شمله الحذف
    expect(cleared, db.allTables.length);
    expect(cleared, greaterThan(40),
        reason: 'المخطط يحوي ٤٨ جدولًا؛ النسخة القديمة كانت تحذف ١٤');
  });

  test('يفرغ جداول كانت النسخة القديمة تتخطّاها', () async {
    // جداول خارج القائمة الـ١٤ القديمة: موظفون ورواتب وفواتير ومشاريع
    await db.into(db.employees).insert(
          EmployeesCompanion.insert(
            syncId: 'a' * 36,
            employeeCode: const Value('EMP-001'),
            name: 'أحمد',
            createdAt: 1,
            updatedAt: 1,
          ),
        );
    await db.into(db.invoices).insert(
          InvoicesCompanion.insert(
            syncId: 'b' * 36,
            issueDate: '2026-09-18',
            createdAt: 1,
            updatedAt: 1,
          ),
        );
    await db.into(db.projects).insert(
          ProjectsCompanion.insert(
            syncId: 'c' * 36,
            name: 'مشروع',
            createdAt: 1,
            updatedAt: 1,
          ),
        );

    expect(await db.select(db.employees).get(), hasLength(1));
    expect(await db.select(db.invoices).get(), hasLength(1));
    expect(await db.select(db.projects).get(), hasLength(1));

    await service.wipeAllData();

    expect(await db.select(db.employees).get(), isEmpty);
    expect(await db.select(db.invoices).get(), isEmpty);
    expect(await db.select(db.projects).get(), isEmpty);
  });

  test('يفرغ الجداول التي كانت النسخة القديمة تشملها أيضًا', () async {
    await db.into(db.meetings).insert(
          MeetingsCompanion.insert(
            syncId: 'd' * 36,
            title: 'اجتماع',
            date: '2026-09-18',
            time: '10:00',
            createdAt: 1,
            updatedAt: 1,
          ),
        );

    await service.wipeAllData();

    expect(await db.select(db.meetings).get(), isEmpty);
  });
}
