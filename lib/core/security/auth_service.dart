import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:local_auth/local_auth.dart';

import 'secure_storage_service.dart';

/// Authentication Service — handles biometric and PIN authentication.
///
/// Layer 1 of the 4-layer security architecture.
/// Supports biometric (fingerprint/face) with PIN as fallback.
class AuthService {
  AuthService._();

  static final AuthService instance = AuthService._();

  final LocalAuthentication _localAuth = LocalAuthentication();
  final SecureStorageService _secureStorage = SecureStorageService.instance;

  SecureStorageService get secureStorage => _secureStorage;

  // ─────────────────────────────────────────────
  // Biometric Authentication
  // ─────────────────────────────────────────────

  /// Check if biometric authentication is available
  Future<bool> isBiometricAvailable() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      return canCheck && isDeviceSupported;
    } catch (_) {
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  /// Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'يرجى التحقق من هويتك للدخول إلى مديري',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
          useErrorDialogs: true,
        ),
      );
    } catch (_) {
      return false;
    }
  }

  // ─────────────────────────────────────────────
  // PIN Authentication
  // ─────────────────────────────────────────────

  /// Set up a new PIN
  Future<void> setupPin(String pin) async {
    final hash = _hashPin(pin);
    await _secureStorage.savePinHash(hash);
  }

  /// Verify PIN against stored hash
  Future<bool> verifyPin(String pin) async {
    final storedHash = await _secureStorage.getPinHash();
    if (storedHash == null) return false;
    return _hashPin(pin) == storedHash;
  }

  /// Check if PIN is set up
  Future<bool> isPinSetup() => _secureStorage.isPinSet();

  /// Change PIN (requires old PIN verification first)
  Future<bool> changePin(String oldPin, String newPin) async {
    final isValid = await verifyPin(oldPin);
    if (!isValid) return false;
    await setupPin(newPin);
    return true;
  }

  // ─────────────────────────────────────────────
  // First Launch Detection
  // ─────────────────────────────────────────────

  /// Check if this is the first app launch (no PIN set)
  Future<bool> isFirstLaunch() => _secureStorage.isFirstLaunch();

  /// Mark first launch as complete
  Future<void> completeFirstLaunch() =>
      _secureStorage.markFirstLaunchComplete();

  // ─────────────────────────────────────────────
  // Auth Method Management
  // ─────────────────────────────────────────────

  /// Get preferred auth method
  Future<int> getPreferredAuthMethod() => _secureStorage.getAuthMethod();

  /// Save preferred auth method
  Future<void> setPreferredAuthMethod(int method) =>
      _secureStorage.saveAuthMethod(method);

  // ─────────────────────────────────────────────
  // PIN Hashing
  // ─────────────────────────────────────────────

  /// Hash PIN using SHA-256 with a salt
  String _hashPin(String pin) {
    // Using app-specific salt. In production, use a per-user salt
    // stored separately in secure storage.
    const salt = 'mudiri_executive_pin_salt_v1';
    final bytes = utf8.encode('$salt:$pin');
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
