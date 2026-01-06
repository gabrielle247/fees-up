# 🚨 Billing & Settings Architecture Audit - CRITICAL FINDINGS

**Status**: POTEMKIN RURAL - Surface UI without functional backends  
**Assessment Date**: January 6, 2026  
**Priority**: CRITICAL - Blocks core functionality  

---

## Executive Summary

The billing periods and settings systems have extensive UI implementations but **non-functional or partially-functional backends**. This creates a false impression of completeness while actual data persistence and business logic are broken or missing.

### Key Issues
1. **Billing Periods** - UI complete, month generation partially works, saving doesn't persist
2. **Settings Updates** - Fake update methods that show success but don't save
3. **Provider Inconsistencies** - Providers claim to persist data but don't properly sync
4. **Missing Data Seeding** - Critical data (months, years) not properly initialized
5. **State Management Chaos** - Mix of local state, database calls, and providers with no clear ownership

---

## 1. Billing Periods System - THE MASSIVE MESS

### Current Architecture

```
YearConfigurationCard (StatefulWidget)
├─ Local State: TextEditingControllers (_startDateController, _endDateController, etc.)
├─ Local State: _months list (loaded from DB)
├─ Method: _loadYearData() - Reads from DB
├─ Method: _regenerateMonthDates() - Updates local list
├─ Method: _onSave() - Attempts to write to DB
└─ Problem: Everything is local state with ad-hoc database calls
```

### Issues Identified

#### 1.1: Missing Month Data Seeding
**File**: `lib/pc/widgets/settings/year_configuration_card.dart:429`

```dart
// PROBLEM: Months loaded from database but might not exist
final months = await db.db.getAll(
  '''SELECT id, name, month_index, start_date, end_date, is_billable, term_id
     FROM school_year_months
     WHERE school_year_id = ? AND school_id = ?
     ORDER BY month_index''',
  [widget.yearId, schoolId],
);

// If months don't exist, card displays "No months found for this year"
// User cannot create months in UI - they can only toggle existing ones
if (_months.isEmpty) {
  return Container(
    child: const Center(
      child: Text('No months found for this year.'),
    ),
  );
}
```

**Impact**: 
- New years have no associated months
- Billing cycles can't be configured
- Auto-billing fails silently

**Root Cause**:
- `school_year_generator_provider.dart` creates years but **separate logic** (not called) creates months
- No automatic month seeding on year creation
- UI has no "Add Month" button despite months being critical

#### 1.2: Date Regeneration is Local-Only
**File**: `lib/pc/widgets/settings/year_configuration_card.dart:930`

```dart
void _regenerateMonthDates() {
  if (_startDateController.text.isEmpty || _endDateController.text.isEmpty) {
    return;
  }

  try {
    final start = DateTime.tryParse(_startDateController.text);
    final end = DateTime.tryParse(_endDateController.text);

    if (start == null || end == null || start.isAfter(end)) return;

    setState(() {
      // PROBLEM: Only updates local state
      // Never persists to database
      for (int i = 0; i < _months.length; i++) {
        final month = _months[i];
        final monthIndex = month['month_index'] as int? ?? (i + 1);

        final monthStart = DateTime(start.year, monthIndex, 1);
        final monthEnd = DateTime(start.year, monthIndex + 1, 0);

        if (monthStart.isBefore(end) && monthEnd.isAfter(start)) {
          month['start_date'] = DateFormat('yyyy-MM-dd')
              .format(monthStart.isBefore(start) ? start : monthStart);
          month['end_date'] = DateFormat('yyyy-MM-dd')
              .format(monthEnd.isAfter(end) ? end : monthEnd);
        }
      }
    });
  } catch (e) {
    debugPrint('⚠️ Error regenerating month dates: $e');
  }
}
```

**Impact**: 
- Month dates recalculated but not saved
- Changes lost on page refresh
- Billing periods use stale dates

#### 1.3: Save Logic is Incomplete
**File**: `lib/pc/widgets/settings/year_configuration_card.dart:513`

