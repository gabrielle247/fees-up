# 📊 Billing Data Architecture & PowerSync-UI Bridge Audit

**Date:** January 6, 2026  
**Status:** COMPREHENSIVE ANALYSIS  
**Scope:** Entire billing data flow from PowerSync → UI in Settings

---

## Executive Summary

Your billing system has a **sophisticated architecture** with good separation of concerns, but there are **critical usability and data consistency gaps** in the Settings UI bridge:

| Aspect | Status | Risk |
|--------|--------|------|
| **Billing Data Schema** | ✅ Well-structured | Low |
| **PowerSync Sync** | ✅ Implemented | Low |
| **Provider Layer** | ✅ Riverpod patterns clean | Low |
| **Settings UI Wiring** | 🟡 **Partially Connected** | **HIGH** |
| **Data Validation** | 🔴 **Minimal** | **CRITICAL** |
| **User Feedback** | 🟡 **Limited** | **MEDIUM** |
| **Offline-First Sync** | ✅ Working | Low |

---

## 1. Billing Data Schema Analysis

### 1.1 Core Tables Structure

```
PowerSync Synced Tables:
├── schools (core metadata)
│   ├── contact_info (JSON)
│   ├── notification_prefs (JSON)
│   ├── logo_url
│   └── [6 more columns]
├── students (billing subject)
│   ├── billing_type ('monthly', 'termly')
│   ├── default_fee
│   ├── owed_total (cached)
│   ├── paid_total (cached)
│   └── [15+ more columns]
├── bills (invoices)
│   ├── invoice_number (INV-00001)
│   ├── status ('draft', 'sent', 'paid')
│   ├── total_amount
│   ├── paid_amount
│   ├── bill_type ('monthly', 'adhoc')
│   ├── school_year_id (nullable)
│   ├── month_index (nullable)
│   ├── term_id (nullable)
│   └── [8+ more columns]
├── bill_items (line items)
│   ├── bill_id (FK)
│   ├── description
│   ├── amount
│   ├── quantity
│   └── created_at
├── payments (records)
│   ├── student_id (FK)
│   ├── amount
│   ├── method
│   ├── bill_id (nullable FK)
│   └── [6 more columns]
├── payment_allocations (mapping)
│   ├── payment_id (FK)
│   ├── bill_id (FK)
│   └── amount
├── billing_configs (school-level rules)
│   ├── currency_code
│   ├── tax_rate_percentage
│   ├── late_fee_percentage
│   ├── default_fee
│   ├── grace_period_days
│   ├── invoice_prefix
│   └── [4 more columns]
├── school_years (academic calendar)
│   ├── year_label
│   ├── start_date
│   ├── end_date
│   └── active (bool)
├── school_year_months (billing periods)
│   ├── school_year_id (FK)
│   ├── month_index
│   ├── start_date
│   ├── end_date
│   ├── is_billable (bool)
│   └── term_id (nullable FK)
└── school_terms (grouping)
    ├── school_year_id (FK)
    ├── name
    ├── start_date
    └── end_date

NOT Synced (Server-only, RLS Protected):
├── billing_suspension_periods
├── billing_audit_log
├── billing_extensions
└── [accessed via Supabase Realtime/RPC only]
```

### 1.2 Schema Strengths ✅

| Feature | Implementation | Quality |
|---------|----------------|---------|
| **Nullable FK Handling** | `school_year_id`, `month_index`, `term_id` all nullable for adhoc bills | Excellent |
| **Sequential Invoicing** | `invoice_number` format `INV-00001` generated server-side | Secure |
| **Status Tracking** | `status` field supports draft/sent/partial/paid/overdue lifecycle | Complete |
| **Multi-Bill Allocation** | `payment_allocations` allows single payment → multiple bills | Flexible |
| **Academic Calendar** | Nov-Aug pattern with terms and billable month toggles | Accurate |
| **Period Mapping** | `school_year_months` links to terms via FK | Relational |

### 1.3 Schema Gaps 🔴

