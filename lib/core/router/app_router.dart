import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── Auth & Core ─────────────────────────────────────────────────────
import '../../features/finance/presentation/clients_list_screen.dart';
import '../../features/finance/presentation/create_client_screen.dart';
import '../../features/finance/presentation/suppliers_list_screen.dart';
import '../../features/auth/presentation/change_pin_page.dart';
import '../../features/store_app/store_home_screen.dart';
import '../../features/store_app/store_modules.dart';
import '../../features/store_app/store_routes.dart';
import '../../features/store_app/store_tabs.dart';
import '../../features/auth/presentation/lock_screen.dart';
import '../../features/auth/presentation/pin_setup_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/account_screen.dart';
import '../../features/auth/presentation/force_update_screen.dart';
import '../../features/auth/presentation/maintenance_screen.dart';
import '../../features/shop/presentation/store_workspace_screen.dart';
import '../../features/shop/presentation/stores_screen.dart';
import '../../features/routine_tasks/presentation/routine_tasks_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/privacy_policy_screen.dart';
import '../../features/settings/presentation/legal_protection_screen.dart';

// ── New ERP Modules ─────────────────────────────────────────────────
import '../../features/business/presentation/business_screen.dart';

// ── Placeholder screens for new routes ─────────────────────────────

// ── New Detail Screens ──────────────────────────────────────────────
import '../../features/finance/presentation/client_detail_screen.dart';
import '../../features/notifications/presentation/notification_center_screen.dart';

// ── RVIOS Onboarding ───────────────────────────────────────────────────
import '../../features/onboarding/presentation/welcome_screen.dart';
import '../../features/store_platform/design_studio_screen.dart';
import '../../features/store_platform/payment_methods_screen.dart';
import '../../features/store_platform/store_plan_screen.dart';
import '../../features/store_platform/store_templates_screen.dart';

// ── RVIOS Platform Screens ────────────────────────────────────────

import '../../shared/widgets/app_scaffold.dart';
import 'route_names.dart';

