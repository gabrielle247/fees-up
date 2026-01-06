# Settings Screens Wiring Status

## ✅ Fully Wired (Connected to PowerSync)

### 1. **Billing Configuration Card** (`billing_config_card.dart`)
- ✅ Controllers for all form fields
- ✅ Loads from `billing_configs` table
- ✅ Saves to PowerSync with UPDATE statement
- ✅ Reset functionality
- ✅ Loading/Error states
- **Pattern**: billingConfigProvider + controllers + saveConfig method

### 2. **School Year Configuration** (`year_configuration_card.dart`)
- ✅ Controllers for year label, dates, description
- ✅ Loads from `school_years` table
- ✅ Active/Inactive toggle stored as integer
- ✅ Terms stored as JSON in description field
- ✅ Add/remove/edit terms dynamically
- ✅ Save/reset with proper validation
- **Storage**: Terms as JSON: `{"description": "...", "terms": [...]}`

### 3. **School Year Registry** (`school_year_registry_card.dart`)
- ✅ Fixed to read `active` column instead of non-existent `status`
- ✅ Shows Active/Inactive status from database
- ✅ Displays all years with proper sorting

### 4. **Organization Card** (`organization_card.dart`)
- ✅ Controllers for name, address, email
- ✅ Loads from `schools` table
- ✅ Contact info stored as JSON in `contact_info` text field (or falls back to name-only if column doesn't exist)
- ✅ Save/reset functionality
- ✅ Loading/Error states
- **Storage**: `{"address": "...", "email": "..."}`

## ⚠️ Partially Wired

### 5. **Users & Permissions View** (`users_permissions_view.dart`)
- ✅ Has `schoolUsersProvider` that loads from `user_profiles` table
- ✅ Displays users in table
- ✅ Has AddUserDialog for creating users
- ⚠️ Filter dropdowns (Role, Status) are UI-only, don't filter data
- ⚠️ Export button has no handler
- ⚠️ Search field doesn't filter results
- **Next**: Wire filters to actually query the provider

## ❌ Still Potemkin (Mock Data Only)

### 6. **Notifications Settings View** (`notifications_settings_view.dart`)
- ❌ All toggles are local state variables
- ❌ No persistence to database
- ❌ Save button doesn't exist
- **Solution Created**: `notification_preferences_provider.dart` created
- **Storage Plan**: JSON in `schools.notification_prefs` or `local_security_config` table
- **Next**: Replace state variables with provider + add Save button

### 7. **General/Financial View - School Logo** (`general_financial_view.dart`)
- ❌ Logo upload button has no handler
- ❌ No file picker integration
- ❌ No image storage logic
- **Next**: Add file picker, upload to assets or base64 in database

### 8. **General/Financial View - Integrations Card** (`general_financial_view.dart`)
- ❌ Teacher access token is hardcoded "sk_live_8372...9283"
- ❌ Copy button has no handler
- **Next**: Load actual token from `teacher_access_tokens` table

### 9. **Integrations - Teacher Tokens Card** (`integrations/teacher_tokens_card.dart`)
- ❌ All tokens are hardcoded mock data
- ❌ Generate Token button has no handler
- ❌ No CRUD operations
- **Schema Exists**: `teacher_access_tokens` table available
- **Next**: Create provider to load/create/revoke tokens

### 10. **Integrations - Security Permissions Card** (`integrations/security_permissions_card.dart`)
- ❌ Policy toggles are mock data
- ❌ No persistence
- **Next**: Check if schema has security_policies table or use JSON storage

### 11. **Integrations - Connected Services Card** (`integrations/connected_services_card.dart`)
- ❌ All service statuses are hardcoded
- ❌ "Manage" buttons have no handlers
- **Next**: Determine if this needs real integration or can remain UI-only for now

### 12. **Integrations - API Config Card** (`integrations/api_config_card.dart`)
- ❌ Webhook URL and API key are hardcoded
- ❌ Copy/Regenerate buttons have no handlers
- **Next**: Store in `local_security_config` or new api_config column

## Schema Support

### Available Tables for Wiring:
- ✅ `schools` - name, subscription_tier, max_students, is_suspended
- ✅ `user_profiles` - email, full_name, role, school_id, is_banned
- ✅ `teacher_access_tokens` - access_code, permission_type, is_used, expires_at
- ✅ `school_years` - year_label, start_date, end_date, description, active
- ✅ `school_year_months` - name, month_index, start_date, end_date, is_billable
- ✅ `school_terms` - name, start_date, end_date, academic_year
- ✅ `billing_configs` - currency, tax, fees, invoice settings
- ✅ `local_security_config` - key/value storage for misc settings

### Missing Columns (Need JSON Storage):
- `schools.contact_info` - for address/email
- `schools.notification_prefs` - for notification settings
- `schools.logo_url` or `schools.logo_base64` - for school logo

## Implementation Pattern

All wired cards follow this pattern:

```dart
class MyCard extends ConsumerStatefulWidget {
  // 1. Controllers for form fields
  final _controller = TextEditingController();
  
  // 2. State variables
  bool _hydrated = false;
  bool _saving = false;
  
  // 3. Load data from PowerSync
  Future<void> _loadData(String schoolId) async {
    final db = DatabaseService();
    final results = await db.db.getAll('SELECT...');
    if (mounted) setState(() {
      _controller.text = results.first['field'];
      _hydrated = true;
    });
  }
  
  // 4. Save data to PowerSync
  Future<void> _onSave() async {
    final db = DatabaseService();
    await db.db.execute('UPDATE table SET field = ?...', [...]);
    // PowerSync automatically syncs to cloud
  }
  
  // 5. UI with Save/Reset buttons
  // 6. Loading/Error states
}
```

## Priority Order for Remaining Work

1. **High**: Notifications view (adds user value, provider ready)
2. **Medium**: Teacher tokens (security feature, schema ready)
3. **Medium**: Search/filters in Users view (usability)
4. **Low**: School logo upload (nice-to-have)
5. **Low**: API config/webhooks (advanced feature)
6. **Low**: Connected services (may not need real integration)
