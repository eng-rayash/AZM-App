import 'package:supabase_flutter/supabase_flutter.dart';

/// Base class for all Supabase repositories.
///
/// Provides common CRUD operations with error handling and
/// company-scoped queries (RLS-aware).
abstract class SupabaseRepository {
  const SupabaseRepository(this.client);

  final SupabaseClient client;

  // ─────────────────────────────────────────────
  // Helper: Error Handling
  // ─────────────────────────────────────────────

  /// Wraps a Supabase call with error handling.
  Future<T> guard<T>(Future<T> Function() fn) async {
    try {
      return await fn();
    } on PostgrestException catch (e) {
      throw RepositoryException(
        message: e.message,
        code: e.code,
        details: e.details?.toString(),
      );
    } on AuthException catch (e) {
      throw RepositoryException(
        message: e.message,
        code: e.statusCode,
      );
    } catch (e) {
      throw RepositoryException(message: e.toString());
    }
  }

  // ─────────────────────────────────────────────
  // Helper: Company-scoped query builder
  // ─────────────────────────────────────────────

  /// Returns a query scoped to the given company.
  /// RLS policies enforce this server-side, but we add it
  /// client-side too for explicit intent.
  PostgrestFilterBuilder<dynamic> companyScoped(
    String table,
    String companySyncId,
  ) {
    return client
        .from(table)
        .select()
        .eq('company_sync_id', companySyncId);
  }
}

// ─────────────────────────────────────────────
// Repository Exception
// ─────────────────────────────────────────────

class RepositoryException implements Exception {
  const RepositoryException({
    required this.message,
    this.code,
    this.details,
  });

  final String message;
  final String? code;
  final String? details;

  @override
  String toString() =>
      'RepositoryException: $message${code != null ? ' (code: $code)' : ''}';
}