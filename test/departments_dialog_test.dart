@TestOn('vm')
library;

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:azm/core/database/app_database.dart';
import 'package:azm/core/database/providers/database_providers.dart';
import 'package:azm/features/hrm/domain/hrm_repository.dart';
import 'package:azm/features/hrm/presentation/departments_screen.dart';

/// اختبار حوار إنشاء القسم.
///
/// موضعه مقصود: زرّا «قسم جديد» كانا يقودان إلى مسار غير مسجّل فتظهر صفحة
/// خطأ. وحين استُبدلا بحوار، ظهر عطب ثانٍ — التخلّص من المتحكّمات النصّية
/// فور عودة `showDialog` بينما حركة الإغلاق لم تنتهِ، فيفشل التأكيد
/// `_dependents.isEmpty` وتتعطّل الشاشة.
///
/// يُختبر الحوار وحده لا شاشة الأقسام: تلك تراقب تدفّقات Drift حيّة تُبقي
/// مؤقّتات معلّقة فيتعلّق `pumpAndSettle`. والعطب في الحوار أصلًا.
void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() async {
    await db.close();
  });

  /// يركّب زرًّا يفتح الحوار — أقرب ما يكون إلى الاستخدام الفعلي،
  /// وبه تمرّ حركتا الفتح والإغلاق كاملتين.
  Widget host() => ProviderScope(
        overrides: [databaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => Center(
                child: ElevatedButton(
                  onPressed: () => showDialog<bool>(
                    context: context,
                    builder: (_) => const CreateDepartmentDialog(isDark: false),
                  ),
                  child: const Text('افتح'),
                ),
              ),
            ),
          ),
        ),
      );

  Future<void> openDialog(WidgetTester tester) async {
    await tester.pumpWidget(host());
    await tester.tap(find.text('افتح'));
    await tester.pumpAndSettle();
  }

  testWidgets('يفتح بحقلَي الاسم والوصف', (tester) async {
    await openDialog(tester);

    expect(find.text('قسم جديد'), findsOneWidget);
    expect(find.text('اسم القسم'), findsOneWidget);
    expect(find.text('الوصف (اختياري)'), findsOneWidget);
  });

  testWidgets('الحفظ يُنشئ القسم ويُغلق الحوار دون تعطّل', (tester) async {
    await openDialog(tester);

    await tester.enterText(find.byType(TextFormField).first, 'المشتريات');
    await tester.tap(find.text('حفظ'));

    // التمرير عبر حركة الإغلاق كاملةً: هنا كان يقع العطب سابقًا، إذ
    // كانت المتحكّمات تُتلَف والحقول ما زالت مركَّبة.
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('قسم جديد'), findsNothing);

    final depts = await HrmRepository(db).getAllDepartments();
    expect(depts.map((d) => d.name), contains('المشتريات'));
  });

  testWidgets('اسم فارغ يمنع الحفظ ويُبقي الحوار مفتوحًا', (tester) async {
    await openDialog(tester);

    await tester.tap(find.text('حفظ'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('اسم القسم مطلوب'), findsOneWidget);
    expect(find.text('قسم جديد'), findsOneWidget);
    expect(await HrmRepository(db).getAllDepartments(), isEmpty);
  });

  testWidgets('الإلغاء يُغلق دون حفظ ودون تعطّل', (tester) async {
    await openDialog(tester);

    await tester.enterText(find.byType(TextFormField).first, 'لن يُحفظ');
    await tester.tap(find.text('إلغاء'));
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('قسم جديد'), findsNothing);
    expect(await HrmRepository(db).getAllDepartments(), isEmpty);
  });
}
