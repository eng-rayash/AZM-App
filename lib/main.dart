import 'package:drift/drift.dart' show driftRuntimeOptions;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/database/providers/database_providers.dart';
import 'core/security/lock_manager.dart';
import 'core/services/supabase_config.dart';
import 'core/services/error_tracking_service.dart';
import 'core/theme/neu_colors.dart';

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
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: NeuColors.bgColor,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize lock manager
  LockManager.instance.initialize();

  // المستأجر المحفوظ يُقرأ **قبل** بناء الشجرة: `databaseProvider`
  // يفتح ملفًّا بحسبه، وقراءته بعد الإقلاع تعني فتح الملف الشخصي ثم
  // إغلاقه فورًا — وميضٌ من بيانات خاطئة في أسوأ الحالات.
  final activeTenant = await loadActiveTenant();

  // في وضع الشركات تُفتح قاعدتان معًا: ملف الشركة النشطة وملف السجلّ.
  // drift يحذّر من إنشاء صنف القاعدة مرّتين لأن **منفّذًا مشتركًا**
  // بين نسختين يسبّب تنازعًا — والمنفّذان هنا ملفّان مختلفان، فالتحذير
  // إيجابية كاذبة. تركه يدرّب على تجاهل تحذيرات drift الحقيقية.
  driftRuntimeOptions.dontWarnAboutMultipleDatabases = true;

  runApp(
    ProviderScope(
      overrides: [
        activeTenantIdProvider.overrideWith(
          (ref) => ActiveTenantNotifier(activeTenant),
        ),
      ],
      child: const AzmApp(),
    ),
  );
}