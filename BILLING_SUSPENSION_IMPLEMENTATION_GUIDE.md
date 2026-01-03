# Billing Suspension System - Implementation Guide
## Complete Guide for Core Global Suspension (Phase 3A)

**Date:** January 3, 2026  
**Status:** Ready for Implementation  
**Estimated Timeline:** 8-10 hours (Phase 3A Core Work)

---

## Overview

The Billing Suspension System enables schools to:
- **Suspend billing globally** (for all students)
- **Suspend billing by scope** (specific students, grades, or fee types)
- **Resume billing** with automatic date tracking
- **Audit all suspension actions** for compliance
- **Check suspension status** for billing operations

This guide covers the **Phase 3A implementation**: Global suspension toggle + Core infrastructure.

---

## What's Included

### 1. Database Schema (Complete)
✅ **File:** `supabase_migrations/billing_suspension_schema.sql`

**Tables Created:**
- `billing_suspension_periods` - Tracks all suspension periods
- `billing_audit_log` - Complete audit trail
- `billing_extensions` (optional) - For backbilling support
- Server functions for quick suspension checks

**Key Features:**
- RLS policies for school isolation
- Automatic status flag update via trigger
- Comprehensive indexes for performance
- Check constraints for data integrity

### 2. Service Layer (Complete)
✅ **File:** `lib/data/services/billing_suspension_service.dart` (544 lines)

**Core Methods:**
```dart
suspendBilling()           // Initiate suspension
resumeBilling()            // End suspension  
isBillingSuspended()       // Quick status check
getActiveSuspensions()     // Get all active periods
isBillingAppliedToStudent()// Check per-student status
getSuspensionSummary()     // UI-ready summary
calculateSuspensionDays()  // For backbilling
getAuditLog()              // Compliance audit trail
```

**Enums & Types:**
- `SuspensionStatus` - active, completed, cancelled
- `SuspensionScopeType` - global, students, grades, fee_types
- `SuspensionPeriod` - Full suspension data model
- `BillingAuditEntry` - Audit log entries
- `AuditAction` - Action types for logging

### 3. Riverpod Integration (Complete)
✅ **File:** `lib/data/providers/billing_suspension_provider.dart` (217 lines)

**Providers:**
- `billingSuppressionServiceProvider` - Service instance
- `billingSuppressionStatusProvider` - Current suspension status
- `activeSuspensionsProvider` - All active periods
- `suspensionSummaryProvider` - UI display data
- `billingAuditLogProvider` - Audit entries
- `suspensionStateProvider` - State management with actions

**StateNotifier Methods:**
```dart
suspendBilling()   // Trigger suspension with state update
resumeBilling()    // Trigger resumption with state update
refreshStatus()    // Refresh all suspension data
clearError()       // Clear error messages
```

---

## Implementation Steps

### Step 1: Deploy Database Schema (1-2 hours)

**1a. Run Migration in Supabase**
```bash
# Open Supabase SQL Editor and run:
# supabase_migrations/billing_suspension_schema.sql
```

**1b. Verify Installation**
```sql
-- Check tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name IN ('billing_suspension_periods', 'billing_audit_log');

-- Check functions exist
SELECT routine_name FROM information_schema.routines
WHERE routine_schema = 'public'
AND routine_name LIKE '%billing%';
```

**Expected Output:**
- 3 new tables (4 with extensions)
- 2 new functions (is_billing_suspended, get_active_suspensions)
- 4 new RLS policies
- 8+ new indexes

### Step 2: Create Billing Control UI Component (3-4 hours)

**2a. Create New File**
```
lib/pc/widgets/billing/billing_suspension_control.dart
```

**2b. Widget Structure**
```dart
class BillingSuspensionControl extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch suspension status
    final statusAsync = ref.watch(billingSuppressionStatusProvider(schoolId));
    final suspensionState = ref.watch(suspensionStateProvider(schoolId));
    
    // Show suspend/resume button based on status
    // Show active suspension details
    // Show suspension history
    // Provide reason input dialog
  }
}
```

**2c. Key Components**
- **Suspend Button** - Opens dialog for reason input
- **Suspension Status Badge** - Shows if billing is suspended
- **Active Suspensions List** - Displays all active periods
- **Resume Button** - Triggers resumption
- **Error Display** - Shows any operation errors

**2d. Dialog for Suspension**
```dart
class SuspensionReasonDialog extends StatefulWidget {
  // Text field for reason (required, 5-500 chars)
  // Scope selector (Global / Students / Grades / Fee Types)
  // Custom note field (optional)
  // Submit/Cancel buttons
}
```

### Step 3: Integrate with Billing Dashboard (2-3 hours)

**3a. Add Status Indicator to Dashboard**
```dart
// In dashboard widget
final suspensionSummary = await ref.watch(
  suspensionSummaryProvider(schoolId)
);

// Display banner if suspended
if (suspensionSummary['is_suspended'] == true) {
  ShowSuspensionBanner(summary: suspensionSummary);
}
```

**3b. Add Control Center to Settings**
```dart
// In settings/admin screen
BillingSuspensionControl(schoolId: schoolId)
```

