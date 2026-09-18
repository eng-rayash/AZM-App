import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/providers/database_providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/demo_data_seeder.dart';
import '../../../core/constants/enums.dart';
import '../../../core/security/security_logger.dart';
import 'restore_result.dart';

// Native-only imports — accessed only on non-web platforms
import 'backup_service_native.dart'
    if (dart.library.html) 'backup_service_web.dart';

/// Backup Service — platform-aware backup and restore.
///
/// على الأجهزة: يصدّر ملف SQLite ويستعيد منه بالدمج على `sync_id`.
/// على الويب: غير مدعوم، ويقول ذلك صراحةً بدل ادّعاء النجاح.
class BackupService {
  final SecurityLogger _logger;
  final AppDatabase _db;

  BackupService(this._logger, this._db);

  /// يصدّر القاعدة الحالية كملف نسخة احتياطية ويعرض ورقة المشاركة.
  Future<bool> exportBackup() async {
    if (kIsWeb) return false;
    return exportNative(_logger, _db);
  }

  /// يستعيد سجلات من ملف نسخة احتياطية بالدمج.
  ///
  /// تُعيد [RestoreResult] لا `bool`: الفارق بين «تمّت ولم تُضف شيئًا»
  /// و«تمّت وأضافت ٤٢٠ سجلًّا» فارق يهمّ المستخدم، و`bool` يطمسه.
  Future<RestoreResult> restoreBackup() async {
    if (kIsWeb) {
      return const RestoreResult.failure(
        'النسخ الاحتياطي غير متاح في نسخة الويب. استخدم تطبيق الجوال.',
      );
    }
    return restoreNative(_logger, _db);
  }

  /// Load realistic executive demo data
  Future<bool> seedDemoData() async {
    final seeder = DemoDataSeeder(_db);
    final success = await seeder.seedDemoData();
    if (success) {
      await _logger.logBackupRestored();
    }
    return success;
  }

  /// يحذف كل بيانات التطبيق من القاعدة المحلية.
  ///
  /// يمرّ على [GeneratedDatabase.allTables] بدل قائمة مكتوبة يدويًا:
  /// النسخة السابقة كانت تعدّد ١٤ جدولًا من أصل ٤٨، فتترك الموظفين
  /// والرواتب والفواتير والمشاريع خلفها بينما تخبر المستخدم أن كل
  /// بياناته حُذفت. المرور على المخطط يجعل الجداول الجديدة مشمولةً
  /// تلقائيًا فلا تعود القائمة تتخلّف.
  ///
  /// يعيد عدد الجداول التي أُفرغت.
  Future<int> wipeAllData() async {
    var cleared = 0;
    await _db.transaction(() async {
      for (final table in _db.allTables) {
        await _db.delete(table).go();
        cleared++;
      }
    });
    await _logger.log(
      SecurityAction.deleteRecord,
      details: 'حذف شامل لبيانات التطبيق ($cleared جدولًا)',
    );
    return cleared;
  }

  /// Get backup file size info
  Future<String> getDbSizeInfo() async {
    if (kIsWeb) return 'غير متوفر على الويب';
    return getDbSizeNative();
  }
}

final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(databaseProvider);
  final logger = SecurityLogger(db.securityLogsDao);
  return BackupService(logger, db);
});
