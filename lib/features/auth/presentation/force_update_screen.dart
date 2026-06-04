import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/services/remote_config_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_button.dart';
import '../../../shared/widgets/neu_card.dart';

class ForceUpdateScreen extends StatelessWidget {
  const ForceUpdateScreen({super.key});

  Future<void> _launchStore() async {
    final url = Uri.parse(RemoteConfigService.instance.storeUrl);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return PopScope(
      canPop: false, // Prevent going back
      child: Scaffold(
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

                    Text(
                      'تحديث إجباري مطلوب',
                      style: isDark ? AppTypography.h2Dark : AppTypography.h2,
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.gapMd,

                    NeuCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Icon(
                            Icons.system_update_rounded,
                            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                            size: 40,
                          ),
                          AppSpacing.gapMd,
                          Text(
                            'الإصدار الحالي للتطبيق لم يعد مدعوماً. يرجى التحديث إلى أحدث إصدار لمتابعة استخدام النظام وإدارة مهامك واجتماعاتك بأمان واستقرار.',
                            style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                    AppSpacing.gapXxl,

                    NeuButton(
                      label: 'تحديث الآن من المتجر',
                      icon: Icons.download_rounded,
                      onPressed: _launchStore,
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
