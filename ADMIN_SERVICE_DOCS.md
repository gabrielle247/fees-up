# Admin Service Documentation

## Overview

The Admin Service provides school administrators with a comprehensive interface to manage permission-based delegated operations. This includes:

- **Teacher Access Codes**: One-time codes for delegating attendance marking and campaign creation
- **Attendance Sessions**: Sessions where student admins can mark attendance with teacher approval
- **Campaign Management**: Creating and managing fundraising campaigns
- **School Dashboard**: Comprehensive metrics and reporting
- **Audit Logging**: Full audit trail of all delegated permissions

## Architecture

### Components

1. **AdminService** (`lib/services/admin_service.dart`)
   - High-level admin operations
   - Teacher access token management
   - Attendance session workflows
   - Campaign management
   - Dashboard data aggregation

2. **DatabaseService** (`lib/services/database_service.dart`)
   - Low-level database operations
   - New tables: `teacher_access_tokens`, `attendance_sessions`
   - Sync queue integration for offline-first support

3. **AdminProvider** (`lib/providers/admin_provider.dart`)
   - Riverpod providers for reactive UI updates
   - Admin context management
   - Data streaming providers

4. **RLS Policies** (`supabase_rls_policies.sql`)
   - Row-level security for Supabase
   - Permission-based access control
   - Role-based policies

## Usage Examples

### 1. Initialize Admin Context

```dart
final adminContext = ref.read(adminContextProvider.notifier);
adminContext.initializeContext(
  schoolId: 'SCH-12345',
  userId: 'ADMIN-67890',
);
```

### 2. Generate Teacher Access Code

```dart
final adminService = ref.read(adminServiceProvider);

final accessCode = await adminService.generateTeacherAccessCode(
  teacherId: 'TCH-001',
  permissionType: 'both', // 'attendance', 'campaigns', or 'both'
  expiresIn: Duration(hours: 2),
);

// Share code with student_admin via SMS/Email
print('Access Code: $accessCode');
```

### 3. Create Attendance Session

```dart
final sessionId = await adminService.createAttendanceSession(
  accessCode: 'ABC123', // Code from teacher
  classId: 'CLS-456',
  teacherId: 'TCH-001',
  sessionDate: DateTime.now(),
);
```

### 4. Mark Bulk Attendance

```dart
await adminService.markBulkAttendance(
  sessionId: sessionId,
  classId: 'CLS-456',
  attendanceDate: DateTime.now(),
  attendanceData: [
    {'studentId': 'STU-001', 'status': 'present'},
    {'studentId': 'STU-002', 'status': 'absent', 'remarks': 'Sick'},
    {'studentId': 'STU-003', 'status': 'late'},
  ],
);
```

### 5. Create Campaign

```dart
final campaignId = await adminService.createCampaign(
  title: 'Sports Equipment Fund',
  description: 'Collecting funds for new sports equipment',
  goalAmount: 5000,
);
```

### 6. Get School Dashboard

```dart
final dashboard = await adminService.getSchoolDashboard();

print('Students: ${dashboard['studentCount']}');
print('Total Revenue: Ksh ${dashboard['totalRevenue']}');
print('Outstanding Bills: Ksh ${dashboard['outstandingBills']}');
print('Active Campaigns: ${dashboard['activeCampaigns']}');
print('Pending Sessions: ${dashboard['pendingAttendanceSessions']}');
```

## Permission-Based Workflow

### Attendance Marking Delegation

```
1. School Admin generates access code
   ├─ Specifies teacher
   ├─ Sets permission type: 'attendance'
   └─ Sets expiration: 2 hours
   
2. Code is shared with Student Admin (SMS/Email)

3. Student Admin creates attendance session
   ├─ Provides access code
   ├─ Specifies class and date
   └─ Session created (pending confirmation)
   
4. Student Admin marks attendance for students
   ├─ Bulk upload attendance records
   ├─ Records marked but pending confirmation
   └─ System queued for sync
   
5. Teacher reviews and confirms session
   ├─ Teacher sees pending session
   ├─ Reviews attendance records
   └─ Confirms session (attendance locked)
```

### Campaign Creation Delegation

```
1. School Admin generates access code
   ├─ Specifies teacher
   ├─ Sets permission type: 'campaigns'
   └─ Sets expiration: 24 hours
   
2. Student Admin receives code

3. Student Admin creates campaign
   ├─ Provides access code
   ├─ Enters campaign details
   └─ Campaign created (linked to teacher)
   
4. Teacher can manage their campaigns
   └─ Campaign marked as teacher-authorized
```

## Database Schema

### teacher_access_tokens Table

```sql
CREATE TABLE teacher_access_tokens (
  id TEXT PRIMARY KEY,
  school_id TEXT NOT NULL,
  teacher_id TEXT NOT NULL,
  granted_by_teacher_id TEXT NOT NULL,
  access_code TEXT NOT NULL UNIQUE,
  permission_type TEXT NOT NULL, -- 'attendance', 'campaigns', 'both'
  is_used INTEGER DEFAULT 0,
  used_at TEXT,
  expires_at TEXT NOT NULL,
  created_at INTEGER
);
```

