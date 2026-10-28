import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/app_database.dart';
import '../database/providers/database_providers.dart';
import '../database/tenant_database.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/company/providers/company_providers.dart';
import 'dev_demo_accounts.dart';
import 'dev_demo_seeder.dart';

/// مُنسّق الحسابات التجريبية — يربط بين الجلسة والباقة وقاعدة البيانات.
///
/// يُستدعى بعد تسجيل دخول ناجح بحساب تجريبي لضمان:
///   ١. إنشاء سجل شركة في `registry` بالباقة الصحيحة
///   ٢. تفعيل الشركة كمستأجر نشط
///   ٣. تعبئة بيانات العرض التجريبي إن كانت القاعدة فارغة
class DevDemoOrchestrator {
  DevDemoOrchestrator._();

  /// يُهيّئ بيئة الحساب التجريبي بالكامل.
  static Future<void> activate(Ref ref, AzmSession session, String email) async {
    if (!kDebugMode) return;

    final companyId = session.company.id;
    final companyName = session.company.name;
    final planValue = DevDemoAccounts.planValueForEmail(email);
    if (planValue == null) return;
    final userSyncId = session.account.id;

    try {
      // ──────────────────────────────────────────────────
      // ١. تبديل المستأجر أولاً ليفتح ملف الشركة الصحيح
      // ──────────────────────────────────────────────────
      await ref.read(activeTenantIdProvider.notifier).switchTo(companyId);

      // ──────────────────────────────────────────────────
      // ٢. إنشاء/تحديث سجل الشركة في قاعدة registry
      // ──────────────────────────────────────────────────
      final registryDb = ref.read(registryDatabaseProvider);
      final existing = await registryDb.companiesDao.getCompanyBySyncId(companyId);

      if (existing == null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final slug = 'demo-${_planCode(planValue).toLowerCase()}';
        final code = 'DEMO-${_planCode(planValue)}';
        await registryDb.companiesDao.insertCompany(
          CompaniesCompanion(
            syncId: Value(companyId),
            createdAt: Value(now),
            updatedAt: Value(now),
            isDeleted: const Value(false),
            companyCode: Value(code),
            name: Value(companyName),
            workspaceSlug: Value(slug),
            planType: Value(planValue),
            subscriptionStatus: const Value(1), // active
            trialEndsAt: Value(DateTime.now().add(const Duration(days: 365))),
            subscriptionEndsAt: Value(DateTime.now().add(const Duration(days: 365))),
            ownerSyncId: Value(userSyncId),
            country: const Value('SA'),
            currency: const Value('SAR'),
            industry: Value(_industryForPlan(planValue)),
            expectedEmployeeCount: Value(_employeeCountForPlan(planValue)),
            defaultLanguage: const Value('ar'),
            defaultTimezone: const Value('Asia/Riyadh'),
          ),
        );
      } else {
        await registryDb.companiesDao.updateCompany(
          CompaniesCompanion(
            planType: Value(planValue),
            subscriptionStatus: const Value(1),
            updatedAt: Value(DateTime.now().millisecondsSinceEpoch),
          ),
          companyId,
        );
      }

      // ──────────────────────────────────────────────────
      // ٣. تفعيل الشركة
      // ──────────────────────────────────────────────────
      final company = await registryDb.companiesDao.getCompanyBySyncId(companyId);
      if (company != null) {
        ref.read(activeCompanyProvider.notifier).setCompany(company);
      }

      // ──────────────────────────────────────────────────
      // ٤. تعبئة بيانات العرض التجريبي في ملف المستأجر
      // ──────────────────────────────────────────────────
      final tenantDb = ref.read(databaseProvider);
      await DevDemoSeeder.seedIfNeeded(tenantDb, planValue);

    } catch (e) {
      debugPrint('[DevDemo] خطأ في تهيئة الحساب التجريبي: $e');
    }
  }

  static String _planCode(int plan) => switch (plan) {
        1 => 'PRO',
        2 => 'BIZ',
        3 => 'BZP',
        4 => 'ENT',
        _ => 'FRE',
      };

  static String _industryForPlan(int plan) => switch (plan) {
        1 => 'استشارات وخدمات مهنية',
        2 => 'تجارة وتوزيع',
        3 => 'تقنية معلومات وبرمجيات',
        4 => 'طاقة وبنية تحتية',
        _ => 'عام',
      };

  static int _employeeCountForPlan(int plan) => switch (plan) {
        1 => 5,
        2 => 20,
        3 => 75,
        4 => 500,
        _ => 1,
      };
}
