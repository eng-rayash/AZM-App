/// AZM — إعداد عنوان الخادم
///
/// العنوان يأتي من `--dart-define` وقت البناء لا من ملف في المستودع:
/// كل بيئة لها بناؤها، فلا يُشحن بناء إنتاج يشير إلى خادم تطوير.
///
/// ```sh
/// flutter run --dart-define=AZM_API_BASE_URL=http://10.0.2.2:3000
/// flutter build apk --dart-define=AZM_API_BASE_URL=https://api.azm.app
/// ```
///
/// ⚠ **لا سرّ هنا ولا يجوز أن يكون.** العنوان ليس سرًّا — أي من يملك
/// الحزمة يراه بالضرورة لأن الجهاز يتصل به. أما المفاتيح والرموز
/// السرّية فلا موضع لها في عميل Flutter أصلًا: `--dart-define` يُدمَج
/// في الثنائي ويُستخرج منه بأدوات عامّة، فهو إعداد لا خزانة.
library;

/// عنوان الخادم.
///
/// الافتراضي يخدم المحاكي: `10.0.2.2` هو مضيف الجهاز من داخل محاكي
/// أندرويد، و`localhost` هناك يعني المحاكي نفسه — خطأ شائع يُنتج
/// «لا اتصال» بلا سبب ظاهر.
const String apiBaseUrl = String.fromEnvironment(
  'AZM_API_BASE_URL',
  defaultValue: 'http://10.0.2.2:3000',
);

/// بادئة المسارات — تطابق `setGlobalPrefix` على الخادم.
const String apiPrefix = '/api/v1';

/// مهلة الطلب الواحد.
///
/// قصيرة عمدًا: التطبيق يعمل دون اتصال، فالفشل السريع والعودة إلى
/// البيانات المحلية أفضل من دوران مؤشّر نصف دقيقة. المزامنة تعيد
/// المحاولة، والمستخدم لا ينتظر.
const Duration apiTimeout = Duration(seconds: 15);

/// هل العنوان المضبوط غير آمن (HTTP لا HTTPS)؟
///
/// مقبول للتطوير على مضيف محلي، وغير مقبول لغيره: رمز الجلسة يمرّ في
/// الترويسة، وHTTP يعني أن أي وسيط على الشبكة يقرؤه.
bool get isInsecureRemoteBaseUrl {
  final uri = Uri.tryParse(apiBaseUrl);
  if (uri == null || uri.scheme == 'https') return false;

  const localHosts = {'localhost', '127.0.0.1', '10.0.2.2', '::1'};
  return !localHosts.contains(uri.host);
}
