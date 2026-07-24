import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/app_typography.dart';

/// RVIOS — Welcome Screen
///
/// الشاشة الأولى التي يراها المستخدم الجديد.
/// تعرض هوية RVIOS وثلاثة خيارات:
///   1. ابدأ مجاناً (Free Personal)
///   2. أنا موظف في شركة (Join Company)
///   3. لدي حساب (Login)
class WelcomeScreen extends ConsumerWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Column(
                      children: [
                        const Spacer(flex: 2),

              // â”€â”€ Logo â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _RviosLogo(isDark: isDark),

              const SizedBox(height: 16),

              // â”€â”€ Tagline â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Text(
                'One Platform. Complete Business Management.',
                style: AppTypography.caption.copyWith(
                  color: NeuColors.gold,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),

              const Spacer(flex: 3),

              // â”€â”€ Action Buttons â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

              // 1. ابدأ مجاناً
              _WelcomeButton(
                id: 'btn_start_free',
                label: 'ابدأ مجاناً',
                sublabel: 'حساب شخصي • مجاني',
                icon: Icons.person_outline_rounded,
                isPrimary: true,
                onTap: () => context.push('/onboarding/register-personal'),
              ),

              const SizedBox(height: 12),

              // 2. إنشاء حساب شركة
              _WelcomeButton(
                id: 'btn_create_company',
                label: 'إنشاء حساب شركة',
                sublabel: 'للشركات والمؤسسات',
                icon: Icons.business_outlined,
                isPrimary: false,
                onTap: () => context.push('/onboarding/create-company'),
              ),

              const SizedBox(height: 12),

              // 3. أنا موظف في شركة
              _WelcomeButton(
                id: 'btn_join_company',
                label: 'أنا موظف في شركة',
                sublabel: 'تسجيل دخول بكود الشركة',
                icon: Icons.badge_outlined,
                isPrimary: false,
                onTap: () => context.push('/onboarding/join-company'),
              ),

              const SizedBox(height: 24),

              // ── Login Link ─────────────────────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'لديك حساب؟ ',
                    style: AppTypography.body.copyWith(
                      color: isDark
                          ? NeuColors.textSecondaryDark
                          : NeuColors.textSecondary,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => context.go('/login'),
                    child: Text(
                      'سجّل دخولك',
                      style: AppTypography.body.copyWith(
                        color: NeuColors.primary,
                        fontWeight: FontWeight.w700,
                        decoration: TextDecoration.underline,
                        decorationColor: NeuColors.primary,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Logo Widget
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _RviosLogo extends StatelessWidget {
  const _RviosLogo({required this.isDark});
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Official Logo Mark Icon
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: NeuColors.primary.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Image.asset(
                'assets/images/logo_icon.png',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // English Title — Yapari Bold
        Text(
          'RVIOS',
          style: TextStyle(
            fontFamily: 'Yapari',
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: isDark ? NeuColors.textPrimaryDark : NeuColors.primary,
            letterSpacing: 4,
          ),
        ),

        // Arabic Title — RTL Maghfira
        Text(
          'ريفيوس',
          style: TextStyle(
            fontFamily: AppTypography.fontFamilyRTLMaghfira,
            fontSize: 34,
            fontWeight: FontWeight.w400,
            color: isDark ? NeuColors.gold : NeuColors.primaryDark,
          ),
        ),

        const SizedBox(height: 6),

        Text(
          'Business Operating System',
          style: TextStyle(
            fontFamily: AppTypography.fontFamilyGivonic,
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: isDark
                ? NeuColors.textSecondaryDark
                : NeuColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
      ],
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Welcome Button Widget
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _WelcomeButton extends StatelessWidget {
  const _WelcomeButton({
    required this.id,
    required this.label,
    required this.sublabel,
    required this.icon,
    required this.isPrimary,
    required this.onTap,
  });

  final String id;
  final String label;
  final String sublabel;
  final IconData icon;
  final bool isPrimary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        key: Key(id),
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isPrimary
                ? NeuColors.primary
                : isDark
                    ? NeuColors.surfaceDark
                    : NeuColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: isPrimary
                ? null
                : Border.all(
                    color: isDark ? NeuColors.borderDark : NeuColors.border,
                    width: 1.5,
                  ),
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: NeuColors.primary.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isPrimary
                      ? Colors.white.withValues(alpha: 0.2)
                      : NeuColors.primaryTint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isPrimary ? Colors.white : NeuColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamilyPanorama,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: isPrimary
                            ? Colors.white
                            : isDark
                                ? NeuColors.textPrimaryDark
                                : NeuColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      sublabel,
                      style: TextStyle(
                        fontFamily: AppTypography.fontFamilyPanorama,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: isPrimary
                            ? Colors.white.withValues(alpha: 0.8)
                            : isDark
                                ? NeuColors.textSecondaryDark
                                : NeuColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: isPrimary
                    ? Colors.white.withValues(alpha: 0.7)
                    : isDark
                        ? NeuColors.textHintDark
                        : NeuColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}