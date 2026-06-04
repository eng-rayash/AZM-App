import 'package:flutter/material.dart';

import '../../../core/services/remote_config_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/neu_colors.dart';
import '../../../shared/widgets/neu_card.dart';

class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final message = RemoteConfigService.instance.maintenanceMessage;

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
                      'صيانة النظام قيد التنفيذ',
                      style: isDark ? AppTypography.h2Dark : AppTypography.h2,
                      textAlign: TextAlign.center,
                    ),
                    AppSpacing.gapMd,

                    NeuCard(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(
                            Icons.construction_rounded,
                            color: isDark ? NeuColors.goldAccent : NeuColors.navyDeep,
                            size: 48,
                          ),
                          AppSpacing.gapLg,
                          Text(
                            message,
                            style: (isDark ? AppTypography.bodyDark : AppTypography.body).copyWith(
                              height: 1.5,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          AppSpacing.gapMd,
                          Text(
                            'يرجى إبقاء التطبيق مغلقاً والتحقق لاحقاً. شكراً لصبركم وتفهمكم.',
                            style: (isDark ? AppTypography.captionDark : AppTypography.caption).copyWith(
                              color: isDark ? NeuColors.textSecondaryDark : NeuColors.textSecondary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
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
