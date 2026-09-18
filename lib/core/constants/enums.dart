/// Core Constants & Enums for AZM
///
/// Unified status and priority systems used across all features.
library;

import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
// Meeting Status
// ─────────────────────────────────────────────

/// نظام حالات الاجتماعات
enum MeetingStatus {
  /// مجدول — Scheduled
  scheduled(0, 'مجدول'),

  /// قيد التنفيذ — In Progress
  inProgress(1, 'قيد التنفيذ'),

  /// مكتمل — Completed
  completed(2, 'مكتمل'),

  /// مؤجل — Postponed
  postponed(3, 'مؤجل'),

  /// ملغي — Cancelled
  cancelled(4, 'ملغي');

  const MeetingStatus(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static MeetingStatus fromValue(int value) =>
      MeetingStatus.values.firstWhere((e) => e.value == value,
      // قيمة غير معروفة لا تُسقط الشاشة: صفّ من نسخة أقدم أو
      // بيانات تالفة تُقرأ كقيمة افتراضية بدل أن ترمي.
      orElse: () => MeetingStatus.scheduled,
      );
}

// ─────────────────────────────────────────────
// Meeting Type
// ─────────────────────────────────────────────

/// أنواع الاجتماعات
enum MeetingType {
  /// اجتماع عام — General
  general(0, 'اجتماع عام'),

  /// اجتماع إداري — Administrative
  administrative(1, 'اجتماع إداري'),

  /// اجتماع طوارئ — Emergency
  emergency(2, 'اجتماع طوارئ'),

  /// اجتماع مراجعة — Review
  review(3, 'اجتماع مراجعة'),

  /// اجتماع تخطيط — Planning
  planning(4, 'اجتماع تخطيط'),

  /// اجتماع متابعة — Follow-up
  followUp(5, 'اجتماع متابعة'),

  /// اجتماع خارجي — External
  external_(6, 'اجتماع خارجي');

  const MeetingType(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static MeetingType fromValue(int value) =>
      MeetingType.values.firstWhere((e) => e.value == value,
      // قيمة غير معروفة لا تُسقط الشاشة: صفّ من نسخة أقدم أو
      // بيانات تالفة تُقرأ كقيمة افتراضية بدل أن ترمي.
      orElse: () => MeetingType.general,
      );
}

// ─────────────────────────────────────────────
// Unified Status System
// ─────────────────────────────────────────────

/// نظام الحالات الموحد — يُستخدم عبر جميع الوحدات
enum UnifiedStatus {
  /// جديد — New
  newItem(0, 'جديد'),

  /// قيد التنفيذ — In Progress
  inProgress(1, 'قيد التنفيذ'),

  /// بانتظار الرد — Awaiting Response
  awaitingResponse(2, 'بانتظار الرد'),

  /// مكتمل — Completed
  completed(3, 'مكتمل'),

  /// متأخر — Overdue
  overdue(4, 'متأخر'),

  /// متعثر — Stalled
  stalled(5, 'متعثر'),

  /// ملغي — Cancelled
  cancelled(6, 'ملغي');

  const UnifiedStatus(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static UnifiedStatus fromValue(int value) =>
      UnifiedStatus.values.firstWhere((e) => e.value == value,
      // قيمة غير معروفة لا تُسقط الشاشة: صفّ من نسخة أقدم أو
      // بيانات تالفة تُقرأ كقيمة افتراضية بدل أن ترمي.
      orElse: () => UnifiedStatus.newItem,
      );
}

// ─────────────────────────────────────────────
// Priority System
// ─────────────────────────────────────────────

/// نظام الأولويات
enum Priority {
  /// عاجل جدًا — Critical
  critical(0, 'عاجل جدًا'),

  /// عالي — High
  high(1, 'عالي'),

  /// متوسط — Medium
  medium(2, 'متوسط'),

  /// منخفض — Low
  low(3, 'منخفض');

