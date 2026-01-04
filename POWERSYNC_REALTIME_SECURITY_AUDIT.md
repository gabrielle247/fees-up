# PowerSync, Real-time & Security Architecture Audit
**Project:** Fees Up - School Financial Management System  
**Author:** Paul VII (Claire) - On-Ground Developer  
**Date:** January 4, 2026  
**Scope:** lib/core, lib/data, lib/pc, lib/shared  

---

## Executive Summary

This audit identifies **critical inconsistencies** in the PowerSync offline-first architecture, real-time data synchronization patterns, and security enforcement across the Fees Up application. The system demonstrates a **hybrid approach** that mixes:

1. **PowerSync local-first** (SQLite + sync) for core entities
2. **Supabase direct REST** for writes (bypassing PowerSync)
3. **Supabase Realtime streams** for online-only features
4. **Mixed security patterns** (RLS awareness but inconsistent enforcement)

---

## 1. PowerSync Implementation Analysis

### ✅ **CORRECT IMPLEMENTATIONS**

#### 1.1 Core Infrastructure
- **Location:** `lib/data/services/database_service.dart`
- **Status:** ✅ Properly configured
- **Details:**
  - PowerSync database initialized with schema
  - SupabaseConnector properly implements `PowerSyncBackendConnector`
  - Handles auth credentials and sync token
  - CRUD queue processing with error handling (42501 RLS, 23503 FK violations)
  - Factory reset capability for local database wipe

#### 1.2 Schema Definition
- **Location:** `lib/data/services/schema.dart`
- **Status:** ✅ Well-structured
- **Details:**
  - Comprehensive table definitions for synced entities
  - **Intentional exclusions:** `billing_extensions`, `suspension_periods`, `billing_audit` (security-critical, server-side only)
  - Proper column types and indexes

#### 1.3 Read Operations via PowerSync
- **Location:** Multiple repositories and providers
- **Status:** ✅ Consistent pattern
- **Examples:**
  - `DashboardRepository.watchStudentCount()` - uses `db.watch()`
  - `AnnouncementsRepository.watchAnnouncements()` - uses `db.watch()`
  - `DatabaseService.watchStudents()` - uses `db.watch()`

**Pattern:**
```dart
Stream<T> watchData(String schoolId) {
  return _db.db.watch(
    'SELECT * FROM table WHERE school_id = ? ORDER BY created_at DESC',
    parameters: [schoolId],
  );
}
```

---

### ❌ **CRITICAL ISSUES**

#### 1.4 Write Operations Bypass PowerSync
**Severity:** 🔴 **CRITICAL**  
**Impact:** Offline-first architecture is broken for writes

**Problem:**
All write operations directly use `supabase.from('table').insert()` instead of writing to PowerSync local database, which should sync to Supabase via the connector.

**Affected Services:**
1. **InvoiceService** (`lib/data/services/invoice_service.dart`)
   ```dart
   // ❌ WRONG: Direct Supabase write
   await supabase.from('bills').insert(billData);
   
   // ✅ SHOULD BE: PowerSync write (syncs automatically)
   await _db.insert('bills', billData);
   ```

2. **TransactionService** (`lib/data/services/transaction_service.dart`)
   ```dart
   // ❌ WRONG: Direct writes
   await supabase.from('payments').insert(paymentData);
   await supabase.from('payment_allocations').insert(allocationData);
   
   // ✅ SHOULD BE: PowerSync writes
   await _db.insert('payments', paymentData);
   await _db.insert('payment_allocations', allocationData);
   ```

3. **BillingRepository** (`lib/data/repositories/billing_repository.dart`)
   ```dart
   // ❌ WRONG: Direct Supabase batch operations
   await supabase.from('bills').insert(billMaps);
   await supabase.from('bill_line_items').insert(lineItemMaps);
   ```

4. **BroadcastService** (`lib/data/services/broadcast_service.dart`)
   ```dart
   // ❌ WRONG: Direct write
   await _supabase.from('broadcasts').insert({...});
   ```

