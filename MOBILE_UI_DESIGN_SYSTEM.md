# 📱 Fees Up - Mobile UI Design System
**Zimbabwe School Fees Management App**  
**Date:** January 8, 2026  
**Platform:** Flutter (iOS/Android/Linux/Windows)  
**Theme:** Lively Slate (Dark Mode Default)

---

## 📋 Screen Inventory & Task Breakdown

### **TIER 1: Core Navigation (4 Main Screens)**

#### 1. **Dashboard Screen** ✅ (EXISTS - Needs Polish)
**Purpose:** Daily overview, quick actions  
**Mobile Height:** Full screen (without nav bar: 88% of viewport)

**Layout:**
```
┌─────────────────────────────┐
│ Header: "Dashboard" (20px)  │
├─────────────────────────────┤
│ 🎯 KPI Cards (2-column)     │
│ ┌──────────┬──────────┐     │
│ │ Learners │ Cash     │     │
│ │   24     │ $1,240   │     │
│ └──────────┴──────────┘     │
├─────────────────────────────┤
│ 📌 Quick Actions (3-wide)   │
│ ┌─ ┬─ ┬─┐                   │
│ │1 │2 │3│                   │
│ └─ ┴─ ┴─┘                   │
├─────────────────────────────┤
│ 📊 Activity Feed (scrollable)│
│ • 2h ago: Payment received  │
│ • 4h ago: New learner added │
│ • 1d ago: Invoice generated │
│ (Load more...)              │
└─────────────────────────────┘
```

**Key Components:**
- Header with user avatar (top-right) + school name
- 2 KPI cards (stacked on narrow, side-by-side on wide)
- 3 quick-action buttons (large, touch-friendly: 56px minimum)
- Scrollable activity feed (infinite load)
- Bottom nav indicator (active tab highlighted)

**Mobile Considerations:**
- Touch targets ≥44px (Apple), ≥48px (Google)
- Max content width 90vw (phone), 600px (tablet)
- Swipe-able activity feed cards

---

#### 2. **Learners Screen** (Core Revenue Driver)
**Purpose:** Manage all learners, allocate fees, view financials

**Layout A: List View (Default)**
```
┌─────────────────────────────┐
│ [Search box] [Filter icon]  │
├─────────────────────────────┤
│ 📚 FORM 1 (8 learners)      │  ← Collapsible section
├─────────────────────────────┤
│ ┌─────────────────────────┐ │
│ │ Learner Card (Full Width)│
│ │ ┌─────────────────────┐ │
│ │ │ Tanaka Moyo         │ │
│ │ │ Form 1A | Active    │ │ ← Status badge (green)
│ │ │ Balance: -$150 USD  │ │ ← Red if owing, green if paid
│ │ │ [Tap to expand]     │ │
│ │ └─────────────────────┘ │
│ └─────────────────────────┘ │
│                             │
│ ┌─────────────────────────┐ │
│ │ Chipo Madzimure         │ │
│ │ Form 1B | Active        │ │
│ │ Balance: +$240 USD      │ │
│ └─────────────────────────┘ │
│                             │
│ [Load more...]              │
└─────────────────────────────┘
```

**Layout B: Expanded Learner Card (Tap)**
```
┌─────────────────────────────┐
│ < Tanaka Moyo       [Menu]  │
├─────────────────────────────┤
│ Form 1A | Status: ACTIVE    │
│ DOB: 15/03/2008             │
│ Enrollment: 02/01/2025      │
├─────────────────────────────┤
│ 💰 Financial Standing       │
│ Outstanding: $150.00 USD    │
│ Last Payment: 2 days ago    │
├─────────────────────────────┤
│ 📋 Fee Allocations:         │
│ ✓ Tuition: $200 USD         │
│ ✓ Levies: $50 USD           │
│ ☐ Transport: $30 USD        │
├─────────────────────────────┤
│ 📜 Recent Transactions:     │
│ • Invoice: $250 (pending)   │
│ • Payment: $150 (2d ago)    │
├─────────────────────────────┤
│ [Edit] [Generate Invoice]   │ ← Action buttons
└─────────────────────────────┘
```

---

