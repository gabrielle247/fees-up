// ==========================================
// FILE: ./constants/app_strings.dart
// ==========================================

class AppStrings {
  const AppStrings._();


  static const String pageTitle = "Billing Configuration";
  static const String header = "Fee Structure & Cycles";
  static const String subHeader = "Define how your school generates invoices and collects payments.";

  // Section: Billing Cycle
  static const String secCycle = "Billing Cycle";
  static const String lblFrequency = "Invoicing Frequency";
  static const String lblDueDate = "Default Due Date";
  static const String hintDueDate = "Days after invoice generation";
  
  // Frequency Options
  static const String freqTermly = "Termly (Standard)";
  static const String freqMonthly = "Monthly";
  static const String freqAdhoc = "Ad-hoc (Manual Only)";

  // Section: Fee Structure
  static const String secStructure = "Fee Heads (Standard)";
  static const String btnAddHead = "Add Fee Head";
  static const String lblTuition = "Tuition Fee";
  static const String lblLevy = "General Levy";
  static const String lblSports = "Sports Fee";
  static const String currency = "\$";

  // Section: Penalties
  static const String secPenalties = "Late Payment Rules";
  static const String lblEnableLateFee = "Enable Late Fees";
  static const String lblPenaltyType = "Penalty Type";
  static const String typeFixed = "Fixed Amount";
  static const String typePercent = "Percentage (%)";
  static const String lblGracePeriod = "Grace Period (Days)";

  // Actions
  static const String btnSaveFinish = "Complete Setup";
  static const String routeDashboard = "/dashboard";

  // ===========================================================================
  // 14. STUDENT REGISTRATION FORM
  // ===========================================================================
  static const String btnRegister = "Register Student";
  
  // Section Headers
  static const String secPersonal = "Personal Information";
  static const String secAcademic = "Academic & Subjects";
  static const String secGuardian = "Guardian Details";
  static const String secFinance = "Financials & Registration";

  // Personal Fields
  static const String lblFirstName = "First Name";
  static const String lblLastName = "Last Name";
  static const String lblNationalId = "National ID";
  static const String lblDob = "Date of Birth";
  static const String hintDob = "mm/dd/yyyy";
  static const String lblGender = "Gender";
  static const String optMale = "Male";
  static const String optFemale = "Female";

  // Academic Fields
  static const String lblStudentType = "Student Type";
  static const String optDay = "Day Scholar";
  static const String optBoarding = "Boarder";
  static const String lblAdmitDate = "Admission Date";
  static const String lblSubjects = "Registered Subjects";
  static const String btnSelectSubjects = "Select Subjects";
  static const String hintSubjects = "Tap to select Zimsec subjects...";
  
  // Guardian Fields
  static const String lblGName = "Guardian Full Name";
  static const String lblGPhone = "Guardian Phone";
  static const String lblGEmail = "Guardian Email";
  static const String lblGRelation = "Relationship";
  static const String optFather = "Father";
  static const String optMother = "Mother";
  static const String optGuardian = "Legal Guardian";

  // Finance Fields
  static const String lblFeeStruct = "Fee Structure";
  static const String hintFeeStruct = "Select applicable fees...";
  static const String lblAmountPaid = "Amount Paid on Registration";
  static const String hintAmount = "0.00";

  // Dialogs
  static const String dlgSubjectTitle = "Select Subjects";
  static const String dlgCancel = "Cancel";
  static const String dlgConfirm = "Confirm Selection";
  static const String errRequired = "Required";
  static const String errEmail = "Invalid Email";



  static const String period = "/mo";
  static const String btnChoose = "Choose";
  static const String lblMostPopular = "MOST POPULAR";

  // IDs
  static const String idBasic = "basic";
  static const String idPro = "pro";
  static const String idEnt = "enterprise";

  // --- BASIC PLAN ---
  static const String titleBasic = "Basic";
  static const String priceBasic = "19";
  static const String descBasic = "Best for small schools";
  static const List<String> featuresBasic = [
    "Up to 100 Students",
    "2 Admin Accounts",
    "Basic Fee Reports",
    "Email Support"
  ];

  // --- PRO PLAN ---
  static const String titlePro = "Pro";
  static const String pricePro = "49";
  static const String descPro = "Ideal for growing institutions";
  static const List<String> featuresPro = [
    "Up to 500 Students",
    "5 Admin Accounts",
    "SMS Notifications",
    "Priority Support",
    "Advanced Analytics"
  ];

