@TestOn('vm')
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:azm/core/navigation/azm_nav_model.dart';
import 'package:azm/core/router/route_names.dart';
import 'package:azm/shared/widgets/azm_sidebar.dart';

/// اختبارات الشريط الجانبي.
///
/// الشريط يعرض ٤٦ وجهة في ست مجموعات. القاعدة التي تجعله صالحًا بدل أن
/// يعيد مشكلة تبويب «المزيد» هي أن **مجموعة واحدة تُفتح في كل مرة**، وأن
/// المجموعة التي يقع فيها المسار الحالي تُفتح تلقائيًا. هذه الاختبارات
/// تثبّت ذلك السلوك.
void main() {
  Widget host(String location) => ProviderScope(
        child: MaterialApp(
          home: Scaffold(
            body: AzmSidebar(currentLocation: location, isDrawer: false),
          ),
        ),
      );

  testWidgets('يعرض «اليوم» وكل المجموعات الست', (tester) async {
    await tester.pumpWidget(host(RouteNames.dashboardFull));
    await tester.pumpAndSettle();

    // ‏«الرئيسية» صارت «اليوم»: اسمٌ يقول ما في الشاشة لا موضعها
    expect(find.text('اليوم'), findsOneWidget);
    for (final g in AzmNav.groups) {
      expect(find.text(g.label), findsOneWidget, reason: g.label);
    }
  });

  testWidgets('المجموعات مطويّة عند الفتح — لا تُغرق الشاشة',
      (tester) async {
    await tester.pumpWidget(host(RouteNames.dashboardFull));
    await tester.pumpAndSettle();

    // «الفواتير» تنتمي إلى المالية وهي مطويّة، فلا تظهر
    expect(find.text('الفواتير'), findsNothing);
    expect(find.text('الموظفون'), findsNothing);
  });

  testWidgets('المجموعة الحاوية للمسار الحالي تُفتح تلقائيًا',
      (tester) async {
    await tester.pumpWidget(host(RouteNames.invoicesList));
    await tester.pumpAndSettle();

    // المالية مفتوحة لأن المسار داخلها
    expect(find.text('الفواتير'), findsOneWidget);
    // والفريق ما زالت مطويّة
    expect(find.text('الموظفون'), findsNothing);
  });

  testWidgets('الضغط على رأس مجموعة يفتحها', (tester) async {
    await tester.pumpWidget(host(RouteNames.dashboardFull));
    await tester.pumpAndSettle();

    expect(find.text('الموظفون'), findsNothing);

    await tester.tap(find.text('الفريق'));
    await tester.pumpAndSettle();

    expect(find.text('الموظفون'), findsOneWidget);
    expect(find.text('الرواتب'), findsOneWidget);
  });

  testWidgets('فتح مجموعة يطوي السابقة — واحدة مفتوحة فقط', (tester) async {
    await tester.pumpWidget(host(RouteNames.invoicesList));
    await tester.pumpAndSettle();

    expect(find.text('الفواتير'), findsOneWidget);

    // مع فتح المالية (٩ وجهات) يهبط رأس «الفريق» تحت الطيّة
    await tester.scrollUntilVisible(find.text('الفريق'), 120);
    await tester.tap(find.text('الفريق'));
    await tester.pumpAndSettle();

    expect(find.text('الموظفون'), findsOneWidget);
    expect(find.text('الفواتير'), findsNothing,
        reason: 'المالية يجب أن تُطوى عند فتح الفريق');
  });

  testWidgets('الضغط ثانيةً على المجموعة المفتوحة يطويها', (tester) async {
    await tester.pumpWidget(host(RouteNames.dashboardFull));
    await tester.pumpAndSettle();

    await tester.tap(find.text('الوثائق'));
    await tester.pumpAndSettle();
    expect(find.text('الأرشيف'), findsOneWidget);

    await tester.tap(find.text('الوثائق'));
    await tester.pumpAndSettle();
    expect(find.text('الأرشيف'), findsNothing);
  });

  testWidgets('قسم النظام أسفل الشجرة، والحساب مثبّت في القدم',
      (tester) async {
    await tester.pumpWidget(host(RouteNames.dashboardFull));
    await tester.pumpAndSettle();

    // القدم خارج القائمة القابلة للتمرير، فهو ظاهر دائمًا
    expect(find.text('الحساب'), findsOneWidget);

    // وقسم النظام داخلها، فيلزم التمرير إليه
    await tester.scrollUntilVisible(find.text('الإعدادات'), 120);
    await tester.pumpAndSettle();

    expect(find.text('النظام'), findsOneWidget);
    expect(find.text('الإعدادات'), findsOneWidget);
  });

  testWidgets('كل وجهة في الشجرة لها مسار مسجّل غير فارغ', (tester) async {
    final all = <NavDestination>[
      AzmNav.home,
      for (final g in AzmNav.groups) ...g.destinations,
      ...AzmNav.system,
    ];

    expect(all.length, greaterThan(40));
    for (final d in all) {
      expect(d.route, startsWith('/'), reason: d.label);
      expect(d.label.trim(), isNotEmpty);
    }

    // لا تتكرّر وجهة بمسارين مختلفين داخل الشجرة
    final routes = all.map((d) => d.route).toList();
    expect(routes.toSet().length, routes.length,
        reason: 'مسار مكرَّر في شجرة التنقّل');
  });
}
