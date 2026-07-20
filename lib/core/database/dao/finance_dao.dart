import 'package:drift/drift.dart';
import '../app_database.dart';
import '../tables/finance/parties_tables.dart';
import '../tables/finance/transactions_tables.dart';
import '../tables/finance/accounting_tables.dart';
import '../tables/projects_table.dart';
import '../tables/entity_links_table.dart';

part 'finance_dao.g.dart';

/// Finance DAO — Clients, Suppliers, Invoices, Expenses, Revenues,
/// ChartOfAccounts, JournalEntries, BankAccounts, PaymentVouchers,
/// Checks, Projects, EntityLinks.
@DriftAccessor(tables: [
  Clients,
  Suppliers,
  Invoices,
  Expenses,
  Revenues,
  ChartOfAccounts,
  JournalEntries,
  BankAccounts,
  PaymentVouchers,
  Checks,
  Projects,
  EntityLinks,
])
class FinanceDao extends DatabaseAccessor<AppDatabase> with _$FinanceDaoMixin {
  FinanceDao(super.db);

  // ── Clients ──────────────────────────────────────────────────────
  Stream<List<Client>> watchClients() =>
      (select(clients)
            ..where((c) => c.isActive.equals(true))
            ..orderBy([(c) => OrderingTerm.asc(c.name)]))
          .watch();

  Future<List<Client>> searchClients(String query) =>
      (select(clients)
            ..where(
              (c) =>
                  c.name.like('%$query%') |
                  c.phone.like('%$query%') |
                  c.email.like('%$query%'),
            ))
          .get();

  Future<Client?> getClientById(int id) =>
      (select(clients)..where((c) => c.id.equals(id))).getSingleOrNull();

  Future<int> insertClient(ClientsCompanion entry) =>
      into(clients).insert(entry);

  Future<bool> updateClient(ClientsCompanion entry) =>
      update(clients).replace(entry);

  Future<int> deleteClient(int id) =>
      (delete(clients)..where((c) => c.id.equals(id))).go();

  // ── Suppliers ────────────────────────────────────────────────────
  Stream<List<Supplier>> watchSuppliers() =>
      (select(suppliers)
            ..where((s) => s.isActive.equals(true))
            ..orderBy([(s) => OrderingTerm.asc(s.name)]))
          .watch();

  Future<int> insertSupplier(SuppliersCompanion entry) =>
      into(suppliers).insert(entry);

  Future<bool> updateSupplier(SuppliersCompanion entry) =>
      update(suppliers).replace(entry);

  // ── Invoices ─────────────────────────────────────────────────────
  Stream<List<Invoice>> watchInvoices() =>
      (select(invoices)..orderBy([(i) => OrderingTerm.desc(i.issueDate)]))
          .watch();

  Stream<List<Invoice>> watchInvoicesByClient(int clientId) =>
      (select(invoices)
            ..where((i) => i.clientId.equals(clientId))
            ..orderBy([(i) => OrderingTerm.desc(i.issueDate)]))
          .watch();

  Stream<List<Invoice>> watchOverdueInvoices() =>
      (select(invoices)
            ..where((i) => i.status.equals(4)) // overdue
            ..orderBy([(i) => OrderingTerm.asc(i.dueDate)]))
          .watch();

  Future<int> insertInvoice(InvoicesCompanion entry) =>
      into(invoices).insert(entry);

  Future<bool> updateInvoice(InvoicesCompanion entry) =>
      update(invoices).replace(entry);

  // ── Expenses ─────────────────────────────────────────────────────
  Stream<List<Expense>> watchExpenses() =>
      (select(expenses)..orderBy([(e) => OrderingTerm.desc(e.date)])).watch();

  Stream<List<Expense>> watchExpensesByProject(int projectId) =>
      (select(expenses)
            ..where((e) => e.projectId.equals(projectId))
            ..orderBy([(e) => OrderingTerm.desc(e.date)]))
          .watch();

  Future<double> sumExpensesByDateRange(String from, String to) async {
    final sum = expenses.amount.sum();
    final query = selectOnly(expenses)
      ..addColumns([sum])
      ..where(expenses.date.isBetweenValues(from, to));
    final result = await query.getSingle();
    return result.read(sum) ?? 0.0;
  }

  Future<int> insertExpense(ExpensesCompanion entry) =>
      into(expenses).insert(entry);

  Future<bool> updateExpense(ExpensesCompanion entry) =>
      update(expenses).replace(entry);

  // ── Revenues ─────────────────────────────────────────────────────
  Stream<List<Revenue>> watchRevenues() =>
      (select(revenues)..orderBy([(r) => OrderingTerm.desc(r.date)])).watch();

  Future<double> sumRevenuesByDateRange(String from, String to) async {
    final sum = revenues.amount.sum();
    final query = selectOnly(revenues)
      ..addColumns([sum])
      ..where(revenues.date.isBetweenValues(from, to));
    final result = await query.getSingle();
    return result.read(sum) ?? 0.0;
  }

  Future<int> insertRevenue(RevenuesCompanion entry) =>
      into(revenues).insert(entry);

  Future<bool> updateRevenue(RevenuesCompanion entry) =>
      update(revenues).replace(entry);

  // ── Chart of Accounts ────────────────────────────────────────────────────
  Stream<List<ChartOfAccount>> watchAccounts() =>
      (attachedDatabase.select(attachedDatabase.chartOfAccounts)
            ..where((a) => a.isActive.equals(true))
            ..orderBy([(a) => OrderingTerm.asc(a.code)]))
          .watch();

