import 'dart:ui';
import 'package:flutter/material.dart';

class ErrorTrackingService {
  ErrorTrackingService._();

  static final ErrorTrackingService instance = ErrorTrackingService._();

  /// Initialize global error tracking hooks
  void initialize() {
    // 1. Capture Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      _logError('FlutterError', details.exception, details.stack);
    };

    // 2. Capture asynchronous Dart errors outside of the Flutter framework
    PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
      _logError('PlatformError', error, stack);
      return true; // Error is handled
    };

    debugPrint('ErrorTrackingService initialized successfully.');
  }

  /// How many times a given error message is printed in full before it is
  /// summarised. A layout error thrown during paint repeats every frame, so
  /// without a cap one bug can emit tens of thousands of console lines and
  /// slow the app down more than the bug itself.
  static const int _maxRepeatsPerError = 3;

  final Map<String, int> _seen = <String, int>{};

  /// Internal logger that handles printing and future remote transmission
  void _logError(String source, Object error, StackTrace? stack) {
    final key = '$source::$error';
    final count = (_seen[key] ?? 0) + 1;
    _seen[key] = count;

    if (count > _maxRepeatsPerError) {
      // Announce the throttle once, then stay quiet about this error.
      if (count == _maxRepeatsPerError + 1) {
        debugPrint(
          '=== [RVIOS] repeating error suppressed after '
          '$_maxRepeatsPerError occurrences: $error ===',
        );
      }
      return;
    }

    debugPrint('=== [RVIOS ERROR CAPTURED ($source)] ===');
    debugPrint('Error: $error');
    if (stack != null) {
      debugPrint('Stacktrace: $stack');
    }
    debugPrint('=======================================');

    // Future implementation:
    // Send to Supabase or Sentry/Crashlytics if connected.
    // e.g. await Supabase.instance.client.from('error_logs').insert({...})
  }

  /// Number of distinct errors seen this session, and their occurrence counts.
  Map<String, int> get errorCounts => Map.unmodifiable(_seen);

  /// Manually log an exception or crash event
  void logException(dynamic exception, [StackTrace? stack]) {
    _logError('ManualLog', exception, stack);
  }
}