class AppSingleton {
  static final AppSingleton _instance = AppSingleton._internal();
  static AppSingleton get instance => _instance;

  AppSingleton._internal();

  // 🛑 The Global Flag
  bool isAuthenticated = false;
}