| Gap | Current State | Impact | Severity |
|-----|---------------|--------|----------|
| **No Due Date on Bills** | Only in `billing_cycle_end` (confusing name) | Unclear deadline | Medium |
| **Cached Totals** | `owed_total`, `paid_total` on students denormalized | Risk of stale data | **HIGH** |
| **No Audit Trail UI** | `billing_audit_log` exists server-side only | Can't debug disputes | Medium |
| **Missing PDF Storage** | `pdf_url` column in schema but no UI for generation | Incomplete invoicing | High |
| **No Dispute/Credit UI** | `credits` table exists but not exposed in Settings | Hidden feature | Medium |
| **Late Fee Calculation** | Config exists but no UI or automatic application | Manual workaround needed | High |

---

## 2. PowerSync → Billing Data Bridge

### 2.1 PowerSync Configuration

**Status:** ✅ **CORRECTLY CONFIGURED**

```dart
// lib/data/services/schema.dart
const Schema appSchema = Schema([
  Table('schools', [...]),      // ✅ Synced
  Table('students', [...]),     // ✅ Synced
  Table('bills', [...]),        // ✅ Synced
  Table('payments', [...]),     // ✅ Synced
  Table('billing_configs', [...]), // ✅ Synced
  // NOTE: billing_audit_log, billing_suspension, etc NOT in schema
  // → Intentional: server-side only, accessed via RPC
]);
```

**Sync Flow:**
1. **Supabase Postgres** → PowerSync upstream → **Local SQLite**
2. **Local write** → PowerSync queues → **Supabase batch**
3. **Realtime triggers** → School members see updates

**RLS Enforced:** ✅
- Users see only their school's data
- Audit logs read-only on server
- Billing operations verified server-side

### 2.2 Data Freshness Issues 🟡

| Data Type | Sync Method | Fresh? | Problem |
|-----------|-----------|--------|---------|
| Bills (read) | PowerSync watch() | ✅ Real-time | None |
| Billing configs (read) | Provider + watch | ✅ Real-time | None |
| Student totals | Cached in SQLite | ❌ **Stale** | Not recalculated when payment created |
| Payment allocations | Not exposed in UI | ❓ Unknown | Can't see partial payments |
| Academic calendar | Seeded once | ✅ Static | Fine (nov-Aug logic now fixed) |

**Critical Finding:** `owed_total` and `paid_total` on `students` table are **denormalized caches** that don't update automatically when payments created.

---

## 3. Settings UI → Billing Data Wiring

### 3.1 Settings Screen Architecture

```
SettingsScreen (settings_screen.dart)
├── Tab 0: General & Financial (general_financial_view.dart) 📍 BILLING
│   ├── BillingConfigCard
│   │   ├── Provider: billingConfigProvider
│   │   ├── Reads: billing_configs table
│   │   ├── Writes: UPDATE billing_configs
│   │   └── UI Fields: [✅ 10 fields wired]
│   │
│   ├── OrganizationCard
│   │   ├── Reads: schools.contact_info (JSON)
│   │   ├── Writes: schools.contact_info + logo_url
│   │   └── UI Fields: [✅ 4 fields wired + logo preview]
│   │
│   ├── SchoolLogoCard (placeholder)
│   │   └── TODO: Upload to Supabase storage
│   │
│   └── IntegrationsCard (placeholder)
│       └── TODO: Teacher access tokens
│
├── Tab 1: School Year (school_year_settings_view.dart)
│   ├── YearConfigurationCard
│   │   ├── Reads: school_years, school_year_months, school_terms
│   │   ├── Writes: school_years + school_year_months
│   │   └── UI Fields: [✅ 8+ fields wired with date pickers]
│   │
│   └── TermManagementCard
│       ├── Reads: school_terms
│       ├── Writes: school_terms (CRUD)
│       └── UI Fields: [✅ 3 fields wired]
│
├── Tab 2: Users & Permissions
├── Tab 3: Notifications ✅ **FULLY WIRED**
└── Tab 4: Integrations
```

### 3.2 Billing Config Card Wiring Status ✅

**File:** `lib/pc/widgets/settings/billing_config_card.dart`

| Field | Status | Persistence | Issues |
|-------|--------|-------------|--------|
| Currency Code | ✅ Reads/Writes | SQLite → Supabase | None |
| Tax Rate (%) | ✅ Reads/Writes | SQLite → Supabase | None |
| Default Fee | ✅ Reads/Writes | SQLite → Supabase | None |
| Registration Fee | ✅ Reads/Writes | SQLite → Supabase | None |
| Late Fee (%) | ✅ Reads/Writes | SQLite → Supabase | ⚠️ Not auto-applied |
| Grace Period Days | ✅ Reads/Writes | SQLite → Supabase | None |
| Invoice Prefix | ✅ Reads/Writes | SQLite → Supabase | None |
| Invoice Sequence | ✅ Reads/Writes | SQLite → Supabase | None |
| Partial Payments | ✅ Reads/Writes | SQLite → Supabase | None |
| Footer Note | ✅ Reads/Writes | SQLite → Supabase | None |

