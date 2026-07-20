import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// ── Auth & Core ─────────────────────────────────────────────────────
import '../../features/appointments/presentation/appointments_list_screen.dart';
import '../../features/hrm/presentation/employees_list_screen.dart';
import '../../features/hrm/presentation/create_employee_screen.dart';
import '../../features/finance/presentation/clients_list_screen.dart';
import '../../features/finance/presentation/invoices_list_screen.dart';
import '../../features/finance/presentation/create_invoice_screen.dart';
import '../../features/finance/presentation/create_client_screen.dart';
import '../../features/finance/presentation/create_expense_revenue_screen.dart';
import '../../features/finance/presentation/projects_list_screen.dart';
import '../../features/finance/presentation/expenses_revenues_list_screen.dart';
import '../../features/finance/presentation/create_project_screen.dart';
import '../../features/finance/presentation/suppliers_list_screen.dart';
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
import '../../features/contacts/presentation/contacts_list_screen.dart';
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
import '../../features/tasks/presentation/edit_task_screen.dart';
import '../../features/tasks/presentation/task_detail_screen.dart';
import '../../features/timeline/presentation/timeline_screen.dart';
import '../../features/visitors/presentation/visitors_list_screen.dart';
import '../../features/routine_tasks/presentation/routine_tasks_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/settings/presentation/security_log_screen.dart';
import '../../features/settings/presentation/privacy_policy_screen.dart';
import '../../features/settings/presentation/legal_protection_screen.dart';

// ── New ERP Modules ─────────────────────────────────────────────────
import '../../features/hrm/presentation/hrm_screen.dart';
import '../../features/finance/presentation/finance_screen.dart';
import '../../features/more/presentation/more_screen.dart';

// ── Placeholder screens for new routes ─────────────────────────────
import '../../shared/widgets/erp_placeholder_screen.dart';

// ── New Detail Screens ──────────────────────────────────────────────
import '../../features/finance/presentation/invoice_detail_screen.dart';
import '../../features/finance/presentation/client_detail_screen.dart';
import '../../features/finance/presentation/project_detail_screen.dart';
import '../../features/hrm/presentation/employee_detail_screen.dart';
import '../../features/hrm/presentation/departments_screen.dart';
import '../../features/hrm/presentation/payroll_screen.dart';
import '../../features/hrm/presentation/attendance_screen.dart';
import '../../features/hrm/presentation/leaves_list_screen.dart';
import '../../features/hrm/presentation/advances_list_screen.dart';
import '../../features/hrm/presentation/evaluations_list_screen.dart';
import '../../features/hrm/presentation/trainings_list_screen.dart';
import '../../features/hrm/presentation/rewards_penalties_screen.dart';
import '../../features/hrm/presentation/branches_screen.dart';
import '../../features/hrm/presentation/hrm_reports_screen.dart';
import '../../features/search/presentation/global_search_screen.dart';
import '../../features/notifications/presentation/notification_center_screen.dart';
import '../../features/finance/presentation/bank_accounts_screen.dart';
import '../../features/finance/presentation/chart_of_accounts_screen.dart';
import '../../features/finance/presentation/journal_entries_screen.dart';
import '../../features/finance/presentation/payment_vouchers_screen.dart';
import '../../features/finance/presentation/finance_reports_screen.dart';

import '../../shared/widgets/app_scaffold.dart';
import 'route_names.dart';

