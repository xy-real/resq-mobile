import 'package:flutter/material.dart';

class AppTheme {
  // Standardized Spacing System (8pt base grid)
  static const double spacing4 = 4.0;
  static const double spacing8 = 8.0;
  static const double spacing10 = 10.0;
  static const double spacing12 = 12.0;
  static const double spacing14 = 14.0;
  static const double spacing16 = 16.0;
  static const double spacing20 = 20.0;
  static const double spacing24 = 24.0;
  static const double spacing32 = 32.0;
  static const double spacing48 = 48.0;

  // Border Radius System (soft, modern corners)
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;

  // Premium Color Palette - Unified & Minimal
  // Primary: Deep, trustworthy blue
  static const Color primary = Color(0xFF1e3a8a); // Deep Blue (primary brand color)
  static const Color primaryDark = Color(0xFF1e40af); // Slightly darker for interaction
  static const Color primaryLight = Color(0xFF3b82f6); // Lighter for accents
  
  // Neutral Grayscale (for calm, professional feel)
  static const Color backgroundDark = Color(0xFF0f172a); // Deep dark background
  static const Color surface = Color(0xFF1e293b); // Primary surface
  static const Color surfaceElevated = Color(0xFF334155); // Elevated surface for cards
  static const Color surfaceHighlight = Color(0xFF475569); // Highlight surface
  
  static const Color textPrimary = Color(0xFFf1f5f9); // Primary text (white-ish)
  static const Color textSecondary = Color(0xFF94a3b8); // Secondary text (gray)
  static const Color textMuted = Color(0xFF64748b); // Muted text (darker gray)
  static const Color dividerColor = Color(0xFF334155); // Subtle divider
  static const Color border = Color(0xFF475569); // Border color
  
  // Semantic Status Indicators (subtle, icon/label based instead of background)
  static const Color statusSafe = Color(0xFF10b981); // Green (safe status)
  static const Color statusNeedsHelp = Color(0xFFf59e0b); // Amber (needs help)
  static const Color statusCritical = Color(0xFFef4444); // Red (critical)
  static const Color statusEvacuated = Color(0xFF3b82f6); // Blue (evacuated)
  
  // For maintaining backward compatibility
  static const Color successGreen = Color(0xFF10b981); // Success
  static const Color errorRed = Color(0xFFef4444); // Error
  static const Color warningOrange = Color(0xFff97316); // Warning
  static const Color infoBlue = Color(0xFF3b82f6); // Info
  
  // Interactive States
  static const Color hoverBlue = Color(0xFF1d4ed8);
  static const Color pressedBlue = Color(0xFF1e40af);
  
  // Semantic Background Colors
  static const Color backgroundSuccess = Color(0xFF064e3b);
  static const Color backgroundError = Color(0xFF7f1d1d);
  static const Color backgroundWarning = Color(0xFF78350f);
  static const Color backgroundInfo = Color(0xFF1e3a8a);
  
  // Backward compatibility aliases (old names)
  static const Color primaryBlue = primary;
  static const Color surfaceBlue = surface;
  static const Color lightBlue = primaryLight;

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primary,
      scaffoldBackgroundColor: backgroundDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacing16, 
          vertical: spacing12
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
          borderSide: const BorderSide(color: primary, width: 2),
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
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 2,
          shadowColor: primary.withValues(alpha: 0.3),
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
          foregroundColor: primary,
          side: const BorderSide(color: primary, width: 1.5),
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
            primary.withValues(alpha: 0.1),
          ),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          color: textPrimary,
          fontSize: 32,
          fontWeight: FontWeight.w800,
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
