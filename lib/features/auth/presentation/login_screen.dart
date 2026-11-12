import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/design/azm_tokens.dart';
import '../../../core/router/route_names.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/app_logo.dart';
import '../../store_app/kit.dart';
import '../providers/auth_providers.dart';

/// دخول التاجر بحساب عزم سمارت نفسه — ثم رمز البريد إن طلبه الخادم.
///
/// رأس متدرّج بهوية RVIOS، ونموذج واحد بخطوتين: البريد وكلمة المرور، ثم الرمز.
/// «المتابعة بلا حساب» تبقى لمن يريد وحدات الأعمال المحلية وحدها.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _code = TextEditingController();
  bool _hide = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _code.dispose();
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
    final email = _email.text.trim();
    if (!email.contains('@') || _password.text.isEmpty) {
      return setState(() => _error = 'اكتب بريدك وكلمة المرور');
    }
    await n.login(email, _password.text);
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
      if (next.status == AuthStatus.authenticated || next.status == AuthStatus.guest) {
        context.go(RouteNames.splash);
      }
    });

    return Scaffold(
      backgroundColor: p.ground,
      body: SingleChildScrollView(
        child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          // ── الرأس ──
          Container(
            decoration: const BoxDecoration(
              gradient: Rv.heroGradient,
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(36)),
            ),
            child: SafeArea(
              bottom: false,
              child: Stack(children: [
                PositionedDirectional(
                  end: -50,
                  top: -30,
                  child: Container(width: 200, height: 200, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: .07))),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
                      child: const AppLogoMark(size: 40),
                    ),
                    const SizedBox(height: 22),
                    Text(code ? 'تحقّق من بريدك' : 'أدِر متجرك\nمن جوالك',
                        style: const TextStyle(fontFamily: 'Zain', fontWeight: FontWeight.w800, fontSize: 38, height: 1.15, color: Colors.white)),
                    const SizedBox(height: 10),
                    Text(
                      code
                          ? 'أرسلنا رمزًا إلى ${notifier.pendingEmail ?? 'بريدك'}. اكتبه لإكمال الدخول.'
                          : 'ادخل بحسابك في RVIOS — حساب لوحة التحكم نفسه: الطلبات والمنتجات والعملاء والتصميم وأعمالك كلها في مكان واحد.',
                      style: TextStyle(color: Colors.white.withValues(alpha: .82), height: 1.6),
                    ),
                  ]),
                ),
              ]),
            ),
          ),

          // ── النموذج ──
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
            child: AutofillGroup(
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                if (!code) ...[
                  TextField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    textDirection: TextDirection.ltr,
                    autofillHints: const [AutofillHints.email],
                    textInputAction: TextInputAction.next,
                    decoration: _deco(p, 'البريد الإلكتروني', Icons.alternate_email_rounded),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _password,
                    obscureText: _hide,
                    autofillHints: const [AutofillHints.password],
                    onSubmitted: (_) => _submit(),
                    decoration: _deco(p, 'كلمة المرور', Icons.lock_outline_rounded).copyWith(
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
                  style: FilledButton.styleFrom(backgroundColor: Rv.red, minimumSize: const Size(0, 54), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  child: busy
                      ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.4, color: Colors.white))
                      : Text(code ? 'تأكيد الدخول' : 'دخول', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
                if (code) ...[
                  const SizedBox(height: 8),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    TextButton(
                      onPressed: () async {
                        await notifier.resendCode();
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('أُعيد إرسال الرمز')));
                      },
                      child: const Text('إعادة الإرسال'),
                    ),
                    TextButton(onPressed: notifier.cancelVerification, child: const Text('رجوع')),
                  ]),
                ] else ...[
                  const SizedBox(height: 18),
                  Row(children: [
                    Expanded(child: Divider(color: p.hairline)),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text('أو', style: AppTypography.caption.copyWith(color: p.inkFaint))),
                    Expanded(child: Divider(color: p.hairline)),
                  ]),
                  const SizedBox(height: 14),
                  OutlinedButton.icon(
                    onPressed: busy ? null : () => context.push(RouteNames.register),
                    icon: const Icon(Icons.add_business_outlined),
                    label: const Text('حساب جديد ومتجر مجاني'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size(0, 50), foregroundColor: Rv.red, side: BorderSide(color: Rv.red.withValues(alpha: .35)), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  ),
                  const SizedBox(height: 6),
                  TextButton(
                    onPressed: busy ? null : () => ref.read(authStateNotifierProvider.notifier).continueAsGuest(),
                    child: Text('المتابعة بلا حساب — وحدات الأعمال على الجهاز فقط', style: AppTypography.caption.copyWith(color: p.inkMuted)),
                  ),
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