/// App Router — GoRouter configuration for AZM.
///
/// Shell Route — تنقّل عزم: أربعة تبويبات
///   /home/dashboard  → DashboardScreen  · ما وضع عملي؟
///   /home/work       → WorkScreen       · ما الذي يجب تنفيذه؟
///   /home/business   → BusinessScreen   · من وماذا أدير؟
///   /home/insights   → InsightsScreen   · ماذا يحدث ولماذا؟
class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'root');
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'shell');

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RouteNames.splash,
    debugLogDiagnostics: true,
    routes: [
      // ─── Splash ───────────────────────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // ─── RVIOS Onboarding ──────────────────────────────────────────
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const WelcomeScreen(),
        routes: [
          GoRoute(
            path: 'register-personal',
            builder: (context, state) => const RegisterScreen(),
          ),
        ],
      ),

      // ─── Auth ─────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.lock,
        builder: (context, state) => const LockScreen(),
      ),
      GoRoute(
        path: RouteNames.pinSetup,
        builder: (context, state) => const PinSetupScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.account,
        builder: (context, state) => const AccountScreen(),
      ),
      GoRoute(
        path: RouteNames.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),
      GoRoute(
        path: RouteNames.legalProtection,
        builder: (context, state) => const LegalProtectionScreen(),
      ),
      GoRoute(
        path: RouteNames.forceUpdate,
        builder: (context, state) => const ForceUpdateScreen(),
      ),
      GoRoute(
        path: RouteNames.maintenance,
        builder: (context, state) => const MaintenanceScreen(),
      ),

      // ─── Main Shell — تنقّل عزم: أربعة تبويبات ────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShellScaffold(child: child),
        routes: [
          // ── المتجر أولًا: تبويبات تطبيق عزم للتاجر ──
          GoRoute(path: StoreRoutes.home, pageBuilder: (context, state) => const NoTransitionPage(child: StoreHomeScreen())),
          GoRoute(path: StoreRoutes.orders, pageBuilder: (context, state) => const NoTransitionPage(child: StoreOrdersScreen())),
          GoRoute(path: StoreRoutes.products, pageBuilder: (context, state) => const NoTransitionPage(child: StoreProductsScreen())),
          // تبويب ٣ — الأعمال
          GoRoute(
            path: RouteNames.businessFull,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: BusinessScreen(),
            ),
          ),
        ],
      ),

      // ─── وحدات المتجر — تُفتح فوق التبويبات ─────────────────────
      GoRoute(path: StoreRoutes.customers, builder: (context, state) => const StoreCustomersScreen()),
      GoRoute(path: StoreRoutes.reviews, builder: (context, state) => const StoreReviewsScreen()),
      GoRoute(path: StoreRoutes.zones, builder: (context, state) => const StoreZonesScreen()),
      GoRoute(path: StoreRoutes.coupons, builder: (context, state) => const StoreCouponsScreen()),
      GoRoute(path: StoreRoutes.questions, builder: (context, state) => const StoreQuestionsScreen()),
      GoRoute(path: StoreRoutes.returns, builder: (context, state) => const StoreReturnsScreen()),
      GoRoute(path: StoreRoutes.trash, builder: (context, state) => const StoreTrashScreen()),
      GoRoute(path: StoreRoutes.carts, builder: (context, state) => const StoreCartsScreen()),
      GoRoute(path: StoreRoutes.sections, builder: (context, state) => const StoreSectionsScreen()),
      GoRoute(path: StoreRoutes.analytics, builder: (context, state) => const StoreAnalyticsScreen()),
      GoRoute(path: StoreRoutes.billing, builder: (context, state) => const StorePlanScreen()),
      GoRoute(path: StoreRoutes.templates, builder: (context, state) => const StoreTemplatesScreen()),
      GoRoute(path: StoreRoutes.design, builder: (context, state) => const DesignStudioScreen()),
      GoRoute(path: StoreRoutes.pay, builder: (context, state) => const PaymentMethodsScreen()),
      GoRoute(path: StoreRoutes.team, builder: (context, state) => const StoreTeamScreen()),
      GoRoute(path: StoreRoutes.notifications, builder: (context, state) => const StoreNotificationsScreen()),

      // ─── منصة المتاجر ─────────────────────────────────────────────
      GoRoute(
        path: RouteNames.storesList,
        builder: (context, state) => const StoresScreen(),
      ),
      GoRoute(
        path: RouteNames.storeWorkspace,
        builder: (context, state) {
          // معرّف نصّي لا عددي: UUID من الخادم
          final storeId = state.pathParameters['storeId']!;
          return StoreWorkspaceScreen(storeId: storeId);
        },
      ),

      // ─── Finance Routes ───────────────────────────────────────────
      GoRoute(
        path: RouteNames.clientsList,
        builder: (context, state) => const ClientsListScreen(),
      ),
      GoRoute(
        path: RouteNames.clientCreate,
        builder: (context, state) => const CreateClientScreen(),
      ),
      GoRoute(
        path: RouteNames.clientEdit,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CreateClientScreen(clientId: id);
        },
      ),
      GoRoute(
        path: RouteNames.clientDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ClientDetailScreen(clientId: id);
        },
      ),
      GoRoute(
        path: RouteNames.suppliersList,
        builder: (context, state) => const SuppliersListScreen(),
      ),

      // ─── Notification Center ──────────────────────────────────────
      GoRoute(
        path: RouteNames.notificationCenter,
        builder: (context, state) => const NotificationCenterScreen(),
      ),

      // ─── Settings ─────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.changePin,
        builder: (context, state) => const ChangePinPage(),
      ),

      // ─── Routine Tasks ─────────────────────────────────────────────
      GoRoute(
        path: RouteNames.routineTasksList,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const RoutineTasksScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(1.0, 0.0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeInOut,
              )),
              child: FadeTransition(opacity: animation, child: child),
            );
          },
        ),
      ),

    ],
  );
}