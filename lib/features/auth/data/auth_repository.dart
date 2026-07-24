import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// RVIOS — Auth Repository (Supabase-backed)
///
/// Bridges the existing AuthNotifier (auth_providers.dart) with Supabase Auth.
/// Adds guest mode via SharedPreferences for offline-first support.
class AuthRepository {
  static const _guestKey = 'rvios_guest_mode';

  SupabaseClient get _client => Supabase.instance.client;

  // ─────────────────────────────────────────────
  // Guest Mode (offline-first)
  // ─────────────────────────────────────────────

  Future<bool> isGuestModeEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_guestKey) ?? false;
  }

  Future<void> setGuestMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_guestKey, value);
  }

  // ─────────────────────────────────────────────
  // State
  // ─────────────────────────────────────────────

  bool get isLoggedIn => _client.auth.currentUser != null;

  User? get currentUser => _client.auth.currentUser;

  String? get currentUserId => _client.auth.currentUser?.id;

  String? get currentUserEmail => _client.auth.currentUser?.email;

  String? get displayName =>
      _client.auth.currentUser?.userMetadata?['display_name'] as String?;

  Stream<AuthState> get authStateStream => _client.auth.onAuthStateChange;

  // ─────────────────────────────────────────────
  // Sign Up
  // ─────────────────────────────────────────────

  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
    String? fullName,
    String? displayName,
  }) async {
    final response = await _client.auth.signUp(
      email: email,
      password: password,
      data: {
        'full_name': ?fullName,
        'display_name': ?displayName,
        if (fullName != null && displayName == null) 'display_name': fullName,
      },
    );
    return response;
  }

  // ─────────────────────────────────────────────
  // Sign In
  // ─────────────────────────────────────────────

  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    return _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  // ─────────────────────────────────────────────
  // OTP / Magic Link
  // ─────────────────────────────────────────────

  Future<void> sendOtp({required String email}) async {
    await _client.auth.signInWithOtp(
      email: email,
      emailRedirectTo: 'https://rvios.com/auth/callback',
    );
  }

  Future<AuthResponse> verifyOtp({
    required String email,
    required String token,
  }) async {
    return _client.auth.verifyOTP(
      email: email,
      token: token,
      type: OtpType.magiclink,
    );
  }

  // ─────────────────────────────────────────────
  // Sign Out
  // ─────────────────────────────────────────────

  Future<void> signOut() async {
    await setGuestMode(false);
    await _client.auth.signOut();
  }

  // ─────────────────────────────────────────────
  // Password Reset
  // ─────────────────────────────────────────────

  Future<void> sendPasswordReset(String email) async {
    await _client.auth.resetPasswordForEmail(
      email,
      redirectTo: 'https://rvios.com/auth/reset-password',
    );
  }

  // ─────────────────────────────────────────────
  // Update Profile
  // ─────────────────────────────────────────────

  Future<UserResponse> updateProfile({
    String? displayName,
    String? avatarUrl,
  }) async {
    return _client.auth.updateUser(
      UserAttributes(
        data: {
          'display_name': ?displayName,
          'avatar_url': ?avatarUrl,
        },
      ),
    );
  }
}