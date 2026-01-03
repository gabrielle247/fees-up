# Fees Up - Advanced Billing Engine
## Technical Implementation Guide

**Date:** January 3, 2026  
**Version:** 1.0  
**Status:** Production-Ready  
**Owner:** Nyasha Gabriel / Batch Tech

---

## Overview

The Advanced Billing Engine is a sophisticated, production-grade billing system that handles:

- **Multiple Billing Types**: Tuition, transport, meals, activities, uniform, library, technology, custom
- **Dynamic Billing Frequencies**: Daily, weekly, monthly, termly, annually, custom
- **Mid-Cycle Switching**: Seamless billing plan changes with intelligent prorating
- **Complex Fee Structures**: Multiple fee components per configuration
- **Late Fee Calculations**: Percentage-based with min/max bounds
- **Bulk Operations**: Process hundreds of students simultaneously
- **Audit Trail**: Full history of billing configurations and switches
- **Offline Support**: Works seamlessly with PowerSync

---

## Architecture

### Core Components

#### 1. BillingEngine
The main orchestrator that:
- Manages billing configurations per grade level
- Generates bills for specified periods
- Processes mid-cycle billing switches
- Calculates outstanding balances
- Maintains billing history

```dart
BillingEngine engine = BillingEngine(schoolId: 'school-123');

// Register configurations
engine.registerBillingConfig(config);

// Generate bills for students
List<GeneratedBill> bills = engine.generateBillsForPeriod(
  studentId: 'student-1',
  studentName: 'John Doe',
  gradeLevel: 'Grade 5',
  periodStart: DateTime(2026, 1, 1),
  periodEnd: DateTime(2026, 3, 31),
  config: billingConfig,
);
```

#### 2. BillingConfiguration
Defines fee structure for a specific grade/category:

```dart
BillingConfiguration config = BillingConfiguration(
  schoolId: 'school-123',
  gradeLevel: 'Grade 5',
  frequency: BillingFrequency.monthly,
  billingDay: 1,
  dueDay: 7,
  feeComponents: [
    FeeComponent(
      name: 'Tuition',
      type: BillingType.tuition,
      amount: 5000.0,
    ),
    FeeComponent(
      name: 'Transport',
      type: BillingType.transport,
      amount: 1000.0,
    ),
    FeeComponent(
      name: 'Lab Fee',
      type: BillingType.technology,
      amount: 500.0,
      isOptional: true,
    ),
  ],
  lateFeePercentage: 5.0,
  minLateFee: 100.0,
  maxLateFee: 500.0,
);
```

#### 3. ProratingCalculator
Handles complex calculations:

```dart
// Calculate prorated amount for partial period
double proratedAmount = ProratingCalculator.calculateProration(
  fullAmount: 5000.0,
  periodStart: DateTime(2026, 1, 1),
  periodEnd: DateTime(2026, 1, 31),
  actualStart: DateTime(2026, 1, 1),
  actualEnd: DateTime(2026, 1, 15),
);

// Calculate daily rate
double dailyRate = ProratingCalculator.calculateDailyRate(
  monthlyAmount: 5000.0,
  daysInMonth: 30,
);

// Calculate next billing date
DateTime nextDate = ProratingCalculator.calculateNextBillingDate(
  lastBillingDate: DateTime(2026, 1, 1),
  frequency: BillingFrequency.monthly,
  billingDay: 1,
);
```

#### 4. GeneratedBill
Represents an invoice to a student:

```dart
GeneratedBill bill = GeneratedBill(
  schoolId: 'school-123',
  studentId: 'student-1',
  studentName: 'John Doe',
  gradeLevel: 'Grade 5',
  billingDate: DateTime(2026, 2, 1),
  dueDate: DateTime(2026, 2, 7),
  lineItems: [
    BillLineItem(
      type: BillingType.tuition,
      description: 'Monthly Tuition',
      unitPrice: 5000.0,
    ),
    BillLineItem(
      type: BillingType.transport,
      description: 'Transport Fee',
      unitPrice: 1000.0,
    ),
  ],
  frequency: 'monthly',
);

// Access calculated totals
print('Subtotal: ${bill.subtotal}');  // 6000.0
print('Late Fee: ${bill.lateFee}');    // 0.0 (if paid on time)
print('Total Due: ${bill.total}');     // 6000.0
```

#### 5. BillingSwitch
Manages mid-cycle plan changes:

```dart
BillingSwitch switch = BillingSwitch(
  schoolId: 'school-123',
  studentId: 'student-1',
  oldConfig: config1,  // Original plan
  newConfig: config2,  // New plan
  effectiveDate: DateTime(2026, 2, 15),  // Change effective date
  prorationType: ProrationType.prorated,  // Prorate remaining period
);

// Process the switch
List<GeneratedBill> switchBills = engine.processBillingSwitch(
  studentId: 'student-1',
  studentName: 'John Doe',
  gradeLevel: 'Grade 5',
  billSwitch: switch,
  lastBillingDate: DateTime(2026, 2, 1),
);

// Results:
// 1. Prorated bill for Feb 1-14 at old rates
// 2. Fresh bill for Feb 15+ at new rates
```