**Strengths:**
- Uses Riverpod `StateNotifierProvider` for state management
- Proper hydration pattern (load once, prevent redundant fetches)
- Snackbar feedback on success/failure
- Reset button to reload from database

**Issues:**
- ❌ **No validation** on numeric fields (negative values accepted?)
- ❌ **No field dependency** (e.g., what if grace period > month length?)
- ❌ **No preview** of how late fees will calculate
- ❌ **No impact warning** (e.g., "Changing tax rate affects existing bills?")

### 3.3 Organization Card Status ✅ + 🟡

**File:** `lib/pc/widgets/settings/organization_card.dart`

| Feature | Status | Notes |
|---------|--------|-------|
| School Name | ✅ Working | Reads/writes `schools.name` |
| Address | ✅ Working | Reads/writes `schools.contact_info.address` (JSON) |
| Email | ✅ Working | Reads/writes `schools.contact_info.email` (JSON) |
| Logo URL | ✅ Captures | Reads/writes `schools.logo_url` |
| Logo Preview | ✅ NEW! | Displays image from Supabase bucket + fallback |
| Contact Info JSON | ✅ Handles | Falls back to legacy columns if JSON missing |

**Strengths:**
- Robust JSON fallback for legacy data
- Logo preview widget shows images with error handling
- Automatic Supabase public URL construction

**Gaps:**
- ❌ No upload mechanism (users must provide full Supabase URL)
- ❌ No validation of image URL (dead links not caught until preview)
- ❌ No batch update (saves name separately from contact_info)

---

## 4. Riverpod Provider Bridge Analysis

### 4.1 Billing Providers

```dart
// invoices_provider.dart
final invoicesProvider = StreamProvider.family<List<...>, String>
  → Watches: bills table
  → Real-time updates ✅
  → Used by: InvoicesTable, StudentBillsDialog

final studentInvoicesProvider = StreamProvider.family<List<...>, String>
  → Watches: bills WHERE student_id = ?
  → Real-time updates ✅
  → Used by: StudentBillsDialog

final invoiceStatsProvider = Provider.family<InvoiceStats, String>
  → Computes: Total billed, collected, pending, overdue
  → ⚠️ Derives from invoicesProvider data
  → Used by: Dashboard cards
  → ISSUE: Doesn't cache, recomputes on every watch

// billing_config_provider.dart
final billingConfigProvider = StateNotifierProvider.autoDispose.family
  → Reads: SELECT * FROM billing_configs
  → Writes: INSERT/UPDATE billing_configs
  → Hydration: One-time load + manual reset
  → Used by: BillingConfigCard, BillingConfigDialog
```

### 4.2 Provider Issues 🔴

| Provider | Issue | Impact | Fix |
|----------|-------|--------|-----|
| `invoiceStatsProvider` | Recomputes on every access | CPU waste | Add `.select()` |
| `billingConfigProvider` | Manual load() call | Easy to forget | Use async provider |
| `studentTotalsProvider` | ❌ DOESN'T EXIST | Can't track per-student totals | Create it! |
| `paymentAllocationsProvider` | Exists but not used in UI | Hidden feature | Expose in payments view |

---

## 5. Data Consistency & Integrity Issues

### 5.1 Critical Issue: Cached Student Totals

**Problem:**
```sql
students.owed_total = Denormalized cache
students.paid_total = Denormalized cache
```

When a payment is created:
1. ✅ `payments` table updated (PowerSync syncs)
2. ✅ `payment_allocations` created
3. ❌ `students.owed_total` NOT recalculated
4. ❌ UI shows stale "Owed $500" until page refresh

**Current Flow:**
```
Payment Created
    ↓
bills.paid_amount += payment.amount  ✅
    ↓
students.owed_total unchanged ❌
    ↓
UI reads stale students.owed_total
    ↓
User sees: "Still Owes $500" (but only owes $300)
```

