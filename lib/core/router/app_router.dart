import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/appointments/presentation/appointments_list_screen.dart';
import '../../features/appointments/presentation/create_appointment_screen.dart';
import '../../features/archive/presentation/archive_list_screen.dart';
import '../../features/archive/presentation/create_archive_screen.dart';
import '../../features/archive/presentation/archive_pdf_viewer_screen.dart';
import '../../features/auth/presentation/change_pin_page.dart';
import '../../features/auth/presentation/lock_screen.dart';
import '../../features/auth/presentation/pin_setup_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/account_screen.dart';
import '../../features/auth/presentation/force_update_screen.dart';
import '../../features/auth/presentation/maintenance_screen.dart';
import '../../features/calls/presentation/calls_list_screen.dart';
import '../../features/contacts/presentation/create_contact_screen.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/directives/presentation/pages/create_directive_page.dart';
import '../../features/directives/presentation/pages/directive_detail_page.dart';
import '../../features/directives/presentation/pages/directives_list_page.dart';
import '../../features/followups/presentation/create_followup_screen.dart';
import '../../features/followups/presentation/followups_list_screen.dart';
import '../../features/meetings/presentation/create_encounter_screen.dart';
import '../../features/meetings/presentation/create_meeting_screen.dart';
import '../../features/meetings/presentation/edit_meeting_screen.dart';
import '../../features/meetings/presentation/meeting_detail_screen.dart';
import '../../features/meetings/presentation/encounters_list_screen.dart';
import '../../features/meetings/presentation/meetings_list_screen.dart';
import '../../features/movements/presentation/create_movement_screen.dart';
import '../../features/movements/presentation/movements_list_screen.dart';
import '../../features/notes/presentation/notes_screen.dart';
import '../../features/reports/presentation/pages/reports_page.dart';
import '../../features/tasks/presentation/create_task_screen.dart';
import '../../features/tasks/presentation/edit_task_screen.dart';
import '../../features/tasks/presentation/task_detail_screen.dart';
import '../../features/tasks/presentation/tasks_list_screen.dart';
import '../../features/timeline/presentation/timeline_screen.dart';
import '../../features/visitors/presentation/visitors_list_screen.dart';

// Phase 5
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/security_log_screen.dart';
import '../../features/settings/presentation/privacy_policy_screen.dart';
import '../../features/settings/presentation/legal_protection_screen.dart';
import '../../shared/widgets/app_scaffold.dart';
import 'route_names.dart';

