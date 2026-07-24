import 'package:drift/drift.dart' as drift;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/providers/database_providers.dart';
import '../../../core/constants/app_currencies.dart';

/// Finance Repository — all financial business logic.
class FinanceRepository {
  FinanceRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  // ── Clients ────────────────────────────────────────────────────

  Stream<List<Client>> watchClients() => _db.financeDao.watchClients();

  Future<List<Client>> searchClients(String q) =>
      _db.financeDao.searchClients(q);

  Future<Client?> getClientById(int id) =>
      _db.financeDao.getClientById(id);

  Future<int> createClient({
    required String name,
    String? nameEn,
    String? code,
    int type = 1,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? country,
    String? taxNumber,
    double? creditLimit,
    String? paymentTerms,
    String? contactPersonName,
    String? contactPersonPhone,
    String? notes,
    int? linkedContactId,
  }) =>
      _db.financeDao.insertClient(
        ClientsCompanion.insert(
          syncId: _uuid.v4(),
          name: name,
          nameEn: drift.Value(nameEn),
          code: drift.Value(code),
          type: drift.Value(type),
          phone: drift.Value(phone),
          email: drift.Value(email),
          address: drift.Value(address),
          city: drift.Value(city),
          country: drift.Value(country),
          taxNumber: drift.Value(taxNumber),
          creditLimit: drift.Value(creditLimit ?? 0),
          currentBalance: const drift.Value(0),
          paymentTerms: drift.Value(paymentTerms),
          contactPersonName: drift.Value(contactPersonName),
          contactPersonPhone: drift.Value(contactPersonPhone),
          isActive: const drift.Value(true),
          notes: drift.Value(notes),
          linkedContactId: drift.Value(linkedContactId),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  Future<bool> updateClient(ClientsCompanion entry) =>
      _db.financeDao.updateClient(entry);

  Future<int> deleteClient(int id) => _db.financeDao.deleteClient(id);

  // ── Suppliers ──────────────────────────────────────────────────

  Stream<List<Supplier>> watchSuppliers() => _db.financeDao.watchSuppliers();

  Future<int> createSupplier({
    required String name,
    String? phone,
    String? email,
    String? address,
    String? city,
    String? country,
    String? taxNumber,
    String? contactPersonName,
    String? iban,
    String? bankName,
    String? category,
    String? notes,
  }) =>
      _db.financeDao.insertSupplier(
        SuppliersCompanion.insert(
          syncId: _uuid.v4(),
          name: name,
          phone: drift.Value(phone),
          email: drift.Value(email),
          address: drift.Value(address),
          city: drift.Value(city),
          country: drift.Value(country),
          taxNumber: drift.Value(taxNumber),
          currentBalance: const drift.Value(0),
          contactPersonName: drift.Value(contactPersonName),
          iban: drift.Value(iban),
          bankName: drift.Value(bankName),
          category: drift.Value(category),
          isActive: const drift.Value(true),
          notes: drift.Value(notes),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  // ── Invoices ───────────────────────────────────────────────────

  Stream<List<Invoice>> watchInvoices() => _db.financeDao.watchInvoices();

  Stream<List<Invoice>> watchInvoicesByClient(int clientId) =>
      _db.financeDao.watchInvoicesByClient(clientId);

  Stream<List<Invoice>> watchOverdueInvoices() =>
      _db.financeDao.watchOverdueInvoices();

  Future<int> createInvoice({
    required String invoiceNumber,
    int? clientId,
    String? clientName,
    int? projectId,
    String? projectName,
    required String issueDate,
    String? dueDate,
    String? itemsJson,
    double subtotal = 0,
    double discountAmount = 0,
    double taxPercent = 0,
    double taxAmount = 0,
    double total = 0,
    String currency = AppCurrencies.sar,
    String? paymentTerms,
    String? notes,
    String? footer,
  }) =>
      _db.financeDao.insertInvoice(
        InvoicesCompanion.insert(
          syncId: _uuid.v4(),
          invoiceNumber: drift.Value(invoiceNumber),
          clientId: drift.Value(clientId),
          clientName: drift.Value(clientName),
          projectId: drift.Value(projectId),
          projectName: drift.Value(projectName),
          issueDate: issueDate,
          dueDate: drift.Value(dueDate),
          items: drift.Value(itemsJson),
          subtotal: drift.Value(subtotal),
          discountAmount: drift.Value(discountAmount),
          taxAmount: drift.Value(taxAmount),
          taxPercent: drift.Value(taxPercent),
          total: drift.Value(total),
          paidAmount: const drift.Value(0),
          remainingAmount: drift.Value(total),
          currency: drift.Value(currency),
          status: const drift.Value(0), // draft
          paymentTerms: drift.Value(paymentTerms),
          notes: drift.Value(notes),
          footer: drift.Value(footer),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  Future<bool> updateInvoice(InvoicesCompanion entry) =>
      _db.financeDao.updateInvoice(entry);

  // ── Expenses ───────────────────────────────────────────────────

  Stream<List<Expense>> watchExpenses() => _db.financeDao.watchExpenses();

  Stream<List<Expense>> watchExpensesByProject(int projectId) =>
      _db.financeDao.watchExpensesByProject(projectId);

  Future<int> createExpense({
    required String title,
    String? description,
    required double amount,
    String currency = AppCurrencies.sar,
    String? category,
    required String date,
    int? projectId,
    String? projectName,
    int? employeeId,
    String? employeeName,
    int? supplierId,
    String? supplierName,
    int paymentMethod = 0,
    String? referenceNumber,
    String? notes,
  }) =>
      _db.financeDao.insertExpense(
        ExpensesCompanion.insert(
          syncId: _uuid.v4(),
          title: title,
          description: drift.Value(description),
          amount: drift.Value(amount),
          currency: drift.Value(currency),
          category: drift.Value(category),
          date: date,
          projectId: drift.Value(projectId),
          projectName: drift.Value(projectName),
          employeeId: drift.Value(employeeId),
          employeeName: drift.Value(employeeName),
          supplierId: drift.Value(supplierId),
          supplierName: drift.Value(supplierName),
          paymentMethod: drift.Value(paymentMethod),
          referenceNumber: drift.Value(referenceNumber),
          status: const drift.Value(0),
          isRecurring: const drift.Value(false),
          notes: drift.Value(notes),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  // ── Revenues ───────────────────────────────────────────────────

  Stream<List<Revenue>> watchRevenues() => _db.financeDao.watchRevenues();

  Future<int> createRevenue({
    required String title,
    String? description,
    required double amount,
    String currency = AppCurrencies.sar,
    String? category,
    required String date,
    int? clientId,
    String? clientName,
    int? projectId,
    String? projectName,
    int? invoiceId,
    String? invoiceNumber,
    int paymentMethod = 0,
    String? referenceNumber,
    String? notes,
  }) =>
      _db.financeDao.insertRevenue(
        RevenuesCompanion.insert(
          syncId: _uuid.v4(),
          title: title,
          description: drift.Value(description),
          amount: drift.Value(amount),
          currency: drift.Value(currency),
          category: drift.Value(category),
          date: date,
          clientId: drift.Value(clientId),
          clientName: drift.Value(clientName),
          projectId: drift.Value(projectId),
          projectName: drift.Value(projectName),
          invoiceId: drift.Value(invoiceId),
          invoiceNumber: drift.Value(invoiceNumber),
          paymentMethod: drift.Value(paymentMethod),
          referenceNumber: drift.Value(referenceNumber),
          notes: drift.Value(notes),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  // ── Projects ───────────────────────────────────────────────────

  Stream<List<Project>> watchProjects() => _db.financeDao.watchProjects();

  Stream<List<Project>> watchActiveProjects() =>
      _db.financeDao.watchActiveProjects();

  Future<Project?> getProjectById(int id) =>
      _db.financeDao.getProjectById(id);

  Future<int> createProject({
    required String name,
    String? description,
    String? code,
    int? clientId,
    String? clientName,
    String? startDate,
    String? endDate,
    double budget = 0,
    double contractValue = 0,
    String currency = AppCurrencies.sar,
    int status = 0,
    int progress = 0,
    int? managerId,
    String? managerName,
    String? category,
    int priority = 2,
    String? notes,
    String? location,
    String? tags,
  }) =>
      _db.financeDao.insertProject(
        ProjectsCompanion.insert(
          syncId: _uuid.v4(),
          name: name,
          description: drift.Value(description),
          code: drift.Value(code),
          clientId: drift.Value(clientId),
          clientName: drift.Value(clientName),
          startDate: drift.Value(startDate),
          endDate: drift.Value(endDate),
          budget: drift.Value(budget),
          actualCost: const drift.Value(0),
          contractValue: drift.Value(contractValue),
          currency: drift.Value(currency),
          status: drift.Value(status),
          progress: drift.Value(progress),
          managerId: drift.Value(managerId),
          managerName: drift.Value(managerName),
          category: drift.Value(category),
          priority: drift.Value(priority),
          notes: drift.Value(notes),
          location: drift.Value(location),
          tags: drift.Value(tags),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  Future<bool> updateProject(ProjectsCompanion entry) =>
      _db.financeDao.updateProject(entry);

  // ── Bank Accounts ──────────────────────────────────────────────

  Stream<List<BankAccount>> watchBankAccounts() =>
      _db.financeDao.watchBankAccounts();

  Future<int> createBankAccount({
    required String bankName,
    String? accountName,
    String? accountNumber,
    String? iban,
    String currency = AppCurrencies.sar,
    double openingBalance = 0,
    String? notes,
  }) =>
      _db.financeDao.insertBankAccount(
        BankAccountsCompanion.insert(
          syncId: _uuid.v4(),
          bankName: bankName,
          accountName: drift.Value(accountName),
          accountNumber: drift.Value(accountNumber),
          iban: drift.Value(iban),
          currency: drift.Value(currency),
          openingBalance: drift.Value(openingBalance),
          currentBalance: drift.Value(openingBalance),
          isActive: const drift.Value(true),
          notes: drift.Value(notes),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  // ── Checks ─────────────────────────────────────────────────────

  Stream<List<Check>> watchChecks() => _db.financeDao.watchChecks();

  Stream<List<Check>> watchPendingChecks() =>
      _db.financeDao.watchPendingChecks();

  Future<int> createCheck({
    required String checkNumber,
    String? bankName,
    required double amount,
    String currency = AppCurrencies.sar,
    String? issueDate,
    required String dueDate,
    String? partyName,
    int? partyId,
    required int type,
    String? notes,
  }) =>
      _db.financeDao.insertCheck(
        ChecksCompanion.insert(
          syncId: _uuid.v4(),
          checkNumber: checkNumber,
          bankName: drift.Value(bankName),
          amount: drift.Value(amount),
          currency: drift.Value(currency),
          issueDate: drift.Value(issueDate),
          dueDate: dueDate,
          partyName: drift.Value(partyName),
          partyId: drift.Value(partyId),
          type: type,
          status: const drift.Value(0),
          notes: drift.Value(notes),
          createdAt: DateTime.now().millisecondsSinceEpoch,
          updatedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

  // ── Finance Summary ────────────────────────────────────────────

  Future<FinanceSummary> getSummaryForCurrentMonth() async {
    final now = DateTime.now();
    final from =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-01';
    final to = '${now.year}-${now.month.toString().padLeft(2, '0')}'
        '-${DateTime(now.year, now.month + 1, 0).day}';
    final map = await _db.financeDao.getFinanceSummary(from, to);
    return FinanceSummary(
      totalRevenue: map['revenue'] ?? 0,
      totalExpenses: map['expenses'] ?? 0,
      netProfit: map['profit'] ?? 0,
    );
  }

  Future<int> countActiveProjects() async {
    final list = await _db.financeDao.watchActiveProjects().first;
    return list.length;
  }

  Future<int> countOverdueInvoices() async {
    final list = await _db.financeDao.watchOverdueInvoices().first;
    return list.length;
  }
}

class FinanceSummary {
  const FinanceSummary({
    required this.totalRevenue,
    required this.totalExpenses,
    required this.netProfit,
  });
  final double totalRevenue;
  final double totalExpenses;
  final double netProfit;
}

// ── Providers ──────────────────────────────────────────────────────

final financeRepositoryProvider = Provider<FinanceRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return FinanceRepository(db);
});

final clientsListProvider = StreamProvider<List<Client>>((ref) =>
    ref.watch(financeRepositoryProvider).watchClients());

final suppliersListProvider = StreamProvider<List<Supplier>>((ref) =>
    ref.watch(financeRepositoryProvider).watchSuppliers());

final invoicesListProvider = StreamProvider<List<Invoice>>((ref) =>
    ref.watch(financeRepositoryProvider).watchInvoices());

final overdueInvoicesProvider = StreamProvider<List<Invoice>>((ref) =>
    ref.watch(financeRepositoryProvider).watchOverdueInvoices());

final expensesListProvider = StreamProvider<List<Expense>>((ref) =>
    ref.watch(financeRepositoryProvider).watchExpenses());

final revenuesListProvider = StreamProvider<List<Revenue>>((ref) =>
    ref.watch(financeRepositoryProvider).watchRevenues());

final projectsListProvider = StreamProvider<List<Project>>((ref) =>
    ref.watch(financeRepositoryProvider).watchProjects());

final activeProjectsProvider = StreamProvider<List<Project>>((ref) =>
    ref.watch(financeRepositoryProvider).watchActiveProjects());

final bankAccountsProvider = StreamProvider<List<BankAccount>>((ref) =>
    ref.watch(financeRepositoryProvider).watchBankAccounts());

final pendingChecksProvider = StreamProvider<List<Check>>((ref) =>
    ref.watch(financeRepositoryProvider).watchPendingChecks());

final invoicesByClientProvider =
    StreamProvider.family<List<Invoice>, int>((ref, clientId) =>
        ref.watch(financeRepositoryProvider).watchInvoicesByClient(clientId));

final projectsByClientProvider =
    StreamProvider.family<List<Project>, int>((ref, clientId) =>
        ref.watch(financeRepositoryProvider).watchProjects().map(
              (list) => list.where((p) => p.clientId == clientId).toList(),
            ));

final financeSummaryProvider = FutureProvider<FinanceSummary>((ref) =>
    ref.watch(financeRepositoryProvider).getSummaryForCurrentMonth());