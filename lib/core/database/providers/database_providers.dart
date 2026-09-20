import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../app_database.dart';
import '../tenant_database.dart';
import '../dao/app_settings_dao.dart';
import '../dao/directives_dao.dart';
import '../dao/follow_ups_dao.dart';
import '../dao/meetings_dao.dart';
import '../dao/security_logs_dao.dart';
import '../dao/tasks_dao.dart';
import '../dao/users_dao.dart';

/// المفتاح الذي يُحفظ تحته المستأجر النشط بين التشغيلات.
const String _activeTenantPrefsKey = 'azm.active_tenant';

/// المستأجر المفتوح حاليًا — مصدر الحقيقة لأي ملف قاعدة يُفتح.
///
/// يعيش **خارج** القاعدة عمدًا. لو كان مخزَّنًا فيها لاحتجنا أن نفتح
/// قاعدة لنعرف أي قاعدة نفتح.
class ActiveTenantNotifier extends StateNotifier<String> {
  ActiveTenantNotifier([super.initial = personalTenant]);

  /// يبدّل المستأجر **ويحفظه** في نداء واحد.
  ///
  /// الضمّ مقصود: لو كان التبديل خطوة والحفظ أخرى، لوُجد مسار يبدّل
  /// دون أن يحفظ — فتعود الجلسة التالية إلى الشخصي ويبدو للمستخدم أن
  /// بيانات شركته ضاعت. نفس شكل العطب الذي أزاله اشتقاق الدور.
  ///
  /// التبديل يُغلق القاعدة الحالية ويفتح ملفًّا آخر، فتُعاد بناء كل
  /// المزوّدات المشتقّة من [databaseProvider]. وهذا هو المقصود: ما
  /// كان معروضًا من الشركة السابقة يختفي لأنه لم يعد موجودًا، لا لأن
  /// مرشّحًا أخفاه.
  Future<void> switchTo(String tenantId) async {
    state = tenantId;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_activeTenantPrefsKey, tenantId);
    } catch (e) {
      // الحفظ فشل والتبديل وقع: الجلسة الحالية صحيحة، والتشغيل
      // التالي يعود للشخصي. أهون من منع التبديل.
      debugPrint('[AZM] تعذّر حفظ المستأجر النشط: $e');
    }
  }
}

final activeTenantIdProvider =
    StateNotifierProvider<ActiveTenantNotifier, String>((ref) {
  return ActiveTenantNotifier();
});

/// يقرأ المستأجر المحفوظ. يُستدعى مرة عند الإقلاع قبل `runApp`،
/// وتُمرَّر نتيجته إلى [activeTenantIdProvider] عبر تجاوز.
Future<String> loadActiveTenant() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_activeTenantPrefsKey);
    return (saved == null || saved.isEmpty) ? personalTenant : saved;
  } catch (_) {
    // تفضيلات غير متاحة — الوضع الشخصي بديل سليم لا تعطّل
    return personalTenant;
  }
}

/// قاعدة المستأجر النشط — **ملف لكل شركة**.
///
/// العزل هنا حقيقة في نظام الملفات: ما ليس في الملف المفتوح غير
/// موجود، فلا استعلام يحتاج مرشّح شركة ولا سبيل لنسيانه. انظر
/// `tenant_database.dart` للمقايضة كاملة.
final databaseProvider = Provider<AppDatabase>((ref) {
  final tenantId = ref.watch(activeTenantIdProvider);
  final db = AppDatabase.forTenant(tenantId);
  ref.onDispose(db.close);
  return db;
});

/// قاعدة السجلّ — الشركات والعضويات، أي «ما هي الشركات المتاحة».
///
/// تبقى دائمًا الملف الشخصي مهما كانت الشركة النشطة، للسبب نفسه الذي
/// أخرج [activeTenantIdProvider] من القاعدة: لو كانت قائمة الشركات
/// داخل ملف الشركة، لاحتجنا أن نعرف الشركة لنعرف الشركات.
///
/// في الوضع الشخصي هي **النسخة نفسها** لا نسخة ثانية: اتصالان
/// بالملف ذاته يتنازعان القفل ويضاعفان التدفّقات.
final registryDatabaseProvider = Provider<AppDatabase>((ref) {
  final tenantId = ref.watch(activeTenantIdProvider);
  if (tenantId == personalTenant) return ref.watch(databaseProvider);

  final db = AppDatabase.forTenant(personalTenant);
  ref.onDispose(db.close);
  return db;
});

/// DAO Providers
final usersDaoProvider = Provider<UsersDao>((ref) {
  return ref.watch(databaseProvider).usersDao;
});

final meetingsDaoProvider = Provider<MeetingsDao>((ref) {
  return ref.watch(databaseProvider).meetingsDao;
});

final securityLogsDaoProvider = Provider<SecurityLogsDao>((ref) {
  return ref.watch(databaseProvider).securityLogsDao;
});

final appSettingsDaoProvider = Provider<AppSettingsDao>((ref) {
  return ref.watch(databaseProvider).appSettingsDao;
});

final tasksDaoProvider = Provider<TasksDao>((ref) {
  return ref.watch(databaseProvider).tasksDao;
});

final followUpsDaoProvider = Provider<FollowUpsDao>((ref) {
  return ref.watch(databaseProvider).followUpsDao;
});

final directivesDaoProvider = Provider<DirectivesDao>((ref) {
  return ref.watch(databaseProvider).directivesDao;
});

// Phase 3
final archiveDaoProvider = Provider((ref) => ref.watch(databaseProvider).archiveDao);
final appointmentsDaoProvider = Provider((ref) => ref.watch(databaseProvider).appointmentsDao);
final contactsDaoProvider = Provider((ref) => ref.watch(databaseProvider).contactsDao);

// Phase 4
final callsDaoProvider = Provider((ref) => ref.watch(databaseProvider).callsDao);
final visitorsDaoProvider = Provider((ref) => ref.watch(databaseProvider).visitorsDao);
final notesDaoProvider = Provider((ref) => ref.watch(databaseProvider).notesDao);