  const Priority(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static Priority fromValue(int value) =>
      Priority.values.firstWhere((e) => e.value == value,
      // قيمة غير معروفة لا تُسقط الشاشة: صفّ من نسخة أقدم أو
      // بيانات تالفة تُقرأ كقيمة افتراضية بدل أن ترمي.
      orElse: () => Priority.medium,
      );
}

// ─────────────────────────────────────────────
// Security Action Types
// ─────────────────────────────────────────────

/// أنواع الإجراءات الأمنية — Security Log
enum SecurityAction {
  login(0, 'تسجيل دخول'),
  failedLogin(1, 'محاولة دخول فاشلة'),
  logout(2, 'تسجيل خروج'),
  pinSetup(3, 'إعداد رمز PIN'),
  pinChanged(4, 'تغيير رمز PIN'),
  biometricEnabled(5, 'تفعيل البصمة'),
  biometricDisabled(6, 'إلغاء البصمة'),
  exportData(7, 'تصدير بيانات'),
  deleteRecord(8, 'حذف سجل'),
  backupCreated(9, 'إنشاء نسخة احتياطية'),
  backupRestored(10, 'استعادة نسخة احتياطية'),
  settingsChanged(11, 'تعديل الإعدادات'),
  appLocked(12, 'قفل التطبيق'),
  appUnlocked(13, 'فتح التطبيق');

  const SecurityAction(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static SecurityAction fromValue(int value) =>
      SecurityAction.values.firstWhere((e) => e.value == value,
      // قيمة غير معروفة لا تُسقط الشاشة: صفّ من نسخة أقدم أو
      // بيانات تالفة تُقرأ كقيمة افتراضية بدل أن ترمي.
      orElse: () => SecurityAction.login,
      );
}

// ─────────────────────────────────────────────
// Auth Method
// ─────────────────────────────────────────────

/// طرق المصادقة
enum AuthMethod {
  /// بصمة — Biometric (priority)
  biometric(0, 'بصمة'),

  /// رمز PIN — PIN Code (fallback)
  pin(1, 'رمز PIN'),

  /// نمط — Pattern (optional, future)
  pattern(2, 'نمط');

  const AuthMethod(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static AuthMethod fromValue(int value) =>
      AuthMethod.values.firstWhere((e) => e.value == value,
      // قيمة غير معروفة لا تُسقط الشاشة: صفّ من نسخة أقدم أو
      // بيانات تالفة تُقرأ كقيمة افتراضية بدل أن ترمي.
      orElse: () => AuthMethod.pin,
      );
}

// ─────────────────────────────────────────────
// Follow Up Entity Type
// ─────────────────────────────────────────────

/// نوع الكيان المرتبط بالمتابعة
enum FollowUpEntityType {
  meeting(0, 'اجتماع'),
  task(1, 'مهمة'),
  directive(2, 'توجيه'),
  client(3, 'عميل'),
  project(4, 'مشروع'),
  employee(5, 'موظف'),
  invoice(6, 'فاتورة'),
  other(7, 'أخرى');

  const FollowUpEntityType(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static FollowUpEntityType fromValue(int value) =>
      FollowUpEntityType.values.firstWhere(
        (e) => e.value == value,
        orElse: () => FollowUpEntityType.other,
      );
}

// ─────────────────────────────────────────────
// Followup Type (ERP)
// ─────────────────────────────────────────────

/// نوع المتابعة في نظام ERP — يُميّز المتابعات عن المهام وغيرها
enum FollowupType {
  followup(0, 'متابعة'),
  task(1, 'مهمة'),
  clientFollowup(2, 'متابعة عميل'),
  projectFollowup(3, 'متابعة مشروع'),
  employeeFollowup(4, 'متابعة موظف'),
  financeFollowup(5, 'متابعة مالية'),
  other(6, 'أخرى');

  const FollowupType(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static FollowupType fromValue(int value) =>
      FollowupType.values.firstWhere(
        (e) => e.value == value,
        orElse: () => FollowupType.followup,
      );
}

// ─────────────────────────────────────────────
// Employee Status
// ─────────────────────────────────────────────

enum EmployeeStatus {
  active(0, 'نشط'),
  onLeave(1, 'في إجازة'),
  suspended(2, 'موقوف'),
  resigned(3, 'مستقيل'),
  terminated(4, 'منهية خدمته'),
  retired(5, 'متقاعد');

