# Fees Up: Component Repository Quick Reference

**Date:** January 6, 2026  
**Version:** 1.0 - Complete Inventory  
**Total Components:** 100+ widgets across 10 screens

---

## 📚 Repository Documents

| Document | Purpose | Size | Coverage |
|----------|---------|------|----------|
| **WIDGETS_SCREENS_REPOSITORY.md** | Complete component catalog with details | ~3,000 lines | All 67 widget files, 10 screens |
| **DEPENDENCY_WIRING_GUIDE.md** | Provider chains, state patterns, flows | ~2,500 lines | Wiring diagrams, lifecycle flows, anti-patterns |
| **QUICK_REFERENCE.md** (this file) | Fast lookup, import statements, patterns | ~800 lines | Common imports, quick answers |

---

## 🎯 Quick Lookup by Feature

### 📊 Dashboard Features

**Files to Import:**
```dart
import 'package:fees_up/pc/screens/pc_home_screen.dart';
import 'package:fees_up/pc/widgets/sidebar.dart';
import 'package:fees_up/pc/widgets/dashboard/kpi_section.dart';
import 'package:fees_up/pc/widgets/dashboard/revenue_chart.dart';
import 'package:fees_up/pc/widgets/dashboard/quick_actions_grid.dart';
import 'package:fees_up/pc/widgets/dashboard/stat_cards.dart';
import 'package:fees_up/pc/widgets/dashboard/recent_payments_section.dart';
```

**Key Widgets:**
- `KpiSection` — Shows Revenue, Outstanding, Collected metrics
- `RevenueChart` — Time-series financial visualization
- `QuickActionsGrid` — "Record Payment", "New Invoice" buttons
- `StatCard` — Generic metric display (reusable)

**Dialogs:**
- `PaymentDialog` — Record ad-hoc payment
- `CampaignDialog` — Create fundraising campaign
- `ExpenseDialog` — Record expense
- `StudentDialog` — Enroll new student

---

### 👥 Student Management

**Files to Import:**
```dart
import 'package:fees_up/pc/screens/students_screen.dart';
import 'package:fees_up/pc/screens/student_details_screen.dart';
import 'package:fees_up/pc/widgets/students/students_table.dart';
import 'package:fees_up/pc/widgets/students/students_header.dart';
import 'package:fees_up/pc/widgets/students/students_stats.dart';
import 'package:fees_up/pc/widgets/students/quick_payment_dialog.dart';
import 'package:fees_up/pc/widgets/students/edit_student_dialog.dart';
```

**Key Widgets:**
- `StudentsTable` — Main roster with sorting/filtering
- `StudentsHeader` — Search, grade filter, class filter
- `StudentsStats` — KPI cards (Total, Active, Pending)
- `StudentViewerSidebar` — Quick student preview

**Dialogs:**
- `QuickPaymentDialog` — **⚠️ CRITICAL: Direct DB access**
- `EditStudentDialog` — Modify student info
- `StudentBillsDialog` — View outstanding bills
- `FinancialLedgerDialog` — Payment history

**Filter Providers:**
```dart
studentGradeFilterProvider        // StateProvider<String>
studentClassFilterProvider        // StateProvider<String>
studentStatusFilterProvider       // StateProvider<String>
studentSearchFilterProvider       // StateProvider<String>
filteredStudentsProvider(schoolId) // ComputedProvider using above
```

---

### 💳 Transactions & Payments

**Files to Import:**
```dart
import 'package:fees_up/pc/screens/transactions_screen.dart';
import 'package:fees_up/pc/widgets/transactions/transactions_table.dart';
import 'package:fees_up/pc/widgets/transactions/transactions_header.dart';
import 'package:fees_up/pc/widgets/transactions/transactions_kpi_cards.dart';
import 'package:fees_up/pc/widgets/transactions/universal_entry_dialog.dart';
import 'package:fees_up/pc/widgets/transactions/payment_allocation_dialog.dart';
```

**Key Widgets:**
- `TransactionsTable` — Payment/Expense ledger
- `TransactionsHeader` — Filter controls, export
- `TransactionsKpiCards` — Summary metrics
- `UniversalTransactionDialog` — Multi-type transaction entry ⭐ Future hub

**Dialogs:**
- `UniversalTransactionDialog` — Create Payment/Expense/Adjustment
- `PaymentAllocationDialog` — Assign payment to bills

