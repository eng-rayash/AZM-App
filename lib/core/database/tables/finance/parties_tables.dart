import 'package:drift/drift.dart';
import '../base_table.dart';

/// Clients table — customers / clients for financial transactions.
///
/// Separate from Contacts (general contacts) — Clients are financial entities.
class Clients extends Table with BaseTableMixin {
  TextColumn get name => text().withLength(min: 1, max: 150)();
  TextColumn get nameEn => text().nullable()();
  TextColumn get code => text().nullable()();
  /// type: 0=individual, 1=company, 2=government, 3=ngo
  IntColumn get type => integer().withDefault(const Constant(1))();
  TextColumn get phone => text().nullable()();
  TextColumn get alternativePhone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get country => text().nullable()();
  TextColumn get taxNumber => text().nullable()();
  TextColumn get commercialRegister => text().nullable()();
  RealColumn get creditLimit => real().withDefault(const Constant(0.0))();
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();
  /// paymentTerms: e.g. "net30", "immediate"
  TextColumn get paymentTerms => text().nullable()();
  TextColumn get contactPersonName => text().nullable()();
  TextColumn get contactPersonPhone => text().nullable()();
  TextColumn get contactPersonEmail => text().nullable()();
  TextColumn get logo => text().nullable()(); // file path
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
  TextColumn get attachments => text().nullable()(); // JSON
  // Link to contacts table (optional)
  IntColumn get linkedContactId => integer().nullable()();
}

/// Suppliers table — vendors / suppliers.
class Suppliers extends Table with BaseTableMixin {
  TextColumn get name => text().withLength(min: 1, max: 150)();
  TextColumn get nameEn => text().nullable()();
  TextColumn get code => text().nullable()();
  /// type: 0=individual, 1=company
  IntColumn get type => integer().withDefault(const Constant(1))();
  TextColumn get phone => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get address => text().nullable()();
  TextColumn get city => text().nullable()();
  TextColumn get country => text().nullable()();
  TextColumn get taxNumber => text().nullable()();
  TextColumn get commercialRegister => text().nullable()();
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();
  TextColumn get paymentTerms => text().nullable()();
  TextColumn get contactPersonName => text().nullable()();
  TextColumn get contactPersonPhone => text().nullable()();
  TextColumn get iban => text().nullable()();
  TextColumn get bankName => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
  TextColumn get attachments => text().nullable()(); // JSON
  /// category: procurement, services, utilities, etc.
  TextColumn get category => text().nullable()();
}