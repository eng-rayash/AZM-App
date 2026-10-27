@TestOn('vm')
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:azm/core/network/api_exception.dart';
import 'package:azm/features/shop/data/shop_models.dart';
import 'package:azm/features/shop/presentation/stores_screen.dart';
import 'package:azm/features/shop/presentation/widgets/shop_async.dart';
import 'package:azm/features/shop/providers/shop_providers.dart';

/// شاشات المتاجر — الحالات التي تُعرض لا المسار السعيد وحده.
///
/// الاختبار الأهمّ هنا هو **انقطاع الاتصال**: شاشات المتاجر تقرأ من
/// الخادم مباشرة بلا نسخة محلية، فانقطاع الشبكة يجب أن يُقال صراحةً.
/// البديل الذي كان سيقع: قائمة فارغة يقرؤها التاجر «لا طلبات»
/// فيطمئنّ — وعنده طلبات تنتظر.
void main() {
  Widget host(Widget child, List<Override> overrides) => ProviderScope(
        overrides: overrides,
        child: MaterialApp(
          locale: const Locale('ar'),
          home: Directionality(
            textDirection: TextDirection.rtl,
            child: child,
          ),
        ),
      );

  StoreList listWith({
    required List<ShopStore> stores,
    required int slots,
  }) =>
      StoreList(
        stores: stores,
        slots: StoreSlots(
          owned: stores.length,
          slots: slots,
          free: slots - stores.length,
          max: slots,
        ),
      );

  ShopStore store({
    String id = 'store-1',
    String name = 'دار العود',
    String slug = 'dar-aloud',
    String plan = 'basic',
    int status = 0,
  }) =>
      ShopStore(
        id: id,
        slug: slug,
        name: name,
        sector: 'perfumes',
        plan: plan,
        status: status,
        verified: false,
        country: 'SA',
        currency: 'ر.س',
      );

  group('قائمة المتاجر', () {
    testWidgets('تعرض المتجر ورابطه وباقته', (tester) async {
      await tester.pumpWidget(host(
        const StoresScreen(),
        [
          storeListProvider.overrideWith(
            (ref) async => listWith(stores: [store()], slots: 1),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('دار العود'), findsOneWidget);
      // الرابط هوية المتجر العامّة — يستحقّ الظهور
      expect(find.text('/dar-aloud'), findsOneWidget);
      expect(find.text('مجانية'), findsOneWidget);
    });

    testWidgets('لا متاجر: تقول ما يُفعل لا «فارغ»', (tester) async {
      await tester.pumpWidget(host(
        const StoresScreen(),
        [
          storeListProvider.overrideWith(
            (ref) async => listWith(stores: const [], slots: 1),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('لا متاجر بعد'), findsOneWidget);
      // `find.widgetWithText` لا يطابق مُنشئات `.icon`: تبني تسميتها
      // عبر ودجت داخلي فلا يصير الزرّ سلفًا للنصّ. النصّ والزرّ
      // كلٌّ على حدة — وهما ما يراه المستخدم ويلمسه.
      expect(find.text('متجر جديد'), findsOneWidget);
      // `byType` يطابق النوع بالضبط، و`FilledButton.icon` يعيد صنفًا
      // فرعيًا — فالمطابقة بالمُسنِد لا بالنوع.
      expect(
        find.byWidgetPredicate((w) => w is FilledButton),
        findsOneWidget,
      );
    });

    testWidgets('الحصّة ممتلئة: لا زرّ إضافة، وسبب مكتوب', (tester) async {
      // الباقة المجانية خانة واحدة. زرّ يفشل عند الضغط يبدو كعطب في
      // التطبيق لا كحدّ في الباقة.
      await tester.pumpWidget(host(
        const StoresScreen(),
        [
          storeListProvider.overrideWith(
            (ref) async => listWith(stores: [store()], slots: 1),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_rounded), findsNothing);
      expect(
        find.textContaining('اشترِ خانة متجر إضافي'),
        findsOneWidget,
      );
    });

    testWidgets('حصّة متاحة: زرّ الإضافة يظهر', (tester) async {
      await tester.pumpWidget(host(
        const StoresScreen(),
        [
          storeListProvider.overrideWith(
            (ref) async => listWith(stores: [store()], slots: 3),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.add_rounded), findsWidgets);
      expect(find.textContaining('استعملتَ 1 من 3'), findsOneWidget);
    });

    testWidgets('المتجر الموقوف معلَّم', (tester) async {
      await tester.pumpWidget(host(
        const StoresScreen(),
        [
          storeListProvider.overrideWith(
            (ref) async => listWith(stores: [store(status: 1)], slots: 1),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('موقوف'), findsOneWidget);
    });
  });

  group('انقطاع الاتصال يُقال صراحةً', () {
    testWidgets('لا يُعرض فراغًا يُقرأ «لا متاجر»', (tester) async {
      await tester.pumpWidget(host(
        const StoresScreen(),
        [
          storeListProvider.overrideWith(
            (ref) async => throw const NetworkUnreachable(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('لا اتصال بالخادم'), findsOneWidget);
      // ولا يُقال «لا متاجر» — الفرق بين «لا بيانات» و«لم تُقرأ»
      expect(find.text('لا متاجر بعد'), findsNothing);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });

    testWidgets('يشرح لماذا لا نسخة محلية', (tester) async {
      await tester.pumpWidget(host(
        const StoresScreen(),
        [
          storeListProvider.overrideWith(
            (ref) async => throw const NetworkUnreachable(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('لحظةً بلحظة'), findsOneWidget);
    });
  });

  group('التصنيف يحكم ما يُعرض', () {
    testWidgets('٤٠١: لا إعادة محاولة — لا تُجدي', (tester) async {
      await tester.pumpWidget(host(
        const StoresScreen(),
        [
          storeListProvider.overrideWith(
            (ref) async => throw const Unauthenticated(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('انتهت الجلسة'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsNothing);
    });

    testWidgets('٤٠٣: صلاحية لا شبكة', (tester) async {
      await tester.pumpWidget(host(
        const StoresScreen(),
        [
          storeListProvider.overrideWith(
            (ref) async => throw const Forbidden(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('صلاحيتك لا تكفي'), findsOneWidget);
    });

    testWidgets('٥٠٠: يُعاد — الخادم متعب لا الطلب خاطئ', (tester) async {
      await tester.pumpWidget(host(
        const StoresScreen(),
        [
          storeListProvider.overrideWith(
            (ref) async => throw const ServerFailure(),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      expect(find.text('تعذّر إكمال الطلب'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsOneWidget);
    });

    testWidgets('٤٠٠: لا إعادة — الطلب نفسه معطوب', (tester) async {
      await tester.pumpWidget(host(
        const StoresScreen(),
        [
          storeListProvider.overrideWith(
            (ref) async => throw const BadRequest('الاسم قصير'),
          ),
        ],
      ));
      await tester.pumpAndSettle();

      // رسالة الخادم لا رسالتنا
      expect(find.text('الاسم قصير'), findsOneWidget);
      expect(find.text('إعادة المحاولة'), findsNothing);
    });
  });

  group('بطاقة الفشل مباشرةً', () {
    testWidgets('خطأ غير متوقَّع لا يُلفَّق برسالة ودّية', (tester) async {
      await tester.pumpWidget(host(
        ShopFailure(error: StateError('عطب داخلي'), onRetry: () {}),
        const [],
      ));
      await tester.pumpAndSettle();

      expect(find.text('خطأ غير متوقَّع'), findsOneWidget);
      // السبب يظهر: إخفاؤه يجعل العطب غير قابل للتتبّع
      expect(find.textContaining('عطب داخلي'), findsOneWidget);
    });
  });
}
