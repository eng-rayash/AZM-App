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

  /// Internal logger that handles printing and future remote transmission
  void _logError(String source, Object error, StackTrace? stack) {
    debugPrint('=== [MUDIRI ERROR CAPTURED ($source)] ===');
    debugPrint('Error: $error');
    if (stack != null) {
      debugPrint('Stacktrace: $stack');
    }
    debugPrint('=======================================');

    // Future implementation:
    // Send to Supabase or Sentry/Crashlytics if connected.
    // e.g. await Supabase.instance.client.from('error_logs').insert({...})
  }

  /// Manually log an exception or crash event
  void logException(dynamic exception, [StackTrace? stack]) {
    _logError('ManualLog', exception, stack);
  }
}
