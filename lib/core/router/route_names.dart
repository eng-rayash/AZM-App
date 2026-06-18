/// Route name constants for the Mudiri application.
///
/// All route paths are centralized here for type-safety.
class RouteNames {
  RouteNames._();

  // ─────────────────────────────────────────────
  // Root Routes
  // ─────────────────────────────────────────────

  static const String splash = '/';
  static const String lock = '/lock';
  static const String pinSetup = '/pin-setup';

  // ─────────────────────────────────────────────
  // Shell Routes (Bottom Navigation)
  // ─────────────────────────────────────────────

  static const String home = '/home';
  static const String dashboard = 'dashboard';
  static const String meetingsList = 'meetings';
  static const String tasksList = 'tasks';
  static const String followupsList = 'followups';
  static const String archiveListShell = 'archive';

  // Full paths for shell routes
  static const String dashboardFull = '/home/dashboard';
  static const String meetingsListFull = '/home/meetings';
  static const String tasksListFull = '/home/tasks';
  static const String followupsListFull = '/home/followups';
  static const String archiveListFull = '/home/archive';

  // ─────────────────────────────────────────────
  // Followups Routes
  // ─────────────────────────────────────────────
  
  static const String followupCreate = '/followups/create';
  static const String followupEdit = '/followups/:id/edit';
  static String followupEditPath(int id) => '/followups/$id/edit';

  // ─────────────────────────────────────────────
  // Tasks Routes
  // ─────────────────────────────────────────────
  
  static const String taskCreate = '/tasks/create';
  static const String taskDetail = '/tasks/:id';
  static const String taskEdit = '/tasks/:id/edit';
  
  static String taskDetailPath(int id) => '/tasks/$id';
  static String taskEditPath(int id) => '/tasks/$id/edit';

  // ─────────────────────────────────────────────
  // Meeting Routes
  // ─────────────────────────────────────────────

  static const String meetingCreate = '/meetings/create';
  static const String meetingDetail = '/meetings/:id';
  static const String meetingEdit = '/meetings/:id/edit';

  /// Generate meeting detail path
  static String meetingDetailPath(int id) => '/meetings/$id';

  /// Generate meeting edit path
  static String meetingEditPath(int id) => '/meetings/$id/edit';

  static const String encounterCreate = '/encounters/create';
  static const String encountersList = '/encounters';

  // ─────────────────────────────────────────────
  // Settings & Security
  // ─────────────────────────────────────────────

  static const String settings = '/settings';
  static const String securityLog = '/security-log';

  // ─────────────────────────────────────────────
  // Contacts Routes (Phase 3)
  // ─────────────────────────────────────────────

  static const String contactsList = '/contacts';
  static const String contactCreate = '/contacts/create';
  static const String contactEdit = '/contacts/:id/edit';
  static String contactDetailPath(int id) => '/contacts/$id';
  static String contactEditPath(int id) => '/contacts/$id/edit';

  // ─────────────────────────────────────────────
  // Appointments Routes (Phase 3)
  // ─────────────────────────────────────────────
  // Phase 3 Modules
  static const String appointmentsList = '/appointments';
  static const String appointmentCreate = '/appointments/create';
  static const String appointmentEdit = '/appointments/:id/edit';
  static String appointmentEditPath(int id) => '/appointments/$id/edit';
  
  static const String archiveList = '/archive';
  static const String archiveCreate = '/archive/create';
  static const String archivePdfViewer = '/archive/pdf-viewer';
  static const String archiveEdit = '/archive/:id/edit';
  static String archiveEditPath(int id) => '/archive/$id/edit';

  // Phase 4 Modules
  static const String callsList = '/calls';
  static const String callCreate = '/calls/create';
  static const String visitorsList = '/visitors';
  static const String visitorCreate = '/visitors/create';
  static const String notesList = '/notes';
  static const String noteCreate = '/notes/create';
  static const String timeline = '/timeline';

  // ─────────────────────────────────────────────
  // Movements Routes
  // ─────────────────────────────────────────────
  static const String movementsList = '/movements';
  static const String movementCreate = '/movements/create';
  static const String movementEdit = '/movements/:id/edit';
  static String movementEditPath(int id) => '/movements/$id/edit';

  // ─────────────────────────────────────────────
  // Directives Routes
  // ─────────────────────────────────────────────

  static const String directivesList = '/directives';
  static const String directiveCreate = '/directives/create';
  static const String directiveDetail = '/directives/:id';
  static const String directiveEdit = '/directives/:id/edit';
  static String directiveDetailPath(int id) => '/directives/$id';
  static String directiveEditPath(int id) => '/directives/$id/edit';

  // ─────────────────────────────────────────────
  // Reports Routes
  // ─────────────────────────────────────────────

  static const String reports = '/reports';

  // ─────────────────────────────────────────────
  // Auth Extended Routes
  // ─────────────────────────────────────────────

  static const String changePin = '/change-pin';
  static const String login = '/login';
  static const String register = '/register';
  static const String account = '/account';
  static const String privacyPolicy = '/privacy-policy';
  static const String legalProtection = '/legal-protection';
  static const String forceUpdate = '/force-update';
  static const String maintenance = '/maintenance';

  // ─────────────────────────────────────────────
  // Routine Tasks Routes
  // ─────────────────────────────────────────────

  static const String routineTasksList = '/routine-tasks';

  // ─────────────────────────────────────────────
  // Settings Extended Routes
  // ─────────────────────────────────────────────

  static const String advancedSettings = '/settings/advanced';
}
