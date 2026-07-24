import 'package:flutter/material.dart';

import 'app_radius.dart';
import 'app_spacing.dart';
import 'app_typography.dart';
import 'neu_colors.dart';

/// RVIOS Platform Theme — Material 3 ThemeData
///
/// Centralized theme definition for RVIOS Platform.
/// Primary: #9E2226 Crimson | Background: #FAF8ED Ivory | Accent: #C8A45D Gold
/// Provides both Light (Ivory) and Dark (Graphite) themes.
class AppTheme {
  AppTheme._();

  // ─────────────────────────────────────────────
  // Light Theme
  // ─────────────────────────────────────────────

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        fontFamily: AppTypography.fontFamilyBody,

        // Color Scheme — RVIOS Light (Ivory)
        colorScheme: const ColorScheme.light(
          primary: NeuColors.primary,
          onPrimary: NeuColors.textOnDark,
          primaryContainer: NeuColors.primaryTint,
          onPrimaryContainer: NeuColors.primaryDark,
          secondary: NeuColors.gold,
          onSecondary: NeuColors.textOnDark,
          secondaryContainer: NeuColors.goldLight,
          onSecondaryContainer: NeuColors.goldDark,
          tertiary: NeuColors.primaryLight,
          surface: NeuColors.bgColor,
          onSurface: NeuColors.textPrimary,
          onSurfaceVariant: NeuColors.textSecondary,
          error: NeuColors.danger,
          onError: NeuColors.textOnDark,
          outline: NeuColors.border,
          outlineVariant: NeuColors.divider,
        ),

        // Scaffold
        scaffoldBackgroundColor: NeuColors.bgColor,

        // AppBar
        appBarTheme: const AppBarTheme(
          backgroundColor: NeuColors.bgColor,
          foregroundColor: NeuColors.textPrimary,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTypography.h3,
          iconTheme: IconThemeData(
            color: NeuColors.primary,
            size: 24,
          ),
        ),

