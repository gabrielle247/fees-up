# 🎯 ALPHA RELEASE TODO - Critical Analysis
**Date**: January 5, 2026  
**Target**: 6:00 PM Alpha Release  
**Analysis**: Comprehensive codebase audit for production-blocking issues

---

## 🔥 CRITICAL (Must Fix Before 6PM Release)

### 1. **School ID Security Architecture** 🚨 CRITICAL
**File**: `lib/main.dart` (lines 85-100)  
**Issue**: School validation engine doesn't pull security rules when PowerSync is active
```dart
// ❌ CURRENT: Defers security to "next login" - defeats PowerSync purpose
if (schoolId != null) {
  SecuritySyncService().pullSecurityRules(schoolId, authService.currentDeviceId);
} else {
  debugPrint("⚠️ No school_id in auth metadata. Security rules will pull on next login.");
}
```

**Impact**: Users with active PowerSync sessions bypass school validation
- Security rules not enforced until manual re-login
- Multi-school users can access wrong school data
- RLS policies not properly scoped

**Solution**:
- [ ] Force school_id injection into PowerSync credentials on init
- [ ] Add fallback: query user_profiles.school_id from local DB
- [ ] Block app access if school_id missing (don't defer to "next login")
- [ ] Add school validation to every PowerSync connection attempt

**Estimated Time**: 2-3 hours

---

### 2. **Billing Settings - Fully Potemkin** 🚨 CRITICAL
**File**: `lib/pc/widgets/settings/billing_config_card.dart`  
**Issue**: All billing configuration UI is non-functional placeholders

**Non-Working Elements**:
- [ ] Currency selection (line 40) - dropdown not wired
- [ ] Tax rate input (line 42) - "Not currently stored in schema"
- [ ] Annual tuition fee (line 51) - no save logic
- [ ] Registration fee (line 53) - no save logic  
- [ ] Partial payments toggle (line 68-73) - `onChanged: (v) {}` stub
- [ ] Late fee percentage - displayed but not editable
- [ ] Invoice prefix/numbering - not implemented

**Impact**: Schools cannot configure billing = **APP IS UNUSABLE**

**Solution**:
- [ ] Wire all inputs to `billing_configs` table via DatabaseService
- [ ] Create BillingConfigState notifier for form management
- [ ] Add Save/Cancel buttons with validation
- [ ] Pull existing config on load (offline-first)
- [ ] Add success/error feedback
- [ ] Cache settings locally for offline editing

**Files to Create/Modify**:
- `lib/data/providers/billing_config_provider.dart` (new)
- `lib/pc/widgets/settings/billing_config_card.dart` (refactor)

**Estimated Time**: 4-5 hours

---

### 3. **Notification System - Incomplete Throughout** 🚨 CRITICAL
**Files**: 
- `lib/pc/widgets/settings/notifications_settings_view.dart`
- `lib/data/providers/notifications_provider.dart`
- `lib/pc/screens/notifications_screen.dart`

**Issues**:
```dart
// ❌ All state is local only - never persists
bool _billingInApp = true;
bool _billingEmail = true;
String _billingFreq = "Immediate";
// ... resets on every app restart
```

**Non-Working Features**:
- [ ] Notification preferences don't save (lines 14-34)
- [ ] "Advanced Filters" button does nothing (line 67)
- [ ] Email frequency dropdowns not functional (line 82)
- [ ] Do Not Disturb schedule not implemented (lines 173-239)
- [ ] Test notification button stub (line 241)
- [ ] Save preferences button stub (line 253)
- [ ] No actual notification delivery system
- [ ] No badge counts or unread tracking

**Impact**: Users cannot control notifications, no notification delivery

**Solution**:
- [ ] Create `notification_preferences` table schema
- [ ] Build NotificationPreferencesService with CRUD
- [ ] Wire all toggles/dropdowns to provider
- [ ] Implement actual in-app notification display
- [ ] Add unread badge counts to sidebar
- [ ] Create notification delivery worker (background)
- [ ] For alpha: Mark DND as "Coming Soon"

**Estimated Time**: 6-8 hours (CUT for alpha - mark "Coming Soon")

---

## ⚠️ HIGH PRIORITY (Post-Alpha if time allows)

### 4. **Password Change - Non-Functional**
**File**: `lib/pc/widgets/profile/security_password_view.dart` (lines 99-102)

```dart
// ❌ Empty handlers
TextButton(onPressed: (){}, child: const Text("Forgot Password?")),
ElevatedButton(onPressed: (){}, child: const Text("Update Password")),
```

**Solution**:
- [ ] Wire "Update Password" to Supabase Auth API
- [ ] Add current password verification
- [ ] Add password strength validator
- [ ] Add confirmation field
- [ ] Show success/error feedback

**Estimated Time**: 2 hours

---

### 5. **Profile Editing - Partially Broken**
**File**: `lib/pc/widgets/profile/personal_info_form.dart`

**Issues**:
- [ ] Form has fields but no save button implementation
- [ ] No validation on email/phone formats
- [ ] Changes don't persist to `user_profiles` table
- [ ] No feedback on save success/failure

**Solution**:
- [ ] Add form validation
- [ ] Wire Save button to DatabaseService.update()
- [ ] Update Supabase auth email if changed
- [ ] Add loading/error states

**Estimated Time**: 2 hours

---

### 6. **Activity Log - Fully Potemkin** ⚠️
**File**: `lib/pc/widgets/profile/activity_log_view.dart`

**Issue**: All activity log entries are hardcoded mock data (lines 38-67)
```dart
_buildLogItem(
  action: "Updated Billing Settings", // ❌ Fake entry
  detail: "Changed late fee percentage from 1.2% to 1.5%",
  time: "2 hours ago",
),
```

**Solution for Alpha**: 
- [ ] Add "Activity logging coming soon" banner
- [ ] Hide "Export Log" button
- [ ] Show empty state with message

**Full Solution (Post-Alpha)**:
- Create `activity_logs` table
- Log all critical actions (create student, payment, settings change)
- Implement real-time feed

**Estimated Time**: 1 hour (alpha version), 6 hours (full)

---

## 📋 MEDIUM PRIORITY (Can Mark "Coming Soon")

### 7. **Two-Factor Authentication - Incomplete**
**File**: `lib/pc/widgets/profile/two_factor_dialog.dart` (line 159)

```dart
// ❌ TODO: Implement verification logic
onPressed: () {
  Navigator.of(context).pop();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text("2FA Enabled Successfully!")),
  );
}
```

**Recommendation**: Mark as "Coming Soon" feature
- [ ] Update UI to show "Coming in v1.1"
- [ ] Disable 2FA setup buttons
- [ ] Add to roadmap documentation

**Estimated Time**: 30 minutes (disable), 8+ hours (full implementation)

---

### 8. **Integrations - All Potemkin**
**File**: `lib/pc/widgets/settings/integrations_settings_view.dart`

**Non-Working**:
- [ ] Google Classroom sync (stub)
- [ ] QuickBooks export (stub)
- [ ] Mailchimp integration (stub)
- [ ] API token generation (stub)
- [ ] Webhook configuration (stub)

**Recommendation**: Mark entire section "Coming Soon"
- [ ] Add banner: "Integrations launching in Phase 2"
- [ ] Keep UI for demo purposes
- [ ] Disable all action buttons

**Estimated Time**: 30 minutes

---

## 🛠️ TOOLBARS & UI POLISH

### 9. **Non-Functional Toolbar Icons**
**Locations**: Found 23 instances across codebase

**Examples**:
```dart
// Settings Header (2 icons)
IconButton(onPressed: () {}, icon: Icon(Icons.sync))         // Line 181
IconButton(onPressed: () {}, icon: Icon(Icons.help_outline)) // Line 186

// Reports Header
IconButton(onPressed: () {}, icon: Icon(Icons.download))     // Line 77

// Transactions Header  
IconButton(onPressed: () {}, icon: Icon(Icons.filter_list))  // Line 84

// Students Header
IconButton(onPressed: () {}, icon: Icon(Icons.file_download)) // Line 102

// Year Configuration
IconButton(onPressed: () {}, icon: Icon(Icons.edit))          // Line 88
```

**Impact**: Users click icons, nothing happens - poor UX

**Solution Options**:
1. **Quick Fix (30 min)**: Hide non-functional icons entirely
2. **Polish (2 hours)**: Add "Coming Soon" tooltips or snackbars
3. **Full (8+ hours)**: Implement actual functionality

**Recommendation for Alpha**: Option 1 or 2

**Estimated Time**: 30 minutes - 2 hours

---

## 📊 SETTINGS CACHING & OFFLINE-FIRST

### 10. **Settings Not Caching Properly**
**File**: `lib/data/providers/settings_provider.dart`

**Current Issue**:
```dart
// ✅ FIXED: Now fetches from DB, but...
final result = await db.db.getAll(
  'SELECT theme_mode, two_factor_enabled, session_timeout_minutes FROM user_settings LIMIT 1',
);

// ❌ PROBLEM: Only works if tables exist
// No offline caching strategy
// No graceful degradation
```

**Missing**:
- [ ] Local state cache for offline editing
- [ ] Optimistic updates (change UI immediately, sync later)
- [ ] Conflict resolution (what if setting changed on another device?)
- [ ] Schema validation (what if tables don't exist yet?)

**Solution**:
- [ ] Add Hive/SharedPreferences cache layer
- [ ] Implement offline queue for pending changes
- [ ] Add schema migration check
- [ ] Show offline indicator when editing without sync

**Estimated Time**: 3-4 hours

---

### 11. **School Preferences - Not PowerSync Aware**
**File**: `lib/data/providers/settings_provider.dart` (lines 59-91)

**Issue**: School preferences query assumes online connection
```dart
final result = await db.db.getAll(
  'SELECT notify_payment, notify_overdue, default_landing_page 
   FROM school_preferences WHERE school_id = ?',
  [dashboard.schoolId],
);
```

**Problem**: If PowerSync hasn't synced `school_preferences` table yet, returns empty

**Solution**:
- [ ] Check PowerSync sync status before query
- [ ] Fall back to sensible defaults immediately
- [ ] Cache last-known-good preferences
- [ ] Add "Settings may be outdated" warning when offline

**Estimated Time**: 2 hours

---

## 🎯 ALPHA RELEASE STRATEGY

### **MUST FIX (Total: ~10 hours)**
1. ✅ School ID security (3h) - **CRITICAL**
2. ✅ Billing settings wiring (5h) - **CRITICAL**
3. ✅ Hide non-functional icons (30min) - **UX BLOCKER**
4. ✅ Password change basics (2h) - **USER EXPECTATION**

### **MARK "COMING SOON" (Total: ~2 hours)**
5. ✅ Two-Factor Auth (30min)
6. ✅ Integrations (30min)
7. ✅ Advanced Notifications (30min)
8. ✅ Activity Log export (30min)

### **POST-ALPHA BACKLOG**
- Full notification system (8h)
- Activity logging (6h)
- Settings offline caching (4h)
- Profile editing validation (2h)
- All toolbar functionality (8h)

---

## 📝 IMPLEMENTATION PRIORITY ORDER

**Hour 1-3**: School ID Security Fix
- Fix PowerSync school_id injection
- Add validation guards
- Test multi-school scenarios

**Hour 4-8**: Billing Settings Wiring
- Create provider
- Wire all inputs
- Add save/cancel
- Test offline editing

**Hour 9**: Password Change
- Wire Update button
- Add validation
- Test flow

**Hour 10**: Polish & "Coming Soon" Banners
- Hide broken icons
- Add "Coming Soon" notices
- Update tooltips

---

## ✅ DEFINITION OF "ALPHA READY"

An alpha is ready when:
- [x] Core functionality works (students, payments, bills)
- [ ] **No broken UI elements that do nothing when clicked** ← FIX THIS
- [ ] **Settings persist between sessions** ← FIX THIS
- [ ] **Security validates on every launch** ← FIX THIS
- [x] Users can complete primary workflows
- [ ] "Coming Soon" features clearly marked
- [x] Zero critical errors in console

**Current Status**: 4/7 ✅ (57%)  
**Target**: 7/7 ✅ (100%) by 6:00 PM

---

## 🚀 POST-ALPHA ROADMAP

### v1.1 (Week 2)
- Full notification system
- Activity logging
- Profile editing enhancements

### v1.2 (Week 3-4)
- Two-factor authentication
- Settings offline optimization
- All toolbar functionality

### v2.0 (Month 2)
- Integrations (Google, QuickBooks, etc.)
- Advanced reporting
- Multi-tenant architecture

---

**Generated**: 2026-01-05 15:58:00  
**Next Review**: Before 6:00 PM deployment
