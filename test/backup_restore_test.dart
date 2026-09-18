@TestOn('vm')
library;

import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:azm/core/database/app_database.dart';
import 'package:azm/features/backup/domain/backup_service_native.dart';

/// اختبارات دمج النسخة الاحتياطية.
///
/// هذا أول اختبار منطق حقيقي في المشروع، وموضعه مقصود: الإصدار السابق
/// من الاستعادة كان يعلن النجاح دون نقل صفّ واحد — فشل صامت في الوظيفة
/// التي يلجأ إليها المستخدم في أسوأ لحظاته. ما لا يُختبر هنا يعود.
void main() {
  late Directory tmp;

  setUp(() async {
    tmp = await Directory.systemTemp.createTemp('azm_restore_test');
  });

  tearDown(() async {
    if (await tmp.exists()) {
      await tmp.delete(recursive: true);
    }
  });

  /// ينشئ قاعدة على القرص — الدمج يعتمد على `ATTACH` فلا تصلح
  /// قاعدة في الذاكرة، إذ لا مسار لها يُرفَق.
  Future<(AppDatabase, File)> newDbFile(String name) async {
    final file = File('${tmp.path}/$name.sqlite');
    final db = AppDatabase.forTesting(NativeDatabase(file));
    // استعلام واحد يجبر إنشاء المخطط
    await db.customSelect('SELECT 1').get();
    return (db, file);
  }

  Future<void> insertMeeting(
    AppDatabase db, {
    required String syncId,
    required String title,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await db.customInsert(
      'INSERT INTO meetings (sync_id, created_at, updated_at, is_deleted, '
      'title, date, time) VALUES (?, ?, ?, 0, ?, ?, ?)',
      variables: [
        Variable.withString(syncId),
        Variable.withInt(now),
        Variable.withInt(now),
        Variable.withString(title),
        Variable.withString('2026-09-07'),
        Variable.withString('10:00'),
      ],
    );
  }

  Future<List<String>> meetingTitles(AppDatabase db) async {
    final rows = await db
        .customSelect('SELECT title FROM meetings ORDER BY title')
        .get();
    return rows.map((r) => r.read<String>('title')).toList();
  }

  test('ينقل الصفوف الغائبة من النسخة إلى القاعدة', () async {
    final (target, _) = await newDbFile('target');
    final (backup, backupFile) = await newDbFile('backup');

    await insertMeeting(target, syncId: 'a' * 36, title: 'اجتماع محلي');
    await insertMeeting(backup, syncId: 'b' * 36, title: 'اجتماع من النسخة');
    await backup.close();

    final result = await mergeFromBackupFile(target, backupFile.path);

    expect(result.isSuccess, isTrue);
    expect(result.insertedRows, 1, reason: 'صفّ واحد فقط غائب عن الهدف');
    expect(
      await meetingTitles(target),
      containsAll(<String>['اجتماع محلي', 'اجتماع من النسخة']),
    );

    await target.close();
  });

  test('لا يكرّر صفًّا موجودًا بنفس sync_id', () async {
    final shared = 'c' * 36;
    final (target, _) = await newDbFile('target');
    final (backup, backupFile) = await newDbFile('backup');

    await insertMeeting(target, syncId: shared, title: 'النسخة الأحدث');
    await insertMeeting(backup, syncId: shared, title: 'النسخة الأقدم');
    await backup.close();

    final result = await mergeFromBackupFile(target, backupFile.path);

    expect(result.isSuccess, isTrue);
    expect(result.insertedRows, 0);
    // الصفّ القائم لا يُكتب فوقه: الاستعادة تضيف ولا تستبدل عملًا أحدث
    expect(await meetingTitles(target), <String>['النسخة الأحدث']);

    await target.close();
  });

  test('نسخة فارغة تنجح ولا تضيف شيئًا — وتُبلَّغ بوضوح', () async {
    final (target, _) = await newDbFile('target');
    final (backup, backupFile) = await newDbFile('backup');
    await backup.close();

    await insertMeeting(target, syncId: 'd' * 36, title: 'اجتماع محلي');

    final result = await mergeFromBackupFile(target, backupFile.path);

    expect(result.isSuccess, isTrue);
    expect(result.insertedRows, 0);
    expect(result.isEmpty, isTrue);
    // الرسالة تقول الحقيقة بدل «تمت الاستعادة بنجاح»
    expect(result.displayMessage, contains('لم يُضَف شيء'));

    await target.close();
  });

  test('ملف ليس قاعدة بيانات يفشل ولا يمسّ البيانات القائمة', () async {
    final (target, _) = await newDbFile('target');
    await insertMeeting(target, syncId: 'e' * 36, title: 'اجتماع محلي');

    final junk = File('${tmp.path}/junk.sqlite');
    await junk.writeAsString('هذا ليس ملف قاعدة بيانات');

    final result = await mergeFromBackupFile(target, junk.path);

    expect(result.isSuccess, isFalse);
    expect(await meetingTitles(target), <String>['اجتماع محلي']);

    await target.close();
  });

  test('يدمج عدة جداول في تمريرة واحدة', () async {
    final (target, _) = await newDbFile('target');
    final (backup, backupFile) = await newDbFile('backup');

    final now = DateTime.now().millisecondsSinceEpoch;
    await insertMeeting(backup, syncId: 'f' * 36, title: 'اجتماع');
    await backup.customInsert(
      'INSERT INTO contacts (sync_id, created_at, updated_at, is_deleted, '
      'name) VALUES (?, ?, ?, 0, ?)',
      variables: [
        Variable.withString('g' * 36),
        Variable.withInt(now),
        Variable.withInt(now),
        Variable.withString('خالد'),
      ],
    );
    await backup.close();

    final result = await mergeFromBackupFile(target, backupFile.path);

    expect(result.isSuccess, isTrue);
    expect(result.insertedRows, 2);
    expect(result.mergedTables, greaterThan(1));

    await target.close();
  });
}