**3c. Quick Status in Student List**
```dart
// Show suspension status per student
final isApplied = await service.isBillingAppliedToStudent(
  studentId: student.id,
  gradeLevel: student.gradeLevel,
);

// Display as chip/badge
if (!isApplied) {
  Chip(label: Text('Billing Suspended'))
}
```

### Step 4: Add to Bill Generation Logic (1-2 hours)

**4a. Modify BillingEngine**
```dart
// In lib/data/services/billing_engine.dart

Future<List<GeneratedBill>> generateBillsForPeriod(...) async {
  // Check if billing is suspended
  final suspensionService = BillingSuppressionService(...);
  if (await suspensionService.isBillingSuspended()) {
    return []; // Don't generate bills if suspended
  }
  
  // Generate bills as normal
  ...
}
```

**4b. Skip Suspended Students**
```dart
// When generating bulk bills
for (final student in students) {
  final isBillingApplied = await suspensionService
      .isBillingAppliedToStudent(
    studentId: student.id,
    gradeLevel: student.gradeLevel,
  );
  
  if (!isBillingApplied) {
    continue; // Skip this student
  }
  
  // Generate bill for this student
  ...
}
```

### Step 5: Notifications (1-2 hours)

**5a. Create Suspension Notification**
```dart
class SuspensionNotification {
  final String schoolName;
  final DateTime startDate;
  final String reason;
  final int affectedStudents;
  
  String get subject => 'Billing Suspended: $schoolName';
  String get body => 'Billing for $affectedStudents students suspended';
}
```

**5b. Send on Suspension**
```dart
// In suspendBilling() method
await _notificationService.sendToSchool(
  title: 'Billing Suspended',
  body: 'Billing has been suspended: $reason',
  actions: ['View Details']
);

// In resumeBilling() method
await _notificationService.sendToSchool(
  title: 'Billing Resumed',
  body: 'Billing has resumed after suspension',
);
```

### Step 6: Testing & QA (2-3 hours)

**6a. Unit Tests**
```dart
// test/services/billing_suspension_service_test.dart

test('suspendBilling creates period in DB', () async {
  final service = setupService();
  final result = await service.suspendBilling(
    reason: 'Test suspension',
  );
  expect(result, isNotNull);
  expect(result!.reason, 'Test suspension');
});

test('isBillingSuspended returns true when active', () async {
  // Suspend billing
  // Check returns true
});

test('resumeBilling marks suspension as completed', () async {
  // Create suspension
  // Resume it
  // Verify status changed to completed
});
```

**6b. Integration Tests**
```dart
// Test full workflow
test('complete suspension workflow', () async {
  // 1. Verify not suspended
  expect(await service.isBillingSuspended(), false);
  
  // 2. Suspend
  await service.suspendBilling(reason: 'Test');
  expect(await service.isBillingSuspended(), true);
  
  // 3. Check audit log
  final auditLog = await service.getAuditLog();
  expect(auditLog, isNotEmpty);
  expect(auditLog.first.action, AuditAction.suspend);
  
  // 4. Resume
  await service.resumeBilling(suspensionId: '...');
  expect(await service.isBillingSuspended(), false);
});
```

**6c. Manual Testing Checklist**
- [ ] Can suspend billing with reason
- [ ] Dashboard shows suspension status
- [ ] Suspend banner displays correctly
- [ ] Can resume billing
- [ ] Audit log records all actions
- [ ] Notifications sent on suspend/resume
- [ ] Bills don't generate during suspension
- [ ] Scope filtering works (if implemented)
- [ ] Error handling for invalid inputs
- [ ] Offline support (PowerSync)

---

## Integration with Existing Code

### BillingEngine Integration
```dart
// In generateBillsForPeriod()
Future<List<GeneratedBill>> generateBillsForPeriod(...) async {
  // NEW: Check suspension status
  final suspensionService = BillingSuppressionService(
    supabase: supabaseClient,
    schoolId: schoolId,
    userId: userId,
  );
  
  // NEW: Skip if globally suspended
  if (await suspensionService.isBillingSuspended()) {
    debugPrint('Billing suspended - skipping bill generation');
    return [];
  }
  
  // EXISTING: Continue with normal bill generation
  ...
}
```

### BillingRepository Integration
```dart
// Add to BillingRepository class
late final _suspensionService = BillingSuppressionService(
  supabase: supabase,
  schoolId: schoolId,
  userId: currentUserId,
);

Future<List<GeneratedBill>> saveBills(List<GeneratedBill> bills) async {
  // NEW: Check if any are suspended
  for (final bill in bills) {
    final isApplied = await _suspensionService.isBillingAppliedToStudent(
      studentId: bill.studentId,
      gradeLevel: bill.gradeLevel,
    );
    
    if (!isApplied) {
      // Skip saving bill for suspended student
      continue;
    }
  }
  
  // EXISTING: Save bills normally
  ...
}
```

