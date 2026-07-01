import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Android TV optimized theme configuration.
/// 
/// This theme is designed specifically for TV interfaces with:
/// - Large, readable fonts
/// - High contrast colors
/// - D-pad friendly focus states
/// - Dark theme by default (better for TV viewing)
class AppTheme {
  AppTheme._();

  // Color Palette - Dark Theme (Default)
  static const Color primaryColor = Color(0xFF64B5F6);
  static const Color primaryVariant = Color(0xFF1976D2);
  static const Color secondaryColor = Color(0xFF81C784);
  static const Color errorColor = Color(0xFFEF5350);
  
  static const Color backgroundColor = Color(0xFF121212);
  static const Color surfaceColor = Color(0xFF1E1E1E);
  static const Color cardColor = Color(0xFF2C2C2C);
  
  static const Color onPrimaryColor = Colors.white;
  static const Color onSecondaryColor = Colors.black;
  static const Color onBackgroundColor = Colors.white;
  static const Color onSurfaceColor = Colors.white;
  static const Color onErrorColor = Colors.white;
  
  static const Color dividerColor = Color(0xFF424242);
  static const Color disabledColor = Color(0xFF616161);
  
  // Focus State Colors
  static const Color focusColor = Color(0xFF64B5F6);
  static const Color hoverColor = Color(0xFF424242);
  static const Color highlightColor = Colors.transparent;
  
  // Font Sizes (optimized for TV viewing from distance)
  static const double fontSizeSmall = 18.0;
  static const double fontSizeMedium = 22.0;
  static const double fontSizeLarge = 28.0;
  static const double fontSizeXLarge = 36.0;
  
  // Spacing (larger for remote navigation)
  static const double spacingSmall = 12.0;
  static const double spacingMedium = 24.0;
  static const double spacingLarge = 32.0;
  static const double spacingXLarge = 48.0;
  
  // Button Sizes (minimum touch target for TV remotes)
  static const double buttonMinWidth = 120.0;
  static const double buttonMinHeight = 56.0;
  static const double iconButtonSize = 56.0;
  
  // Border Radius
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 16.0;
  
  /// Dark Theme Data - Optimized for Android TV
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        primaryContainer: primaryVariant,
        secondary: secondaryColor,
        secondaryContainer: Color(0xFF4CAF50),
        surface: surfaceColor,
        error: errorColor,
        onPrimary: onPrimaryColor,
        onSecondary: onSecondaryColor,
        onSurface: onSurfaceColor,
        onError: onErrorColor,
        background: backgroundColor,
        onBackground: onBackgroundColor,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: surfaceColor,
        foregroundColor: onSurfaceColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: onSurfaceColor,
          fontSize: fontSizeLarge,
          fontWeight: FontWeight.w600,
        ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: onPrimaryColor,
          minimumSize: const Size(buttonMinWidth, buttonMinHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          textStyle: const TextStyle(
            fontSize: fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: onSurfaceColor,
          minimumSize: const Size(buttonMinWidth, buttonMinHeight),
          padding: const EdgeInsets.symmetric(
            horizontal: 32,
            vertical: 16,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
          side: const BorderSide(color: dividerColor, width: 2),
          textStyle: const TextStyle(
            fontSize: fontSizeMedium,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: onSurfaceColor,
          minimumSize: const Size(iconButtonSize, iconButtonSize),
          padding: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadiusMedium),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 24,
          vertical: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: dividerColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: dividerColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(borderRadiusMedium),
          borderSide: const BorderSide(color: errorColor),
        ),
        hintStyle: const TextStyle(
          color: disabledColor,
          fontSize: fontSizeMedium,
        ),
        labelStyle: const TextStyle(
          color: onSurfaceColor,
          fontSize: fontSizeMedium,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: fontSizeXLarge,
          fontWeight: FontWeight.bold,
          color: onBackgroundColor,
        ),
        displayMedium: TextStyle(
          fontSize: fontSizeLarge,
          fontWeight: FontWeight.w600,
          color: onBackgroundColor,
        ),
        bodyLarge: TextStyle(
          fontSize: fontSizeMedium,
          color: onBackgroundColor,
        ),
        bodyMedium: TextStyle(
          fontSize: fontSizeSmall,
          color: onBackgroundColor,
        ),
        labelLarge: TextStyle(
          fontSize: fontSizeMedium,
          fontWeight: FontWeight.w600,
          color: onBackgroundColor,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: dividerColor,
        thickness: 1,
        space: spacingMedium,
      ),
      focusColor: focusColor,
      hoverColor: hoverColor,
      highlightColor: highlightColor,
    );
  }
  
  /// Light Theme Data (optional, for users who prefer it)
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      // Similar structure but with light colors
      // Can be implemented based on user preference
    );
  }
}