---

### 📄 Invoices

**Files to Import:**
```dart
import 'package:fees_up/pc/screens/invoices_screen.dart';
import 'package:fees_up/pc/widgets/invoices/invoices_table.dart';
import 'package:fees_up/pc/widgets/invoices/invoices_header.dart';
import 'package:fees_up/pc/widgets/invoices/invoices_stats.dart';
import 'package:fees_up/pc/widgets/invoices/invoice_dialog.dart';
import 'package:fees_up/pc/widgets/invoices/payment_allocations_dialog.dart';
```

**Key Widgets:**
- `InvoicesTable` — Invoice list with status, due dates
- `InvoicesStats` — KPI cards (Total, Paid, Outstanding, Overdue)
- `InvoiceDialog` — Create/Edit invoice with line items
- `PaymentAllocationsDialog` — Reconcile payments

---

### 📢 Announcements/Broadcasts

**Files to Import:**
```dart
import 'package:fees_up/pc/screens/announcements_screen.dart';
import 'package:fees_up/pc/widgets/announcements/broadcast_list.dart';
import 'package:fees_up/pc/widgets/announcements/broadcast_kpi_cards.dart';
import 'package:fees_up/pc/widgets/announcements/compose_broadcast_dialog.dart';
```

**Key Widgets:**
- `BroadcastList` — ⭐ **"Fortress Stream"** pattern (exemplary)
- `BroadcastKpiCards` — ⭐ **"Aggregated Context"** pattern (exemplary)
- `ComposeBroadcastDialog` — **⚠️ Monolithic form**, needs refactoring

**Providers:**
```dart
schoolBroadcastProvider          // School-level announcements
internalHQBroadcastProvider      // Global HQ alerts (system messages)
broadcastLogicProvider           // Service for post/update/delete
```

**Pattern:** Dynamic rewiring based on `_filter` state
```dart
final feedAsync = (_filter == 'Internal')
  ? ref.watch(internalHQBroadcastProvider)
  : ref.watch(schoolBroadcastProvider);
```

---

### ⚙️ Settings

**Files to Import:**
```dart
import 'package:fees_up/pc/screens/settings_screen.dart';
import 'package:fees_up/pc/widgets/settings/school_year_settings_view.dart';
import 'package:fees_up/pc/widgets/settings/notifications_settings_view.dart';
import 'package:fees_up/pc/widgets/settings/users_permissions_view.dart';
import 'package:fees_up/pc/widgets/settings/integrations_settings_view.dart';
import 'package:fees_up/pc/widgets/settings/audit_trail_view.dart';
```

**Main Views:**
- `SchoolYearSettingsView` — Academic calendar setup
- `NotificationsSettingsView` — Email/SMS delivery channels
- `UsersPermissionsView` — Team management
- `IntegrationsSettingsView` — API keys, webhooks
- `AuditTrailView` — Log viewer
- `GeneralFinancialView` — Accounting rules

**Settings Cards:**
- `YearConfigurationCard` — Multi-year setup
- `BillingConfigCard` — Invoice templates
- `OrganizationCard` — School details

**Dialogs:**
- `BillingPeriodDialog` — Invoice schedule
- `AddUserDialog` — Invite team member

---

### 📊 Reports

**Files to Import:**
```dart
import 'package:fees_up/pc/screens/reports_screen.dart';
import 'package:fees_up/pc/widgets/reports/financial_summary_cards.dart';
import 'package:fees_up/pc/widgets/reports/custom_report_builder.dart';
import 'package:fees_up/pc/widgets/reports/reports_header.dart';
```

**Key Widgets:**
- `FinancialSummaryCards` — Preset report cards
- `CustomReportBuilderWidget` — Query builder
- `ReportsHeader` — Category filter tabs

---

### 👤 Profile

**Files to Import:**
```dart
import 'package:fees_up/pc/screens/profile_screen.dart';
import 'package:fees_up/pc/widgets/profile/profile_header_card.dart';
import 'package:fees_up/pc/widgets/profile/personal_info_form.dart';
import 'package:fees_up/pc/widgets/profile/account_security_card.dart';
import 'package:fees_up/pc/widgets/profile/role_permissions_view.dart';
```