/// App Router — GoRouter configuration for Mudiri ERP.
///
/// Shell Route: 5-tab bottom navigation
///   /home/dashboard    → DashboardScreen
///   /home/followups    → FollowupsListScreen
///   /home/hrm          → HrmScreen
///   /home/finance      → FinanceScreen
///   /home/more         → MoreScreen
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
      // ─── Splash ───────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.splash,
        builder: (context, state) => const SplashScreen(),
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

      // ─── Main Shell (5-Tab Bottom Navigation) ────────────────────
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        builder: (context, state, child) => AppShellScaffold(child: child),
        routes: [
          // Tab 1 — Dashboard
          GoRoute(
            path: RouteNames.dashboardFull,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: DashboardScreen(),
            ),
          ),
          // Tab 2 — Follow-ups (merged Tasks)
          GoRoute(
            path: RouteNames.followupsListFull,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FollowupsListScreen(),
            ),
          ),
          // Tab 3 — HRM
          GoRoute(
            path: RouteNames.hrmFull,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: HrmScreen(),
            ),
          ),
          // Tab 4 — Finance
          GoRoute(
            path: RouteNames.financeFull,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: FinanceScreen(),
            ),
          ),
          // Tab 5 — More
          GoRoute(
            path: RouteNames.moreFull,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: MoreScreen(),
            ),
          ),
          // Legacy shell routes — kept for backward compatibility
          GoRoute(
            path: RouteNames.archiveListFull,
            pageBuilder: (context, state) => const NoTransitionPage(
              child: ArchiveListScreen(),
            ),
          ),
        ],
      ),

      // ─── Follow-ups Routes ────────────────────────────────────────
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

      // ─── Meeting Routes ───────────────────────────────────────────
      GoRoute(
        path: RouteNames.meetingsList,
        builder: (context, state) => const MeetingsListScreen(),
      ),
      GoRoute(
        path: RouteNames.meetingCreate,
        builder: (context, state) => const CreateMeetingScreen(),
      ),
      GoRoute(
        path: RouteNames.encounterCreate,
        builder: (context, state) => const CreateEncounterScreen(),
      ),
      GoRoute(
        path: RouteNames.encountersList,
        builder: (context, state) => const EncountersListScreen(),
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

      // ─── Task Routes (legacy — still navigable from old links) ────
      GoRoute(
        path: RouteNames.taskCreate,
        // Redirect to followup create with type=task
        redirect: (context, state) => RouteNames.followupCreate,
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

      // ─── HRM Routes ───────────────────────────────────────────────
      GoRoute(
        path: RouteNames.employeesList,
        builder: (context, state) => const EmployeesListScreen(),
      ),
      GoRoute(
        path: RouteNames.employeeCreate,
        builder: (context, state) => const CreateEmployeeScreen(),
      ),
      GoRoute(
        path: RouteNames.employeeEdit,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return CreateEmployeeScreen(employeeId: id);
        },
      ),
      // ── Contacts ──────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.contactsList,
        builder: (context, state) => const ContactsListScreen(),
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
      GoRoute(
        path: RouteNames.invoicesList,
        builder: (context, state) => const InvoicesListScreen(),
      ),
      GoRoute(
        path: RouteNames.invoiceCreate,
        builder: (context, state) => const CreateInvoiceScreen(),
      ),
      GoRoute(
        path: RouteNames.invoiceDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return InvoiceDetailScreen(invoiceId: id);
        },
      ),
      GoRoute(
        path: RouteNames.expensesList,
        builder: (context, state) =>
            const ExpensesRevenuesListScreen(isExpense: true),
      ),
      GoRoute(
        path: RouteNames.expenseCreate,
        builder: (context, state) =>
            const CreateExpenseRevenueScreen(isExpense: true),
      ),
      GoRoute(
        path: RouteNames.revenuesList,
        builder: (context, state) =>
            const ExpensesRevenuesListScreen(isExpense: false),
      ),
      GoRoute(
        path: RouteNames.revenueCreate,
        builder: (context, state) =>
            const CreateExpenseRevenueScreen(isExpense: false),
      ),
      GoRoute(
        path: RouteNames.chartOfAccounts,
        builder: (context, state) => const ChartOfAccountsScreen(),
      ),
      GoRoute(
        path: RouteNames.journalEntries,
        builder: (context, state) => const JournalEntriesScreen(),
      ),
      GoRoute(
        path: RouteNames.bankAccountsList,
        builder: (context, state) => const BankAccountsScreen(),
      ),
      GoRoute(
        path: RouteNames.paymentVouchersList,
        builder: (context, state) => const PaymentVouchersScreen(),
      ),
      GoRoute(
        path: RouteNames.checksList,
        builder: (context, state) => const BankAccountsScreen(),
      ),
      GoRoute(
        path: RouteNames.financeReports,
        builder: (context, state) => const FinanceReportsScreen(),
      ),

      // ─── Projects Routes ──────────────────────────────────────────
      GoRoute(
        path: RouteNames.projectsList,
        builder: (context, state) => const ProjectsListScreen(),
      ),
      GoRoute(
        path: RouteNames.projectCreate,
        builder: (context, state) => const CreateProjectScreen(),
      ),
      GoRoute(
        path: RouteNames.projectDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return ProjectDetailScreen(projectId: id);
        },
      ),

      // ─── Global Search ────────────────────────────────────────────
      GoRoute(
        path: RouteNames.globalSearch,
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const GlobalSearchScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) =>
              FadeTransition(opacity: animation, child: child),
        ),
      ),

      // ─── Notification Center ──────────────────────────────────────
      GoRoute(
        path: RouteNames.notificationCenter,
        builder: (context, state) => const NotificationCenterScreen(),
      ),

      // ─── Contacts ─────────────────────────────────────────────────
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

      // ─── Appointments ─────────────────────────────────────────────
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

      // ─── Archive ──────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.archiveList,
        builder: (context, state) => const ArchiveListScreen(),
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

      // ─── Calls ────────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.callsList,
        builder: (context, state) => const CallsListScreen(),
      ),

      // ─── Visitors ─────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.visitorsList,
        builder: (context, state) => const VisitorsListScreen(),
      ),

      // ─── Notes ───────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.notesList,
        builder: (context, state) => const NotesScreen(),
      ),

      // ─── Movements ───────────────────────────────────────────────
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

      // ─── Timeline ─────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.timeline,
        builder: (context, state) => const TimelineScreen(),
      ),

      // ─── Directives ───────────────────────────────────────────────
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

      // ─── Reports ──────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.reports,
        builder: (context, state) => const ReportsPage(),
      ),

      // ─── Settings ─────────────────────────────────────────────────
      GoRoute(
        path: RouteNames.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: RouteNames.securityLog,
        builder: (context, state) => const SecurityLogScreen(),
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

      // ─── HRM Sub-modules ───────────────────────────────────────────
      GoRoute(
        path: RouteNames.employeeDetail,
        builder: (context, state) {
          final id = int.parse(state.pathParameters['id']!);
          return EmployeeDetailScreen(employeeId: id);
        },
      ),
      GoRoute(
        path: RouteNames.departmentsList,
        builder: (context, state) => const DepartmentsScreen(),
      ),
      GoRoute(
        path: RouteNames.branchesList,
        builder: (context, state) => const BranchesScreen(),
      ),
      GoRoute(
        path: RouteNames.positionsList,
        builder: (context, state) => const ErpPlaceholderScreen(
          title: 'المسميات الوظيفية',
          icon: Icons.work_outline_rounded,
        ),
      ),
      GoRoute(
        path: RouteNames.contractsList,
        builder: (context, state) => const ErpPlaceholderScreen(
          title: 'العقود',
          icon: Icons.description_rounded,
        ),
      ),
      GoRoute(
        path: RouteNames.salariesList,
        builder: (context, state) => const PayrollScreen(),
      ),
      GoRoute(
        path: RouteNames.attendanceList,
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: RouteNames.leavesList,
        builder: (context, state) => const LeavesListScreen(),
      ),
      GoRoute(
        path: RouteNames.advancesList,
        builder: (context, state) => const AdvancesListScreen(),
      ),
      GoRoute(
        path: RouteNames.evaluationsList,
        builder: (context, state) => const EvaluationsListScreen(),
      ),
      GoRoute(
        path: RouteNames.trainingsList,
        builder: (context, state) => const TrainingsListScreen(),
      ),
      GoRoute(
        path: RouteNames.rewardsPenaltiesList,
        builder: (context, state) => const RewardsPenaltiesScreen(),
      ),
      GoRoute(
        path: RouteNames.hrmReports,
        builder: (context, state) => const HrmReportsScreen(),
      ),
      GoRoute(
        path: RouteNames.payroll,
        builder: (context, state) => const PayrollScreen(),
      ),
      GoRoute(
        path: RouteNames.attendance,
        builder: (context, state) => const AttendanceScreen(),
      ),


    ],
  );
}
