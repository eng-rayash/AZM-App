import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/enums.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../features/company/providers/company_providers.dart';

/// RVIOS — Pricing & Subscription Screen
///
/// Displays all available plans with features, pricing, and upgrade CTAs.
/// Highlights the current plan and allows upgrading/downgrading.
class PricingScreen extends ConsumerWidget {
  const PricingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final company = ref.watch(activeCompanyProvider);
    final currentPlan = company != null
        ? PlanType.fromValue(company.planType)
        : PlanType.freePersonal;

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close_rounded,
              color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          'اختر باقتك',
          style: TextStyle(
            fontFamily: 'Panorama',
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
          ),
        ),
        centerTitle: true,
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // â”€â”€ Header â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Text(
                'قدرات بلا حدود لإدارة أعمالك',
                style: TextStyle(
                  fontFamily: 'Panorama',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                'ابدأ مجاناً وقم بالترقية عند الحاجة',
                style: TextStyle(
                  fontFamily: 'Panorama',
                  fontSize: 14,
                  color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // â”€â”€ Plan Cards â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              ...PlanType.values.map((plan) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _PlanCard(
                      plan: plan,
                      isCurrentPlan: plan == currentPlan,
                      isDark: isDark,
                    ),
                  )),

              const SizedBox(height: 16),

              // â”€â”€ FAQ â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              _FaqSection(isDark: isDark),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// Plan Card
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.isCurrentPlan,
    required this.isDark,
  });

  final PlanType plan;
  final bool isCurrentPlan;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final isPopular = plan == PlanType.business;
    final isPremium = plan == PlanType.enterprise;

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: isCurrentPlan
                ? NeuColors.primaryTint
                : isDark
                    ? NeuColors.surfaceDark
                    : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isCurrentPlan
                  ? NeuColors.primary
                  : isPopular
                      ? NeuColors.gold
                      : isDark
                          ? NeuColors.borderDark
                          : NeuColors.border,
              width: isCurrentPlan || isPopular ? 2 : 1,
            ),
            boxShadow: isPopular
                ? [
                    BoxShadow(
                      color: NeuColors.gold.withValues(alpha: 0.2),
                      blurRadius: 20,
                      spreadRadius: 2,
                    )
                  ]
                : null,
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Plan header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _planColor(plan).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_planIcon(plan),
                        color: _planColor(plan), size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.arabicLabel,
                          style: TextStyle(
                            fontFamily: 'Panorama',
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? NeuColors.textPrimaryDark
                                : NeuColors.textPrimary,
                          ),
                        ),
                        Text(
                          plan.isUnlimited
                              ? 'مستخدمون غير محدودون'
                              : 'حتى ${plan.maxUsers} مستخدم',
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
                  // Price
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _planPrice(plan),
                        style: TextStyle(
                          fontFamily: 'Panorama',
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: _planColor(plan),
                        ),
                      ),
                      if (plan != PlanType.freePersonal)
                        const Text(
                          'ريال/شهر',
                          style: TextStyle(
                            fontFamily: 'Panorama',
                            fontSize: 11,
                            color: NeuColors.textHint,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 16),
              Divider(color: isDark ? NeuColors.borderDark : NeuColors.border),
              const SizedBox(height: 12),

              // Features
              ..._planFeatures(plan).map((feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle_rounded,
                            color: NeuColors.primary, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontFamily: 'Panorama',
                              fontSize: 13,
                              color: isDark
                                  ? NeuColors.textSecondaryDark
                                  : NeuColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 16),

              // CTA Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  key: Key('btn_plan_${plan.name}'),
                  onPressed: isCurrentPlan
                      ? null
                      : () => _showPaymentDialog(context, plan),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isCurrentPlan
                        ? Colors.grey.shade300
                        : _planColor(plan),
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: Colors.grey.shade200,
                    disabledForegroundColor: Colors.grey.shade500,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: isCurrentPlan ? 0 : 2,
                  ),
                  child: Text(
                    isCurrentPlan
                        ? '✓ باقتك الحالية'
                        : plan == PlanType.freePersonal
                            ? 'ابدأ مجاناً'
                            : 'اشترك الآن',
                    style: const TextStyle(
                      fontFamily: 'Panorama',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Popular badge
        if (isPopular)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: NeuColors.gold,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '⭐ الأكثر طلباً',
                style: TextStyle(
                  fontFamily: 'Panorama',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),

        if (isPremium)
          Positioned(
            top: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFC8A45D), Color(0xFF7A5C2A)],
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                '👑 Enterprise',
                style: TextStyle(
                  fontFamily: 'Panorama',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Color _planColor(PlanType plan) {
    switch (plan) {
      case PlanType.freePersonal: return NeuColors.textHint;
      case PlanType.professional: return NeuColors.primary;
      case PlanType.business: return NeuColors.gold;
      case PlanType.businessPlus: return const Color(0xFF7B1FA2);
      case PlanType.enterprise: return const Color(0xFF1B5E20);
    }
  }

  IconData _planIcon(PlanType plan) {
    switch (plan) {
      case PlanType.freePersonal: return Icons.person_outline_rounded;
      case PlanType.professional: return Icons.business_center_rounded;
      case PlanType.business: return Icons.apartment_rounded;
      case PlanType.businessPlus: return Icons.corporate_fare_rounded;
      case PlanType.enterprise: return Icons.domain_rounded;
    }
  }

  String _planPrice(PlanType plan) {
    switch (plan) {
      case PlanType.freePersonal: return 'مجاني';
      case PlanType.professional: return '149';
      case PlanType.business: return '399';
      case PlanType.businessPlus: return '799';
      case PlanType.enterprise: return 'تواصل معنا';
    }
  }

  /// Shows the subscription/payment bottom sheet for the given plan.
  ///
  /// Currently presents payment options (card / bank transfer / enterprise contact).
  /// Ready to be connected to Stripe / PayTabs / HyperPay when keys are configured.
  void _showPaymentDialog(BuildContext context, PlanType plan) {
    final price = _planPrice(plan);
    final isEnterprise = plan == PlanType.enterprise;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? NeuColors.surfaceDark : Colors.white,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.only(
            top: 16,
            left: 24,
            right: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
          ),
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
              const SizedBox(height: 20),

              // Plan info
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: _planColor(plan).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(_planIcon(plan),
                        color: _planColor(plan), size: 24),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الاشتراك في ${plan.arabicLabel}',
                          style: TextStyle(
                            fontFamily: 'Panorama',
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? NeuColors.textPrimaryDark
                                : NeuColors.textPrimary,
                          ),
                        ),
                        if (!isEnterprise)
                          Text(
                            '$price ريال / شهرياً',
                            style: TextStyle(
                              fontFamily: 'Panorama',
                              fontSize: 13,
                              color: _planColor(plan),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              if (isEnterprise) ...[
                // Enterprise — contact sales
                Text(
                  'للباقة المؤسسية، تواصل مع فريق المبيعات للحصول على سعر مخصص لاحتياجاتك.',
                  style: TextStyle(
                    fontFamily: 'Panorama',
                    fontSize: 14,
                    color: isDark
                        ? NeuColors.textSecondaryDark
                        : NeuColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    key: const Key('btn_contact_sales'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                              'سيتواصل معك فريق المبيعات قريباً'),
                          backgroundColor: NeuColors.primary,
                        ),
                      );
                    },
                    icon: const Icon(Icons.support_agent_rounded,
                        color: Colors.white),
                    label: const Text(
                      'تواصل مع فريق المبيعات',
                      style: TextStyle(
                        fontFamily: 'Panorama',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NeuColors.primary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                ),
              ] else ...[
                // Standard payment options
                _PaymentOption(
                  icon: Icons.credit_card_rounded,
                  label: 'بطاقة ائتمانية / مدى',
                  subtitle: 'Visa · Mastercard · Mada',
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content:
                            Text('سيتم ربط بوابة الدفع قريباً'),
                        backgroundColor: NeuColors.primary,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        margin: const EdgeInsets.all(16),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 10),
                _PaymentOption(
                  icon: Icons.account_balance_rounded,
                  label: 'تحويل بنكي',
                  subtitle: 'IBAN · SWIFT',
                  onTap: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'تفاصيل الحساب البنكي ستُرسل على بريدك الإلكتروني'),
                        backgroundColor: NeuColors.primary,
                      ),
                    );
                  },
                ),
              ],

              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    fontFamily: 'Panorama',
                    color: isDark
                        ? NeuColors.textSecondaryDark
                        : NeuColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<String> _planFeatures(PlanType plan) {
    switch (plan) {
      case PlanType.freePersonal:
        return [
          'لوحة تحكم شخصية',
          'إدارة المهام والتقويم',
          'الاجتماعات والملاحظات',
          'الأرشيف الشخصي',
          'تذكيرات ذكية',
        ];
      case PlanType.professional:
        return [
          'كل مزايا المجاني',
          'حتى 10 مستخدمين',
          'الشؤون المالية والفواتير',
          'إدارة العملا، والمشاريع',
          'التقارير والإحصائيات',
          'دومين workspace مخصص',
        ];
      case PlanType.business:
        return [
          'كل مزايا Professional',
          'حتى 50 مستخدم',
          'الموارد البشرية الكاملة',
          'الرواتب والحضور',
          'المتابعات والتوجيهات',
          'نظام الموافقات',
          'دعم أولوية',
        ];
      case PlanType.businessPlus:
        return [
          'كل مزايا Business',
          'حتى 200 مستخدم',
          'إدارة الفروع المتعددة',
          'تقارير متقدمة',
          'API كامل',
          'دعم مخصص 24/7',
        ];
      case PlanType.enterprise:
        return [
          'مستخدمون غير محدودون',
          'SSO وAD Integration',
          'Custom Domain',
          'SLA مضمون 99.9%',
          'فريق تقني مخصص',
          'تخصيص كامل للنظام',
        ];
    }
  }
}

// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
// FAQ Section
// â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _FaqSection extends StatelessWidget {
  const _FaqSection({required this.isDark});
  final bool isDark;

  static const _faqs = [
    ('هل يمكنني تغيير الباقة لاحقاً؟',
     'نعم، يمكنك الترقية أو التخفيض في أي وقت. عند الترقية يتم احتساب الفرق حتى نهاية الفترة.'),
    ('ما طرق الدفع المتاحة؟',
     'ندعم البطاقات الائتمانية (Visa/Mastercard)، مدى، Apple Pay، وتحويل بنكي للشركات.'),
    ('هل بياناتي محفوظة عند التخفيض؟',
     'نعم، بياناتك محفوظة دائماً. عند التخفيض يتم تعطيل الميزات الإضافية فقط.'),
    ('هل يوجد عقد ملزم؟',
     'لا، الاشتراك شهري قابل للإلغاء في أي وقت.'),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الأسئلة الشائعة',
          style: TextStyle(
            fontFamily: 'Panorama',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: isDark ? NeuColors.textPrimaryDark : NeuColors.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        ..._faqs.map((faq) => _FaqItem(
              question: faq.$1,
              answer: faq.$2,
              isDark: isDark,
            )),
      ],
    );
  }
}

class _FaqItem extends StatefulWidget {
  const _FaqItem({
    required this.question,
    required this.answer,
    required this.isDark,
  });
  final String question;
  final String answer;
  final bool isDark;

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: widget.isDark ? NeuColors.surfaceDark : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: widget.isDark ? NeuColors.borderDark : NeuColors.border,
        ),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          title: Text(
            widget.question,
            style: TextStyle(
              fontFamily: 'Panorama',
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.isDark
                  ? NeuColors.textPrimaryDark
                  : NeuColors.textPrimary,
            ),
          ),
          trailing: Icon(
            _expanded
                ? Icons.keyboard_arrow_up_rounded
                : Icons.keyboard_arrow_down_rounded,
            color: NeuColors.primary,
          ),
          onExpansionChanged: (val) => setState(() => _expanded = val),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(
                widget.answer,
                style: TextStyle(
                  fontFamily: 'Panorama',
                  fontSize: 13,
                  color: widget.isDark
                      ? NeuColors.textSecondaryDark
                      : NeuColors.textSecondary,
                  height: 1.6,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  const _PaymentOption({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isDark ? NeuColors.borderDark : NeuColors.border,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: NeuColors.primaryTint,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: NeuColors.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Panorama',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? NeuColors.textPrimaryDark
                          : NeuColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
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
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: isDark
                  ? NeuColors.textSecondaryDark
                  : NeuColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}