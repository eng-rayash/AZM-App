import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/contacts_table.dart';
import '../../utils/arabic_normalizer.dart';

part 'contacts_dao.g.dart';

/// Data Access Object for Contacts table.
@DriftAccessor(tables: [Contacts])
class ContactsDao extends DatabaseAccessor<AppDatabase> with _$ContactsDaoMixin {
  ContactsDao(super.db);

  /// Watch all active contacts
  Stream<List<Contact>> watchAllActive() => (select(contacts)
        ..where((c) => c.isDeleted.equals(false))
        ..orderBy([
          (c) => OrderingTerm.desc(c.isVip),
          (c) => OrderingTerm.asc(c.name),
        ]))
      .watch();

  /// بحث في جهات الاتصال بالاسم أو الشركة.
  ///
  /// المطابقة مطبَّعة — انظر [filterNormalized].
  Stream<List<Contact>> searchContacts(String query) => (select(contacts)
        ..where((c) => c.isDeleted.equals(false))
        ..orderBy([(c) => OrderingTerm.asc(c.name)]))
      .watch()
      .map((rows) => filterNormalized(
            rows,
            query,
            (c) => [c.name, c.company],
          ));

  /// Insert a new contact
  Future<int> insertContact(ContactsCompanion contact) => into(contacts).insert(contact);

  /// Update contact
  Future<bool> updateContact(ContactsCompanion contact, int id) =>
      (update(contacts)..where((c) => c.id.equals(id)))
          .write(contact)
          .then((rows) => rows > 0);

  /// Soft delete contact
  Future<void> softDelete(int id) =>
      (update(contacts)..where((c) => c.id.equals(id))).write(
        ContactsCompanion(
          isDeleted: const Value(true),
          updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
        ),
      );

  /// Get contact by id
  Future<Contact?> getById(int id) =>
      (select(contacts)..where((c) => c.id.equals(id))).getSingleOrNull();
}