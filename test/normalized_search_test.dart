@TestOn('vm')
library;

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:azm/core/database/app_database.dart';

/// البحث المطبَّع عبر طبقة DAO الحقيقية.
///
/// `arabic_normalizer_test.dart` يثبت أن الدالة تطبّع. هذا الملف يثبت
/// أن **البحث في التطبيق يستعملها** — والفرق بينهما هو الفرق الذي
/// تكرّر في هذا المشروع: شيء مكتوب وصحيح ولا يناديه أحد.
///
/// قبل هذا التوصيل كان البحث `LIKE '%q%'` على النصّ الخام، فيفشل
/// صامتًا: المستخدم يكتب «احمد» فيرى نتيجة فارغة ويظنّ أن السجلّ غير
/// موجود، ولا شيء يدلّه على أن السبب إملائي.
/// طوابع زمنية بالمللي ثانية — `BaseTableMixin` يخزّنها أعدادًا.
final _now = DateTime.now().millisecondsSinceEpoch;

/// معرّف مزامنة بطول ٣٦ بالضبط، محسوبًا لا معدودًا باليد.
///
/// العمود يشترط الطول، وعدّ الشرطات يدويًا هو ما أفشل هذا الملف أول
/// مرة — وهو العطب نفسه الذي جعل `logAction` غير قابل للاستدعاء.
String _syncId(String seed) => seed.padRight(36, '-').substring(0, 36);

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  group('الموظفون', () {
    setUp(() async {
      await db.employeesDao.insertEmployee(
        EmployeesCompanion.insert(
          syncId: _syncId('emp-ahmed'),
          name: 'أحمد العتيبي',
          employeeCode: const Value('EMP-001'),
          phone: const Value('0551234567'),
          createdAt: _now,
          updatedAt: _now,
        ),
      );
      await db.employeesDao.insertEmployee(
        EmployeesCompanion.insert(
          syncId: _syncId('emp-mostafa'),
          name: 'مصطفى محمد',
          employeeCode: const Value('EMP-002'),
          createdAt: _now,
          updatedAt: _now,
        ),
      );
    });

    test('«احمد» يجد «أحمد» — كان يعيد لا شيء', () async {
      final found = await db.employeesDao.search('احمد');
      expect(found, hasLength(1));
      expect(found.single.name, 'أحمد العتيبي');
    });

    test('«مصطفي» يجد «مصطفى»', () async {
      final found = await db.employeesDao.search('مصطفي');
      expect(found.single.name, 'مصطفى محمد');
    });

    test('الأرقام العربية-الهندية تجد المخزَّن باللاتينية', () async {
      final found = await db.employeesDao.search('٠٥٥١٢٣٤٥٦٧');
      expect(found.single.name, 'أحمد العتيبي');
    });

    test('الرقم الوظيفي باللاتينية الصغيرة يُطابق', () async {
      final found = await db.employeesDao.search('emp-002');
      expect(found.single.name, 'مصطفى محمد');
    });

    test('لا يطابق اسمًا مختلفًا فعلًا', () async {
      expect(await db.employeesDao.search('خالد'), isEmpty);
    });

    test('نصّ فارغ يعيد الكل لا لا شيء', () async {
      expect(await db.employeesDao.search(''), hasLength(2));
    });

    test('المحذوف لا يظهر — كان يظهر', () async {
      final ahmed = (await db.employeesDao.search('احمد')).single;
      await db.employeesDao.deleteEmployee(ahmed.id);

      expect(await db.employeesDao.search('احمد'), isEmpty);
    });
  });

  group('الاجتماعات', () {
    test('«شركه» يجد «شركة» في العنوان', () async {
      await db.meetingsDao.insertMeeting(
        MeetingsCompanion.insert(
          syncId: _syncId('mtg-test'),
          title: 'اجتماع شركة سحبكم',
          date: '2026-10-01',
          time: '10:00',
          createdAt: _now,
          updatedAt: _now,
        ),
      );

      final found = await db.meetingsDao.search('شركه');
      expect(found.single.title, 'اجتماع شركة سحبكم');
    });

    test('الحدّ يُطبَّق بعد التصفية لا قبلها', () async {
      // ستّون اجتماعًا يطابق، والحدّ خمسون. لو قُطع قبل التصفية
      // لاعتمدت النتيجة على ترتيب الصفوف لا على المطابقة.
      for (var i = 0; i < 60; i++) {
        await db.meetingsDao.insertMeeting(
          MeetingsCompanion.insert(
            syncId: _syncId('mtg-limit-$i-'),
            title: 'مراجعة مؤسسة رقم $i',
            date: '2026-10-01',
            time: '10:00',
            createdAt: _now,
            updatedAt: _now,
          ),
        );
      }

      final found = await db.meetingsDao.search('موسسه');
      expect(found, hasLength(50));
    });
  });

  group('العملاء', () {
    setUp(() async {
      await db.financeDao.insertClient(
        ClientsCompanion.insert(
          syncId: _syncId('cli-test'),
          name: 'مؤسسة النور',
          createdAt: _now,
          updatedAt: _now,
        ),
      );
    });

    test('«موسسه» يجد «مؤسسة»', () async {
      final found = await db.financeDao.searchClients('موسسه');
      expect(found.single.name, 'مؤسسة النور');
    });

    test('المحذوف لا يظهر — كان يظهر', () async {
      final client = (await db.financeDao.searchClients('موسسه')).single;
      await (db.update(db.clients)..where((c) => c.id.equals(client.id)))
          .write(const ClientsCompanion(isDeleted: Value(true)));

      expect(await db.financeDao.searchClients('موسسه'), isEmpty);
    });
  });

  group('جهات الاتصال — البحث تدفّقي', () {
    test('«شركه» يجد «شركة» عبر التدفّق', () async {
      await db.contactsDao.insertContact(
        ContactsCompanion.insert(
          syncId: _syncId('con-test'),
          name: 'سعد',
          company: const Value('شركة الفجر'),
          createdAt: _now,
          updatedAt: _now,
        ),
      );

      final found = await db.contactsDao.searchContacts('شركه').first;
      expect(found.single.name, 'سعد');
    });
  });
}
