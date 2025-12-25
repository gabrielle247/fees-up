import 'package:flutter/material.dart';

class AppColors {
  // Private constructor to prevent instantiation
  const AppColors._();

  // Greyway.Co Brand Colors
  // A distinct, professional "Tech Blue"
  static const Color primaryBlue = Color(0xFF2962FF); 
  static const Color primaryBlueLight = Color(0xFF768FFF);
  static const Color primaryBlueDark = Color(0xFF0039CB);

  // Dark Mode Backgrounds
  static const Color backgroundBlack = Color(0xff121b22); // Deep dark background
  static const Color surfaceGrey = Color(0xff1c2a35); // Cards and Sheets
  static const Color surfaceLightGrey = Color(0xff2c2c2c); // Hover states

  // Text Colors
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFFB0B0B0);

  // Functional Colors
  static const Color errorRed = Color(0xFFCF6679);
  static const Color successGreen = Color(0xFF00C853);
  static const Color warningOrange = Color(0xFFFFAB00);
}