  // --- ENTERPRISE PLAN ---
  static const String titleEnt = "Enterprise";
  static const String priceEnt = "99";
  static const String descEnt = "For large scale management";
  static const List<String> featuresEnt = [
    "Unlimited Students",
    "Unlimited Admin Accounts",
    "API Access",
    "Dedicated Manager",
    "Custom Branding"
  ];

  static const String routeBilling = "/billing";
  static const String routePlans = "/plans";
  static const String btnUpgrade = "Upgrade Plan";
  static const String btnCurrentPlan = "Current Plan";
  static const String btnSelectPlan = "Select Plan";
  static const String planSelectionSuccess = "Plan selected successfully!";
  static const String planSelectionFailure = "Failed to select plan. Please try again.";
  // ===========================================================================\
  // 13. ACADEMIC & CALENDAR (NEW)
  // ===========================================================================

  // Screen Specific
  static const String stepTitle = "Step 2: Academic Config";
  static const String stepProgress = "2 of 3";
  static const String headline = "How do you operate?";
  static const String subtitle = "Configure your currency and academic calendar structure.";
  
  // Labels
  static const String labelBaseCurrency = "Base Currency";
  static const String labelTermSystem = "Term System";
  static const String hintYear = "YYYY";

  // Data Values - Currencies
  static const String valUsdCode = "USD";
  static const String valUsdName = "United States Dollar (\$)";
  static const String valZwgCode = "ZWG";
  static const String valZwgName = "Zimbabwe Gold (ZiG)";
  static const String valZarCode = "ZAR";
  static const String valZarName = "South African Rand (R)";
  static const String valGbpCode = "GBP";
  static const String valGbpName = "British Pound (£)";

  // Data Values - Systems
  static const String id3Terms = "3_terms";
  static const String name3Terms = "3 Terms (Standard)";
  static const String desc3Terms = "Trimester system (Jan-Apr, May-Aug, Sep-Dec)";
  
  static const String id2Semesters = "2_semesters";
  static const String name2Semesters = "2 Semesters";
  static const String desc2Semesters = "Half-year system common in universities";
  
  static const String id4Quarters = "4_quarters";
  static const String name4Quarters = "4 Quarters";
  static const String desc4Quarters = "Quarterly system";
  
  static const String nextBtnLabel = "Next: Select Plan";

  // Map Keys (To avoid "key" strings in logic)
  static const String kCode = "code";
  static const String kName = "name";
  static const String kId = "id";
  static const String kDesc = "desc";
  // ===========================================================================
  // 1. GENERAL APP INFO
  // ===========================================================================
  static const String appName = "Fees Up";
  static const String appVersion = "Alpha 1.0.0";
  static const String currencySymbol = "\$";
  static const String currencyUSD = "USD";
  static const String appLoggerName = "Fees Up Logger";
  static const String error = "Error";
  static const String stackTrace = "StackTrace";
  static const String successPrefix = "✅ SUCCESS";

  // ===========================================================================
  // 2. COMMON ACTIONS
  // ===========================================================================
  static const String save = "Save";
  static const String cancel = "Cancel";
  static const String delete = "Delete";
  static const String edit = "Edit";
  static const String view = "View";
  static const String search = "Search";
  static const String filter = "Filter";
  static const String export = "Export";
  static const String next = "Next";
  static const String previous = "Previous";
  static const String back = "Back";
  static const String confirm = "Confirm";
  static const String loading = "Loading...";
  static const String logout = "Logout";
  static const String viewAll = "View All";
  static const String viewList = "View List";
  static const String viewFullLedger = "View Full Ledger";
  static const String generateAll = "Generate All";
  static const String pay = "Pay";
  static const String history = "History";
  static const String manageFees = "Manage Fees";
  static const String manageTerms = "Manage Terms";
  static const String exportData = "Export Data";
  static const String editDetails = "Edit Details";
  static const String createSchool = "Create School";
  static const String syncNow = "Sync Now";
  static const String loadMore = "Load more...";
  static const String notAvailable = "N/A";
  static const String contact = "Contact";
  static const String remind = "Remind";
  static const String share = "Share";
  static const String call = "Call";
  static const String add = "Add";
  static const String create = "Create";
  static const String update = "Update";
  static const String remove = "Remove";
  static const String clear = "Clear";
  static const String apply = "Apply";
  static const String close = "Close";

