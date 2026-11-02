@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:azm/core/utils/arabic_numerals.dart';

/// الأرقام العربية في العرض.
///
/// نظير [arabic_normalizer] في الاتجاه المعاكس: ذاك يوحّد إلى اللاتينية
/// قبل البحث، وهذا يعرّب قبل العرض. خلطهما يعني إمّا بحثًا لا يطابق
/// وإمّا واجهةً تخلط نظامي ترقيم في السطر الواحد.
void main() {
  group('toArabicDigits', () {
    test('يحوّل الأرقام اللاتينية إلى هندية', () {
      expect(toArabicDigits('0123456789'), '٠١٢٣٤٥٦٧٨٩');
    });

    test('يترك الحروف وعلامات الترقيم كما هي', () {
      expect(toArabicDigits('22 جمادى الأولى 1448 هـ'), '٢٢ جمادى الأولى ١٤٤٨ هـ');
      expect(toArabicDigits('آخر 6 أشهر'), 'آخر ٦ أشهر');
      expect(toArabicDigits('75%'), '٧٥٪'.replaceAll('٪', '%'));
    });

    test('آمن على النصّ الخالي والمعرَّب أصلًا', () {
      expect(toArabicDigits(''), '');
      expect(toArabicDigits('٢٠٢٦'), '٢٠٢٦');
      expect(toArabicDigits('بلا أرقام'), 'بلا أرقام');
    });
  });

  group('arabicCount — قواعد العدد', () {
    String days(int n) => arabicCount(
          n,
          one: 'يوم',
          two: 'يومين',
          few: 'أيام',
          many: 'يومًا',
        );

    test('الواحد لا يُعدّ', () {
      expect(days(1), 'يوم');
    });

    test('الاثنان صيغة مثنّى بلا رقم', () {
      expect(days(2), 'يومين');
    });

    test('٣ إلى ١٠ تأخذ جمع القلّة', () {
      expect(days(3), '٣ أيام');
      expect(days(10), '١٠ أيام');
    });

    test('١١ فصاعدًا تعود إلى المفرد — وهو ما كسرته الصيغة القديمة', () {
      expect(days(11), '١١ يومًا');
      expect(days(25), '٢٥ يومًا');
    });

    test('العبرة بخانة الآحاد لا بالعدد كلّه', () {
      expect(days(103), '١٠٣ أيام');
      expect(days(111), '١١١ يومًا');
    });

    test('الصفر يأخذ صيغة المفرد', () {
      expect(days(0), '٠ يومًا');
    });
  });
}
