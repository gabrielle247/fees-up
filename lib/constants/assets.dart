class AppAssets {
  const AppAssets._();

  // ===========================================================================
  // ROOT PATHS
  // ===========================================================================
  static const String _images = 'assets/images';
  static const String _icons = 'assets/icons';
  static const String _illustrations = 'assets/illustrations';

  // ===========================================================================
  // 1. BRANDING
  // ===========================================================================
  static const String appLogo = '$_images/logo.png';
  static const String appLogoDark = '$_images/logo_dark.png';
  static const String favicon = '$_images/favicon.png';

  // ===========================================================================
  // 2. ILLUSTRATIONS (Empty States & Onboarding)
  // ===========================================================================
  static const String loginHero = '$_illustrations/login_hero.png';
  static const String emptyStudents = '$_illustrations/empty_students.png';
  static const String emptyLedger = '$_illustrations/empty_ledger.png';
  static const String successCheck = '$_illustrations/success_check.png';
  
  // ===========================================================================
  // 3. ICONS (Custom SVGs if Material Icons aren't enough)
  // ===========================================================================
  static const String googleIcon = '$_icons/google.svg';
  static const String appleIcon = '$_icons/apple.svg';
  static const String filterIcon = '$_icons/filter.svg';
}