**Consequences:**
- ❌ Offline writes **FAIL** - requires network connection
- ❌ PowerSync queue never used for writes
- ❌ No automatic retry/sync when back online
- ❌ Data loss risk if network fails mid-operation
- ❌ Inconsistent data state between local SQLite and Supabase

---

#### 1.5 Mixed Data Access Patterns
**Severity:** 🟡 **MODERATE**  
**Impact:** Confusing architecture, maintenance burden

**Current Pattern:**
- **Reads:** PowerSync local database (`db.watch()`, `db.getAll()`)
- **Writes:** Supabase REST API (`supabase.from().insert()`)

**Why This Is Problematic:**
- Defeats the purpose of offline-first architecture
- Creates two separate data flow paths
- Makes testing and debugging harder
- Violates the "single source of truth" principle

**Example from `AnnouncementsRepository`:**
```dart
// ✅ Read: Uses PowerSync
Stream<List<Announcement>> watchAnnouncements(String schoolId) {
  return _db.db.watch('SELECT * FROM notifications...', parameters: [schoolId]);
}

// ❌ Write: Uses DatabaseService which wraps PowerSync execute
// BUT other services use direct Supabase writes
await _db.insert('notifications', data); // This is correct
```

**Note:** `AnnouncementsRepository` is **one of the few** that does this correctly by using `DatabaseService.insert()` which properly uses PowerSync.

---

## 2. Real-time Synchronization Analysis

### ✅ **CORRECT IMPLEMENTATIONS**

#### 2.1 StreamProvider Pattern for PowerSync Data
- **Location:** `lib/data/providers/`
- **Status:** ✅ Well-implemented
- **Examples:**
  - `dashboardDataProvider` - uses `db.onChange()` listener
  - `notificationsProvider` - uses repository `watch()` method
  - `activeCampaignProvider` - streams from PowerSync

**Pattern:**
```dart
final dataProvider = StreamProvider<DataType>((ref) async* {
  await for (final _ in db.onChange(['table1', 'table2'])) {
    final results = await db.getAll('SELECT...');
    yield transformedData;
  }
});
```

#### 2.2 Online-Only Realtime Streams
- **Location:** `lib/data/services/broadcast_service.dart`
- **Status:** ✅ Properly documented and implemented
- **Details:**
  - Explicitly marked as "ONLINE STREAM"
  - Uses Supabase Realtime: `.stream(primaryKey: ['id'])`
  - Has offline fallback via encrypted local cache
  - Auto-expires messages older than 7 days

**Pattern:**
```dart
Stream<List<Broadcast>> streamBroadcasts(String schoolId) {
  return _supabase
      .from('broadcasts')
      .stream(primaryKey: ['id'])
      .order('created_at', ascending: false)
      .map((maps) => /* transform and cache */);
}
```

---

### ⚠️ **INCONSISTENCIES**

#### 2.3 FutureProvider vs StreamProvider Confusion
**Severity:** 🟡 **MODERATE**  
**Impact:** Stale data in some UI components

**Problem:**
Critical financial data uses `FutureProvider` (one-time fetch) instead of `StreamProvider` (real-time updates).

**Examples:**
```dart
// ❌ PROBLEM: One-time fetch, won't update if data changes
final schoolInvoicesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, schoolId) async {
    final invoiceService = ref.watch(invoiceServiceProvider);
    return invoiceService.getInvoicesForSchool(schoolId: schoolId);
  }
);

// ✅ SHOULD BE: Real-time stream
final schoolInvoicesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, schoolId) {
    return _db.db.watch(
      'SELECT * FROM bills WHERE school_id = ? ORDER BY created_at DESC',
      parameters: [schoolId]
    );
  }
);
```

**Affected Providers:**
1. `schoolInvoicesProvider` - invoices won't update live
2. `transactionSummaryProvider` - financial summaries stale
3. `schoolYearsProvider` - academic year changes not reactive
4. `outstandingBillsProvider` - payment updates not reflected
5. All providers in `financial_providers.dart` using `FutureProvider`

**UI Impact:**
- Users must manually refresh to see new invoices
- Payment status changes require page reload
- Dashboard KPIs don't update in real-time

