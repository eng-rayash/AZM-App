@TestOn('vm')
library;

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:azm/core/constants/enums.dart';
import 'package:azm/core/database/app_database.dart';
import 'package:azm/core/database/providers/database_providers.dart';
import 'package:azm/features/company/providers/company_providers.dart';

/// الدور مشتقّ لا مخزَّن.
///
/// كان `activeMemberRoleProvider` نسخةً مكرّرة من حقيقة في القاعدة،
/// يحدّثها ودجت واحد عند تبديل الشركة. الاختبار الأول أدناه هو ما كان
/// يفشل: ضبط الشركة برمجيًا — أي مسار لا يمرّ بذلك الودجت — كان يترك
/// الدور على قيمته السابقة.
/// معرّف بطول ٣٦ بالضبط — الأعمدة تشترطه، والعدّ اليدوي يُخطئ.
String _id(String seed) => seed.padRight(36, '-').substring(0, 36);

void main() {
  late AppDatabase db;
  late ProviderContainer container;

  /// شركة محلية تكفي لاختبار الاشتقاق.
  Future<Company> seedCompany(String name) async {
    final syncId = _id('company-$name');
    final now = DateTime.now().millisecondsSinceEpoch;

    await db.companiesDao.insertCompany(
      CompaniesCompanion.insert(
        syncId: syncId,
        companyCode: 'CMP-${name.toUpperCase()}',
        name: name,
        workspaceSlug: name,
        createdAt: now,
        updatedAt: now,
        ownerSyncId: _id('owner-user'),
      ),
    );

    return (await db.companiesDao.getAllCompanies())
        .firstWhere((c) => c.syncId == syncId);
  }

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
    container = ProviderContainer(
      overrides: [databaseProvider.overrideWithValue(db)],
    );
  });

  tearDown(() async {
    container.dispose();
    await db.close();
  });

  test('الدور يتبع الشركة النشطة دون أن يضبطه أحد', () async {
    final company = await seedCompany('alpha');

    // ضبط الشركة فقط — لا ضبط للدور، وهذا هو بيت القصيد
    container.read(activeCompanyProvider.notifier).setCompany(company);
    await container.read(userRoleInCompanyProvider.future);

    // لا مستخدم مسجَّل: الوضع المحلي، والجهاز جهازك
    expect(container.read(activeMemberRoleProvider), UserRole.owner);
  });

  test('العودة للوضع الشخصي تعيد حسابه', () async {
    final company = await seedCompany('beta');

    container.read(activeCompanyProvider.notifier).setCompany(company);
    await container.read(userRoleInCompanyProvider.future);
    expect(container.read(activeMemberRoleProvider), UserRole.owner);

    container.read(activeCompanyProvider.notifier).clearCompany();
    await container.read(userRoleInCompanyProvider.future);

    expect(container.read(activeMemberRoleProvider), UserRole.employee);
  });

  test('لا شركة نشطة ⇐ الوضع الشخصي', () async {
    await container.read(userRoleInCompanyProvider.future);
    expect(container.read(activeMemberRoleProvider), UserRole.employee);
  });

  test('المشتقّات تتبعه — لا تُضبط على حدة', () async {
    final company = await seedCompany('gamma');

    expect(container.read(canManageUsersProvider), isFalse);

    container.read(activeCompanyProvider.notifier).setCompany(company);
    await container.read(userRoleInCompanyProvider.future);

    expect(container.read(canManageUsersProvider), isTrue);
  });

  group('مستخدم مسجَّل بعضوية حقيقية', () {
    /// حاوية بمستخدم مزيَّف — هذا ما أتاحه حقن [currentUserSyncIdProvider]
    /// بدل القراءة من `Supabase.instance` العالمي.
    ProviderContainer withUser(String userSyncId) => ProviderContainer(
          overrides: [
            databaseProvider.overrideWithValue(db),
            currentUserSyncIdProvider.overrideWithValue(userSyncId),
          ],
        );

    Future<void> seedMembership({
      required String companySyncId,
      required String userSyncId,
      required UserRole role,
    }) async {
      final now = DateTime.now().millisecondsSinceEpoch;
      await db.companiesDao.insertMember(
        CompanyMembersCompanion.insert(
          syncId: _id('member-$userSyncId'),
          companySyncId: companySyncId,
          userSyncId: userSyncId,
          role: Value(role.level),
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    test('الدور يُقرأ من صفّ العضوية', () async {
      final company = await seedCompany('delta');
      final user = _id('user-hr-manager');
      await seedMembership(
        companySyncId: company.syncId,
        userSyncId: user,
        role: UserRole.hrManager,
      );

      final c = withUser(user);
      addTearDown(c.dispose);

      c.read(activeCompanyProvider.notifier).setCompany(company);
      await c.read(userRoleInCompanyProvider.future);

      expect(c.read(activeMemberRoleProvider), UserRole.hrManager);
      // مدير الموارد البشرية لا يصل إلى المالية رغم أن رقمه أصغر
      expect(c.read(canAccessFinanceProvider), isFalse);
      expect(c.read(canManageUsersProvider), isFalse);
    });

    test('تغيير الدور في القاعدة يسري بإعادة الحساب', () async {
      final company = await seedCompany('epsilon');
      final user = _id('user-promoted');
      await seedMembership(
        companySyncId: company.syncId,
        userSyncId: user,
        role: UserRole.employee,
      );

      final c = withUser(user);
      addTearDown(c.dispose);

      c.read(activeCompanyProvider.notifier).setCompany(company);
      await c.read(userRoleInCompanyProvider.future);
      expect(c.read(canManageUsersProvider), isFalse);

      await db.companiesDao.updateMember(
        CompanyMembersCompanion(role: Value(UserRole.admin.level)),
        company.syncId,
        user,
      );
      c.invalidate(userRoleInCompanyProvider);
      await c.read(userRoleInCompanyProvider.future);

      expect(c.read(activeMemberRoleProvider), UserRole.admin);
      expect(c.read(canManageUsersProvider), isTrue);
    });
  });

  test('الدور قيمة مقروءة فقط — لا سبيل لضبطه يدويًا', () {
    // `Provider` لا يعرض `notifier` قابلًا للكتابة كما كان
    // `StateProvider` يفعل. هذا الاختبار يوثّق النية: المصدر واحد،
    // والكتابة عليه من خارجه ليست مسارًا مدعومًا.
    expect(activeMemberRoleProvider, isA<Provider<UserRole>>());
  });
}