  // ===========================================================================
  // 3. AUTHENTICATION & SECURITY
  // ===========================================================================
  static const String loginTitle = "Welcome Back";
  static const String welcomeBack = "Welcome Back";
  static const String loginSubtitle = "Sign in to manage your school.";
  static const String emailLabel = "Email Address";
  static const String emailAddressHint = "you@example.com";
  static const String email = "Email";
  static const String password = "Password";
  static const String passwordLabel = "Password";
  static const String passwordHint = "Enter your password";
  static const String loginButton = "Sign In";
  static const String logIn = "Log In";
  static const String login = "Login";
  static const String loginFailed = "Login failed";
  static const String forgotPassword = "Forgot Password?";
  static const String resetPassword = "Reset Password";
  static const String resetPasswordSubtitle =
      "Enter your account email to receive a reset link.";
  static const String resetPasswordHelp =
      "Check your inbox and spam folder for the reset link.";
  static const String resetPasswordSuccess =
      "Reset link sent. Follow the email instructions to continue.";
  static const String resetPasswordFailure =
      "Could not send a reset link. Please verify your email and try again.";
  static const String rememberMe = "Remember me";
  static const String noAccount = "Don't have an account?";
  static const String signUp = "Sign Up";
  static const String schoolIdLabel = "School ID/Code *";
  static const String schoolIdHint = "e.g. 88392";
  static const String authenticating = "Authenticating...";

  // Signup
  static const String signupTitle = "Join Fees Up";
  static const String signupSubtitle = "Create your account to get started.";
  static const String signupFailed = "Signup failed";
  static const String createAccount = "Create Account";
  static const String fullName = "Full Name";
  static const String fullNameRequired = "Full name is required";
  static const String fullNameTooShort =
      "Full name must be at least 3 characters";
  static const String confirmPassword = "Confirm Password";
  static const String confirmPasswordRequired = "Please confirm your password";
  static const String passwordsDoNotMatch = "Passwords do not match";
  static const String alreadyHaveAccount = "Already have an account?";
  static const String selectRole = "Select Role";
  static const String roleRequired = "Please select a role";
  static const String failedToLoadRoles = "Failed to load roles";

  // 2FA & Security
  static const String twoFactorTitle = "Two-Factor Authentication";
  static const String twoFactorSubtitle =
      "Please enter the code sent to your device.";
  static const String verifyCode = "Verify Code";
  static const String resendCode = "Resend Code";
  static const String codeSent = "Code sent successfully";
  static const String setup2FA = "Setup 2FA";
  static const String securitySettings = "Security Settings";

  // Validation Messages
  static const String emailRequired = "Email is required";
  static const String enterValidEmail = "Please enter a valid email";
  static const String passwordRequired = "Password is required";
  static const String passwordTooShort =
      "Password must be at least 6 characters";

  // ===========================================================================
  // 4. DASHBOARD & ONBOARDING
  // ===========================================================================
  static const String dashboardTitle = "Dashboard";
  static const String healthScore = "Financial Health";
  static const String collectedThisMonth = "Collected (Month)";
  static const String outstandingFees = "Outstanding Fees";
  static const String outstandingInvoices = "Outstanding Invoices";
  static const String totalOutstandingCaption =
      "Total outstanding value to be collected";
  static const String activeStudents = "Active Students";
  static const String expenses = "Expenses";
  static const String recentTransactions = "Recent Transactions";
  static const String quickActions = "Quick Actions";
  static const String totalIncome = "Total Income";
  static const String totalOwing = "Total Owing";
  static const String welcomeBackAdmin = "Welcome back, Admin";
  static const String schoolNamePlaceholder = "Harare High School";

  // Onboarding
  static const String welcomeTitle = "Welcome to Fees Up";
  static const String welcomeSubtitle =
      "To get started, create your school profile or load example data.";
  static const String loadExampleData = "Load Example Data (Demo)";
  static const String createNewSchool = "Create New School";
  static const String failedToLoadDemoData = "Failed to load demo data";
  static const String createYourSchoolTitle = "Create Your School";
  static const String createYourSchoolSubtitle =
      "Set up your school profile to start managing fees and student data";
  static const String createSchoolContinue = "Create School & Continue";
  static const String joinExistingSchool = "Join Existing School";
  static const String schoolNameLabel = "School Name";
  static const String emailAddressLabel = "Email Address";
  static const String requiredField = "This field is required";
  static const String genericError = "An error occurred";