---

#### 2.4 No Connection State Management
**Severity:** 🟡 **MODERATE**  
**Impact:** Poor UX when offline

**Problem:**
- PowerSync provides `currentStatus.connected` but it's rarely used
- UI doesn't inform users when they're offline
- No visual feedback for sync status

**Current Status:**
```dart
// Only used in DatabaseService
bool get isConnected => _db.currentStatus.connected;

// ❌ Not exposed to UI layer
// ❌ No sync progress indicators
// ❌ No "last synced" timestamp
```

**Needed:**
```dart
// TODO: Create connection status provider
final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  return _db.statusStream.map((status) => SyncStatus(
    isConnected: status.connected,
    lastSyncedAt: status.lastSynced,
    hasPendingChanges: status.hasPendingUploads,
  ));
});
```

---

## 3. Security Architecture Analysis

### ✅ **CORRECT IMPLEMENTATIONS**

#### 3.1 Billing Guard Pattern
- **Location:** `lib/core/security/billing_guard.dart`
- **Status:** ✅ Excellent security wrapper
- **Details:**
  - Enforces active status check before billing operations
  - Handles both global suspension (`is_suspended`) and feature suspension (`billing_suspended`)
  - Fail-safe approach (blocks if verification fails)
  - Used in `InvoiceService` for all critical operations

**Pattern:**
```dart
Future<T> run<T>({
  required String schoolId,
  required Future<T> Function() action,
}) async {
  await _enforceActiveStatus(schoolId);
  return await action();
}
```

#### 3.2 Sensitive Data Exclusion
- **Location:** Schema design
- **Status:** ✅ Properly architected
- **Details:**
  - `billing_extensions`, `suspension_periods`, `billing_audit` excluded from PowerSync
  - Accessed only via RPC functions (server-side)
  - Prevents client-side tampering with financial calculations

#### 3.3 Encryption for Local Cache
- **Location:** `lib/data/services/encryption_service.dart`
- **Status:** ✅ Basic but functional
- **Details:**
  - AES-256 encryption for broadcast cache
  - Key from environment variables
  - Decrypt failure returns safe default (`[]`)

---

### ⚠️ **SECURITY CONCERNS**

#### 3.4 RLS Awareness vs Enforcement Gap
**Severity:** 🔴 **CRITICAL**  
**Impact:** Potential security vulnerabilities

**Problem:**
Code **comments** mention RLS but actual **enforcement** is inconsistent.

**Examples:**

1. **AnnouncementsRepository** - RLS Aware ✅
   ```dart
   // ✅ GOOD: Manually injects user_id to satisfy RLS
   Future<void> createAnnouncement({
     required String userId, // Explicit parameter
     ...
   }) async {
     data['user_id'] = userId;  // Satisfies RLS constraint
     await _db.insert('notifications', data);
   }
   ```

2. **InvoiceService** - RLS Mentioned but Not Enforced ❌
   ```dart
   /// ✅ SECURE: Create adhoc invoice (manual billing)
   /// - No schema hacks (no 'term_id': 'adhoc-manual')
   
   // ❌ PROBLEM: No user_id parameter or injection
   Future<Map<String, dynamic>> createAdhocInvoice({
     required String schoolId,
     required String studentId,
     // Missing: required String userId ???
   }) async {
     final billData = {
       'id': invoiceId,
       'school_id': schoolId,
       // ❌ No 'user_id' field - will RLS block this?
     };
     await supabase.from('bills').insert(billData);
   }
   ```

3. **SupabaseConnector** - Handles RLS Violations Silently ⚠️
   ```dart
   catch (PostgrestException e) {
     // 42501 = RLS Violation
     if (e.code == '42501' || e.code == '23503') {
       debugPrint('❌ Sync Error ${e.code}... Skipping to unblock queue.');
       await transaction.complete(); // Silently drops the operation
     }
   }
   ```
   **Issue:** Failed RLS checks are logged but **not surfaced to user**. Data may appear saved locally but never sync to server.

---

