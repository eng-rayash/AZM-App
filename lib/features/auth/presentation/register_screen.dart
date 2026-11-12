import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/azm_tokens.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../store_app/kit.dart';
import '../../store_platform/create_store_wizard.dart';
import '../providers/auth_providers.dart';

/// «افتح متجرك مجانًا» — الخطوة الأولى: حساب RVIOS (الاسم والنشاط والبريد وكلمة المرور)،
/// ثم رمز البريد، ثم يُفتح معالج المتجر مباشرة: القالب ← الباقة ← البيانات ← الدفع.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _name = TextEditingController();
  final _business = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  bool _hide = true;
  String? _error;

  @override
  void dispose() {
    for (final c in [_name, _business, _email, _password, _code]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final n = ref.read(authStateNotifierProvider.notifier);
    setState(() => _error = null);
    if (ref.read(authStateNotifierProvider).status == AuthStatus.emailVerificationPending) {
      if (_code.text.trim().length < 4) return setState(() => _error = 'اكتب الرمز الذي وصلك على البريد');
      await n.verifyCode(_code.text.trim());
      if (mounted && n.lastError != null) setState(() => _error = n.lastError);
      return;
    }
    final name = _name.text.trim();
    final email = _email.text.trim();
    if (name.length < 2) return setState(() => _error = 'اكتب اسمك');
    if (!email.contains('@')) return setState(() => _error = 'اكتب بريدًا صحيحًا');
    if (_password.text.length < 8) return setState(() => _error = 'كلمة المرور ثماني خانات على الأقل');
    final business = _business.text.trim().length >= 2 ? _business.text.trim() : 'نشاط $name';
    CreateStoreWizard.openAfterSignUp = true;
    await n.register(email, _password.text, name, business);
  }

  @override
  Widget build(BuildContext context) {
    final p = AzmPalette.of(context);
    final auth = ref.watch(authStateNotifierProvider);
    final notifier = ref.read(authStateNotifierProvider.notifier);
    final code = auth.status == AuthStatus.emailVerificationPending;
    final busy = auth.status == AuthStatus.loading;
    final error = _error ?? (auth.status == AuthStatus.error ? auth.errorMessage : null);

    ref.listen<AuthState>(authStateNotifierProvider, (prev, next) {
      if (next.status == AuthStatus.authenticated) context.go(RouteNames.splash);
    });

    return Scaffold(
      backgroundColor: p.ground,
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // ── الرأس ──
          Container(
            decoration: const BoxDecoration(gradient: Rv.heroGradient, borderRadius: BorderRadius.vertical(bottom: Radius.circular(36))),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 6, 24, 30),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  IconButton(
                    onPressed: () {
                      if (code) return notifier.cancelVerification();
                      context.canPop() ? context.pop() : context.go('/onboarding');
                    },
                    icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                  ),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 8),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const AnimatedRvMark(width: 70, color: RvBrand.cream, loop: false),
                      const SizedBox(height: 18),
                      Text(code ? 'تحقّق من بريدك' : 'افتح متجرك\nمجانًا',
                          style: const TextStyle(fontFamily: 'Zain', fontWeight: FontWeight.w800, fontSize: 38, height: 1.15, color: Colors.white)),
                      const SizedBox(height: 10),
                      Text(
                        code
                            ? 'أرسلنا رمزًا إلى ${notifier.pendingEmail ?? 'بريدك'}. اكتبه، ثم نختار قالب متجرك.'
                            : 'حسابك أولًا، ثم تختار قالبك وباقتك ويصير متجرك جاهزًا برابطه — كل ذلك من هنا.',
                        style: TextStyle(color: Colors.white.withValues(alpha: .85), height: 1.6),
                      ),
                      if (!code) ...[
                        const SizedBox(height: 16),
                        Wrap(spacing: 6, runSpacing: 6, children: [
                          for (final (i, t) in const [(1, 'حسابك'), (2, 'القالب'), (3, 'الباقة'), (4, 'متجرك')])
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(color: i == 1 ? Colors.white : Colors.white.withValues(alpha: .12), borderRadius: BorderRadius.circular(99)),
                              child: Text('$i · $t', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800, color: i == 1 ? Rv.red : Colors.white70)),
                            ),
                        ]),
                      ],
                    ]),
                  ),
                ]),
              ),
            ),
          ),

          // ── النموذج ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 26, 24, 24),
            child: AutofillGroup(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                if (!code) ...[
                  TextField(controller: _name, textInputAction: TextInputAction.next, autofillHints: const [AutofillHints.name], decoration: _deco(p, 'اسمك', Icons.person_outline_rounded)),
                  const SizedBox(height: 12),
                  TextField(controller: _business, textInputAction: TextInputAction.next, decoration: _deco(p, 'اسم نشاطك التجاري (اختياري)', Icons.store_mall_directory_outlined)),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    decoration: _deco(p, 'البريد الإلكتروني', Icons.alternate_email_rounded),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _password,
                    obscureText: _hide,
                    autofillHints: const [AutofillHints.newPassword],
                    onSubmitted: (_) => _submit(),
                    decoration: _deco(p, 'كلمة المرور (٨ خانات أو أكثر)', Icons.lock_outline_rounded).copyWith(
                      suffixIcon: IconButton(icon: Icon(_hide ? Icons.visibility_outlined : Icons.visibility_off_outlined), onPressed: () => setState(() => _hide = !_hide)),
                    ),
                  ),
                ] else
                  TextField(
                    controller: _code,
                    autofocus: true,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    onSubmitted: (_) => _submit(),
                    style: const TextStyle(fontSize: 28, letterSpacing: 12, fontWeight: FontWeight.w700),
                    decoration: _deco(p, 'رمز التحقق', Icons.mark_email_read_outlined).copyWith(counterText: ''),
                  ),
                if (error != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: p.dangerSubtle, borderRadius: BorderRadius.circular(14)),
                    child: Row(children: [
                      Icon(Icons.error_outline_rounded, color: p.danger, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(error, style: TextStyle(color: p.danger))),
                    ]),
                  ),
                ],
                const SizedBox(height: 20),
                FilledButton(
                  onPressed: busy ? null : _submit,
                  style: FilledButton.styleFrom(backgroundColor: Rv.red, minimumSize: const Size(0, 56), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))),
                  child: busy
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                      : Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                          Text(code ? 'تأكيد ومتابعة إلى متجري' : 'أنشئ حسابي وتابع', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                          const SizedBox(width: 6),
                          const Icon(Icons.arrow_back_rounded, size: 20),
                        ]),
                ),
                if (code)
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    TextButton(
                      onPressed: () async {
                        await notifier.resendCode();
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أُعيد إرسال الرمز')));
                      },
                      child: const Text('إعادة الإرسال'),
                    ),
                    TextButton(onPressed: notifier.cancelVerification, child: const Text('تعديل البريد')),
                  ])
                else ...[
                  const SizedBox(height: 14),
                  Text('بإنشاء الحساب توافق على شروط الاستخدام وسياسة الخصوصية.', textAlign: TextAlign.center, style: AppTypography.caption.copyWith(color: p.inkFaint)),
                  const SizedBox(height: 6),
                  TextButton(onPressed: () => context.go(RouteNames.login), child: const Text('لدي حساب — تسجيل الدخول')),
                ],
              ]),
            ),
          ),
        ]),
      ),
    );
  }

  InputDecoration _deco(AzmPalette p, String label, IconData icon) => InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: p.surfaceRaised,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: p.hairline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: p.hairline)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Rv.red, width: 1.6)),
      );
}
