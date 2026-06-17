import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/route_names.dart';
import '../../../core/security/auth_service.dart';
import '../../../core/security/secure_storage_service.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../providers/auth_providers.dart';
import '../../../core/services/remote_config_service.dart';

/// Splash Screen — app entry point.
///
/// Displays the Mudiri logo for 1.5 seconds, then routes to:
/// - Login Screen (if not logged in & not guest)
/// - PIN Setup (first launch)
/// - Lock Screen (returning user)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _controller.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // 1. Fetch remote configuration from Supabase (with resilient offline fallback)
    try {
      await RemoteConfigService.instance.fetchConfigs();
    } catch (e) {
      debugPrint('Error fetching configs: $e');
    }

    if (!mounted) return;

    // 2. Check for Maintenance Mode
    if (RemoteConfigService.instance.maintenanceMode) {
      context.go(RouteNames.maintenance);
      return;
    }

    // 3. Check for Forced Update Constraints
    const currentVersion = AppConstants.appVersion;
    final minVersionRequired = RemoteConfigService.instance.minVersion;
    if (RemoteConfigService.instance.isVersionOlder(currentVersion, minVersionRequired)) {
      context.go(RouteNames.forceUpdate);
      return;
    }

    await Future.delayed(AppConstants.splashDuration);
    if (!mounted) return;

    final authRepository = ref.read(authRepositoryProvider);
    final isGuest = await authRepository.isGuestModeEnabled();
    final isLoggedIn = authRepository.isLoggedIn;

    if (!mounted) return;

    if (!isGuest && !isLoggedIn) {
      // User must log in or choose guest mode first
      context.go(RouteNames.login);
      return;
    }

    final authService = AuthService.instance;
    final isFirstLaunch = await authService.isFirstLaunch();

    if (!mounted) return;

    // Check if PIN is enabled (default: disabled)
    final SecureStorageService storage = authService.secureStorage;
    final pinEnabled = await storage.read('pin_enabled');
    final isPinEnabled = pinEnabled == 'true';

    if (!mounted) return;

    if (isPinEnabled && isFirstLaunch) {
      context.go(RouteNames.pinSetup);
    } else if (isPinEnabled) {
      context.go(RouteNames.lock);
    } else {
      // PIN disabled — go directly to home
      context.go(RouteNames.dashboardFull);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeuColors.navyDeep,
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // App Icon
                Container(
                  width: 110,
                  height: 110,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 24,
                        offset: const Offset(0, 10),
                        spreadRadius: 2,
                      ),
                      BoxShadow(
                        color: Colors.white.withValues(alpha: 0.08),
                        blurRadius: 12,
                        offset: const Offset(-4, -4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Image.asset(
                      'assets/icon.png',
                      width: 110,
                      height: 110,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // App Name
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamilyHeading,
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: NeuColors.textOnDark,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 8),

                // Tagline
                Text(
                  AppConstants.appDescription,
                  style: TextStyle(
                    fontFamily: AppTypography.fontFamilyBody,
                    fontSize: 14,
                    color: NeuColors.textOnDark.withValues(alpha: 0.7),
                  ),
                ),

                const SizedBox(height: 48),

                // Loading indicator
                SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      NeuColors.goldAccent.withValues(alpha: 0.8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