  // ===========================================================================
  // 5. STUDENTS (REGISTRY & PAYER INFO)
  // ===========================================================================
  static const String studentsTitle = "Students";
  static const String allStudents = "All Students";
  static const String activeLabel = "Active";
  static const String inactiveLabel = "Inactive";
  static const String suspendedLabel = "Suspended";
  static const String addStudent = "Add Student";
  static const String studentDetails = "Student Profile";

  // Tabs
  static const String personalInformation = "Personal Information";
  static const String financialInformation = "Financial Information";
  static const String communicationLog = "Communication Log";

  // Sections
  static const String personalInfo = "Personal Info";
  static const String academicInfo = "Academic Info";
  static const String guardianInfo = "Guardian / Payer Info"; // NEW

  // Fields
  static const String firstName = "First Name";
  static const String lastName = "Last Name";
  static const String dob = "Date of Birth";
  static const String gender = "Gender";
  static const String nationalId = "National ID";
  static const String enrollmentStatus = "Status";
  static const String currentClass = "Current Class";
  static const String student = "Student";

  // New Academic Fields
  static const String admissionNumber = "Admission Number";
  static const String admissionDate = "Date of Admission";
  static const String studentTypeLabel = "Student Type";
  static const String dayScholar = "Day Scholar";
  static const String boarder = "Boarder";
  static const String international = "International";

  // Guardian / Payer Fields (Critical for Finance)
  static const String guardianName = "Guardian Name";
  static const String guardianPhone = "Guardian Phone";
  static const String guardianEmail = "Guardian Email";
  static const String guardianRelationship = "Relationship";
  static const String relationshipFather = "Father";
  static const String relationshipMother = "Mother";
  static const String relationshipSponsor = "Sponsor/Other";

  // Status & Balance
  static const String active = "ACTIVE";
  static const String inactive = "INACTIVE";
  static const String suspended = "SUSPENDED";
  static const String owing = "OWING";
  static const String paid = "PAID";
  static const String outstanding = "Outstanding";
  static const String outstandingBalance = "Outstanding Balance";
  static const String totalPaidLabel = "Total Paid";
  static const String totalInvoicedLabel = "Total Invoiced";
  static const String pendingInvoices = "Pending Invoices";
  static const String noStudentsFound = "No students found";
  static const String noStudentsOnPage = "No students on this page";
  static const String totalStudentsPrefix = "Total:";

  // ===========================================================================
  // 6. FINANCE (THE LEDGER)
  // ===========================================================================
  static const String financeTitle = "Finance";
  static const String ledger = "Ledger";
  static const String ledgerTitle = "Ledger";
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
  static const String receipts = "Receipts";
  static const String invoices = "Invoices";
  static const String pending = "Pending";
  static const String monthTotal = "Month Total";
  static const String entriesSuffix = "entries";
  static const String receipt = "Receipt";
  static const String invoice = "Invoice";
  static const String classFee = "Class Fee";
  static const String noRecentTransactions = "No recent transactions";
  static const String errorLoadingTransactions = "Error loading transactions";
  static const String invoiceGenerationComingSoon =
      "Invoice Generation is coming soon!";

  // Invoice & Fee Status
  static const String issued = "ISSUED";
  static const String term = "TERM";
  static const String monthly = "MONTHLY";
  static const String yearly = "YEARLY";
  static const String fixed = "FIXED";
  static const String monthlyRecurrenceKey = "monthly";
  static const String monthlySubscriptionCategory = "MONTHLY_SUBSCRIPTION";

  // Ledger Transaction Types
  static const String debitType = "DEBIT";
  static const String creditType = "CREDIT";

  // Activity Feed Types
  static const String paymentType = "payment";
  static const String invoiceType = "invoice";
  static const String enrollmentType = "enrollment";

  // Fallback & Templates
  static const String unknownStudent = "Unknown Student";
  static const String paymentFrom = "Payment from";
  static const String invoiceFor = "Invoice for";

  // Reports & Analytics
  static const String revenueReports = "Revenue Reports";
  static const String totalLifetimeRevenue = "Total Lifetime Revenue";
  static const String growth = "Growth";
  static const String placeholderMoney = "\$0.00";
  static const String zeroPercent = "0.0%";

