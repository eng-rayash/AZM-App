import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/route_names.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_input.dart';
import '../providers/auth_providers.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  String? _validationError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _validationError = null);
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (password != confirmPassword) {
      setState(() => _validationError = 'كلمتا المرور غير متطابقتين');
      return;
    }

    await ref.read(authStateNotifierProvider.notifier).register(email, password, name);
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authStateNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Always register the listener first (Riverpod requirement)
    ref.listen<AuthState>(authStateNotifierProvider, (previous, next) {
      if (next.status == AuthStatus.authenticated) {
        context.go(RouteNames.splash);
      }
    });

    // === Email Verification Pending Screen ===
    if (authState.status == AuthStatus.emailVerificationPending) {
      return Scaffold(
        backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
        body: SafeArea(
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: Center(
              child: Padding(
                padding: AppSpacing.screen,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: NeuColors.goldAccent.withValues(alpha: 0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.mark_email_unread_rounded,
                        color: NeuColors.goldAccent,
                        size: 48,
                      ),
                    ),
                    AppSpacing.gapXxl,
                    Text(
                      'تم إرسال رابط التفعيل',
                      style: isDark ? AppTypography.h2Dark : AppTypography.h2,
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.gapMd,
                    Text(
                      'تم إرسال رابط التحقق إلى بريدك الإلكتروني. يرجى فتح بريدك والضغط على رابط التفعيل، ثم عد إلى التطبيق وسجّل دخولك.',
                      style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                        color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.gapXl,
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: NeuColors.goldAccent.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: NeuColors.goldAccent.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.info_outline_rounded,
                            color: NeuColors.goldAccent,
                            size: 20,
                          ),
                          AppSpacing.gapHSm,
                          Expanded(
                            child: Text(
                              'لم تجد الرسالة؟ تحقق من مجلد البريد غير المرغوب فيه (Spam).',
                              style: AppTypography.bodySmall.copyWith(
                                color: NeuColors.goldAccent,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.gapXxl,
                    NeuButton(
                      label: 'الذهاب إلى تسجيل الدخول',
                      icon: Icons.login_rounded,
                      onPressed: () => context.go(RouteNames.login),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    // === Normal Register Form ===
    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
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
          child: Center(
            child: SingleChildScrollView(
              padding: AppSpacing.screen,
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      'إنشاء حساب جديد',
                      style: isDark ? AppTypography.h2Dark : AppTypography.h2,
                    ),
                    AppSpacing.gapXs,
                    Text(
                      'قم بإنشاء حساب لحفظ بياناتك سحابياً ومزامنتها',
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

                    // Full Name Input
                    NeuInput(
                      controller: _nameController,
                      label: 'الاسم الكامل',
                      hint: 'الاسم واللقب',
                      prefixIcon: Icons.person_outline,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'يرجى إدخال الاسم الكامل';
                        }
                        return null;
                      },
                    ),
                    AppSpacing.gapLg,

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
                      textInputAction: TextInputAction.next,
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
                    ),
                    AppSpacing.gapLg,

                    // Confirm Password Input
                    NeuInput(
                      controller: _confirmPasswordController,
                      label: 'تأكيد كلمة المرور',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_clock_outlined,
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
                          return 'يرجى تأكيد كلمة المرور';
                        }
                        return null;
                      },
                      onSubmitted: (_) => _submit(),
                    ),
                    AppSpacing.gapXxl,

                    // Register Button
                    NeuButton(
                      label: 'إنشاء الحساب',
                      icon: Icons.person_add_rounded,
                      isLoading: authState.status == AuthStatus.loading,
                      onPressed: _submit,
                    ),
                    AppSpacing.gapXxl,

                    // Back to Login Switch
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'لديك حساب بالفعل؟ ',
                          style: isDark ? AppTypography.bodyDark : AppTypography.body,
                        ),
                        GestureDetector(
                          onTap: () => context.pop(),
                          child: Text(
                            'تسجيل الدخول',
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
