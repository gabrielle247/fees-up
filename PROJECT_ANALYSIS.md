# Fees Up - Project Status Analysis & Action Plan

**Date:** January 3, 2026  
**Project:** Fees Up (SaaS Student Fees Management)  
**Status:** Pre-Launch Beta Phase  
**Owner:** Nyasha Gabriel / Batch Tech

---

## 📋 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Current Architecture](#current-architecture)
3. [Build Status & Blockers](#build-status--blockers)
4. [Feature Completeness Matrix](#feature-completeness-matrix)
5. [Critical Issues by Priority](#critical-issues-by-priority)
6. [Recommended Action Plan](#recommended-action-plan)
7. [Timeline to Production](#timeline-to-production)

---

## Executive Summary

**Fees Up is a 70% complete offline-first Flutter application** with a production-grade backend powered by **Supabase + PowerSync**. The core infrastructure is solid, but several critical user-facing features are incomplete, preventing full functional launch.

### What's Working ✅

- **Authentication**: Email/password + Google OAuth fully implemented
- **Real-time Sync**: PowerSync + Supabase integration handles offline-first architecture
- **School Management**: Create, link, and manage schools and profiles
- **Student Management**: Full CRUD with search functionality
- **Financial Core**: Dashboard shows live KPI metrics (balance, revenue, etc.)
- **Manual Transactions**: Payment and expense recording works end-to-end
- **UI/Responsive Design**: Material 3 dark theme, responsive mobile/desktop layouts
- **State Management**: Riverpod architecture well-structured and scalable

### What's Broken or Missing ❌

- **Mobile Transaction Screen**: Placeholder only, not functional
- **Auto-Billing Logic**: Student registration can't auto-generate bills
- **Invoice PDF Generation**: Button exists but no backend PDF logic
- **Reports Screen**: UI built but backend data fetching disconnected
- **Mobile App Features**: Limited to home/auth, missing screens
- **Settings Year Configuration**: UI read-only, no edit/save logic
- **Broadcast Permissions**: No role-based access control
- **Premium Guard**: Hardcoded `true`, monetization disabled

### Build Errors 🔴

- **Missing ResponsiveLayout**: Import path error in `app_router.dart`
- **No shared/layout directory**: Referenced but not created

---

## Current Architecture

### Tech Stack

```text
Frontend:       Flutter 3.5+ (Mobile + Desktop)
State Mgmt:     Riverpod 2.6+ (Provider pattern)
Navigation:     GoRouter 14.2+
Backend:        Supabase (PostgreSQL + Auth)
Offline Sync:   PowerSync 1.8+
Local DB:       SQLite (via sqflite)
Charts:         FL Chart
Styling:        Material 3 + Custom AppColors
```

### Directory Structure

```text
lib/
├── main.dart                      # App entry point
├── core/
│   ├── routes/app_router.dart     # Navigation (HAS ERRORS)
│   ├── theme/app_theme.dart       # Material 3 theme
│   ├── widgets/                   # Shared components
│   └── constants/app_colors.dart  # Design tokens
├── data/
│   ├── models/                    # 13 model files (Student, Finance, etc.)
│   ├── repositories/              # Data access layer
│   ├── providers/                 # Riverpod state providers
│   └── services/
│       ├── database_service.dart  # PowerSync wrapper
│       ├── supabase_connector.dart # Sync implementation
│       └── schema.dart            # Local SQLite schema
├── mobile/
│   ├── screens/                   # Mobile views (HOME + AUTH only)
│   └── widgets/dashboard/
├── pc/
│   ├── screens/                   # 10 desktop screens
│   │   ├── pc_home_screen.dart
│   │   ├── students_screen.dart
│   │   ├── invoices_screen.dart
│   │   ├── transactions_screen.dart
│   │   ├── reports_screen.dart
│   │   ├── settings_screen.dart
│   │   ├── announcements_screen.dart
│   │   ├── notifications_screen.dart
│   │   ├── profile_screen.dart
│   │   └── auth/
│   └── widgets/                   # Reusable PC components
└── shared/
    ├── layout/
    └── widgets/
```

### Data Flow

```text
UI Layer (Mobile/PC Screens)
    ↓
Riverpod Providers (State Management)
    ↓
Repository Layer (Business Logic)
    ↓
DatabaseService (PowerSync Interface)
    ↓
Local SQLite ↔ Supabase (Real-time Sync)
```

---

## Build Status & Blockers

### 🔴 **BLOCKING ISSUE #1: Missing ResponsiveLayout**

**Error Location:** [lib/core/routes/app_router.dart](lib/core/routes/app_router.dart#L16)

**Problem:**

```dart
import '../../../shared/layout/responsive_layout.dart';  // ❌ DOESN'T EXIST
```

The import path is wrong. The router expects a `ResponsiveLayout` widget that doesn't exist in the workspace.

**Current Impact:**

- Project won't compile
- Mobile and home routes fail to load

**Solution:**

Create the missing `shared/layout/responsive_layout.dart` file that bridges mobile/desktop views:

```dart
// lib/shared/layout/responsive_layout.dart
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileScaffold;
  final Widget pcScaffold;

  const ResponsiveLayout({
    required this.mobileScaffold,
    required this.pcScaffold,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width < 1024 ? mobileScaffold : pcScaffold;
  }
}
```

**Effort:** 5 minutes | **Priority:** CRITICAL

---

## Feature Completeness Matrix

| Feature | Mobile | Desktop | Status | Blocker |
|---------|--------|---------|--------|---------|
| **Auth (Email/Google)** | ✅ | ✅ | Complete | None |
| **School Creation** | ✅ | ✅ | Complete | None |
| **Dashboard/Home** | ✅ | ✅ | Complete | None |
| **Student CRUD** | ⚠️ Limited | ✅ | ~80% | Mobile UI missing |
| **Manual Payments** | ❌ | ✅ | ~50% | Mobile form missing |
| **Manual Expenses** | ❌ | ✅ | ~50% | Mobile form missing |
| **Invoices** | ❌ | ⚠️ Partial | ~40% | PDF generation missing |
| **Transactions (View)** | ❌ Placeholder | ✅ | ~60% | Mobile screen stub |
| **Reports** | ❌ | ⚠️ No Data | ~30% | Backend disconnected |
| **Settings** | ❌ | ⚠️ Read-only | ~50% | No save logic |
| **Broadcasts** | ❌ | ✅ UI Only | ~40% | No permissions check |
| **Notifications** | ⚠️ Basic | ✅ | ~70% | Limited features |

---

## Critical Issues by Priority

### 🔴 **P0: Build-Blocking Issues** (Must Fix Before Any Testing)

#### Issue 1: ResponsiveLayout Missing

- **File:** [lib/core/routes/app_router.dart](lib/core/routes/app_router.dart#L16)
- **Impact:** App won't compile
- **Fix Time:** 5 minutes
- **Action:** Create `shared/layout/responsive_layout.dart`

#### Issue 2: Database Service Initialization

- **File:** [lib/main.dart](lib/main.dart#L32)
- **Problem:** DatabaseService initialization might fail silently if PowerSync endpoint not set
- **Impact:** Sync won't work; user sees confusing errors
- **Fix:** Add better error handling and user feedback

---

### 🟠 **P1: Critical Functional Gaps** (Core App Broken)

#### Gap 1: Mobile Transaction Screen - Placeholder Only

- **File:** [lib/core/routes/app_router.dart](lib/core/routes/app_router.dart#L63-L66)
- **Current Code:**

  ```dart
  mobileScaffold: Scaffold(body: Center(child: Text("Mobile Transactions"))),
  ```

- **Impact:** Mobile users cannot view financial records
- **Prerequisite:** Need `lib/mobile/screens/mobile_transactions_screen.dart`
- **Complexity:** Medium (adapt desktop TransactionsScreen)
- **Est. Effort:** 4-6 hours
- **Note:** This is **customer-facing** - blocking mobile launch

#### Gap 2: Auto-Billing on Student Registration

- **File:** [lib/pc/widgets/dashboard/student_dialog.dart](lib/pc/widgets/dashboard/student_dialog.dart) (implied)
- **Problem:** `_attemptAutoBilling()` assumes `school_years` and `school_year_months` tables exist
- **Impact:** New students not billed automatically → manual invoice creation required
- **Root Cause:** Schema incomplete - no default billing cycle
- **Solution Options:**
  - A) Create default school year on school setup ✅ Recommended
  - B) Remove auto-billing; make it explicit manual action
  - C) Implement graceful fallback with quick-add billing
- **Est. Effort:** 2-3 hours

#### Gap 3: Mobile Students Screen

- **File:** Missing `lib/mobile/screens/mobile_students_screen.dart`
- **Impact:** Can't manage students from mobile
- **Est. Effort:** 3-4 hours

---

### 🟡 **P2: Feature Implementation Gaps** (App Functional But Incomplete)

#### Gap 4: Reports Backend Disconnected

- **File:** [lib/pc/screens/reports_screen.dart](lib/pc/screens/reports_screen.dart)
- **Status:** UI fully built, zero backend connections
- **Missing:**
  - Data fetching from `ReportsRepository`
  - "Generate Report" button logic
  - Chart data binding
- **Est. Effort:** 4-5 hours

#### Gap 5: Invoice PDF Generation

- **File:** [lib/pc/widgets/invoices/invoice_dialog.dart](lib/pc/widgets/invoices/invoice_dialog.dart) (implied)
- **Status:** Invoice creation works; PDF download button doesn't
- **Missing:** PDF generation logic (client-side or server call)
- **Options:**
  - Use `pdf` package for client-side generation
  - Call Supabase edge function for server-side
- **Est. Effort:** 3-4 hours

#### Gap 6: Settings Year Configuration - No Save Logic

- **File:** [lib/pc/widgets/settings/year_configuration_card.dart](lib/pc/widgets/settings/year_configuration_card.dart) (implied)
- **Status:** Forms are read-only mockups
- **Missing:**
  - State binding
  - Validation
  - Database writes
- **Est. Effort:** 2-3 hours

#### Gap 7: Premium Guard Always True

- **File:** [lib/core/widgets/premium_guard.dart](lib/core/widgets/premium_guard.dart#L7)
- **Current Code:**

  ```dart
  final isPremiumProvider = Provider<bool>((ref) => true);  // Hardcoded
  ```

- **Impact:** Monetization disabled; all features unlocked for free
- **Fix:** Read `subscription_tier` from `schools` table
- **Est. Effort:** 1-2 hours

#### Gap 8: Broadcast Role-Based Access

- **File:** [lib/pc/widgets/announcements/compose_broadcast_dialog.dart](lib/pc/widgets/announcements/compose_broadcast_dialog.dart) (implied)
- **Problem:** Any authenticated user can post school-wide broadcasts
- **Risk:** Potential abuse; no permission checks
- **Fix:** Add role check (only `school_admin` or higher)
- **Est. Effort:** 1 hour

---

### 🔵 **P3: Polish & Optimization** (App Works, UX Improvements Needed)

#### Polish 1: Form Dirty State Tracking

- **Issue:** Dialogs don't update `formDirtyProvider` when fields change
- **Consequence:** Tab switching won't warn about unsaved changes
- **Est. Effort:** 1-2 hours

#### Polish 2: Activity Log - Real Audit Trail

- **Status:** Currently hardcoded mock data
- **Need:** Real database-backed activity log
- **Est. Effort:** 3-4 hours

#### Polish 3: User Linking - Email Validation

- **Problem:** `addUserByEmail()` assumes user exists in Supabase auth
- **Risk:** Cryptic errors if email invalid
- **Fix:** Pre-validate email existence
- **Est. Effort:** 1 hour

---

## Recommended Action Plan

### **Phase 1: Fix Build Issues (Immediate - Jan 3-4)**

| Task | File | Est. Time | Priority |
|------|------|-----------|----------|
| Create ResponsiveLayout widget | `shared/layout/responsive_layout.dart` | 30 min | P0 |
| Improve DB init error handling | `lib/main.dart` | 45 min | P0 |
| Verify PowerSync endpoint setup | `lib/data/services/supabase_connector.dart` | 30 min | P0 |
| **Total Phase 1** | | **2 hours** | |

**Deliverable:** Project compiles and runs without errors.

---

### **Phase 2: Critical Mobile Screens (Jan 4-8)**

| Task | File | Est. Time | Priority |
|------|------|-----------|----------|
| Build Mobile Transactions Screen | `lib/mobile/screens/mobile_transactions_screen.dart` | 6 hours | P1 |
| Build Mobile Students Screen | `lib/mobile/screens/mobile_students_screen.dart` | 4 hours | P1 |
| Create default school year on setup | `DatabaseService.initialize()` | 2 hours | P1 |
| Fix auto-billing logic | `student_dialog.dart` | 2 hours | P1 |
| **Total Phase 2** | | **14 hours** | |

**Deliverable:** Mobile app fully functional (read/write access to students & transactions).

---

### **Phase 3: Feature Completions (Jan 8-15)**

| Task | File | Est. Time | Priority |
|------|------|-----------|----------|
| Wire Reports to backend | `lib/pc/screens/reports_screen.dart` | 5 hours | P2 |
| Implement Invoice PDF generation | `invoice_dialog.dart` | 4 hours | P2 |
| Add year configuration save logic | `year_configuration_card.dart` | 3 hours | P2 |
| Fix Premium Guard provider | `premium_guard.dart` | 2 hours | P2 |
| Add role-based broadcast control | `compose_broadcast_dialog.dart` | 1 hour | P2 |
| **Total Phase 3** | | **15 hours** | |

**Deliverable:** All features fully functional; no placeholder UI.

---

### **Phase 4: Polish & Testing (Jan 15-22)**

| Task | Est. Time | Priority |
|------|-----------|----------|
| Form dirty state tracking | 2 hours | P3 |
| Implement real audit log | 4 hours | P3 |
| Email validation on user linking | 1 hour | P3 |
| Search/autocomplete UX fixes | 2 hours | P3 |
| End-to-end testing & bug fixes | 8 hours | P3 |
| **Total Phase 4** | **17 hours** | |

**Deliverable:** Production-ready app; ready for beta launch.

---

## Timeline to Production

```text
CURRENT STATE (Jan 3):  Build broken, 70% feature complete
                        ⚠️ Cannot run app

PHASE 1 (Jan 3-4):      Build fixes
                        ✅ App compiles & runs

PHASE 2 (Jan 4-9):      Mobile screens + core fixes
                        ✅ All CRUD operations work mobile & desktop

PHASE 3 (Jan 9-16):     Feature completions
                        ✅ No placeholder UI anywhere

PHASE 4 (Jan 16-23):    Polish & testing
                        ✅ Production-ready

LAUNCH DATE:            Feb 1, 2026 (4 weeks)
```

### **Total Development Effort**

- **Phase 1-2 (Build + Critical):** 16 hours (2-3 days with 8h/day sprints)
- **Phase 3-4 (Features + Polish):** 32 hours (4-5 days)
- **Total:** ~48 hours (~1 week with focused effort)

---

## Detailed Next Steps (Immediate Actions)

### **Step 1: Create ResponsiveLayout (Do First)**

Create [lib/shared/layout/responsive_layout.dart](lib/shared/layout/responsive_layout.dart):

```dart
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget mobileScaffold;
  final Widget pcScaffold;

  const ResponsiveLayout({
    required this.mobileScaffold,
    required this.pcScaffold,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    // Desktop breakpoint: 1024px
    return width < 1024 ? mobileScaffold : pcScaffold;
  }
}
```

Then update import in [lib/core/routes/app_router.dart](lib/core/routes/app_router.dart#L16):

```dart
import '../../shared/layout/responsive_layout.dart';  // ✅ Correct path
```

### **Step 2: Test Build**

Run: `make run` (or `flutter run -d linux`)

Expected output: App launches without import errors.

### **Step 3: Create Mobile Transactions Screen**

Create [lib/mobile/screens/mobile_transactions_screen.dart](lib/mobile/screens/mobile_transactions_screen.dart) by adapting [lib/pc/screens/transactions_screen.dart](lib/pc/screens/transactions_screen.dart) with responsive adjustments.

### **Step 4: Wire Reports**

Update [lib/pc/screens/reports_screen.dart](lib/pc/screens/reports_screen.dart) to call `ReportsRepository.fetchFinancialSummary()` instead of placeholder data.

---

## Dependencies & Prerequisites

### What You Need in Supabase

- ✅ `schools` table with `subscription_tier` column
- ✅ `school_years` and `school_year_months` tables (or auto-create in backend)
- ✅ `students`, `bills`, `payments`, `expenses` tables
- ✅ RLS policies for school isolation
- ⚠️ `reports` view or endpoint (planned for Phase 3)
- ⚠️ PDF generation service (planned for Phase 3)

### Flutter Packages Already Added

- ✅ `flutter_riverpod` for state management
- ✅ `powersync` for offline sync
- ✅ `go_router` for navigation
- ✅ `supabase_flutter` for backend
- ⚠️ `pdf` for PDF generation (added, but not used yet)

---

## FAQ & Troubleshooting

**Q: Why is the app 70% complete if so many features are missing?**

A: Core infrastructure (auth, sync, CRUD) works perfectly. The 30% gap is feature-specific screens and polish, not foundational issues.

**Q: Can we launch with placeholder screens?**

A: Not for production. Placeholder screens break user trust and violate SaaS best practices. All screens must be functional.

**Q: What's the minimum viable product (MVP)?**

A: School admin can:

1. Create/link school
2. Add students (auto-billed)
3. Record payments/expenses
4. View dashboard KPIs
5. Generate invoices

That's ~60% of current work. Remaining 40% is "nice-to-have" (reports, broadcasts, etc.).

**Q: Should we prioritize mobile or desktop first?**

A: Desktop first (80% done). Mobile should follow (currently 20% done). Mobile is customer-facing and revenue-critical.

**Q: Can we defer Reports & PDF to v1.1?**

A: Yes. They're P2 (not P0/P1). More critical to have working mobile & auto-billing first.

---

## Success Metrics

### By Feb 1, 2026

- ✅ App compiles without errors
- ✅ All screens functional (no placeholders)
- ✅ Mobile & desktop feature parity for core features
- ✅ 100% CRUD operations tested
- ✅ Offline sync tested across scenarios
- ✅ 10+ beta users can manage schools without support

### By Feb 15, 2026 (Post-Beta)

- ✅ Stripe subscription integration active
- ✅ Hard limits enforced (max students per plan)
- ✅ Audit logs recording all actions
- ✅ SLA uptime 99.5%+

---

## Appendix: File Reference

### Critical Files to Fix

- [lib/core/routes/app_router.dart](lib/core/routes/app_router.dart) - Fix import, add ResponsiveLayout
- [lib/main.dart](lib/main.dart) - Improve error handling
- [lib/pc/screens/reports_screen.dart](lib/pc/screens/reports_screen.dart) - Wire backend
- [lib/core/widgets/premium_guard.dart](lib/core/widgets/premium_guard.dart) - Real provider

### Key Implementation Files

- [lib/data/services/database_service.dart](lib/data/services/database_service.dart) - Core sync logic
- [lib/data/repositories/](lib/data/repositories/) - Data access layer
- [lib/data/providers/](lib/data/providers/) - Riverpod state management
- [lib/pc/screens/](lib/pc/screens/) - Desktop UI
- [lib/mobile/screens/](lib/mobile/screens/) - Mobile UI

### Well-Structured Examples

- [lib/pc/screens/students_screen.dart](lib/pc/screens/students_screen.dart) - Follow this pattern
- [lib/pc/screens/invoices_screen.dart](lib/pc/screens/invoices_screen.dart) - Dialog patterns
- [lib/mobile/screens/mobile_home_screen.dart](lib/mobile/screens/mobile_home_screen.dart) - Mobile patterns

---

## Document Metadata

- **Created:** January 3, 2026
- **Last Updated:** January 3, 2026
- **Status:** Ready for Implementation
- **Approval:** Awaiting Nyasha Gabriel
- **Version:** 1.0

---

**For questions or clarifications, refer to the code comments and test the app after each phase.**

**Next: Fix ResponsiveLayout, then run `make run` to verify build. 🚀**
