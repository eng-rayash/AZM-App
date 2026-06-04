import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_input.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  String? _validationError;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _validationError = null);
    if (!_formKey.currentState!.validate()) return;

    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    await ref.read(authStateNotifierProvider.notifier).login(email, password);
  }

  Future<void> _continueAsGuest() async {
    await ref.read(authStateNotifierProvider.notifier).continueAsGuest();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final authState = ref.watch(authStateNotifierProvider);

    // Listen to auth state transitions
    ref.listen<AuthState>(authStateNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated || next.status == AuthStatus.guest) {
        // Navigate to splash or router logic will take care of redirect
        context.go(RouteNames.splash);
      }
    });

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.screen,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(22),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 15,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(22),
                        child: Image.asset(
                          'assets/icon.png',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    AppSpacing.gapLg,

                    // Title
                    Text(
                      AppConstants.appName,
                      style: isDark ? AppTypography.h1Dark : AppTypography.h1,
                    ),
                    AppSpacing.gapXs,
                    Text(
                      'نظام الإدارة التنفيذي الذكي',
                      style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                        color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
                      ),
                    ),
                    AppSpacing.gapXxl,

                    // Error Box if any
                    if (authState.status == AuthStatus.error || _validationError != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: NeuColors.danger.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: NeuColors.danger.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          _validationError ?? authState.errorMessage ?? 'حدث خطأ غير متوقع',
                          style: AppTypography.bodySmall.copyWith(color: NeuColors.danger),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      AppSpacing.gapMd,
                    ],

                    // Email Input
                    NeuInput(
                      controller: _emailController,
                      label: 'البريد الإلكتروني',
                      hint: 'example@domain.com',
                      prefixIcon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال البريد الإلكتروني';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                          return 'يرجى إدخال بريد إلكتروني صالح';
                        }
                        return null;
                      },
                    ),
                    AppSpacing.gapLg,

                    // Password Input
                    NeuInput(
                      controller: _passwordController,
                      label: 'كلمة المرور',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outlined,
                      obscureText: _obscurePassword,
                      keyboardType: TextInputType.visiblePassword,
                      textInputAction: TextInputAction.done,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                          color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال كلمة المرور';
                        }
                        if (value.length < 6) {
                          return 'يجب أن تكون كلمة المرور ٦ أحرف على الأقل';
                        }
                        return null;
                      },
                      onSubmitted: (_) => _submit(),
                    ),
                    AppSpacing.gapXl,

                    // Sign In Button
                    NeuButton(
                      label: 'تسجيل الدخول',
                      icon: Icons.login_rounded,
                      isLoading: authState.status == AuthStatus.loading,
                      onPressed: _submit,
                    ),
                    AppSpacing.gapMd,

                    // Continue as Guest Button (Secondary Neumorphic)
                    NeuButton(
                      label: 'الاستمرار كضيف (عمل محلي)',
                      icon: Icons.person_outline_rounded,
                      variant: NeuButtonVariant.secondary,
                      onPressed: authState.status == AuthStatus.loading ? null : _continueAsGuest,
                    ),
                    AppSpacing.gapXxl,

                    // Divider and Register Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'ليس لديك حساب؟ ',
                          style: isDark ? AppTypography.bodyDark : AppTypography.body,
                        ),
                        GestureDetector(
                          onTap: () => context.push(RouteNames.register),
                          child: Text(
                            'إنشاء حساب جديد',
                            style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                              color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