        // Bottom Navigation
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: NeuColors.bgColor,
          selectedItemColor: NeuColors.primary,
          unselectedItemColor: NeuColors.textHint,
          selectedLabelStyle: AppTypography.navLabel,
          unselectedLabelStyle: AppTypography.navLabel,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        // Card
        cardTheme: CardThemeData(
          color: NeuColors.surface,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
          ),
          margin: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
        ),

        // Elevated Button
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: NeuColors.primary,
            foregroundColor: NeuColors.textOnDark,
            textStyle: AppTypography.button,
            padding: AppSpacing.button,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),

        // Text Button
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: NeuColors.primary,
            textStyle: AppTypography.button.copyWith(
              color: NeuColors.primary,
            ),
            padding: AppSpacing.button,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
          ),
        ),

        // Outlined Button
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: NeuColors.primary,
            side: const BorderSide(color: NeuColors.primary, width: 1.5),
            textStyle: AppTypography.button.copyWith(
              color: NeuColors.primary,
            ),
            padding: AppSpacing.button,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),

        // Input Decoration
        inputDecorationTheme: InputDecorationTheme(
          filled: false,
          contentPadding: AppSpacing.input,
          border: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(
              color: NeuColors.primary,
              width: 2,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(
              color: NeuColors.danger,
              width: 1.5,
            ),
          ),
          labelStyle: AppTypography.label,
          hintStyle: AppTypography.body.copyWith(
            color: NeuColors.textHint,
          ),
          errorStyle: AppTypography.caption.copyWith(
            color: NeuColors.danger,
          ),
          floatingLabelStyle: AppTypography.label.copyWith(
            color: NeuColors.primary,
            fontWeight: FontWeight.w600,
          ),
        ),

        // Floating Action Button
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: NeuColors.primary,
          foregroundColor: NeuColors.textOnDark,
          elevation: 0,
          shape: CircleBorder(),
        ),

        // Divider
        dividerTheme: const DividerThemeData(
          color: NeuColors.divider,
          thickness: 1,
          space: 0,
        ),

        // Dialog
        dialogTheme: DialogThemeData(
          backgroundColor: NeuColors.bgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.dialog,
          ),
          titleTextStyle: AppTypography.h3,
          contentTextStyle: AppTypography.body,
        ),

        // Bottom Sheet
        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: NeuColors.bgColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.bottomSheet,
          ),
        ),

        // Chip
        chipTheme: ChipThemeData(
          backgroundColor: NeuColors.surface,
          labelStyle: AppTypography.caption,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.chip,
          ),
          side: BorderSide.none,
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.xs,
          ),
        ),

        // Snackbar
        snackBarTheme: SnackBarThemeData(
          backgroundColor: NeuColors.primary,
          contentTextStyle: AppTypography.body.copyWith(
            color: NeuColors.textOnDark,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.chip,
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );

  // ─────────────────────────────────────────────
  // Dark Theme
  // ─────────────────────────────────────────────

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: AppTypography.fontFamilyBody,

        // Color Scheme — RVIOS Dark (Graphite)
        colorScheme: const ColorScheme.dark(
          primary: NeuColors.primary,
          onPrimary: NeuColors.textOnDark,
          primaryContainer: NeuColors.primaryDark,
          onPrimaryContainer: NeuColors.primaryTint,
          secondary: NeuColors.gold,
          onSecondary: NeuColors.textPrimary,
          secondaryContainer: NeuColors.goldDark,
          onSecondaryContainer: NeuColors.goldLight,
          tertiary: NeuColors.primaryLight,
          surface: NeuColors.bgColorDark,
          onSurface: NeuColors.textPrimaryDark,
          onSurfaceVariant: NeuColors.textSecondaryDark,
          error: NeuColors.danger,
          onError: NeuColors.textOnDark,
          outline: NeuColors.borderDark,
          outlineVariant: NeuColors.dividerDark,
        ),

        scaffoldBackgroundColor: NeuColors.bgColorDark,

        appBarTheme: AppBarTheme(
          backgroundColor: NeuColors.bgColorDark,
          foregroundColor: NeuColors.textPrimaryDark,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: AppTypography.h3Dark,
          iconTheme: const IconThemeData(
            color: NeuColors.gold,
            size: 24,
          ),
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: NeuColors.bgColorDark,
          selectedItemColor: NeuColors.primary,
          unselectedItemColor: NeuColors.textHintDark,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
        ),

        cardTheme: CardThemeData(
          color: NeuColors.surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.card,
          ),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: NeuColors.primary,
            foregroundColor: NeuColors.textOnDark,
            textStyle: AppTypography.button,
            padding: AppSpacing.button,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),

        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: NeuColors.gold,
            textStyle: AppTypography.button.copyWith(
              color: NeuColors.gold,
            ),
            padding: AppSpacing.button,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
          ),
        ),

        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: NeuColors.textPrimaryDark,
            side: const BorderSide(color: NeuColors.borderDark, width: 1.5),
            textStyle: AppTypography.button.copyWith(
              color: NeuColors.textPrimaryDark,
            ),
            padding: AppSpacing.button,
            shape: RoundedRectangleBorder(
              borderRadius: AppRadius.button,
            ),
            minimumSize: const Size(double.infinity, 52),
          ),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: false,
          contentPadding: AppSpacing.input,
          border: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: AppRadius.input,
            borderSide: const BorderSide(
              color: NeuColors.primary,
              width: 2,
            ),
          ),
          labelStyle: AppTypography.labelDark,
          hintStyle: AppTypography.bodyDark.copyWith(
            color: NeuColors.textHintDark,
          ),
        ),

        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: NeuColors.primary,
          foregroundColor: NeuColors.textOnDark,
          elevation: 0,
          shape: CircleBorder(),
        ),

        dividerTheme: const DividerThemeData(
          color: NeuColors.dividerDark,
          thickness: 1,
          space: 0,
        ),

        dialogTheme: DialogThemeData(
          backgroundColor: NeuColors.bgColorDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.dialog,
          ),
          titleTextStyle: AppTypography.h3Dark,
          contentTextStyle: AppTypography.bodyDark,
        ),

        bottomSheetTheme: BottomSheetThemeData(
          backgroundColor: NeuColors.bgColorDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: AppRadius.bottomSheet,
          ),
        ),
      );
}