import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/providers/theme_provider.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';

import 'features/notifications/domain/notification_service.dart';
import 'features/notifications/providers/smart_notifications_provider.dart';

/// AZM Application Root Widget.
///
/// Configures:
/// - Material 3 theme (AZM — حبر على ورق، وطباشير على جرافيت)
/// - Arabic locale (RTL-first)
/// - GoRouter navigation with Onboarding flow
/// - Riverpod state management
/// - Dynamic theme mode via ThemeNotifier
class AzmApp extends ConsumerStatefulWidget {
  const AzmApp({super.key});

  @override
  ConsumerState<AzmApp> createState() => _AzmAppState();
}

class _AzmAppState extends ConsumerState<AzmApp> {
  @override
  void initState() {
    super.initState();
    _initializeNotifications();
  }

  Future<void> _initializeNotifications() async {
    try {
      await ref.read(notificationServiceProvider).init();
    } catch (e) {
      debugPrint('Error initializing notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeProvider);

    // Watch smart notification scheduler to reactively sync alerts globally
    ref.watch(smartNotificationsSchedulerProvider);

    return MaterialApp.router(
      // App Identity
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,

      // Theme — dynamic mode
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,

      // Locale — Arabic first
      locale: const Locale('ar'),
      supportedLocales: const [
        Locale('ar'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Router
      routerConfig: AppRouter.router,
    );
  }
}