### attendance_sessions Table

```sql
CREATE TABLE attendance_sessions (
  id TEXT PRIMARY KEY,
  school_id TEXT NOT NULL,
  class_id TEXT NOT NULL,
  teacher_id TEXT NOT NULL,
  student_admin_id TEXT NOT NULL,
  access_token_id TEXT NOT NULL,
  session_date TEXT NOT NULL,
  is_confirmed_by_teacher INTEGER DEFAULT 0,
  confirmed_at TEXT,
  created_at INTEGER
);
```

## RLS Policies

### Teacher Access Tokens
- Teachers can view tokens they created
- Student admins can view unused, non-expired tokens
- Only system can mark tokens as used

### Attendance Sessions
- Teachers can view sessions for their classes
- Student admins can view sessions they created
- School admins can view all sessions
- Student admins can create sessions with valid tokens
- Only teachers can confirm sessions

### Attendance Records
- Student admins can mark attendance only with valid session
- Teachers can view confirmed attendance sessions
- Records are tracked by session for audit trail

## Providers (Riverpod)

### State Providers

```dart
// Admin context initialization
adminContextProvider

// Access codes list
accessCodesProvider

// School dashboard metrics
schoolDashboardProvider

// Students with financial data
studentsWithFinancialsProvider

// Campaigns
schoolCampaignsProvider

// Attendance sessions
attendanceSessionsProvider

// Audit logs
permissionAuditProvider
attendanceAuditProvider
```

## Error Handling

```dart
try {
  await adminService.createAttendanceSession(...);
} catch (e) {
  if (e.toString().contains('Invalid access code')) {
    // Handle invalid code
  } else if (e.toString().contains('Access code expired')) {
    // Handle expired code
  } else if (e.toString().contains('Admin context not initialized')) {
    // Initialize context first
  }
}
```

## Audit Trail

### Permission Audit Log

```dart
final auditLog = await adminService.getPermissionAuditLog();

// Returns list of all teacher access tokens with:
// - Teacher ID
// - Permission type granted
// - Timestamp
// - Expiration
// - Whether code was used
```

### Attendance Audit Log

```dart
final attendanceAudit = await adminService.getAttendanceAuditLog();

// Returns list of all attendance sessions with:
// - Student admin who created session
// - Teacher who confirmed
// - Date and time
// - Confirmation status
// - Number of records marked
```

## Security Considerations

1. **Access Codes are One-Time**: Once used, a code cannot be reused
2. **Expiration**: Codes have configurable expiration (default: 4 hours)
3. **Teacher Approval**: All delegated work requires teacher confirmation
4. **Audit Trail**: All operations logged with timestamp and user
5. **RLS Protection**: Supabase RLS policies enforce row-level access
6. **Admin-Only**: All admin operations require school admin role

## Integration with UI

### In Widget

```dart
class AdminDashboard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final context_ = ref.watch(adminContextProvider);
    final dashboard = ref.watch(schoolDashboardProvider);
    
    // Use data from providers
    return dashboard.when(
      data: (data) => Column(...),
      loading: () => Center(child: CircularProgressIndicator()),
      error: (error, st) => Center(child: Text('Error: $error')),
    );
  }
}
```

### With Admin Operations

```dart
final adminService = ref.read(adminServiceProvider);

// Generate code
final code = await adminService.generateTeacherAccessCode(...);

// Invalidate code
await adminService.revokeAccessCode(tokenId);

// Create session
final sessionId = await adminService.createAttendanceSession(...);

// Mark attendance
await adminService.markBulkAttendance(...);
```

## Testing

### Mock Data

```dart
// Create test admin context
adminContext.initializeContext(
  schoolId: 'TEST-SCH-001',
  userId: 'TEST-ADMIN-001',
);

// Generate test access code
final testCode = await adminService.generateTeacherAccessCode(
  teacherId: 'TEST-TCH-001',
  permissionType: 'both',
  expiresIn: Duration(hours: 1),
);

// Create test session
final testSession = await adminService.createAttendanceSession(
  accessCode: testCode,
  classId: 'TEST-CLS-001',
  teacherId: 'TEST-TCH-001',
  sessionDate: DateTime.now(),
);
```

## Troubleshooting

### "Admin context not initialized"
```dart
// Solution: Initialize context before using AdminService
final context = ref.read(adminContextProvider.notifier);
context.initializeContext(
  schoolId: schoolId,
  userId: userId,
);
```

### "Invalid access code"
```dart
// Verify code exists and hasn't expired
final token = await adminService.getAccessTokenByCode(code);
if (token == null) {
  // Code not found
}
```

### "Access code already used"
```dart
// Get fresh access codes
final codes = await adminService.getActiveAccessCodes();
// Use one of the active codes
```

## Future Enhancements

1. **Bulk Code Generation**: Generate multiple codes at once
2. **Permission Revocation**: Revoke permissions mid-session
3. **Attendance Approval Workflow**: Multi-level approvals
4. **Campaign Analytics**: Track campaign performance
5. **SMS/Email Integration**: Auto-send codes to users
6. **Role-Based Permissions**: Fine-grained permission types
