import 'package:flutter/material.dart';

class AppTheme {
  // Standardized Spacing System (4px base unit)
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;

  // Border Radius System
  static const double radiusSmall = 6.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;

  // Dark Blue Color Palette (Enhanced)
  static const Color primaryDark = Color(0xFF1e3a5f); // Deep Navy Blue
  static const Color primaryBlue = Color(0xFF2563eb); // Primary Blue
  static const Color accentBlue = Color(0xFF3b82f6); // Accent Blue
  static const Color lightBlue = Color(0xFF60a5fa); // Light Blue
  static const Color backgroundDark = Color(0xFF0f172a); // Very Dark Blue
  static const Color surfaceBlue = Color(0xFF1e293b); // Surface Blue
  static const Color surfaceElevated = Color(0xFF334155); // Elevated Surface
  
  static const Color textPrimary = Color(0xFFf1f5f9); // Light text
  static const Color textSecondary = Color(0xFF94a3b8); // Secondary text
  static const Color textMuted = Color(0xFF64748b); // Muted text
  static const Color dividerColor = Color(0xFF334155); // Divider
  
  // Status Colors
  static const Color successGreen = Color(0xFF10b981); // Success
  static const Color errorRed = Color(0xFFef4444); // Error
  static const Color warningOrange = Color(0xFff97316); // Warning
  static const Color infoBlue = Color(0xFF3b82f6); // Info
  
  // Interactive Colors
  static const Color hoverBlue = Color(0xFF1d4ed8);
  static const Color pressedBlue = Color(0xFF1e40af);
  
  // Semantic Background Colors
  static const Color backgroundSuccess = Color(0xFF064e3b);
  static const Color backgroundError = Color(0xFF7f1d1d);
  static const Color backgroundWarning = Color(0xFF78350f);
  static const Color backgroundInfo = Color(0xFF1e3a8a);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceBlue,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing16, 
          vertical: spacing12
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: dividerColor, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: dividerColor, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: errorRed, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: errorRed, width: 2),
        ),
        hintStyle: const TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
        labelStyle: const TextStyle(color: textSecondary, fontWeight: FontWeight.w600),
        errorStyle: const TextStyle(color: errorRed, fontWeight: FontWeight.w500),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primaryBlue.withValues(alpha: 0.3),
          minimumSize: const Size(double.infinity, spacing48),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24, 
            vertical: spacing12
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            Colors.white.withValues(alpha: 0.1),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryBlue,
          side: const BorderSide(color: primaryBlue, width: 1.5),
          minimumSize: const Size(double.infinity, spacing48),
          padding: const EdgeInsets.symmetric(
            horizontal: spacing24, 
            vertical: spacing12
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ).copyWith(
          overlayColor: WidgetStateProperty.all(
            primaryBlue.withValues(alpha: 0.1),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.5,
        ),
        displayMedium: TextStyle(
          color: textPrimary,
          fontSize: 28,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.25,
        ),
        headlineLarge: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.15,
        ),
        titleMedium: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        bodyMedium: TextStyle(
          color: textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: TextStyle(
          color: textMuted,
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
        labelLarge: TextStyle(
          color: textPrimary,
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        labelMedium: TextStyle(
          color: textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.5,
        ),
        labelSmall: TextStyle(
          color: textMuted,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
