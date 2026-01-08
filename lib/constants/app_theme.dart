import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  // ===========================================================================
  // THEME DATA (DARK MODE DEFAULT)
  // ===========================================================================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      fontFamily:
          'Inter', // We will add google_fonts later, or use system default

      // 1. CORE PALETTE
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryBlue,
        onPrimary: Colors.white,
        primaryContainer: AppColors.primaryBlue_20,
        onPrimaryContainer: AppColors.primaryBlueLight,

        secondary: AppColors.accentPurple,
        onSecondary: Colors.white,
        secondaryContainer: AppColors.purple_20,
        onSecondaryContainer: AppColors.accentPurpleLight,

        surface: AppColors.surfaceGrey,
        onSurface: AppColors.textWhite,

        error: AppColors.errorRed,
        onError: Colors.white,

      ),

      // 2. SCAFFOLD & APP BAR
      scaffoldBackgroundColor: AppColors.backgroundBlack,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDarkGrey,
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 2,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: IconThemeData(color: AppColors.textWhite),
        titleTextStyle: TextStyle(
          color: AppColors.textWhite,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          letterSpacing: -0.5,
        ),
      ),

      // 3. CARDS & SURFACES
      cardTheme: CardThemeData(
        color: AppColors.surfaceGrey,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.surfaceLightGrey, width: 1),
        ),
      ),

      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surfaceGrey,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.surfaceLightGrey, width: 1),
        ),
        titleTextStyle: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: AppColors.textWhite,
        ),
      ),

      // 4. INPUTS (TEXT FIELDS) - The "Workhorse" of Data Entry
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceDarkGrey,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: const TextStyle(color: AppColors.textWhite38, fontSize: 14),
        labelStyle: const TextStyle(color: AppColors.textWhite70, fontSize: 14),

        // Default Border (Idle)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.surfaceLightGrey),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.surfaceLightGrey),
        ),

        // Focus Border (Electric Blue)
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
        ),

        // Error Border
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.errorRed),
        ),
      ),

      // 5. BUTTONS
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
          foregroundColor: AppColors.textWhite,
          side: const BorderSide(color: AppColors.surfaceLightGrey),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),

      // 6. TYPOGRAPHY (Inter-based scaling)
      textTheme: const TextTheme(
        // Large Titles
        displayLarge: TextStyle(
            color: AppColors.textWhite,
            fontSize: 32,
            fontWeight: FontWeight.bold),
        displayMedium: TextStyle(
            color: AppColors.textWhite,
            fontSize: 28,
            fontWeight: FontWeight.bold),
        displaySmall: TextStyle(
            color: AppColors.textWhite,
            fontSize: 24,
            fontWeight: FontWeight.w600),

        // Section Headers
        headlineMedium: TextStyle(
            color: AppColors.textWhite,
            fontSize: 20,
            fontWeight: FontWeight.w600),
        headlineSmall: TextStyle(
            color: AppColors.textWhite,
            fontSize: 18,
            fontWeight: FontWeight.w600),

        // Body Text
        bodyLarge: TextStyle(color: AppColors.textWhite, fontSize: 16),
        bodyMedium: TextStyle(color: AppColors.textWhite70, fontSize: 14),
        bodySmall: TextStyle(color: AppColors.textGrey, fontSize: 12),

        // Labels (Buttons, Captions)
        labelLarge: TextStyle(
            color: AppColors.textWhite,
            fontSize: 14,
            fontWeight: FontWeight.w600),
        labelMedium: TextStyle(
            color: AppColors.textGrey,
            fontSize: 12,
            fontWeight: FontWeight.w500),
      ),

      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
        space: 24,
      ),
    );
  }
}