#### 3.5 No Client-Side Row-Level Validation
**Severity:** 🟡 **MODERATE**  
**Impact:** Unexpected errors, poor UX

**Problem:**
- App relies on **server RLS** to reject unauthorized operations
- No **client-side checks** to prevent attempts
- Results in cryptic errors instead of helpful messages

**Example Scenario:**
1. User (role: `teacher`) tries to delete a student
2. Client sends DELETE request to Supabase
3. Server RLS blocks it (403 Forbidden)
4. User sees generic "Operation failed" error
5. **Should:** Client checks user role before showing delete button

**Needed:**
```dart
// TODO: Create permission service
class PermissionService {
  bool canDeleteStudent(String userRole) => userRole == 'admin';
  bool canEditBilling(String userRole) => ['admin', 'accountant'].contains(userRole);
  bool canViewReports(String userRole) => userRole != 'parent';
}
```

---

#### 3.6 Encryption Key Management
**Severity:** 🟡 **MODERATE**  
**Impact:** Hardcoded fallback key in production

**Problem:**
```dart
static const _envPassword = String.fromEnvironment(
  'UFT_PASSWORD', 
  defaultValue: 'FeesUpDefaultDevKey32CharsLong!!' // ❌ Hardcoded fallback
);
```

**Issues:**
- Default key is **hardcoded in source code**
- If environment variable missing, app uses predictable key
- Compromises encryption security

**Recommendation:**
```dart
// ✅ Fail-safe approach
static final _envPassword = const String.fromEnvironment('UFT_PASSWORD');

static String encrypt(String plainText) {
  if (_envPassword.isEmpty) {
    throw SecurityException('UFT_PASSWORD not configured. Cannot encrypt data.');
  }
  // ... proceed with encryption
}
```

---

## 4. Data Flow Architecture Map