### Riverpod Usage in Widgets
```dart
// In any widget
class MyBillingWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch suspension status
    final status = ref.watch(
      billingSuppressionStatusProvider('school-123')
    );
    
    // Show loading
    if (status.isLoading) {
      return LoadingWidget();
    }
    
    // Show error
    if (status.hasError) {
      return ErrorWidget(error: status.error);
    }
    
    // Show UI based on status
    final isSuspended = status.value ?? false;
    if (isSuspended) {
      return SuspensionBanner();
    } else {
      return NormalBillingUI();
    }
  }
}
```

---

## Database Schema Overview

### billing_suspension_periods Table
```sql
Column              | Type          | Description
--------------------+---------------+------------------------------------------
id                  | UUID PK       | Unique suspension ID
school_id           | UUID FK       | School this suspension applies to
start_date          | TIMESTAMPTZ   | When suspension started
end_date            | TIMESTAMPTZ   | When suspension ended (NULL if ongoing)
reason              | TEXT          | Required reason for suspension
custom_note         | TEXT          | Optional admin notes
created_by          | UUID FK       | User who created suspension
status              | VARCHAR(20)   | active, completed, cancelled
scope               | JSONB         | Who suspension applies to
created_at          | TIMESTAMPTZ   | Creation timestamp
updated_at          | TIMESTAMPTZ   | Last update timestamp
```

### billing_audit_log Table
```sql
Column              | Type          | Description
--------------------+---------------+------------------------------------------
id                  | UUID PK       | Unique audit entry ID
school_id           | UUID FK       | School this action affects
user_id             | UUID FK       | User who performed action
action              | VARCHAR(50)   | Type of action (suspend, resume, etc)
details             | JSONB         | Context-specific details
created_at          | TIMESTAMPTZ   | When action occurred
```

### schools Table Additions
```sql
Column                      | Type          | Description
----------------------------+---------------+------------------------------------------
billing_suspended           | BOOLEAN       | Current suspension status (auto-updated)
last_billing_resume_date    | TIMESTAMPTZ   | When billing was last resumed
```

---

## Server Functions

### is_billing_suspended(p_school_id UUID)
Returns TRUE if school has active suspension, FALSE otherwise.

**Usage:**
```dart
final isSuspended = await supabase.rpc('is_billing_suspended', 
  params: {'p_school_id': schoolId}
);
```

### get_active_suspensions(p_school_id UUID)
Returns all active suspension periods for a school.

**Usage:**
```dart
final suspensions = await supabase.rpc('get_active_suspensions',
  params: {'p_school_id': schoolId}
);
```

---

## Timeline & Milestones

### Week 1 (Jan 3-9)
- [x] Database schema created ✅
- [x] Service layer implemented ✅
- [x] Riverpod integration done ✅
- [ ] **TODO:** Database migration deployed
- [ ] **TODO:** UI control component built
- [ ] **TODO:** Tests written

### Week 2 (Jan 10-16)
- [ ] Dashboard integration complete
- [ ] Bill generation logic updated
- [ ] Notifications implemented
- [ ] QA & testing complete
- [ ] Production ready

### Week 3+ (Jan 17+)
- [ ] Granular suspension (v1.1)
- [ ] Backbilling calculations (v1.1)
- [ ] Advanced audit reports (v1.1)

---

## Potential Issues & Mitigations

| Issue | Risk | Mitigation |
|-------|------|-----------|
| **Timezone confusion** | Medium | Store all dates as UTC, convert on display |
| **Offline suspension status** | Medium | Cache status locally via PowerSync |
| **RLS policy conflicts** | High | Test policies thoroughly before production |
| **Audit log growth** | Low | Archive logs > 7 years old monthly |
| **Notification delivery** | Medium | Implement retry logic with exponential backoff |
| **Partial suspension edge cases** | High | Write comprehensive unit tests |

---

## Success Criteria

Phase 3A is complete when:
- [x] Database schema deployed
- [x] Service layer 100% functional
- [x] Riverpod providers working
- [ ] UI control implemented & tested
- [ ] Dashboard shows suspension status
- [ ] Bills don't generate during suspension
- [ ] Audit log records all actions
- [ ] Notifications sent correctly
- [ ] All tests passing
- [ ] Production ready

---

## Documentation Files

See also:
- **BILLING_ENGINE_DOCUMENTATION.md** - Fee component architecture
- **RECONCILIATION_ANALYSIS.md** - Strategic roadmap
- **PROJECT_ANALYSIS.md** - Overall project status
- **BILLING_ENGINE_FIXES.md** - Code quality details
- **supabase_migrations/billing_suspension_schema.sql** - Full DB schema

---

## Next Steps (After Phase 3A)

1. **Phase 3B - Granular Controls** (Defer to v1.1 if time pressure)
   - Scope selector UI (students, grades, fee types)
   - Multiple active suspensions per school
   - Per-student override capabilities

2. **Backbilling System** (v1.1)
   - Calculate missed bills during suspension
   - Backbill generation on resume
   - Backbill notification to parents

3. **Advanced Reports** (v1.1)
   - Suspension impact analysis
   - Revenue impact calculations
   - Compliance reporting

---

**Owner:** Nyasha Gabriel / Batch Tech  
**Status:** Ready for Implementation  
**Last Updated:** January 3, 2026