```dart
Future<void> _onSave(BuildContext context, String schoolId) async {
  setState(() => _saving = true);

  try {
    final db = DatabaseService();

    // Build description with terms if present
    String descriptionValue;
    if (_terms.isNotEmpty) {
      descriptionValue = jsonEncode({
        'description': _descriptionController.text.trim(),
        'terms': _terms,
      });
    } else {
      descriptionValue = _descriptionController.text.trim();
    }

    // Update the YEAR
    await db.db.execute(
      '''UPDATE school_years 
         SET year_label = ?, start_date = ?, end_date = ?, 
             description = ?, active = ? 
         WHERE id = ? AND school_id = ?''',
      [
        _yearLabelController.text.trim(),
        _startDateController.text,
        _endDateController.text,
        descriptionValue,
        _activeToggle ? 1 : 0,
        widget.yearId,
        schoolId,
      ],
    );

    // PROBLEM: Years are saved but MONTHS ARE NOT
    // _months list has been modified locally but never saved back to DB
    // The _regenerateMonthDates() changes are lost forever

    // PROBLEM 2: No transaction wrapping
    // Year saved successfully but if month save fails, inconsistent state

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Year configuration saved successfully'),
        ),
      );
    }
  } catch (e) {
    // PROBLEM 3: Generic error handling
    // "Failed to save: $e" tells user nothing useful
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  } finally {
    if (mounted) setState(() => _saving = false);
  }
}
```

**Missing Logic**:
1. No loop to update individual months
2. No `UPDATE school_year_months` statement
3. No validation of month date ranges
4. No handling of term assignments

**Real Impact**:
```
User Action                      → Expected                 → Actual
─────────────────────────────────────────────────────────────────────────
Sets year dates                 → Months recalculate        → Only local state
Clicks "Save Year"              → All data persisted        → Only year persisted
Months show updated dates       → Billing uses new dates    → Billing uses DB dates
Reopens year config             → Dates are maintained      → Local changes lost
```

### 1.4: Month Billable Toggle is Fake
**File**: `lib/pc/widgets/settings/year_configuration_card.dart:488`

```dart
void _toggleMonthBillable(dynamic monthId, bool value) {
  setState(() {
    for (final m in _months) {
      if (m['id'] == monthId) {
        // PROBLEM: Only updates local state
        m['is_billable'] = value;
        break;
      }
    }
  });
}
```

**Path from UI to DB**:
1. ✅ User clicks toggle switch
2. ✅ Local `_months[i]['is_billable']` updated
3. ✅ UI refreshes
4. ❌ No update statement to `school_year_months` table
5. ❌ Changes not persisted
6. ❌ Changes lost on refresh

---

## 2. Settings Update Methods - THE FAKES

### 2.1: BillingConfigCard Update Flow

**File**: `lib/pc/widgets/settings/billing_config_card.dart:298`

```dart
Future<void> _onSave(BuildContext context, String schoolId) async {
  setState(() => _saving = true);
  try {
    // This LOOKS legitimate...
    await ref.read(billingConfigProvider(schoolId).notifier).saveConfig(
      currencyCode: _currencyController.text.trim().isEmpty
          ? 'USD'
          : _currencyController.text.trim(),
      taxRate: _parseDouble(_taxController.text),
      registrationFee: _parseDouble(_registrationFeeController.text),
      // ... all parameters
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Billing settings saved')),
      );
    }
  } catch (e) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Error: $e')),
      );
    }
  }
}
```

**Provider Implementation**: `lib/data/providers/billing_config_provider.dart:68`

```dart
Future<void> saveConfig({
  required String currencyCode,
  required double taxRate,
  required double registrationFee,
  required int gracePeriodDays,
  required String invoicePrefix,
  required int invoiceSequenceSeed,
  required double lateFeePercentage,
  required double defaultFee,
  required bool allowPartialPayments,
  required String invoiceFooterNote,
}) async {
  try {
    final existing = await _db.db.getAll(
      'SELECT id FROM billing_configs WHERE school_id = ? LIMIT 1',
      [schoolId],
    );

    final payload = <String, dynamic>{
      'school_id': schoolId,
      'currency_code': currencyCode,
      'tax_rate_percentage': taxRate,
      'registration_fee': registrationFee,
      'grace_period_days': gracePeriodDays,
      'invoice_prefix': invoicePrefix,
      'invoice_sequence_seed': invoiceSequenceSeed,
      'late_fee_percentage': lateFeePercentage,
      'default_fee': defaultFee,
      'allow_partial_payments': allowPartialPayments ? 1 : 0,
      'invoice_footer_note': invoiceFooterNote,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (existing.isEmpty) {
      // PROBLEM: Using raw DatabaseService.insert()
      await _db.insert('billing_configs', {
        'id': _uuid.v4(),
        ...payload,
      });
    } else {
      // PROBLEM: Using raw DatabaseService.update()
      await _db.update(
        'billing_configs',
        existing.first['id'] as String,
        payload,
      );
    }

    await load(); // Reload after save
  } catch (e, st) {
    debugPrint('❌ Failed to save billing config: $e');
    state = AsyncError(e, st);
    rethrow;
  }
}
```

**The Problem**: 
- ✅ Writes to local SQLite database (correct)
- ❌ PowerSync MAY OR MAY NOT sync to Supabase
- ❌ No explicit `uploadData()` call
- ❌ No sync status checking
- ❌ No conflict resolution if offline changes conflict

