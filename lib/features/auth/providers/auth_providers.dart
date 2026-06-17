import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, guest, unauthenticated, error, emailVerificationPending }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final User? user;

  const AuthState({
    required this.status,
    this.errorMessage,
    this.user,
  });

  const AuthState.initial() : status = AuthStatus.initial, errorMessage = null, user = null;
  const AuthState.loading() : status = AuthStatus.loading, errorMessage = null, user = null;
  const AuthState.authenticated(User u) : status = AuthStatus.authenticated, errorMessage = null, user = u;
  const AuthState.guest() : status = AuthStatus.guest, errorMessage = null, user = null;
  const AuthState.unauthenticated() : status = AuthStatus.unauthenticated, errorMessage = null, user = null;
  const AuthState.error(String message) : status = AuthStatus.error, errorMessage = message, user = null;
  const AuthState.emailVerificationPending() : status = AuthStatus.emailVerificationPending, errorMessage = null, user = null;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;

  AuthNotifier(this._repository) : super(const AuthState.initial()) {
    checkCurrentState();
  }

  Future<void> checkCurrentState() async {
    state = const AuthState.loading();
    try {
      final isGuest = await _repository.isGuestModeEnabled();
      if (isGuest) {
        state = const AuthState.guest();
      } else if (_repository.isLoggedIn) {
        state = AuthState.authenticated(_repository.currentUser!);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    try {
      final response = await _repository.signInWithEmail(email: email, password: password);
      if (response.user != null) {
        state = AuthState.authenticated(response.user!);
      } else {
        state = const AuthState.unauthenticated();
      }
    } catch (e) {
      state = AuthState.error(_translateError(e));
    }
  }

  Future<void> register(String email, String password, String fullName) async {
    state = const AuthState.loading();
    try {
      final response = await _repository.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
      // When Supabase email confirmation is enabled, session is null but user may exist
      if (response.session != null && response.user != null) {
        state = AuthState.authenticated(response.user!);
      } else {
        // Email verification required — show pending state
        state = const AuthState.emailVerificationPending();
      }
    } catch (e) {
      state = AuthState.error(_translateError(e));
    }
  }

  Future<void> continueAsGuest() async {
    state = const AuthState.loading();
    try {
      await _repository.setGuestMode(true);
      state = const AuthState.guest();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> logout() async {
    state = const AuthState.loading();
    try {
      await _repository.signOut();
      state = const AuthState.unauthenticated();
    } catch (e) {
      state = AuthState.error(e.toString());
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _repository.sendPasswordReset(email);
    } catch (e) {
      state = AuthState.error(_translateError(e));
    }
  }

  String _translateError(dynamic error) {
    final errStr = error.toString().toLowerCase();
    if (errStr.contains('invalid login credentials') || errStr.contains('invalid_credentials')) {
      // Could be wrong password OR account not found
      return 'كلمة المرور غير صحيحة أو الحساب غير موجود. تحقق من بيانات الدخول.';
    } else if (errStr.contains('user not found') || errStr.contains('no user')) {
      return 'الحساب غير موجود. يرجى إنشاء حساب جديد.';
    } else if (errStr.contains('wrong password') || errStr.contains('invalid password')) {
      return 'كلمة المرور غير صحيحة. يرجى المحاولة مجددًا.';
    } else if (errStr.contains('user already registered') || errStr.contains('already registered')) {
      return 'هذا البريد الإلكتروني مسجل بالفعل. يرجى تسجيل الدخول.';
    } else if (errStr.contains('network') || errStr.contains('connection') || errStr.contains('timeout')) {
      return 'فشل الاتصال بالشبكة. يرجى التحقق من اتصال الإنترنت.';
    } else if (errStr.contains('email not confirmed') || errStr.contains('email_not_confirmed')) {
      return 'لم يتم تأكيد البريد الإلكتروني بعد. يرجى مراجعة بريدك والضغط على رابط التفعيل.';
    } else if (errStr.contains('too many requests') || errStr.contains('rate limit')) {
      return 'محاولات كثيرة. يرجى الانتظار قليلًا ثم المحاولة مجددًا.';
    }
    return 'حدث خطأ: $error';
  }
}

final authStateNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo);
});
