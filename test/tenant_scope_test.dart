@TestOn('vm')
library;

// `Value` وحده مطلوب من drift: تصديره لـ isNull/isNotNull يصطدم
// بمطابِقَي flutter_test اللذين يحملان الاسمين نفسيهما.
import 'package:drift/drift.dart' show Value, Variable;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:azm/core/database/app_database.dart';

/// اختبارات نطاق المستأجر — الأساس الذي يقوم عليه تعدّد الشركات.
///
/// المخطط كان فيه ٤ جداول مستأجر فقط تحمل مرجع الشركة، و٤٤ جدول أعمال
/// بلا أي مرجع. أي استعلام كان يرى بيانات كل الشركات.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async => db.close());

  group('المخطط', () {
    test('٤١ جدول أعمال تحمل company_id', () async {
      final scoped = db.allTables
          .where((t) => t.columnsByName.containsKey('company_id'))
          .map((t) => t.actualTableName)
          .toList();

      expect(scoped, hasLength(41));
    });

    test('ما لا يخصّ شركة لا يحمل العمود', () async {
      String? colOf(String table) {
        final t = db.allTables.firstWhere((t) => t.actualTableName == table);
        return t.columnsByName.containsKey('company_id') ? 'yes' : null;
      }

      // المستخدم عالمي — عضوياته في company_members
      expect(colOf('users'), isNull);
      // إعدادات جهاز لا بيانات عمل
      expect(colOf('app_settings'), isNull);
      // أحداث تقع قبل اختيار شركة
      expect(colOf('security_logs'), isNull);
      // جذر المستأجر لا يشير إلى نفسه
      expect(colOf('companies'), isNull);
    });

    test('جداول الأعمال الأساسية مشمولة', () async {
      bool scoped(String table) => db.allTables
          .firstWhere((t) => t.actualTableName == table)
          .columnsByName
          .containsKey('company_id');

      for (final t in [
        'employees',
        'invoices',
        'expenses',
        'revenues',
        'projects',
        'meetings',
        'follow_ups',
        'clients',
        'salary_records',
        'journal_entries',
      ]) {
        expect(scoped(t), isTrue, reason: '$t يجب أن يحمل company_id');
      }
    });
  });

  group('الشركة المحلية الافتراضية', () {
    test('تُنشأ عند فتح قاعدة جديدة', () async {
      // يفتح الاتصال ويشغّل beforeOpen
      await db.customSelect('SELECT 1').get();

      final local = await (db.select(db.companies)
            ..where((c) => c.syncId.equals(AppDatabase.localCompanyId)))
          .getSingleOrNull();

      expect(local, isNotNull);
      expect(local!.name, 'مساحة العمل المحلية');
      expect(local.syncId, hasLength(36), reason: 'يطابق قيد العمود');
    });

    test('لا تتكرّر عند إعادة الفتح', () async {
      await db.customSelect('SELECT 1').get();
      await db.customSelect('SELECT 1').get();

      final all = await (db.select(db.companies)
            ..where((c) => c.syncId.equals(AppDatabase.localCompanyId)))
          .get();

      expect(all, hasLength(1));
    });
  });

  group('نسب الصفوف اليتيمة', () {
    test('صفّ كُتب بلا مالك يُنسب إلى الشركة المحلية', () async {
      await db.customSelect('SELECT 1').get();

      // محاكاة صفّ سابق على تعدّد المستأجرين: يُكتب بلا company_id
      await db.into(db.meetings).insert(
            MeetingsCompanion.insert(
              syncId: 'a' * 36,
              title: 'اجتماع قديم',
              date: '2026-01-01',
              time: '10:00',
              createdAt: 1,
              updatedAt: 1,
            ),
          );

      final before = (await db.select(db.meetings).get()).single;
      expect(before.companyId, isNull, reason: 'كُتب بلا مالك');

      // إعادة تشغيل منطق الملء كما يقع عند الإقلاع
      await db.customUpdate(
        'UPDATE "meetings" SET company_id = ? WHERE company_id IS NULL',
        variables: [Variable.withString(AppDatabase.localCompanyId)],
        updates: {db.meetings},
      );

      final after = (await db.select(db.meetings).get()).single;
      expect(after.companyId, AppDatabase.localCompanyId);
    });
  });

  group('العزل — الأساس الذي يبني عليه الخادم', () {
    test('تقييد الاستعلام بالشركة يفصل البيانات', () async {
      await db.customSelect('SELECT 1').get();

      const companyA = 'company-a---------------------------';
      const companyB = 'company-b---------------------------';

      Future<void> addMeeting(String id, String company, String title) =>
          db.into(db.meetings).insert(
                MeetingsCompanion.insert(
                  syncId: id,
                  title: title,
                  date: '2026-01-01',
                  time: '10:00',
                  createdAt: 1,
                  updatedAt: 1,
                  companyId: Value(company),
                ),
              );

      await addMeeting('a' * 36, companyA, 'اجتماع شركة أ');
      await addMeeting('b' * 36, companyB, 'اجتماع شركة ب');

      final onlyA = await (db.select(db.meetings)
            ..where((m) => m.companyId.equals(companyA)))
          .get();

      expect(onlyA, hasLength(1));
      expect(onlyA.single.title, 'اجتماع شركة أ');

      // بلا تقييد يرى الاستعلام الشركتين — وهذا بالضبط ما كان يحدث
      // في كل استعلام قبل هذه الهجرة
      final unscoped = await db.select(db.meetings).get();
      expect(unscoped, hasLength(2));
    });
  });
}
