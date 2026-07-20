/// Core Constants & Enums for the Mudiri Application
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
      MeetingStatus.values.firstWhere((e) => e.value == value);
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
      MeetingType.values.firstWhere((e) => e.value == value);
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
      UnifiedStatus.values.firstWhere((e) => e.value == value);
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
      Priority.values.firstWhere((e) => e.value == value);
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
      SecurityAction.values.firstWhere((e) => e.value == value);
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
      AuthMethod.values.firstWhere((e) => e.value == value);
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