**Real User Experience**:
1. User edits billing config
2. Clicks "Save" → ✅ Saves locally  
3. Sees snackbar "✅ Settings saved"
4. But if PowerSync sync fails: ❌ Changes don't reach Supabase
5. Another device sees old config
6. No indication to user that sync failed

### 2.2: OrganizationCard Save is Partially Fake
**File**: `lib/pc/widgets/settings/organization_card.dart:187`

```dart
Future<void> _onSave(BuildContext context, String schoolId) async {
  setState(() => _saving = true);
  try {
    // Direct database calls instead of provider-based updates
    final db = DatabaseService();

    // PROBLEM: Building a JSON structure for contact_info
    // but if the field doesn't exist in schema, it fails silently
    final contactJson = jsonEncode({
      'address': _addressController.text.trim(),
      'email': _emailController.text.trim(),
    });

    // PROBLEM: Using raw SQL instead of repository
    await db.db.execute(
      'UPDATE schools SET name = ?, contact_info = ?, logo_url = ?, updated_at = ? WHERE id = ?',
      [
        _nameController.text.trim(),
        contactJson,
        _logoController.text.trim(),
        DateTime.now().toIso8601String(),
        schoolId,
      ],
    );

    // Success message without verification
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Organization details updated')),
      );
    }
  } catch (e) {
    // Vague error message
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to save: $e')),
      );
    }
  }
}
```

**Issues**:
1. Uses legacy `contact_info` JSON field
2. Doesn't handle if that column doesn't exist
3. Raw SQL instead of type-safe updates
4. Logo URL stored as plain string, not Supabase reference
5. No validation of URLs or contact details

---

## 3. Provider Architecture Chaos

### 3.1: Multiple Competing Data Sources

```
BillingConfigCard
├─ Source 1: Local TextEditingControllers
├─ Source 2: billingConfigProvider (reads from DB)
├─ Source 3: Direct DatabaseService calls
└─ Problem: 3 sources of truth for same data
```

### 3.2: Hydration Pattern is Fragile

**Pattern**:
```dart
// YearConfigurationCard
bool _hydrated = false;

@override
Widget build(BuildContext context) {
  if (!_hydrated) {
    _loadYearData();  // Called during build()
    _hydrated = true;  // Set flag to prevent reload
  }
  // ...
}
```

**Problems**:
1. ⚠️ Database call in `build()` method (anti-pattern)
2. ⚠️ `_hydrated` flag can get out of sync
3. ⚠️ No cancel/retry logic if load fails
4. ⚠️ Provider changes don't trigger reload

---

## 4. Data Persistence Gaps

### 4.1: Billing Periods - No Atomic Transactions

```dart
// Current (WRONG):
await db.execute('UPDATE school_years ...');  // Succeeds
await db.execute('UPDATE school_year_months ...'); // ← Could fail here
// If month update fails, year is saved but months are stale

// Should be:
await db.transaction((tx) async {
  await tx.execute('UPDATE school_years ...');
  await tx.execute('UPDATE school_year_months ...');  // Both succeed or both fail
});
```

### 4.2: Settings Save Without Verification

```dart
// Current (WRONG):
await db.db.execute('UPDATE billing_configs ...');
ScaffoldMessenger.of(context).showSnackBar(
  const SnackBar(content: Text('✅ Settings saved')),
);

// Should be:
try {
  await db.db.execute('UPDATE billing_configs ...');
  // Verify the update actually occurred
  final result = await db.db.getAll(
    'SELECT * FROM billing_configs WHERE id = ?',
    [configId],
  );
  if (result.isNotEmpty && result.first['currency_code'] == updatedValue) {
    // Success - data really changed
    ScaffoldMessenger.of(context).showSnackBar(...);
  } else {
    // Silent failure - update didn't stick
    throw Exception('Settings update verification failed');
  }
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(...);
}
```

---

## 5. Missing Features / Non-Functional Stubs

| Feature | UI | Backend | Notes |
|---------|:---:|:--------:|-------|
| **Add School Year** | ✅ Button visible | ❌ Dead click | `_onAddYear()` creates demo data, not persisted |
| **Delete School Year** | ❌ No UI | ❌ No code | Users can't delete years |
| **Add Month** | ❌ No UI | ❌ No code | Months must be system-generated only |
| **Edit Month Dates** | ✅ Sliders/pickers | ⚠️ Local only | Changes don't persist to DB |
| **Toggle Month Billable** | ✅ Toggle switch | ⚠️ Local only | Changes lost on refresh |
| **Save All Settings** | ✅ Save button | ⚠️ Incomplete | Year saves but months don't |
| **Billing Config Save** | ✅ Save button | ⚠️ Fake PowerSync | Saves locally but sync may fail silently |
| **Organization Update** | ✅ Save button | ⚠️ Raw SQL | No type safety or validation |

