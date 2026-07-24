import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_client.dart';
import 'api_config.dart';

/// Global API client provider — singleton through app lifecycle
final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient();
  ref.onDispose(client.dispose);
  return client;
});

// ── Typed API Service Providers ──────────────────────────────

/// Tasks API — connects to /api/v1/tasks
final tasksApiProvider = Provider<TasksApi>((ref) {
  return TasksApi(ref.watch(apiClientProvider));
});

/// Companies API — connects to /api/v1/companies
final companiesApiProvider = Provider<CompaniesApi>((ref) {
  return CompaniesApi(ref.watch(apiClientProvider));
});

/// Members API — connects to /api/v1/members
final membersApiProvider = Provider<MembersApi>((ref) {
  return MembersApi(ref.watch(apiClientProvider));
});

/// Finance API — connects to /api/v1/finance
final financeApiProvider = Provider<FinanceApi>((ref) {
  return FinanceApi(ref.watch(apiClientProvider));
});

/// Employees API — connects to /api/v1/employees
final employeesApiProvider = Provider<EmployeesApi>((ref) {
  return EmployeesApi(ref.watch(apiClientProvider));
});

// ══════════════════════════════════════════════════════════════
// API Service Classes
// ══════════════════════════════════════════════════════════════

/// Tasks API Service
class TasksApi {
  final ApiClient _client;
  TasksApi(this._client);

  Future<List<Map<String, dynamic>>> getAll({
    String? companyId,
    int? status,
    int? priority,
  }) async {
    final params = <String, String>{};
    if (status != null) params['status'] = status.toString();
    if (priority != null) params['priority'] = priority.toString();

    final data = await _client.get(
      ApiConfig.tasks,
      companyId: companyId,
      queryParams: params.isEmpty ? null : params,
    );
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<Map<String, dynamic>> create(
    Map<String, dynamic> body, {
    String? companyId,
  }) async {
    final data = await _client.post(ApiConfig.tasks, body, companyId: companyId);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> updateStatus(
    String syncId,
    int status, {
    String? companyId,
  }) async {
    final data = await _client.patch(
      '${ApiConfig.tasks}/$syncId/status',
      {'status': status},
      companyId: companyId,
    );
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> update(
    String syncId,
    Map<String, dynamic> body, {
    String? companyId,
  }) async {
    final data = await _client.patch(
      '${ApiConfig.tasks}/$syncId',
      body,
      companyId: companyId,
    );
    return Map<String, dynamic>.from(data as Map);
  }

  Future<void> delete(String syncId, {String? companyId}) =>
      _client.delete('${ApiConfig.tasks}/$syncId', companyId: companyId);
}

/// Companies API Service
class CompaniesApi {
  final ApiClient _client;
  CompaniesApi(this._client);

  Future<List<Map<String, dynamic>>> getMyCompanies() async {
    final data = await _client.get(ApiConfig.companies);
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    final data = await _client.post(ApiConfig.companies, body);
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> getStats(String syncId) async {
    final data = await _client.get('${ApiConfig.companies}/$syncId/stats');
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> update(
    String syncId,
    Map<String, dynamic> body,
  ) async {
    final data = await _client.patch('${ApiConfig.companies}/$syncId', body);
    return Map<String, dynamic>.from(data as Map);
  }
}

/// Members API Service
class MembersApi {
  final ApiClient _client;
  MembersApi(this._client);

  Future<List<Map<String, dynamic>>> getMembers(String companyId) async {
    final data = await _client.get(ApiConfig.members, companyId: companyId);
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<Map<String, dynamic>> invite(
    String companyId,
    String email,
    int role,
  ) async {
    final data = await _client.post(
      '${ApiConfig.members}/invitations',
      {'email': email, 'role': role},
      companyId: companyId,
    );
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> acceptInvitation(
    String code, {
    String? displayName,
  }) async {
    final data = await _client.post(
      '${ApiConfig.members}/invitations/$code/accept',
      {'displayName': ?displayName},
    );
    return Map<String, dynamic>.from(data as Map);
  }
}

/// Finance API Service
class FinanceApi {
  final ApiClient _client;
  FinanceApi(this._client);

  Future<Map<String, dynamic>> getSummary(String companyId) async {
    final data = await _client.get(
      ApiConfig.financeSummary,
      companyId: companyId,
    );
    return Map<String, dynamic>.from(data as Map);
  }

  Future<List<Map<String, dynamic>>> getInvoices(
    String companyId, {
    int? status,
  }) async {
    final params = status != null ? {'status': status.toString()} : null;
    final data = await _client.get(
      ApiConfig.invoices,
      companyId: companyId,
      queryParams: params,
    );
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<List<Map<String, dynamic>>> getExpenses(String companyId) async {
    final data = await _client.get(
      ApiConfig.expenses,
      companyId: companyId,
    );
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<Map<String, dynamic>> markInvoicePaid(String syncId) async {
    final data = await _client.patch('${ApiConfig.invoices}/$syncId/paid', {});
    return Map<String, dynamic>.from(data as Map);
  }
}

/// Employees API Service
class EmployeesApi {
  final ApiClient _client;
  EmployeesApi(this._client);

  Future<List<Map<String, dynamic>>> getAll(String companyId, {int? status}) async {
    final params = status != null ? {'status': status.toString()} : null;
    final data = await _client.get(
      ApiConfig.employees,
      companyId: companyId,
      queryParams: params,
    );
    return List<Map<String, dynamic>>.from(data as List);
  }

  Future<Map<String, dynamic>> getStats(String companyId) async {
    final data = await _client.get(
      '${ApiConfig.employees}/stats',
      companyId: companyId,
    );
    return Map<String, dynamic>.from(data as Map);
  }

  Future<Map<String, dynamic>> create(
    String companyId,
    Map<String, dynamic> body,
  ) async {
    final data = await _client.post(
      ApiConfig.employees,
      body,
      companyId: companyId,
    );
    return Map<String, dynamic>.from(data as Map);
  }
}