#### 3. **Finance Screen** (Critical for Cash Tracking)
**Purpose:** Ledger, payments, outstanding invoices

**Layout A: Finance Dashboard**
```
┌─────────────────────────────┐
│ 💵 Finance Overview         │
├─────────────────────────────┤
│ Total Income:  $8,950 USD   │ ← Green
│ Total Owing:   $2,340 USD   │ ← Red
│ Cash Today:    $150 USD     │ ← Blue
├─────────────────────────────┤
│ 📊 Outstanding Invoices:    │
│ 12 invoices | Total: $2,340 │
│ [View List] [Generate All]  │
├─────────────────────────────┤
│ 📝 Recent Transactions:     │
│ (Scrollable ledger)         │
│ 🟢 2h ago: Payment $150     │
│ 📄 1d ago: Invoice $250     │
│ 🟢 2d ago: Payment $200     │
│ [View Full Ledger]          │
└─────────────────────────────┘
```

**Layout B: Full Ledger View**
```
┌─────────────────────────────┐
│ Ledger | [Filter by date]   │
├─────────────────────────────┤
│ January 2026 (8 entries)    │
├─────────────────────────────┤
│ 08 Jan | CREDIT | $200      │ ← Payment (green icon)
│        Tanaka Moyo          │
│        EcoCash Ref: 123456  │
│                             │
│ 07 Jan | DEBIT  | $250      │ ← Invoice (blue icon)
│        Invoice INV-00124    │
│        Chipo Madzimure      │
│                             │
│ 05 Jan | CREDIT | $150      │
│        Multiple students    │
│        (Batch payment)      │
│                             │
│ [Load more...]              │
└─────────────────────────────┘
```

---

#### 4. **Configs Screen** (Less Frequent, But Important)
**Purpose:** Manage fees, school settings, backups

**Layout A: Configs Menu**
```
┌─────────────────────────────┐
│ Settings & Configuration    │
├─────────────────────────────┤
│ 🏫 School Profile           │
│   Harare High School        │
│   [Edit Details]            │
├─────────────────────────────┤
│ 💰 Fee Charges              │
│   • Tuition: $200 USD       │
│   • Levies: $50 USD         │
│   • Boarding: $100 USD      │
│   • Transport: $30 USD      │
│   [Manage Fees]             │
├─────────────────────────────┤
│ 📅 Academic Calendar        │
│   Current Term: Term 1      │
│   Dates: 02 Jan - 28 Mar    │
│   [Manage Terms]            │
├─────────────────────────────┤
│ 🔄 Sync & Backup            │
│   Last Sync: 2 hours ago    │
│   [Sync Now] [Export Data]  │
├─────────────────────────────┤
│ ⚙️ Advanced Settings         │
│   [Language] [Theme] [Help] │
└─────────────────────────────┘
```

---

## 🎯 MASSIVE TASK SCREENS (Batch Operations)

### **Screen 5: Learner Selection (CRITICAL)**

**Use Case:** "Generate invoices for Form 1"

#### **5.1 Selection Mode - List View**
```
┌─────────────────────────────┐
│ [X] Generate Invoices       │ ← Header shows action
├─────────────────────────────┤
│ Form 1 (8 learners)         │
├─────────────────────────────┤
│ ☐ Tanaka Moyo              │ ← Checkbox (left side)
│   Balance: -$150 USD        │
│                             │
│ ☑ Chipo Madzimure          │ ← Pre-selected (has owing fees)
│   Balance: -$200 USD        │
│                             │
│ ☑ Kudzai Zvenyika          │
│   Balance: -$85 USD         │
│                             │
│ ☐ Tinashe Mapuranga        │
│   Balance: +$50 USD         │
│   (Paid up - grayed out)    │
│                             │
│ ☐ [Select All]              │
│ ☑ [Select Only Owing]       │
├─────────────────────────────┤
│ Selected: 2 learners        │ ← Counter at bottom
│ Total Invoice: $450 USD     │
│                             │
│ [Cancel]   [Generate Now]   │ ← Sticky footer
└─────────────────────────────┘
```

