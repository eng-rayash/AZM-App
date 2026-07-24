import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';


// ─────────────────────────────────────────────
// Supabase Client Provider
// ─────────────────────────────────────────────

/// Global Supabase client provider.
/// The client is initialized in main.dart before app startup.
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

/// Current authenticated user (null if not logged in)
final currentUserProvider = Provider<User?>((ref) {
  return Supabase.instance.client.auth.currentUser;
});

/// Auth state stream provider
final authStateProvider = StreamProvider<AuthState>((ref) {
  return Supabase.instance.client.auth.onAuthStateChange;
});

/// Whether the user is currently authenticated
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(currentUserProvider) != null;
});

// ─────────────────────────────────────────────
// Helper Extensions
// ─────────────────────────────────────────────

extension SupabaseClientX on SupabaseClient {
  /// Shorthand for auth.currentUser.id — throws if not authenticated
  String get userId {
    final id = auth.currentUser?.id;
    if (id == null) throw Exception('User not authenticated');
    return id;
  }
}