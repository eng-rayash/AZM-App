import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/archive_table.dart';
import '../../utils/arabic_normalizer.dart';

part 'archive_dao.g.dart';

/// Data Access Object for Archive table
@DriftAccessor(tables: [Archive])
class ArchiveDao extends DatabaseAccessor<AppDatabase> with _$ArchiveDaoMixin {
  ArchiveDao(super.db);

  /// Watch all active archive records
  Stream<List<ArchiveData>> watchAllActive() => (select(archive)
        ..where((a) => a.isDeleted.equals(false))
        ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
      .watch();

  /// بحث في الأرشيف بالعنوان أو الرقم المرجعي أو الوسوم.
  ///
  /// المطابقة مطبَّعة — انظر [filterNormalized].
  Stream<List<ArchiveData>> searchArchive(String query) => (select(archive)
        ..where((a) => a.isDeleted.equals(false))
        ..orderBy([(a) => OrderingTerm.desc(a.createdAt)]))
      .watch()
      .map((rows) => filterNormalized(
            rows,
            query,
            (a) => [a.title, a.referenceNumber, a.tags],
          ));

  /// Get a single archive record by ID
  Future<ArchiveData?> getById(int id) =>
      (select(archive)..where((a) => a.id.equals(id))).getSingleOrNull();

  /// Insert document
  Future<int> insertDocument(ArchiveCompanion document) => into(archive).insert(document);

  /// Soft delete document
  Future<void> softDelete(int id) =>
      (update(archive)..where((a) => a.id.equals(id))).write(
        ArchiveCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Update document
  Future<bool> updateDocument(ArchiveCompanion document, int id) =>
      (update(archive)..where((a) => a.id.equals(id)))
          .write(document)
          .then((rows) => rows > 0);
}