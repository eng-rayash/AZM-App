import 'dart:convert';

import 'package:crypto/crypto.dart';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../features/auth/data/auth_repository.dart';

/// حسابات تجريبية للمطوّر — **تعمل بلا خادم**.
///
/// أربعة حسابات بأربع باقات مختلفة للاختبار المحلي. عند تسجيل الدخول
/// بأحد هذه الإيميلات وكلمة المرور `azm2025`، يُنشأ جلسة محلية مباشرة
/// بدون الاتصال بالباكند — لا تُعدَّل أي ملفات في مجلد `api`.
///
/// تعمل فقط في وضع التطوير (`kDebugMode`).
class DevDemoAccounts {
  DevDemoAccounts._();

  static const String _prefsKey = 'azm.dev_demo_session';

  /// كلمة المرور الموحّدة لجميع الحسابات التجريبية.
  static const String _password = 'azm2025';

  /// الحسابات التجريبية الأربعة.
  static const List<_DemoAccount> _accounts = [
    _DemoAccount(
      email: 'rayashpro2@gmail.com',
      displayName: 'احمد سالم',
      companyName: 'موظف في شركة',
      planValue: 1, // PlanType.professional
      planLabel: 'محترف',
    ),
    _DemoAccount(
      email: 'rayash2025@gmail.com',
      displayName: 'رياش البريهي',
      companyName: 'مجموعة الأعمال',
      planValue: 2, // PlanType.business
      planLabel: 'أعمال',
    ),
    _DemoAccount(
      email: 'ruqiafaisal797@gmail.com',
      displayName: 'رقية فيصل',
      companyName: 'أعمال بلس المتقدمة',
      planValue: 3, // PlanType.businessPlus
      planLabel: 'أعمال بلس',
    ),
    _DemoAccount(
      email: 'rviostech@gmail.com',
      displayName: 'المدير التنفيذي',
      companyName: 'RVIOS Technologies',
      planValue: 4, // PlanType.enterprise
      planLabel: 'مؤسسي',
    ),
  ];

  /// هل هذا البريد حساب تجريبي؟
  static bool isDemoEmail(String email) {
    if (!kDebugMode) return false;
    return _accounts.any((a) => a.email == email.trim().toLowerCase());
  }

  /// يحاول تسجيل دخول تجريبي. يعيد `null` إن لم يكن حساباً تجريبياً
  /// أو كلمة المرور خاطئة.
  static AzmSession? tryLogin(String email, String password) {
    if (!kDebugMode) return null;

    final normalizedEmail = email.trim().toLowerCase();
    final account = _accounts.cast<_DemoAccount?>().firstWhere(
          (a) => a!.email == normalizedEmail,
          orElse: () => null,
        );
    if (account == null) return null;
    if (password != _password) return null;

    return _buildSession(account);
  }

  /// يحفظ جلسة تجريبية بين التشغيلات.
  static Future<void> saveSession(AzmSession session) async {
    if (!kDebugMode) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(session.toJson()));
  }
  
  /// يستعيد جلسة تجريبية محفوظة.
  static Future<AzmSession?> restoreSession() async {
    if (!kDebugMode) return null;
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return null;
    try {
      return AzmSession.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
        offline: true,
      );
    } catch (_) {
      return null;
    }
  }

  /// يمسح الجلسة التجريبية عند الخروج.
  static Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  /// معلومات الباقة لحساب تجريبي (لتهيئة الشركة في القاعدة المحلية).
  static int? planValueForEmail(String email) {
    final normalizedEmail = email.trim().toLowerCase();
    final account = _accounts.cast<_DemoAccount?>().firstWhere(
          (a) => a!.email == normalizedEmail,
          orElse: () => null,
        );
    return account?.planValue;
  }

  static AzmSession _buildSession(_DemoAccount account) {
    // معرّفات ثابتة بصيغة UUID — مبنية من البريد لضمان التطابق بين التشغيلات
    final userUuid = _deterministicId('user-${account.email}');
    final companyUuid = _deterministicId('company-${account.email}');
    return AzmSession(
      account: AzmAccount(
        id: userUuid,
        email: account.email,
        displayName: account.displayName,
      ),
      company: AzmCompany(
        id: companyUuid,
        name: account.companyName,
        role: 0, // owner
      ),
      role: 0, // owner
    );
  }

  /// ينشئ معرّف UUID ثابت (v5-like) من نص — نفس المدخل = نفس المخرج دائماً.
  static String _deterministicId(String input) {
    final bytes = sha256.convert(utf8.encode(input)).bytes;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    // تنسيق UUID: 8-4-4-4-12
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20, 32)}';
  }
}

class _DemoAccount {
  const _DemoAccount({
    required this.email,
    required this.displayName,
    required this.companyName,
    required this.planValue,
    required this.planLabel,
  });

  final String email;
  final String displayName;
  final String companyName;
  final int planValue;
  final String planLabel;
}
