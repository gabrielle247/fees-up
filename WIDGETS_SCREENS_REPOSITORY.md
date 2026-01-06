# Fees Up: Comprehensive Widgets & Screens Repository

**Last Updated:** January 6, 2026  
**Status:** Complete Architectural Inventory  
**Total Components:** 100+ widgets, 10 screens

---

## Table of Contents

1. [Screens Overview](#screens-overview)
2. [Widgets by Category](#widgets-by-category)
3. [Dependency Graph](#dependency-graph)
4. [Component Relationship Matrix](#component-relationship-matrix)
5. [Provider Wiring](#provider-wiring)
6. [State Management Patterns](#state-management-patterns)

---

## Screens Overview

### Desktop Screens (`lib/pc/screens/`)

| Screen | Class | Widget Type | Purpose | Key Widgets |
|--------|-------|-------------|---------|------------|
| **Home/Dashboard** | `PCHomeScreen` | `ConsumerWidget` | Main application dashboard | DashboardSidebar, KpiSection, RevenueChart, QuickActionsGrid, RecentPaymentsSection |
| **Announcements** | `AnnouncementsScreen` | `StatelessWidget` | Internal & HQ broadcast feed | BroadcastList, BroadcastKpiCards, ComposeBroadcastDialog |
| **Students** | `StudentsScreen` | `ConsumerWidget` | Student management table | StudentsTable, StudentsHeader, StudentsStats, QuickPaymentDialog |
| **Student Details** | `StudentDetailsScreen` | `ConsumerWidget` | Individual student profile & financial ledger | StudentViewerSidebar, StudentBillsDialog, FinancialLedgerDialog |
| **Transactions** | `TransactionsScreen` | `ConsumerWidget` | Payment/expense records | TransactionsTable, TransactionsHeader, TransactionsKpiCards, UniversalTransactionDialog |
| **Invoices** | `InvoicesScreen` | `ConsumerWidget` | Invoice management | InvoicesTable, InvoicesHeader, InvoicesStats, InvoiceDialog |
| **Reports** | `ReportsScreen` | `ConsumerWidget` | Financial analytics & custom reports | FinancialSummaryCards, CustomReportBuilderWidget, ReportsHeader |
| **Notifications** | `NotificationsScreen` | `ConsumerWidget` | Notification center | NotificationsList, NotificationsKpiCards |
| **Profile** | `ProfileScreen` | `StatefulWidget` | User settings & security | ProfileHeaderCard, PersonalInfoForm, AccountSecurityCard, RolePermissionsView, ActivityLogView |
| **Settings** | `SettingsScreen` | `ConsumerStatefulWidget` | Application configuration | SchoolYearSettingsView, NotificationsSettingsView, UsersPermissionsView, IntegrationsSettingsView, AuditTrailView, GeneralFinancialView |

---

## Widgets by Category

### 📊 Dashboard Widgets (`lib/pc/widgets/dashboard/`)

**Purpose:** Core dashboard components and KPI displays

| Widget | Class | Type | State | Purpose |
|--------|-------|------|-------|---------|
| **KPI Section** | `KpiSection` | `ConsumerWidget` | ✓ Reactive | Aggregated performance metrics (Revenue, Outstanding, Collected) |
| **Revenue Chart** | `RevenueChart` | `ConsumerWidget` | ✓ Reactive | Time-series financial visualization (bar/line chart) |
| **Stat Cards** | `StatCard` | `StatelessWidget` | ✗ Stateless | Generic metric display (title, value, icon, color) |
| **Alert Badge** | `AlertBadge` | `StatelessWidget` | ✗ Stateless | Status indicator (Critical, Warning, Info) |
| **Dashboard Header** | `DashboardHeader` | `StatelessWidget` | ✗ Stateless | Page title & navigation controls |
| **Dashboard Top Bar** | `DashboardTopBar` | `StatelessWidget` | ✗ Stateless | Global toolbar (search, filters, time range) |
| **Recent Payments** | `RecentPaymentsSection` | `StatelessWidget` | ✗ Stateless | Payment history list view |
| **Payment Row** | `_PaymentRow` | `StatelessWidget` | ✗ Stateless | Individual payment record in list |
| **Quick Actions Grid** | `QuickActionsGrid` | `StatelessWidget` | ✗ Stateless | Action buttons (New Payment, New Invoice, etc.) |
| **Quick Action Item** | `QuickActionItem` | Class | ✗ Data Model | Action metadata (label, icon, route) |
| **No School Overlay** | `NoSchoolOverlay` | `StatelessWidget` | ✗ Stateless | Fallback UI when school not initialized |
| **Screen Size Error** | `ScreenSizeError` | `StatelessWidget` | ✗ Stateless | Responsive design constraint warning |

**Dialog Components:**

| Dialog | Class | Type | Purpose | Fields |
|--------|-------|------|---------|--------|
| **Payment Dialog** | `PaymentDialog` | `ConsumerStatefulWidget` | Record ad-hoc student payment | Amount, Student Selector, Payment Method, Description |
| **Student Dialog** | `StudentDialog` | `ConsumerStatefulWidget` | Enroll new student | Name, Class, Contact, Guardian Info |
| **Campaign Dialog** | `CampaignDialog` | `ConsumerStatefulWidget` | Create fundraising campaign | Title, Target Amount, Duration, Description |
| **Expense Dialog** | `ExpenseDialog` | `ConsumerStatefulWidget` | Record expense with dashed-border UI | Category, Amount, Vendor, Attachments |

---

### 📢 Announcements/Broadcasts Widgets (`lib/pc/widgets/announcements/`)

**Pattern:** "Fortress Stream" - Dynamic provider rewiring based on filter state

| Widget | Class | Type | State | Purpose |
|--------|-------|------|-------|---------|
| **Broadcast List** | `BroadcastList` | `ConsumerStatefulWidget` | ✓ Local + Reactive | Main feed with "All/Internal/System" filter switching |
| **Broadcast KPI Cards** | `BroadcastKpiCards` | `ConsumerWidget` | ✓ Reactive (Multi-source) | Aggregated context: School + HQ alerts |
| **Compose Dialog** | `ComposeBroadcastDialog` | `ConsumerStatefulWidget` | ✓ Form State + Reactive | Create new announcement |

**Wiring Details:**
- `BroadcastList` watches `schoolBroadcastProvider` OR `internalHQBroadcastProvider` based on `_filter` state
- `BroadcastKpiCards` watches BOTH providers simultaneously
- Form submission uses `ref.read(broadcastLogicProvider).post()`

---

### 📚 Students Widgets (`lib/pc/widgets/students/`)

| Widget | Class | Type | State | Purpose |
|--------|-------|------|-------|---------|
| **Students Table** | `StudentsTable` | `ConsumerStatefulWidget` | ✓ Reactive + Filters | Main student roster with sorting/filtering |
| **Students Header** | `StudentsHeader` | `ConsumerStatefulWidget` | ✓ Local State | Search bar, filter controls, action buttons |
| **Students Stats** | `StudentsStats` | `ConsumerWidget` | ✓ Reactive | KPI cards (Total Students, Active, Pending) |
| **Stat Card** | `_StatCard` | `StatelessWidget` | ✗ Stateless | Generic metric display for student stats |
| **Student Viewer Sidebar** | `StudentViewerSidebar` | `ConsumerWidget` | ✓ Reactive | Quick student profile preview in details screen |
| **Edit Student Dialog** | `EditStudentDialog` | `ConsumerStatefulWidget` | ✓ Form State | Modify student information |
| **Quick Payment Dialog** | `QuickPaymentDialog` | `ConsumerStatefulWidget` | ✓ Form State + Direct DB | **⚠️ CRITICAL ISSUE** - Direct `_dbService.db.watch()` usage |
| **Student Bills Dialog** | `StudentBillsDialog` | `ConsumerWidget` | ✓ Reactive | View outstanding bills for a student |
| **Financial Ledger Dialog** | `FinancialLedgerDialog` | `ConsumerStatefulWidget` | ✓ Reactive | Detailed payment history & reconciliation |

**Filter State Providers:**
- `studentGradeFilterProvider`
- `studentClassFilterProvider`
- `studentStatusFilterProvider`
- `studentSearchFilterProvider`

---

### 💳 Transactions Widgets (`lib/pc/widgets/transactions/`)

| Widget | Class | Type | State | Purpose |
|--------|-------|------|-------|---------|
| **Transactions Table** | `TransactionsTable` | `ConsumerStatefulWidget` | ✓ Reactive | Payment/Expense ledger with inline actions |
| **Transaction Row** | `_TransactionRowFromMap` | `StatelessWidget` | ✗ Stateless | Individual transaction record |
| **Transactions Header** | `TransactionsHeader` | `ConsumerWidget` | ✓ Reactive | Filter controls, export options |
| **Transactions KPI Cards** | `TransactionsKpiCards` | `ConsumerWidget` | ✓ Reactive | Summary metrics (Total, Pending, etc.) |
| **Universal Entry Dialog** | `UniversalTransactionDialog` | `ConsumerStatefulWidget` | ✓ Form State | Multi-type transaction entry (payment, expense, adjustment) |
| **Payment Allocation Dialog** | `PaymentAllocationDialog` | `ConsumerStatefulWidget` | ✓ Form State + Reactive | Assign payment to specific bill(s) |

---

### 📄 Invoices Widgets (`lib/pc/widgets/invoices/`)

| Widget | Class | Type | State | Purpose |
|--------|-------|------|-------|---------|
| **Invoices Table** | `InvoicesTable` | `ConsumerStatefulWidget` | ✓ Reactive | Invoice list with status, due dates |
| **Invoices Header** | `InvoicesHeader` | `ConsumerWidget` | ✓ Reactive | Filter by status, date range, student |
| **Invoices Stats** | `InvoicesStats` | `ConsumerWidget` | ✓ Reactive | KPI cards (Total, Paid, Outstanding, Overdue) |
| **Stat Card** | `_StatCard` | `StatelessWidget` | ✗ Stateless | Invoice metric display |
| **Create Invoice Card** | `_CreateInvoiceCard` | `ConsumerWidget` | ✓ Reactive | Quick-action card to initiate new invoice |
| **Invoice Dialog** | `InvoiceDialog` | `ConsumerStatefulWidget` | ✓ Form State + Reactive | Create/Edit invoice with line items |
| **Payment Allocations Dialog** | `PaymentAllocationsDialog` | `ConsumerStatefulWidget` | ✓ Form State + Reactive | Reconcile payments against invoices |

---

### ⚙️ Settings Widgets (`lib/pc/widgets/settings/`)

**Primary Views:**

| View | Class | Type | State | Purpose |
|------|-------|------|-------|---------|
| **School Year Settings** | `SchoolYearSettingsView` | `ConsumerStatefulWidget` | ✓ Reactive | Define academic calendar & billing periods |
| **Notifications Settings** | `NotificationsSettingsView` | `ConsumerStatefulWidget` | ✓ Reactive + Local | Email/SMS delivery channels & rules |
| **Users & Permissions** | `UsersPermissionsView` | `ConsumerStatefulWidget` | ✓ Reactive | Role assignment, team management |
| **Integrations Settings** | `IntegrationsSettingsView` | `StatelessWidget` | ✗ Stateless | API keys, webhook configuration |
| **Audit Trail** | `AuditTrailView` | `ConsumerStatefulWidget` | ✓ Reactive | Log viewer with date/user filters |
| **General Financial** | `GeneralFinancialView` | `ConsumerWidget` | ✓ Reactive | Accounting rules, chart of accounts |

**Settings Cards:**

| Card | Class | Type | Purpose |
|------|-------|------|---------|
| **Year Configuration Card** | `YearConfigurationCard` | `ConsumerStatefulWidget` | Multi-year academic calendar setup |
| **School Year Registry Card** | `SchoolYearRegistryCard` | `ConsumerWidget` | Display registered academic years |
| **Organization Card** | `OrganizationCard` | `ConsumerStatefulWidget` | School name, logo, contact details |
| **Billing Config Card** | `BillingConfigCard` | `ConsumerStatefulWidget` | Invoice templates, payment terms |
| **Settings Header** | `SettingsHeader` | `ConsumerWidget` | Tab navigation, search functionality |

**Dialog Components:**

| Dialog | Class | Type | Purpose |
|--------|-------|------|---------|
| **Billing Period Dialog** | `BillingPeriodDialog` | `ConsumerStatefulWidget` | Define invoice generation schedule |
| **Add User Dialog** | `AddUserDialog` | `ConsumerStatefulWidget` | Invite team member with role selection |

**Integrations Sub-folder:**

| Component | Class | Type | Purpose |
|-----------|-------|------|---------|
| **API Config Card** | `ApiConfigCard` | `StatelessWidget` | Display API credentials & usage |
| **Connected Services** | `ConnectedServicesCard` | `StatelessWidget` | List active integrations (Stripe, etc.) |
| **Service Row** | `_ServiceRow` | `StatelessWidget` | Individual service status & disconnect action |
| **Teacher Tokens Card** | `TeacherTokensCard` | `StatelessWidget` | API token management for teachers |
| **Token Row** | `_TokenRow` | `StatelessWidget` | Individual token with revoke option |
| **Security Permissions** | `SecurityPermissionsCard` | `StatefulWidget` | OAuth scopes & API permissions matrix |

---

### 👤 Profile Widgets (`lib/pc/widgets/profile/`)

| Widget | Class | Type | State | Purpose |
|--------|-------|------|-------|---------|
| **Profile Header Card** | `ProfileHeaderCard` | `ConsumerWidget` | ✓ Reactive | User avatar, name, role badge |
| **Personal Info Form** | `PersonalInfoForm` | `ConsumerWidget` | ✓ Reactive | Edit name, email, phone, location |
| **Account Security Card** | `AccountSecurityCard` | `StatelessWidget` | ✗ Stateless | Password change, 2FA status |
| **Security Password View** | `SecurityPasswordView` | `StatelessWidget` | ✗ Stateless | Password strength meter, change form |
| **Role Permissions View** | `RolePermissionsView` | `StatelessWidget` | ✗ Stateless | Display current user permissions |
| **Activity Log View** | `ActivityLogView` | `StatelessWidget` | ✗ Stateless | Login history, action audit trail |
| **Enable 2FA Dialog** | `EnableTwoFactorDialog` | `StatefulWidget` | ✓ Local State | QR code display, TOTP setup |

---

### 📊 Reports Widgets (`lib/pc/widgets/reports/`)

| Widget | Class | Type | State | Purpose |
|--------|-------|------|-------|---------|
| **Financial Summary Cards** | `FinancialSummaryCards` | `ConsumerWidget` | ✓ Reactive | Revenue, Expenses, Net metrics |
| **Invoice Stats Card** | `_InvoiceStatsCard` | `StatelessWidget` | ✗ Stateless | Invoice-specific metrics |
| **Transaction Summary Card** | `_TransactionSummaryCard` | `StatelessWidget` | ✗ Stateless | Payment/Expense breakdown |
| **Quick Action Card** | `_QuickActionCard` | `StatelessWidget` | ✗ Stateless | Export, Schedule, Archive actions |
| **Custom Report Builder** | `CustomReportBuilderWidget` | `ConsumerWidget` | ✓ Reactive | Query builder for custom reports |
| **Builder Header** | `_BuilderHeader` | `StatelessWidget` | ✗ Stateless | Title, save/load controls |
| **Report Form Section** | `_ReportFormSection` | `StatelessWidget` | ✗ Stateless | Filter criteria input |
| **Report Summary Panel** | `_ReportSummaryPanel` | `ConsumerWidget` | ✓ Reactive | Preview & configuration |
| **Report Card** | `ReportCard` | `StatelessWidget` | ✗ Stateless | Saved report display in library |
| **Reports Header** | `ReportsHeader` | `ConsumerWidget` | ✓ Reactive | Category tabs, search, create button |
| **Report Preview Dialog** | `ReportPreviewDialog` | [TBD] | [TBD] | Display generated report |

---

### 🔔 Notifications Widgets (`lib/pc/widgets/notifications/`)

| Widget | Class | Type | State | Purpose |
|--------|-------|------|-------|---------|
| **Notifications List** | `NotificationsList` | `ConsumerStatefulWidget` | ✓ Local + Reactive | Paginated notification feed |
| **Vertical Divider** | `_VerticalDivider` | `StatelessWidget` | ✗ Stateless | Timeline separator |
| **Notifications KPI Cards** | `NotificationsKpiCards` | `ConsumerWidget` | ✓ Reactive | Unread count, critical alerts |

---

### 🔄 Shared/Global Widgets

| Widget | Path | Class | Type | Purpose |
|--------|------|-------|------|---------|
| **Dashboard Sidebar** | `sidebar.dart` | `DashboardSidebar` | `StatefulWidget` | Main navigation menu, active state tracking |
| **Sidebar Item** | `sidebar.dart` | `_SidebarItem` | `StatefulWidget` | Individual nav item with icon, label, hover state |
| **Logout Dialog** | `logout_dialog.dart` | `LogoutDialog` | `StatefulWidget` | Confirmation dialog for session termination |

---

## Dependency Graph

### Provider Chain (Simplified)

```
[Screens] 
  ↓
[Widget Layer]
  ├─→ [Riverpod Providers] (StateProvider, AsyncProvider, StreamProvider)
  │    └─→ [Database Service] (_dbService)
  │         └─→ [Supabase/Local DB]
  │
  └─→ [State Management Patterns]
       ├─ ConsumerWidget (watches providers)
       ├─ ConsumerStatefulWidget (watches + local state)
       └─ StatefulWidget (local state only)
```

### Critical Provider Dependencies

| Provider | Watched By | Purpose |
|----------|-----------|---------|
| `schoolBroadcastProvider` | BroadcastList, BroadcastKpiCards | School announcements feed |
| `internalHQBroadcastProvider` | BroadcastList, BroadcastKpiCards | HQ-wide alerts |
| `broadcastLogicProvider` | ComposeBroadcastDialog | Post/Update broadcasts |
| `filteredStudentsProvider` | StudentsTable, StudentsScreen | Student roster with filters |
| `studentGradeFilterProvider` | StudentsTable | Grade filter state |
| `studentClassFilterProvider` | StudentsTable | Class filter state |
| `studentStatusFilterProvider` | StudentsTable | Enrollment status filter |
| `dashboardDataProvider` | PCHomeScreen, KpiSection, RevenueChart | Dashboard metrics |
| `fundraisingProvider` | PCHomeScreen, CampaignDialog | Campaign data |
| `transactionStreamProvider` | TransactionsTable, TransactionsHeader | Payment/Expense ledger |

---

## Component Relationship Matrix

### Screen → Widget Relationships

```
PCHomeScreen (Home)
├── DashboardSidebar (navigation)
├── DashboardTopBar (header)
├── DashboardHeader (title)
├── KpiSection (metrics)
├── RevenueChart (visualization)
├── QuickActionsGrid (action buttons)
├── RecentPaymentsSection (quick list)
├── NoSchoolOverlay (conditional fallback)
└── [Various Dialogs for quick actions]

StudentsScreen
├── DashboardSidebar
├── StudentsHeader (filters + search)
├── StudentsStats (KPI cards)
└── StudentsTable (main data grid)
    └── QuickPaymentDialog
    └── EditStudentDialog

StudentDetailsScreen
├── DashboardSidebar
├── StudentViewerSidebar (profile preview)
├── StudentBillsDialog
└── FinancialLedgerDialog

TransactionsScreen
├── DashboardSidebar
├── TransactionsHeader
├── TransactionsKpiCards
└── TransactionsTable
    ├── UniversalTransactionDialog
    └── PaymentAllocationDialog

InvoicesScreen
├── DashboardSidebar
├── InvoicesHeader
├── InvoicesStats
└── InvoicesTable
    ├── InvoiceDialog
    └── PaymentAllocationsDialog

SettingsScreen
├── DashboardSidebar
├── SettingsHeader (tab navigation)
├── SchoolYearSettingsView
│   ├── YearConfigurationCard
│   └── SchoolYearRegistryCard
├── NotificationsSettingsView
│   └── [Notification group tiles]
├── UsersPermissionsView
│   └── [User rows + AddUserDialog]
├── IntegrationsSettingsView
│   ├── ApiConfigCard
│   ├── ConnectedServicesCard
│   ├── TeacherTokensCard
│   └── SecurityPermissionsCard
├── AuditTrailView
└── [Other views...]

ProfileScreen
├── ProfileHeaderCard
├── PersonalInfoForm
├── AccountSecurityCard
├── RolePermissionsView
├── ActivityLogView
└── EnableTwoFactorDialog

AnnouncementsScreen
├── DashboardSidebar
├── BroadcastKpiCards
├── BroadcastList
└── ComposeBroadcastDialog

ReportsScreen
├── DashboardSidebar
├── ReportsHeader
├── FinancialSummaryCards
├── CustomReportBuilderWidget
└── [Report cards list]

NotificationsScreen
├── DashboardSidebar
├── NotificationsHeader
├── NotificationsKpiCards
└── NotificationsList
```

---

## Provider Wiring

### Reactive (Watch-Based) Pattern

**Example: BroadcastList "Fortress Stream"**
```dart
// Dynamic rewiring based on filter state
final AsyncValue<List<Broadcast>> feedAsync = (_filter == 'Internal')
   ? ref.watch(internalHQBroadcastProvider)
   : ref.watch(schoolBroadcastProvider);
```

**Example: BroadcastKpiCards "Aggregated Context"**
```dart
final schoolFeedAsync = ref.watch(schoolBroadcastProvider);
final hqFeedAsync = ref.watch(internalHQBroadcastProvider);
// Handles both independently with error isolation
```

### Form/Dialog Pattern

**Example: ComposeBroadcastDialog**
```dart
// Problem: Direct read, no async state management
ref.read(broadcastLogicProvider).post(title, body, priority)
```

### ⚠️ Anti-Pattern: Direct Database Access

**Example: QuickPaymentDialog (CRITICAL ISSUE)**
```dart
// ⚠️ BYPASSES Riverpod entirely
_paymentSubscription = _dbService.db
   .watch('SELECT * FROM payments WHERE student_id = ?', parameters: [widget.studentId])
   .listen((payments) { ... });
```

---

## State Management Patterns

### Pattern Distribution

| Pattern | Count | Risk Level | Examples |
|---------|-------|-----------|----------|
| `ConsumerWidget` (pure reactive) | ~25 | ✅ Low | KpiSection, RevenueChart, BroadcastKpiCards |
| `ConsumerStatefulWidget` (reactive + ephemeral) | ~30 | ✅ Medium | BroadcastList, StudentsTable, TransactionsTable |
| `StatefulWidget` (ephemeral state only) | ~15 | ⚠️ Medium | DashboardSidebar, LogoutDialog, ProfileScreen |
| `StatelessWidget` (pure presentation) | ~30 | ✅ Low | StatCard, DashboardHeader, RecentPaymentsSection |

### State Pattern Categories

#### 1. **Optimal: Ephemeral State (Local)**
**Used For:** UI controls with no cross-widget impact
- Filter selections (`_filter` in BroadcastList)
- Form inputs before submission
- Collapse/Expand states

**Example:**
```dart
class BroadcastList extends ConsumerStatefulWidget {
  String _filter = 'All'; // ✅ Correct: Local, ephemeral
}
```

#### 2. **Optimal: Reactive State (Providers)**
**Used For:** Data shared across widgets
- Student roster
- Payment ledger
- KPI calculations

**Example:**
```dart
final schoolFeedAsync = ref.watch(schoolBroadcastProvider); // ✅ Correct
```

#### 3. **Sub-Optimal: Form State Coupling**
**Used In:** Dialog/Form widgets
- Validation logic tightly coupled to UI
- Submission logic buried in widget methods
- Testing requires UI harness

**Example:**
```dart
class ComposeBroadcastDialog extends ConsumerStatefulWidget {
  _titleCtrl, _bodyCtrl, _priority // ⚠️ Should be in controller
}
```

#### 4. **Critical: Direct Database Wiring**
**Used In:** QuickPaymentDialog
- Bypasses Riverpod framework
- Manual subscription lifecycle management
- Memory leak risks

**Example:**
```dart
_paymentSubscription = _dbService.db.watch(...).listen(...) // ⚠️ CRITICAL
```

---

## Architectural Observations

### "Law of Fragments" Adherence

#### ✅ Exemplary Implementations

**BroadcastKpiCards** - Independent error handling per card
- Each card receives isolated `AsyncValue`
- Failure in HQ feed doesn't break School feed display
- Perfect fault tolerance

**StatCard** - Pure presentation fragment
- Accepts primitives only (title, value, icon, color)
- Completely decoupled from data source
- 100% reusable

**RecentPaymentsSection** - Stateless composition
- Parent fetches data
- Fragment only renders
- Zero coupling

#### ⚠️ Violations

**ComposeBroadcastDialog** - Monolithic form
- Tightly couples: validation, state, submission, API
- Cannot be reused for "Edit" functionality
- Testing requires widget harness

**QuickPaymentDialog** - Direct database access
- Breaks fragment isolation principle
- Contains business logic (amount validation, transaction sequencing)
- Difficult to unit test

---

## Refactoring Priorities

### Critical (P0)
1. **QuickPaymentDialog** → Extract PaymentRepository, use StreamProvider
2. **ComposeBroadcastDialog** → Move logic to BroadcastFormController (AsyncNotifier)
3. **BroadcastList** → Replace string filters with BroadcastFilter enum

### High (P1)
1. **StudentsTable** → Consolidate filter providers into StudentFilterNotifier
2. **Global AsyncValue handling** → Create reusable AsyncFragment widget
3. **Form state management** → Standardize with AsyncNotifier pattern

### Medium (P2)
1. **TransactionsTable** → Extract row builder to standalone component
2. **InvoicesTable** → Apply same fragmentation principles
3. **ReportBuilder** → Decompose complex nested structure

---

## Quick Reference: Widget Imports

### Most Used Widgets (by frequency)

```dart
// Dialogs
import 'package:fees_up/pc/widgets/dashboard/payment_dialog.dart';
import 'package:fees_up/pc/widgets/students/quick_payment_dialog.dart';
import 'package:fees_up/pc/widgets/transactions/universal_entry_dialog.dart';

// Tables
import 'package:fees_up/pc/widgets/students/students_table.dart';
import 'package:fees_up/pc/widgets/transactions/transactions_table.dart';
import 'package:fees_up/pc/widgets/invoices/invoices_table.dart';

// Headers/Sections
import 'package:fees_up/pc/widgets/dashboard/kpi_section.dart';
import 'package:fees_up/pc/widgets/dashboard/revenue_chart.dart';

// Settings
import 'package:fees_up/pc/widgets/settings/school_year_settings_view.dart';
```

---

**Document Status:** ✅ Complete  
**Last Scan:** January 6, 2026  
**Maintained By:** Architecture Team

