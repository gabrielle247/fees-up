# **Fees Up – Batch Tech – Functional Gap Analysis**  
**Date:** January 2, 2026  
**Prepared for:** Nyasha Gabriel (Boss)  
**Project Alias:** Batch One  

---

## 🔍 **Executive Summary**

The `Fees Up` codebase demonstrates a **highly structured, production-grade architecture** built around:
- **PowerSync + Supabase** for offline-first, real-time sync
- **Riverpod** for state management
- **GoRouter** for navigation with auth guards
- **Material 3 Dark Theme** with cohesive design tokens (`AppColors`)
- **Modular UI Components** across mobile and PC targets

However, several **core features remain unimplemented or partially wired**, which block full production readiness. This document details those gaps, organized by **domain**.

---

## ⚠️ **Critical Functional Gaps**

### 1. **Student Registration – Auto-Billing Logic Broken**
- **File**: `./pc/widgets/dashboard/student_dialog.dart`
- **Issue**: `_attemptAutoBilling()` references tables `school_years` and `school_year_months` that **do not exist in the synced schema** unless a school year has been explicitly created via settings.
- **Consequence**: New students are **not auto-billed** on registration → manual invoice creation becomes mandatory.
- **Recommendation**: Either:
  - Ensure a default `school_year` and month range is created during `createSchool()`, OR
  - Gracefully fall back to a direct bill creation without school-year context when none exists.

### 2. **Invoice Creation – Schema Integrity Risk**
- **File**: `./pc/widgets/invoices/invoice_dialog.dart`
- **Issue**: Manual invoices hardcode `'term_id': 'adhoc-manual'` to bypass Postgres check constraints.
- **Risk**: This is a **schema hack**, not a sustainable solution. May break if RLS or constraints are tightened.
- **Recommendation**: Add a proper `bill_type = 'adhoc'` path in the Supabase RLS policy and database schema.

### 3. **Mobile Transaction Screen – Placeholder Only**
- **File**: `./core/routes/app_router.dart`
- **Issue**: `/transactions` route returns a **static placeholder** for mobile:
  ```dart
  mobileScaffold: Scaffold(body: Center(child: Text("Mobile Transactions"))),
  ```
- **Consequence**: Mobile users **cannot access financial records**.
- **Recommendation**: Build `MobileTransactionsScreen` mirroring PC logic with responsive components.

---

## 🧩 **Incomplete Feature Implementations**

### 4. **Reports Screen – Template & Export Logic Missing**
- **File**: `./pc/screens/reports_screen.dart`
- **Status**: UI fully built, but:
  - **No data fetching** from `ReportsRepository`
  - **"Generate Report"** and **"Preview Data"** buttons are inert
  - State management via `reportBuilderProvider` is **not connected to backend**
- **Recommendation**: Bind the StateNotifier to `ReportsRepository` methods like `fetchFinancialSummary`.

### 5. **Universal Transaction Dialog – Future Modules Unimplemented**
- **File**: `./pc/widgets/transactions/universal_entry_dialog.dart`
- **Status**: Supports only `payment`, `expense`, `student`, `campaign`.
- **Missing**: `payroll`, `assets`, `bulkImport`, `auditLog`
- **Note**: This is acceptable for **v1**, but flags indicate these are **planned**.
- **Recommendation**: Add a feature flag or feature gate for Professional Suite.

### 6. **Settings – Year Configuration Not Editable**
- **File**: `./pc/widgets/settings/year_configuration_card.dart`
- **Issue**: All `TextFormField` fields are **read-only mockups** – no state binding or save logic.
- **Consequence**: Admins **cannot actually configure** academic years via UI.
- **Recommendation**: Connect to `DatabaseService` write operations with validation.

---

## 🔒 **Security & Policy Gaps**

### 7. **Broadcast System – No Role/Permission Gate**
- **File**: `./pc/widgets/announcements/compose_broadcast_dialog.dart`
- **Issue**: **Any authenticated user** can post school-wide or HQ-internal broadcasts.
- **Risk**: Potential for abuse or misinformation.
- **Recommendation**: Restrict `postBroadcast` to `school_admin` or `super_admin` roles via auth check in `BroadcastLogic`.

### 8. **Premium Guard – Always Unlocked**
- **File**: `./core/widgets/premium_guard.dart`
- **Status**: `isPremiumProvider` hardcodes `true`.
- **Consequence**: **Monetization logic is disabled**.
- **Recommendation**: Replace with real provider that reads `subscription_tier` from `schools` table.

---

## 🔄 **Sync & Data Integrity Risks**

### 9. **User Linking – No Email Validation**
- **File**: `./data/repositories/users_repository.dart`
- **Issue**: `addUserByEmail()` assumes the user **already exists** in Supabase auth.
- **Risk**: If email doesn’t exist, RPC throws → **user sees cryptic error**.
- **Recommendation**: Pre-validate email existence or provide user-friendly onboarding flow.

### 10. **Manual Transaction Dialogs – No Form Dirty Tracking**
- **Files**: `payment_dialog.dart`, `expense_dialog.dart`, etc.
- **Issue**: `formDirtyProvider` is **never updated** inside dialogs.
- **Consequence**: Universal Hub **cannot warn** about unsaved changes when switching tabs.
- **Recommendation**: Connect all form fields to update `formDirtyProvider` on change.

---

## 🖥️ **UI/UX Polish Gaps**

| Feature | Issue | Impact |
|--------|-------|--------|
| **Search in Settings** | Autocomplete shows matches but **doesn’t highlight** selected tab | Confusing UX |
| **Student Subjects** | Subject selector **doesn’t persist** across dialog close/reopen | Data loss risk |
| **Invoice PDF** | `pdf_url` field exists but **no PDF generation** logic | Feature incomplete |
| **Activity Log** | Hardcoded mock data – **no real audit trail** | Lacks compliance |

---

## ✅ **What’s Fully Functional**

- ✅ Auth (email/password + Google)
- ✅ School creation & profile linking
- ✅ Real-time sync (PowerSync ↔ Supabase)
- ✅ Student CRUD (with search)
- ✅ Manual payment & expense recording
- ✅ Notifications (local + broadcast)
- ✅ Responsive layout (mobile ↔ PC)
- ✅ Dashboard KPIs (live stats)
- ✅ Campaign creation & tracking

---

## 📌 **Recommended Next Steps**

1. **Fix Critical Gaps** (Auto-billing, Mobile Transactions, Invoice Schema)
2. **Wire Reports to Backend**
3. **Implement Premium Guard Logic**
4. **Add Role Checks to Broadcasts**
5. **Build PDF Invoice Generator** (even if client-side stub)

---

**Prepared by:** AI Assistant  
**For:** Nyasha Gabriel – Batch Tech  
**Project:** Fees Up (Batch One)  

> **Save this as `functional_gap_analysis.md`**  
> Let me know when you're ready to tackle specific gaps – I'll generate full implementation files with zero fragments.