  const EmployeeStatus(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static EmployeeStatus fromValue(int value) =>
      EmployeeStatus.values.firstWhere(
        (e) => e.value == value,
        orElse: () => EmployeeStatus.active,
      );
}

// ─────────────────────────────────────────────
// Contract Status
// ─────────────────────────────────────────────

enum ContractStatus {
  active(0, 'ساري'),
  expiringSoon(1, 'ينتهي قريباً'),
  expired(2, 'منتهي'),
  terminated(3, 'مُنهى');

  const ContractStatus(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static ContractStatus fromValue(int value) =>
      ContractStatus.values.firstWhere(
        (e) => e.value == value,
        orElse: () => ContractStatus.active,
      );
}

// ─────────────────────────────────────────────
// Invoice Status
// ─────────────────────────────────────────────

enum InvoiceStatus {
  draft(0, 'مسودة'),
  sent(1, 'مُرسلة'),
  paid(2, 'مدفوعة'),
  partial(3, 'مدفوعة جزئياً'),
  overdue(4, 'متأخرة'),
  cancelled(5, 'ملغاة');

  const InvoiceStatus(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static InvoiceStatus fromValue(int value) =>
      InvoiceStatus.values.firstWhere(
        (e) => e.value == value,
        orElse: () => InvoiceStatus.draft,
      );
}

// ─────────────────────────────────────────────
// Project Status
// ─────────────────────────────────────────────

enum ProjectStatus {
  planning(0, 'تخطيط'),
  active(1, 'نشط'),
  onHold(2, 'متوقف'),
  completed(3, 'مكتمل'),
  cancelled(4, 'ملغي');

  const ProjectStatus(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static ProjectStatus fromValue(int value) =>
      ProjectStatus.values.firstWhere(
        (e) => e.value == value,
        orElse: () => ProjectStatus.planning,
      );
}

// ─────────────────────────────────────────────
// Leave Type
// ─────────────────────────────────────────────

enum LeaveType {
  annual(0, 'سنوية'),
  sick(1, 'مرضية'),
  emergency(2, 'طارئة'),
  unpaid(3, 'بدون راتب'),
  maternity(4, 'أمومة'),
  hajj(5, 'حج'),
  other(6, 'أخرى');

  const LeaveType(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static LeaveType fromValue(int value) =>
      LeaveType.values.firstWhere(
        (e) => e.value == value,
        orElse: () => LeaveType.other,
      );
}

// ─────────────────────────────────────────────
// Payment Method
// ─────────────────────────────────────────────

enum PaymentMethod {
  cash(0, 'نقداً'),
  bankTransfer(1, 'تحويل بنكي'),
  creditCard(2, 'بطاقة ائتمانية'),
  check(3, 'شيك');

