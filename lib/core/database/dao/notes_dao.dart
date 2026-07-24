import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/notes_table.dart';

part 'notes_dao.g.dart';

@DriftAccessor(tables: [Notes])
class NotesDao extends DatabaseAccessor<AppDatabase> with _$NotesDaoMixin {
  NotesDao(super.db);

  Future<int> insertNote(NotesCompanion note) => into(notes).insert(note);
  Future<bool> deleteNoteSoft(int id) async {
    final result = await (update(notes)..where((t) => t.id.equals(id))).write(
        NotesCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );
    return result > 0;
  }
  Stream<List<NoteItem>> watchAllNotes() =>
      (select(notes)..where((t) => t.isDeleted.equals(false))
          ..orderBy([(t) => OrderingTerm(expression: t.createdAt, mode: OrderingMode.desc)]))
          .watch();

  Future<bool> updateNote(NotesCompanion note, int id) =>
      (update(notes)..where((t) => t.id.equals(id)))
          .write(note)
          .then((rows) => rows > 0);
}