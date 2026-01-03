# Secure Billing Engine Architecture
**Classification:** 🔒 HIGH SECURITY  
**Date:** January 3, 2026  
**Project:** Fees Up (Batch Tech)  
**Author:** Nyasha Gabriel  
**Status:** APPROVED & ENFORCED

---

## Executive Summary

To maintain billing integrity and prevent financial anomalies, the **billing_suspension_periods**, **billing_audit_log**, and **billing_extensions** tables are **intentionally excluded from PowerSync schema**. These tables contain critical financial state that must:

1. **Single-Source-of-Truth:** Server-side only, never cached offline
2. **Immutable History:** Append-only audit trail for compliance
3. **Atomic Operations:** All-or-nothing suspension/resume transactions
4. **Engine-Gated:** Only the designated billing engine can modify these tables

---

## 🔒 Architecture Overview

### Excluded Tables (Server-Side Only)

| Table | Purpose | Access |
|-------|---------|--------|
| `billing_suspension_periods` | Tracks suspension/resume cycles | Supabase Realtime + RPC only |
| `billing_audit_log` | Immutable action log | Read-only RPC + Realtime |
| `billing_extensions` | Date extensions for bills | Engine RPC only |

**Verification:**
- ✅ These tables are **NOT** in `lib/data/services/schema.dart`
- ✅ PowerSync will not attempt to sync them to client
- ✅ Client code accesses via Supabase Realtime (online-only)
- ✅ No offline caching of suspension state permitted

### Access Pattern

```
┌─────────────────────────────┐
│   Mobile Device / Desktop   │
│   (PowerSync Offline-First) │
└──────────────┬──────────────┘
               │
        ┌──────▼──────┐
        │ Online Check │
        └──────┬──────┘
               │
      ┌────────┴─────────┐
      │                  │
   ONLINE             OFFLINE
      │                  │
      ▼                  ▼
┌──────────────┐  ┌────────────────┐
│ Realtime RPC │  │ Cached Billing │
│   Functions  │  │  Status (stale)│
└──────────────┘  └────────────────┘
      │
      ▼
┌──────────────────────────────┐
│   Supabase Database          │
│ (Single-Source-of-Truth)     │
└──────────────────────────────┘
```

---

## 🛡️ Implementation Requirements

### 1. PowerSync Schema Configuration
```dart
// ✅ CORRECT: These tables are NOT in schema.dart
// Location: lib/data/services/schema.dart

const Schema appSchema = Schema([
  // ... other tables ...
  
  Table('bills', [ /* ... */ ]),
  Table('payments', [ /* ... */ ]),
  // ... other sync tables ...
  
  // ❌ INTENTIONALLY MISSING:
  // - billing_suspension_periods
  // - billing_audit_log
  // - billing_extensions
  //
  // See: SECURE_BILLING_ENGINE_ARCHITECTURE.md
]);
```

### 2. Server-Side Access Only

```dart
// ❌ WRONG: Never cache locally
final cached = await db.query('billing_suspension_periods');

// ✅ CORRECT: Online-only subscription
final subscription = supabase
  .from('billing_suspension_periods')
  .stream(primaryKey: ['id'])
  .eq('school_id', schoolId)
  .listen((event) {
    // Update UI with real-time data
  });
```

### 3. RPC-Gated Operations

```dart
// All billing suspension operations go through Supabase RPC
class BillingSuppressionService {
  final Supabase supabase;
  
  Future<void> suspendBilling({
    required String schoolId,
    required String reason,
    required DateTime startDate,
    DateTime? endDate,
  }) async {
    // ✅ Uses RPC - not direct table insert
    final result = await supabase.rpc('suspend_billing', {
      'p_school_id': schoolId,
      'p_reason': reason,
      'p_start_date': startDate.toIso8601String(),
      'p_end_date': endDate?.toIso8601String(),
    });
    
    if (result == null) {
      throw Exception('Failed to suspend billing');
    }
  }
}
```

### 4. Immutable Audit Log

All suspension activities automatically logged via database trigger:

```sql
-- Server-side trigger (Supabase)
CREATE TRIGGER audit_billing_suspension_insert
AFTER INSERT ON billing_suspension_periods
FOR EACH ROW
EXECUTE FUNCTION log_billing_action('suspend');

CREATE TRIGGER audit_billing_suspension_resume
AFTER UPDATE ON billing_suspension_periods
  WHEN NEW.status = 'completed' AND OLD.status = 'active'
FOR EACH ROW
EXECUTE FUNCTION log_billing_action('resume');
```

---

## 🔌 Riverpod Provider Architecture

### Online-Only State Management

