import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/directives_table.dart';

part 'directives_dao.g.dart';

/// Data Access Object for Directives
@DriftAccessor(tables: [Directives])
class DirectivesDao extends DatabaseAccessor<AppDatabase> with _$DirectivesDaoMixin {
  DirectivesDao(super.db);

  /// Watch all active directives
  Stream<List<Directive>> watchAllActive() => (select(directives)
        ..where((d) => d.isDeleted.equals(false))
        ..orderBy([
          (d) => OrderingTerm.asc(d.status),
          (d) => OrderingTerm.asc(d.priority),
        ]))
      .watch();

  /// Insert a new directive
  Future<int> insertDirective(DirectivesCompanion directive) => into(directives).insert(directive);

  /// Update status
  Future<void> updateStatus(int id, int status) =>
      (update(directives)..where((d) => d.id.equals(id))).write(
        DirectivesCompanion(
          status: Value(status),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Soft delete
  Future<void> softDelete(int id) =>
      (update(directives)..where((d) => d.id.equals(id))).write(
        DirectivesCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Get a single directive by ID
  Future<Directive?> getById(int id) =>
      (select(directives)..where((d) => d.id.equals(id))).getSingleOrNull();

  /// Update directive
  Future<bool> updateDirective(DirectivesCompanion directive, int id) =>
      (update(directives)..where((d) => d.id.equals(id)))
          .write(directive)
          .then((rows) => rows > 0);
}