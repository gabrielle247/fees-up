# Admin Service Quick Reference

## Setup

```dart
// 1. Initialize admin context (do this once when admin logs in)
final adminContext = ref.read(adminContextProvider.notifier);
adminContext.initializeContext(
  schoolId: userProfile['school_id'],
  userId: userProfile['id'],
);
```

### Generate Teacher Access Code

```dart
final adminService = ref.read(adminServiceProvider);

final code = await adminService.generateTeacherAccessCode(
  teacherId: 'TCH-001',
  permissionType: 'attendance', // or 'campaigns' or 'both'
  expiresIn: Duration(hours: 2),
);
// Share code: ABC123 with student admin
```

### Manage Access Codes

```dart
// Get all active codes
final codes = await adminService.getActiveAccessCodes();

// Revoke a code (mark as used)
await adminService.revokeAccessCode('token-id');

// Check if code exists
final token = await adminService.getAccessTokenByCode('ABC123');
```

### Create Attendance Session

```dart
final sessionId = await adminService.createAttendanceSession(
  accessCode: 'ABC123',
  classId: 'CLS-456',
  teacherId: 'TCH-001',
  sessionDate: DateTime.now(),
);
```

### Mark Attendance

```dart
await adminService.markBulkAttendance(
  sessionId: 'sess-123',
  classId: 'CLS-456',
  attendanceDate: DateTime.now(),
  attendanceData: [
    {'studentId': 'STU-001', 'status': 'present'},
    {'studentId': 'STU-002', 'status': 'absent'},
  ],
);
```

### Manage Attendance Sessions

```dart
// Get all school sessions
final sessions = await adminService.getSchoolAttendanceSessions();

// Get pending sessions for teacher
final pending = await adminService.getPendingAttendanceSessions('TCH-001');
```

### Campaign Management

```dart
// Create campaign
final campaignId = await adminService.createCampaign(
  title: 'School Renovation Fund',
  description: 'Raising funds for campus renovation',
  goalAmount: 100000,
);

// Get all campaigns
final campaigns = await adminService.getSchoolCampaigns();

// Update campaign status
await adminService.updateCampaignStatus(campaignId, 'completed');
```

### Dashboard & Reporting

```dart
// Get dashboard metrics
final dashboard = await adminService.getSchoolDashboard();
print(dashboard['studentCount']);
print(dashboard['totalRevenue']);
print(dashboard['outstandingBills']);

// Get students with financial data
final students = await adminService.getStudentsWithFinancials();

// Get detailed student report
final report = await adminService.getStudentFinancialReport('STU-123');
```

### Audit Logs

```dart
// Permission audit (who accessed what)
final permAudit = await adminService.getPermissionAuditLog();

// Attendance audit (who marked attendance)
final attAudit = await adminService.getAttendanceAuditLog();
```

### Providers (for UI)

```dart
// In ConsumerWidget:
final accessCodes = ref.watch(accessCodesProvider);
final dashboard = ref.watch(schoolDashboardProvider);
final campaigns = ref.watch(schoolCampaignsProvider);
final sessions = ref.watch(attendanceSessionsProvider);
final students = ref.watch(studentsWithFinancialsProvider);
final permAudit = ref.watch(permissionAuditProvider);
final attAudit = ref.watch(attendanceAuditProvider);
```

### Common Workflows

**Delegate Attendance Marking:**
```dart
1. Admin: Generate code
   final code = await adminService.generateTeacherAccessCode(
     teacherId: 'teacher-1',
     permissionType: 'attendance',
     expiresIn: Duration(hours: 2),
   );
   
2. Share code with student_admin

3. Student Admin: Create session
   final sessionId = await adminService.createAttendanceSession(
     accessCode: code,
     classId: 'class-1',
     teacherId: 'teacher-1',
     sessionDate: DateTime.now(),
   );
   
4. Student Admin: Mark attendance
   await adminService.markBulkAttendance(
     sessionId: sessionId,
     classId: 'class-1',
     attendanceDate: DateTime.now(),
     attendanceData: [...],
   );
   
5. Teacher: Reviews and confirms session (in teacher app)
```

**Launch Campaign:**
```dart
1. Admin: Create campaign
   final id = await adminService.createCampaign(
     title: 'Fundraiser',
     goalAmount: 50000,
   );
   
2. Admin: Monitor progress
   final campaigns = await adminService.getSchoolCampaigns();
   
3. Admin: Update status
   await adminService.updateCampaignStatus(id, 'completed');
```

### Error Handling

```dart
try {
  await adminService.createAttendanceSession(...);
} on Exception catch (e) {
  if (e.toString().contains('Invalid access code')) {
    // Show: "Access code not found or invalid"
  } else if (e.toString().contains('expired')) {
    // Show: "Access code has expired"
  } else if (e.toString().contains('not initialized')) {
    // Initialize context first
  } else {
    // Show generic error
  }
}
```

### Tables Created

**teacher_access_tokens**: One-time codes for teachers to delegate work
- id, school_id, teacher_id, granted_by_teacher_id
- access_code (unique), permission_type
- is_used, used_at, expires_at, created_at

**attendance_sessions**: Sessions where student_admin marks attendance
- id, school_id, class_id, teacher_id, student_admin_id
- access_token_id, session_date
- is_confirmed_by_teacher, confirmed_at, created_at

### Supabase RLS Policies

- ✅ Teachers can create access tokens
- ✅ Student admins can view unused tokens
- ✅ Student admins can create sessions with valid tokens
- ✅ Teachers can confirm sessions
- ✅ School admins can view all sessions
- ✅ Full audit trail of all operations

### Key Features

✅ One-time access codes (prevent reuse)
✅ Configurable expiration times
✅ Teacher approval required
✅ Bulk attendance marking
✅ Campaign management
✅ Complete audit trail
✅ Offline-first with sync queue
✅ Row-level security (Supabase RLS)
✅ Admin context isolation
✅ Real-time UI updates (Riverpod)

### Role Hierarchy

```
super_admin (system)
  ├─ school_admin (school owner)
  │   ├─ student_admin (manages student/billing)
  │   └─ teachers_admin (manages teachers)
  │
  ├─ teacher (class educator)
  │   └─ can approve delegated work
  │
  └─ student (learner)
```

### Next Steps

1. Implement Supabase RLS policies
2. Add SMS/Email notification integration
3. Create admin UI for managing codes
4. Add approval workflow UI
5. Implement teacher app to confirm sessions
6. Add analytics dashboard
7. Create audit report exports