**Key Features:**
- Large checkboxes (min 48px touch target)
- Show learner status + balance right-aligned
- Color coding: Green (paid), Red (owing), Gray (disabled)
- Smart pre-selection: "Owing fees only"
- Real-time total calculation
- Sticky footer with action buttons

#### **5.2 Batch Selection - Grid Toggle View**
```
┌─────────────────────────────┐
│ Select Learners   [List/Grid]│ ← Toggle view
├─────────────────────────────┤
│ ┌──────┐ ┌──────┐           │
│ │ ☑    │ │ ☑    │ Grid      │
│ │ T.M. │ │ C.M. │ View      │
│ │ $150 │ │ $200 │           │
│ └──────┘ └──────┘           │
│                             │
│ ┌──────┐ ┌──────┐           │
│ │ ☐    │ │ ☐    │           │
│ │ K.Z. │ │ T.M. │           │
│ │ $85  │ │ Paid │           │
│ └──────┘ └──────┘           │
├─────────────────────────────┤
│ Selected: 2 | Total: $450   │
│ [Cancel]   [Generate Now]   │
└─────────────────────────────┘
```

**Advantage:**
- Better overview for touch
- Visual cards easier to tap
- Shows more info at glance

---

### **Screen 6: Payment Recording (High Frequency)**

#### **6.1 Quick Payment Entry**
```
┌─────────────────────────────┐
│ < Record Payment     [Help] │
├─────────────────────────────┤
│                             │
│ 💰 Amount                   │
│ ┌─────────────────────────┐ │
│ │ $ [_____________]       │ │ ← Large input, right-aligned
│ │      0.00 USD           │ │
│ └─────────────────────────┘ │
│                             │
│ 🏦 Payment Method           │
│ ┌─────────────────────────┐ │
│ │ [EcoCash] [Cash] [Bank] │ │ ← Pill buttons
│ └─────────────────────────┘ │
│                             │
│ 📲 EcoCash Reference        │
│ ┌─────────────────────────┐ │
│ │ [_____________________] │ │
│ │ e.g., 123456789        │ │
│ └─────────────────────────┘ │
│                             │
│ 👤 Learner                  │
│ ┌─────────────────────────┐ │
│ │ [Search/Tap to select]  │ │ ← Dropdown trigger
│ │ (No learner selected)   │ │
│ └─────────────────────────┘ │
│                             │
│ 📝 Notes (Optional)         │
│ ┌─────────────────────────┐ │
│ │ [_____________________] │ │
│ │                        │ │
│ └─────────────────────────┘ │
│                             │
│ [Clear]   [Save Payment]    │
└─────────────────────────────┘
```

#### **6.2 Learner Picker (Modal/Sheet)**
```
┌─────────────────────────────┐
│ Select Learner              │ ← Modal header
├─────────────────────────────┤
│ [Search learners...]        │ ← Search box
├─────────────────────────────┤
│ FORM 1                      │
│ ├─ Tanaka Moyo              │
│ │  Outstanding: $150        │
│ ├─ Chipo Madzimure          │
│ │  Outstanding: $200        │
│                             │
│ FORM 2                      │
│ ├─ Kudzai Zvenyika          │
│ │  Outstanding: $0 (Paid)   │
│                             │
│ [Cancel]                    │
└─────────────────────────────┘
```

#### **6.3 Payment Confirmation**
```
┌─────────────────────────────┐
│ ✅ Confirm Payment          │
├─────────────────────────────┤
│                             │
│ Amount: $200.00 USD         │
│ Learner: Tanaka Moyo        │
│ Method: EcoCash             │
│ Reference: 123456789       │
│                             │
│ Allocation:                 │
│ • Invoice INV-00120: $150   │
│ • Invoice INV-00121: $50    │
│                             │
│ 📅 Date: Today 14:32        │
│                             │
│ [Edit]   [Confirm]          │
└─────────────────────────────┘
```

---

### **Screen 7: Bulk Invoice Generation**

