import 'dart:convert';
import 'dart:math';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../constants/app_constants.dart';

/// Secure Storage Service — wraps flutter_secure_storage.
///
/// Manages encrypted key-value storage using the OS keychain (iOS)
/// or encrypted shared preferences (Android).
///
/// Stores:
/// - Database encryption key
/// - PIN hash
/// - Auth method preference
/// - First launch flag
class SecureStorageService {
  SecureStorageService._();

  static final SecureStorageService instance = SecureStorageService._();

  final FlutterSecureStorage _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  // ─────────────────────────────────────────────
  // Database Encryption Key
  // ─────────────────────────────────────────────

  /// Get or create the database encryption key.
  /// The key is generated once on first launch and stored securely.
  Future<String> getOrCreateDbKey() async {
    var key = await _storage.read(key: AppConstants.dbEncryptionKeyName);
    if (key == null) {
      key = _generateSecureKey(32); // 256-bit key
      await _storage.write(
        key: AppConstants.dbEncryptionKeyName,
        value: key,
      );
    }
    return key;
  }

  // ─────────────────────────────────────────────
  // PIN Management
  // ─────────────────────────────────────────────

  /// Save hashed PIN
  Future<void> savePinHash(String pinHash) async {
    await _storage.write(
      key: AppConstants.pinHashKeyName,
      value: pinHash,
    );
  }

  /// Get stored PIN hash
  Future<String?> getPinHash() async {
    return _storage.read(key: AppConstants.pinHashKeyName);
  }

  /// Check if PIN is set
  Future<bool> isPinSet() async {
    final hash = await _storage.read(key: AppConstants.pinHashKeyName);
    return hash != null && hash.isNotEmpty;
  }

  // ─────────────────────────────────────────────
  // Auth Method
  // ─────────────────────────────────────────────

  /// Save preferred auth method
  Future<void> saveAuthMethod(int method) async {
    await _storage.write(
      key: AppConstants.authMethodKeyName,
      value: method.toString(),
    );
  }

  /// Get preferred auth method
  Future<int> getAuthMethod() async {
    final value = await _storage.read(key: AppConstants.authMethodKeyName);
    return value != null ? int.parse(value) : 0; // Default: biometric
  }

  // ─────────────────────────────────────────────
  // First Launch
  // ─────────────────────────────────────────────

  /// Check if this is the first launch
  Future<bool> isFirstLaunch() async {
    final value = await _storage.read(key: AppConstants.isFirstLaunchKey);
    return value == null;
  }

  /// Mark first launch as complete
  Future<void> markFirstLaunchComplete() async {
    await _storage.write(
      key: AppConstants.isFirstLaunchKey,
      value: 'false',
    );
  }

  // ─────────────────────────────────────────────
  // Generic Operations
  // ─────────────────────────────────────────────

  /// Read a value from secure storage
  Future<String?> read(String key) => _storage.read(key: key);

  /// Write a value to secure storage
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  /// Delete a value from secure storage
  Future<void> delete(String key) => _storage.delete(key: key);

  /// Delete all values (use with extreme caution)
  Future<void> deleteAll() => _storage.deleteAll();

  // ─────────────────────────────────────────────
  // Key Generation
  // ─────────────────────────────────────────────

  /// Generate a cryptographically secure random key
  String _generateSecureKey(int length) {
    final random = Random.secure();
    final values = List<int>.generate(length, (_) => random.nextInt(256));
    return base64Url.encode(values);
  }
}