```
┌─────────────────────────────────────────────────────────────┐
│                         UI LAYER (PC/Mobile)                │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   Screens    │  │   Widgets    │  │   Dialogs    │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
└─────────┼──────────────────┼──────────────────┼────────────┘
          │ ref.watch()      │                  │
          ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────┐
│                     PROVIDERS (Riverpod)                    │
│  ┌──────────────────┐  ┌──────────────────┐                │
│  │ StreamProvider   │  │ FutureProvider   │ ❌ ISSUE: Mix  │
│  │ (Real-time) ✅   │  │ (One-time) ⚠️    │    of types    │
│  └────────┬─────────┘  └────────┬─────────┘                │
└───────────┼──────────────────────┼──────────────────────────┘
            │                      │
            ▼                      ▼
┌─────────────────────────────────────────────────────────────┐
│               DATA LAYER (Services/Repositories)            │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  READS (Correct ✅)                                   │  │
│  │  - db.watch() → PowerSync local SQLite               │  │
│  │  - db.getAll() → PowerSync queries                   │  │
│  │  - Reactive streams → UI updates automatically       │  │
│  └──────────────────────────────────────────────────────┘  │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  WRITES (BROKEN ❌)                                   │  │
│  │  - supabase.from().insert() → Direct REST            │  │
│  │  - supabase.from().update() → Bypasses PowerSync     │  │
│  │  - Requires network → No offline support             │  │
│  │  - PowerSync queue unused → No auto-retry            │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────┬───────────────────────────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────────────────────────┐
│                    POWERSYNC DATABASE                       │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  Local SQLite (greyway_feesup.db)                    │  │
│  │  - Schema: appSchema (19 tables)                     │  │
│  │  - Connector: SupabaseConnector                      │  │
│  │  - CRUD Queue: Processes local→remote sync           │  │
│  └──────────────────┬───────────────────────────────────┘  │
└─────────────────────┼───────────────────────────────────────┘
                      │
                      ▼ SYNC (Bidirectional)
┌─────────────────────────────────────────────────────────────┐
│                    SUPABASE (Backend)                       │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  PostgreSQL Database                                  │  │
│  │  - Tables with RLS policies                          │  │
│  │  - Realtime subscriptions (.stream())                │  │
│  │  - RPC functions for sensitive operations            │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

**Current Flow Issues:**
- ✅ **Reads:** PowerSync → Local SQLite → Reactive UI
- ❌ **Writes:** Direct Supabase REST (bypasses PowerSync queue)
- ⚠️ **Sync:** Only server→client working, client→server broken for most tables

---

## 5. Detailed Findings by Module

### 5.1 Core (`lib/core/`)
| File | Status | Issues |
|------|--------|--------|
| `security/billing_guard.dart` | ✅ | None - well designed |
| `errors/billing_exceptions.dart` | ✅ | Custom exceptions properly defined |
| `widgets/premium_guard.dart` | ⚠️ | Not audited (out of scope) |

### 5.2 Data Services (`lib/data/services/`)
| Service | Read Pattern | Write Pattern | Security | Issues |
|---------|--------------|---------------|----------|--------|
| `database_service.dart` | ✅ PowerSync | ✅ PowerSync | ✅ | None |
| `supabase_connector.dart` | N/A | ✅ CRUD Queue | ⚠️ Silent RLS failures | Log but don't surface errors |
| `invoice_service.dart` | ⚠️ Direct Supabase | ❌ Direct Supabase | ✅ BillingGuard | Bypasses PowerSync writes |
| `transaction_service.dart` | ⚠️ Direct Supabase | ❌ Direct Supabase | ❌ No guard | Bypasses PowerSync writes, no security wrapper |
| `broadcast_service.dart` | ✅ Realtime Stream | ❌ Direct Supabase | ✅ Encrypted cache | Correct for online-only feature |
| `billing_suspension_service.dart` | ⚠️ Direct Supabase | ⚠️ RPC + Direct | ✅ | Intentionally server-side, but mixed patterns |
| `encryption_service.dart` | N/A | N/A | ⚠️ Hardcoded fallback | Security risk |

### 5.3 Data Repositories (`lib/data/repositories/`)
| Repository | Pattern | Issues |
|------------|---------|--------|
| `dashboard_repository.dart` | ✅ PowerSync watch | None |
| `announcements_repository.dart` | ✅ PowerSync + RLS aware | **Best Practice Example** |
| `billing_repository.dart` | ❌ Direct Supabase | Bypasses PowerSync |
| `broadcast_repository.dart` | ⚠️ Realtime Stream | Intentional for online-only |

### 5.4 Data Providers (`lib/data/providers/`)
| Provider | Type | Real-time? | Issues |
|----------|------|------------|--------|
| `dashboard_provider.dart` | StreamProvider | ✅ | None |
| `notifications_provider.dart` | StreamProvider | ✅ | None |
| `financial_providers.dart` | FutureProvider | ❌ | Should be StreamProvider |
| `settings_provider.dart` | FutureProvider | ❌ | Should be StreamProvider |
| `broadcast_provider.dart` | StreamProvider | ✅ | None |
| `expense_provider.dart` | StreamProvider | ✅ | None |

### 5.5 PC Widgets (`lib/pc/`)
**Status:** ✅ Mostly correct
- Properly use `ref.watch()` to consume providers
- UI is reactive to data changes
- **Issue:** Widgets using `FutureProvider` data won't see live updates

### 5.6 Shared (`lib/shared/`)
**Status:** Not audited (minimal security impact)

---

## 6. Risk Assessment Matrix

| Risk | Severity | Probability | Impact | Current Mitigation | Needed Action |
|------|----------|-------------|--------|-------------------|---------------|
| Offline writes fail | 🔴 Critical | High | Data loss, poor UX | None | Fix all write operations to use PowerSync |
| RLS violations not surfaced | 🔴 Critical | Medium | Silent data sync failures | Logged in connector | Surface errors to UI, add client validation |
| Stale financial data | 🟡 Moderate | High | Incorrect billing decisions | Manual refresh | Convert FutureProvider → StreamProvider |
| Hardcoded encryption key | 🟡 Moderate | Low | Data breach if code leaked | Environment variable option | Remove fallback, enforce env var |
| No connection state feedback | 🟡 Moderate | High | User confusion | None | Add sync status UI indicators |
| Mixed data access patterns | 🟡 Moderate | Low | Developer confusion | Documentation | Standardize on PowerSync-first |

---

## 7. Recommendations & Action Plan

### PHASE 1: Critical Fixes (Week 1)
**Priority:** 🔴 **IMMEDIATE**

#### 7.1 Fix Write Operations to Use PowerSync
```dart
// TODO: Update all services to use DatabaseService instead of direct Supabase