#### **7.1 Invoice Generation Wizard - Step 1**
```
┌─────────────────────────────┐
│ Generate Invoices           │ Step 1 of 3
├─────────────────────────────┤
│                             │
│ 📍 Select Scope             │
│ ┌─────────────────────────┐ │
│ │ ◉ All Learners          │ │ ← Radio buttons
│ │ ○ By Form               │ │
│ │ ○ By Fee Status         │ │
│ │ ○ Custom Selection      │ │
│ └─────────────────────────┘ │
│                             │
│ 📅 Term/Period             │
│ ┌─────────────────────────┐ │
│ │ [Term 1, 2026]          │ │ ← Dropdown
│ └─────────────────────────┘ │
│                             │
│ 💾 Fee Set                  │
│ ┌─────────────────────────┐ │
│ │ [Standard Fees]         │ │
│ │ Tuition: $200           │ │
│ │ Levies: $50             │ │
│ │ Total per Learner: $250 │ │
│ └─────────────────────────┘ │
│                             │
│ [Back]   [Next (8 to bill)]│ ← Shows count
└─────────────────────────────┘
```

#### **7.2 Invoice Generation Wizard - Step 2 (Selection)**
```
┌─────────────────────────────┐
│ Select Learners             │ Step 2 of 3
├─────────────────────────────┤
│                             │
│ Form 1 (12 total)           │
│ ☑ [Select All Form 1]       │
│                             │
│ ☑ Tanaka Moyo              │
│   Owes: $0 (Paid up)        │
│                             │
│ ☑ Chipo Madzimure          │
│   Owes: $200 (Include?)     │
│                             │
│ ☐ Kudzai Zvenyika          │
│   Owes: $0 (Paid up)        │
│                             │
│ Form 2 (8 total)            │
│ ☐ [Select All Form 2]       │
│   (Grayed: all paid up)     │
│                             │
│ Selected: 2                 │
│ Total Invoice Value: $450   │
│                             │
│ [Back]   [Next]             │
└─────────────────────────────┘
```

#### **7.3 Invoice Generation Wizard - Step 3 (Review & Generate)**
```
┌─────────────────────────────┐
│ Review & Generate           │ Step 3 of 3
├─────────────────────────────┤
│                             │
│ 📊 Summary                  │
│ Learners: 2                 │
│ Invoices to Generate: 2     │
│ Total Value: $450 USD       │
│ Payment Terms: NET 30       │
│                             │
│ 📋 Invoice Details:         │
│ • INV-00125: Tanaka $250    │
│ • INV-00126: Chipo $200     │
│                             │
│ ✓ Send SMS notification?    │
│   (If phone numbers exist)  │
│                             │
│ ✓ Auto-generate next month? │
│   (Recurring fees)          │
│                             │
│ ⚠️ This cannot be undone    │
│                             │
│ [Back]   [Generate Now]     │
└─────────────────────────────┘
```

#### **7.4 Generation In Progress**
```
┌─────────────────────────────┐
│ Generating Invoices...      │
├─────────────────────────────┤
│                             │
│ ⏳ Processing               │
│ ███████░░░░ 70%             │
│                             │
│ Generated: 2 of 2           │
│                             │
│ • INV-00125 ✓               │
│ • INV-00126 ✓               │
│                             │
│ [Processing cannot be       │
│  interrupted]               │
│                             │
│                             │
│                             │
│ [Please wait...]            │
└─────────────────────────────┘
```

#### **7.5 Success State**
```
┌─────────────────────────────┐
│ ✅ Invoices Generated!      │
├─────────────────────────────┤
│                             │
│ 2 invoices created          │
│ Total: $450 USD             │
│                             │
│ 📄 INV-00125 (Tanaka)       │
│    $250.00 | Due: 07 Feb    │
│                             │
│ 📄 INV-00126 (Chipo)        │
│    $200.00 | Due: 07 Feb    │
│                             │
│ ✓ SMS sent to 2 learners    │
│   (where available)         │
│                             │
│ [View Ledger] [View All]    │
└─────────────────────────────┘
```

---

### **Screen 8: Fee Allocation Manager**

