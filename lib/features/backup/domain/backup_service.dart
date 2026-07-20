import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:drift/native.dart';
import 'package:drift/drift.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/security/security_logger.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/demo_data_seeder.dart';

/// Backup Service — handles encrypted database export and restore.
///
/// Export: Copies the live SQLite database to a timestamped backup file
///         and shares it via the system share sheet.
/// Restore: Picks a .sqlite file via file picker and merges the records
///          table-by-table using syncId to avoid data loss.
class BackupService {
  final SecurityLogger _logger;
  final AppDatabase _db;

  BackupService(this._logger, this._db);

  /// Export the current database as a shareable backup file.
  Future<bool> exportBackup() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final dbFile = File(p.join(dbFolder.path, AppConstants.dbName));

      if (!await dbFile.exists()) return false;

      final dateStr = DateFormat('yyyyMMdd_HHmm').format(DateTime.now());
      final backupFileName = 'mudiri_backup_$dateStr.sqlite';
      
      // Copy to temp dir for sharing
      final tempDir = await getTemporaryDirectory();
      final tempFile = File(p.join(tempDir.path, backupFileName));
      await dbFile.copy(tempFile.path);

      await _logger.logBackupCreated();

      // ignore: deprecated_member_use
      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'نسخة احتياطية لتطبيق مديري — $dateStr',
      );
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Restore database backup records using a smart merge approach.
  /// Matches on syncId to update newer records and insert missing ones.
  Future<bool> restoreBackup() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.any,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final sourceFile = File(result.files.single.path!);
        
        // Validate: file should exist and be non-empty
        if (!await sourceFile.exists()) return false;
        final fileSize = await sourceFile.length();
        if (fileSize < 1024) return false; // Too small to be a valid DB

        final backupDb = AppDatabase.forTesting(NativeDatabase(sourceFile));

        try {
          await _db.transaction(() async {
            // 1. Users
            final backupUsers = await backupDb.select(backupDb.users).get();
            for (final item in backupUsers) {
              final existing = await (_db.select(_db.users)..where((t) => t.syncId.equals(item.syncId))).getSingleOrNull();
              final companion = item.toCompanion(true).copyWith(id: const Value.absent());
              if (existing == null) {
                await _db.into(_db.users).insert(companion);
              } else if (item.updatedAt > existing.updatedAt) {
                await (_db.update(_db.users)..where((t) => t.syncId.equals(item.syncId))).write(companion);
              }
            }

            // 2. Meetings
            final backupMeetings = await backupDb.select(backupDb.meetings).get();
            for (final item in backupMeetings) {
              final existing = await (_db.select(_db.meetings)..where((t) => t.syncId.equals(item.syncId))).getSingleOrNull();
              final companion = item.toCompanion(true).copyWith(id: const Value.absent());
              if (existing == null) {
                await _db.into(_db.meetings).insert(companion);
              } else if (item.updatedAt > existing.updatedAt) {
                await (_db.update(_db.meetings)..where((t) => t.syncId.equals(item.syncId))).write(companion);
              }
            }

            // 3. Tasks
            final backupTasks = await backupDb.select(backupDb.tasks).get();
            for (final item in backupTasks) {
              final existing = await (_db.select(_db.tasks)..where((t) => t.syncId.equals(item.syncId))).getSingleOrNull();
              final companion = item.toCompanion(true).copyWith(id: const Value.absent());
              if (existing == null) {
                await _db.into(_db.tasks).insert(companion);
              } else if (item.updatedAt > existing.updatedAt) {
                await (_db.update(_db.tasks)..where((t) => t.syncId.equals(item.syncId))).write(companion);
              }
            }

            // 4. FollowUps
            final backupFollowUps = await backupDb.select(backupDb.followUps).get();
            for (final item in backupFollowUps) {
              final existing = await (_db.select(_db.followUps)..where((t) => t.syncId.equals(item.syncId))).getSingleOrNull();
              final companion = item.toCompanion(true).copyWith(id: const Value.absent());
              if (existing == null) {
                await _db.into(_db.followUps).insert(companion);
              } else if (item.updatedAt > existing.updatedAt) {
                await (_db.update(_db.followUps)..where((t) => t.syncId.equals(item.syncId))).write(companion);
              }
            }

            // 5. Directives
            final backupDirectives = await backupDb.select(backupDb.directives).get();
            for (final item in backupDirectives) {
              final existing = await (_db.select(_db.directives)..where((t) => t.syncId.equals(item.syncId))).getSingleOrNull();
              final companion = item.toCompanion(true).copyWith(id: const Value.absent());
              if (existing == null) {
                await _db.into(_db.directives).insert(companion);
              } else if (item.updatedAt > existing.updatedAt) {
                await (_db.update(_db.directives)..where((t) => t.syncId.equals(item.syncId))).write(companion);
              }
            }

            // 6. Contacts
            final backupContacts = await backupDb.select(backupDb.contacts).get();
            for (final item in backupContacts) {
              final existing = await (_db.select(_db.contacts)..where((t) => t.syncId.equals(item.syncId))).getSingleOrNull();
              final companion = item.toCompanion(true).copyWith(id: const Value.absent());
              if (existing == null) {
                await _db.into(_db.contacts).insert(companion);
              } else if (item.updatedAt > existing.updatedAt) {
                await (_db.update(_db.contacts)..where((t) => t.syncId.equals(item.syncId))).write(companion);
              }
            }

            // 7. Appointments
            final backupAppointments = await backupDb.select(backupDb.appointments).get();
            for (final item in backupAppointments) {
              final existing = await (_db.select(_db.appointments)..where((t) => t.syncId.equals(item.syncId))).getSingleOrNull();
              final companion = item.toCompanion(true).copyWith(id: const Value.absent());
              if (existing == null) {
                await _db.into(_db.appointments).insert(companion);
              } else if (item.updatedAt > existing.updatedAt) {
                await (_db.update(_db.appointments)..where((t) => t.syncId.equals(item.syncId))).write(companion);
              }
            }

            // 8. Archive
            final backupArchive = await backupDb.select(backupDb.archive).get();
            for (final item in backupArchive) {
              final existing = await (_db.select(_db.archive)..where((t) => t.syncId.equals(item.syncId))).getSingleOrNull();
              final companion = item.toCompanion(true).copyWith(id: const Value.absent());
              if (existing == null) {
                await _db.into(_db.archive).insert(companion);
              } else if (item.updatedAt > existing.updatedAt) {
                await (_db.update(_db.archive)..where((t) => t.syncId.equals(item.syncId))).write(companion);
              }
            }

            // 9. SecurityLogs
            final backupSecurityLogs = await backupDb.select(backupDb.securityLogs).get();
            for (final item in backupSecurityLogs) {
              final existing = await (_db.select(_db.securityLogs)..where((t) => t.syncId.equals(item.syncId))).getSingleOrNull();
              final companion = item.toCompanion(true).copyWith(id: const Value.absent());
              if (existing == null) {
                await _db.into(_db.securityLogs).insert(companion);
              } else if (item.updatedAt > existing.updatedAt) {
                await (_db.update(_db.securityLogs)..where((t) => t.syncId.equals(item.syncId))).write(companion);
              }
            }

            // 10. AppSettings
            final backupAppSettings = await backupDb.select(backupDb.appSettings).get();
            for (final item in backupAppSettings) {
              final existing = await (_db.select(_db.appSettings)..where((t) => t.syncId.equals(item.syncId))).getSingleOrNull();
              final companion = item.toCompanion(true).copyWith(id: const Value.absent());
              if (existing == null) {
                await _db.into(_db.appSettings).insert(companion);
              } else if (item.updatedAt > existing.updatedAt) {
                await (_db.update(_db.appSettings)..where((t) => t.syncId.equals(item.syncId))).write(companion);
              }
            }

            // 11. Calls
            final backupCalls = await backupDb.select(backupDb.calls).get();
            for (final item in backupCalls) {
              final existing = await (_db.select(_db.calls)..where((t) => t.syncId.equals(item.syncId))).getSingleOrNull();
              final companion = item.toCompanion(true).copyWith(id: const Value.absent());
              if (existing == null) {
                await _db.into(_db.calls).insert(companion);
              } else if (item.updatedAt > existing.updatedAt) {
                await (_db.update(_db.calls)..where((t) => t.syncId.equals(item.syncId))).write(companion);
              }
            }

            // 12. Visitors
            final backupVisitors = await backupDb.select(backupDb.visitors).get();
            for (final item in backupVisitors) {
              final existing = await (_db.select(_db.visitors)..where((t) => t.syncId.equals(item.syncId))).getSingleOrNull();
              final companion = item.toCompanion(true).copyWith(id: const Value.absent());
              if (existing == null) {
                await _db.into(_db.visitors).insert(companion);
              } else if (item.updatedAt > existing.updatedAt) {
                await (_db.update(_db.visitors)..where((t) => t.syncId.equals(item.syncId))).write(companion);
              }
            }

            // 13. Notes
            final backupNotes = await backupDb.select(backupDb.notes).get();
            for (final item in backupNotes) {
              final existing = await (_db.select(_db.notes)..where((t) => t.syncId.equals(item.syncId))).getSingleOrNull();
              final companion = item.toCompanion(true).copyWith(id: const Value.absent());
              if (existing == null) {
                await _db.into(_db.notes).insert(companion);
              } else if (item.updatedAt > existing.updatedAt) {
                await (_db.update(_db.notes)..where((t) => t.syncId.equals(item.syncId))).write(companion);
              }
            }

            // 14. Movements
            final backupMovements = await backupDb.select(backupDb.movements).get();
            for (final item in backupMovements) {
              final existing = await (_db.select(_db.movements)..where((t) => t.syncId.equals(item.syncId))).getSingleOrNull();
              final companion = item.toCompanion(true).copyWith(id: const Value.absent());
              if (existing == null) {
                await _db.into(_db.movements).insert(companion);
              } else if (item.updatedAt > existing.updatedAt) {
                await (_db.update(_db.movements)..where((t) => t.syncId.equals(item.syncId))).write(companion);
              }
            }

            // 15. Routine Tasks
            final backupRoutineTasks = await backupDb.select(backupDb.routineTasks).get();
            for (final item in backupRoutineTasks) {
              final existing = await (_db.select(_db.routineTasks)..where((t) => t.syncId.equals(item.syncId))).getSingleOrNull();
              final companion = item.toCompanion(true).copyWith(id: const Value.absent());
              if (existing == null) {
                await _db.into(_db.routineTasks).insert(companion);
              } else if (item.updatedAt > existing.updatedAt) {
                await (_db.update(_db.routineTasks)..where((t) => t.syncId.equals(item.syncId))).write(companion);
              }
            }

            // 16. Routine Completions
            final backupRoutineCompletions = await backupDb.select(backupDb.routineCompletions).get();
            for (final item in backupRoutineCompletions) {
              final existing = await (_db.select(_db.routineCompletions)..where((t) => t.syncId.equals(item.syncId))).getSingleOrNull();
              final companion = item.toCompanion(true).copyWith(id: const Value.absent());
              if (existing == null) {
                await _db.into(_db.routineCompletions).insert(companion);
              } else if (item.updatedAt > existing.updatedAt) {
                await (_db.update(_db.routineCompletions)..where((t) => t.syncId.equals(item.syncId))).write(companion);
              }
            }
          });
        } finally {
          await backupDb.close();
        }

        await _logger.logBackupRestored();
        return true;
      }
      
      return false;
    } catch (e) {
      return false;
    }
  }

  /// Load realistic executive demo data into database
  Future<bool> seedDemoData() async {
    final seeder = DemoDataSeeder(_db);
    final success = await seeder.seedDemoData();
    if (success) {
      await _logger.logBackupRestored();
    }
    return success;
  }

  /// Get backup file size info for display
  Future<String> getDbSizeInfo() async {
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
}

final backupServiceProvider = Provider<BackupService>((ref) {
  final db = ref.watch(databaseProvider);
  final logger = SecurityLogger(db.securityLogsDao);
  return BackupService(logger, db);
});
