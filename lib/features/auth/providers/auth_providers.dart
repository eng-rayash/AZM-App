import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../../core/dev/dev_demo_accounts.dart';
import '../../../core/dev/dev_demo_orchestrator.dart';
import '../data/auth_repository.dart';

enum AuthStatus { initial, loading, authenticated, guest, unauthenticated, error, emailVerificationPending }

class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final AzmSession? session;

  const AuthState({
    required this.status,
    this.errorMessage,
    this.session,
  });

  /// الحساب المسجَّل — `null` للضيف ولغير المسجَّل.
  AzmAccount? get user => session?.account;

  const AuthState.initial() : status = AuthStatus.initial, errorMessage = null, session = null;
  const AuthState.loading() : status = AuthStatus.loading, errorMessage = null, session = null;
  const AuthState.authenticated(AzmSession s) : status = AuthStatus.authenticated, errorMessage = null, session = s;
  const AuthState.guest() : status = AuthStatus.guest, errorMessage = null, session = null;
  const AuthState.unauthenticated() : status = AuthStatus.unauthenticated, errorMessage = null, session = null;
  const AuthState.error(String message) : status = AuthStatus.error, errorMessage = message, session = null;
  const AuthState.emailVerificationPending() : status = AuthStatus.emailVerificationPending, errorMessage = null, session = null;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository();
});

/// عميل الباكند الموحّد بجلسة المستخدم الحالية — لكل ما سيتصل بالخادم بعد الدخول.
final apiClientProvider = Provider<ApiClient>((ref) => ref.watch(authRepositoryProvider).api);

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _repository;
  final Ref _ref;

  AuthNotifier(this._repository, this._ref) : super(const AuthState.initial()) {
    checkCurrentState();
  }

  Future<void> checkCurrentState() async {
    state = const AuthState.loading();
    try {
      if (await _repository.isGuestModeEnabled()) {
        state = const AuthState.guest();
        return;
      }
      // استعادة جلسة تجريبية محفوظة (وضع التطوير فقط)
      final demoSession = await DevDemoAccounts.restoreSession();
      if (demoSession != null) {
        // إعادة تهيئة الشركة والباقة من القاعدة المحلية
        if (kDebugMode) {
          await DevDemoOrchestrator.activate(
            _ref,
            demoSession,
            demoSession.account.email,
          );
        }
        state = AuthState.authenticated(demoSession);
        return;
      }
      final session = await _repository.restore();
      state = session != null ? AuthState.authenticated(session) : const AuthState.unauthenticated();
    } catch (e) {
      // لا خادم ولا جلسة محفوظة على الجهاز — يعود لشاشة الدخول برسالة واضحة
      state = AuthState.error(_message(e));
    }
  }

  Future<void> login(String email, String password) async {
    state = const AuthState.loading();
    try {
      // ── حسابات المطوّر التجريبية — تعمل بلا خادم في وضع التطوير فقط ──
      final demoSession = DevDemoAccounts.tryLogin(email, password);
      if (demoSession != null) {
        await DevDemoAccounts.saveSession(demoSession);
        // تهيئة الشركة والباقة وبيانات العرض
        if (kDebugMode) {
          await DevDemoOrchestrator.activate(
            _ref,
            demoSession,
            email,
          );
        }
        state = AuthState.authenticated(demoSession);
        return;
      }
      final session = await _repository.signIn(email: email, password: password);
      state = AuthState.authenticated(session);
    } catch (e) {
      state = AuthState.error(_message(e));
    }
  }

  /// حساب جديد وشركته — الخادم ينشئهما معًا، والمسجِّل مالكها.
  Future<void> register(String email, String password, String fullName, String companyName) async {
    state = const AuthState.loading();
    try {
      final session = await _repository.signUp(
        email: email,
        password: password,
        displayName: fullName,
        companyName: companyName,
      );
      state = AuthState.authenticated(session);
    } catch (e) {
      state = AuthState.error(_message(e));
    }
  }

  Future<void> switchCompany(String companyId) async {
    try {
      state = AuthState.authenticated(await _repository.switchCompany(companyId));
    } catch (e) {
      state = AuthState.error(_message(e));
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
      await DevDemoAccounts.clearSession();
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
      state = AuthState.error(_message(e));
    }
  }

  /// رسائل الخادم عربية أصلًا (`ApiException.message`) — تُعرض كما هي.
  String _message(Object error) =>
      error is ApiException ? error.message : 'حدث خطأ غير متوقع — أعد المحاولة.';
}

final authStateNotifierProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final repo = ref.watch(authRepositoryProvider);
  return AuthNotifier(repo, ref);
});
