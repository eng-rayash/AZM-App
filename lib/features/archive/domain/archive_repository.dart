import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/enums.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/security/security_logger.dart';

/// Repository for handling Archive logic.
class ArchiveRepository {
  ArchiveRepository(this._db, this._logger);

  final AppDatabase _db;
  final SecurityLogger _logger;
  static const _uuid = Uuid();

  /// Watch all active archive records
  Stream<List<ArchiveData>> watchAll() => _db.archiveDao.watchAllActive();

  /// Search archive
  Stream<List<ArchiveData>> search(String query) =>
      _db.archiveDao.searchArchive(query);

  /// Create a new archive record.
  ///
  /// The file (if any) is saved by the presentation layer via
  /// [FileStorageService] before calling this method.  The
  /// [localFilePath] passed here is the already-persisted path.
  ///
  /// Returns: Database record ID
  Future<int> createArchiveRecord({
    required String title,
    String? referenceNumber,
    String? documentDate,
    String? hijriDate,
    String? directedEntity,
    String? category,
    String? localFilePath,
    String? tags,
    String? notes,
    bool isConfidential = false,
  }) async {
    // localFilePath is already saved by the presentation layer via
    // FileStorageService — no need to re-copy it here.

    final now = DateTime.now().millisecondsSinceEpoch;

    final id = await _db.archiveDao.insertDocument(
      ArchiveCompanion.insert(
        syncId: _uuid.v4(),
        title: title,
        referenceNumber: drift.Value(referenceNumber),
        documentDate: drift.Value(documentDate),
        hijriDate: drift.Value(hijriDate),
        directedEntity: drift.Value(directedEntity),
        category: drift.Value(category),
        localFilePath: drift.Value(localFilePath),
        tags: drift.Value(tags),
        notes: drift.Value(notes),
        isConfidential: drift.Value(isConfidential),
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Log archive creation
    await _logger.log(
      SecurityAction.exportData,
      details: 'أرشفة وثيقة جديدة: $title',
    );

    return id;
  }

  /// Update an existing archive record.
  Future<bool> updateArchiveRecord({
    required int id,
    required String title,
    String? referenceNumber,
    String? documentDate,
    String? hijriDate,
    String? directedEntity,
    String? category,
    String? localFilePath,
    String? tags,
    String? notes,
    bool isConfidential = false,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final success = await _db.archiveDao.updateDocument(
      ArchiveCompanion(
        title: drift.Value(title),
        referenceNumber: drift.Value(referenceNumber),
        documentDate: drift.Value(documentDate),
        hijriDate: drift.Value(hijriDate),
        directedEntity: drift.Value(directedEntity),
        category: drift.Value(category),
        localFilePath: drift.Value(localFilePath),
        tags: drift.Value(tags),
        notes: drift.Value(notes),
        isConfidential: drift.Value(isConfidential),
        updatedAt: drift.Value(now),
      ),
      id,
    );

    if (success) {
      await _logger.log(
        SecurityAction.exportData,
        details: 'تعديل وثيقة مؤرشفة: $title',
      );
    }

    return success;
  }

  /// Record access to confidential document
  Future<void> logConfidentialAccess(String title) async {
    await _logger.log(
      SecurityAction.exportData,
      details: 'محاولة وصول لوثيقة سرية: $title',
    );
  }

  /// Delete (soft) an archive record.
  ///
  /// The physical file is intentionally NOT deleted to preserve
  /// data recoverability — consistent with the project's
  /// "Hard Delete forbidden" rule.
  Future<void> deleteRecord(int id) async {
    // Perform soft delete in database
    await _db.archiveDao.softDelete(id);
    await _logger.logRecordDeleted('وثيقة مؤرشفة', id);
  }
}

/// Provider for ArchiveRepository
final archiveRepositoryProvider = Provider<ArchiveRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final logger = SecurityLogger(db.securityLogsDao);
  return ArchiveRepository(db, logger);
});

/// Provider for archive stream
final archiveListProvider = StreamProvider<List<ArchiveData>>((ref) {
  return ref.watch(archiveRepositoryProvider).watchAll();
});