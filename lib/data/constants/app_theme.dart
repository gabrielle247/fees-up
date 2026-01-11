// ==========================================
// FILE: ./constants/app_theme.dart
// ==========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  // ===========================================================================
  // 1. THEME GETTERS
  // ===========================================================================
  
  static ThemeData get darkTheme => _buildDarkTheme();
  static ThemeData get lightTheme => _buildLightTheme();
  static ThemeData get highContrastTheme => _buildContrastTheme();

  static ThemeData themeData(BuildContext context) {
    final brightness = MediaQuery.platformBrightnessOf(context);
    return brightness == Brightness.dark ? darkTheme : lightTheme;
  }

  // ===========================================================================
  // 2. DARK THEME (Using EXISTING Lively Slate Keys)
  // ===========================================================================
  static ThemeData _buildDarkTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',

      // CORE PALETTE
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryBlue_20,
        onPrimaryContainer: AppColors.primaryBlueLight,
        secondary: AppColors.accentPurple,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.purple_20,
        onSecondaryContainer: AppColors.accentPurpleLight,
        // using existing keys
        surface: AppColors.surfaceGrey, 
        onSurface: AppColors.textWhite,
        error: AppColors.errorRed,
        onError: Colors.white,
      ),

      // SCAFFOLD
      scaffoldBackgroundColor: AppColors.backgroundBlack, // existing key
      
      // APP BAR
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDarkGrey, // existing key
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.textWhite), // existing key
        titleTextStyle: TextStyle(
          color: AppColors.textWhite, // existing key
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),

      // CARDS
      cardTheme: CardThemeData(
        color: AppColors.surfaceGrey, // existing key
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.surfaceLightGrey, width: 1), // existing key
        ),
      ),

      // DIALOGS
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceGrey, // existing key
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceLightGrey, width: 1), // existing key
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textWhite, // existing key
        ),
      ),

      // INPUTS
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDarkGrey, // existing key
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.textWhite38, fontSize: 14), // existing key
        labelStyle: const TextStyle(color: AppColors.textWhite70, fontSize: 14), // existing key
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.surfaceLightGrey), // existing key
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.surfaceLightGrey), // existing key
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
      ),

      // BUTTONS
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textWhite, // existing key
          side: const BorderSide(color: AppColors.surfaceLightGrey), // existing key
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // TYPOGRAPHY (Mapped to existing keys)
      textTheme: _buildTextTheme(
        primary: AppColors.textWhite,
        secondary: AppColors.textWhite70,
        disabled: AppColors.textWhite38,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider, // existing key
        thickness: 1,
        space: 24,
      ),
    );
  }

  // ===========================================================================
  // 3. LIGHT THEME (Clean Paper) - Uses NEW keys you added
  // ===========================================================================
  static ThemeData _buildLightTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Inter',

      colorScheme: const ColorScheme.light(
        primary: AppColors.primaryBlue,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFE3F2FD),
        onPrimaryContainer: AppColors.primaryBlueDark,
        secondary: AppColors.accentPurple,
        onSecondary: Colors.white,
        surface: AppColors.lightSurface, // New key
        onSurface: AppColors.lightTextPrimary, // New key
        error: AppColors.errorRed,
        onError: Colors.white,
      ),

      scaffoldBackgroundColor: AppColors.lightBackground, // New key
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.lightSurface,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 2,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        iconTheme: IconThemeData(color: AppColors.lightTextPrimary),
        titleTextStyle: TextStyle(
          color: AppColors.lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.lightSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.lightBorder, width: 1), // New key
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.lightSurface,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.lightBorder, width: 1),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.lightTextPrimary,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.lightSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.lightTextDisabled, fontSize: 14), // New key
        labelStyle: const TextStyle(color: AppColors.lightTextSecondary, fontSize: 14), // New key
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.lightTextPrimary,
          side: const BorderSide(color: AppColors.lightBorder),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      textTheme: _buildTextTheme(
        primary: AppColors.lightTextPrimary,
        secondary: AppColors.lightTextSecondary,
        disabled: AppColors.lightTextDisabled,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.lightBorder,
        thickness: 1,
        space: 24,
      ),
    );
  }

  // ===========================================================================
  // 4. CONTRAST THEME (Sharp OLED) - Uses NEW keys you added
  // ===========================================================================
  static ThemeData _buildContrastTheme() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily: 'Inter',

      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        onPrimary: Colors.white,
        surface: AppColors.contrastSurface, // New key
        onSurface: AppColors.contrastTextPrimary, // New key
        error: AppColors.errorRed,
        onError: Colors.black,
        tertiary: AppColors.contrastHighVisYellow, // New key
      ),

      scaffoldBackgroundColor: AppColors.contrastBackground, // New key
      
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.contrastSurface,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.contrastTextPrimary),
        shape: Border(bottom: BorderSide(color: AppColors.contrastBorder, width: 1)), // New key
        titleTextStyle: TextStyle(
          color: AppColors.contrastTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),

      cardTheme: CardThemeData(
        color: AppColors.contrastSurface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.contrastBorder, width: 2),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.contrastSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.contrastBorder, width: 2),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: AppColors.contrastTextPrimary,
        ),
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.contrastSurface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.contrastTextSecondary, fontSize: 14), // New key
        labelStyle: const TextStyle(color: AppColors.contrastTextPrimary, fontSize: 14, fontWeight: FontWeight.bold),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.contrastBorder, width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.contrastBorder, width: 2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.contrastHighVisYellow, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.errorRed, width: 2),
        ),
      ),

      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: const BorderSide(color: Colors.white, width: 1),
          ),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.contrastTextPrimary,
          side: const BorderSide(color: AppColors.contrastBorder, width: 2),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),

      textTheme: _buildTextTheme(
        primary: AppColors.contrastTextPrimary,
        secondary: AppColors.contrastTextSecondary,
        disabled: AppColors.contrastTextSecondary,
      ).apply(
        bodyColor: AppColors.contrastTextPrimary,
        displayColor: AppColors.contrastTextPrimary,
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.contrastBorder,
        thickness: 2,
        space: 24,
      ),
    );
  }

  // ===========================================================================
  // 5. SHARED HELPER
  // ===========================================================================
  static TextTheme _buildTextTheme({
    required Color primary,
    required Color secondary,
    required Color disabled,
  }) {
    return TextTheme(
      displayLarge: TextStyle(color: primary, fontSize: 32, fontWeight: FontWeight.bold),
      displayMedium: TextStyle(color: primary, fontSize: 28, fontWeight: FontWeight.bold),
      displaySmall: TextStyle(color: primary, fontSize: 24, fontWeight: FontWeight.w600),
      headlineMedium: TextStyle(color: primary, fontSize: 20, fontWeight: FontWeight.w600),
      headlineSmall: TextStyle(color: primary, fontSize: 18, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(color: primary, fontSize: 16),
      bodyMedium: TextStyle(color: secondary, fontSize: 14),
      bodySmall: TextStyle(color: disabled, fontSize: 12),
      labelLarge: TextStyle(color: primary, fontSize: 14, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(color: disabled, fontSize: 12, fontWeight: FontWeight.w500),
    );
  }
}