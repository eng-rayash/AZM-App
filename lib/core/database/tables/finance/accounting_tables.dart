import 'package:drift/drift.dart';
import '../base_table.dart';
import '../tenant_scoped.dart';

/// Chart of Accounts table — دليل الحسابات.
class ChartOfAccounts extends Table with BaseTableMixin, TenantScoped {
  TextColumn get code => text().withLength(min: 1, max: 20)();
  TextColumn get name => text().withLength(min: 1, max: 150)();
  TextColumn get nameEn => text().nullable()();
  /// type: 0=asset (أصول), 1=liability (خصوم), 2=equity (حقوق ملكية),
  ///       3=revenue (إيرادات), 4=expense (مصروفات)
  IntColumn get type => integer()();
  IntColumn get parentId => integer().nullable()();
  TextColumn get parentName => text().nullable()(); // cached
  TextColumn get description => text().nullable()();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  BoolColumn get allowTransactions =>
      boolean().withDefault(const Constant(true))();
  RealColumn get openingBalance => real().withDefault(const Constant(0.0))();
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();
}

/// Journal Entries table — القيود اليومية.
class JournalEntries extends Table with BaseTableMixin, TenantScoped {
  TextColumn get entryNumber => text().nullable()();
  TextColumn get date => text()();
  TextColumn get description => text()();
  /// lines: JSON [{accountId, accountName, debit, credit, description}]
  TextColumn get lines => text()();
  RealColumn get totalDebit => real().withDefault(const Constant(0.0))();
  RealColumn get totalCredit => real().withDefault(const Constant(0.0))();
  /// type: 0=manual, 1=invoice, 2=payment, 3=salary, 4=expense, 5=revenue
  IntColumn get type => integer().withDefault(const Constant(0))();
  IntColumn get referenceId => integer().nullable()();
  TextColumn get referenceType => text().nullable()();
  /// status: 0=draft, 1=posted, 2=reversed
  IntColumn get status => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
}

/// Bank Accounts table — الحسابات البنكية.
class BankAccounts extends Table with BaseTableMixin, TenantScoped {
  TextColumn get bankName => text().withLength(min: 1, max: 100)();
  TextColumn get accountName => text().nullable()();
  TextColumn get accountNumber => text().nullable()();
  TextColumn get iban => text().nullable()();
  TextColumn get currency => text().withDefault(const Constant('SAR'))();
  TextColumn get branch => text().nullable()();
  RealColumn get openingBalance => real().withDefault(const Constant(0.0))();
  RealColumn get currentBalance => real().withDefault(const Constant(0.0))();
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
  TextColumn get notes => text().nullable()();
  TextColumn get logo => text().nullable()(); // file path
}

/// Payment Vouchers table — سندات القبض والصرف.
class PaymentVouchers extends Table with BaseTableMixin, TenantScoped {
  TextColumn get voucherNumber => text().nullable()();
  /// type: 0=receipt (سند قبض), 1=payment (سند صرف)
  IntColumn get type => integer()();
  TextColumn get date => text()();
  RealColumn get amount => real().withDefault(const Constant(0.0))();
  TextColumn get currency => text().withDefault(const Constant('SAR'))();
  /// partyType: 0=client, 1=supplier, 2=employee, 3=other
  IntColumn get partyType => integer().nullable()();
  IntColumn get partyId => integer().nullable()();
  TextColumn get partyName => text().nullable()();
  IntColumn get accountId => integer().nullable()();
  TextColumn get accountName => text().nullable()(); // cached
  IntColumn get bankAccountId => integer().nullable()();
  TextColumn get description => text().nullable()();
  TextColumn get reference => text().nullable()();
  TextColumn get attachments => text().nullable()(); // JSON
  /// paymentMethod: 0=cash, 1=bank-transfer, 2=check
  IntColumn get paymentMethod => integer().withDefault(const Constant(0))();
  /// status: 0=draft, 1=confirmed, 2=cancelled
  IntColumn get status => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
}

/// Checks table — الشيكات.
class Checks extends Table with BaseTableMixin, TenantScoped {
  TextColumn get checkNumber => text()();
  TextColumn get bankName => text().nullable()();
  RealColumn get amount => real().withDefault(const Constant(0.0))();
  TextColumn get currency => text().withDefault(const Constant('SAR'))();
  TextColumn get issueDate => text().nullable()();
  TextColumn get dueDate => text()();
  TextColumn get partyName => text().nullable()();
  IntColumn get partyId => integer().nullable()();
  /// type: 0=incoming (مستلم), 1=outgoing (مصدر)
  IntColumn get type => integer()();
  /// status: 0=pending, 1=deposited, 2=cleared, 3=bounced, 4=cancelled
  IntColumn get status => integer().withDefault(const Constant(0))();
  TextColumn get notes => text().nullable()();
  TextColumn get attachments => text().nullable()(); // JSON
}