**Tabs:**
1. Personal Info → `PersonalInfoForm`
2. Account Security → `AccountSecurityCard`, `SecurityPasswordView`
3. Permissions → `RolePermissionsView`
4. Activity Log → `ActivityLogView`

---

### 🔔 Notifications

**Files to Import:**
```dart
import 'package:fees_up/pc/screens/notifications_screen.dart';
import 'package:fees_up/pc/widgets/notifications/notifications_list.dart';
import 'package:fees_up/pc/widgets/notifications/notifications_kpi_cards.dart';
```

---

## 🔄 State Management Quick Ref

### When to Use Each Pattern

| Pattern | Use Case | Example |
|---------|----------|---------|
| **ConsumerWidget** | Pure reactive, no local state | `KpiSection`, `RevenueChart`, `BroadcastKpiCards` |
| **ConsumerStatefulWidget** | Reactive + ephemeral state | `StudentsTable`, `BroadcastList`, form dialogs |
| **StatefulWidget** | Ephemeral state only | `DashboardSidebar`, `LogoutDialog` |
| **StatelessWidget** | Pure presentation | `StatCard`, `DashboardHeader`, `_PaymentRow` |

### Provider Patterns

| Pattern | Syntax | Best For |
|---------|--------|----------|
| **StateProvider** | `StateProvider<T>` | Simple toggle/selection state |
| **AsyncProvider** | `AsyncProvider<T>` | Async operations (network, DB) |
| **StreamProvider** | `StreamProvider<T>` | Real-time updates |
| **FutureProvider** | `FutureProvider<T>` | One-time async fetch |
| **Provider.family** | `Provider.family<T, P>` | Scoped data (e.g., by studentId) |
| **StateNotifierProvider** | `StateNotifierProvider<N, T>` | Complex state logic with methods |

---

## 🚀 Import Cheat Sheet

### Most Common Imports

```dart
// Screens
import 'package:fees_up/pc/screens/pc_home_screen.dart';
import 'package:fees_up/pc/screens/students_screen.dart';
import 'package:fees_up/pc/screens/transactions_screen.dart';
import 'package:fees_up/pc/screens/invoices_screen.dart';
import 'package:fees_up/pc/screens/settings_screen.dart';

// Shared Widgets
import 'package:fees_up/pc/widgets/sidebar.dart';
import 'package:fees_up/pc/widgets/logout_dialog.dart';

// Dashboard
import 'package:fees_up/pc/widgets/dashboard/kpi_section.dart';
import 'package:fees_up/pc/widgets/dashboard/revenue_chart.dart';
import 'package:fees_up/pc/widgets/dashboard/stat_cards.dart';
import 'package:fees_up/pc/widgets/dashboard/payment_dialog.dart';

// Students
import 'package:fees_up/pc/widgets/students/students_table.dart';
import 'package:fees_up/pc/widgets/students/quick_payment_dialog.dart';

// Transactions
import 'package:fees_up/pc/widgets/transactions/transactions_table.dart';
import 'package:fees_up/pc/widgets/transactions/universal_entry_dialog.dart';

// Invoices
import 'package:fees_up/pc/widgets/invoices/invoices_table.dart';
import 'package:fees_up/pc/widgets/invoices/invoice_dialog.dart';

// Announcements
import 'package:fees_up/pc/widgets/announcements/broadcast_list.dart';
import 'package:fees_up/pc/widgets/announcements/compose_broadcast_dialog.dart';
```

---

## 🎨 Architecture Patterns Used

### ✅ Exemplary Patterns

1. **Fortress Stream** (BroadcastList)
   - Dynamic provider rewiring based on filter state
   - Automatic subscription lifecycle management
   
2. **Aggregated Context** (BroadcastKpiCards)
   - Multiple independent data sources
   - Per-source error isolation
   - No single point of failure

3. **Container/Presentational** (StatCard usage)
   - Parent fetches data
   - Child only renders
   - Zero coupling to data source

4. **Repository Abstraction** (Payment, Invoice repos)
   - SQL encapsulated in repositories
   - UI layer has no database knowledge
   - Testable with mocks

### ⚠️ Anti-Patterns (To Fix)

1. **Direct Database Access** (QuickPaymentDialog)
   - Bypasses Riverpod framework
   - Manual subscription lifecycle
   - Memory leak risks
   - **Priority: P0 Refactor**

