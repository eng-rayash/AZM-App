import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/security/secure_storage_service.dart';

class AuthRepository {
  final SupabaseClient _supabase = Supabase.instance.client;
  final SecureStorageService _secureStorage = SecureStorageService.instance;

  static const String guestModeKey = 'auth_guest_mode_enabled';

  /// Check if the user is logged in with Supabase
  User? get currentUser => _supabase.auth.currentUser;

  /// Check if session exists
  bool get isLoggedIn => currentUser != null;

  /// Check if guest mode is enabled
  Future<bool> isGuestModeEnabled() async {
    final val = await _secureStorage.read(guestModeKey);
    return val == 'true';
  }

  /// Set guest mode
  Future<void> setGuestMode(bool enabled) async {
    await _secureStorage.write(guestModeKey, enabled.toString());
  }

  /// Sign In with Email & Password
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
    // Disable guest mode on successful login
    await setGuestMode(false);
    return response;
  }

  /// Sign Up with Email & Password
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    final response = await _supabase.auth.signUp(
      email: email,
      password: password,
      data: fullName != null ? {'full_name': fullName} : null,
    );
    // Disable guest mode on successful signup
    await setGuestMode(false);
    return response;
  }

  /// Sign Out
  Future<void> signOut() async {
    await _supabase.auth.signOut();
    await setGuestMode(false);
  }

  /// Send password reset email
  Future<void> sendPasswordReset(String email) async {
    await _supabase.auth.resetPasswordForEmail(
      email,
      redirectTo: 'io.supabase.mudiri://login-callback',
    );
  }
}