```dart
// Location: lib/data/providers/billing_suspension_provider.dart

// ✅ CORRECT: Real-time subscription (no local cache)
final billingSuppressionStatusProvider = FutureProvider.family<
  SuspensionStatus,
  String
>((ref, schoolId) async {
  final supabase = ref.watch(supabaseProvider);
  
  // Query server-side status
  return await supabase.rpc('get_suspension_status', {
    'p_school_id': schoolId,
  });
});

// ✅ CORRECT: Realtime updates
final suspensionStreamProvider = StreamProvider.family<
  List<SuspensionPeriod>,
  String
>((ref, schoolId) {
  final supabase = ref.watch(supabaseProvider);
  
  // Realtime stream - refreshes when server changes data
  return supabase
    .from('billing_suspension_periods')
    .stream(primaryKey: ['id'])
    .eq('school_id', schoolId)
    .map((rows) => rows
      .map(SuspensionPeriod.fromMap)
      .toList()
    );
});

// ✅ CORRECT: StateNotifier for RPC calls only
class SuspensionStateNotifier extends StateNotifier<SuspensionUIState> {
  final Supabase supabase;
  final String schoolId;
  final String userId;
  
  SuspensionStateNotifier({
    required this.supabase,
    required this.schoolId,
    required this.userId,
  }) : super(const SuspensionUIState());
  
  Future<void> suspendBilling({
    required String reason,
    required DateTime startDate,
  }) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      // ✅ All modifications via RPC (server processes)
      await supabase.rpc('suspend_billing', {
        'p_school_id': schoolId,
        'p_reason': reason,
        'p_start_date': startDate.toIso8601String(),
        'p_user_id': userId,
      });
      
      // ✅ UI automatically updates via Realtime stream
      state = state.copyWith(isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }
}
```

---

## 🚨 Security Enforcement Checklist

### Before Integration
- [ ] Verify `billing_suspension_periods` NOT in `schema.dart`
- [ ] Verify `billing_audit_log` NOT in `schema.dart`
- [ ] Verify `billing_extensions` NOT in `schema.dart`
- [ ] Confirm no `.insert()`, `.update()`, `.delete()` calls on these tables from client
- [ ] Validate all suspension operations use RPC functions
- [ ] Test Realtime subscriptions work online-only

### Database Configuration
- [ ] RLS policies prevent direct client inserts
- [ ] Append-only enforcement on audit_log (no updates/deletes)
- [ ] Server functions created for all suspension operations
- [ ] Triggers configured for audit logging
- [ ] Indexes optimized for real-time queries

### Code Review Gates
- [ ] Billing suspension service uses only RPC calls
- [ ] No local caching of suspension state in SharedPreferences
- [ ] No SQLite queries for these tables
- [ ] All UI updates driven by Realtime subscriptions
- [ ] Error handling includes offline/online state transitions

---

## 📋 Provider Implementation Pattern

### Widget Usage (Correct Pattern)

```dart
// ✅ CORRECT: Watch realtime stream
class BillingDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Real-time suspension status
    final suspensionStream = ref.watch(
      suspensionStreamProvider(schoolId),
    );
    
    return suspensionStream.when(
      data: (suspensions) {
        if (suspensions.isEmpty) {
          return Text('Billing active');
        }
        
        final active = suspensions
          .where((s) => s.status == SuspensionStatus.active)
          .first;
          
        return BillingStatusBanner(
          suspendedSince: active.startDate,
          reason: active.reason,
          onResume: () => ref
            .read(suspensionStateProvider(schoolId).notifier)
            .resumeBilling(),
        );
      },
      loading: () => LoadingIndicator(),
      error: (err, stack) {
        // Show stale cached data or "offline" message
        return OfflineMessage();
      },
    );
  }
}
```

---

## 🚀 Deployment Verification

### Post-Deployment Tests

```bash
# 1. Verify tables not in PowerSync schema
grep -n "billing_suspension_periods\|billing_audit_log\|billing_extensions" \
  lib/data/services/schema.dart
# Expected: No matches

# 2. Verify no direct table queries from app
grep -rn "\.from\('billing_suspension" lib/
# Expected: Only in admin portal components (read-only)

# 3. Verify RPC-only modifications
grep -rn "billing_suspension_periods.*insert\|update\|delete" lib/
# Expected: No matches in app code, only in Supabase functions
```

---

## ⚠️ Critical Warnings

> **WARNING #1:** Any attempt to add these tables to PowerSync schema creates a critical security vulnerability. Client devices could modify suspension state offline, causing billing system corruption.

> **WARNING #2:** Local caching of suspension state in SharedPreferences or Hive invalidates the single-source-of-truth. Always query server or use Realtime subscriptions.

> **WARNING #3:** Direct Supabase table queries (`.from()`) on these tables from client-side code bypasses RPC validation. Use only RPC functions for modifications.

> **WARNING #4:** Removing RLS policies on these tables exposes the billing system to unauthorized modifications. RLS enforcement is mandatory.

---

## 📚 Related Documentation

- **BILLING_SUSPENSION_IMPLEMENTATION_GUIDE.md** - How to build UI components
- **BILLING_SUSPENSION_DEPLOYMENT_CHECKLIST.md** - Deployment procedures
- **supabase_migrations/billing_suspension_schema.sql** - Server-side schema

---

## ✅ Sign-Off

**Architecture Owner:** Nyasha Gabriel  
**Date Approved:** January 3, 2026  
**Status:** ACTIVE & ENFORCED

No modifications to this security architecture permitted without explicit approval from the architecture owner.

---

*This document contains proprietary security architecture. Distribution prohibited without authorization.*
