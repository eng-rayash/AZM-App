// Native-only backup implementation — compiled ONLY on Android/iOS/Desktop.
// Safely imports drift/native.dart and dart:io without affecting web builds.
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/database/app_database.dart';
import '../../../core/security/security_logger.dart';
import 'restore_result.dart';

/// Export database as .sqlite backup file and share it.
Future<bool> exportNative(SecurityLogger logger, AppDatabase db) async {
  try {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, AppConstants.dbName));
    if (!await dbFile.exists()) return false;

    final dateStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
    final backupFileName = 'azm_backup_$dateStr.sqlite';

    final tempDir = await getTemporaryDirectory();
    final tempFile = File(p.join(tempDir.path, backupFileName));

    // التفريغ قبل النسخ: لولاه قد تبقى كتابات في سجلّ WAL خارج الملف
    // فتخرج نسخة ناقصة تبدو سليمة.
    await db.customStatement('PRAGMA wal_checkpoint(TRUNCATE)');
    await dbFile.copy(tempFile.path);

    await logger.logBackupCreated();

    // ignore: deprecated_member_use
    await Share.shareXFiles(
      [XFile(tempFile.path)],
      text: 'نسخة احتياطية عزم — $dateStr',
    );
    return true;
  } catch (_) {
    return false;
  }
}

// ─────────────────────────────────────────────────────────────
// Restore
// ─────────────────────────────────────────────────────────────

/// الجداول التي تُدمَج من النسخة، وكلها تحمل `sync_id` تُميَّز به الصفوف.
///
/// جداول المستأجر والإعدادات والسجلّ الأمني مستثناة عمدًا: دمجها من نسخة
/// أقدم يعيد عضويات وأذونات وسجلات أمنية لا تخصّ الحالة الراهنة.
const _mergeableTables = <String>[
  'meetings',
  'follow_ups',
  'directives',
  'contacts',
  'appointments',
  'archive',
  'notes',
  'calls',
  'visitors',
  'movements',
  'routine_tasks',
  'routine_completions',
  'employees',
  'departments',
  'branches',
  'positions',
  'employee_contracts',
  'salary_records',
  'attendance_records',
  'leave_requests',
  'leave_balances',
  'employee_advances',
  'performance_evaluations',
  'training_records',
  'employee_assets',
  'rewards_penalties',
  'clients',
  'suppliers',
  'invoices',
  'expenses',
  'revenues',
  'chart_of_accounts',
  'journal_entries',
  'bank_accounts',
  'payment_vouchers',
  'checks',
  'projects',
  'entity_links',
];

/// يستعيد سجلات من ملف نسخة احتياطية بالدمج لا بالاستبدال.
///
/// الدمج يتم داخل SQLite عبر `ATTACH`، فتُنفَّذ كل عملية كاستعلام واحد
/// `INSERT ... SELECT` بدل تحميل الصفوف إلى الذاكرة صفًّا صفًّا. والصفوف
/// تُميَّز بـ`sync_id`: ما هو موجود لا يُكرَّر، وما ليس موجودًا يُضاف.
/// لا يُحدَّث صفّ قائم — الاستعادة تضيف ولا تكتب فوق عملٍ أحدث.
Future<RestoreResult> restoreNative(
  SecurityLogger logger,
  AppDatabase db,
) async {
  File? sourceFile;
  try {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );

    if (result == null || result.files.single.path == null) {
      return const RestoreResult.cancelled();
    }
    sourceFile = File(result.files.single.path!);

    if (!await sourceFile.exists()) {
      return const RestoreResult.failure('لم يُعثر على الملف المحدَّد.');
    }

    // ترويسة SQLite: ١٦ بايتًا ثابتة. الفحص يمنع محاولة إرفاق ملف
    // ليس قاعدة بيانات أصلًا، وهو أشيع خطأ عند اختيار ملف يدويًا.
    if (!await _looksLikeSqlite(sourceFile)) {
      return const RestoreResult.failure(
        'الملف المحدَّد ليس نسخة احتياطية صالحة.',
      );
    }
  } catch (e) {
    debugPrint('[Restore] file selection failed: $e');
    return const RestoreResult.failure('تعذّر قراءة الملف المحدَّد.');
  }

  final result = await mergeFromBackupFile(db, sourceFile.path);
  if (result.isSuccess) {
    await logger.logBackupRestored();
  }
  return result;
}