/// App Router — GoRouter configuration with auth guards.
///
/// Implements declarative routing with:
/// - Shell route for bottom navigation
/// - Auth redirect for lock screen
/// - Type-safe route parameters
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
      // ─── Splash Screen ───
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
      ),

      // ─── Lock Screen ───
      GoRoute(
        path: RouteNames.lock,
        builder: (context, state) => const LockScreen(),
      ),

      // ─── PIN Setup (first launch) ───
      GoRoute(
        path: RouteNames.pinSetup,
        builder: (context, state) => const PinSetupScreen(),
      ),

      // ─── Login Screen ───
      GoRoute(
        path: RouteNames.login,
        builder: (context, state) => const LoginScreen(),
      ),

      // ─── Register Screen ───
      GoRoute(
        path: RouteNames.register,
        builder: (context, state) => const RegisterScreen(),
      ),

      // ─── Account Screen ───
      GoRoute(
        path: RouteNames.account,
        builder: (context, state) => const AccountScreen(),
      ),

      // ─── Privacy Policy Screen ───
      GoRoute(
        path: RouteNames.privacyPolicy,
        builder: (context, state) => const PrivacyPolicyScreen(),
      ),

      // ─── Legal Protection Screen ───
      GoRoute(
        path: RouteNames.legalProtection,
        builder: (context, state) => const LegalProtectionScreen(),
      ),

      // ─── Force Update Screen ───
      GoRoute(
        path: RouteNames.forceUpdate,
        builder: (context, state) => const ForceUpdateScreen(),
      ),

      // ─── Maintenance Screen ───
      GoRoute(
        path: RouteNames.maintenance,
        builder: (context, state) => const MaintenanceScreen(),
      ),

      // ─── Main Shell (Bottom Navigation) ───
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShellScaffold(child: child),
        routes: [
          GoRoute(
            path: RouteNames.dashboardFull,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.meetingsListFull,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MeetingsListScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.tasksListFull,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: TasksListScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.followupsListFull,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FollowupsListScreen(),
            ),
          ),
          GoRoute(
            path: RouteNames.archiveListFull,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ArchiveListScreen(),
            ),
          ),
        ],
      ),

      // ─── Contact Routes (outside shell) ───
      GoRoute(
        path: RouteNames.contactCreate,
        builder: (context, state) => const CreateContactScreen(),
      ),
      GoRoute(
        path: RouteNames.contactEdit,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CreateContactScreen(contactId: id);
        },
      ),

      // ─── Appointment Routes ───
      GoRoute(
        path: RouteNames.appointmentsList,
        builder: (context, state) => const AppointmentsListScreen(),
      ),
      GoRoute(
        path: RouteNames.appointmentCreate,
        builder: (context, state) => const CreateAppointmentScreen(),
      ),
      GoRoute(
        path: RouteNames.appointmentEdit,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CreateAppointmentScreen(appointmentId: id);
        },
      ),

      GoRoute(
        path: RouteNames.archiveCreate,
        builder: (context, state) => const CreateArchiveScreen(),
      ),
      GoRoute(
        path: RouteNames.archiveEdit,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CreateArchiveScreen(archiveId: id);
        },
      ),
      GoRoute(
        path: RouteNames.archivePdfViewer,
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return ArchivePdfViewerScreen(
            pdfPath: extra['pdfPath'] as String,
            title: extra['title'] as String,
          );
        },
      ),

      // ─── Call Routes ───
      GoRoute(
        path: RouteNames.callsList,
        builder: (context, state) => const CallsListScreen(),
      ),

      // ─── Visitor Routes ───
      GoRoute(
        path: RouteNames.visitorsList,
        builder: (context, state) => const VisitorsListScreen(),
      ),

      // ─── Note Routes ───
      GoRoute(
        path: RouteNames.notesList,
        builder: (context, state) => const NotesScreen(),
      ),

      // ─── Movement Routes ───
      GoRoute(
        path: RouteNames.movementsList,
        builder: (context, state) => const MovementsListScreen(),
      ),
      GoRoute(
        path: RouteNames.movementCreate,
        builder: (context, state) => const CreateMovementScreen(),
      ),
      GoRoute(
        path: RouteNames.movementEdit,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CreateMovementScreen(movementId: id);
        },
      ),

      // ─── Encounters Routes ───
      GoRoute(
        path: RouteNames.encountersList,
        builder: (context, state) => const EncountersListScreen(),
      ),

      // ─── Timeline Routes ───
      GoRoute(
        path: RouteNames.timeline,
        builder: (context, state) => const TimelineScreen(),
      ),

      // ─── Settings Routes ───
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.securityLog,
        builder: (context, state) => const SecurityLogScreen(),
      ),

      // ─── Follow-ups Routes (outside shell) ───
      GoRoute(
        path: RouteNames.followupCreate,
        builder: (context, state) => const CreateFollowupScreen(),
      ),
      GoRoute(
        path: RouteNames.followupEdit,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CreateFollowupScreen(followupId: id);
        },
      ),

      // ─── Meeting Routes (outside shell) ───
      GoRoute(
        path: RouteNames.meetingCreate,
        builder: (context, state) => const CreateMeetingScreen(),
      ),
      GoRoute(
        path: RouteNames.encounterCreate,
        builder: (context, state) => const CreateEncounterScreen(),
      ),
      GoRoute(
        path: RouteNames.meetingDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return MeetingDetailScreen(meetingId: id);
        },
      ),
      GoRoute(
        path: RouteNames.meetingEdit,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EditMeetingScreen(meetingId: id);
        },
      ),

      // ─── Task Routes (outside shell) ───
      GoRoute(
        path: RouteNames.taskCreate,
        builder: (context, state) => const CreateTaskScreen(),
      ),
      GoRoute(
        path: RouteNames.taskDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return TaskDetailScreen(taskId: id);
        },
      ),
      GoRoute(
        path: RouteNames.taskEdit,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EditTaskScreen(taskId: id);
        },
      ),

      // ─── Directive Routes ───
      GoRoute(
        path: RouteNames.directivesList,
        builder: (context, state) => const DirectivesListPage(),
      ),
      GoRoute(
        path: RouteNames.directiveCreate,
        builder: (context, state) => const CreateDirectivePage(),
      ),
      GoRoute(
        path: RouteNames.directiveDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return DirectiveDetailPage(directiveId: id);
        },
      ),
      GoRoute(
        path: RouteNames.directiveEdit,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CreateDirectivePage(directiveId: id);
        },
      ),

      // ─── Reports Route ───
      GoRoute(
        path: RouteNames.reports,
        builder: (context, state) => const ReportsPage(),
      ),

      // ─── Change PIN Route ───
      GoRoute(
        path: RouteNames.changePin,
        builder: (context, state) => const ChangePinPage(),
      ),
    ],
  );
}
