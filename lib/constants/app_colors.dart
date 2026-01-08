import 'package:flutter/material.dart';

/// **FEES UP: PRODUCTION COLOR SYSTEM**
/// 
/// Theme: "Lively Slate"
/// Identity: Electric Blue Primary + Vibrant Purple Accent over Deep Slate.
/// Standard: 100% Immutable Constants. No runtime calculations.
class AppColors {
  const AppColors._();

  // ===========================================================================
  // 1. BRAND IDENTITY
  // ===========================================================================
  
  // PRIMARY: Electric Blue (Action, Primary Buttons, Active States)
  static const Color primaryBlue = Color(0xFF2962FF); 
  static const Color primaryBlueLight = Color(0xFF768FFF);
  static const Color primaryBlueDark = Color(0xFF0039CB);

  // ACCENT: Vibrant Purple (Secondary Actions, Highlights, "Magic" Moments)
  static const Color accentPurple = Color(0xFFA855F7); 
  static const Color accentPurpleLight = Color(0xFFD180FF);
  static const Color accentPurpleDark = Color(0xFFAA00FF);

  // ===========================================================================
  // 2. THE LIVELY SLATE (BACKGROUNDS & SURFACES)
  // ===========================================================================
  
  // The Canvas (Main App Background) - Slate 900
  static const Color backgroundBlack = Color(0xFF0F172A); 
  
  // The Cards (Dialogs, Cards, Sheets) - Slate 800
  static const Color surfaceGrey = Color(0xFF1E293B);
  
  // The Contrast (Sidebar, Top Bar, Active Tabs) - Slate 950
  static const Color surfaceDarkGrey = Color(0xFF020617);
  
  // The Structural (Borders, Input Fills) - Slate 700
  static const Color surfaceLightGrey = Color(0xFF334155);
  
  // The Highlight (Hover States on Dark) - Slate 600
  static const Color surfaceHighlight = Color(0xFF475569);

  // ===========================================================================
  // 3. UI ELEMENTS & UTILITIES
  // ===========================================================================
  
  // Dividers - Matching surface light for subtle, high-quality separation
  static const Color divider = Color(0xFF334155); 
  
  // Icons - Default grey for inactive icons
  static const Color iconGrey = Color(0xFF64748B);

  // ===========================================================================
  // 4. TYPOGRAPHY (READABILITY STANDARD)
  // ===========================================================================
  
  // High Emphasis (Headings, Primary Data) - Slate 50
  static const Color textWhite = Color(0xFFF8FAFC);
  
  // Medium Emphasis (Body Text, Labels) - 70% Opacity
  static const Color textWhite70 = Color(0xB3F8FAFC);
  
  // Low Emphasis (Hints, Placeholders, Disabled Text) - 54% Opacity
  static const Color textWhite54 = Color(0x8AF8FAFC);
  
  // Subtle/Disabled (Icons, Watermarks) - 38% Opacity
  static const Color textWhite38 = Color(0x61F8FAFC);
  
  // Brand Text (Links, Clickables) - Muted Blue for readability on Dark
  static const Color textBlue = Color(0xFF60A5FA);

  // Muted Text (Secondary Info) - Slate 400
  static const Color textGrey = Color(0xFF94A3B8);

  // ===========================================================================
  // 5. FUNCTIONAL & FEEDBACK
  // ===========================================================================
  
  // ERROR (Destructive Actions, Alerts) - Red 500
  static const Color errorRed = Color(0xFFEF4444);
  
  // SUCCESS (Payments, Confirmations) - Emerald 500
  static const Color successGreen = Color(0xFF10B981);
  
  // WARNING (Overdue, Pending) - Amber 500
  static const Color warningOrange = Color(0xFFF59E0B);
  
  // INFO (Notices) - Sky 500
  static const Color infoBlue = Color(0xFF0EA5E9);

  // DISABLED (Inactive Buttons) - Slate 600
  static const Color disabledGrey = Color(0xFF475569);

  // ===========================================================================
  // 6. INTERACTION STATES (PRE-CALCULATED ALPHA)
  // ===========================================================================
  // Use these for Chips, Table Rows, and Splash Effects.
  // Format: 0xAA (Alpha) + RRGGBB
  
  // Primary Blue Variants
  static const Color primaryBlue_08 = Color(0x142962FF); // Hover
  static const Color primaryBlue_12 = Color(0x1F2962FF); // Focus
  static const Color primaryBlue_20 = Color(0x332962FF); // Active/Selected
  
  // Accent Purple Variants
  static const Color purple_08 = Color(0x14A855F7);
  static const Color purple_12 = Color(0x1FA855F7);
  static const Color purple_20 = Color(0x33A855F7);

  // Semantic Backgrounds (Chips/Badges)
  static const Color errorRedBg = Color(0x22EF4444);     // Red 500 @ ~13%
  static const Color successGreenBg = Color(0x2210B981); // Emerald 500 @ ~13%
  static const Color warningOrangeBg = Color(0x22F59E0B); // Amber 500 @ ~13%
  static const Color infoBlueBg = Color(0x220EA5E9);     // Sky 500 @ ~13%
  
  // Overlay (Modal Backgrounds)
  static const Color overlayDark = Color(0xD9020617);    // Slate 950 @ 85%

  // ===========================================================================
  // 7. GRADIENTS & DECORATIONS
  // ===========================================================================
  
  // The "Electric" Gradient (Primary Actions)
  static const LinearGradient electricGradient = LinearGradient(
    colors: [primaryBlue, Color(0xFF536DFE)], // Blue A400 -> Indigo A200
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // The "Void" Gradient (Sidebar/Drawers)
  static const LinearGradient voidGradient = LinearGradient(
    colors: [surfaceDarkGrey, backgroundBlack],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}