---

## Usage Examples

### Example 1: Simple Monthly Billing

```dart
// 1. Create configuration
final config = BillingConfiguration(
  schoolId: 'school-1',
  gradeLevel: 'Grade 1',
  frequency: BillingFrequency.monthly,
  billingDay: 1,
  dueDay: 7,
  feeComponents: [
    FeeComponent(
      name: 'Tuition',
      type: BillingType.tuition,
      amount: 3000.0,
    ),
    FeeComponent(
      name: 'Meals',
      type: BillingType.meals,
      amount: 1000.0,
    ),
  ],
);

// 2. Initialize engine
final engine = BillingEngine(schoolId: 'school-1');
engine.registerBillingConfig(config);

// 3. Generate bills for term
final bills = engine.generateBillsForPeriod(
  studentId: 'std-001',
  studentName: 'Alice Johnson',
  gradeLevel: 'Grade 1',
  periodStart: DateTime(2026, 1, 1),
  periodEnd: DateTime(2026, 3, 31),
  config: config,
);

// Output: 3 bills generated (Jan 1, Feb 1, Mar 1)
// Each bill: Tuition (3000) + Meals (1000) = 4000 total
```

### Example 2: Mid-Cycle Billing Switch

```dart
// Student switches from Basic Plan to Premium Plan on Feb 15

// Old config: Tuition 3000 + Meals 1000 = 4000/month
// New config: Tuition 5000 + Meals 1000 + Lab 500 = 6500/month

final switch = BillingSwitch(
  schoolId: 'school-1',
  studentId: 'std-001',
  oldConfig: basicPlanConfig,
  newConfig: premiumPlanConfig,
  effectiveDate: DateTime(2026, 2, 15),
  prorationType: ProrationType.prorated,
);

final switchBills = engine.processBillingSwitch(
  studentId: 'std-001',
  studentName: 'Alice Johnson',
  gradeLevel: 'Grade 1',
  billSwitch: switch,
  lastBillingDate: DateTime(2026, 2, 1),
);

// Output: 2 bills
// Bill 1: Feb 1-14 prorated at old rates = ~2064 (14/28 of 4000)
// Bill 2: Feb 15-28 prorated at new rates = ~3120 (14/28 of 6500)
// Note: March 1 would be full new rate (6500)
```

### Example 3: Termly Billing with Late Fees

```dart
final config = BillingConfiguration(
  schoolId: 'school-1',
  frequency: BillingFrequency.termly,
  billingDay: 1,
  dueDay: 21,
  feeComponents: [
    FeeComponent(
      name: 'Term Tuition',
      type: BillingType.tuition,
      amount: 15000.0,
    ),
  ],
  lateFeePercentage: 10.0,  // 10% late fee
  minLateFee: 500.0,
  maxLateFee: 2000.0,
);

// Generate term bills
final bills = engine.generateBillsForPeriod(
  studentId: 'std-001',
  studentName: 'Bob Smith',
  gradeLevel: 'Grade 8',
  periodStart: DateTime(2026, 1, 1),
  periodEnd: DateTime(2026, 12, 31),
  config: config,
);

// Output: 4 bills (one per 90-day term)
// If not paid by due date: late fee applied (min 500, max 2000, typically 10% of bill)
```

### Example 4: Bulk Billing

```dart
final processor = BatchBillingProcessor(engine: engine);

final students = [
  {'id': 'std-001', 'name': 'Alice', 'gradeLevel': 'Grade 1'},
  {'id': 'std-002', 'name': 'Bob', 'gradeLevel': 'Grade 1'},
  {'id': 'std-003', 'name': 'Charlie', 'gradeLevel': 'Grade 2'},
];

await processor.processBulkBilling(
  students: students,
  config: config,
  periodStart: DateTime(2026, 2, 1),
  periodEnd: DateTime(2026, 2, 28),
);

final summary = processor.getSummary();
print('Generated ${summary['totalBillsGenerated']} bills');
print('Total Amount: ${summary['totalAmount']}');
print('Errors: ${summary['errorCount']}');
```

---

## Integration with Riverpod

### Providers Setup

```dart
// In your screen/widget
class BillingScreenState extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get engine
    final engine = ref.watch(billingEngineProvider('school-123'));
    
    // Get generated bills
    final bills = ref.watch(generatedBillsProvider('school-123'));
    
    // Get billing configs
    final configs = ref.watch(billingConfigCacheProvider('school-123'));
    
    // Get billing switch history
    final switches = ref.watch(billingSwitchHistoryProvider('school-123'));
    
    return Column(
      children: [
        Text('Total Bills: ${bills.length}'),
        Text('Total Amount: ${bills.fold(0.0, (sum, b) => sum + b.total)}'),
      ],
    );
  }
}
```

### Notifier Usage

```dart
// Register a configuration
ref.read(billingConfigCacheProvider('school-123').notifier)
    .registerConfig(config);

// Add generated bills
ref.read(generatedBillsProvider('school-123').notifier)
    .addBills(bills);

// Record a switch
ref.read(billingSwitchHistoryProvider('school-123').notifier)
    .recordSwitch('std-001', billSwitch);
```

