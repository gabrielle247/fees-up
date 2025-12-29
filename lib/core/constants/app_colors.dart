import 'package:flutter/material.dart';

class AppColors {
  const AppColors._();

  // --- BRAND COLORS ---
  // A vivid, electric blue that pops against the slate background
  static const Color primaryBlue = Color(0xFF2962FF); 
  static const Color primaryBlueLight = Color(0xFF768FFF);
  static const Color primaryBlueDark = Color(0xFF0039CB);
  
  // A vibrant purple for secondary actions
  static const Color accentPurple = Color(0xFFA855F7); 
  static const Color accentPurpleLight = Color(0xFFD180FF);
  static const Color accentPurpleDark = Color(0xFFAA00FF);

  // --- BACKGROUNDS (The "Lively Slate" Theme) ---
  // Replaced muddy teal-blacks with deep, rich Slate Blue-Greys
  static const Color backgroundBlack = Color(0xFF0F172A); // Deepest Slate (Main BG)
  static const Color surfaceGrey = Color(0xFF1E293B);     // Card/Dialog Surface
  static const Color surfaceLightGrey = Color(0xFF334155); // Borders / Input Fills
  static const Color surfaceDarkGrey = Color(0xFF020617);  // Sidebar / Contrast Areas
  
  // --- TEXT COLORS ---
  static const Color textWhite = Color(0xFFF8FAFC); // Slightly off-white for less eye strain
  static const Color textWhite70 = Color(0xB3F8FAFC);
  static const Color textWhite54 = Color(0x8AF8FAFC);
  static const Color textWhite38 = Color(0x61F8FAFC);
  static const Color textGrey = Color(0xFF94A3B8); // Slate-tinted grey text

  // --- UI ELEMENTS ---
  static const Color divider = Color(0xFF334155); // Matching the surface light
  static const Color iconGrey = Color(0xFF64748B);
  static const Color overlayDark = Color(0xD9020617);

  // --- FUNCTIONAL COLORS ---
  // Adjusted to be slightly more vibrant to match the lively theme
  static const Color errorRed = Color(0xFFEF4444);
  static const Color successGreen = Color(0xFF10B981); // Emerald green
  static const Color warningOrange = Color(0xFFF59E0B); // Amber
  static const Color disabledGrey = Color(0xFF475569);

  // --- TRANSPARENT BACKGROUNDS ---
  // Perfect for chips and subtle highlights
  static const Color errorRedBg = Color(0x22EF4444);
  static const Color purpleBg = Color(0x22A855F7);
  static const Color primaryBlueBg = Color(0x222962FF);
  static const Color successGreenBg = Color(0x2210B981);
}