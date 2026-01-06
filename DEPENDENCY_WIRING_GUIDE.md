# Fees Up: Detailed Component Dependency & Wiring Guide

**Status:** Comprehensive Dependency Analysis  
**Date:** January 6, 2026

---

## Table of Contents

1. [Provider Dependency Graph](#provider-dependency-graph)
2. [Screen-to-Widget Wiring Map](#screen-to-widget-wiring-map)
3. [State Management Wiring Patterns](#state-management-wiring-patterns)
4. [Database Access Patterns](#database-access-patterns)
5. [Dialog Lifecycle Flows](#dialog-lifecycle-flows)
6. [Component Inheritance Hierarchy](#component-inheritance-hierarchy)

---

## Provider Dependency Graph

### Core Application Providers

```
dashboardDataProvider
├─ Provides: DashboardData {
│   revenue: double,
│   outstandingBalance: double,
│   activeStudents: int,
│   invoicesCount: int
│ }
├─ Watched By: 
│   ├─ PCHomeScreen (KpiSection, RevenueChart)
│   └─ ReportsScreen (FinancialSummaryCards)
└─ Dependencies: 
    └─ DatabaseService.query()

fundraisingProvider
├─ Provides: FundraisingData {campaigns, totalRaised, activeCount}
├─ Watched By:
│   ├─ PCHomeScreen (dashboard display)
│   └─ CampaignDialog (form prefill)
└─ Dependencies:
    └─ campaignRepositoryProvider

schoolBroadcastProvider
├─ Provides: List<Broadcast> (school-level announcements)
├─ Watched By:
│   ├─ BroadcastList (dynamic, "All" or "School" filter)
│   └─ BroadcastKpiCards (aggregated view)
└─ Dependencies:
    └─ broadcastRepositoryProvider

internalHQBroadcastProvider
├─ Provides: List<Broadcast> (global HQ alerts)
├─ Watched By:
│   ├─ BroadcastList (dynamic, "Internal" filter)
│   └─ BroadcastKpiCards (aggregated view)
├─ Note: "Loophole Closed" - Specifically filters system messages
└─ Dependencies:
    └─ broadcastRepositoryProvider

filteredStudentsProvider(schoolId)
├─ Provides: List<Student> (dynamically filtered)
├─ Watched By:
│   ├─ StudentsScreen (main display)
│   ├─ StudentsTable (renders rows)
│   └─ StudentsHeader (filter counts)
├─ Depends On:
│   ├─ studentGradeFilterProvider
│   ├─ studentClassFilterProvider
│   ├─ studentStatusFilterProvider
│   └─ studentSearchFilterProvider
└─ Base Data: studentRepositoryProvider

studentGradeFilterProvider
├─ Type: StateProvider<String>
├─ Initial: "All"
├─ Watched By: filteredStudentsProvider, StudentsHeader
└─ Updated By: StudentsHeader dropdown

studentClassFilterProvider
├─ Type: StateProvider<String>
├─ Watched By: filteredStudentsProvider, StudentsHeader
└─ Updated By: StudentsHeader dropdown

studentStatusFilterProvider
├─ Type: StateProvider<String>
├─ Watched By: filteredStudentsProvider
└─ Updated By: StudentsHeader button group

studentSearchFilterProvider
├─ Type: StateProvider<String>
├─ Watched By: filteredStudentsProvider
└─ Updated By: StudentsHeader search input

transactionStreamProvider
├─ Provides: AsyncValue<List<Transaction>>
├─ Watched By:
│   ├─ TransactionsTable (rows)
│   ├─ TransactionsHeader (filters)
│   └─ TransactionsKpiCards (metrics)
├─ Parameters: {schoolId, dateRange, type}
└─ Updates: Real-time via StreamProvider

broadcastLogicProvider
├─ Provides: BroadcastService {post(), update(), delete()}
├─ Read By:
│   └─ ComposeBroadcastDialog (submit action)
└─ Note: ⚠️ Not used with AsyncValue - blocking operation

invoiceRepositoryProvider
├─ Provides: InvoiceRepository interface
├─ Used By:
│   ├─ InvoicesTable
│   ├─ InvoiceDialog
│   └─ InvoicesStats
└─ Methods: {create(), read(), update(), delete(), filter()}

paymentRepositoryProvider
├─ Provides: PaymentRepository interface
├─ Used By:
│   ├─ PaymentDialog (record payment)
│   ├─ QuickPaymentDialog (**⚠️ SHOULD use, currently doesn't**)
│   └─ TransactionsTable
└─ Methods: {create(), query(), allocate()}

reportEngineProvider
├─ Provides: ReportEngine {generate(), export()}
├─ Used By:
│   ├─ CustomReportBuilderWidget
│   └─ FinancialSummaryCards (preset reports)
└─ Supports: PDF, Excel, JSON export

notificationStreamProvider
├─ Provides: AsyncValue<List<Notification>>
├─ Watched By:
│   ├─ NotificationsScreen
│   ├─ NotificationsList
│   └─ NotificationsKpiCards
└─ Type: StreamProvider (real-time updates)

currentUserProvider
├─ Provides: User {id, name, email, role, permissions}
├─ Watched By: [Global - used throughout app]
├─ ProfileScreen, SettingsScreen, LogoutDialog
└─ Type: AsyncProvider (refetch on app init)

schoolConfigProvider
├─ Provides: SchoolConfig {name, year, terms, timezone}
├─ Watched By: [Global - cached]
├─ Type: FutureProvider
└─ Invalidates: App restart or settings change
```

---

## Screen-to-Widget Wiring Map

### 1. PCHomeScreen (Dashboard)

```
PCHomeScreen (ConsumerWidget)
│
├─→ DashboardSidebar (StatefulWidget)
│   └─ Manages: Active nav item state
│
├─→ DashboardTopBar (StatelessWidget)
│   └─ Displays: Time range selector, school name
│
├─→ DashboardHeader (StatelessWidget)
│   └─ Displays: "Dashboard" title + quick stats
│
├─→ KpiSection (ConsumerWidget)
│   └─ Watches: dashboardDataProvider
│       ├─ Shows: Revenue, Outstanding, Collected
│       └─ Triggers: RevenueChart update when data changes
│
├─→ RevenueChart (ConsumerWidget)
│   ├─ Watches: dashboardDataProvider, dateRangeProvider
│   └─ Renders: Bar/Line chart of revenue over time
│
├─→ QuickActionsGrid (StatelessWidget)
│   ├─ Children: QuickActionItem buttons
│   │   ├─ "Record Payment" → showDialog(PaymentDialog)
│   │   ├─ "New Invoice" → push(InvoicesScreen)
│   │   ├─ "New Campaign" → showDialog(CampaignDialog)
│   │   └─ "Record Expense" → showDialog(ExpenseDialog)
│   └─ Action Handlers: Navigator.push() or showDialog()
│
├─→ RecentPaymentsSection (StatelessWidget)
│   └─ Children: _PaymentRow (displays last 5 transactions)
│
└─→ Dialogs (Lazily Loaded)
    ├─ PaymentDialog (on "Record Payment" tap)
    ├─ CampaignDialog (on "New Campaign" tap)
    ├─ ExpenseDialog (on "Record Expense" tap)
    └─ StudentDialog (on "Enroll Student" tap)

Providers Watched:
├─ dashboardDataProvider (required)
├─ fundraisingProvider (optional, for campaign preview)
└─ currentUserProvider (for permissions check)
```

### 2. StudentsScreen

```
StudentsScreen (ConsumerWidget)
│
├─→ DashboardSidebar
│
├─→ StudentsHeader (ConsumerStatefulWidget)
│   ├─ Manages: Search input state, filter selections
│   ├─ Actions:
│   │   ├─ ref.read(studentGradeFilterProvider.notifier).state = 'Grade 10'
│   │   ├─ ref.read(studentClassFilterProvider.notifier).state = 'A'
│   │   └─ ref.read(studentSearchFilterProvider.notifier).state = 'John'
│   └─ Displays: Filter counts, search bar, "Add Student" button
│
├─→ StudentsStats (ConsumerWidget)
│   ├─ Watches: filteredStudentsProvider(schoolId)
│   └─ Displays: Total, Active, Pending stat cards
│
├─→ StudentsTable (ConsumerStatefulWidget)
│   ├─ Watches: 
│   │   ├─ filteredStudentsProvider(schoolId) [main data]
│   │   ├─ studentGradeFilterProvider [responsive rebuild]
│   │   ├─ studentClassFilterProvider [responsive rebuild]
│   │   ├─ studentStatusFilterProvider [responsive rebuild]
│   │   └─ studentSearchFilterProvider [responsive rebuild]
│   ├─ Renders: DataTable with columns (Name, Class, Grade, Status, Balance)
│   ├─ Row Actions (tap):
│   │   ├─ View Details → push(StudentDetailsScreen, studentId)
│   │   ├─ Quick Payment → showDialog(QuickPaymentDialog)
│   │   ├─ Edit → showDialog(EditStudentDialog)
│   │   └─ View Bills → showDialog(StudentBillsDialog)
│   └─ Local State: Sort column, page number
│
└─→ Dialogs
    ├─ QuickPaymentDialog (⚠️ CRITICAL: Uses _dbService.db.watch directly)
    ├─ EditStudentDialog (ConsumerStatefulWidget)
    │   └─ Watches: studentProvider(studentId) for prefill data
    └─ StudentBillsDialog (ConsumerWidget)
        └─ Watches: studentBillsProvider(studentId)

⚠️ Filter Provider Cascade Issue:
   When multiple filters change in quick succession:
   ├─ studentGradeFilterProvider updates → StudentsTable rebuilds
   ├─ studentClassFilterProvider updates → StudentsTable rebuilds
   ├─ studentStatusFilterProvider updates → StudentsTable rebuilds
   └─ Result: 3+ rebuilds for what should be 1 atomic update
```

### 3. StudentDetailsScreen

```
StudentDetailsScreen (ConsumerWidget)
│ Receives: studentId from route params
│
├─→ Watches: studentProvider(studentId)
│   └─ Provides: Full student object with enrollments
│
├─→ DashboardSidebar
│
├─→ StudentViewerSidebar (ConsumerWidget)
│   ├─ Watches: studentProvider(studentId)
│   └─ Displays: Avatar, name, class, balance, contact info
│
├─→ Main Content Area
│   ├─ Enrolled Classes Section
│   ├─ Payment History (with _buildClassItem)
│   └─ Outstanding Bills Section
│
└─→ Action Dialogs
    ├─ StudentBillsDialog (ConsumerWidget)
    │   └─ Watches: studentBillsProvider(studentId)
    │
    └─ FinancialLedgerDialog (ConsumerStatefulWidget)
        ├─ Watches: paymentHistoryProvider(studentId)
        └─ Features: Filter by date, reconciliation tools
```

### 4. TransactionsScreen

```
TransactionsScreen (ConsumerWidget)
│
├─→ DashboardSidebar
│
├─→ TransactionsHeader (ConsumerWidget)
│   ├─ Watches: transactionStreamProvider
│   └─ Displays: Filter controls, date range, export button
│
├─→ TransactionsKpiCards (ConsumerWidget)
│   ├─ Watches: transactionStreamProvider
│   └─ Shows: Total Transactions, Pending, Reconciled, Failed
│
├─→ TransactionsTable (ConsumerStatefulWidget)
│   ├─ Watches: transactionStreamProvider(schoolId, dateRange, type)
│   ├─ Renders: Columns (Date, Type, Amount, Method, Status, Actions)
│   ├─ Row Actions:
│   │   ├─ View Details → showDialog or details panel
│   │   ├─ Edit → showDialog(UniversalTransactionDialog, initialData)
│   │   ├─ Allocate Payment → showDialog(PaymentAllocationDialog)
│   │   └─ Delete → confirmation → ref.read(repo).delete(id)
│   └─ Local State: Sort, pagination, inline editing
│
├─→ _TransactionRowFromMap (StatelessWidget)
│   └─ Displays: Single transaction row (pure presentation)
│
└─→ Dialog Components
    ├─ UniversalTransactionDialog (ConsumerStatefulWidget) ⭐ Future Universal Hub
    │   ├─ Manages: Form state for Payment/Expense/Adjustment
    │   ├─ Submission: ref.read(transactionLogicProvider).save()
    │   └─ Validation: Type-specific rules via strategy pattern
    │
    └─ PaymentAllocationDialog (ConsumerStatefulWidget)
        ├─ Shows: List of bills to allocate against
        ├─ Watches: studentBillsProvider(studentId)
        └─ Submission: ref.read(paymentLogicProvider).allocate()
```

### 5. InvoicesScreen

```
InvoicesScreen (ConsumerWidget)
│
├─→ DashboardSidebar
│
├─→ InvoicesHeader (ConsumerWidget)
│   ├─ Watches: invoiceStatusFilterProvider
│   └─ Displays: Filter buttons (All, Draft, Sent, Paid, Overdue)
│
├─→ InvoicesStats (ConsumerWidget)
│   ├─ Watches: invoiceStreamProvider
│   ├─ Renders:
│   │   ├─ _StatCard: "Total Invoices"
│   │   ├─ _StatCard: "Revenue (Paid)"
│   │   ├─ _StatCard: "Outstanding"
│   │   └─ _CreateInvoiceCard: "Create New" CTA
│   │
│   └─ _CreateInvoiceCard (ConsumerWidget)
│       └─ Tap → showDialog(InvoiceDialog, null)
│
├─→ InvoicesTable (ConsumerStatefulWidget)
│   ├─ Watches: 
│   │   ├─ invoiceStreamProvider(schoolId, statusFilter, dateRange)
│   │   └─ invoiceStatusFilterProvider [rebuild trigger]
│   ├─ Renders: Columns (Invoice #, Student, Amount, Due Date, Status)
│   ├─ Row Actions:
│   │   ├─ View/Edit → showDialog(InvoiceDialog, invoiceId)
│   │   ├─ Allocate Payments → showDialog(PaymentAllocationsDialog)
│   │   ├─ Send → Email dialog
│   │   └─ Archive → confirmation → delete
│   └─ Local State: Sort, page, selected rows
│
└─→ Dialog Components
    ├─ InvoiceDialog (ConsumerStatefulWidget)
    │   ├─ Modes: Create or Edit
    │   ├─ Form Fields:
    │   │   ├─ Student (autocomplete dropdown)
    │   │   ├─ Line Items (add/remove)
    │   │   ├─ Due Date
    │   │   └─ Notes
    │   ├─ Submission: ref.read(invoiceLogicProvider).save()
    │   └─ Validation: Line item count > 0, student selected
    │
    └─ PaymentAllocationsDialog (ConsumerStatefulWidget)
        ├─ Shows: List of unpaid invoices for student
        ├─ Watches: studentInvoicesProvider(studentId)
        └─ Allocation Logic: Assign payment to specific invoices
```

### 6. SettingsScreen

```
SettingsScreen (ConsumerStatefulWidget)
│ Manages: Active tab state locally (_selectedTab)
│
├─→ DashboardSidebar
│
├─→ SettingsHeader (ConsumerWidget)
│   ├─ Displays: Tab buttons (School Year, Notifications, Users, Integrations, etc.)
│   └─ Updates: ref.read(_selectedTabProvider.notifier).state = 'Notifications'
│
└─→ Dynamic Content (based on _selectedTab)
    │
    ├─ "School Year" Tab
    │   └─→ SchoolYearSettingsView (ConsumerStatefulWidget)
    │       ├─ YearConfigurationCard (ConsumerStatefulWidget)
    │       │   └─ Manages: New year creation form
    │       │
    │       └─ SchoolYearRegistryCard (ConsumerWidget)
    │           └─ Watches: schoolYearsProvider
    │               └─ Displays: Registered years list
    │
    ├─ "Notifications" Tab
    │   └─→ NotificationsSettingsView (ConsumerStatefulWidget)
    │       ├─ Manages: Delivery channel toggles (Email, SMS, Push)
    │       ├─ _NotificationGroupTile (StatelessWidget)
    │       │   └─ Displays: Each notification type checkbox
    │       │
    │       └─ _DeliveryChannelTile (StatelessWidget)
    │           └─ Displays: Channel toggle + settings icon
    │
    ├─ "Users & Permissions" Tab
    │   └─→ UsersPermissionsView (ConsumerStatefulWidget)
    │       ├─ Watches: organizationUsersProvider
    │       ├─ Renders: _UserRow for each user
    │       │   ├─ Displays: Name, email, role, last login
    │       │   └─ Actions: Edit, Revoke, Impersonate (admin only)
    │       │
    │       └─ AddUserDialog trigger (tap "Invite User")
    │           ├─ Form: Email, Role dropdown
    │           └─ Submission: ref.read(userLogicProvider).invite()
    │
    ├─ "Integrations" Tab
    │   └─→ IntegrationsSettingsView (StatelessWidget)
    │       ├─ ApiConfigCard (StatelessWidget)
    │       │   └─ Displays: API key, usage stats, regenerate button
    │       │
    │       ├─ ConnectedServicesCard (StatelessWidget)
    │       │   ├─ _ServiceRow (StatelessWidget) × N
    │       │   │   └─ Stripe, Google Classroom, Zoom, etc.
    │       │   └─ Actions: Connect, Disconnect, Settings
    │       │
    │       ├─ TeacherTokensCard (StatelessWidget)
    │       │   ├─ _TokenRow (StatelessWidget) × N
    │       │   └─ Actions: Generate, Copy, Revoke
    │       │
    │       └─ SecurityPermissionsCard (StatefulWidget)
    │           └─ OAuth scopes matrix (checkboxes)
    │
    ├─ "Organization" Tab
    │   └─→ OrganizationCard (ConsumerStatefulWidget)
    │       ├─ Form Fields: School name, logo, timezone
    │       └─ Submission: ref.read(organizationLogicProvider).update()
    │
    ├─ "Billing" Tab
    │   └─→ BillingConfigCard (ConsumerStatefulWidget)
    │       ├─ BillingPeriodDialog trigger
    │       │   ├─ Form: Invoice generation schedule (Monthly/Quarterly/etc.)
    │       │   └─ Submission: ref.read(billingLogicProvider).updateSchedule()
    │       │
    │       └─ Display: Current plan, next billing date
    │
    ├─ "Audit Trail" Tab
    │   └─→ AuditTrailView (ConsumerStatefulWidget)
    │       ├─ Watches: auditLogStreamProvider (filtered)
    │       ├─ Manages: Date range, user filter, action type filter
    │       └─ Renders: Log entries paginated list
    │
    └─ "General Financial" Tab
        └─→ GeneralFinancialView (ConsumerWidget)
            ├─ Watches: accountingConfigProvider
            └─ Displays: Chart of accounts, tax settings
```

### 7. ProfileScreen

```
ProfileScreen (StatefulWidget)
│ Manages: _selectedTab (local state)
│
├─→ DashboardSidebar
│
├─→ ProfileHeaderCard (ConsumerWidget)
│   ├─ Watches: currentUserProvider
│   └─ Displays: Avatar, name, role badge, email
│
└─→ Tab Content (based on _selectedTab)
    │
    ├─ "Personal Info" Tab
    │   └─→ PersonalInfoForm (ConsumerWidget)
    │       ├─ Watches: currentUserProvider (prefill)
    │       ├─ Form: Name, Email, Phone, Location
    │       └─ Submission: ref.read(userProfileLogicProvider).update()
    │
    ├─ "Account Security" Tab
    │   └─→ AccountSecurityCard (StatelessWidget)
    │       │
    │       ├─ SecurityPasswordView (StatelessWidget)
    │       │   ├─ Form: Current Password, New Password, Confirm
    │       │   └─ Features: Strength meter, requirements checklist
    │       │
    │       └─ Enable2FA Button
    │           └─ Tap → showDialog(EnableTwoFactorDialog)
    │               ├─ Displays: QR code + manual entry code
    │               └─ Submission: ref.read(authLogicProvider).enable2FA()
    │
    ├─ "Permissions" Tab
    │   └─→ RolePermissionsView (StatelessWidget)
    │       └─ Displays: Read-only permission matrix (School Admin, Teacher, etc.)
    │
    └─ "Activity Log" Tab
        └─→ ActivityLogView (StatelessWidget)
            └─ Displays: Login history with timestamps + devices
```

### 8. AnnouncementsScreen

```
AnnouncementsScreen (StatelessWidget)
│
├─→ DashboardSidebar
│
├─→ _BroadcastsHeader (StatelessWidget)
│   └─ Displays: Page title "Announcements"
│
├─→ BroadcastKpiCards (ConsumerWidget) ⭐ Exemplary Multi-Provider Wiring
│   ├─ Watches:
│   │   ├─ schoolBroadcastProvider (independently)
│   │   └─ internalHQBroadcastProvider (independently)
│   ├─ Renders: Two cards side-by-side
│   │   ├─ "Active Broadcasts" (from schoolBroadcastProvider)
│   │   │   └─ Shows: Count, last updated, icon
│   │   │
│   │   └─ "HQ Internal Alerts" (from internalHQBroadcastProvider)
│   │       └─ Shows: Count, critical indicator
│   │
│   └─ Error Handling: Per-card, isolated
│       ├─ If school feed fails: "HQ Internal" still displays
│       └─ If HQ feed fails: "Active Broadcasts" still displays
│
├─→ BroadcastList (ConsumerStatefulWidget) ⭐ Exemplary "Fortress Stream"
│   ├─ Manages: _filter state ("All", "Internal", "System")
│   ├─ Watches: (dynamic, based on _filter)
│   │   ├─ If _filter == "Internal": internalHQBroadcastProvider
│   │   └─ Else: schoolBroadcastProvider
│   │
│   ├─ Filter Buttons:
│   │   ├─ "All Broadcasts" → _filter = "All" → rewire to schoolBroadcastProvider
│   │   ├─ "Internal Only" → _filter = "Internal" → rewire to internalHQBroadcastProvider
│   │   └─ "System" → _filter = "System" → filter results client-side
│   │
│   └─ Renders: ListView of BroadcastItems
│       ├─ Tap → View full broadcast
│       └─ Context menu → Edit (admin only)
│
└─→ ComposeBroadcastDialog (ConsumerStatefulWidget)
    ├─ Trigger: "New Announcement" button (FAB or header)
    ├─ Manages: Form state (_titleCtrl, _bodyCtrl, _priority)
    ├─ Form Fields:
    │   ├─ Title (TextField)
    │   ├─ Body (Editor/RichText)
    │   ├─ Priority (Dropdown: Normal, Urgent, Critical)
    │   ├─ Recipients (Dropdown: Everyone, Teachers, Parents)
    │   └─ Schedule (DateTimePicker: Now or Later)
    │
    ├─ Submission:
    │   ├─ Validate: _formKey.currentState!.validate()
    │   ├─ Set _isLoading = true
    │   ├─ Call: ref.read(broadcastLogicProvider).post(title, body, priority)
    │   ├─ Handle Success: Pop dialog, show SnackBar
    │   └─ Handle Error: Show error dialog
    │
    └─ ⚠️ ARCHITECTURAL ISSUE:
        ├─ Logic tightly coupled to UI widget
        ├─ No AsyncValue state management
        ├─ Difficult to unit test without UI harness
        └─ Solution: Move to BroadcastFormController (AsyncNotifier)
```

### 9. ReportsScreen

```
ReportsScreen (ConsumerWidget)
│
├─→ DashboardSidebar
│
├─→ ReportsHeader (ConsumerWidget)
│   ├─ Displays: Category tabs (Financial, Student, Invoice, etc.)
│   └─ Manages: Category filter state
│
├─→ Scrollable Report List
│   │
│   ├─ FinancialSummaryCards (ConsumerWidget) - Preset Reports
│   │   ├─ Watches: dashboardDataProvider, reportDataProvider
│   │   ├─ Renders:
│   │   │   ├─ _InvoiceStatsCard (StatelessWidget)
│   │   │   │   └─ Shows: Invoice metrics (Created, Paid, Outstanding)
│   │   │   ├─ _TransactionSummaryCard (StatelessWidget)
│   │   │   │   └─ Shows: Payment/Expense breakdown by type
│   │   │   └─ _QuickActionCard (StatelessWidget)
│   │   │       └─ Shows: Export, Schedule, Archive buttons
│   │   │
│   │   └─ Tap actions:
│   │       ├─ Export → Download PDF/Excel
│   │       ├─ Schedule → Set up recurring report
│   │       └─ View Details → showDialog or navigation
│   │
│   └─ Saved Reports List
│       ├─ ReportCard (StatelessWidget) × N
│       │   ├─ Shows: Report name, date created, status
│       │   └─ Tap → View full report
│       │
│       └─ "Create Custom Report" Button
│           └─ Tap → showDialog(CustomReportBuilderWidget)
│
└─→ CustomReportBuilderWidget (ConsumerWidget) - Query Builder
    ├─ Watches: reportEngineProvider
    ├─ Components:
    │   ├─ _BuilderHeader (StatelessWidget)
    │   │   └─ Title input, Save/Load dropdowns
    │   │
    │   ├─ _ReportFormSection (StatelessWidget)
    │   │   ├─ Date range picker
    │   │   ├─ Data source checkboxes (Invoices, Payments, etc.)
    │   │   ├─ Filter criteria inputs
    │   │   └─ Group by dropdown (Date, Student, Class, etc.)
    │   │
    │   └─ _ReportSummaryPanel (ConsumerWidget)
    │       ├─ Watches: reportPreviewProvider (generated on-the-fly)
    │       ├─ Shows: Summary statistics
    │       └─ Buttons: Export, Run, Save as Template
    │
    └─ Submission Flow:
        ├─ ref.read(reportEngineProvider).generate(criteria)
        ├─ Returns: Report object with data + formatting
        └─ Display: Table view with charts
```

### 10. NotificationsScreen

```
NotificationsScreen (ConsumerWidget)
│
├─→ DashboardSidebar
│
├─→ _NotificationsHeader (StatelessWidget)
│   └─ Displays: "Mark all as read" button, refresh icon
│
├─→ NotificationsKpiCards (ConsumerWidget)
│   ├─ Watches: notificationStreamProvider
│   └─ Shows: Unread count, Critical alerts count
│
└─→ NotificationsList (ConsumerStatefulWidget)
    ├─ Watches: notificationStreamProvider
    ├─ Manages: Pagination, scroll state
    ├─ Renders: Paginated notification feed
    │   ├─ Notification Item
    │   │   ├─ Icon + Title + Timestamp
    │   │   ├─ Unread indicator (blue dot)
    │   │   └─ Tap → Navigate to related resource
    │   │
    │   └─ _VerticalDivider (StatelessWidget)
    │       └─ Dividers between notification groups (by date)
    │
    └─ Infinite Scroll:
        ├─ Watches: ScrollController
        └─ At bottom → Load next 20 items
```

---

## State Management Wiring Patterns

### Pattern 1: Pure Reactive (Exemplary)

**Example: BroadcastKpiCards**

```dart
class BroadcastKpiCards extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schoolFeedAsync = ref.watch(schoolBroadcastProvider);
    final hqFeedAsync = ref.watch(internalHQBroadcastProvider);
    
    return Row(
      children: [
        Expanded(
          child: schoolFeedAsync.when(
            data: (broadcasts) => _buildAsyncCard(
              title: 'Active Broadcasts',
              value: broadcasts.length,
              ...
            ),
            loading: () => LoadingCard(),
            error: (err, stack) => ErrorCard(),
          ),
        ),
        Expanded(
          child: hqFeedAsync.when(
            data: (broadcasts) => _buildAsyncCard(
              title: 'HQ Internal',
              value: broadcasts.where((b) => b.isSystemMessage).length,
              ...
            ),
            loading: () => LoadingCard(),
            error: (err, stack) => ErrorCard(),
          ),
        ),
      ],
    );
  }
}
```

**✅ Advantages:**
- Independent error states per card
- Automatic subscription lifecycle management
- Caching built-in via Riverpod
- Unit testable with mock providers

---

### Pattern 2: Dynamic Provider Rewiring (Fortress Stream)

**Example: BroadcastList**

```dart
class BroadcastList extends ConsumerStatefulWidget {
  @override
  ConsumerState<BroadcastList> createState() => _BroadcastListState();
}

class _BroadcastListState extends ConsumerState<BroadcastList> {
  String _filter = 'All';
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ⭐ DYNAMIC REWIRING: Provider selection based on filter
    final AsyncValue<List<Broadcast>> feedAsync = (_filter == 'Internal')
      ? ref.watch(internalHQBroadcastProvider)
      : ref.watch(schoolBroadcastProvider);
    
    return Column(
      children: [
        // Filter buttons change _filter, triggering rewire
        Row(
          children: [
            FilterButton(
              label: 'All',
              isSelected: _filter == 'All',
              onTap: () => setState(() => _filter = 'All'),
            ),
            FilterButton(
              label: 'Internal',
              isSelected: _filter == 'Internal',
              onTap: () => setState(() => _filter = 'Internal'),
            ),
          ],
        ),
        // Single AsyncValue consumption
        feedAsync.when(
          data: (broadcasts) {
            final filtered = _filter == 'System'
              ? broadcasts.where((b) => b.isSystemMessage).toList()
              : broadcasts;
            return ListView(children: filtered.map(...).toList());
          },
          loading: () => LoadingWidget(),
          error: (err, stack) => ErrorWidget(),
        ),
      ],
    );
  }
}
```

**✅ Advantages:**
- Riverpod automatically handles subscription switches
- Resources for unselected provider are released
- Single consumption point for UI
- No manual subscription management

---

### Pattern 3: Multi-Filter Aggregation (Sub-Optimal)

**Example: StudentsTable**

```dart
class StudentsTable extends ConsumerStatefulWidget {
  @override
  ConsumerState<StudentsTable> createState() => _StudentsTableState();
}

class _StudentsTableState extends ConsumerState<StudentsTable> {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ⚠️ PROBLEM: Watching 4+ independent providers
    final selectedGrade = ref.watch(studentGradeFilterProvider);
    final selectedClass = ref.watch(studentClassFilterProvider);
    final selectedStatus = ref.watch(studentStatusFilterProvider);
    final searchTerm = ref.watch(studentSearchFilterProvider);
    
    // This triggers 4 separate rebuilds if filters update sequentially
    final students = ref.watch(
      filteredStudentsProvider(
        schoolId: widget.schoolId,
        grade: selectedGrade,
        class: selectedClass,
        status: selectedStatus,
        search: searchTerm,
      )
    );
    
    return DataTable(rows: students.map(...).toList());
  }
}
```

**⚠️ Issues:**
- 4+ separate watches = 4+ rebuild triggers
- If user clears all filters, rebuilds cascade
- Should consolidate into single StudentFilterState

**✅ Refactored Version:**

```dart
// consolidate all filters into one provider
final studentFilterProvider = StateNotifierProvider((ref) {
  return StudentFilterNotifier();
});

class StudentFilterNotifier extends StateNotifier<StudentFilterState> {
  StudentFilterNotifier() : super(StudentFilterState());
  
  void updateGrade(String grade) {
    state = state.copyWith(grade: grade);
  }
  
  void updateAll({
    String? grade,
    String? classId,
    String? status,
    String? search,
  }) {
    state = state.copyWith(
      grade: grade ?? state.grade,
      class: classId ?? state.class,
      status: status ?? state.status,
      search: search ?? state.search,
    );
  }
}

// In widget: single watch
final filters = ref.watch(studentFilterProvider);
final students = ref.watch(filteredStudentsProvider(widget.schoolId, filters));
```

---

### Pattern 4: Form State Management (Sub-Optimal)

**Example: ComposeBroadcastDialog**

```dart
class ComposeBroadcastDialog extends ConsumerStatefulWidget {
  @override
  ConsumerState<ComposeBroadcastDialog> createState() =>
      _ComposeBroadcastDialogState();
}

class _ComposeBroadcastDialogState extends ConsumerState<ComposeBroadcastDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _bodyCtrl;
  String _priority = 'Normal';
  bool _isLoading = false;
  String? _errorMsg;
  
  @override
  void initState() {
    _titleCtrl = TextEditingController();
    _bodyCtrl = TextEditingController();
    super.initState();
  }
  
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      await ref.read(broadcastLogicProvider).post(
        title: _titleCtrl.text,
        body: _bodyCtrl.text,
        priority: _priority,
      );
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Broadcast posted')),
      );
    } catch (e) {
      setState(() => _errorMsg = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              controller: _titleCtrl,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            TextFormField(
              controller: _bodyCtrl,
              validator: (v) => v!.isEmpty ? 'Required' : null,
            ),
            DropdownButton(
              value: _priority,
              items: ['Normal', 'Urgent', 'Critical']
                .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                .toList(),
              onChanged: (v) => setState(() => _priority = v!),
            ),
            if (_isLoading)
              CircularProgressIndicator()
            else if (_errorMsg != null)
              Text(_errorMsg!, style: TextStyle(color: Colors.red))
            else
              ElevatedButton(
                onPressed: _submit,
                child: Text('Post'),
              ),
          ],
        ),
      ),
    );
  }
  
  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }
}
```

**⚠️ Issues:**
- Business logic embedded in UI
- Manual state management (_isLoading,_errorMsg)
- Difficult to test without rendering widget
- Cannot reuse for "Edit" functionality

**✅ Refactored: AsyncNotifier Controller**

```dart
// controllers/broadcast_form_controller.dart
@riverpod
class BroadcastFormController extends _$BroadcastFormController {
  Future<void> submit({
    required String title,
    required String body,
    required Priority priority,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() =>
      ref.read(broadcastRepositoryProvider).postBroadcast(
        title: title,
        body: body,
        priority: priority,
      ),
    );
  }
}

// In widget: simple UI
class ComposeBroadcastDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = ref.watch(broadcastFormControllerProvider);
    final formState = ref.watch(broadcastFormControllerProvider);
    
    return Dialog(
      child: Column(
        children: [
          // Form fields...
          formState.when(
            data: (_) {
              Navigator.pop(context);
              return SizedBox(); // dispose
            },
            loading: () => CircularProgressIndicator(),
            error: (err, stack) => ErrorWidget(error: err),
          ),
        ],
      ),
    );
  }
}
```

---

### Pattern 5: Direct Database Access (CRITICAL ANTI-PATTERN)

**Example: QuickPaymentDialog ⚠️**

```dart
class QuickPaymentDialog extends ConsumerStatefulWidget {
  final String studentId;
  
  @override
  ConsumerState<QuickPaymentDialog> createState() =>
      _QuickPaymentDialogState();
}

class _QuickPaymentDialogState extends ConsumerState<QuickPaymentDialog> {
  late StreamSubscription _paymentSubscription;
  List<dynamic> _payments = [];
  bool _isLoading = false;
  String? _selectedMethod = 'Cash';
  
  @override
  void initState() {
    super.initState();
    // ⚠️⚠️⚠️ CRITICAL: Bypasses Riverpod entirely
    _paymentSubscription = _dbService.db
      .watch('SELECT * FROM payments WHERE student_id = ?', parameters: [widget.studentId])
      .listen((payments) {
        setState(() => _payments = payments);
      });
  }
  
  Future<void> _recordPayment(double amount) async {
    // ⚠️ No atomic transaction handling
    await _dbService.db.insert('payments', {
      'student_id': widget.studentId,
      'amount': amount,
      'method': _selectedMethod,
      'date': DateTime.now().toIso8601String(),
    });
    
    // ⚠️ If app crashes here, payment recorded but bill not updated
    final billId = await _dbService.db.query(
      'SELECT id FROM bills WHERE student_id = ? ORDER BY date DESC LIMIT 1',
      parameters: [widget.studentId],
    ).then((results) => results.first['id']);
    
    await _dbService.db.update('bills', billId, {'is_paid': 1});
  }
  
  @override
  void dispose() {
    // ⚠️ If this is forgotten, memory leak occurs
    _paymentSubscription.cancel();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Column(
        children: [
          Text('Recent Payments'),
          ListView.builder(
            itemCount: _payments.length,
            itemBuilder: (ctx, idx) {
              final payment = _payments[idx];
              return ListTile(
                title: Text('${payment['amount']} - ${payment['method']}'),
                subtitle: Text(payment['date']),
              );
            },
          ),
          TextFormField(
            onChanged: (v) => _amount = double.parse(v),
          ),
          DropdownButton(
            value: _selectedMethod,
            items: ['Cash', 'Check', 'Card', 'Mobile'].map(...).toList(),
            onChanged: (v) => setState(() => _selectedMethod = v),
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : () async {
              setState(() => _isLoading = true);
              try {
                await _recordPayment(_amount);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              } finally {
                setState(() => _isLoading = false);
              }
            },
            child: Text('Record Payment'),
          ),
        ],
      ),
    );
  }
}
```

**⚠️⚠️⚠️ CRITICAL ISSUES:**

1. **Bypasses Riverpod** - No caching, error handling, or debouncing
2. **Manual Subscription** - Memory leak risk if dispose() not called
3. **Non-Atomic Transaction** - App crash between insert and update leaves DB inconsistent
4. **Hardcoded SQL** - Schema changes require modifying this widget
5. **Duplicate Logic** - Payment recording logic cannot be shared with bulk import
6. **Non-Testable** - Cannot test without mock DatabaseService

**✅ Refactored: Repository + StreamProvider Pattern**

```dart
// repositories/payment_repository.dart
abstract class PaymentRepository {
  Future<void> recordPayment({
    required String studentId,
    required double amount,
    required String method,
  });
  
  Stream<List<Payment>> watchPaymentsForStudent(String studentId);
}

class PaymentRepositoryImpl implements PaymentRepository {
  @override
  Future<void> recordPayment({
    required String studentId,
    required double amount,
    required String method,
  }) async {
    await _dbService.db.withTransaction(() async {
      // ✅ Atomic at database level
      await _dbService.db.insert('payments', {...});
      await _dbService.db.update('bills', {...});
    });
  }
  
  @override
  Stream<List<Payment>> watchPaymentsForStudent(String studentId) {
    return _dbService.db
      .watch('SELECT * FROM payments WHERE student_id = ?', 
             parameters: [studentId])
      .map((rows) => rows.map(Payment.fromMap).toList());
  }
}

// providers/payment_provider.dart
final paymentRepositoryProvider = Provider((ref) {
  return PaymentRepositoryImpl(_dbService);
});

final paymentHistoryProvider = StreamProvider.family<List<Payment>, String>(
  (ref, studentId) {
    final repo = ref.watch(paymentRepositoryProvider);
    return repo.watchPaymentsForStudent(studentId);
  },
);

// In widget: clean, testable
class QuickPaymentDialog extends ConsumerWidget {
  final String studentId;
  
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final paymentsAsync = ref.watch(paymentHistoryProvider(studentId));
    
    return Dialog(
      child: paymentsAsync.when(
        data: (payments) => PaymentForm(
          studentId: studentId,
          recentPayments: payments,
          onSubmit: (amount, method) {
            ref.read(paymentRepositoryProvider).recordPayment(
              studentId: studentId,
              amount: amount,
              method: method,
            );
          },
        ),
        loading: () => LoadingWidget(),
        error: (err, stack) => ErrorWidget(error: err),
      ),
    );
  }
}
```

---

## Database Access Patterns

### ✅ Pattern A: Repository Abstraction

```dart
// SQL is encapsulated in repository
// UI has no knowledge of table names, columns, joins
final payments = ref.watch(paymentHistoryProvider(studentId));
```

### ⚠️ Pattern B: Direct SQL in UI

```dart
// ⚠️ SQL leaks into widget layer
_dbService.db.watch('SELECT * FROM payments WHERE student_id = ?')
```

### ⭐ Recommended Transition

1. Create `repositories/` folder
2. Move all SQL queries there
3. Export interfaces, not implementations
4. Wrap repositories in Providers
5. Update widgets to watch providers only

---

## Dialog Lifecycle Flows

### Example: PaymentDialog Flow

```
User Taps "Record Payment"
        ↓
showDialog(PaymentDialog)
        ↓
PaymentDialog.build()
        ↓
User Enters Amount, Selects Method
        ↓
User Taps "Record"
        ↓
_submit() called
  ├─ setState(_isLoading = true)
  ├─ ref.read(broadcastLogicProvider).post(...)
  ├─ setState(_isLoading = false)
  └─ Navigator.pop(context) OR show error
        ↓
Dialog Dismissed OR Error Shown
```

---

## Component Inheritance Hierarchy

```
Widget (Flutter Base)
├── StatelessWidget
│   ├── DashboardHeader
│   ├── DashboardTopBar
│   ├── StatCard
│   ├── AlertBadge
│   ├── NoSchoolOverlay
│   ├── ScreenSizeError
│   ├── ProfileHeaderCard
│   ├── RecentPaymentsSection
│   ├── _PaymentRow
│   ├── QuickActionsGrid
│   ├── IntegrationsSettingsView
│   └── ...
│
├── StatefulWidget
│   ├── DashboardSidebar
│   ├── _SidebarItem
│   ├── LogoutDialog
│   ├── ProfileScreen
│   ├── EnableTwoFactorDialog
│   ├── SecurityPermissionsCard
│   └── ...
│
├── ConsumerWidget (Riverpod)
│   ├── KpiSection
│   ├── RevenueChart
│   ├── BroadcastKpiCards
│   ├── StudentsStats
│   ├── TransactionsKpiCards
│   ├── InvoicesStats
│   ├── NotificationsKpiCards
│   ├── PersonalInfoForm
│   ├── CustomReportBuilderWidget
│   └── ...
│
└── ConsumerStatefulWidget (Riverpod + State)
    ├── BroadcastList
    ├── ComposeBroadcastDialog
    ├── StudentsTable
    ├── StudentsHeader
    ├── EditStudentDialog
    ├── TransactionsTable
    ├── TransactionsHeader
    ├── InvoicesTable
    ├── InvoiceDialog
    ├── QuickPaymentDialog (⚠️ CRITICAL ISSUES)
    ├── PaymentAllocationDialog
    ├── SchoolYearSettingsView
    ├── NotificationsSettingsView
    ├── UsersPermissionsView
    ├── AuditTrailView
    ├── SettingsScreen
    ├── YearConfigurationCard
    ├── BillingConfigCard
    ├── OrganizationCard
    └── ...
```

---

**Document Complete**  
**Total Components Mapped:** 100+  
**Total Screens:** 10  
**Critical Issues Identified:** 3  
**Exemplary Patterns:** 5