// BEFORE (❌ WRONG):
await supabase.from('bills').insert(billData);

// AFTER (✅ CORRECT):
await _db.insert('bills', billData);
```

**Files to Update:**
1. `lib/data/services/invoice_service.dart`
2. `lib/data/services/transaction_service.dart`
3. `lib/data/repositories/billing_repository.dart`
4. `lib/data/repositories/broadcast_repository.dart` (if broadcasts should be offline-capable)

**Testing:**
- Verify offline bill creation works
- Confirm sync queue processes when back online
- Check RLS policies still enforced server-side

#### 7.2 Add RLS Enforcement Checks
```dart
// TODO: Add user_id to all create operations

class InvoiceService {
  Future<Map<String, dynamic>> createAdhocInvoice({
    required String schoolId,
    required String studentId,
    required String userId, // ✅ ADD THIS
    // ... other params
  }) async {
    final billData = {
      'id': invoiceId,
      'school_id': schoolId,
      'student_id': studentId,
      'user_id': userId, // ✅ ADD THIS for RLS
      // ... other fields
    };
    
    await _db.insert('bills', billData); // Use PowerSync
  }
}
```

#### 7.3 Surface Sync Errors to UI
```dart
// TODO: Create sync error provider

final syncErrorsProvider = StreamProvider<List<SyncError>>((ref) {
  return _db.watchSyncErrors(); // Hypothetical PowerSync API
});

// TODO: Show errors in UI
class SyncErrorBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final errors = ref.watch(syncErrorsProvider);
    if (errors.value?.isEmpty ?? true) return SizedBox.shrink();
    
    return ErrorBanner(
      message: 'Some data failed to sync. Check your permissions.',
      errors: errors.value!,
    );
  }
}
```

---

### PHASE 2: Real-time Improvements (Week 2)
**Priority:** 🟡 **HIGH**

#### 7.4 Convert Financial Providers to Streams
```dart
// TODO: Replace FutureProvider with StreamProvider

// BEFORE (❌ ONE-TIME FETCH):
final schoolInvoicesProvider = FutureProvider.family<List<Map<String, dynamic>>, String>(
  (ref, schoolId) async {
    final service = ref.watch(invoiceServiceProvider);
    return service.getInvoicesForSchool(schoolId: schoolId);
  }
);

// AFTER (✅ REAL-TIME STREAM):
final schoolInvoicesProvider = StreamProvider.family<List<Map<String, dynamic>>, String>(
  (ref, schoolId) {
    return DatabaseService().db.watch(
      'SELECT * FROM bills WHERE school_id = ? ORDER BY created_at DESC',
      parameters: [schoolId]
    );
  }
);
```

**Files to Update:**
1. `lib/data/providers/financial_providers.dart` (entire file)
2. `lib/data/providers/settings_provider.dart` (schoolYearsProvider)

#### 7.5 Add Sync Status UI
```dart
// TODO: Create sync status indicator

final syncStatusProvider = StreamProvider<SyncStatus>((ref) {
  return DatabaseService().db.statusStream.map((status) => SyncStatus(
    isConnected: status.connected,
    lastSyncedAt: status.lastSynced,
    uploadQueueSize: status.uploadQueueSize,
  ));
});

// TODO: Add to AppBar or status bar
class SyncStatusIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(syncStatusProvider).value;
    if (status == null) return SizedBox.shrink();
    
    return Row(children: [
      Icon(
        status.isConnected ? Icons.cloud_done : Icons.cloud_off,
        color: status.isConnected ? Colors.green : Colors.orange,
      ),
      if (status.uploadQueueSize > 0)
        Badge(label: Text('${status.uploadQueueSize}')),
    ]);
  }
}
```

---

### PHASE 3: Security Hardening (Week 3)
**Priority:** 🟡 **MODERATE**

#### 7.6 Client-Side Permission Checks
```dart
// TODO: Create PermissionService

