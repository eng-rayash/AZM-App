import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/enums.dart';
import '../../../core/theme/neu_colors.dart';
import '../providers/company_providers.dart';

/// RVIOS — Company Switcher Widget
///
/// Displays a tappable chip in the AppBar showing the active company (or "شخصي").
/// On tap, opens a bottom sheet listing all companies the user belongs to,
/// plus the option to switch to personal mode or add a new company.
///
/// Usage in AppBar:
/// ```dart
/// AppBar(
///   title: const CompanySwitcher(),
///   ...
/// )
/// ```
class CompanySwitcher extends ConsumerWidget {
  const CompanySwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final company = ref.watch(activeCompanyProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => _showSwitcherSheet(context, ref),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: company != null
              ? NeuColors.primaryTint
              : isDark
                  ? NeuColors.surfaceDark
                  : NeuColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: company != null
                ? NeuColors.primary.withValues(alpha: 0.4)
                : isDark
                    ? NeuColors.borderDark
                    : NeuColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Company icon
            Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: company != null ? NeuColors.primary : NeuColors.textHint,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  company != null
                      ? Icons.business_rounded
                      : Icons.person_rounded,
                  color: Colors.white,
                  size: 12,
                ),
              ),
            ),
            const SizedBox(width: 6),

            // Company name / Personal
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 140),
              child: Text(
                company?.name ?? 'شخصي',
                style: TextStyle(
                  fontFamily: 'Panorama',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: company != null
                      ? NeuColors.primary
                      : isDark
                          ? NeuColors.textSecondaryDark
                          : NeuColors.textSecondary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),

            const SizedBox(width: 4),
            Icon(
              Icons.unfold_more_rounded,
              size: 14,
              color: company != null ? NeuColors.primary : NeuColors.textHint,
            ),
          ],
        ),
      ),
    );
  }

  void _showSwitcherSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CompanySwitcherSheet(),
    );
  }
}

// ─────────────────────────────────────────────
// Switcher Bottom Sheet
// ─────────────────────────────────────────────

class _CompanySwitcherSheet extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final activeCompany = ref.watch(activeCompanyProvider);
    final companiesAsync = ref.watch(companiesListProvider);

    return Container(
      decoration: BoxDecoration(
        color: isDark ? NeuColors.surfaceDark : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.only(top: 12, bottom: 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: isDark ? NeuColors.borderDark : NeuColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Text(
                  'مساحات العمل',
                  style: TextStyle(
                    fontFamily: 'Panorama',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? NeuColors.textPrimaryDark
                        : NeuColors.textPrimary,
                  ),
                ),
                const Spacer(),
                // Add new company
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    context.push('/onboarding/create-company');
                  },
                  icon: const Icon(Icons.add, size: 16, color: NeuColors.primary),
                  label: const Text(
                    'أضف شركة',
                    style: TextStyle(
                      fontFamily: 'Panorama',
                      fontSize: 13,
                      color: NeuColors.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Personal mode option ────────────────────────────────
          _WorkspaceItem(
            id: 'switcher_personal',
            icon: Icons.person_rounded,
            name: 'الوضع الشخصي',
            subtitle: 'Free Personal',
            isActive: activeCompany == null,
            onTap: () {
              // الدور يُشتقّ من الشركة النشطة، فلا يُضبط هنا.
              ref.read(activeCompanyProvider.notifier).clearCompany();
              Navigator.pop(context);
            },
          ),

          // ── Companies list ──────────────────────────────────────
          companiesAsync.when(
            loading: () => const Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator(color: NeuColors.primary),
            ),
            error: (e, _) => Padding(
              padding: const EdgeInsets.all(20),
              child: Text('خطأ في تحميل الشركات: $e'),
            ),
            data: (companies) => Column(
              children: companies.map((company) {
                final plan = PlanType.fromValue(company.planType);
                return _WorkspaceItem(
                  id: 'switcher_company_${company.companyCode}',
                  icon: Icons.business_rounded,
                  name: company.name,
                  subtitle: plan.arabicLabel,
                  companyCode: company.companyCode,
                  isActive: activeCompany?.syncId == company.syncId,
                  onTap: () {
                    // ضبط الشركة وحده يكفي: `activeMemberRoleProvider`
                    // مشتقّ منها فيُعاد حسابه تلقائيًا. الجلب اليدوي
                    // للدور هنا كان المسار الوحيد الذي يحدّثه — ولذلك
                    // كان أي مسار آخر يترك الدور متخلّفًا.
                    ref.read(activeCompanyProvider.notifier).setCompany(company);
                    Navigator.pop(context);
                  },
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 8),

          // ── Join company ────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: OutlinedButton.icon(
              key: const Key('btn_join_company'),
              onPressed: () {
                Navigator.pop(context);
                context.push('/onboarding/join-company');
              },
              icon: const Icon(Icons.badge_outlined, size: 18),
              label: const Text(
                'انضم لشركة بكود الموظف',
                style: TextStyle(fontFamily: 'Panorama', fontSize: 14),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: NeuColors.primary,
                side: const BorderSide(color: NeuColors.primary),
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────
// Workspace Item
// ─────────────────────────────────────────────

class _WorkspaceItem extends StatelessWidget {
  const _WorkspaceItem({
    required this.id,
    required this.icon,
    required this.name,
    required this.subtitle,
    required this.isActive,
    required this.onTap,
    this.companyCode,
  });

  final String id;
  final IconData icon;
  final String name;
  final String subtitle;
  final bool isActive;
  final VoidCallback onTap;
  final String? companyCode;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: InkWell(
        key: Key(id),
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isActive
                ? NeuColors.primaryTint
                : isDark
                    ? NeuColors.bgColorDark
                    : NeuColors.bgColor,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isActive
                  ? NeuColors.primary
                  : isDark
                      ? NeuColors.borderDark
                      : NeuColors.border,
              width: isActive ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isActive ? NeuColors.primary : NeuColors.textHint,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontFamily: 'Panorama',
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isActive
                            ? NeuColors.primary
                            : isDark
                                ? NeuColors.textPrimaryDark
                                : NeuColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontFamily: 'Panorama',
                            fontSize: 11,
                            color: isDark
                                ? NeuColors.textSecondaryDark
                                : NeuColors.textSecondary,
                          ),
                        ),
                        if (companyCode != null) ...[
                          const Text(' • ',
                              style:
                                  TextStyle(color: NeuColors.textHint, fontSize: 10)),
                          Text(
                            companyCode!,
                            style: const TextStyle(
                              fontFamily: 'Panorama',
                              fontSize: 10,
                              color: NeuColors.textHint,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              if (isActive)
                const Icon(Icons.check_circle_rounded,
                    color: NeuColors.primary, size: 20)
              else
                const Icon(Icons.chevron_right_rounded,
                    color: NeuColors.textHint, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
