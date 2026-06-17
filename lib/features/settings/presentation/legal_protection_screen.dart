import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';

class LegalProtectionScreen extends StatelessWidget {
  const LegalProtectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? NeuColors.bgColorDark : NeuColors.bgColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'الحماية وشروط الاستخدام',
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
                // Header Card
                NeuCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.gavel_rounded,
                        color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                        size: 48,
                      ),
                      AppSpacing.gapMd,
                      Text(
                        'اتفاقية الاستخدام وحماية الملكية الفكرية لتطبيق "مديري"',
                        style: (isDark ? AppTypography.h4Dark : AppTypography.h4).copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      AppSpacing.gapSm,
                      Text(
                        'إصدار الترخيص القانوني المعتمد',
                        style: isDark ? AppTypography.captionDark : AppTypography.caption,
                      ),
                    ],
                  ),
                ),
                AppSpacing.gapXl,

                // Section 1: Copyright
                _buildSection(
                  title: 'حقوق النشر والملكية الفكرية ©',
                  content: 'جميع الحقوق محفوظة لتطبيق "مديري" لعام ٢٠٢٦. إن الواجهات البرمجية، الأكواد المصدرية، التصاميم الهيكلية والجمالية (Executive Neumorphic Design System)، الشعارات، والأيقونات الرسمية هي ملكية فكرية حصرية ومحمية بموجب قوانين حماية حقوق الملكية الفكرية الدولية وقوانين العلامات التجارية والبرمجيات.',
                  isDark: isDark,
                ),
                AppSpacing.gapLg,

                // Section 2: License Terms
                _buildSection(
                  title: 'شروط الترخيص والاستخدام الفردي',
                  content: 'يُرخص هذا التطبيق للاستخدام الشخصي والتنفيذي المباشر للمستخدم. يُمنع منعاً باتاً:\n'
                      '• هندسة الكود برمجياً أو محاولة فك التشفير لقواعد البيانات المحلية.\n'
                      '• نسخ الواجهات الرسومية المبتكرة للتطبيق وإعادة استخدامها تجارياً.\n'
                      '• إعادة توزيع أو بيع التطبيق أو أي جزء منه دون إذن مسبق ومكتوب من المطور.',
                  isDark: isDark,
                ),
                AppSpacing.gapLg,

                // Section 3: Developer Info
                _buildSection(
                  title: 'معلومات التطوير والمسؤولية القانونية',
                  content: '• تطوير وإشراف: المهندس رياش البريهي (Eng: Rayash Albureihi).\n'
                      '• إخلاء المسؤولية: تم تصميم التطبيق كأداة لتنظيم وإدارة المهام والاجتماعات للمدراء التنفيذيين. لا يتحمل المطور أي مسؤولية عن فقدان البيانات الناتج عن سوء استخدام الجهاز، أو عمل فورمات للهاتف دون حفظ نسخة احتياطية مشفرة.',
                  isDark: isDark,
                ),
                AppSpacing.gapLg,

                AppSpacing.gapXxl,

                SizedBox(
                  width: double.infinity,
                  child: NeuButton(
                    label: 'إغلاق وموافق',
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
