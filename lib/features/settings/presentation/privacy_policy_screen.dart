import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'سياسة الخصوصية وحماية البيانات',
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
          child: SingleChildScrollView(
            padding: AppSpacing.screen,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NeuCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.privacy_tip_rounded,
                        color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                        size: 48,
                      ),
                      AppSpacing.gapMd,
                      Text(
                        'وثيقة السرية وحماية بيانات المستخدمين لـ "مديري"',
                        style: (isDark ? AppTypography.h4Dark : AppTypography.h4).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.gapSm,
                      Text(
                        'آخر تحديث: يونيو ٢٠٢٦',
                        style: isDark ? AppTypography.captionDark : AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapXl,

                _buildSection(
                  title: '١. بنية العمل المحلي الكامل (Offline-First)',
                  content: 'تطبيق "مديري" مبني على مبدأ الخصوصية المطلقة كأولوية قصوى. جميع مذكراتك، مهامك، اجتماعاتك، ومستنداتك يتم تخزينها محلياً وبشكل مشفر بالكامل على جهازك الشخصي. لا نقوم برفع أو مشاركة أو معالجة أي بيانات خاصة بك على خوادم خارجية إلا إذا اخترت صراحة تفعيل خيار "الحساب والتحقق" وربطه بـ Supabase للنسخ الاحتياطي السحابي الخاص بك.',
                  isDark: isDark,
                ),
                AppSpacing.gapLg,

                _buildSection(
                  title: '٢. تشفير قواعد البيانات والملفات',
                  content: 'تخضع قواعد البيانات المحلية (Drift SQLite) للتشفير القوي ثنائي المفاتيح باستخدام محرك SQLCipher والتشفير العسكري AES256. مفتاح التشفير يتم توليده بشكل عشوائي وفريد على جهازك خلال التشغيل الأول، ويُحفظ بشكل آمن تماماً داخل مساحة التخزين الآمنة للنظام (Keystore لـ Android و Keychain لـ iOS) ولا يمكن لأي تطبيق آخر الوصول إليه.',
                  isDark: isDark,
                ),
                AppSpacing.gapLg,

                _buildSection(
                  title: '٣. الأذونات وصلاحيات الوصول واستخدامها',
                  content: '• المقاييس الحيوية (Biometric / البصمة): تُستخدم حصرياً لتسهيل وتسريع التحقق من هويتك عند فتح التطبيق، ولا يتم تخزين بيانات البصمة إطلاقاً داخل التطبيق وإنما تُدار بالكامل عبر نظام التشغيل.\n'
                      '• الكاميرا والملفات: تُطلب هذه الصلاحية فقط لتمكينك من مسح المستندات ضوئياً وحفظ المرفقات والمستندات الورقية الخاصة بك بداخل الأرشيف التنفيذي للجهاز.\n'
                      '• الإشعارات: تُستخدم لإرسال تنبيهات وتذكيرات بالمهام والاجتماعات الهامة الخاصة بك.',
                  isDark: isDark,
                ),
                AppSpacing.gapLg,

                _buildSection(
                  title: '٤. النسخ الاحتياطي الاختياري والمزامنة السحابية',
                  content: 'يوفر التطبيق ميزتين للنسخ الاحتياطي:\n'
                      '١. النسخ المحلي المشفر: يتم تشفير البيانات وتصديرها كملف مشفر تحفظه في مكان آمن من اختيارك.\n'
                      '٢. النسخ السحابي عبر Supabase: في حال تسجيل حسابك، يتم تخزين البيانات بشكل آمن ومحمي في خوادم Supabase تحت إشراف حسابك الخاص ووفقاً لمعايير أمان البنية السحابية الصارمة للتطبيق.',
                  isDark: isDark,
                ),
                AppSpacing.gapLg,

                _buildSection(
                  title: '٥. حقوق المستخدم والتحكم الكامل بالبيانات',
                  content: 'للمستخدم الحق الكامل والسيادة المطلقة على بياناته. يمكنك في أي وقت:\n'
                      '• حذف كافة البيانات المحلية والسحابية بشكل نهائي وفوري بضغطة زر واحدة من لوحة الإعدادات.\n'
                      '• تصدير نسخة كاملة من بياناتك وملفاتك بصيغة مشفرة أو كملفات Excel وتقارير PDF لاستخدامها خارج التطبيق.',
                  isDark: isDark,
                ),
                AppSpacing.gapXxl,

                SizedBox(
                  width: double.infinity,
                  child: NeuButton(
                    label: 'فهمت وأوافق',
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: () => context.pop(),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required String content,
    required bool isDark,
  }) {
    return NeuCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
            ),
          ),
          AppSpacing.gapSm,
          Text(
            content,
            style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(
              height: 1.5,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