/// يدمج سجلات ملف نسخة احتياطية في القاعدة المفتوحة.
///
/// مفصولة عن [restoreNative] عمدًا: تلك تختار الملف عبر واجهة النظام
/// فيتعذّر اختبارها، وهذه منطق خالص يأخذ مسارًا ويعيد نتيجة — فهي
/// قابلة للاختبار، وهي الجزء الذي لا يجوز أن ينكسر صامتًا.
@visibleForTesting
Future<RestoreResult> mergeFromBackupFile(
  AppDatabase db,
  String backupPath,
) async {
  var attached = false;
  try {
    // ATTACH لا يعمل داخل معاملة، فيسبقها ويليه DETACH في finally.
    await db.customStatement('ATTACH DATABASE ? AS backup', [backupPath]);
    attached = true;

    var insertedRows = 0;
    var mergedTables = 0;
    final skipped = <String>[];

    await db.transaction(() async {
      for (final table in _mergeableTables) {
        final columns = await _sharedColumns(db, table);

        // الجدول غائب عن النسخة (مخطط أقدم) أو بلا أعمدة مشتركة
        if (columns.isEmpty) {
          skipped.add(table);
          continue;
        }

        final cols = columns.map((c) => '"$c"').join(', ');
        final inserted = await db.customUpdate(
          'INSERT INTO main."$table" ($cols) '
          'SELECT $cols FROM backup."$table" '
          'WHERE "sync_id" NOT IN (SELECT "sync_id" FROM main."$table")',
          updates: const {},
        );

        insertedRows += inserted;
        mergedTables++;
      }
    });

    return RestoreResult(
      status: RestoreStatus.success,
      insertedRows: insertedRows,
      mergedTables: mergedTables,
      skippedTables: skipped,
    );
  } catch (e) {
    debugPrint('[Restore] merge failed: $e');
    return const RestoreResult.failure(
      'تعذّر دمج النسخة. لم تُعدَّل بياناتك الحالية.',
    );
  } finally {
    if (attached) {
      try {
        await db.customStatement('DETACH DATABASE backup');
      } catch (e) {
        // فكّ الإرفاق قد يفشل إن أُغلقت المعاملة على خطأ — لا يُخفي
        // النتيجة الحقيقية للمستخدم.
        debugPrint('[Restore] detach failed: $e');
      }
    }
  }
}

/// الأعمدة المشتركة بين الجدول في القاعدة الحالية وفي النسخة، بلا `id`.
///
/// `id` مستثنى لأنه مفتاح تزايُدي: نقله يصطدم بصفوف قائمة. والتقاطع
/// يجعل الاستعادة تعمل عبر نسخ مخطط مختلفة — عمود أُضيف بعد النسخة
/// يُترك لقيمته الافتراضية بدل أن تفشل العملية كلها.
Future<List<String>> _sharedColumns(AppDatabase db, String table) async {
  try {
    final mainCols = await _columnsOf(db, 'main', table);
    if (mainCols.isEmpty) return const [];

    final backupCols = await _columnsOf(db, 'backup', table);
    if (backupCols.isEmpty) return const [];

    final shared = mainCols
        .where((c) => c != 'id' && backupCols.contains(c))
        .toList();

    // بلا `sync_id` لا سبيل لتمييز المكرَّر، فالدمج غير آمن
    if (!shared.contains('sync_id')) return const [];

    return shared;
  } catch (_) {
    return const [];
  }
}

Future<Set<String>> _columnsOf(
  AppDatabase db,
  String schema,
  String table,
) async {
  final rows = await db
      .customSelect('PRAGMA $schema.table_info("$table")')
      .get();
  return rows.map((r) => r.read<String>('name')).toSet();
}

/// كل ملف SQLite يبدأ بالسلسلة `SQLite format 3 `.
Future<bool> _looksLikeSqlite(File file) async {
  if (await file.length() < 512) return false;
  final header = await file.openRead(0, 16).first;
  const expected = 'SQLite format 3';
  if (header.length < expected.length) return false;
  for (var i = 0; i < expected.length; i++) {
    if (header[i] != expected.codeUnitAt(i)) return false;
  }
  return true;
}

/// Get local SQLite database file size.
Future<String> getDbSizeNative() async {
  try {
    final dbFolder = await getApplicationDocumentsDirectory();
    final dbFile = File(p.join(dbFolder.path, AppConstants.dbName));
    if (await dbFile.exists()) {
      final bytes = await dbFile.length();
      if (bytes < 1024) return '$bytes B';
      if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
      return '${(bytes / 1048576).toStringAsFixed(1)} MB';
    }
    return 'غير متوفر';
  } catch (_) {
    return 'خطأ';
  }
}