  const PaymentMethod(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static PaymentMethod fromValue(int value) =>
      PaymentMethod.values.firstWhere(
        (e) => e.value == value,
        orElse: () => PaymentMethod.cash,
      );
}

// ─── Status Color Extensions ───

extension InvoiceStatusColor on InvoiceStatus {
  Color get color {
    switch (this) {
      case InvoiceStatus.draft:
        return Colors.grey;
      case InvoiceStatus.sent:
        return const Color(0xFF0984E3); // Sleek blue
      case InvoiceStatus.paid:
        return const Color(0xFF00B894); // Premium green
      case InvoiceStatus.partial:
        return const Color(0xFFF39C12); // Premium orange
      case InvoiceStatus.overdue:
        return const Color(0xFFD63031); // Premium red
      case InvoiceStatus.cancelled:
        return Colors.grey;
    }
  }
}

extension ProjectStatusColor on ProjectStatus {
  Color get color {
    switch (this) {
      case ProjectStatus.planning:
        return const Color(0xFF9B59B6); // Premium purple
      case ProjectStatus.active:
        return const Color(0xFF0984E3); // Sleek blue
      case ProjectStatus.onHold:
        return const Color(0xFFF1C40F); // Premium amber/yellow
      case ProjectStatus.completed:
        return const Color(0xFF00B894); // Premium green
      case ProjectStatus.cancelled:
        return Colors.grey;
    }
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// RVIOS Platform Enums — Multi-Tenant, Accounts, Modules
// ═════════════════════════════════════════════════════════════════════════════

// ─────────────────────────────────────────────
// Account Type
// ─────────────────────────────────────────────

/// نوع حساب المستخدم في منصة RVIOS
enum AccountType {
  /// شخصي مجاني — Free Personal (tasks, meetings, notes only)
  freePersonal(0, 'شخصي مجاني', 'Free'),

  /// محترف — Professional (solo business, finance, projects)
  professional(1, 'محترف', 'Professional'),

  /// أعمال — Business (company, employees, HRM)
  business(2, 'أعمال', 'Business'),

  /// مؤسسي — Enterprise (multi-branch, API, SSO)
  enterprise(3, 'مؤسسي', 'Enterprise');

  const AccountType(this.value, this.arabicLabel, this.englishLabel);
  final int value;
  final String arabicLabel;
  final String englishLabel;

  static AccountType fromValue(int value) =>
      AccountType.values.firstWhere(
        (e) => e.value == value,
        orElse: () => AccountType.freePersonal,
      );
}

// ─────────────────────────────────────────────
// Plan Type (for Companies)
// ─────────────────────────────────────────────

/// نوع باقة الشركة على المنصة
enum PlanType {
  freePersonal(0, 'مجاني', 1),
  professional(1, 'محترف', 1),
  business(2, 'أعمال', 20),
  businessPlus(3, 'أعمال بلس', 100),
  enterprise(4, 'مؤسسي', -1); // -1 = unlimited

  const PlanType(this.value, this.arabicLabel, this.maxUsers);
  final int value;
  final String arabicLabel;
  final int maxUsers; // -1 = unlimited

  bool get isUnlimited => maxUsers == -1;

  static PlanType fromValue(int value) =>
      PlanType.values.firstWhere(
        (e) => e.value == value,
        orElse: () => PlanType.freePersonal,
      );
}

// ─────────────────────────────────────────────
// Subscription Status
// ─────────────────────────────────────────────

enum SubscriptionStatus {
  trial(0, 'تجريبي'),
  active(1, 'نشط'),
  suspended(2, 'موقوف'),
  cancelled(3, 'ملغي');

  const SubscriptionStatus(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static SubscriptionStatus fromValue(int value) =>
      SubscriptionStatus.values.firstWhere(
        (e) => e.value == value,
        orElse: () => SubscriptionStatus.trial,
      );
}

// ─────────────────────────────────────────────
// User Role (in a Company)
// ─────────────────────────────────────────────

/// دور المستخدم داخل الشركة
enum UserRole {
  /// مالك الشركة — Owner (all permissions, cannot be removed)
  owner(0, 'المالك', 'Owner'),

  /// مدير عام — Super Admin
  superAdmin(1, 'مدير عام', 'Super Admin'),

  /// مدير — Admin
  admin(2, 'مدير', 'Admin'),

  /// مدير تنفيذي — Executive Manager
  executive(3, 'مدير تنفيذي', 'Executive'),

  /// مدير موارد بشرية — HR Manager
  hrManager(4, 'مدير الموارد البشرية', 'HR Manager'),

  /// مدير مالي — Finance Manager
  financeManager(5, 'المدير المالي', 'Finance Manager'),

  /// مدير قسم — Department Manager
  deptManager(6, 'مدير القسم', 'Dept. Manager'),

  /// قائد فريق — Team Leader
  teamLeader(7, 'قائد الفريق', 'Team Leader'),

  /// موظف — Employee
  employee(8, 'موظف', 'Employee'),

  /// زائر — Guest (read-only)
  guest(9, 'زائر', 'Guest');

  const UserRole(this.value, this.arabicLabel, this.englishLabel);
  final int value;
  final String arabicLabel;
  final String englishLabel;

  /// Whether this role can manage other users
  bool get canManageUsers => value <= 2;

  /// Whether this role has HR module access
  bool get hasHrAccess => value <= 4;

  /// Whether this role has Finance module access
  bool get hasFinanceAccess => value <= 5 && value != 4;

  /// Whether this role is a company owner
  bool get isOwner => value == 0;

  /// Role level — same as value; lower = higher privilege (0=owner, 9=guest)
  int get level => value;

  static UserRole fromValue(int value) =>
      UserRole.values.firstWhere(
        (e) => e.value == value,
        orElse: () => UserRole.employee,
      );
}

// ─────────────────────────────────────────────
// App Modules
// ─────────────────────────────────────────────

/// وحدات منصة RVIOS — يمكن تفعيل/تعطيل كل وحدة حسب الباقة والصلاحية
enum AppModule {
  // ── Free Personal ─────────────────────────
  dashboard('dashboard', 'لوحة التحكم', 0),
  tasks('tasks', 'المهام', 0),
  meetings('meetings', 'الاجتماعات', 0),
  calendar('calendar', 'التقويم', 0),
  notes('notes', 'الملاحظات', 0),
  archive('archive', 'الأرشيف', 0),
  reminders('reminders', 'التذكيرات', 0),

  // ── Professional ──────────────────────────
  finance('finance', 'الشؤون المالية', 1),
  projects('projects', 'المشاريع', 1),
  clients('clients', 'العملاء', 1),
  invoices('invoices', 'الفواتير', 1),
  reports('reports', 'التقارير', 1),

  // ── Business ──────────────────────────────
  hrm('hrm', 'الموارد البشرية', 2),
  payroll('payroll', 'الرواتب', 2),
  attendance('attendance', 'الحضور والانصراف', 2),
  followUps('follow_ups', 'المتابعات', 2),
  directives('directives', 'التوجيهات', 2),
  approvals('approvals', 'الموافقات', 2),
  contacts('contacts', 'جهات الاتصال', 2),

  // ── Enterprise ────────────────────────────
  branches('branches', 'الفروع', 3),
  auditLogs('audit_logs', 'سجلات التدقيق', 3),
  api('api', 'API', 3),
  sso('sso', 'SSO', 3);

  const AppModule(this.key, this.arabicLabel, this.minPlanIndex);
  final String key;
  final String arabicLabel;

  /// Minimum plan index required (0=Free, 1=Pro, 2=Business, 3=Enterprise)
  final int minPlanIndex;

  /// Whether this module is available for the given plan
  bool isAvailableFor(PlanType plan) => plan.value >= minPlanIndex;

  static AppModule? fromKey(String key) {
    try {
      return AppModule.values.firstWhere((m) => m.key == key);
    } catch (_) {
      return null;
    }
  }
}

// ─────────────────────────────────────────────
// Entity Link Type — نوع الكيان في الربط الشامل
// ─────────────────────────────────────────────

/// نوع الكيان في جدول [EntityLinks] وفي `FollowUps.linkedEntityType`.
///
/// هذا **المصدر الوحيد** لترقيم أنواع الكيانات. كان يسكن داخل ملف widget،
/// وهو تعداد مجال لا عرض.
///
/// ⚠ لا يُخلط مع [FollowUpEntityType]: ذاك ترقيم قديم مختلف يخصّ العمود
/// `FollowUps.entityType` وحده، وفيه `meeting = 0` بينما هنا `meeting = 1`.
/// العمودان يحملان معنيين مختلفين ولا يُترجم أحدهما إلى الآخر ضمنيًا.
enum EntityLinkType {
  none(0, 'غير محدد'),
  meeting(1, 'اجتماع'),
  followup(2, 'متابعة'),
  client(3, 'عميل'),
  project(4, 'مشروع'),
  employee(5, 'موظف'),
  invoice(6, 'فاتورة'),
  expense(7, 'مصروف'),
  revenue(8, 'إيراد'),
  contract(9, 'عقد'),
  directive(10, 'توجيه'),
  contact(11, 'جهة اتصال'),
  supplier(12, 'مورد'),
  document(13, 'مستند'),
  appointment(14, 'موعد'),
  note(15, 'ملاحظة'),
  other(16, 'أخرى');

  const EntityLinkType(this.value, this.label);
  final int value;
  final String label;

  static EntityLinkType fromValue(int v) => EntityLinkType.values.firstWhere(
        (e) => e.value == v,
        orElse: () => EntityLinkType.other,
      );
}

// ─────────────────────────────────────────────
// Invitation Status
// ─────────────────────────────────────────────

enum InvitationStatus {
  pending(0, 'معلق'),
  accepted(1, 'مقبول'),
  expired(2, 'منتهي الصلاحية'),
  cancelled(3, 'ملغي');

  const InvitationStatus(this.value, this.arabicLabel);
  final int value;
  final String arabicLabel;

  static InvitationStatus fromValue(int value) =>
      InvitationStatus.values.firstWhere(
        (e) => e.value == value,
        orElse: () => InvitationStatus.pending,
      );
}
