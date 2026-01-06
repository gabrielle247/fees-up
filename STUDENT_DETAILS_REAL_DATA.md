# Student Details Screen - Real Data Integration

## Overview
Refactored the student details screen to display **real data from PowerSync database** instead of static/placeholder data.

## Changes Made

### 1. **New StreamProviders for Real-Time Data**
Added four StreamProviders that watch the PowerSync database for live updates:

#### `studentEnrollmentsProvider`
- **SQL**: Fetches enrollments with joined class and teacher info
- **Data**: Real-time list of classes student is enrolled in
- **Updates**: Automatically refreshes when enrollment data changes

#### `studentAttendanceProvider`
- **SQL**: Fetches last 30 attendance records for the student
- **Data**: Individual attendance entries with status (present/absent)
- **Calculation**: Attendance percentage computed from raw data

#### `studentBillsProvider`
- **SQL**: Fetches all bills for the student, ordered by creation date
- **Data**: Bill titles, amounts, payment status, dates
- **Calculation**: Outstanding balance and total paid derived from bill records

#### `studentPaymentsProvider`
- **SQL**: Fetches all payment records for the student
- **Data**: Payment history with amounts, dates, methods
- **Usage**: Can be used for payment history display (future enhancement)

### 2. **Refactored Academic Card (`_buildAcademicDataCard`)**

**Before**: Hardcoded static values
```dart
// Static attendance
"Attendance: 96%"
"142 Days Present"
"6 Days Absent"

// Static class list
"Mathematics - Mr. Johnson - A"
"Science - Ms. Floyd - B+"
// etc.
```

**After**: Real database data with async handling
```dart
attendanceAsync.when(
  data: (attendance) {
    final present = attendance.where((a) => a['status'] == 'present').length;
    final absent = attendance.where((a) => a['status'] == 'absent').length;
    final percent = ((present / (present + absent)) * 100).toStringAsFixed(0);
    // Display calculated values
  },
  loading: () => CircularProgressIndicator(...),
  error: (err, _) => ErrorWidget(...),
)

enrollmentsAsync.when(
  data: (enrollments) {
    // Display real enrollment data from database
    return Column(
      children: enrollments.map((e) => 
        _buildClassItem(
          e['class_name'],
          e['teacher_name'],
          grade,
          AppColors.primaryBlue,
        )
      ).toList(),
    );
  },
  // ... loading/error states
)
```

### 3. **Refactored Financial Card (`_buildFinancialDataCard`)**

**Before**: Hardcoded summary values
```dart
Outstanding: ZWL 1,350.00 (static)
Total Paid: ZWL 2,500.00 (static)
Recent Bills: Hardcoded 3 sample bills
```

**After**: Real aggregated data from bills
```dart
billsAsync.when(
  data: (bills) {
    // Calculate from actual database records
    final totalOwed = bills
      .where((b) => (b['is_paid'] as int?) == 0)
      .fold<double>(0.0, (sum, b) => 
        sum + ((b['total_amount'] as num?)?.toDouble() ?? 0.0)
      );
    
    final totalPaid = bills
      .where((b) => (b['is_paid'] as int?) == 1)
      .fold<double>(0.0, (sum, b) => 
        sum + ((b['total_amount'] as num?)?.toDouble() ?? 0.0)
      );
    
    // Display actual bills from database
    return Column(
      children: bills.take(3).map((bill) {
        final isPaid = (bill['is_paid'] as int?) == 1;
        return Row(
          children: [
            Text(bill['title']),
            Text(NumberFormat.simpleCurrency().format(bill['total_amount'])),
            Icon(isPaid ? Icons.check_circle : Icons.pending_actions),
          ],
        );
      }).toList(),
    );
  },
  // ... loading/error states
)
```

### 4. **Real-Time Updates via PowerSync**
- All data is **live-streamed** from PowerSync
- When school admin updates grades, attendance, or bills → screen auto-refreshes
- No manual refresh needed
- Handles loading and error states gracefully

