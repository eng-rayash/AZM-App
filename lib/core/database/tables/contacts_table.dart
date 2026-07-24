import 'package:drift/drift.dart';

import 'base_table.dart';

/// Contacts table — stores important contacts and executives.
class Contacts extends Table with BaseTableMixin {
  /// Full name
  TextColumn get name => text().withLength(min: 1, max: 150)();

  /// Position or job title
  TextColumn get position => text().nullable()();

  /// Company or organization
  TextColumn get company => text().nullable()();

  /// Primary phone number
  TextColumn get phoneNumber => text().nullable()();

  /// Email address
  TextColumn get email => text().nullable()();

  /// Is this a VIP contact?
  BoolColumn get isVip => boolean().withDefault(const Constant(false))();
  
  /// Notes about the contact
  TextColumn get notes => text().nullable()();
}