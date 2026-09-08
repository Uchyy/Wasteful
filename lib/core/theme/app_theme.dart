// core/theme/app_theme.dart
import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get light => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: AppColors.light.background,
        extensions: const [AppColors.light],
        textTheme: AppTextStyles.textTheme(
          AppColors.light.textPrimary,
          AppColors.light.textSecondary,
          isDark: false,
        ),
        radioTheme: RadioThemeData(
          
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.light.accent;
            }
            return AppColors.light.accent;
          }),
        ),
        listTileTheme: ListTileThemeData(
          iconColor: AppColors.dark.accent.withAlpha(100)
        )
      );

  static ThemeData get dark => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.dark.background,
        extensions: const [AppColors.dark],
        textTheme: AppTextStyles.textTheme(
          AppColors.dark.textPrimary,
          AppColors.dark.textSecondary,
          isDark: true,
        ),
        radioTheme: RadioThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppColors.dark.accent;
            }
            return AppColors.dark.accent;
          }),
        ),
        listTileTheme: ListTileThemeData(
          iconColor: AppColors.dark.accent.withAlpha(100)
        )
      );
}