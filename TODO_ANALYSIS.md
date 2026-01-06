# TODO Analysis Report
**Project:** Fees Up - School Financial Management System  
**Generated:** January 5, 2026  
**Scope:** Complete project scan for all TODO, FIXME, HACK, and XXX comments  

---

## Executive Summary

This report analyzes **6 unique TODO items** found in the active codebase (excluding documentation and batch dump files). Each TODO has been evaluated for:
- **Missing Dependencies**: What needs to exist first
- **Implementation Complexity**: Development effort required
- **Impact**: Effect on system functionality
- **Recommendation**: Priority and approach

---

## TODO Inventory

### 🔴 **CRITICAL PRIORITY**

#### 1. DatabaseService.watchClasses() Implementation
**Location:** `lib/data/providers/students_provider.dart:39`

**Current Code:**
```dart
final classesProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, schoolId) {
    // TODO: Implement watchClasses in DatabaseService
    // For now, returning empty stream - user will need to create classes table
    return Stream.value([]);
  },
);
```

**Missing Dependencies:**
- ✅ `classes` table already exists in PowerSync schema (lib/data/services/schema.dart)
- ❌ `watchClasses()` method not implemented in DatabaseService

**What's Needed:**
```dart
// Add to lib/data/services/database_service.dart
Stream<List<Map<String, dynamic>>> watchClasses(String schoolId) {
  return _db.watch(
    'SELECT * FROM classes WHERE school_id = ? ORDER BY name ASC',
    parameters: [schoolId],
  );
}
```

**Impact:**
- Classes filter in Students screen is currently **disabled** (50% opacity)
- Users cannot filter students by class until implemented
- Affects UX in Students table filtering

**Recommendation:**
- **Priority:** HIGH
- **Effort:** 15 minutes
- **Action:** Add method to DatabaseService following existing `watchStudents()` pattern
- **Blocker:** None - schema exists, just needs implementation

---

#### 2. DatabaseService.watchNotifications() Implementation
**Location:** `lib/data/providers/students_provider.dart:49`

**Current Code:**
```dart
final notificationsProvider = StreamProvider<List<Map<String, dynamic>>>(
  (ref) {
    // TODO: Implement watchNotifications(userId) in DatabaseService
    // For now, returning empty stream
    return Stream.value([]);
  },
);
```

**Missing Dependencies:**
- ✅ `notifications` table exists in PowerSync schema
- ❌ `watchNotifications(userId)` method not in DatabaseService
- ⚠️ Requires userId parameter - needs auth integration

**What's Needed:**
```dart
// Add to lib/data/services/database_service.dart
Stream<List<Map<String, dynamic>>> watchNotifications(String userId) {
  return _db.watch(
    'SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC',
    parameters: [userId],
  );
}

// Usage in provider:
final notificationsProvider = StreamProvider<List<Map<String, dynamic>>>(
  (ref) {
    final user = ref.watch(currentUserProvider);
    if (user == null) return Stream.value([]);
    
    final db = DatabaseService();
    return db.watchNotifications(user.id);
  },
);
```

**Impact:**
- Real-time notifications not working
- Users won't see new notifications without page refresh
- Affects notification bell/counter in UI

**Recommendation:**
- **Priority:** HIGH
- **Effort:** 20 minutes (includes auth integration)
- **Action:** Implement DatabaseService method + connect to auth provider
- **Blocker:** None - currentUserProvider already exists in lib/data/providers/auth_provider.dart

---

### 🟡 **MEDIUM PRIORITY**

#### 3. Navigate to Payment/Subscription Screen
**Location:** `lib/core/widgets/premium_guard.dart:72`

**Current Code:**
```dart
ElevatedButton(
  onPressed: () {
    // TODO: Navigate to Payment/Subscription Screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Subscription Flow Coming Soon")),
    );
  },
```

**Missing Dependencies:**
- ❌ Payment/subscription screen not created
- ❌ Stripe/payment integration not implemented
- ❌ Subscription tier management UI not built

**What's Needed:**
1. **Create Subscription Screen:**
   - `lib/pc/screens/subscription_screen.dart`
   - Tier comparison (Free, Pro, Unlimited)
   - Feature matrix display
   - Payment button integration

2. **Payment Integration:**
   - Stripe Flutter SDK or equivalent
   - Webhook handlers for subscription events
   - Supabase Edge Functions for payment processing

3. **Navigation Route:**
   ```dart
   // Add to lib/core/routes/app_router.dart
   GoRoute(
     path: '/subscription',
     builder: (context, state) => const SubscriptionScreen(),
   ),
   
   // Update premium_guard.dart
   onPressed: () {
     context.push('/subscription');
   },
   ```

**Impact:**
- Users cannot upgrade subscription tiers
- Premium features remain locked
- Revenue generation blocked

**Recommendation:**
- **Priority:** MEDIUM (Business critical but requires external integrations)
- **Effort:** 3-5 days
  - UI: 1 day
  - Stripe integration: 2 days
  - Testing: 1-2 days
- **Action:** Defer until payment gateway decision made
- **Blocker:** Requires business decision on payment provider (Stripe, Paddle, etc.)