---

## 6. Architectural Recommendations

### Phase 1: Fix Critical Data Persistence (WEEK 1)

1. **Implement Atomic Month Persistence**
   ```dart
   Future<void> _saveYearWithMonths(String yearId, Map<String, dynamic> yearData) async {
     await db.transaction((tx) async {
       // Update year
       await tx.execute('''UPDATE school_years SET ...''');
       
       // Update each month
       for (final month in _months) {
         await tx.execute('''UPDATE school_year_months 
            SET start_date = ?, end_date = ?, is_billable = ? 
            WHERE id = ?''', [
           month['start_date'],
           month['end_date'],
           month['is_billable'] ? 1 : 0,
           month['id'],
         ]);
       }
     });
   }
   ```

2. **Auto-Seed Months on Year Creation**
   - When creating a school year, immediately create 12 associated months
   - Set sensible defaults (Nov-Oct academic calendar)
   - No UI required for this - automatic

3. **Fix YearConfigurationCard Save Flow**
   - Call `_saveYearWithMonths()` instead of just updating year
   - Verify changes persisted before showing success message
   - Implement proper error recovery

### Phase 2: Establish Single Source of Truth (WEEK 2)

1. **Replace Direct DB Calls with Repositories**
   ```dart
   // Instead of:
   await db.execute('UPDATE billing_configs ...');
   
   // Use:
   final success = await billingRepository.updateBillingConfig(config);
   ```

2. **Implement Proper Providers**
   - Each settings page should have ONE StateNotifierProvider
   - Provider owns the form state (not local controllers)
   - Save operations go through provider's notifier

3. **Fix PowerSync Sync Status**
   - Check `uploadData()` result before showing success
   - Show "Syncing..." indicator if offline
   - Implement retry for failed syncs

### Phase 3: Add Data Validation (WEEK 3)

1. **Form Validation**
   - Year dates: start < end, both in valid range
   - Month dates: within year boundaries
   - Billing config: non-negative amounts, valid currency codes

2. **Conflict Detection**
   - Detect overlapping year/month ranges
   - Warn if billable months sum to invalid total
   - Prevent invalid state transitions

### Phase 4: Improve UX/Error Handling (WEEK 4)

1. **Clear Feedback**
   - Show which fields failed validation
   - Distinguish between local vs sync errors
   - Provide actionable error messages

2. **Undo/Revert**
   - "Cancel" button should discard local changes
   - "Reset" button should reload from DB
   - Show indication of unsaved changes

---

## 7. Summary: Why This is Broken

### The Potemkin Pattern

```
APPEARANCE                      REALITY
─────────────────────────────────────────────────────────────
✅ UI looks complete            ❌ Forms don't save properly
✅ Buttons are clickable        ❌ Clicks cause silent failures
✅ Snackbars show success       ❌ Data not actually persisted
✅ LocalStorage reads work      ❌ Sync to server doesn't happen
✅ Multiple screens exist       ❌ Most are non-functional stubs
```

### Root Causes

1. **Architecture Mismatch**: 
   - UI built for Riverpod providers but uses direct DB calls
   - Providers defined but not used by settings screens

2. **No Verification**:
   - Success assumed without checking actual persistence
   - No read-back validation after writes

3. **Incomplete Implementations**:
   - Month saving loop never written
   - Transaction support not used
   - Atomic operations missing throughout

4. **Silent Failures**:
   - DB errors caught but re-thrown (good) or ignored (bad)
   - PowerSync failures undetected
   - User gets success message despite underlying failures

---

## 8. Impact Assessment

### What Currently Works
- ✅ Reading existing data from local SQLite
- ✅ Displaying data in UI
- ✅ User can interact with forms
- ✅ Some updates reach local DB

### What Doesn't Work
- ❌ Month configuration persistence
- ❌ Multi-step atomic operations
- ❌ PowerSync sync status verification
- ❌ Settings updates across devices
- ❌ Billing cycles depend on months (broken)
- ❌ Auto-billing (depends on months)
- ❌ Offline-first sync reliability

### Severity
**CRITICAL** - Core billing system cannot function without working months/periods

---

## Next Steps

1. **Immediate**: Create month seeding function for existing years
2. **Today**: Implement atomic year+month persistence
3. **This week**: Convert all settings to use repositories
4. **This week**: Add PowerSync sync verification
5. **Next week**: Comprehensive testing of settings→billing flow

This system needs a **full architectural refactoring**, not just bug fixes.
