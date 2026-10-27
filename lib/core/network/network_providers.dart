import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/providers/database_providers.dart';
import '../database/tenant_database.dart';
import '../../features/auth/data/azm_auth_api.dart';
import 'api_client.dart';
import 'auth_token_store.dart';

/// AZM — مزوّدات الشبكة
///
/// نقطة تجميع واحدة: من يحتاج الخادم يأخذ [azmAuthApiProvider] أو
/// [apiClientProvider]، ولا يبني عميلًا بنفسه. السبب عملي لا جمالي —
/// عميل يُبنى في مكانين يعني خزانتَي رموز، فيخرج المستخدم من واحدة
/// ويبقى داخلًا في الأخرى.
final authTokenStoreProvider = Provider<AuthTokenStore>((ref) {
  return AuthTokenStore();
});

/// هل انتهت الجلسة؟ تُرفع من [ApiClient] عند ٤٠١.
///
/// إشارة لا إجراء: العميل لا يعرف التوجيه، والطبقة التي تراقب هذه
/// القيمة هي التي تقرّر أين تذهب بالمستخدم.
final sessionExpiredProvider = StateProvider<bool>((ref) => false);

final apiClientProvider = Provider<ApiClient>((ref) {
  final client = ApiClient(
    tokens: ref.watch(authTokenStoreProvider),
    onUnauthenticated: () {
      // `read` لا `watch`: لا نريد إعادة بناء العميل حين تتغيّر الراية
      ref.read(sessionExpiredProvider.notifier).state = true;
    },
  );
  ref.onDispose(client.close);
  return client;
});

final azmAuthApiProvider = Provider<AzmAuthApi>((ref) {
  return AzmAuthApi(ref.watch(apiClientProvider));
});

// ─────────────────────────────────────────────
// اعتماد الجلسة
// ─────────────────────────────────────────────

/// متحكّم الجلسة — اعتمادها وإنهاؤها.
///
/// صنف لا دالتان حرّتان: الدالة الحرّة تحتاج `Ref`، والودجت يملك
/// `WidgetRef` ولا يتحوّل أحدهما إلى الآخر. المتحكّم يُقرأ من
/// الاثنين بلا تمييز.
class SessionController {
  SessionController(this._ref);

  final Ref _ref;

  /// يُفعّل جلسةً جديدة: يحفظ الرمز، ثم يفتح ملف قاعدة الشركة.
  ///
  /// الترتيب ليس اعتباطيًا. الرمز أولًا لأن أي طلب يتبع يحتاجه؛
  /// وتبديل المستأجر أخيرًا لأنه يُغلق القاعدة ويُعيد بناء شجرة
  /// المزوّدات — فأي عمل بعده في هذه الدالة يجري على نسخة مُهمَلة.
  ///
  /// والضمّ في نداء واحد مقصود: رمز محفوظ بلا تبديل مستأجر يعني أن
  /// التطبيق يكتب بيانات شركة في ملف شركة أخرى. تسريب لا يكشفه
  /// اختبار واجهة.
  Future<void> adopt({
    required String accessToken,
    required String companyId,
  }) async {
    await _ref.read(authTokenStoreProvider).save(
          token: accessToken,
          companyId: companyId,
        );
    _ref.read(sessionExpiredProvider.notifier).state = false;
    await _ref.read(activeTenantIdProvider.notifier).switchTo(companyId);
  }

  /// يُخرج المستخدم: يمحو الرمز ويعود إلى الملف الشخصي.
  ///
  /// **لا يمحو بيانات الشركة.** الخروج قد يكون لأن الرمز انتهى لا لأن
  /// المستخدم أراد، وتعديلات لم تُزامَن بعد تضيع لو مُحيت. الملف يبقى،
  /// ويعود المستخدم إليه عند الدخول.
  Future<void> end() async {
    await _ref.read(authTokenStoreProvider).clear();
    await _ref.read(activeTenantIdProvider.notifier).switchTo(personalTenant);
    _ref.read(sessionExpiredProvider.notifier).state = false;
  }
}

final sessionControllerProvider = Provider<SessionController>((ref) {
  return SessionController(ref);
});
