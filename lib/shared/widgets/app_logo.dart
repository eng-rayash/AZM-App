import 'package:flutter/material.dart';

import '../../core/theme/app_typography.dart';
import '../../core/theme/neu_colors.dart';

/// RVIOS Official Brand Logo & Typography Component
class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 64,
    this.showText = true,
    this.isDark = false,
    this.useFullBanner = false,
  });

  /// Logo Icon Size
  final double size;

  /// Whether to display brand text alongside logo icon
  final bool showText;

  /// Dark mode toggle
  final bool isDark;

  /// Whether to use full logo banner image asset
  final bool useFullBanner;

  @override
  Widget build(BuildContext context) {
    if (useFullBanner) {
      return Image.asset(
        'assets/images/logo_full.png',
        width: size * 3.5,
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => _buildTextLogo(),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Brand Logo Icon
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(size * 0.24),
            boxShadow: [
              BoxShadow(
                color: NeuColors.primary.withValues(alpha: 0.3),
                blurRadius: size * 0.25,
                offset: Offset(0, size * 0.1),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(size * 0.24),
            child: Image.asset(
              'assets/images/logo_icon.png',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => Image.asset(
                'assets/icon.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),

        if (showText) ...[
          SizedBox(height: size * 0.2),

          // English Title (Yapari Bold)
          Text(
            'RVIOS',
            style: TextStyle(
              fontFamily: 'Yapari',
              fontSize: size * 0.42,
              fontWeight: FontWeight.w700,
              letterSpacing: 3.0,
              color: isDark ? NeuColors.textPrimaryDark : NeuColors.primary,
            ),
          ),

          // Arabic Title (RTL Maghfira)
          Text(
            'ريفيوس',
            style: TextStyle(
              fontFamily: AppTypography.fontFamilyRTLMaghfira,
              fontSize: size * 0.38,
              fontWeight: FontWeight.w400,
              color: isDark ? NeuColors.gold : NeuColors.primaryDark,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTextLogo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'RVIOS',
          style: TextStyle(
            fontFamily: 'Yapari',
            fontSize: size * 0.5,
            fontWeight: FontWeight.w700,
            color: isDark ? NeuColors.textPrimaryDark : NeuColors.primary,
          ),
        ),
        Text(
          'ريفيوس',
          style: TextStyle(
            fontFamily: AppTypography.fontFamilyRTLMaghfira,
            fontSize: size * 0.45,
            color: isDark ? NeuColors.gold : NeuColors.primaryDark,
          ),
        ),
      ],
    );
  }
}