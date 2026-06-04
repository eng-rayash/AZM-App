import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';
import '../providers/auth_providers.dart';

class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateNotifierProvider);

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'حسابي والتحقق',
          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: AppSpacing.screen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                
                // Account Card
                NeuCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      // User Avatar/Icon
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          color: isDark ? NeuColors.navyDeep : NeuColors.navyDeep.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          authState.status == AuthStatus.authenticated
                              ? Icons.person_rounded
                              : Icons.person_outline_rounded,
                          color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                          size: 36,
                        ),
                      ),
                      AppSpacing.gapLg,

                      if (authState.status == AuthStatus.authenticated && authState.user != null) ...[
                        Text(
                          authState.user!.email ?? 'مستخدم مديري',
                          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
                        ),
                        AppSpacing.gapXs,
                        Text(
                          'معرف المستخدم: ${authState.user!.id.substring(0, 8)}...',
                          style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(
                            color: isDark ? NeuColors.textHintDark : NeuColors.textHint,
                          ),
                        ),
                        AppSpacing.gapMd,
                        const Divider(),
                        AppSpacing.gapMd,
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.cloud_done_rounded,
                              color: NeuColors.success,
                              size: 20,
                            ),
                            AppSpacing.gapHSm,
                            Text(
                              'الحساب متصل سحابياً مع Supabase',
                              style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                                color: NeuColors.success,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          'دخول كضيف (وضع محلي)',
                          style: isDark ? AppTypography.h3Dark : AppTypography.h3,
                        ),
                        AppSpacing.gapXs,
                        Text(
                          'البيانات تحفظ محلياً فقط على هذا الجهاز ولا تتم مزامنتها سحابياً.',
                          style: isDark ? AppTypography.captionDark : AppTypography.caption,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),

                const Spacer(),

                if (authState.status == AuthStatus.authenticated) ...[
                  NeuButton(
                    label: 'تسجيل الخروج من الحساب',
                    icon: Icons.logout_rounded,
                    variant: NeuButtonVariant.danger,
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (ctx) => Directionality(
                          textDirection: TextDirection.rtl,
                          child: AlertDialog(
                            backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
                            title: const Text('تسجيل الخروج'),
                            content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج من حسابك؟'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('إلغاء'),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(backgroundColor: NeuColors.danger),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('تسجيل خروج'),
                              ),
                            ],
                          ),
                        ),
                      );

                      if (confirmed == true) {
                        await ref.read(authStateNotifierProvider.notifier).logout();
                        if (context.mounted) {
                          context.go(RouteNames.splash);
                        }
                      }
                    },
                  ),
                ] else ...[
                  Text(
                    'قم بإنشاء حساب أو تسجيل الدخول للاستفادة من مزامنة المذكرات والاجتماعات سحابياً، وحمايتها من الضياع.',
                    style: isDark ? AppTypography.bodyDark : AppTypography.body,
                    textAlign: TextAlign.center,
                  ),
                  AppSpacing.gapXxl,
                  NeuButton(
                    label: 'إنشاء حساب أو تسجيل الدخول',
                    icon: Icons.login_rounded,
                    variant: NeuButtonVariant.primary,
                    onPressed: () {
                      context.go(RouteNames.login);
                    },
                  ),
                ],
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
