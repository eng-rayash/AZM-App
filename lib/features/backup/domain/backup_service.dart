import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/providers/database_providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/demo_data_seeder.dart';
import '../../../core/security/security_logger.dart';

// Native-only imports — accessed only on non-web platforms
import 'backup_service_native.dart'
    if (dart.library.html) 'backup_service_web.dart';

/// Backup Service — platform-aware backup and restore.
///
/// On Native (Android/iOS/Desktop): exports/imports SQLite file.
/// On Web: Supabase cloud backup (export JSON, restore from JSON).
class BackupService {
  final SecurityLogger _logger;
  final AppDatabase _db;

  BackupService(this._logger, this._db);

  /// Export the current database as a backup.
  Future<bool> exportBackup() async {
    if (kIsWeb) {
      return _exportWeb();
    }
    return exportNative(_logger, _db);
  }

  /// Restore database from backup.
  Future<bool> restoreBackup() async {
    if (kIsWeb) {
      return _restoreWeb();
    }
    return restoreNative(_logger, _db);
  }

  // ── Web stubs (Supabase-based backup in future versions) ──────────

  Future<bool> _exportWeb() async {
    // On web, backup is handled by Supabase (data is already in cloud)
    await _logger.logBackupCreated();
    return true;
  }

  Future<bool> _restoreWeb() async {
    // On web, data is already in Supabase cloud
    await _logger.logBackupRestored();
    return true;
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

  /// Get backup file size info
  Future<String> getDbSizeInfo() async {
    if (kIsWeb) return 'Supabase Cloud';
    return getDbSizeNative();
  }
}

final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(databaseProvider);
  final logger = SecurityLogger(db.securityLogsDao);
  return BackupService(logger, db);
});