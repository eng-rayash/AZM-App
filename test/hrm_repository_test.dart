@TestOn('vm')
library;

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:azm/core/database/app_database.dart';
import 'package:azm/features/hrm/domain/hrm_repository.dart';

/// اختبارات تدفّقات الإنشاء في الموارد البشرية.
///
/// سببها المباشر: خمس شاشات كانت تبني `Companion` بلا الأعمدة الأساسية
/// (`syncId` و`createdAt` و`updatedAt`)، فيرفض Drift الإدراج
/// بـ`InvalidDataException` — أي أن أزرار «تقديم» و«حفظ» لم تكن تحفظ شيئًا،
/// وكان الفشل صامتًا لأن الاستثناء يقع داخل `onPressed` غير محروس.
///
/// هذه الاختبارات تثبت أن المسار يعمل من طرفه إلى طرفه، وتمنع عودة العطب.
void main() {
  late AppDatabase db;
  late HrmRepository repo;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    repo = HrmRepository(db);
  });

  tearDown(() async => db.close());

  group('السلف', () {
    test('تُحفظ وتظهر في التدفّق', () async {
      final id = await repo.createAdvance(
        employeeId: 1,
        employeeName: 'أحمد العتيبي',
        amount: 5000,
        requestDate: '2026-09-11',
        reason: 'ظرف طارئ',
      );
      expect(id, greaterThan(0));

      final rows = await repo.watchAdvances().first;
      expect(rows, hasLength(1));
      expect(rows.single.employeeName, 'أحمد العتيبي');
      expect(rows.single.amount, 5000);
      expect(rows.single.status, 0, reason: 'الحالة الافتراضية: معلّق');
    });

    test('تملأ الأعمدة الأساسية التي كانت الشاشة تُغفلها', () async {
      await repo.createAdvance(
        employeeId: 2,
        amount: 1200,
        requestDate: '2026-09-11',
      );

      final row = (await repo.watchAdvances().first).single;
      expect(row.syncId, hasLength(36), reason: 'UUID للمزامنة');
      expect(row.createdAt, greaterThan(0));
      expect(row.updatedAt, greaterThan(0));
      expect(row.isDeleted, isFalse);
    });
  });

  group('تقييم الأداء', () {
    test('يُحفظ ويحسب النسبة من الدرجات', () async {
      await repo.createEvaluation(
        employeeId: 1,
        employeeName: 'سارة',
        period: '2026-Q3',
        totalScore: 45,
        maxPossibleScore: 50,
      );

      final row = (await repo.watchEvaluations().first).single;
      expect(row.period, '2026-Q3');
      expect(row.percentage, closeTo(90, 0.01));
    });

    test('النسبة الممرَّرة صراحةً تسبق الحساب', () async {
      await repo.createEvaluation(
        employeeId: 1,
        period: '2026-Q3',
        percentage: 72,
        totalScore: 45,
        maxPossibleScore: 50,
      );

      final row = (await repo.watchEvaluations().first).single;
      expect(row.percentage, 72);
    });
  });

  group('التدريب', () {
    test('يُحفظ بنوعه وحالته', () async {
      await repo.createTraining(
        employeeId: 3,
        employeeName: 'خالد',
        trainingName: 'إدارة المشاريع',
        provider: 'معهد الإدارة',
        trainingType: 2,
        startDate: '2026-10-01',
      );

      final row = (await repo.watchTrainings().first).single;
      expect(row.trainingName, 'إدارة المشاريع');
      expect(row.trainingType, 2);
      expect(row.syncId, hasLength(36));
    });
  });

  group('المكافآت والجزاءات', () {
    test('تُحفظ بنوعها ومبلغها', () async {
      await repo.createRewardPenalty(
        employeeId: 4,
        employeeName: 'نورة',
        type: 1,
        reason: 'تأخّر متكرر',
        date: '2026-09-11',
        amount: 300,
      );

      final row = (await repo.watchRewardsPenalties().first).single;
      expect(row.type, 1);
      expect(row.amount, 300);
      expect(row.reason, 'تأخّر متكرر');
    });
  });

  group('الإجازات', () {
    test('الطلب يُحفظ', () async {
      await repo.createLeaveRequest(
        employeeId: 5,
        employeeName: 'محمد',
        leaveType: 0,
        startDate: '2026-10-01',
        endDate: '2026-10-05',
        daysCount: 5,
        reason: 'إجازة سنوية',
      );

      final rows = await repo.watchPendingLeaves().first;
      expect(rows, hasLength(1));
      expect(rows.single.days, 5);
    });

    test('تغيير الحالة لا يمحو بقية الحقول', () async {
      // الشاشة كانت تبني صفًّا جزئيًا وتستدعي `replace`، فتُفقَد كل
      // الحقول غير المذكورة — اسم الموظف والسبب من بينها.
      await repo.createLeaveRequest(
        employeeId: 5,
        employeeName: 'محمد الشهري',
        leaveType: 0,
        startDate: '2026-10-01',
        endDate: '2026-10-05',
        daysCount: 5,
        reason: 'إجازة سنوية',
      );

      final before = (await repo.watchPendingLeaves().first).single;
      await repo.updateLeaveStatus(
        leave: before,
        newStatus: 1,
        approverName: 'المدير',
      );

      final after = (await repo.watchLeavesByEmployee(5).first).single;
      expect(after.status, 1);
      expect(after.employeeName, 'محمد الشهري', reason: 'لا يُمحى');
      expect(after.reason, 'إجازة سنوية', reason: 'لا يُمحى');
      expect(after.approvedByName, 'المدير');
    });
  });
}
