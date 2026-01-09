class AppStrings {
  const AppStrings._();

  // ===========================================================================
  // 1. GENERAL APP INFO
  // ===========================================================================
  static const String appName = "Fees Up";
  static const String appVersion = "Alpha 1.0.0";
  static const String currencySymbol = "\$";

  // ===========================================================================
  // 2. COMMON ACTIONS
  // ===========================================================================
  static const String save = "Save";
  static const String cancel = "Cancel";
  static const String delete = "Delete";
  static const String edit = "Edit";
  static const String view = "View";
  static const String search = "Search...";
  static const String filter = "Filter";
  static const String export = "Export";
  static const String next = "Next";
  static const String back = "Back";
  static const String confirm = "Confirm";
  static const String loading = "Loading...";

  // ===========================================================================
  // 3. AUTHENTICATION
  // ===========================================================================
  static const String loginTitle = "Welcome Back";
  static const String loginSubtitle = "Sign in to manage your school.";
  static const String emailLabel = "Email Address";
  static const String passwordLabel = "Password";
  static const String loginButton = "Sign In";
  static const String forgotPassword = "Forgot Password?";
  static const String noAccount = "Don't have an account?";
  static const String signUp = "Sign Up";
  static const String schoolIdLabel = "School ID / Domain";

  // ===========================================================================
  // 4. DASHBOARD (FINANCIAL HEALTH)
  // ===========================================================================
  static const String dashboardTitle = "Overview";
  static const String healthScore = "Financial Health";
  static const String collectedThisMonth = "Collected (Month)";
  static const String outstandingFees = "Outstanding Fees";
  static const String activeStudents = "Active Students";
  static const String expenses = "Expenses";
  static const String recentTransactions = "Recent Transactions";
  static const String quickActions = "Quick Actions";

  // ===========================================================================
  // 5. STUDENTS (REGISTRY)
  // ===========================================================================
  static const String studentsTitle = "Students";
  static const String addStudent = "Add Student";
  static const String studentDetails = "Student Profile";
  static const String personalInfo = "Personal Info";
  static const String academicInfo = "Academic Info";
  static const String firstName = "First Name";
  static const String lastName = "Last Name";
  static const String dob = "Date of Birth";
  static const String gender = "Gender";
  static const String nationalId = "National ID";
  static const String enrollmentStatus = "Status";
  static const String currentClass = "Current Class";

  // ===========================================================================
  // 6. FINANCE (THE LEDGER)
  // ===========================================================================
  static const String financeTitle = "Finance";
  static const String ledger = "Ledger";
  static const String feeStructures = "Fee Structures";
  static const String recordPayment = "Record Payment";
  static const String createInvoice = "Create Invoice";
  static const String paymentMethod = "Payment Method";
  static const String amount = "Amount";
  static const String referenceCode = "Reference / Receipt #";
  static const String description = "Description";
  static const String transactionType = "Type";
  static const String debit = "Debit (Bill)";
  static const String credit = "Credit (Payment)";
  static const String balance = "Balance";

  // ===========================================================================
  // 7. SETTINGS & SAAS
  // ===========================================================================
  static const String settingsTitle = "Settings";
  static const String schoolProfile = "School Profile";
  static const String subscription = "Subscription";
  static const String currentPlan = "Current Plan";
  static const String upgradePlan = "Upgrade Plan";
  static const String planLimits = "Plan Limits";
  static const String studentsUsed = "Students Used";
  static const String usersUsed = "Users Used";
  static const String logout = "Log Out";

  // ===========================================================================
  // 8. ERRORS & VALIDATION
  // ===========================================================================
  static const String requiredField = "This field is required";
  static const String invalidEmail = "Please enter a valid email";
  static const String genericError = "Something went wrong. Please try again.";
  static const String networkError = "No internet connection.";
  static const String limitReached = "Plan limit reached. Please upgrade.";
  static const String successSave = "Saved successfully!";
  static const String confirmDelete = "Are you sure you want to delete this?";
}