2. **Monolithic Form Dialogs** (ComposeBroadcastDialog)
   - Validation + state + submission tightly coupled
   - Difficult to test
   - Cannot reuse for "Edit" mode
   - **Priority: P1 Refactor**

3. **Stringly Typed Logic** (BroadcastList filters)
   - String literals for logic branching
   - Compile-time errors not caught
   - **Priority: P2 Refactor**

4. **Filter Provider Cascade** (StudentsTable)
   - Multiple separate filter providers
   - Sequential updates = multiple rebuilds
   - **Priority: P2 Refactor**

---

## 📋 File Organization

```
lib/pc/
├── screens/          (10 screen files)
│   ├── pc_home_screen.dart
│   ├── students_screen.dart
│   ├── student_details_screen.dart
│   ├── transactions_screen.dart
│   ├── invoices_screen.dart
│   ├── settings_screen.dart
│   ├── profile_screen.dart
│   ├── announcements_screen.dart
│   ├── reports_screen.dart
│   └── notifications_screen.dart
│
└── widgets/          (67 widget files)
    ├── sidebar.dart
    ├── logout_dialog.dart
    ├── dashboard/     (12 files)
    ├── students/      (8 files)
    ├── transactions/  (6 files)
    ├── invoices/      (7 files)
    ├── settings/      (15 files)
    │   └── integrations/ (4 files)
    ├── profile/       (7 files)
    ├── announcements/ (3 files)
    ├── notifications/ (2 files)
    └── reports/       (5 files)
```

---

## 🔍 Finding Components

### By Feature

| Feature | File | Screen |
|---------|------|--------|
| Dashboard metrics | `dashboard/kpi_section.dart` | PCHomeScreen |
| Revenue visualization | `dashboard/revenue_chart.dart` | PCHomeScreen |
| Student table | `students/students_table.dart` | StudentsScreen |
| Quick payment | `students/quick_payment_dialog.dart` | StudentsScreen |
| Invoice creation | `invoices/invoice_dialog.dart` | InvoicesScreen |
| Announcements feed | `announcements/broadcast_list.dart` | AnnouncementsScreen |
| Settings tabs | `settings/*_settings_view.dart` | SettingsScreen |
| User profile | `profile/*.dart` | ProfileScreen |
| Financial reports | `reports/financial_summary_cards.dart` | ReportsScreen |

### By State Type

| Type | Count | Examples |
|------|-------|----------|
| Stateless | ~30 | StatCard, DashboardHeader, _PaymentRow |
| StatefulWidget | ~15 | DashboardSidebar, LogoutDialog |
| ConsumerWidget | ~25 | KpiSection, RevenueChart |
| ConsumerStatefulWidget | ~30 | StudentsTable, BroadcastList |

---

## 🚨 Critical Issues Tracker

| Issue | Location | Severity | Status |
|-------|----------|----------|--------|
| Direct DB access in QuickPaymentDialog | `students/quick_payment_dialog.dart` | 🔴 P0 | Documented |
| Monolithic form in ComposeBroadcastDialog | `announcements/compose_broadcast_dialog.dart` | 🟡 P1 | Documented |
| Stringly typed filter logic | `announcements/broadcast_list.dart` | 🟡 P1 | Documented |
| Filter provider cascade | `students/students_table.dart` | 🟡 P2 | Documented |

---

## 📞 Quick Reference Commands

```bash
# Find all widgets in a category
find lib/pc/widgets/dashboard -name "*.dart"

# Search for provider usage
grep -r "ref.watch" lib/pc/widgets/

# Find all dialogs
find lib/pc/widgets -name "*dialog.dart"

# Count widgets by type
grep -r "class.*extends ConsumerWidget" lib/pc/widgets/ | wc -l
```

---

## 📚 Related Documentation

- **WIDGETS_SCREENS_REPOSITORY.md** — Complete catalog
- **DEPENDENCY_WIRING_GUIDE.md** — Provider chains & flows
- **ARCHITECTURAL_AUDIT_OPTIMIZATION_REPORT.md** — Overall analysis
- **BILLING_ENGINE_DOCUMENTATION.md** — Payment subsystem
- **BILLING_WIRING_IMPLEMENTATION_SUMMARY.md** — Transaction flows

---

**Last Updated:** January 6, 2026  
**Maintenance:** Architecture Team  
**Status:** ✅ Complete & Current