  // Filters
  static const String allTime = "All Time";
  static const String thisMonth = "This Month";
  static const String last3Months = "Last 3 Months";
  static const String type = "Type";
  static const String all = "All";
  static const String sortBy = "Sort By";
  static const String dateNewest = "Date (Newest)";
  static const String amountHigh = "Amount (High)";

  // ===========================================================================
  // 7. CONFIGS & SETTINGS
  // ===========================================================================
  static const String settingsTitle = "Settings";
  static const String configsTitle = "Configs";
  static const String schoolProfile = "School Profile";
  static const String subscription = "Subscription";
  static const String currentPlan = "Current Plan";
  static const String upgradePlan = "Upgrade Plan";
  static const String planLimits = "Plan Limits";
  static const String studentsUsed = "Students Used";
  static const String usersUsed = "Users Used";

  // Settings Sections
  static const String advancedSettingsTitle = "ADVANCED SETTINGS";
  static const String syncAndBackupTitle = "SYNC & BACKUP";
  static const String academicCalendarTitle = "ACADEMIC CALENDAR";
  static const String feeChargesTitle = "FEE CHARGES";
  static const String currentSession = "CURRENT SESSION";
  static const String week = "Week";
  static const String weeksTotalSuffix = "Weeks Total";
  static const String language = "Language";
  static const String english = "English";
  static const String theme = "Theme";
  static const String livelySlate = "Lively Slate";
  static const String helpAndSupport = "Help & Support";
  static const String systemSynchronized = "System Synchronized";
  static const String lastSyncedJustNow = "Last synced: just now";
  static const String syncCompleted = "Sync completed";
  static const String syncFailedPrefix = "Sync failed";

  // School Creation Form & Detailed Profile
  static const String schoolNameHint = "e.g. Harare High School";
  static const String phoneNumberLabel = "Phone Number";
  static const String phoneNumberHint = "+263 78 123 4567";

  // New Finance Identity Fields
  static const String addressLine1Label = "Address Line 1";
  static const String addressLine1Hint = "123 Education Blvd";
  static const String cityLabel = "City/Town";
  static const String cityHint = "Harare";
  static const String taxIdLabel = "Tax ID / Reg Number";
  static const String taxIdHint = "e.g. 100-223-99";
  static const String websiteLabel = "Website";
  static const String websiteHint = "www.hararehigh.ac.zw";
  static const String mottoLabel = "Motto / Slogan";
  static const String mottoHint = "Excellence in Education";

  static const String countryLabel = "Country *";
  static const String districtRegionLabel = "District/Region *";
  static const String districtRegionHint = "e.g. Harare";
  static const List<String> countryOptions = [
    'Zimbabwe',
    'South Africa',
    'Botswana',
    'Zambia',
  ];

  // ===========================================================================
  // 8. DATE & TIME
  // ===========================================================================
  static const String today = "Today";
  static const String yesterday = "Yesterday";
  static const String am = "AM";
  static const String pm = "PM";
  static const List<String> monthsAbbrev = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  static const String justNow = "just now";
  static const String minutesAgo = "m ago";
  static const String hoursAgo = "h ago";
  static const String daysAgo = "d ago";
  static const String weeksAgo = "w ago";
  static const String monthsAgo = "mo ago";
  static const String yearsAgo = "y ago";
  static const String startDate = "Start Date";
  static const String endDate = "End Date";
  static const String dueDate = "Due Date";
  static const String date = "Date";

  // ===========================================================================
  // 9. ERRORS & VALIDATION
  // ===========================================================================

  static const String required = "Required";
  static const String invalidEmail = "Invalid email";
  static const String networkError = "No internet connection.";
  static const String limitReached = "Plan limit reached. Please upgrade.";
  static const String successSave = "Saved successfully!";
  static const String confirmDelete = "Are you sure you want to delete this?";
  static const String noSchoolFoundError = "No school found in the database.";
  static const String syncErrorDetails =
      "Please check your internet connection and try again.";
  static const String invalidPayload = "Invalid encrypted payload";

