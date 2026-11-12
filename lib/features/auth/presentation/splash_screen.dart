import 'package:flutter/material.dart';

import '../../../shared/widgets/rvios_brand.dart';
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
import '../../store_app/store_routes.dart';

/// AZM Splash Screen — app entry point.
///
/// Displays the AZM wordmark for 1.5 seconds, then routes to:
/// - /onboarding (first launch — no account)
/// - Lock Screen (returning user with PIN)
/// - Dashboard (returning user, PIN disabled)
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  /// ميزانية الإقلاع — أقصى ما ينتظره المستخدم قبل أن يمضي التطبيق
  /// ببياناته المحلية.
  ///
  /// التطبيق يعمل دون اتصال، فلا معنى لحبس الشاشة الأولى على شبكة:
  /// ما يصل في الوقت يُستعمل، وما تأخّر يلحق بنا بعد الدخول.
  ///
  /// عامّة ليقرأها اختبار الدخان: كان يضخّ ١٥٠٠ مللي ثانية بالرقم،
  /// فكل تغيير هنا يتركه يرسُب بمؤقّت معلّق.
  static const bootBudget = Duration(milliseconds: 2500);

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

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _controller.forward();
    _navigateAfterDelay();
  }

  /// أقلّ ما تبقى شاشة الانطلاق ظاهرة — لحظة علامة لا انتظار.
  static const _minSplash = Duration(milliseconds: 700);

  Future<void> _navigateAfterDelay() async {
    // الإقلاع كان **متسلسلًا**: `fetchConfigs` ينتظر الشبكة حتى
    // `apiTimeout` (١٥ ثانية)، ثم يُضاف إليه تأخير صناعي ثابت ١٫٥
    // ثانية، ثم `checkCurrentState` ينتظر الشبكة مرّة أخرى — فبلا
    // خادم يدور المؤشّر قرابة ٣٠ ثانية قبل أن يظهر شيء.
    //
    // الآن: الطلبان يجريان معًا، وتحتهما سقف واحد، ولحظة العلامة
    // تتداخل معهما بدل أن تُضاف إليهما. فالزمن = الأطول لا المجموع.
    final minSplash = Future<void>.delayed(_minSplash);

    final boot = Future.wait([
      RemoteConfigService.instance.fetchConfigs().catchError((Object e) {
        debugPrint('Error fetching configs: $e');
      }),
      _resolveAuth(),
    ]);

    await Future.wait([
      minSplash,
      boot.timeout(
        SplashScreen.bootBudget,
        onTimeout: () {
          // لا خطأ هنا: تجاوز الميزانية حالة متوقّعة لا عطب. الإعدادات
          // تبقى على افتراضياتها، وحالة الدخول تُحسم من الجلسة المخزَّنة.
          debugPrint('Boot budget exceeded — continuing with local state.');
          return const [];
        },
      ),
    ]);

    if (!mounted) return;

    // الصيانة والتحديث الإلزامي يُفحصان **بعد** وصول الإعدادات لا
    // قبلها: بلا اتصال تبقى القيم الافتراضية، فلا يُحتجز المستخدم
    // خلف شاشة صيانة لأن الشبكة تأخّرت.
    if (RemoteConfigService.instance.maintenanceMode) {
      context.go(RouteNames.maintenance);
      return;
    }

    const currentVersion = AppConstants.appVersion;
    final minVersionRequired = RemoteConfigService.instance.minVersion;
    if (RemoteConfigService.instance.isVersionOlder(
      currentVersion,
      minVersionRequired,
    )) {
      context.go(RouteNames.forceUpdate);
      return;
    }

    final auth = ref.read(authStateNotifierProvider);
    final isGuest = auth.status == AuthStatus.guest;
    final isLoggedIn = auth.status == AuthStatus.authenticated;

    if (!isGuest && !isLoggedIn) {
      context.go('/onboarding');
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
      // PIN disabled — إلى لوحة المتجر
      context.go(StoreRoutes.home);
    }
  }

  /// يحسم حالة الدخول إن لم تكن محسومة — وإلا فلا طلب.
  Future<void> _resolveAuth() async {
    final status = ref.read(authStateNotifierProvider).status;
    if (status != AuthStatus.initial && status != AuthStatus.loading) return;
    await ref.read(authStateNotifierProvider.notifier).checkCurrentState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeuColors.primary,
      body: Stack(
        children: [
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // علامة RV الكريمية على الأحمر — تُرسم ثم تمتلئ
                    const AnimatedRvMark(width: 150, color: RvBrand.cream, glow: true, loop: false),
                    const SizedBox(height: 26),
                    const RviosWordmark(width: 210, onDark: true, animate: true, delay: Duration(milliseconds: 700)),
                    const SizedBox(height: 8),

                    Text(
                      AppConstants.appTagline,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamilyPanorama,
                        fontSize: 13,
                        color: Colors.white.withValues(alpha: 0.75),
                        letterSpacing: 1,
                      ),
                    ),

                    const SizedBox(height: 48),

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
        ],
      ),
    );
  }
}
