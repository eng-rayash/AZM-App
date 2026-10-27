import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/providers/database_providers.dart';
import '../../features/company/providers/company_providers.dart';

/// AZM — سجلّ التدقيق
///
/// يجيب عن سؤال واحد بعد وقوع الحدث: **من فعل ماذا، متى، وبأي سياق؟**
///
/// جدول `AuditLogs` و`CompaniesDao.logAction` كانا موجودين منذ v11 بلا
/// مستدعٍ واحد — ولم يكن ممكنًا استدعاؤهما أصلًا: العمودان
/// `actorSyncId` و`companySyncId` إلزاميّان، ولا التطبيق يكتب مستخدمًا
/// محليًا ولا شركةً. هذه الطبقة تحلّ السياق وتوفّر بديلًا صريحًا حين
/// يغيب، بدل أن يُترك النداء مستحيلًا.
///
/// ⚠ التدقيق **يتبع** الكتابة ولا يحرسها: إخفاقه لا يُفشل العملية
/// الأصلية. سجلّ ناقص أهون من فاتورة لم تُحفظ لأن سطر تدقيق فشل.
///
/// الوجهة النهائية لهذه الطبقة هي سجلّ الإجراءات في المرحلة ٤، حيث
/// يصير التدقيق تلقائيًا لكل إجراء مسجَّل بدل استدعاء يدوي عند كل كتابة.
class AuditService {
  AuditService(
    this._db, {
    String Function()? resolveActor,
    String Function()? resolveTenant,
  })  : _resolveActor = resolveActor,
        _resolveTenant = resolveTenant;

  final AppDatabase _db;

  /// محلّلا السياق يُحقنان كدالتين لا كـ`Ref`.
  ///
  /// الاعتماد على `Ref` كان يربط الخدمة بشجرة Riverpod فيتعذّر
  /// اختبارها؛ والدالة تفصل «كيف يُعرف الفاعل» عن «كيف يُسجَّل الحدث».
  final String Function()? _resolveActor;
  final String Function()? _resolveTenant;

  /// معرّف يُستخدم حين لا يوجد مستخدم مسجَّل — الوضع الضيف/المحلي.
  ///
  /// سلسلة ثابتة بطول ٣٦ لتطابق قيد العمود، ومقروءة في قاعدة البيانات
  /// بدل صفر أو فراغ لا يدلّ على شيء.
  static const String localActor = 'local-device-user-------------------';

  /// معرّف يُستخدم حين لا توجد شركة نشطة — الوضع الشخصي.
  static const String personalTenant = 'personal-workspace------------------';

  // ─────────────────────────────────────────────
  // التسجيل
  // ─────────────────────────────────────────────

  /// يسجّل إجراءً.
  ///
  /// [action] يتبع نمط `<كيان>.<فعل>` — مثل `invoice.created` أو
  /// `data.wiped`. النمط نفسه الذي سيستخدمه سجلّ الإجراءات، فينتقل
  /// السجلّ إليه دون إعادة ترقيم.
  Future<void> log({
    required String action,
    String? entityType,
    String? entitySyncId,
    String? description,
    Map<String, dynamic>? oldValue,
    Map<String, dynamic>? newValue,
    AuditSeverity severity = AuditSeverity.info,
  }) async {
    try {
      await _db.companiesDao.logAction(
        actorSyncId: _actor(),
        companySyncId: _tenant(),
        action: action,
        entityType: entityType,
        entitySyncId: entitySyncId,
        description: description,
        oldValueJson: oldValue == null ? null : jsonEncode(oldValue),
        newValueJson: newValue == null ? null : jsonEncode(newValue),
        platform: _platform(),
        severity: severity.value,
      );
    } catch (e) {
      // لا يُعاد الرمي: التدقيق يتبع الكتابة ولا يحرسها.
      debugPrint('[Audit] تعذّر تسجيل "$action": $e');
    }
  }

  // ─────────────────────────────────────────────
  // حلّ السياق
  // ─────────────────────────────────────────────

  /// الفاعل: ما يعيده المحلّل، وإلا [localActor].
  String _actor() {
    try {
      final v = _resolveActor?.call();
      if (v != null && v.isNotEmpty) return v;
    } catch (_) {
      // المحلّل غير متاح — لا يمنع التسجيل
    }
    return localActor;
  }

  /// المستأجر: ما يعيده المحلّل، وإلا [personalTenant].
  ///
  /// لا شركة تُكتب في القاعدة اليوم لأن معالج الإنشاء محاكاة، فالقيمة
  /// الفعلية الآن هي البديل دائمًا. يتغيّر ذلك في المرحلة ٣.
  String _tenant() {
    try {
      final v = _resolveTenant?.call();
      if (v != null && v.isNotEmpty) return v;
    } catch (_) {
      // المحلّل غير متاح — لا يمنع التسجيل
    }
    return personalTenant;
  }

  String _platform() {
    if (kIsWeb) return 'web';
    return defaultTargetPlatform.name;
  }

  // ─────────────────────────────────────────────
  // القراءة
  // ─────────────────────────────────────────────

  /// آخر السجلات للمستأجر الحالي، الأحدث أولًا.
  Future<List<AuditLog>> recent({int limit = 100}) =>
      _db.companiesDao.getAuditLogs(_tenant(), limit: limit);
}

/// خطورة الحدث المسجَّل.
enum AuditSeverity {
  /// عملية اعتيادية — إنشاء، تعديل
  info(0),

  /// تستحق انتباهًا — تغيير صلاحية، تصدير بيانات
  warning(1),

  /// مدمِّرة أو حسّاسة — حذف شامل، اعتماد مالي
  critical(2);

  const AuditSeverity(this.value);
  final int value;
}

// ─────────────────────────────────────────────
// Provider
// ─────────────────────────────────────────────

final auditServiceProvider = Provider<AuditService>((ref) {
  return AuditService(
    ref.watch(databaseProvider),
    resolveActor: () => ref.read(currentUserSyncIdProvider) ?? '',
    resolveTenant: () => ref.read(activeCompanyProvider)?.syncId ?? '',
  );
});
