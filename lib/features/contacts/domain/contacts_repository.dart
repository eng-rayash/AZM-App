import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/constants/enums.dart';
import '../../../core/database/app_database.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/security/security_logger.dart';

/// Repository for handling Contacts logic.
class ContactsRepository {
  ContactsRepository(this._db, this._logger);

  final AppDatabase _db;
  final SecurityLogger _logger;
  static const _uuid = Uuid();

  /// Watch all active contacts
  Stream<List<Contact>> watchAll() => _db.contactsDao.watchAllActive();

  /// Search contacts
  Stream<List<Contact>> search(String query) => _db.contactsDao.searchContacts(query);

  /// Create a new contact
  Future<int> createContact({
    required String name,
    String? position,
    String? company,
    String? phoneNumber,
    String? email,
    bool isVip = false,
    String? notes,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final id = await _db.contactsDao.insertContact(
      ContactsCompanion.insert(
        syncId: _uuid.v4(),
        name: name,
        position: drift.Value(position),
        company: drift.Value(company),
        phoneNumber: drift.Value(phoneNumber),
        email: drift.Value(email),
        isVip: drift.Value(isVip),
        notes: drift.Value(notes),
        createdAt: now,
        updatedAt: now,
      ),
    );

    // Only log VIP contact creation for privacy/security
    if (isVip) {
      await _logger.log(SecurityAction.settingsChanged, details: 'إضافة جهة اتصال VIP: $name');
    }
    
    return id;
  }

  /// Update contact
  Future<bool> updateContact({
    required int id,
    required String name,
    String? position,
    String? company,
    String? phoneNumber,
    String? email,
    bool isVip = false,
    String? notes,
  }) async {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    final success = await _db.contactsDao.updateContact(
      ContactsCompanion(
        name: drift.Value(name),
        position: drift.Value(position),
        company: drift.Value(company),
        phoneNumber: drift.Value(phoneNumber),
        email: drift.Value(email),
        isVip: drift.Value(isVip),
        notes: drift.Value(notes),
        updatedAt: drift.Value(now),
      ),
      id,
    );

    if (success && isVip) {
      await _logger.log(SecurityAction.settingsChanged, details: 'تعديل جهة اتصال VIP: $name');
    }

    return success;
  }

  /// Delete (soft)
  Future<void> deleteContact(int id) async {
    await _db.contactsDao.softDelete(id);
    await _logger.logRecordDeleted('جهة اتصال', id);
  }

  /// Get contact by ID
  Future<Contact?> getById(int id) => _db.contactsDao.getById(id);
}

/// Provider for ContactsRepository
final contactsRepositoryProvider = Provider<ContactsRepository>((ref) {
  final db = ref.watch(databaseProvider);
  final logger = SecurityLogger(db.securityLogsDao);
  return ContactsRepository(db, logger);
});

/// Provider for contacts stream
final contactsListProvider = StreamProvider<List<Contact>>((ref) {
  return ref.watch(contactsRepositoryProvider).watchAll();
});