class PermissionService {
  final String userRole;
  PermissionService({required this.userRole});
  
  bool canCreateInvoice() => ['admin', 'accountant'].contains(userRole);
  bool canDeleteStudent() => userRole == 'admin';
  bool canViewFinancialReports() => userRole != 'parent';
  bool canSuspendBilling() => userRole == 'admin';
  bool canEditSchoolSettings() => userRole == 'admin';
}

// TODO: Use in UI
ElevatedButton(
  onPressed: permissions.canCreateInvoice() 
    ? () => _showInvoiceDialog()
    : null, // Disabled if no permission
  child: Text('Create Invoice'),
)
```

#### 7.7 Remove Hardcoded Encryption Key
```dart
// TODO: Enforce environment variable

class EncryptionService {
  static final _envPassword = const String.fromEnvironment('UFT_PASSWORD');

  static void _validateKey() {
    if (_envPassword.isEmpty) {
      throw SecurityException(
        'UFT_PASSWORD environment variable not set. '
        'Set it via --dart-define=UFT_PASSWORD=your_key_here'
      );
    }
  }

  static String encrypt(String plainText) {
    _validateKey();
    // ... proceed with encryption
  }
}
```

#### 7.8 Add Audit Logging for Security Events
```dart
// TODO: Create security audit logger

