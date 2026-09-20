/// AZM — التطبيع العربي
///
/// نظير `api/src/common/text/normalize-arabic.ts` على العميل.
///
/// ⚠ **الملفّان يجب أن يبقيا متطابقَي السلوك.** البحث دون اتصال يمرّ
/// على SQLite محليًا، وبه اتصال يمرّ على PostgreSQL. أي اختلاف بين
/// التنفيذين يعني أن الاستعلام نفسه يعطي نتيجتين مختلفتين حسب حالة
/// الشبكة — وهو عطب يصعب تفسيره للمستخدم ويصعب تتبّعه.
///
/// اختبارات `test/arabic_normalizer_test.dart` تحمل الحالات نفسها
/// الموجودة في `normalize-arabic.spec.ts` عمدًا.
///
/// ## لماذا يلزم أصلًا
///
/// البحث القائم `LIKE '%q%'` على الاسم الخام يفشل على العربية فشلًا
/// صامتًا: «احمد» لا يطابق «أحمد»، و«شركه» لا تطابق «شركة»، و«مصطفي»
/// لا يطابق «مصطفى». المستخدم يرى نتيجة فارغة ويظنّ أن السجلّ غير
/// موجود، ولا شيء يشير إلى أن السبب إملائي.
library;

/// تشكيل وعلامات إضافية تُحذف كليًّا.
final _diacritics = RegExp(r'[ً-ٰٟۖ-ۭ]');

/// تطويل الكلمة — زخرفة لا تحمل معنى.
final _tatweel = RegExp('ـ');

/// صور الألف التي تُوحَّد: آ أ إ ٱ
final _alefForms = RegExp(r'[آأإٱ]');

final _arabicIndic = RegExp(r'[٠-٩]');
final _extendedIndic = RegExp(r'[۰-۹]');
final _whitespace = RegExp(r'\s+');

/// يطبّع نصًّا عربيًا للبحث والمطابقة.
///
/// ما يفعله بالترتيب: حذف التشكيل والتطويل · توحيد الألف والتاء
/// المربوطة والألف المقصورة والهمزات · تحويل الأرقام الهندية إلى
/// لاتينية · خفض اللاتينية · ضغط المسافات.
///
/// ما لا يفعله عمدًا: لا يحذف «ال» التعريف. «الرياض» و«رياض» اسمان
/// مختلفان، ودمجهما يخلط شركات منفصلة.
String normalizeArabic(String input) {
  if (input.isEmpty) return '';

  return input
      .replaceAll(_diacritics, '')
      .replaceAll(_tatweel, '')
      .replaceAll(_alefForms, 'ا') // ← ا
      .replaceAll('ة', 'ه') // ة ← ه
      .replaceAll('ى', 'ي') // ى ← ي
      .replaceAll('ؤ', 'و') // ؤ ← و
      .replaceAll('ئ', 'ي') // ئ ← ي
      .replaceAllMapped(
        _arabicIndic,
        (m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) - 0x0660 + 48),
      )
      .replaceAllMapped(
        _extendedIndic,
        (m) => String.fromCharCode(m.group(0)!.codeUnitAt(0) - 0x06F0 + 48),
      )
      .toLowerCase()
      .replaceAll(_whitespace, ' ')
      .trim();
}

/// هل يطابق [needle] النصَّ [haystack] بعد التطبيع؟
///
/// مطابقة احتواء لا تساوٍ: المستخدم يكتب «سحبكم» ويقصد «شركة سحبكم
/// للتجارة».
bool matchesNormalized(String haystack, String needle) {
  final n = normalizeArabic(needle);
  if (n.isEmpty) return false;
  return normalizeArabic(haystack).contains(n);
}

/// يصفّي صفوفًا بالمطابقة المطبَّعة على عدّة حقول.
///
/// نقطة الاختناق الوحيدة للبحث: كل `search` في طبقة DAO يمرّ من هنا،
/// فلا يبقى في المشروع مكانان يطبّقان قواعد مطابقة مختلفة.
///
/// ## لماذا التصفية في Dart لا في SQL
///
/// التطبيع في SQL يحتاج أحد أمرين: عمودًا مطبَّعًا مخزَّنًا يُحدَّث مع
/// كل كتابة، أو دالة SQLite مخصَّصة. الأول يضيف مسار كتابة يمكن
/// نسيانه — وهو أخطر أنواع العطب لأنه يظهر بعد أشهر على صفوف قديمة
/// فقط. والثاني لا يتوفّر على الويب: `sqlite3.createFunction` غير
/// متاح في بناء WASM، فيصير البحث يعمل على الهاتف ويفشل على المتصفّح.
///
/// التصفية هنا تقرأ صفوف المستأجر النشطة ثم تطابق في الذاكرة. الكلفة
/// مقبولة لأن القاعدة محلية ولمستأجر واحد؛ حين تتجاوز جداولها عشرات
/// الآلاف من الصفوف يصير العمود المخزَّن هو الجواب — والخادم يفعل
/// ذلك بالفعل في `nameNormalized` لأن بياناته لكل المستأجرين.
///
/// [fields] تعيد الحقول القابلة للبحث في الصفّ؛ الفراغات تُتجاهل.
///
/// نصّ البحث الفارغ يعيد الصفوف كما هي لا قائمة فارغة: صندوق بحث لم
/// يُكتب فيه شيء يعني «اعرض الكل» لا «لا شيء يطابق».
List<T> filterNormalized<T>(
  Iterable<T> rows,
  String query,
  Iterable<String?> Function(T row) fields,
) {
  final needle = normalizeArabic(query);
  if (needle.isEmpty) return rows.toList();

  return rows.where((row) {
    for (final field in fields(row)) {
      if (field == null || field.isEmpty) continue;
      if (normalizeArabic(field).contains(needle)) return true;
    }
    return false;
  }).toList();
}