**Correct Flow Should Be:**
```
Payment Created
    ↓
Trigger: Calculate SUM(bills.total_amount - bills.paid_amount) 
    WHERE student_id = X
    ↓
Update students.owed_total = calculated value
    ↓
PowerSync syncs updated students.owed_total
    ↓
All clients see fresh data
```

### 5.2 Who Recalculates Totals?

| Scenario | Who Updates | When | Working? |
|----------|-----------|------|----------|
| Admin creates adhoc invoice | Backend | Immediately | ✅ Yes |
| Admin records payment | Backend? UI? | ? | ❌ **Unclear** |
| Monthly invoice generated | Backend (seeder) | Nov 1 + async | ✅ Yes |
| Student makes payment via parent portal | Backend | Immediately | ✅ Yes (if portal exists) |
| PowerSync offline → online | Conflict? Merge? | When syncing | ❌ **Risky** |

---

## 6. Settings UI Data Flow Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                     SETTINGS SCREEN                          │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  [Tab: General & Financial]                                  │
│  ├─ Billing Config Card                                     │
│  │  ├─ billingConfigProvider.watch()                        │
│  │  │  └─ SELECT * FROM billing_configs (PowerSync)         │
│  │  ├─ _onSave() → DatabaseService.execute(UPDATE ...)      │
│  │  │  └─ PowerSync queues → Supabase batch                 │
│  │  └─ Snackbar feedback                                    │
│  │                                                           │
│  ├─ Organization Card                                       │
│  │  ├─ DatabaseService.getAll(schools WHERE id = ?)        │
│  │  ├─ Parse JSON: contact_info → address/email/logo       │
│  │  ├─ _logoController.text → live preview                 │
│  │  ├─ _onSave() → UPDATE schools SET ...                  │
│  │  │  └─ Saves contact_info JSON + logo_url               │
│  │  └─ Snackbar feedback                                    │
│  │                                                           │
│  └─ School Logo Card (placeholder)                          │
│     └─ TODO: Upload to Supabase storage → avatars bucket    │
│                                                               │
│  [Tab: School Year]                                          │
│  ├─ YearConfigurationCard                                   │
│  │  ├─ _loadYearData()                                      │
│  │  │  ├─ SELECT * FROM school_years WHERE id = ?          │
│  │  │  ├─ SELECT * FROM school_year_months WHERE year_id = ?
│  │  │  └─ SELECT * FROM school_terms WHERE year_id = ?     │
│  │  ├─ Date Pickers (interactive calendar)                 │
│  │  │  └─ _pickDate() validates start ≤ end                │
│  │  │  └─ _regenerateMonthDates() clips month boundaries    │
│  │  ├─ Month billability toggles                           │
│  │  ├─ Term assignment dropdowns                           │
│  │  ├─ _onSave() → Upsert school_years + school_year_months
│  │  │  └─ PowerSync queues → Supabase batch                 │
│  │  └─ Snackbar feedback                                    │
│  │                                                           │
│  └─ TermManagementCard                                      │
│     ├─ Display school_terms as rows                        │
│     ├─ Add/Remove term buttons                              │
│     ├─ _onSave() → INSERT/DELETE school_terms               │
│     └─ Snackbar feedback                                    │
│                                                               │
│  [Tab: Notifications] ✅ FULLY WIRED                        │
│  └─ NotificationsSettingsView                               │
│     ├─ notificationPreferencesProvider                      │
│     ├─ Toggles: billing, campaigns, attendance, announcements
│     ├─ Channels: SMS, Email, In-app                         │
│     ├─ DND: Quiet hours                                     │
│     └─ Snackbar feedback                                    │
│                                                               │
└─────────────────────────────────────────────────────────────┘
           ↓ All local changes queue in PowerSync
           ↓ On network available → batch upload
           ↓ Supabase validates & applies RLS
           ↓ Realtime triggers notify other sessions
           ↓ Other devices pull updated data
