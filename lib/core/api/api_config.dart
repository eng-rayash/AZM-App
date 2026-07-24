/// RVIOS API Client Configuration
///
/// Connects Flutter app to the NestJS backend on Render.
/// Change [baseUrl] to your actual Render URL after deployment.
class ApiConfig {
  /// Base URL for the RVIOS NestJS API
  /// Update this after Render deployment
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://rvios-api.onrender.com',
  );

  static const String apiVersion = 'v1';
  static const String apiPrefix = 'api';

  /// Full versioned API URL
  static String get apiUrl => '$baseUrl/$apiPrefix/$apiVersion';

  /// Request timeout
  static const Duration timeout = Duration(seconds: 30);

  /// Endpoints
  static const String health = '/health';
  static const String companies = '/companies';
  static const String members = '/members';
  static const String tasks = '/tasks';
  static const String meetings = '/meetings';
  static const String followUps = '/follow-ups';
  static const String employees = '/employees';
  static const String finance = '/finance';
  static const String invoices = '/finance/invoices';
  static const String expenses = '/finance/expenses';
  static const String financeSummary = '/finance/summary';
  static const String storage = '/storage';
  static const String notes = '/notes';
  static const String contacts = '/contacts';
}