## Data Flow

```
StudentDetailsScreen
  ↓
  watchStudent (from row click)
    ↓
    studentEnrollmentsProvider (watch enrollments from DB)
    studentAttendanceProvider (watch attendance from DB)
    studentBillsProvider (watch bills from DB)
    studentPaymentsProvider (watch payments from DB)
    ↓
    PowerSync (local SQLite)
    ↓
    Supabase (via sync)
```

## Error Handling

Each provider includes proper error handling:
```dart
.when(
  data: (data) => DisplayData(...),
  loading: () => LoadingSpinner(),
  error: (err, _) => ErrorMessage("Error loading X"),
)
```

## Database Schema Used

### `enrollments` table
- `student_id`, `class_id`, `enrolled_at`
- Joined with `classes` (for `class.name`)
- Joined with `teachers` (for `teacher.full_name`)

### `attendance` table
- `student_id`, `date`, `status` (present/absent/late)

### `bills` table
- `student_id`, `total_amount`, `is_paid`, `title`, `created_at`

### `payments` table
- `student_id`, `amount`, `date_paid`, `method`

## Testing Checklist

- [ ] Open student details - see real attendance percentage calculated
- [ ] Verify enrolled classes match database records
- [ ] Check financial summary adds up from actual bills
- [ ] Update a bill in database - screen should auto-refresh
- [ ] Add new attendance record - percentage updates
- [ ] Error handling works (try with missing data)

## Future Enhancements

1. **Payment History Tab**: Use `studentPaymentsProvider` to show payment history
2. **Attendance Chart**: Visualize attendance trends over time
3. **Bill Download**: Add button to generate PDF invoice
4. **Enrollment Edit**: Allow changing class assignments
5. **Attendance Bulk Upload**: CSV import for attendance

## Offline-First Functionality - PRESERVED ✅

### Key Point: These changes **DO NOT affect offline-first capability**

#### How Offline-First Still Works:

1. **Local Data Source**: All StreamProviders read from **local PowerSync SQLite database**, not Supabase directly
   ```dart
   db.db.watch(...)  // Watches local SQLite, not cloud
   ```

2. **No Changes to Sync Logic**: 
   - ❌ Did NOT modify DatabaseService initialization
   - ❌ Did NOT modify PowerSync connector
   - ❌ Did NOT modify Supabase sync logic
   - ❌ Did NOT add any network calls
   - ✅ Data still syncs in background when online

3. **Offline Behavior**:
   - User opens student details while **offline**: ✅ Shows cached data from local SQLite
   - User makes changes while **offline**: ✅ Stored locally, queued for sync
   - Connection restored: ✅ PowerSync auto-syncs in background
   - User sees live updates: ✅ StreamProviders detect local changes

4. **Data Flow (Offline)**:
   ```
   Student Details Screen
         ↓
   studentBillsProvider.watch()
         ↓
   PowerSync (local SQLite) ← data comes FROM HERE
         ↓
   (Supabase is not queried while offline)
   ```

5. **Data Flow (Online)**:
   ```
   Student Details Screen
         ↓
   studentBillsProvider.watch()
         ↓
   PowerSync (local SQLite) ← always reads from local
         ↓
   PowerSync Sync Engine ← automatically syncs with Supabase in background
   ```

### What Actually Changed:
- **Before**: Reading hardcoded static values (`owed = 1350.00`, `paid = 2500.00`)
- **After**: Reading from local PowerSync database (`SELECT * FROM bills WHERE student_id = ?`)
- **Sync**: PowerSync continues syncing independently (no code changes)

### Result:
The app is now **properly leveraging the offline-first architecture** instead of showing stale hardcoded data. All data always comes from the local database, which stays in sync when online.

## Performance Notes

- Streams are lazy-loaded (only query when card visible)
- PowerSync handles offline sync automatically
- Pagination not implemented (loads all bills - can add LIMIT if needed)
- Consider caching in future if database grows large
