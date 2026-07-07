import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
    );

    return _buildTheme(scheme, Brightness.light);
  }

  static ThemeData get darkTheme {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      primary: AppColors.primary,
      secondary: AppColors.secondary,
    );

    return _buildTheme(scheme, Brightness.dark);
  }

  static ThemeData _buildTheme(ColorScheme colorScheme, Brightness brightness) {
    final isDark = brightness == Brightness.dark;

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: brightness,
      scaffoldBackgroundColor: isDark
          ? AppColors.background
          : const Color(0xFFF5F7FA),
      canvasColor: isDark ? AppColors.background : const Color(0xFFF5F7FA),
      dividerColor: isDark ? AppColors.divider : Colors.black12,
      splashFactory: NoSplash.splashFactory,
      fontFamily: 'Roboto',
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: isDark ? AppColors.background : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black87,
        titleTextStyle: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.card,
        elevation: AppConstants.elevation,
        margin: EdgeInsets.all(8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppConstants.radius)),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 52),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radius),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: BorderSide(color: AppColors.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radius),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: isDark ? AppColors.surface : Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radius),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radius),
          borderSide: BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radius),
          borderSide: BorderSide(color: AppColors.sell),
        ),
        labelStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
        hintStyle: TextStyle(color: isDark ? Colors.white38 : Colors.black38),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? AppColors.card : Colors.white,
        contentTextStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radius),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppConstants.radius)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: isDark ? AppColors.card : Colors.white,
        indicatorColor: AppColors.primary.withAlpha(32),
        labelTextStyle: MaterialStateProperty.all(
          TextStyle(
            color: isDark ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconTheme: IconThemeData(color: isDark ? Colors.white : Colors.black87),
      textTheme: TextTheme(
        headlineLarge: AppTextStyles.heading,
        headlineMedium: AppTextStyles.title,
        bodyLarge: AppTextStyles.body,
        bodyMedium: AppTextStyles.subtitle,
        bodySmall: AppTextStyles.small,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: AppColors.primary,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: isDark ? AppColors.surface : Colors.grey.shade100,
        selectedColor: AppColors.primary,
        disabledColor: Colors.grey.shade300,
        labelStyle: TextStyle(color: isDark ? Colors.white : Colors.black87),
        secondaryLabelStyle: TextStyle(
          color: isDark ? Colors.white : Colors.black87,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: MaterialStateProperty.all(AppColors.primary),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: isDark ? Colors.white : Colors.black87,
        textColor: isDark ? Colors.white : Colors.black87,
      ),
    );
  }
}