---

#### 4. School Selection Provider Integration
**Location:** `lib/data/providers/financial_providers.dart:385`

**Current Code:**
```dart
final selectedSchoolIdProvider = StateProvider<String?>((ref) {
  // TODO: Connect to auth/school selection provider
  return null;
});
```

**Missing Dependencies:**
- ⚠️ School selection mechanism not clear
- ⚠️ Multi-tenant user handling not defined

**What's Needed:**
Based on existing patterns, likely:
```dart
final selectedSchoolIdProvider = Provider<String?>((ref) {
  final user = ref.watch(currentUserProvider);
  if (user == null) return null;
  
  // Option 1: If user belongs to one school
  final profile = ref.watch(userProfileProvider);
  return profile.value?.schoolId;
  
  // Option 2: If user can switch between schools
  final schoolSelection = ref.watch(schoolSwitcherProvider);
  return schoolSelection;
});
```

**Impact:**
- Financial dashboard won't filter by correct school
- Transaction queries may return wrong data
- Multi-tenant data isolation issue

**Recommendation:**
- **Priority:** MEDIUM-HIGH
- **Effort:** 1-2 hours (depends on user/school relationship)
- **Action:** Clarify user-school relationship model first
- **Blocker:** Architecture decision needed - single-school vs multi-school per user

---

### 🟢 **LOW PRIORITY** (Infrastructure/DX)

#### 5. Replace Debug Print with Logging Framework
**Locations:**
- `lib/data/repositories/billing_repository.dart:38`
- `lib/data/services/transaction_service.dart:502`

**Current Code:**
```dart
void debugPrintError(String message) {
  // TODO: Replace with proper logging service
  // ignore: avoid_print
  print('❌ ERROR: $message');
}
```

**Missing Dependencies:**
- ❌ Logging framework not configured
- ❌ Log levels not defined
- ❌ Log output destinations not set up

**What's Needed:**
```dart
// Add dependency to pubspec.yaml
dependencies:
  logger: ^2.0.0  # or firebase_analytics, sentry_flutter, etc.

// Create lib/core/services/logging_service.dart
import 'package:logger/logger.dart';

class LoggingService {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  static void warning(String message) {
    _logger.w(message);
  }

  static void info(String message) {
    _logger.i(message);
  }

  static void debug(String message) {
    _logger.d(message);
  }
}

// Replace all debugPrintError calls:
LoggingService.error('Failed to fetch billing configurations: $e');
```

**Impact:**
- Current logging works but not production-ready
- Missing structured logging for debugging
- No log aggregation or filtering

**Recommendation:**
- **Priority:** LOW (Nice-to-have, not blocking)
- **Effort:** 2-3 hours
- **Action:** Implement when preparing for production
- **Blocker:** None
- **Suggested Package:** `logger` for dev, `sentry_flutter` for production error tracking

---

#### 6. Two-Factor Authentication Verification Logic
**Location:** `lib/pc/widgets/profile/two_factor_dialog.dart:158`

**Current Code:**
```dart
ElevatedButton(
  onPressed: () {
    // TODO: Implement verification logic
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("2FA Enabled Successfully!")),
    );
  },
```

**Missing Dependencies:**
- ❌ OTP verification service not implemented
- ❌ TOTP/SMS integration not configured
- ❌ Backend 2FA endpoints not created

**What's Needed:**
1. **Backend Setup:**
   - Supabase Auth 2FA (built-in support)
   - SMS provider (Twilio) or TOTP library

2. **Frontend Implementation:**
   ```dart
   Future<void> _verifyAndEnable2FA(String code) async {
     try {
       // Verify TOTP code
       final response = await Supabase.instance.client.auth.verifyOTP(
         token: code,
         type: OtpType.totp,
       );
       
       if (response.user != null) {
         // Enable 2FA for user
         await Supabase.instance.client.rpc('enable_2fa');
         Navigator.of(context).pop();
         ScaffoldMessenger.of(context).showSnackBar(
           const SnackBar(content: Text("2FA Enabled Successfully!")),
         );
       }
     } catch (e) {
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text("Verification failed: $e")),
       );
     }
   }
   ```

**Impact:**
- 2FA dialog shows but doesn't actually enable security
- Security feature incomplete
- User accounts less protected

**Recommendation:**
- **Priority:** LOW-MEDIUM (Security feature but not core functionality)
- **Effort:** 4-6 hours
  - Supabase Auth setup: 2 hours
  - Frontend integration: 2 hours
  - Testing: 1-2 hours
- **Action:** Implement as part of security hardening sprint
- **Blocker:** Requires Supabase Auth configuration decision (TOTP vs SMS)

---

## TODOs Found in Documentation (Informational Only)

The following TODOs appear in `POWERSYNC_REALTIME_SECURITY_AUDIT.md` but are **architectural recommendations** rather than code-level TODOs:

1. **Create connection status provider** - PowerSync connection monitoring UI
2. **Create permission service** - Role-based access control service
3. **Update all services to use DatabaseService** - Migration from direct Supabase
4. **Add user_id to all create operations** - RLS compliance
5. **Create sync error provider** - Offline sync error handling
6. **Show errors in UI** - User-facing error messages
7. **Replace FutureProvider with StreamProvider** - Real-time reactivity
8. **Create sync status indicator** - Visual sync feedback
9. **Add to AppBar/status bar** - UI placement for sync status
10. **Enforce environment variable** - Configuration management
11. **Create security audit logger** - Audit trail system
12. **Create ARCHITECTURE.md** - Architecture documentation
13. **Add to CONTRIBUTING.md** - Developer onboarding docs
14. **Create offline test suite** - Offline mode testing
15. **Create RLS test suite** - Security policy testing
16. **Create sync test suite** - PowerSync integration tests
17. **Add indexes to frequently queried columns** - Database optimization
18. **Add throttling to high-frequency streams** - Performance optimization
19. **Add pagination for student lists** - Large dataset handling

**Note:** These are part of the PowerSync architecture improvement roadmap and should be prioritized separately from code-level TODOs.

---

## Build System TODOs

### CMakeLists.txt Comments
**Locations:**
- `linux/flutter/CMakeLists.txt:9`
- `windows/flutter/CMakeLists.txt:9`

**Content:**
```cmake
# TODO: Move the rest of this into files in ephemeral. See
```

**Analysis:**
- These are **Flutter-generated** comments
- Part of standard Flutter template
- Not actionable for application development

**Recommendation:**
- **Priority:** N/A (Framework-level comment)
- **Action:** Ignore - Flutter team will address in framework updates

---

## Implementation Roadmap

### Phase 1: Critical Fixes (Week 1)
**Total Effort:** ~2 hours

1. **Implement DatabaseService.watchClasses()** - 15 min
   - Add method to DatabaseService
   - Test with classes filter

2. **Implement DatabaseService.watchNotifications()** - 20 min
   - Add method to DatabaseService
   - Connect to currentUserProvider
   - Test notification display

3. **Fix selectedSchoolIdProvider** - 1-2 hours
   - Clarify user-school relationship
   - Connect to auth/profile providers
   - Test multi-tenant filtering

### Phase 2: User-Facing Features (Week 2-3)
**Total Effort:** 4-6 days

1. **Two-Factor Authentication** - 4-6 hours
   - Configure Supabase Auth
   - Implement OTP verification
   - Add error handling

2. **Subscription/Payment Flow** - 3-5 days
   - Design subscription screen
   - Integrate payment provider
   - Test upgrade flow

### Phase 3: Infrastructure Improvements (Ongoing)
**Total Effort:** 2-3 hours

1. **Logging Framework** - 2-3 hours
   - Add logger package
   - Create LoggingService
   - Replace all debugPrintError calls
   - Configure log levels

---

## Dependencies Summary

### ✅ Already Available
- PowerSync database and schema
- Auth provider (currentUserProvider)
- DatabaseService base infrastructure
- GoRouter navigation
- Supabase client

### ❌ Missing (Requires Creation)
- **watchClasses() method** → Simple addition
- **watchNotifications() method** → Simple addition
- **Subscription screen** → New screen + routing
- **Payment integration** → External service setup
- **Logging service** → New service class
- **2FA verification** → Auth configuration
- **School selection logic** → Architecture decision needed

### ⚠️ Unclear/Decision Needed
- **User-school relationship model** - Single vs multi-school access
- **Payment provider choice** - Stripe vs Paddle vs other
- **2FA method** - TOTP vs SMS
- **Logging destination** - Console vs Sentry vs Firebase

---

## Risk Assessment

### 🔴 High Risk
- **Missing watchClasses/watchNotifications**: Features appear functional but don't work
- **selectedSchoolIdProvider null**: Multi-tenant data leakage risk

### 🟡 Medium Risk
- **No payment flow**: Cannot monetize, but doesn't break core features
- **2FA incomplete**: Security gap but not blocking basic operations

### 🟢 Low Risk
- **Debug print statements**: Works in development, just not production-grade
- **Build system comments**: Framework-level, no impact on application

---

## Quick Win Checklist

Focus on these for immediate impact:

- [ ] **5 min:** Add `watchClasses()` to DatabaseService
- [ ] **5 min:** Test classes filter in Students screen
- [ ] **10 min:** Add `watchNotifications()` to DatabaseService  
- [ ] **10 min:** Connect notificationsProvider to auth
- [ ] **30 min:** Fix selectedSchoolIdProvider (decide on architecture first)
- [ ] **15 min:** Add route for student details screen to GoRouter (if using routing)

---

## Conclusion

The TODO items in this codebase are **minimal and well-contained**. The critical blockers (watchClasses, watchNotifications) can be resolved in **under 1 hour** of focused development. The remaining items are either:

1. **Business decisions** (payment provider, 2FA method)
2. **Infrastructure polish** (logging, error handling)
3. **Feature additions** (subscription UI)

**Recommended Next Steps:**
1. Implement Phase 1 items today (2 hours max)
2. Make architecture decisions for selectedSchoolIdProvider
3. Plan Phase 2 implementation timeline based on business priorities

The codebase is in **good shape** - these TODOs represent planned work rather than technical debt.

---

**Report End**