  // Repository Error Messages
  static const String feeStructureRepositoryAllForSchoolFailed =
      "FeeStructureRepository: allForSchool failed";
  static const String feeStructureRepositorySaveFailed =
      "FeeStructureRepository: save failed";
  static const String invoiceRepositoryAllForSchoolFailed =
      "InvoiceRepository: allForSchool failed";
  static const String invoiceRepositoryItemsForInvoiceFailed =
      "InvoiceRepository: itemsForInvoice failed";
  static const String invoiceRepositorySaveInvoiceFailed =
      "InvoiceRepository: saveInvoice failed";
  static const String invoiceRepositorySaveItemFailed =
      "InvoiceRepository: saveItem failed";
  static const String ledgerRepositoryAllForStudentFailed =
      "LedgerRepository: allForStudent failed";
  static const String ledgerRepositoryAllForSchoolFailed =
      "LedgerRepository: allForSchool failed";
  static const String paymentRepositoryAllForSchoolFailed =
      "PaymentRepository: allForSchool failed";
  static const String paymentRepositorySaveFailed =
      "PaymentRepository: save failed";
  static const String studentRepositoryGetAllFailed =
      "StudentRepository: getAll failed";
  static const String studentRepositoryGetByIdFailed =
      "StudentRepository: getById failed";
  static const String studentRepositorySaveFailed =
      "StudentRepository: save failed";
  static const String studentRepositoryDeleteFailed =
      "StudentRepository: delete failed";
  static const String schoolRepositoryGetCurrentSchoolFailed =
      "SchoolRepository: getCurrentSchool failed";
  static const String schoolRepositorySaveFailed =
      "SchoolRepository: save failed";

  // ===========================================================================
  // 10. DATABASE
  // ===========================================================================
  static const String databaseName = "fees_up.db";

  // ===========================================================================
  // 11. COMMUNICATION AUDIT TRAIL
  // ===========================================================================
  static const String communicationTitle = "Communication Log";
  static const String sendSms = "Send SMS";
  static const String sendWhatsapp = "Send via WhatsApp";
  static const String sendEmail = "Send Email";
  static const String historyLog = "History Log";

  // Purpose
  static const String purposeReminder = "Payment Reminder";
  static const String purposeReceipt = "Receipt Sent";
  static const String purposeInvoice = "Invoice Sent";
  static const String purposeGeneral = "General Notice";

  // Message Templates
  static const String reminderTemplate =
      "Dear {guardian}, please note that {student} has an outstanding balance of {amount}. Please pay by {date}.";
  static const String receiptTemplate =
      "Dear {guardian}, we acknowledge receipt of {amount} for {student}. Thank you.";
  static const String invoiceTemplate =
      "Dear {guardian}, an invoice of {amount} has been generated for {student}. Please settle by {date}.";
  static const String generalNoticeTemplate =
      "Dear {guardian}, this is a notice regarding {student}. Please contact the school for more details.";

  //Reports & Analytics
  static const String communicationReports = "Communication Reports";
  static const String totalMessagesSent = "Total Messages Sent";
  static const String totalSmsSent = "Total SMS Sent";
  static const String totalEmailsSent = "Total Emails Sent";
  static const String totalWhatsappSent = "Total WhatsApp Messages Sent";

  //Reset Password
  static const String resetPasswordTitle = "Reset Your Password";
  static const String enter6DigitCode = "Enter 6-Digit Code";
  static const String newPasswordLabel = "New Password";
  static const String confirmNewPasswordLabel = "Confirm New Password";
  static const String passwordRequirement =
      "Password must be at least 6 characters.";
  static const String passwordMismatch = "Passwords do not match.";
  static const String confirmPasswordLabel = "Confirm New Password";
  static const String confirmPasswordHint =
      "Re-enter your new password to confirm.";
  static const String schoolCheck = "School Check";
  static const String setUpANewSchool = "Set up a new school";
  static const String haveAccess = "I already have access";

  // ===========================================================================
  // 12. ONBOARDING & SETUP
  // ===========================================================================

  // --- New Onboarding Strings ---
  static const String onboardingPathSubtitle =
      "Choose your path to get started.";
  static const String adminSubtitle =
      "I am an Admin or Principal setting up a new organization.";
  static const String studentSubtitle =
      "I have an invite code or I am a student/parent.";
  static const String joinCodeSubtitle =
      "Enter the code provided by your admin.";
  static const String accessCodeLabel = "Access Code / School ID";

  // --- Reset Password Flow ---
  static const String resetCodeSent =
      "We sent you a 6-digit code. Check your email and enter it below.";
  static const String requestCodeFirst = "Request a code first.";
  static const String enterSixDigitCode =
      "Enter the 6-digit code from your email.";
  static const String passwordUpdated = "Password updated successfully!";
  static const String resetUpdateFailed =
      "Invalid code or update failed. Try again.";
  static const String enterCodePrompt = "Enter the code and your new password.";
  static const String codeLabel = "6-digit code";
  static const String codeHint = "Enter the code from your email";
  static const String verifyAndUpdateBtn = "Verify code & update password";