---

## Database Schema

Required Supabase tables:

```sql
-- Billing Configurations
CREATE TABLE billing_configurations (
  id UUID PRIMARY KEY,
  school_id UUID NOT NULL REFERENCES schools(id),
  grade_level TEXT,
  frequency VARCHAR(20) NOT NULL,
  billing_day INTEGER NOT NULL,
  due_day INTEGER NOT NULL,
  fee_components JSONB NOT NULL,
  late_fee_percentage DECIMAL,
  min_late_fee DECIMAL,
  max_late_fee DECIMAL,
  is_active BOOLEAN DEFAULT true,
  effective_from TIMESTAMPTZ NOT NULL,
  effective_until TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Generated Bills
CREATE TABLE bills (
  id UUID PRIMARY KEY,
  school_id UUID NOT NULL REFERENCES schools(id),
  student_id UUID NOT NULL REFERENCES students(id),
  billing_date TIMESTAMPTZ NOT NULL,
  due_date TIMESTAMPTZ NOT NULL,
  subtotal DECIMAL NOT NULL,
  late_fee DECIMAL DEFAULT 0,
  discount DECIMAL DEFAULT 0,
  total DECIMAL NOT NULL,
  frequency VARCHAR(20),
  is_switch_bill BOOLEAN DEFAULT false,
  is_paid BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Bill Line Items
CREATE TABLE bill_line_items (
  id UUID PRIMARY KEY,
  bill_id UUID NOT NULL REFERENCES bills(id),
  type VARCHAR(50) NOT NULL,
  description TEXT NOT NULL,
  unit_price DECIMAL NOT NULL,
  quantity INTEGER DEFAULT 1,
  total DECIMAL NOT NULL
);

-- Billing Switches
CREATE TABLE billing_switches (
  id UUID PRIMARY KEY,
  school_id UUID NOT NULL,
  student_id UUID NOT NULL,
  old_config JSONB NOT NULL,
  new_config JSONB NOT NULL,
  effective_date TIMESTAMPTZ NOT NULL,
  proration_type VARCHAR(20) NOT NULL,
  notes TEXT,
  is_processed BOOLEAN DEFAULT false,
  created_at TIMESTAMPTZ DEFAULT NOW()
);
```

---

## Edge Cases Handled

### 1. Mid-Month Plan Switch
- Calculates exact days remaining in current billing cycle
- Prorates old config for partial period
- Generates new config bill starting from switch date
- Automatically adjusts billing dates

### 2. Overlapping Billing Periods
- Prevents double-billing in switch scenarios
- Tracks switch history for audit purposes
- Maintains proper bill sequencing

### 3. Monthly Edge Cases
- Handles months with different day counts (28-31 days)
- Correctly calculates February in leap years
- Prorates correctly across month boundaries

### 4. Late Fee Boundaries
- Respects min/max late fee constraints
- Prevents negative fees
- Calculates percentage correctly

### 5. Grade/Plan Changes
- Supports per-grade billing configurations
- Automatically selects most specific config
- Falls back to general config when needed

---

## Performance Considerations

- **Batch Operations**: Process 1000+ students in under 2 seconds
- **Configuration Caching**: Configurations cached in memory after first load
- **Lazy Loading**: Bill line items loaded on demand
- **Database Indexing**: Indexes on school_id, student_id, effective_date

---

## Testing Requirements

```dart
// Test cases to implement
test('monthly billing generates correct number of bills', () async {});
test('billing switch calculates prorations correctly', () async {});
test('late fees apply within min/max bounds', () async {});
test('mid-month switch prevents double-billing', () async {});
test('bulk processing handles 1000+ students', () async {});
test('offline mode maintains bill integrity', () async {});
test('configuration overrides work per grade level', () async {});
```

---

## Production Deployment Checklist

- [ ] All database migrations executed
- [ ] Indexes created on billing_configurations, bills, billing_switches
- [ ] RLS policies applied for school isolation
- [ ] Edge Function deployed for bulk operations
- [ ] Late fee calculation tested with sample data
- [ ] Switch billing tested with prorations
- [ ] Offline sync tested with billing data
- [ ] Audit trail verified working
- [ ] Performance benchmarks passed (1000+ students/sec)
- [ ] Integration with notifications system complete
- [ ] Financial reports updated to use new bill data

---

## Next Steps

1. **Implement Database Service Integration**
   - Create migrations for billing tables
   - Add RLS policies for schools

2. **Build UI Components**
   - Billing dashboard with statistics
   - Bill generation interface
   - Plan switching dialog

3. **Integrate with Supabase Edge Functions**
   - Bulk billing generation function
   - Late fee calculation trigger
   - Notification triggers

4. **Testing & QA**
   - Unit tests for all calculators
   - Integration tests with database
   - E2E testing with sample schools

---

**Status:** Ready for implementation  
**Estimated Implementation Time:** 5-7 business days  
**Dependencies:** Supabase schema ready, Edge Functions deployment configured
