import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/enums.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/dao/notes_dao.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/security/security_logger.dart';

/// Repository for Notes — Phase 4
class NotesRepository {
  final NotesDao _dao;
  final SecurityLogger _logger;
  final _uuid = const Uuid();

  NotesRepository(this._dao, this._logger);

  Future<void> createNote({
    String? title,
    required String content,
    String? colorCode,
    String? tags,
  }) async {
    final companion = NotesCompanion.insert(
      syncId: _uuid.v4(),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
      title: Value(title),
      content: content,
      colorCode: Value(colorCode),
      tags: Value(tags),
    );

    await _dao.insertNote(companion);
    await _logger.log(SecurityAction.settingsChanged, details: 'تم إنشاء ملاحظة جديدة: ${title ?? "بدون عنوان"}');
  }

  Future<bool> updateNote({
    required int id,
    String? title,
    required String content,
    String? colorCode,
    String? tags,
  }) async {
    final companion = NotesCompanion(
      title: Value(title),
      content: Value(content),
      colorCode: Value(colorCode),
      tags: Value(tags),
      updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
    );
    return await _dao.updateNote(companion, id);
  }

  Future<void> deleteNote(int id) async {
    await _dao.deleteNoteSoft(id);
    await _logger.logRecordDeleted('ملاحظة', id);
  }

  Stream<List<NoteItem>> watchAllNotes() => _dao.watchAllNotes();
}

final notesRepositoryProvider = Provider<NotesRepository>((ref) {
  final dao = ref.watch(notesDaoProvider);
  final db = ref.watch(databaseProvider);
  final logger = SecurityLogger(db.securityLogsDao);
  return NotesRepository(dao, logger);
});

final notesListProvider = StreamProvider<List<NoteItem>>((ref) {
  final repo = ref.watch(notesRepositoryProvider);
  return repo.watchAllNotes();
});