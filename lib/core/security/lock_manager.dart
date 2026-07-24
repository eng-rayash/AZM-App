import 'dart:async';

import 'package:flutter/widgets.dart';

import '../constants/app_constants.dart';

/// Lock Manager — handles auto-lock behavior.
///
/// Monitors user activity and locks the app after
/// [AppConstants.lockAfterSeconds] seconds of inactivity.
/// Also locks when the app goes to background.
class LockManager extends WidgetsBindingObserver {
  LockManager._();

  static final LockManager instance = LockManager._();

  Timer? _inactivityTimer;
  bool _isLocked = true;
  final ValueNotifier<bool> isLockedNotifier = ValueNotifier<bool>(true);

  /// Initialize the lock manager
  void initialize() {
    WidgetsBinding.instance.addObserver(this);
    _startInactivityTimer();
  }

  /// Dispose resources
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _inactivityTimer?.cancel();
  }

  /// Call this on any user interaction to reset the timer
  void registerUserActivity() {
    _resetInactivityTimer();
  }

  /// Lock the app
  void lock() {
    _isLocked = true;
    isLockedNotifier.value = true;
    _inactivityTimer?.cancel();
  }

  /// Unlock the app (after successful authentication)
  void unlock() {
    _isLocked = false;
    isLockedNotifier.value = false;
    _startInactivityTimer();
  }

  /// Check if the app is currently locked
  bool get isLocked => _isLocked;

  // ─────────────────────────────────────────────
  // App Lifecycle
  // ─────────────────────────────────────────────

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        // Lock when app goes to background
        lock();
        break;
      case AppLifecycleState.resumed:
        // App resumed — lock screen will show
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  // ─────────────────────────────────────────────
  // Inactivity Timer
  // ─────────────────────────────────────────────

  void _startInactivityTimer() {
    _inactivityTimer?.cancel();
    _inactivityTimer = Timer(
      Duration(seconds: AppConstants.lockAfterSeconds),
      () {
        lock();
      },
    );
  }

  void _resetInactivityTimer() {
    if (!_isLocked) {
      _startInactivityTimer();
    }
  }
}