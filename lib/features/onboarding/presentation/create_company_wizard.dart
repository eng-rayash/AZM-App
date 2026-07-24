import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/constants/enums.dart';
import '../../../core/services/code_generator_service.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../core/theme/app_typography.dart';

/// RVIOS — Create Company Wizard
///
/// Wizard متعدد الخطوات لإنشاء حساب شركة جديد.
///
/// الخطوات:
///   1. بيانات المسؤول (الاسم، البريد، كلمة المرور)
///   2. بيانات الشركة (الاسم، الدولة، النشاط، العملة)
///   3. حجم الشركة (عدد الموظفين)
///   4. اختيار الباقة
///   5. النتيجة (Company ID + Workspace URL)
class CreateCompanyWizard extends ConsumerStatefulWidget {
  const CreateCompanyWizard({super.key});

  @override
  ConsumerState<CreateCompanyWizard> createState() =>
      _CreateCompanyWizardState();
}

class _CreateCompanyWizardState extends ConsumerState<CreateCompanyWizard> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  final int _totalSteps = 4;

  // â”€â”€ Form Controllers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  // Step 1 — Owner
  final _ownerNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _passwordVisible = false;

  // Step 2 — Company
  final _companyNameCtrl = TextEditingController();
  String _selectedCountry = 'SA';
  String _selectedCurrency = 'SAR';
  String _selectedIndustry = '';

  // Step 3 — Size
  int _employeeCount = 1;

  // Step 4 — Plan
  PlanType _selectedPlan = PlanType.business;

  // â”€â”€ Result â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
  String? _generatedCompanyCode;
  String? _generatedWorkspaceSlug;
  bool _isCreating = false;

  @override
  void dispose() {
    _pageController.dispose();
    _ownerNameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _companyNameCtrl.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < _totalSteps - 1) {
      setState(() => _currentStep++);
      _pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      _createCompany();
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      context.pop();
    }
  }

  Future<void> _createCompany() async {
    setState(() => _isCreating = true);

    // Generate codes
    final companyCode = CodeGeneratorService.generateCompanyCode();
    final slug = CodeGeneratorService.generateWorkspaceSlug(
        _companyNameCtrl.text.trim());

    await Future.delayed(const Duration(milliseconds: 1500)); // simulate

    setState(() {
      _generatedCompanyCode = companyCode;
      _generatedWorkspaceSlug = slug;
      _isCreating = false;
      _currentStep = _totalSteps; // show result
    });

    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );
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
          onPressed: _prevStep,
        ),
        title: _currentStep < _totalSteps
            ? Text(
                'إنشاء حساب الشركة',
                style: AppTypography.h3,
              )
            : null,
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: isDark
            ? NeuColors.textPrimaryDark
            : NeuColors.textPrimary,
      ),
      body: Column(
        children: [
          // â”€â”€ Step Indicator â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          if (_currentStep < _totalSteps) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28),
              child: _StepIndicator(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
              ),
            ),
            const SizedBox(height: 8),
          ],

          // â”€â”€ Pages â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _Step1OwnerInfo(
                  nameCtrl: _ownerNameCtrl,
                  emailCtrl: _emailCtrl,
                  passwordCtrl: _passwordCtrl,
                  passwordVisible: _passwordVisible,
                  onTogglePassword: () =>
                      setState(() => _passwordVisible = !_passwordVisible),
                  onNext: _nextStep,
                ),
                _Step2CompanyInfo(
                  nameCtrl: _companyNameCtrl,
                  selectedCountry: _selectedCountry,
                  selectedCurrency: _selectedCurrency,
                  selectedIndustry: _selectedIndustry,
                  onCountryChanged: (v) =>
                      setState(() => _selectedCountry = v),
                  onCurrencyChanged: (v) =>
                      setState(() => _selectedCurrency = v),
                  onIndustryChanged: (v) =>
                      setState(() => _selectedIndustry = v),
                  onNext: _nextStep,
                ),
                _Step3Size(
                  employeeCount: _employeeCount,
                  onChanged: (v) => setState(() => _employeeCount = v),
                  onNext: _nextStep,
                ),
                _Step4Plan(
                  selected: _selectedPlan,
                  onChanged: (p) => setState(() => _selectedPlan = p),
                  onNext: _nextStep,
                  isCreating: _isCreating,
                ),
                // Result page
                _ResultPage(
                  companyName: _companyNameCtrl.text,
                  companyCode: _generatedCompanyCode ?? '',
                  workspaceSlug: _generatedWorkspaceSlug ?? '',
                  ownerName: _ownerNameCtrl.text,
                  onGoToDashboard: () => context.go('/dashboard'),
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
// Step Indicator
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.currentStep,
    required this.totalSteps,
  });
  final int currentStep;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(totalSteps, (i) {
        final isActive = i == currentStep;
        final isDone = i < currentStep;
        return Expanded(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: 4,
            margin: const EdgeInsets.symmetric(horizontal: 3),
            decoration: BoxDecoration(
              color: isDone || isActive
                  ? NeuColors.primary
                  : NeuColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        );
      }),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Step 1 — Owner Info
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _Step1OwnerInfo extends StatelessWidget {
  const _Step1OwnerInfo({
    required this.nameCtrl,
    required this.emailCtrl,
    required this.passwordCtrl,
    required this.passwordVisible,
    required this.onTogglePassword,
    required this.onNext,
  });

  final TextEditingController nameCtrl;
  final TextEditingController emailCtrl;
  final TextEditingController passwordCtrl;
  final bool passwordVisible;
  final VoidCallback onTogglePassword;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('بيانات المسؤول', style: AppTypography.h2),
          const SizedBox(height: 6),
          Text(
            'ستكون أنت المالك الرئيسي للحساب',
            style: AppTypography.body.copyWith(
              color: NeuColors.textSecondary,
            ),
          ),
          const SizedBox(height: 28),

          _RviosTextField(
            id: 'field_owner_name',
            label: 'الاسم الكامل',
            controller: nameCtrl,
            icon: Icons.person_outline,
          ),
          const SizedBox(height: 16),

          _RviosTextField(
            id: 'field_owner_email',
            label: 'البريد الإلكتروني',
            controller: emailCtrl,
            icon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),

          _RviosTextField(
            id: 'field_owner_password',
            label: 'كلمة المرور',
            controller: passwordCtrl,
            icon: Icons.lock_outline,
            obscureText: !passwordVisible,
            suffixIcon: IconButton(
              icon: Icon(
                passwordVisible
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: NeuColors.textHint,
              ),
              onPressed: onTogglePassword,
            ),
          ),

          const SizedBox(height: 32),
          _RviosPrimaryButton(
            id: 'btn_step1_next',
            label: 'التالي',
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Step 2 — Company Info
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _Step2CompanyInfo extends StatelessWidget {
  const _Step2CompanyInfo({
    required this.nameCtrl,
    required this.selectedCountry,
    required this.selectedCurrency,
    required this.selectedIndustry,
    required this.onCountryChanged,
    required this.onCurrencyChanged,
    required this.onIndustryChanged,
    required this.onNext,
  });

  final TextEditingController nameCtrl;
  final String selectedCountry;
  final String selectedCurrency;
  final String selectedIndustry;
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String> onCurrencyChanged;
  final ValueChanged<String> onIndustryChanged;
  final VoidCallback onNext;

  static const _countries = {
    'SA': '🇸🇦 المملكة العربية السعودية',
    'AE': '🇦🇪 الإمارات',
    'KW': '🇰🇼 الكويت',
    'QA': '🇶🇦 قطر',
    'BH': '🇧🇭 البحرين',
    'OM': '🇴🇲 عُمان',
    'EG': '🇪🇬 مصر',
    'JO': '🇯🇴 الأردن',
    'OTHER': '🌐 أخرى',
  };

  static const _currencies = ['SAR', 'AED', 'KWD', 'QAR', 'BHD', 'OMR', 'EGP', 'JOD', 'USD'];

  static const _industries = [
    'تجارة وبيع بالتجزئة',
    'خدمات احترافية',
    'صناعة وتصنيع',
    'تقنية المعلومات',
    'عقارات وإنشاءات',
    'تعليم وتدريب',
    'صحة ورعاية طبية',
    'ضيافة وسياحة',
    'مال وبنوك',
    'نقل ولوجستيات',
    'أخرى',
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('بيانات الشركة', style: AppTypography.h2),
          const SizedBox(height: 6),
          Text(
            'المعلومات الأساسية لمساحة عملك',
            style: AppTypography.body.copyWith(color: NeuColors.textSecondary),
          ),
          const SizedBox(height: 28),

          _RviosTextField(
            id: 'field_company_name',
            label: 'اسم الشركة / المؤسسة',
            controller: nameCtrl,
            icon: Icons.business_outlined,
          ),
          const SizedBox(height: 16),

          // Country Dropdown
          _RviosDropdown<String>(
            id: 'field_country',
            label: 'الدولة',
            value: selectedCountry,
            items: _countries.entries
                .map((e) => DropdownMenuItem(
                      value: e.key,
                      child: Text(e.value),
                    ))
                .toList(),
            onChanged: (v) => onCountryChanged(v!),
          ),
          const SizedBox(height: 16),

          // Currency Dropdown
          _RviosDropdown<String>(
            id: 'field_currency',
            label: 'العملة',
            value: selectedCurrency,
            items: _currencies
                .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                .toList(),
            onChanged: (v) => onCurrencyChanged(v!),
          ),
          const SizedBox(height: 16),

          // Industry Dropdown
          _RviosDropdown<String>(
            id: 'field_industry',
            label: 'القطاع / النشاط',
            value: selectedIndustry.isEmpty ? null : selectedIndustry,
            hint: 'اختر القطاع',
            items: _industries
                .map((i) => DropdownMenuItem(value: i, child: Text(i)))
                .toList(),
            onChanged: (v) => onIndustryChanged(v!),
          ),

          const SizedBox(height: 32),
          _RviosPrimaryButton(
            id: 'btn_step2_next',
            label: 'التالي',
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Step 3 — Company Size
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _Step3Size extends StatelessWidget {
  const _Step3Size({
    required this.employeeCount,
    required this.onChanged,
    required this.onNext,
  });

  final int employeeCount;
  final ValueChanged<int> onChanged;
  final VoidCallback onNext;

  static const _sizes = [
    (1, '1 موظف', 'فردي / عمل حر'),
    (5, '2–5 موظفين', 'فريق صغير'),
    (10, '6–10 موظفين', 'شركة ناشئة'),
    (20, '11–20 موظفاً', 'شركة صغيرة'),
    (50, '21–50 موظفاً', 'شركة متوسطة'),
    (100, '51–100 موظفاً', 'شركة كبيرة'),
    (101, 'أكثر من 100', 'مؤسسة'),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('حجم الشركة', style: AppTypography.h2),
          const SizedBox(height: 6),
          Text(
            'يساعدنا في اقتراح الباقة المناسبة',
            style: AppTypography.body.copyWith(color: NeuColors.textSecondary),
          ),
          const SizedBox(height: 24),

          ..._sizes.map((s) {
            final isSelected = employeeCount == s.$1;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                onTap: () => onChanged(s.$1),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? NeuColors.primaryTint
                        : isDark
                            ? NeuColors.surfaceDark
                            : NeuColors.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? NeuColors.primary
                          : isDark
                              ? NeuColors.borderDark
                              : NeuColors.border,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.$2,
                              style: TextStyle(
                                fontFamily: 'Panorama',
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                                color: isSelected
                                    ? NeuColors.primary
                                    : isDark
                                        ? NeuColors.textPrimaryDark
                                        : NeuColors.textPrimary,
                              ),
                            ),
                            Text(
                              s.$3,
                              style: TextStyle(
                                fontFamily: 'Panorama',
                                fontSize: 12,
                                color: isDark
                                    ? NeuColors.textSecondaryDark
                                    : NeuColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(Icons.check_circle_rounded,
                            color: NeuColors.primary),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),
          _RviosPrimaryButton(
            id: 'btn_step3_next',
            label: 'التالي',
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Step 4 — Plan Selection
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _Step4Plan extends StatelessWidget {
  const _Step4Plan({
    required this.selected,
    required this.onChanged,
    required this.onNext,
    required this.isCreating,
  });

  final PlanType selected;
  final ValueChanged<PlanType> onChanged;
  final VoidCallback onNext;
  final bool isCreating;

  static const _plans = [
    (PlanType.business, 'أعمال', 'حتى 20 مستخدماً', 'âœ… HRM âœ… مالية âœ… مشاريع', false),
    (PlanType.businessPlus, 'أعمال بلس', 'حتى 100 مستخدم', 'âœ… كل الأعمال + تقارير متقدمة', false),
    (PlanType.enterprise, 'مؤسسي', 'غير محدود', 'âœ… فروع + API + SSO + Audit Logs', true),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('اختر الباقة', style: AppTypography.h2),
          const SizedBox(height: 6),
          Text(
            'يمكنك البد، بالتجربة المجانية ثم الترقية',
            style: AppTypography.body.copyWith(color: NeuColors.textSecondary),
          ),
          const SizedBox(height: 8),

          // Free trial badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: NeuColors.goldTint,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: NeuColors.gold),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_outline, color: NeuColors.gold, size: 16),
                const SizedBox(width: 6),
                Text(
                  '${AppConstants.trialDays} يوم مجاناً لجميع الباقات',
                  style: const TextStyle(
                    color: NeuColors.goldDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                    fontFamily: 'Panorama',
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          ..._plans.map((p) {
            final isSelected = selected == p.$1;
            final isEnterprise = p.$5;

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: InkWell(
                onTap: () => onChanged(p.$1),
                borderRadius: BorderRadius.circular(16),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? NeuColors.primary
                        : isDark
                            ? NeuColors.surfaceDark
                            : NeuColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected
                          ? NeuColors.primary
                          : isEnterprise
                              ? NeuColors.gold
                              : isDark
                                  ? NeuColors.borderDark
                                  : NeuColors.border,
                      width: isSelected || isEnterprise ? 2 : 1,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: NeuColors.primary.withValues(alpha: 0.25),
                              blurRadius: 16,
                              offset: const Offset(0, 4),
                            )
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            p.$2,
                            style: TextStyle(
                              fontFamily: 'Panorama',
                              fontWeight: FontWeight.w700,
                              fontSize: 17,
                              color: isSelected
                                  ? Colors.white
                                  : isEnterprise
                                      ? NeuColors.gold
                                      : isDark
                                          ? NeuColors.textPrimaryDark
                                          : NeuColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white.withValues(alpha: 0.2)
                                  : NeuColors.primaryTint,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              p.$3,
                              style: TextStyle(
                                fontSize: 11,
                                color: isSelected
                                    ? Colors.white
                                    : NeuColors.primary,
                                fontFamily: 'Panorama',
                              ),
                            ),
                          ),
                          const Spacer(),
                          if (isSelected)
                            const Icon(Icons.check_circle,
                                color: Colors.white, size: 22),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        p.$4,
                        style: TextStyle(
                          fontFamily: 'Panorama',
                          fontSize: 13,
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.85)
                              : isDark
                                  ? NeuColors.textSecondaryDark
                                  : NeuColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const SizedBox(height: 24),
          isCreating
              ? const Center(
                  child: CircularProgressIndicator(
                    color: NeuColors.primary,
                  ),
                )
              : _RviosPrimaryButton(
                  id: 'btn_create_company_final',
                  label: 'إنشاء الشركة',
                  icon: Icons.business_center_outlined,
                  onTap: onNext,
                ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Result Page
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ResultPage extends StatelessWidget {
  const _ResultPage({
    required this.companyName,
    required this.companyCode,
    required this.workspaceSlug,
    required this.ownerName,
    required this.onGoToDashboard,
  });

  final String companyName;
  final String companyCode;
  final String workspaceSlug;
  final String ownerName;
  final VoidCallback onGoToDashboard;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
      child: Column(
        children: [
          const SizedBox(height: 20),

          // â”€â”€ Success Icon â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Container(
            width: 80,
            height: 80,
            decoration: const BoxDecoration(
              color: NeuColors.success,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.check_rounded,
                color: Colors.white, size: 44),
          ),

          const SizedBox(height: 20),

          Text(
            'تم إنشاء شركتك بنجاح! 🎉',
            style: AppTypography.h2,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 8),

          Text(
            'مرحباً $ownerName، مساحة عملك جاهزة',
            style: AppTypography.body.copyWith(
              color: isDark
                  ? NeuColors.textSecondaryDark
                  : NeuColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // â”€â”€ Company Details Card â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: isDark ? NeuColors.borderDark : NeuColors.border,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  companyName,
                  style: AppTypography.h3,
                ),
                const SizedBox(height: 16),

                _InfoRow(label: 'Company ID', value: companyCode, canCopy: true),
                const SizedBox(height: 12),
                _InfoRow(
                  label: 'رابط Workspace',
                  value: 'app.rvios.com/$workspaceSlug',
                  canCopy: true,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Info note
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: NeuColors.goldTint,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: NeuColors.gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.info_outline, color: NeuColors.gold, size: 18),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'احتفظ بـ Company ID، ستحتاجه لدعوة الموظفين للانضمام',
                    style: TextStyle(
                      fontFamily: 'Panorama',
                      fontSize: 12,
                      color: NeuColors.goldDark,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          _RviosPrimaryButton(
            id: 'btn_go_to_dashboard',
            label: 'ادخل إلى لوحة التحكم',
            icon: Icons.dashboard_outlined,
            onTap: onGoToDashboard,
          ),
        ],
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Info Row (copyable)
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.label,
    required this.value,
    this.canCopy = false,
  });

  final String label;
  final String value;
  final bool canCopy;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: isDark
                      ? NeuColors.textSecondaryDark
                      : NeuColors.textSecondary,
                  fontFamily: 'Panorama',
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontFamily: 'Panorama',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: NeuColors.primary,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
        if (canCopy)
          IconButton(
            icon: const Icon(Icons.copy_rounded, size: 18),
            color: NeuColors.primary,
            onPressed: () async {
              await Clipboard.setData(ClipboardData(text: value));
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Row(
                      children: [
                        const Icon(Icons.check_circle_outline,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 8),
                        Text('تم نسخ "$label"'),
                      ],
                    ),
                    backgroundColor: NeuColors.success,
                    duration: const Duration(seconds: 2),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              }
            },
          ),
      ],
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Shared Widgets
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _RviosTextField extends StatelessWidget {
  const _RviosTextField({
    required this.id,
    required this.label,
    required this.controller,
    required this.icon,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
  });

  final String id;
  final String label;
  final TextEditingController controller;
  final IconData icon;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? NeuColors.borderDark : NeuColors.border,
        ),
      ),
      child: TextFormField(
        key: Key(id),
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        textDirection: TextDirection.rtl,
        style: TextStyle(
          fontFamily: 'Panorama',
          color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
        ),
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: NeuColors.primary, size: 20),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          labelStyle: TextStyle(
            color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
            fontFamily: 'Panorama',
          ),
        ),
      ),
    );
  }
}

class _RviosDropdown<T> extends StatelessWidget {
  const _RviosDropdown({
    required this.id,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
    this.hint,
  });

  final String id;
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;
  final String? hint;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDark ? NeuColors.surfaceDark : NeuColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: isDark ? NeuColors.borderDark : NeuColors.border,
        ),
      ),
      child: DropdownButtonFormField<T>(
        key: Key(id),
        initialValue: value,
        hint: hint != null ? Text(hint!) : null,
        items: items,
        onChanged: onChanged,
        isExpanded: true,
        decoration: const InputDecoration(border: InputBorder.none),
        dropdownColor:
            isDark ? NeuColors.surfaceElevatedDark : NeuColors.surfaceElevated,
        style: TextStyle(
          fontFamily: 'Panorama',
          color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
          fontSize: 14,
        ),
      ),
    );
  }
}

class _RviosPrimaryButton extends StatelessWidget {
  const _RviosPrimaryButton({
    required this.id,
    required this.label,
    required this.onTap,
    this.icon,
  });

  final String id;
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton.icon(
        key: Key(id),
        onPressed: onTap,
        icon: icon != null
            ? Icon(icon, size: 20, color: Colors.white)
            : const SizedBox.shrink(),
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