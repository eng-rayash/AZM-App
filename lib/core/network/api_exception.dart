/// AZM — أخطاء الشبكة، مصنَّفة بما يُفعل بها
///
/// التصنيف ليس ترفًا توثيقيًا: محرّك المزامنة يتصرّف بحسب **نوع**
/// الفشل لا بحسب وقوعه.
///
///   • انقطاع اتصال → أعد المحاولة لاحقًا، ولا تُزعج المستخدم. هذا
///     الوضع الطبيعي لتطبيق يعمل دون اتصال، لا حالة خطأ.
///   • ٤xx → **لا** تُعد المحاولة. الطلب نفسه معطوب، وإعادته ألف مرة
///     تعطي النتيجة نفسها وتستهلك البطارية.
///   • ٥xx → أعد المحاولة بتباطؤ أُسّي. الخادم متعب لا الطلب خاطئ.
///   • ٤٠٩ → لا إعادة ولا تجاهل: أعد الجلب وادمج. هذه حالة ثالثة
///     قائمة بذاتها، وخلطها بـ٤xx يجعل المزامنة تُسقط تعديلًا صامتًا.
///   • ٤٠١ → الرمز انتهى أو سُحب. أخرج المستخدم، ولا تُعد المحاولة
///     بالرمز نفسه.
library;

/// أصل كل أخطاء الطبقة.
sealed class ApiException implements Exception {
  const ApiException(this.message);

  /// رسالة عربية صالحة للعرض.
  ///
  /// الخادم يردّ بالعربية أصلًا، فنمرّر رسالته حين توجد بدل أن نخترع
  /// رسالة عامّة تُخفي السبب الحقيقي.
  final String message;

  /// هل تُجدي إعادة المحاولة بالطلب نفسه؟
  bool get isRetryable;

  @override
  String toString() => '$runtimeType: $message';
}

/// تعذّر الوصول إلى الخادم — لا شبكة، أو مهلة، أو اسم مضيف لا يُحلّ.
///
/// ليست خطأً في تطبيق يعمل دون اتصال. الواجهة تعرضها «غير متزامن» لا
/// «فشل»، والمزامنة تؤجّل.
final class NetworkUnreachable extends ApiException {
  const NetworkUnreachable([super.message = 'لا اتصال بالخادم']);

  @override
  bool get isRetryable => true;
}

/// الخادم ردّ بخطأ في الطلب (٤٠٠، ٤٢٢، …).
///
/// [fieldErrors] يحمل أخطاء التحقّق حين يرسلها الخادم، فتُعرض عند
/// الحقل المعني بدل رسالة واحدة لا تدلّ على موضع العطب.
final class BadRequest extends ApiException {
  const BadRequest(super.message, {this.fieldErrors = const []});

  final List<String> fieldErrors;

  @override
  bool get isRetryable => false;
}

/// الرمز غائب أو منتهٍ أو مسحوب.
final class Unauthenticated extends ApiException {
  const Unauthenticated([super.message = 'انتهت الجلسة — سجّل الدخول']);

  @override
  bool get isRetryable => false;
}

/// مُصادَق عليه لكن الصلاحية لا تكفي.
///
/// تختلف عن [NotFound] عمدًا: الخادم يعيد «غير موجود» لسجلّ شركة أخرى
/// كي لا يكشف وجوده، و«ممنوع» لسجلّ في شركتك لا يحقّ لك. الفارق
/// معنوي للمستخدم: الأولى خطأ في المعرّف، والثانية طلب ترقية صلاحية.
final class Forbidden extends ApiException {
  const Forbidden([super.message = 'صلاحيتك لا تكفي لهذا الإجراء']);

  @override
  bool get isRetryable => false;
}

/// السجلّ غير موجود — أو ليس في نطاق شركتك، ولا نفرّق.
final class NotFound extends ApiException {
  const NotFound([super.message = 'السجلّ غير موجود']);

  @override
  bool get isRetryable => false;
}

/// تعارض نسخ — جهاز آخر عدّل السجلّ أولًا.
///
/// حالة ثالثة لا نجاح ولا فشل: أعد الجلب وادمج. [currentVersion]
/// و[expectedVersion] يأتيان من الخادم ليعرف الدمج على ماذا يبني.
final class VersionConflict extends ApiException {
  const VersionConflict(
    super.message, {
    required this.currentVersion,
    required this.expectedVersion,
  });

  final int currentVersion;
  final int expectedVersion;

  /// لا تُعد المحاولة بالحمولة نفسها — ستتعارض مرة أخرى.
  @override
  bool get isRetryable => false;
}

/// البريد أو الكود مستخدَم بالفعل.
final class AlreadyExists extends ApiException {
  const AlreadyExists(super.message);

  @override
  bool get isRetryable => false;
}

/// خطأ في الخادم (٥xx) — أعد المحاولة بتباطؤ.
final class ServerFailure extends ApiException {
  const ServerFailure([super.message = 'خطأ في الخادم — جرّب لاحقًا']);

  @override
  bool get isRetryable => true;
}

/// ردّ لم نتوقّعه: حالة غير مُعالَجة، أو جسم ليس JSON صالحًا.
///
/// لا تُبتلع ولا تُعاد: ردّ غير متوقَّع يعني إمّا خادمًا بإصدار أحدث
/// وإمّا وسيطًا يعترض الطلب. كلاهما يستحقّ الظهور لا التجاهل.
final class UnexpectedResponse extends ApiException {
  const UnexpectedResponse(super.message, {this.statusCode});

  final int? statusCode;

  @override
  bool get isRetryable => false;
}
