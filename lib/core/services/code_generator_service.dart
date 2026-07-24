import 'dart:math';

import '../constants/app_constants.dart';
import '../constants/enums.dart';

/// RVIOS — Code Generator Service
///
/// Generates unique human-readable codes for companies and employees.
/// Examples:
///   Company: CMP-8X7Q2K
///   Employee: EMP-00215
///   Workspace slug: acme-corp
class CodeGeneratorService {
  CodeGeneratorService._();

  static final _random = Random.secure();

  // ─────────────────────────────────────────────
  // Company Code  (CMP-XXXXXX)
  // ─────────────────────────────────────────────

  /// Generates a unique Company ID, e.g. "CMP-8X7Q2K"
  static String generateCompanyCode() {
    const chars = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789'; // no 0,O,I,1 — readable
    final rand = List.generate(
      AppConstants.codeRandomLength,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
    return '${AppConstants.companyIdPrefix}-$rand';
  }

  // ─────────────────────────────────────────────
  // Employee Code  (EMP-XXXXX)
  // ─────────────────────────────────────────────

  /// Generates a sequential Employee Code, e.g. "EMP-00215"
  ///
  /// [index] is the 1-based position of the employee in the company.
  static String generateEmployeeCode(int index) {
    final padded = index.toString().padLeft(5, '0');
    return '${AppConstants.employeeIdPrefix}-$padded';
  }

  // ─────────────────────────────────────────────
  // Workspace Slug
  // ─────────────────────────────────────────────

  /// Converts a company name to a URL-safe workspace slug.
  ///
  /// Examples:
  ///   "شركة أكمي للتجارة" → "shrkh-akmy"  (transliterated Arabic)
  ///   "Acme Corp"         → "acme-corp"
  ///   "ABC & XYZ Ltd."    → "abc-xyz-ltd"
  static String generateWorkspaceSlug(String companyName) {
    // Transliterate Arabic → Latin (basic map)
    var slug = _transliterateArabic(companyName);

    // Lowercase + replace non-alphanumeric with hyphens
    slug = slug
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'-+'), '-')
        .replaceAll(RegExp(r'^-|-$'), '');

    // Limit length
    if (slug.length > 30) slug = slug.substring(0, 30);
    if (slug.isEmpty) slug = 'workspace';

    return slug;
  }

  /// Appends a short random suffix to make a slug unique.
  ///
  /// e.g. "acme-corp" → "acme-corp-x7k"
  static String makeSlugUnique(String baseSlug) {
    const chars = 'abcdefghjkmnpqrstuvwxyz23456789';
    final suffix = List.generate(3, (_) => chars[_random.nextInt(chars.length)])
        .join();
    return '$baseSlug-$suffix';
  }

  // ─────────────────────────────────────────────
  // Username
  // ─────────────────────────────────────────────

  /// Generates a default username from a name.
  ///
  /// Examples:
  ///   "Ahmed Saleh"     → "ahmed.saleh"
  ///   "أحمد صالح"      → "ahmed.saleh"  (transliterated)
  static String generateUsername(String fullName) {
    final parts = _transliterateArabic(fullName)
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .take(2)
        .toList();

    if (parts.isEmpty) return 'user${_random.nextInt(9999)}';
    if (parts.length == 1) return parts.first;
    return '${parts.first}.${parts.last}';
  }

  // ─────────────────────────────────────────────
  // Temporary Password
  // ─────────────────────────────────────────────

  /// Generates a secure temporary password of [length] characters.
  ///
  /// Always includes: uppercase, lowercase, digit, special char.
  static String generateTempPassword({int length = 12}) {
    const upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ';
    const lower = 'abcdefghjkmnpqrstuvwxyz';
    const digits = '23456789';
    const special = '@#\$!%';
    const all = upper + lower + digits + special;

    final pw = [
      upper[_random.nextInt(upper.length)],
      lower[_random.nextInt(lower.length)],
      digits[_random.nextInt(digits.length)],
      special[_random.nextInt(special.length)],
      ...List.generate(
          length - 4, (_) => all[_random.nextInt(all.length)]),
    ]..shuffle(_random);

    return pw.join();
  }

  // ─────────────────────────────────────────────
  // Invitation Token
  // ─────────────────────────────────────────────

  /// Generates a secure UUID-like invitation token (36 chars).
  static String generateInvitationToken() {
    const chars = '0123456789abcdef';
    final b = List.generate(32, (_) => chars[_random.nextInt(chars.length)]);
    // Format as UUID: 8-4-4-4-12
    return '${b.sublist(0, 8).join()}'
        '-${b.sublist(8, 12).join()}'
        '-${b.sublist(12, 16).join()}'
        '-${b.sublist(16, 20).join()}'
        '-${b.sublist(20, 32).join()}';
  }

  // ─────────────────────────────────────────────
  // Helpers
  // ─────────────────────────────────────────────

  /// Basic Arabic → Latin transliteration map
  static String _transliterateArabic(String input) {
    const map = {
      'أ': 'a', 'ا': 'a', 'إ': 'i', 'آ': 'a',
      'ب': 'b', 'ت': 't', 'ث': 'th', 'ج': 'j',
      'ح': 'h', 'خ': 'kh', 'د': 'd', 'ذ': 'th',
      'ر': 'r', 'ز': 'z', 'س': 's', 'ش': 'sh',
      'ص': 's', 'ض': 'd', 'ط': 't', 'ظ': 'z',
      'ع': 'a', 'غ': 'gh', 'ف': 'f', 'ق': 'q',
      'ك': 'k', 'ل': 'l', 'م': 'm', 'ن': 'n',
      'ه': 'h', 'و': 'w', 'ي': 'y', 'ى': 'a',
      'ة': 'h', 'ء': '', 'ئ': 'y', 'ؤ': 'w',
      'لا': 'la', '،': '', '؟': '',
    };

    var result = input;
    map.forEach((arabic, latin) {
      result = result.replaceAll(arabic, latin);
    });

    return result;
  }

  /// Returns the available modules for a given plan + role combo
  static List<AppModule> getAvailableModules(PlanType plan, UserRole role) {
    return AppModule.values
        .where((m) => m.isAvailableFor(plan))
        .where((m) {
          // Additional role-based filtering
          if (m == AppModule.hrm || m == AppModule.payroll || m == AppModule.attendance) {
            return role.hasHrAccess;
          }
          if (m == AppModule.finance || m == AppModule.invoices) {
            return role.hasFinanceAccess || role.hasHrAccess == false;
          }
          return true;
        })
        .toList();
  }
}