```

---

## 7. Usability Assessment

### 7.1 Strengths ✅

| Feature | Quality | Notes |
|---------|---------|-------|
| **Tab Navigation** | Excellent | Clear separation of concerns |
| **Feedback Loops** | Good | Snackbars on save/error |
| **Offline Handling** | Excellent | PowerSync handles queuing |
| **Date Pickers** | Good | Interactive calendar + validation |
| **Logo Preview** | Excellent | Live image with error fallback |
| **Hydration Pattern** | Good | One-time load prevents duplication |

### 7.2 Usability Gaps 🔴

| Gap | Severity | Fix Effort |
|-----|----------|-----------|
| **No numeric validation** on billing config | High | 1-2 hours |
| **No preview** of late fee impact | High | 2-3 hours |
| **Payment allocation UI missing** | Critical | 4-5 hours |
| **No audit trail visible** | Medium | 2-3 hours |
| **Student total recalc not visible** | Critical | Server fix required |
| **Invoice PDF generation** | High | 3-4 hours |
| **Late fee auto-application** | Critical | Server logic + trigger |
| **No batch payment import** | Medium | 6-8 hours |

---

## 8. Data Flow Issues Summary

### 8.1 Write Paths

```
User Input → Controller → _onSave() → DatabaseService.execute() 
                         → PowerSync (SQLite)
                         → Queued in local queue
                         → [Network] → Supabase Postgres
                         → RLS checks + triggers
                         → Realtime broadcast
                         → [Network] → Other clients' PowerSync
                         → SQLite update
                         → Provider notified
                         → UI rebuilt
```

**Issues in this path:**
- ❌ No offline-first optimistic UI updates
- ❌ No conflict resolution if offline edits
- ⚠️ Triggers on Supabase might not recalc student totals

### 8.2 Read Paths

```
Provider.watch() → DatabaseService.db.watch() (stream)
                 → SQLite changes
                 → Real-time updates
                 → Widget rebuild

Issues:
- ⚠️ If bill created offline → owed_total stale until recalc
- ❌ No SUM() calculations in UI (all manual)
- ❌ Student total denormalization creates sync risk
```

---

## 9. Recommendations

### Phase 1: Critical Fixes (Do ASAP)

1. **Add Validation to Billing Config** (1-2 hours)
   - Reject negative values
   - Warn if grace period > 30 days
   - Validate currency code ISO format

2. **Fix Student Total Denormalization** (Server)
   - Create Supabase trigger: on bill/payment insert → recalc students.owed_total
   - Or: Create RPC function `calculate_student_totals(student_id)`
   - Test with offline→online scenarios

3. **Add Late Fee Auto-Application** (3-4 hours)
   - Server trigger: Check bill due_date, apply late_fee if past grace period
   - UI shows: "Late Fee: $15 (3 days overdue)"

### Phase 2: UX Improvements (Next Sprint)

4. **Payment Allocations UI** (4-5 hours)
   - Show which bills a payment covered
   - Allow manual allocation (when bill > payment)
   - Display partial payment status

5. **Audit Trail in Settings** (2-3 hours)
   - Read-only view of `billing_audit_log`
   - Filter by date, action type
   - CSV export

6. **Invoice PDF Generation** (3-4 hours)
   - Hook to Supabase storage
   - Generate PDF on bill create
   - Store path in `bills.pdf_url`
   - Link in invoices table

### Phase 3: Nice-to-Have (Polish)

7. **Late Fee Impact Preview** (2-3 hours)
   - Input: overdue amount, days overdue
   - Output: "Late fee would be: $50 (10%)"

8. **Batch Payment Import** (6-8 hours)
   - CSV upload: Date, Student ID, Amount
   - Allocate to bills automatically or manually
   - Reconciliation report

---

## 10. Architecture Strengths Summary

| Layer | Strength |
|-------|----------|
| **Schema** | Relational integrity, proper FKs, nullable handling |
| **PowerSync** | Correct sync setup, RLS enforced, offline-first ready |
| **Providers** | Clean Riverpod patterns, real-time watches |
| **UI Components** | Good separation (cards), feedback loops |
| **Date Handling** | Nov-Aug pattern fixed, interactive pickers |

---

## Conclusion

**Your billing system is architecturally sound** with good schema design and PowerSync integration. However, **settings usability has gaps** especially around:

1. **Data consistency** (student total denormalization)
2. **Validation** (no constraints on config values)
3. **Visibility** (no audit trail, no payment allocations UI)
4. **Automation** (late fees not auto-applied)

**Recommended next step:** Fix denormalized student totals on Supabase (server trigger), then add validation to billing config card (client-side), then expose payment allocations UI.

All of this is **achievable in 2-3 sprints** with proper prioritization.