  static String schoolSetup = "School Setup";

  // --- School Setup Keys ---
  static const String schoolInfo = "School Information";
  static const String schoolName = "School Name";
  static const String subdomain = "Subdomain";
  static const String schoolEmail = "Official Email";
  static const String schoolPhone = "Phone Number";
  static const String schoolAddress = "Address Line 1";
  static const String schoolCity = "City";
  static const String schoolCountry = "Country";
  static const String schoolWebsite = "Website (Optional)";
  static const String schoolTaxId = "Tax ID / Registration";
  static const String subdomainHint = "your-school.feesup.com";
  static const String setupFinish = "Create Institution";

  // --- Setup Step Titles ---
  static const String setupIdentity = "Identity";
  static const String setupIdentitySub =
      "Define how your school appears in the system.";
  static const String setupContact = "Communication";
  static const String setupContactSub =
      "Primary contact details for school administration.";
  static const String setupLocation = "Location";
  static const String setupLocationSub =
      "Physical address for billing and record-keeping.";

  // --- School Setup UI ---
  static const String stepIdentity = "Identity";
  static const String stepIdentitySub =
      "Define your institution's digital persona.";
  static const String stepContact = "Communication";
  static const String stepContactSub = "Set up administrative reachability.";
  static const String stepLocation = "Location";
  static const String stepLocationSub = "Physical presence and billing data.";

  // ===========================================================================
  // 13. ACADEMIC & CALENDAR (NEW)
  // ===========================================================================
  static const String academicYears = "Academic Years";
  static const String manageAcademicYears = "Manage Academic Years";
  static const String createAcademicYear = "Create Academic Year";
  static const String editAcademicYear = "Edit Academic Year";
  static const String noAcademicYears = "No academic years found.";
  static const String lockYear = "Lock Year";
  static const String unlockYear = "Unlock Year";

  static const String terms = "Terms";
  static const String manageTermsSubtitle =
      "Configure terms within academic years";
  static const String createTerm = "Create Term";
  static const String currentTerm = "Current Term";
  static const String termNameLabel = "Term Name";
  static const String termNameHint = "e.g. Term 1";

  // Enrollment / Classes
  static const String classes = "Classes";
  static const String streams = "Streams";
  static const String gradeLevel = "Grade Level";
  static const String classStream = "Class Stream";
  static const String enroll = "Enroll";
  static const String promoteStudents = "Promote Students";
  static const String promote = "Promote";

  // ===========================================================================
  // 14. DISCOUNTS & SCHOLARSHIPS (NEW)
  // ===========================================================================
  static const String discounts = "Discounts";
  static const String scholarships = "Scholarships";
  static const String manageDiscounts = "Manage Discounts";
  static const String createDiscount = "Create Discount";
  static const String discountName = "Discount Name";
  static const String discountValue = "Percentage (%)";
  static const String applyDiscount = "Apply Discount";
  static const String staffChild = "Staff Child";
  static const String sportsBursary = "Sports Bursary";
  static const String noDiscountsFound = "No active discounts found.";

  // ===========================================================================
  // 15. PLACEHOLDER & GENERIC UI (FOR PLACEBO SCREENS)
  // ===========================================================================
  static const String placeholderTitle = "Title Goes Here";
  static const String placeholderSubtitle =
      "This is a placeholder subtitle for UI testing purposes.";
  static const String loremIpsumShort =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit.";
  static const String loremIpsumLong =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam.";

  // Generic Form Keys (Reuse these!)
  static const String nameLabel = "Name";
  static const String nameHint = "Enter name";
  static const String descriptionLabel = "Description";
  static const String descriptionHint = "Enter description";
  static const String statusLabel = "Status";
  static const String actions = "Actions";
  static const String details = "Details";
  static const String summary = "Summary";
  static const String notes = "Notes";
  static const String stepXofY = "Step {current} of {total}";
  static const String optional = "(Optional)";
  static const String completed = "Completed";
  static const String inProgress = "In Progress";

  //Key Strings
  static const String keyName = "name";
  static const String keyAmount = "amount";


  //Str
   static const String numText= "16";
    static const String dayText= "Day";


}