  Future<List<ChartOfAccount>> getAccountsByType(int type) =>
      (attachedDatabase.select(attachedDatabase.chartOfAccounts)
            ..where((a) => a.type.equals(type) & a.isActive.equals(true))
            ..orderBy([(a) => OrderingTerm.asc(a.code)]))
          .get();

  Future<int> insertAccount(ChartOfAccountsCompanion entry) =>
      attachedDatabase.into(attachedDatabase.chartOfAccounts).insert(entry);

  Future<bool> updateAccount(ChartOfAccountsCompanion entry) =>
      attachedDatabase.update(attachedDatabase.chartOfAccounts).replace(entry);

  // ── Journal Entries ────────────────────────────────────────────────────
  Stream<List<JournalEntry>> watchJournalEntries() =>
      (attachedDatabase.select(attachedDatabase.journalEntries)
            ..orderBy([(j) => OrderingTerm.desc(j.date)]))
          .watch();

  Future<int> insertJournalEntry(JournalEntriesCompanion entry) =>
      attachedDatabase.into(attachedDatabase.journalEntries).insert(entry);

  // ── Bank Accounts ────────────────────────────────────────────────────
  Stream<List<BankAccount>> watchBankAccounts() =>
      (attachedDatabase.select(attachedDatabase.bankAccounts)
            ..where((b) => b.isActive.equals(true))
            ..orderBy([(b) => OrderingTerm.asc(b.bankName)]))
          .watch();

  Future<int> insertBankAccount(BankAccountsCompanion entry) =>
      attachedDatabase.into(attachedDatabase.bankAccounts).insert(entry);

  Future<bool> updateBankAccount(BankAccountsCompanion entry) =>
      attachedDatabase.update(attachedDatabase.bankAccounts).replace(entry);

  // ── Payment Vouchers ───────────────────────────────────────────────────
  Stream<List<PaymentVoucher>> watchVouchers() =>
      (attachedDatabase.select(attachedDatabase.paymentVouchers)
            ..orderBy([(v) => OrderingTerm.desc(v.date)]))
          .watch();

  Future<int> insertVoucher(PaymentVouchersCompanion entry) =>
      attachedDatabase.into(attachedDatabase.paymentVouchers).insert(entry);

  // ── Checks ────────────────────────────────────────────────────────
  Stream<List<Check>> watchChecks() =>
      (attachedDatabase.select(attachedDatabase.checks)
            ..orderBy([(c) => OrderingTerm.asc(c.dueDate)]))
          .watch();

  Stream<List<Check>> watchPendingChecks() =>
      (attachedDatabase.select(attachedDatabase.checks)
            ..where((c) => c.status.equals(0))
            ..orderBy([(c) => OrderingTerm.asc(c.dueDate)]))
          .watch();

  Future<int> insertCheck(ChecksCompanion entry) =>
      attachedDatabase.into(attachedDatabase.checks).insert(entry);

  // ── Projects ─────────────────────────────────────────────────────
  Stream<List<Project>> watchProjects() =>
      (select(projects)..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
          .watch();

  Stream<List<Project>> watchActiveProjects() =>
      (select(projects)
            ..where((p) => p.status.equals(1)) // active
            ..orderBy([(p) => OrderingTerm.asc(p.name)]))
          .watch();

  Stream<List<Project>> watchProjectsByClient(int clientId) =>
      (select(projects)
            ..where((p) => p.clientId.equals(clientId))
            ..orderBy([(p) => OrderingTerm.desc(p.createdAt)]))
          .watch();

  Future<Project?> getProjectById(int id) =>
      (select(projects)..where((p) => p.id.equals(id))).getSingleOrNull();

  Future<int> insertProject(ProjectsCompanion entry) =>
      into(projects).insert(entry);

  Future<bool> updateProject(ProjectsCompanion entry) =>
      update(projects).replace(entry);

  Future<int> deleteProject(int id) =>
      (delete(projects)..where((p) => p.id.equals(id))).go();

  // ── Entity Links ────────────────────────────────────────────────────
  /// Get all links for a given source entity.
  Future<List<EntityLink>> getLinksForEntity(
    int sourceType,
    int sourceId,
  ) =>
      (attachedDatabase.select(attachedDatabase.entityLinks)
            ..where(
              (l) =>
                  l.sourceType.equals(sourceType) &
                  l.sourceId.equals(sourceId),
            ))
          .get();

  /// Get all links TO a given target entity.
  Future<List<EntityLink>> getLinksToEntity(
    int targetType,
    int targetId,
  ) =>
      (attachedDatabase.select(attachedDatabase.entityLinks)
            ..where(
              (l) =>
                  l.targetType.equals(targetType) &
                  l.targetId.equals(targetId),
            ))
          .get();

  Future<int> insertLink(EntityLinksCompanion entry) =>
      attachedDatabase.into(attachedDatabase.entityLinks).insert(entry);

  Future<int> deleteLink(int id) =>
      (attachedDatabase.delete(attachedDatabase.entityLinks)..where((l) => l.id.equals(id))).go();

  // ── Finance Summary (for Dashboard) ─────────────────────────────
  Future<Map<String, double>> getFinanceSummary(String from, String to) async {
    final totalRevenue = await sumRevenuesByDateRange(from, to);
    final totalExpenses = await sumExpensesByDateRange(from, to);
    return {
      'revenue': totalRevenue,
      'expenses': totalExpenses,
      'profit': totalRevenue - totalExpenses,
    };
  }
}
