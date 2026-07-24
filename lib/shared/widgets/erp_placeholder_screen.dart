import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/neu_colors.dart';
import '../../core/theme/app_typography.dart';
import '../widgets/neu_card.dart';

/// ERP Placeholder Screen — shown for modules under active development.
///
/// Displays a consistent "coming soon" or "under construction" message
/// while the full feature is being built. All new ERP modules start here.
class ErpPlaceholderScreen extends StatelessWidget {
  const ErpPlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
    this.comingSoon = true,
    this.subtitle,
  });

  final String title;
  final IconData icon;
  final bool comingSoon;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textPrimary = NeuColors.textPrimaryFor(
      Theme.of(context).brightness,
    );
    final textSecondary = NeuColors.textSecondaryFor(
      Theme.of(context).brightness,
    );

    return Scaffold(
      backgroundColor: NeuColors.background(Theme.of(context).brightness),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.pop(),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: textPrimary,
          ),
        ),
        title: Text(
          title,
          style: AppTypography.headingSmall.copyWith(
            color: textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: NeuCard(
            isDark: isDark,
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        NeuColors.navyDeep,
                        NeuColors.navyMid,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(22),
                    boxShadow: [
                      BoxShadow(
                        color: NeuColors.navyDeep.withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 44,
                  ),
                ),

                const SizedBox(height: 28),

                // Title
                Text(
                  title,
                  style: AppTypography.headingMedium.copyWith(
                    color: textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 12),

                // Subtitle
                Text(
                  subtitle ??
                      (comingSoon
                          ? 'هذه الوحدة قيد التطوير\nسيتم إطلاقها قريباً'
                          : 'هذه الوحدة جاهزة للبيانات\nالواجهة الكاملة قادمة قريباً'),
                  style: AppTypography.bodyMedium.copyWith(
                    color: textSecondary,
                    height: 1.6,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 28),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: comingSoon
                        ? NeuColors.warning.withValues(alpha: 0.12)
                        : NeuColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: comingSoon
                          ? NeuColors.warning.withValues(alpha: 0.3)
                          : NeuColors.success.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        comingSoon
                            ? Icons.construction_rounded
                            : Icons.check_circle_rounded,
                        color: comingSoon
                            ? NeuColors.warning
                            : NeuColors.success,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        comingSoon ? 'قيد التطوير' : 'قاعدة البيانات جاهزة',
                        style: AppTypography.labelMedium.copyWith(
                          color: comingSoon
                              ? NeuColors.warning
                              : NeuColors.success,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Back button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => context.pop(),
                    icon: const Icon(Icons.arrow_back_rounded),
                    label: const Text('العودة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: NeuColors.navyDeep,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}