class SecurityAuditService {
  Future<void> logSecurityEvent({
    required String userId,
    required String action,
    required String resource,
    required bool allowed,
    String? reason,
  }) async {
    await _db.insert('security_audit', {
      'id': Uuid().v4(),
      'user_id': userId,
      'action': action,
      'resource': resource,
      'allowed': allowed,
      'reason': reason,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
}

// Usage in BillingGuard
if (isGlobalSuspended) {
  await _auditService.logSecurityEvent(
    userId: currentUserId,
    action: 'create_invoice',
    resource: schoolId,
    allowed: false,
    reason: 'School globally suspended',
  );
  throw BillingSuspendedException('...');
}
```

---

### PHASE 4: Architecture Standardization (Week 4)
**Priority:** 🟢 **LOW**

#### 7.9 Document Data Access Patterns
```dart
// TODO: Create ARCHITECTURE.md

# Data Access Patterns

## Rule 1: All Reads via PowerSync
❌ NEVER: supabase.from('table').select()
✅ ALWAYS: _db.db.watch('SELECT * FROM table')

## Rule 2: All Writes via PowerSync
❌ NEVER: supabase.from('table').insert()
✅ ALWAYS: _db.insert('table', data)

## Rule 3: Use StreamProvider for Real-time Data
❌ NEVER: FutureProvider for frequently changing data
✅ ALWAYS: StreamProvider.family for reactive updates

## Exception: Online-Only Features
✅ ALLOWED: supabase.from().stream() for broadcasts
✅ ALLOWED: supabase.rpc() for server-side functions
✅ ALLOWED: Direct Supabase for non-synced tables
```

#### 7.10 Create Developer Guidelines
```dart
// TODO: Add to CONTRIBUTING.md

## Adding a New Feature Checklist

1. [ ] Define schema in `schema.dart` (if needs offline support)
2. [ ] Create repository with PowerSync watch methods
3. [ ] Create StreamProvider (not FutureProvider)
4. [ ] Add user_id to all write operations (RLS compliance)
5. [ ] Use DatabaseService.insert() for writes
6. [ ] Add permission checks in service layer
7. [ ] Test offline functionality
8. [ ] Add sync status indicators to UI
9. [ ] Document security considerations
```

---

## 8. Testing Strategy

### 8.1 Offline Mode Testing
```bash
# TODO: Create offline test suite

# Test 1: Create invoice while offline
1. Disable network
2. Create new invoice
3. Verify saved to local SQLite
4. Enable network
5. Verify synced to Supabase

# Test 2: Payment allocation while offline
1. Disable network
2. Record payment with allocations
3. Check PowerSync queue size > 0
4. Enable network
5. Verify all allocations synced
```

### 8.2 RLS Policy Testing
```bash
# TODO: Create RLS test suite

# Test 1: Cross-school access prevention
1. Login as School A admin
2. Attempt to read School B students
3. Verify empty result (not error)

# Test 2: Role-based write permissions
1. Login as teacher
2. Attempt to delete student
3. Verify blocked with helpful message (not generic error)
```

### 8.3 Sync Queue Testing
```bash
# TODO: Create sync test suite

# Test 1: Queue processing after network restore
1. Create 10 students offline
2. Enable network
3. Monitor queue drain (should complete in <5s)

# Test 2: Conflict resolution
1. Modify same record offline on two devices
2. Sync both to server
3. Verify last-write-wins or conflict UI shown
```

---

## 9. Migration Path

### 9.1 Backwards Compatibility
**Challenge:** Existing data created via direct Supabase writes

**Solution:**
1. New code uses PowerSync writes
2. Old data continues to sync via PowerSync read
3. No data migration needed
4. Gradual rollout over 2 weeks

### 9.2 Rollout Plan
**Week 1:** Fix critical services (invoices, transactions)  
**Week 2:** Update providers to streams, add sync UI  
**Week 3:** Security hardening, permission checks  
**Week 4:** Documentation, testing, monitoring  

### 9.3 Rollback Plan
If critical issues arise:
1. Revert to direct Supabase writes (old pattern)
2. Keep PowerSync for reads only
3. Disable offline mode in UI
4. Fix issues, re-deploy

---

## 10. Performance Considerations

### 10.1 PowerSync Query Optimization
```dart
// TODO: Add indexes to frequently queried columns

Schema([
  Table('bills', [
    Column.text('school_id'),
    Column.text('student_id'),
    // ...
  ], indexes: [
    Index('idx_bills_school_student', ['school_id', 'student_id']),
    Index('idx_bills_due_date', ['due_date']),
  ]),
]);
```

### 10.2 Stream Throttling
```dart
// TODO: Add throttling to high-frequency streams

final dashboardDataProvider = StreamProvider<DashboardData>((ref) async* {
  await for (final _ in db.onChange(['students', 'bills']).throttleTime(Duration(seconds: 1))) {
    yield computedDashboardData;
  }
});
```

### 10.3 Pagination for Large Datasets
```dart
// TODO: Add pagination for student lists

final studentsProvider = StreamProvider.family<List<Student>, int>(
  (ref, page) {
    final offset = page * 50;
    return _db.db.watch(
      'SELECT * FROM students WHERE school_id = ? LIMIT 50 OFFSET ?',
      parameters: [schoolId, offset]
    );
  }
);
```

---

## Conclusion

The Fees Up application has a **solid foundation** with PowerSync, but critical gaps exist in the write operation flow. The current architecture:

**✅ Strengths:**
- Proper PowerSync setup and configuration
- Excellent schema design with security-first approach
- Good reactive UI patterns with Riverpod
- BillingGuard security wrapper is exemplary

**❌ Critical Weaknesses:**
- **All writes bypass PowerSync** → Offline mode broken
- **FutureProvider overuse** → Stale data in financial dashboards
- **RLS errors silently dropped** → User confusion, data loss risk
- **No sync status UI** → Poor offline UX

**Priority Actions:**
1. 🔴 Fix write operations to use PowerSync (IMMEDIATE)
2. 🔴 Add RLS enforcement to all create operations (IMMEDIATE)
3. 🟡 Convert financial providers to StreamProvider (HIGH)
4. 🟡 Add sync status UI indicators (HIGH)
5. 🟢 Standardize architecture documentation (LOW)

**Estimated Effort:** 3-4 weeks for full implementation  
**Risk if Not Fixed:** Data loss, broken offline mode, security vulnerabilities  
**Benefit if Fixed:** True offline-first app, real-time updates, better security

---

