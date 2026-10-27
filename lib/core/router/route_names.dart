/// Route name constants for the Mudiri ERP application.
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
  // Shell Routes — تنقّل عزم: أربعة تبويبات
  // الرئيسية | العمل | الأعمال | الذكاء
  // ─────────────────────────────────────────────
  //
  // كل تبويب يجيب عن سؤال واحد:
  //   الرئيسية → ما وضع عملي؟ ما يحتاجني؟ ماذا أفعل الآن؟
  //   العمل    → ما الذي يجب تنفيذه؟
  //   الأعمال  → من وماذا أدير؟
  //   الذكاء   → ماذا يحدث ولماذا؟
  //
  // لا تبويب «المزيد»: حين يصير مكبًّا لعشرات الوجهات فالمشكلة في معمار
  // المعلومات. الإعدادات والحساب يُوصَل إليهما من ترويسة الرئيسية.

  static const String home = '/home';
  static const String dashboard = 'dashboard';
  static const String workShell = 'work';
  static const String businessShell = 'business';
  static const String insightsShell = 'insights';

  // Full paths for shell routes
  static const String dashboardFull = '/home/dashboard';
  static const String workFull = '/home/work';
  static const String businessFull = '/home/business';
  static const String insightsFull = '/home/insights';

  // مسارات مُبقاة داخل الـShell — وجهات لا تبويبات
  static const String followupsListFull = '/home/followups';
  static const String hrmFull = '/home/hrm';
  static const String financeFull = '/home/finance';
  static const String moreFull = '/home/more';

  // مسار الأرشيف داخل الـShell — مسجّل ويعمل.
  //
  // حُذف من هنا `meetingsListFull` و`tasksListFull`: لم يكونا مسجّلين في
  // الراوتر قط، وكان استدعاؤهما يعرض صفحة خطأ. وجهتاهما الصحيحتان
  // `meetingsList` و`followupsListFull`.
  static const String archiveListFull = '/home/archive';

  // ─────────────────────────────────────────────
  // Follow-ups Routes
  // ─────────────────────────────────────────────

  static const String followupCreate = '/followups/create';
  static const String followupDetail = '/followups/:id';
  static const String followupEdit = '/followups/:id/edit';
  static String followupDetailPath(int id) => '/followups/$id';
  static String followupEditPath(int id) => '/followups/$id/edit';

  // ─────────────────────────────────────────────
  // Tasks Routes (legacy — now merged into FollowUps)
  // ─────────────────────────────────────────────

  static const String taskCreate = '/tasks/create';
  static const String taskDetail = '/tasks/:id';
  static const String taskEdit = '/tasks/:id/edit';
  static String taskDetailPath(int id) => '/tasks/$id';
  static String taskEditPath(int id) => '/tasks/$id/edit';

  // ─────────────────────────────────────────────
  // Meeting Routes
  // ─────────────────────────────────────────────

  static const String meetingsList = '/meetings';
  static const String meetingCreate = '/meetings/create';
  static const String meetingDetail = '/meetings/:id';
  static const String meetingEdit = '/meetings/:id/edit';
  static String meetingDetailPath(int id) => '/meetings/$id';
  static String meetingEditPath(int id) => '/meetings/$id/edit';

  // Encounters → now merged into Meetings with meetingCategory=1
  static const String encounterCreate = '/meetings/encounter/create';
  static const String encountersList = '/meetings/encounters';

  // ─────────────────────────────────────────────
  // HRM Routes
  // ─────────────────────────────────────────────

  static const String hrmDashboard = '/hrm';
  static const String employeesList = '/hrm/employees';
  static const String employeeCreate = '/hrm/employees/create';
  static const String employeeDetail = '/hrm/employees/:id';
  static const String employeeEdit = '/hrm/employees/:id/edit';
  static String employeeDetailPath(int id) => '/hrm/employees/$id';
  static String employeeEditPath(int id) => '/hrm/employees/$id/edit';

  static const String departmentsList = '/hrm/departments';
  static const String departmentCreate = '/hrm/departments/create';

  static const String branchesList = '/hrm/branches';
  static const String branchCreate = '/hrm/branches/create';

  static const String positionsList = '/hrm/positions';

  static const String contractsList = '/hrm/contracts';
  static const String contractCreate = '/hrm/contracts/create';
  static const String contractDetail = '/hrm/contracts/:id';
  static String contractDetailPath(int id) => '/hrm/contracts/$id';

  static const String salariesList = '/hrm/salaries';
  static const String salaryCreate = '/hrm/salaries/create';

  static const String attendanceList = '/hrm/attendance';
  static const String attendanceCreate = '/hrm/attendance/create';

  static const String leavesList = '/hrm/leaves';
  static const String leaveCreate = '/hrm/leaves/create';

  static const String advancesList = '/hrm/advances';
  static const String advanceCreate = '/hrm/advances/create';

  static const String evaluationsList = '/hrm/evaluations';
  static const String evaluationCreate = '/hrm/evaluations/create';

  static const String trainingsList = '/hrm/trainings';
  static const String trainingCreate = '/hrm/trainings/create';

  static const String rewardsPenaltiesList = '/hrm/rewards-penalties';

  static const String hrmReports = '/hrm/reports';

  // ─────────────────────────────────────────────
  // Finance Routes
  // ─────────────────────────────────────────────
  // منصة المتاجر
  // ─────────────────────────────────────────────

  static const String storesList = '/shop/stores';

  /// لوحة متجر — المعرّف UUID نصًّا لا عددًا، بخلاف بقية المسارات:
  /// معرّفات المتاجر تأتي من PostgreSQL لا من ترقيم SQLite المحلي.
  static const String storeWorkspace = '/shop/stores/:storeId';
  static String storeWorkspacePath(String storeId) =>
      '/shop/stores/$storeId';

  // ─────────────────────────────────────────────

  static const String financeDashboard = '/finance';

  // Clients
  static const String clientsList = '/finance/clients';
  static const String clientCreate = '/finance/clients/create';
  static const String clientDetail = '/finance/clients/:id';
  static const String clientEdit = '/finance/clients/:id/edit';
  static String clientDetailPath(int id) => '/finance/clients/$id';
  static String clientEditPath(int id) => '/finance/clients/$id/edit';

  // Suppliers
  static const String suppliersList = '/finance/suppliers';
  static const String supplierCreate = '/finance/suppliers/create';
  static const String supplierDetail = '/finance/suppliers/:id';
  static String supplierDetailPath(int id) => '/finance/suppliers/$id';

  // Invoices
  static const String invoicesList = '/finance/invoices';
  static const String invoiceCreate = '/finance/invoices/create';
  static const String invoiceDetail = '/finance/invoices/:id';
  static const String invoiceEdit = '/finance/invoices/:id/edit';
  static String invoiceDetailPath(int id) => '/finance/invoices/$id';
  static String invoiceEditPath(int id) => '/finance/invoices/$id/edit';

  // Expenses
  static const String expensesList = '/finance/expenses';
  static const String expenseCreate = '/finance/expenses/create';
  static const String expenseDetail = '/finance/expenses/:id';
  static String expenseDetailPath(int id) => '/finance/expenses/$id';

  // Revenues
  static const String revenuesList = '/finance/revenues';
  static const String revenueCreate = '/finance/revenues/create';

  // Accounting
  static const String chartOfAccounts = '/finance/accounts';
  static const String journalEntries = '/finance/journal';
  static const String journalEntryCreate = '/finance/journal/create';
  static const String bankAccountsList = '/finance/bank-accounts';
  static const String bankAccountCreate = '/finance/bank-accounts/create';
  static const String paymentVouchersList = '/finance/vouchers';
  static const String paymentVoucherCreate = '/finance/vouchers/create';
  static const String checksList = '/finance/checks';
  static const String checkCreate = '/finance/checks/create';

  // Finance Reports
  static const String financeReports = '/finance/reports';

  // ─────────────────────────────────────────────
  // Projects Routes
  // ─────────────────────────────────────────────

  static const String projectsList = '/projects';
  static const String projectCreate = '/projects/create';
  static const String projectDetail = '/projects/:id';
  static const String projectEdit = '/projects/:id/edit';
  static String projectDetailPath(int id) => '/projects/$id';
  static String projectEditPath(int id) => '/projects/$id/edit';

  // ─────────────────────────────────────────────
  // Global Search
  // ─────────────────────────────────────────────

  static const String globalSearch = '/search';

  // ─────────────────────────────────────────────
  // Settings & Security
  // ─────────────────────────────────────────────

  static const String settings = '/settings';
  static const String securityLog = '/security-log';
  static const String advancedSettings = '/settings/advanced';

  // ─────────────────────────────────────────────
  // Contacts Routes
  // ─────────────────────────────────────────────

  static const String contactsList = '/contacts';
  static const String contactCreate = '/contacts/create';
  static const String contactEdit = '/contacts/:id/edit';
  static String contactDetailPath(int id) => '/contacts/$id';
  static String contactEditPath(int id) => '/contacts/$id/edit';

  // ─────────────────────────────────────────────
  // Appointments Routes
  // ─────────────────────────────────────────────

  static const String appointmentsList = '/appointments';
  static const String appointmentCreate = '/appointments/create';
  static const String appointmentEdit = '/appointments/:id/edit';
  static String appointmentEditPath(int id) => '/appointments/$id/edit';

  // ─────────────────────────────────────────────
  // Archive Routes
  // ─────────────────────────────────────────────

  static const String archiveList = '/archive';
  static const String archiveCreate = '/archive/create';
  static const String archivePdfViewer = '/archive/pdf-viewer';
  static const String archiveEdit = '/archive/:id/edit';
  static String archiveEditPath(int id) => '/archive/$id/edit';

  // ─────────────────────────────────────────────
  // Phase 4 Modules
  // ─────────────────────────────────────────────

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
  // Auth Routes
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
  // Notification Center
  // ─────────────────────────────────────────────

  static const String notificationCenter = '/notifications';

  // ─────────────────────────────────────────────
  // HRM Sub-module Routes
  // ─────────────────────────────────────────────

  static const String payroll = '/hrm/payroll';
  static const String attendance = '/hrm/attendance-screen';

  // ─────────────────────────────────────────────
  // Path Builders (typed navigation helpers)
  // ─────────────────────────────────────────────

  /// /finance/revenues/:id
  static String revenueDetailPath(int id) => '/finance/revenues/$id';
}