#### **8.1 Learner Fee Allocation**
```
┌─────────────────────────────┐
│ < Tanaka Moyo      [Menu]  │
├─────────────────────────────┤
│ Form 1A | Active            │
│                             │
│ 📋 Fee Allocations:         │
├─────────────────────────────┤
│                             │
│ ✓ Tuition                   │
│   $200.00 USD               │
│   [Tap to edit]             │
│                             │
│ ✓ Levies                    │
│   $50.00 USD                │
│   [Tap to edit]             │
│                             │
│ ☐ Transport                 │
│   $30.00 USD                │
│   [Add to allocation]       │
│                             │
│ ☐ Boarding                  │
│   (Not applicable)          │
│                             │
├─────────────────────────────┤
│ Total Allocated: $250.00    │
│                             │
│ [Cancel] [Save Changes]     │
└─────────────────────────────┘
```

---

## 📊 Screen Count & Complexity Matrix

| Category | Screen Name | Complexity | Frequency | Priority |
|----------|-------------|-----------|-----------|----------|
| **CORE (4)** | Dashboard | Medium | Daily | P0 |
| | Learners List | Medium | Daily | P0 |
| | Learners Detail | Medium | Daily | P0 |
| | Finance Ledger | High | Daily | P0 |
| **ACTIONS (8)** | Learner Selection | HIGH | Weekly | P1 |
| | Payment Recording | HIGH | Daily | P0 |
| | Invoice Generation | VERY HIGH | Weekly | P1 |
| | Fee Allocation | Medium | Weekly | P2 |
| | Configs/Settings | Low | Monthly | P3 |
| | Search/Filter | Medium | Daily | P1 |
| | Learner Edit Form | Medium | Weekly | P2 |
| | Batch Operations | VERY HIGH | Weekly | P1 |
| **MODALS (6)** | Learner Picker | Medium | Frequent | P1 |
| | Confirmation Dialog | Low | Frequent | P0 |
| | Date Picker | Low | Frequent | P1 |
| | Error/Success Toast | Low | Frequent | P0 |
| | Loading Spinner | Low | Frequent | P0 |
| | Form Validation | Low | Frequent | P0 |

**Total Unique Screens: 18**  
**Total With Variations: ~25-30**  
**Estimated Build Time:** 4-5 weeks for full implementation

---

## 🎨 Mobile-Specific Design Patterns

### **Pattern 1: Bottom Sheet for Secondary Actions**
```
User taps [Menu] on learner card
        ↓
Bottom sheet slides up (doesn't cover top)
        ↓
Options:
  • View Invoice History
  • Edit Fee Allocation
  • Generate Invoice
  • Delete Learner
        ↓
User taps option or swipes down to close
```

### **Pattern 2: Swipe Actions (List Items)**
```
List item (learner card):
  Left swipe → [Delete] [Archive]
  Long press → Toggle checkbox
```

### **Pattern 3: Floating Action Button (FAB) for Primary Action**
```
Dashboard:
  FAB: [+] → Quick menu: 
    • New Learner
    • Record Payment
    • Generate Invoice
    
Learners screen:
  FAB: [+] → Add new learner form
  
Finance screen:
  FAB: [+] → Record payment
```

### **Pattern 4: Tab Navigation (Mobile Bottom, Web Top)**
```
Mobile:
┌──────────────────────────┐
│ [Content]                │
├──────────────────────────┤
│ 🏠 📚 💰 ⚙️              │ ← Tab bar (sticky)

Web (1200px+):
┌────────┬───────────────┐
│🏠📚💰⚙️│ [Content]     │
│        │               │
└────────┴───────────────┘
```

### **Pattern 5: Snackbar for Feedback**
```
[Action performed]
     ↓
Snackbar slides in from bottom:
  "✓ Learner added successfully" [Undo]
     ↓
  (Auto-dismisses after 4s)
```

---

## 🔐 Mobile-Specific Safety Features

### **1. Confirmation for Destructive Actions**
```
User taps [Delete Learner]
        ↓
Dialog:
  "⚠️ Delete Tanaka Moyo?"
  "This cannot be undone."
  [Cancel] [Delete]
```

### **2. Duplicate Detection**
```
User taps [Generate Invoices]
        ↓
System checks: "Invoice already generated for Jan 2026?"
        ↓
Warning: "Invoices for this period exist. Generate anyway?"
        ↓
[Cancel] [Skip Duplicates] [Generate All]
```

