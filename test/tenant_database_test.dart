@TestOn('vm')
library;

import 'dart:io';

import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:azm/core/constants/app_constants.dart';
import 'package:azm/core/database/app_database.dart';
import 'package:azm/core/database/tenant_database.dart';

/// العزل المحلي: **قاعدة لكل شركة**.
///
/// البديل المرفوض كان `where companyId = ?` في ١٨٠ استعلامًا، وكل
/// استعلام جديد فرصة نسيان لا يُصدر خطأً بل بيانات شركة أخرى.
///
/// هنا لا يوجد مرشّح أصلًا. الاختبارات أدناه تكتب في ملف شركة وتقرأ
/// من ملف أخرى — وما لا يوجد في الملف المفتوح غير موجود.
void main() {
  // drift يحذّر من إنشاء صنف القاعدة مرّتين لأن منفّذًا مشتركًا بين
  // نسختين يسبّب تنازعًا. هنا — وفي التطبيق — المنفّذان مختلفان:
  // ملفّ لكل مستأجر، وملفّ السجلّ منفصل عنهما. التحذير إيجابية كاذبة،
  // وتركه يدرّب على تجاهل تحذيرات drift الحقيقية.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  group('اشتقاق اسم الملف', () {
    test('الوضع الشخصي يحتفظ بالاسم القديم', () {
      // شرط لا تفصيل: تغييره يفتح ملفًا فارغًا فيبدو أن البيانات ضاعت
      expect(tenantDbName(personalTenant), AppConstants.dbName);
    });

    test('كل شركة اسم مختلف', () {
      final a = tenantDbName('11111111-2222-3333-4444-555555555555');
      final b = tenantDbName('66666666-7777-8888-9999-000000000000');

      expect(a, isNot(b));
      expect(a, isNot(AppConstants.dbName));
    });

    test('ثابت عبر النداءات — الاسم لا يتغيّر فتختفي البيانات', () {
      const id = 'aaaaaaaa-bbbb-cccc-dddd-eeeeeeeeeeee';
      expect(tenantDbName(id), tenantDbName(id));
    });

    test('يعقّم ما قد يصير مسارًا', () {
      // معرّف يحمل `/` أو `..` كان سيكتب خارج مجلّد التطبيق
      final name = tenantDbName('../../etc/passwd');
      expect(name, isNot(contains('/')));
      expect(name, isNot(contains('..')));
    });

    test('معرّفان طويلان بالبادئة نفسها لا يتشاركان ملفًا', () {
      final prefix = 'x' * 80;
      expect(tenantDbName('${prefix}alpha'), isNot(tenantDbName('${prefix}beta')));
    });

    test('معرّف لا يصلح اسمًا يفشل صراحةً لا صامتًا', () {
      // الفشل الصريح خير من ملف واحد تتشاركه كل الحالات الشاذّة
      expect(() => tenantDbName('///'), throwsArgumentError);
      expect(() => tenantDbName(''), throwsArgumentError);
    });
  });

  group('العزل بين ملفين', () {
    late Directory tmp;
    late AppDatabase alpha;
    late AppDatabase beta;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('azm_tenant_test');
      alpha = AppDatabase.forTesting(
        NativeDatabase(File('${tmp.path}/${tenantDbName('alpha')}')),
      );
      beta = AppDatabase.forTesting(
        NativeDatabase(File('${tmp.path}/${tenantDbName('beta')}')),
      );
    });

    tearDown(() async {
      await alpha.close();
      await beta.close();
      await tmp.delete(recursive: true);
    });

    Future<void> addMeeting(AppDatabase db, String title) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.meetingsDao.insertMeeting(
        MeetingsCompanion.insert(
          syncId: 'mtg-$title'.padRight(36, '-').substring(0, 36),
          title: title,
          date: '2026-10-01',
          time: '10:00',
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    test('ما يُكتب في ألفا لا يُرى في بيتا — ولا مرشّح في الاستعلام', () async {
      await addMeeting(alpha, 'اجتماع ألفا السرّي');

      // `getAllActive` بلا أي شرط شركة — وهذا هو بيت القصيد
      expect(await beta.meetingsDao.getAllActive(), isEmpty);
      expect(
        (await alpha.meetingsDao.getAllActive()).single.title,
        'اجتماع ألفا السرّي',
      );
    });

    test('البحث لا يعبر الحدّ', () async {
      await addMeeting(alpha, 'مراجعة مؤسسة ألفا');
      await addMeeting(beta, 'مراجعة مؤسسة بيتا');

      final fromBeta = await beta.meetingsDao.search('موسسه');
      expect(fromBeta, hasLength(1));
      expect(fromBeta.single.title, 'مراجعة مؤسسة بيتا');
    });

    test('الحذف في واحدة لا يمسّ الأخرى', () async {
      await addMeeting(alpha, 'مشترك');
      await addMeeting(beta, 'مشترك');

      final target = (await alpha.meetingsDao.getAllActive()).single;
      await alpha.meetingsDao.softDelete(target.id);

      expect(await alpha.meetingsDao.getAllActive(), isEmpty);
      expect(await beta.meetingsDao.getAllActive(), hasLength(1));
    });

    test('«امسح كل البيانات» لا تتعدّى ملفها', () async {
      await addMeeting(alpha, 'ألفا');
      await addMeeting(beta, 'بيتا');

      await alpha.transaction(() async {
        for (final table in alpha.allTables) {
          await alpha.delete(table).go();
        }
      });

      expect(await alpha.meetingsDao.getAllActive(), isEmpty);
      expect(await beta.meetingsDao.getAllActive(), hasLength(1));
    });

    test('المعرّف المتسلسل يتكرّر بين الملفين بلا تصادم', () async {
      // كل ملف يبدأ ترقيمه من ١. هذا مقبول لأن `syncId` هو الهوية
      // العابرة للأجهزة، و`id` محليّ للملف.
      await addMeeting(alpha, 'أ');
      await addMeeting(beta, 'ب');

      expect(
        (await alpha.meetingsDao.getAllActive()).single.id,
        (await beta.meetingsDao.getAllActive()).single.id,
      );
    });
  });
}
