@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';

import 'package:azm/core/utils/arabic_normalizer.dart';

/// التطبيع العربي على العميل.
///
/// الحالات هنا **مطابقة** لما في `api/src/common/text/normalize-arabic.spec.ts`
/// عمدًا: التنفيذان يجب أن يتصرّفا بالسلوك نفسه، لأن البحث دون اتصال
/// يمرّ على SQLite وبه اتصال يمرّ على PostgreSQL. انحراف أحدهما يجعل
/// الاستعلام نفسه يعطي نتيجتين حسب حالة الشبكة.
void main() {
  group('الهمزات — أكثر مصادر الفشل شيوعًا', () {
    test('يوحّد صور الألف', () {
      final target = normalizeArabic('أحمد');
      expect(normalizeArabic('احمد'), target);
      expect(normalizeArabic('إحمد'), target);
      expect(normalizeArabic('آحمد'), target);
    });

    test('«احمد» يطابق «أحمد» — كان يفشل', () {
      expect(matchesNormalized('أحمد العتيبي', 'احمد'), isTrue);
    });

    test('يوحّد الهمزة على الواو والياء', () {
      expect(normalizeArabic('مؤسسة'), normalizeArabic('موسسة'));
      expect(normalizeArabic('قائمة'), normalizeArabic('قايمة'));
    });
  });

  group('التاء المربوطة', () {
    test('«شركه» يطابق «شركة» — كان يفشل', () {
      expect(matchesNormalized('شركة سحبكم', 'شركه'), isTrue);
    });

    test('يوحّدها في آخر الكلمة', () {
      expect(normalizeArabic('مؤسسة'), normalizeArabic('مؤسسه'));
    });
  });

  group('الألف المقصورة', () {
    test('«مصطفي» يطابق «مصطفى» — كان يفشل', () {
      expect(matchesNormalized('مصطفى محمد', 'مصطفي'), isTrue);
    });
  });

  group('التشكيل والتطويل', () {
    test('يحذف التشكيل', () {
      expect(normalizeArabic('مُحَمَّد'), normalizeArabic('محمد'));
    });

    test('يحذف التطويل', () {
      expect(normalizeArabic('محـــمد'), normalizeArabic('محمد'));
    });
  });

  group('الأرقام', () {
    test('يحوّل العربية-الهندية إلى لاتينية', () {
      expect(normalizeArabic('فاتورة ١٢٣'), 'فاتوره 123');
    });

    test('يحوّل الفارسية أيضًا', () {
      expect(normalizeArabic('۴۵۶'), '456');
    });
  });

  group('المسافات', () {
    test('يضغط المتكرّرة ويقصّ الأطراف', () {
      expect(normalizeArabic('  شركة   سحبكم  '), 'شركه سحبكم');
    });
  });

  group('ما لا يفعله عمدًا', () {
    test('لا يحذف «ال» التعريف', () {
      // «الرياض» و«رياض» اسمان مختلفان؛ دمجهما يخلط شركات منفصلة
      expect(normalizeArabic('الرياض'), isNot(normalizeArabic('رياض')));
    });

    test('لا يطابق أسماء مختلفة فعلًا', () {
      expect(matchesNormalized('أحمد', 'محمد'), isFalse);
      expect(matchesNormalized('شركة النور', 'شركة الفجر'), isFalse);
    });
  });

  group('الحالات الحدّية', () {
    test('النصّ الفارغ لا يرمي', () {
      expect(normalizeArabic(''), '');
      expect(matchesNormalized('أحمد', ''), isFalse);
    });

    test('اللاتينية تُخفَّض', () {
      expect(normalizeArabic('AZM Corp'), 'azm corp');
      expect(matchesNormalized('AZM Corp', 'azm'), isTrue);
    });

    test('الخليط العربي اللاتيني يعمل', () {
      expect(matchesNormalized('شركة AZM للتقنية', 'azm'), isTrue);
    });
  });
}