### **3. Offline Indicator**
```
┌─────────────────────────────┐
│ 🔴 Offline - Changes cached │ ← Red banner
│ [Retry] [View Cache]        │
├─────────────────────────────┤
│ [Normal content]            │
```

---

## 📐 Mobile Dimensions & Spacing

### **Touch Targets**
```
Minimum: 44×44 pt (iOS), 48×48 dp (Android)
Recommended for most: 56×56 dp
Spacing between targets: 8 dp minimum
```

### **Typography (Mobile)**
```
Header:     20-24 sp (bold)
Subheader:  16-18 sp (semi-bold)
Body:       14 sp (regular)
Caption:    12 sp (regular)
Small:      10 sp (gray)
```

### **Layout Widths**
```
Phone (320-480px):   Full width, no margins
Phablet (480-600px): 90% width, centered
Tablet (600px+):     600px max, centered
```

---

## 🚀 Implementation Priority (Phase by Phase)

### **Phase 1: MVP (Week 1-2)**
- ✅ Dashboard (already exists, polish only)
- ✅ Learners List & Detail
- ⏳ Payment Recording
- ⏳ Simple ledger view

### **Phase 2: Core Features (Week 3-4)**
- 🟡 Learner Selection (batch)
- 🟡 Invoice Generation (wizard)
- 🟡 Fee Allocation Manager
- 🟡 Advanced filters

### **Phase 3: Polish (Week 5)**
- 🟡 Offline indicators
- 🟡 Animations/transitions
- 🟡 Error states
- 🟡 Accessibility (a11y)

---

## ✨ Quick Reference: Main Screen Flows

**Flow 1: Record Payment (Most Common)**
```
Dashboard [Record Payment FAB]
     ↓
Payment Entry Form
  ├─ Amount
  ├─ Method (EcoCash/Cash/Bank)
  ├─ Reference (optional)
  └─ Learner (picker modal)
     ↓
Confirm Payment Dialog
     ↓
Success & Ledger updated
```

**Flow 2: Generate Invoices (Weekly)**
```
Dashboard [Quick Action: "Generate Invoices"]
     ↓
Invoice Wizard Step 1 (Scope)
     ↓
Invoice Wizard Step 2 (Selection) ← MASSIVE SELECTION UI
     ↓
Invoice Wizard Step 3 (Review)
     ↓
Progress bar
     ↓
Success & Ledger updated
```

**Flow 3: Manage Learner**
```
Learners Tab
     ↓
Learner Card [Tap]
     ↓
Learner Detail View
  ├─ Personal Info
  ├─ Financial Standing
  ├─ Fee Allocations
  └─ Transaction History
     ↓
[Menu] → Edit/Delete/Generate Invoice
```

---

## 📝 Summary: Total Screen Deliverables

**SCREENS TO BUILD:**
1. ✅ Dashboard (exists, polish)
2. 🟡 Learners List (paginated, searchable)
3. 🟡 Learners Detail (expandable card)
4. 🟡 Finance Dashboard (overview KPIs)
5. 🟡 Finance Ledger (scrollable transactions)
6. 🟡 **Learner Selection** (batch with checkboxes) ⭐
7. 🟡 **Payment Recording** (form + confirmation) ⭐
8. 🟡 **Invoice Wizard** (3-step flow) ⭐
9. 🟡 Fee Allocation Manager
10. 🟡 Configs/Settings Menu
11. 🟡 Learner Search Results
12. 🟡 Learner Add/Edit Form
13. 🟡 School Profile Edit
14. 🟡 Fee Charge Manager
15. 🟡 Academic Calendar Manager

**MODALS & COMPONENTS:**
- Learner Picker Modal
- Date Picker
- Confirmation Dialogs (5 variations)
- Payment Method Selector
- Form Validation Messages
- Snackbar Notifications
- Loading Spinners
- Empty States (5 variations)
- Error States (4 variations)

**TOTAL:** 15 screens + 14 modals/components = **~29 unique UIs**

---

**Estimated Development Time:**
- **MVP (4 screens):** 1 week
- **Full Feature Set (14 screens):** 4-5 weeks
- **Polish & Testing:** 1 week
- **Total:** 6 weeks end-to-end

Ready to start Figma prototypes or begin implementation? 🎨
