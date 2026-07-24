import 'package:drift/drift.dart';
import '../base_table.dart';

/// Invoices table — sales invoices issued to clients.
class Invoices extends Table with BaseTableMixin {
  TextColumn get invoiceNumber => text().nullable()();
  IntColumn get clientId => integer().nullable()();
  TextColumn get clientName => text().nullable()(); // cached
  IntColumn get projectId => integer().nullable()();
  TextColumn get projectName => text().nullable()(); // cached
  TextColumn get issueDate => text()();
  TextColumn get dueDate => text().nullable()();
  /// items: JSON [{description, quantity, unitPrice, discount, total}]
  TextColumn get items => text().nullable()();
  RealColumn get subtotal => real().withDefault(const Constant(0.0))();
  RealColumn get discountAmount => real().withDefault(const Constant(0.0))();
  RealColumn get discountPercent => real().withDefault(const Constant(0.0))();
  RealColumn get taxAmount => real().withDefault(const Constant(0.0))();
  RealColumn get taxPercent => real().withDefault(const Constant(0.0))();
  RealColumn get total => real().withDefault(const Constant(0.0))();
  RealColumn get paidAmount => real().withDefault(const Constant(0.0))();
  RealColumn get remainingAmount => real().withDefault(const Constant(0.0))();
  TextColumn get currency => text().withDefault(const Constant('SAR'))();
  /// status: 0=draft, 1=sent, 2=paid, 3=partial, 4=overdue, 5=cancelled
  IntColumn get status => integer().withDefault(const Constant(0))();
  TextColumn get paymentTerms => text().nullable()();
  TextColumn get notes => text().nullable()();
  TextColumn get footer => text().nullable()();
  TextColumn get attachments => text().nullable()(); // JSON
  TextColumn get pdfPath => text().nullable()();
}

/// Expenses table — company expenses.
class Expenses extends Table with BaseTableMixin {
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  RealColumn get amount => real().withDefault(const Constant(0.0))();
  TextColumn get currency => text().withDefault(const Constant('SAR'))();
  TextColumn get category => text().nullable()();
  TextColumn get date => text()();
  IntColumn get projectId => integer().nullable()();
  TextColumn get projectName => text().nullable()(); // cached
  IntColumn get employeeId => integer().nullable()();
  TextColumn get employeeName => text().nullable()(); // cached
  IntColumn get supplierId => integer().nullable()();
  TextColumn get supplierName => text().nullable()(); // cached
  TextColumn get costCenter => text().nullable()();
  /// paymentMethod: 0=cash, 1=bank-transfer, 2=credit-card, 3=check
  IntColumn get paymentMethod => integer().withDefault(const Constant(0))();
  TextColumn get referenceNumber => text().nullable()();
  IntColumn get accountId => integer().nullable()();
  TextColumn get attachments => text().nullable()(); // JSON
  /// status: 0=pending, 1=approved, 2=rejected, 3=paid
  IntColumn get status => integer().withDefault(const Constant(0))();
  BoolColumn get isRecurring => boolean().withDefault(const Constant(false))();
  TextColumn get recurringRule => text().nullable()();
  TextColumn get notes => text().nullable()();
}

/// Revenues table — income records.
class Revenues extends Table with BaseTableMixin {
  TextColumn get title => text().withLength(min: 1, max: 200)();
  TextColumn get description => text().nullable()();
  RealColumn get amount => real().withDefault(const Constant(0.0))();
  TextColumn get currency => text().withDefault(const Constant('SAR'))();
  TextColumn get category => text().nullable()();
  TextColumn get date => text()();
  IntColumn get clientId => integer().nullable()();
  TextColumn get clientName => text().nullable()(); // cached
  IntColumn get projectId => integer().nullable()();
  TextColumn get projectName => text().nullable()(); // cached
  IntColumn get invoiceId => integer().nullable()();
  TextColumn get invoiceNumber => text().nullable()(); // cached
  /// paymentMethod: 0=cash, 1=bank-transfer, 2=credit-card, 3=check
  IntColumn get paymentMethod => integer().withDefault(const Constant(0))();
  TextColumn get referenceNumber => text().nullable()();
  IntColumn get accountId => integer().nullable()();
  TextColumn get attachments => text().nullable()(); // JSON
  TextColumn get notes => text().nullable()();
}