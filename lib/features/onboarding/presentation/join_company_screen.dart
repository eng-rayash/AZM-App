import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/app_typography.dart';

/// RVIOS — Join Company Screen
///
/// يسمح للموظف بالانضمام لشركة موجودة عبر:
///   1. كود الشركة + كود الموظف (مولّد من المسؤول)
///   2. رابط الدعوة (token link)
class JoinCompanyScreen extends ConsumerStatefulWidget {
  const JoinCompanyScreen({super.key});

  @override
  ConsumerState<JoinCompanyScreen> createState() => _JoinCompanyScreenState();
}

class _JoinCompanyScreenState extends ConsumerState<JoinCompanyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabCtrl;

  // â”€â”€ Tab 1: Code-based â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final _companyCodeCtrl = TextEditingController();
  final _employeeCodeCtrl = TextEditingController();
  final _tempPasswordCtrl = TextEditingController();
  bool _passwordVisible = false;

  // â”€â”€ Tab 2: Link-based â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  final _inviteLinkCtrl = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _companyCodeCtrl.dispose();
    _employeeCodeCtrl.dispose();
    _tempPasswordCtrl.dispose();
    _inviteLinkCtrl.dispose();
    super.dispose();
  }

  Future<void> _joinWithCode() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500)); // simulate
    setState(() => _isLoading = false);
    if (mounted) context.go('/dashboard');
  }

  Future<void> _joinWithLink() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(milliseconds: 1500));
    setState(() => _isLoading = false);
    if (mounted) context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text('الانضمام لشركة', style: AppTypography.h3),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor:
            isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
        bottom: TabBar(
          controller: _tabCtrl,
          labelColor: NeuColors.primary,
          unselectedLabelColor:
              isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
          indicatorColor: NeuColors.primary,
          indicatorWeight: 2,
          labelStyle: const TextStyle(
            fontFamily: 'Panorama',
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'كود الموظف'),
            Tab(text: 'رابط الدعوة'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          // ── Tab 1: Code-based ───────────────────────────────────
          SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                // Info Card
                _InfoCard(
                  icon: Icons.badge_outlined,
                  title: 'كيف أحصل على الأكواد؟',
                  body:
                      'اطلب من مسؤول الشركة أن يرسل لك Company ID وEmployee Code والكلمة السرية المؤقتة.',
                ),

                const SizedBox(height: 24),

                _JoinTextField(
                  id: 'field_company_code',
                  label: 'Company ID',
                  hint: 'مثال: CMP-8X7Q2K',
                  controller: _companyCodeCtrl,
                  icon: Icons.business_outlined,
                  isUpperCase: true,
                ),
                const SizedBox(height: 14),

                _JoinTextField(
                  id: 'field_employee_code',
                  label: 'Employee Code',
                  hint: 'مثال: EMP-00215',
                  controller: _employeeCodeCtrl,
                  icon: Icons.badge_outlined,
                  isUpperCase: true,
                ),
                const SizedBox(height: 14),

                _JoinTextField(
                  id: 'field_temp_password',
                  label: 'الكلمة السرية المؤقتة',
                  controller: _tempPasswordCtrl,
                  icon: Icons.lock_outline,
                  obscureText: !_passwordVisible,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _passwordVisible
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: NeuColors.textHint,
                    ),
                    onPressed: () =>
                        setState(() => _passwordVisible = !_passwordVisible),
                  ),
                ),

                const SizedBox(height: 32),

                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: NeuColors.primary,
                        ),
                      )
                    : _JoinButton(
                        id: 'btn_join_with_code',
                        label: 'انضم إلى الشركة',
                        onTap: _joinWithCode,
                      ),
              ],
            ),
          ),

          // ── Tab 2: Link-based ───────────────────────────────────
          SingleChildScrollView(
            padding:
                const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),

                _InfoCard(
                  icon: Icons.link_rounded,
                  title: 'رابط الدعوة',
                  body:
                      'الصق رابط الدعوة الذي أرسله لك مسؤول الشركة عبر البريد أو واتساب.',
                ),

                const SizedBox(height: 24),

                _JoinTextField(
                  id: 'field_invite_link',
                  label: 'رابط الدعوة',
                  hint: 'https://app.rvios.com/join/...',
                  controller: _inviteLinkCtrl,
                  icon: Icons.link_rounded,
                  keyboardType: TextInputType.url,
                ),

                const SizedBox(height: 32),

                _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: NeuColors.primary,
                        ),
                      )
                    : _JoinButton(
                        id: 'btn_join_with_link',
                        label: 'تحقق من الرابط',
                        onTap: _joinWithLink,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Info Card
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NeuColors.primaryTint,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: NeuColors.primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: NeuColors.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Panorama',
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: NeuColors.primary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: TextStyle(
                    fontFamily: 'Panorama',
                    fontSize: 12,
                    color: isDark
                        ? NeuColors.textSecondaryDark
                        : NeuColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Join TextField
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _JoinTextField extends StatelessWidget {
  const _JoinTextField({
    required this.id,
    required this.label,
    required this.controller,
    required this.icon,
    this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.isUpperCase = false,
  });

  final String id;
  final String label;
  final String? hint;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final bool isUpperCase;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isDark ? NeuColors.borderDark : NeuColors.border),
      ),
      child: TextFormField(
        key: Key(id),
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textDirection: TextDirection.ltr,
        style: TextStyle(
          fontFamily: 'Panorama',
          fontWeight: FontWeight.w600,
          letterSpacing: 1,
          color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
        ),
        onChanged: isUpperCase
            ? (v) {
                final upper = v.toUpperCase();
                if (upper != v) {
                  controller.value = controller.value.copyWith(text: upper);
                }
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: NeuColors.primary, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: TextStyle(
            color: isDark
                ? NeuColors.textSecondaryDark
                : NeuColors.textSecondary,
            fontFamily: 'Panorama',
          ),
          hintStyle: TextStyle(
            color: isDark ? NeuColors.textHintDark : NeuColors.textHint,
            fontFamily: 'Panorama',
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Join Button
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _JoinButton extends StatelessWidget {
  const _JoinButton({
    required this.id,
    required this.label,
    required this.onTap,
  });

  final String id;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        key: Key(id),
        onPressed: onTap,
        icon: const Icon(Icons.login_rounded, color: Colors.white),
        label: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Panorama',
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: NeuColors.primary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}