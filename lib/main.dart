import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/security/lock_manager.dart';
import 'core/services/supabase_config.dart';
import 'core/services/error_tracking_service.dart';

/// Application entry point.
///
/// Initializes:
/// 1. Flutter bindings
/// 2. Error tracking
/// 3. Supabase config
/// 4. System UI (status bar style)
/// 5. Screen orientation (portrait only)
/// 6. Lock manager (auto-lock)
/// 7. Riverpod scope
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Error Tracking
  ErrorTrackingService.instance.initialize();

  // Initialize Supabase Config
  try {
    await SupabaseConfig.initialize();
  } catch (e) {
    debugPrint('Error initializing Supabase: $e');
  }

  // Lock to portrait orientation (executive apps don't rotate)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // System UI styling
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFECF0F6),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize lock manager
  LockManager.instance.initialize();

  runApp(
    const ProviderScope(
      child: MudiriApp(),
    ),
  );
}
