/// AZM — الأرقام العربية في العرض
///
/// واجهة عزم عربية بالكامل، والتواريخ فيها كانت تخلط نظامي ترقيم في
/// السطر الواحد: «الاثنين ٢ نوفمبر ٢٠٢٦» ميلاديًّا بالأرقام الهندية،
/// و«22 جمادى الأولى 1448 هـ» هجريًّا بالأرقام اللاتينية — لأن `intl`
/// يعرّب أرقامه بينما حزمة `hijri` تعيدها خامًا.
///
/// هذا الملف للعرض وحده. نظيره [arabic_normalizer] يسير في الاتجاه
/// المعاكس — يوحّد الأرقام إلى اللاتينية قبل البحث — ولا يصحّ استعمال
/// أحدهما مكان الآخر: ما يُخزَّن ويُبحث فيه لاتيني، وما يُقرأ عربي.
library;

const _arabicIndicDigits = <String>[
  '٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩', //
];

/// يحوّل أرقام [input] اللاتينية (0-9) إلى هندية (٠-٩) ويترك ما عداها.
///
/// آمن على النصّ المختلط: الحروف وعلامات الترقيم والأرقام الهندية
/// الموجودة أصلًا تمرّ كما هي.
String toArabicDigits(String input) {
  if (input.isEmpty) return input;

  final buffer = StringBuffer();
  for (final rune in input.runes) {
    if (rune >= 0x30 && rune <= 0x39) {
      buffer.write(_arabicIndicDigits[rune - 0x30]);
    } else {
      buffer.writeCharCode(rune);
    }
  }
  return buffer.toString();
}

/// يصوغ «[count] [معدود]» على قواعد العدد العربية.
///
/// العربية لا تجمع كالإنجليزية: الواحد لا يُعدّ، والاثنان لهما صيغة
/// مثنّى، و٣–١٠ تأخذ جمع القلّة، و١١ فصاعدًا تعود إلى المفرد. وصيغة
/// `'$n أيام'` الشائعة تُخرج «1 أيام» و«11 أيام» وكلاهما خطأ.
///
/// ```dart
/// arabicCount(1, one: 'يوم', two: 'يومين', few: 'أيام', many: 'يومًا');
/// // → 'يوم'
/// arabicCount(5, one: 'يوم', two: 'يومين', few: 'أيام', many: 'يومًا');
/// // → '٥ أيام'
/// ```
String arabicCount(
  int count, {
  required String one,
  required String two,
  required String few,
  required String many,
}) {
  if (count == 1) return one;
  if (count == 2) return two;
  final n = toArabicDigits('$count');
  // جمع القلّة للعشرة فما دون، ثم المفرد المنصوب لما فوقها. العبرة
  // بخانة الآحاد: ١٠٣ تُعامل معاملة ٣ لا معاملة ١٠٣.
  final unit = count % 100;
  if (unit >= 3 && unit <= 10) return '$n $few';
  return '$n $many';
}
