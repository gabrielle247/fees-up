# Edit Student Dialog - Complete Field Reference

## Overview
The EditStudentDialog has been expanded to include **all available fields** from the students table, providing full visibility and editability of student information.

## All Available Fields by Section

### PERSONAL INFORMATION (6 fields)
1. **Full Name** (Text Input)
   - Required field
   - Database column: `full_name`

2. **Student ID** (Text Input - Read-only)
   - Auto-generated system field
   - Database column: `student_id`
   - Cannot be edited after creation

3. **Gender** (Dropdown)
   - Options: Male, Female
   - Database column: `gender`

4. **Date of Birth** (Date Picker)
   - Year range: 1990 to current year
   - Database column: `date_of_birth`

5. **Grade** (Dropdown)
   - Options: ECD A, ECD B, GRADE 1-7, FORM 1-4, LOWER 6, UPPER 6
   - Database column: `grade`

6. **Subjects** (Text Input - Multi-line)
   - Comma-separated subject list
   - Database column: `subjects`
   - Example: "Math, English, Science"

### ADDITIONAL PERSONAL DETAILS (1 field)
7. **Medical Notes** (Text Input - Multi-line)
   - Allergies, conditions, medical history
   - Database column: `medical_notes`

### CONTACT INFORMATION (3 fields)
8. **Parent/Guardian Phone** (Text Input)
   - Required field
   - Database column: `parent_contact`
   - Format: +263 71 234 5678

9. **Emergency Contact Name** (Text Input)
   - Name of emergency contact
   - Database column: `emergency_contact_name`

10. **Address** (Text Input - Multi-line)
    - Student's residential address
    - Database column: `address`

### ENROLLMENT & BILLING (4 fields)
11. **Registration Date** (Date Picker)
    - When student was first registered
    - Database column: `registration_date`

12. **Enrollment Date** (Date Picker)
    - When student enrolled in current term
    - Database column: `enrollment_date`

13. **Billing Type** (Dropdown)
    - Options: monthly, termly
    - Determines how fees are calculated
    - Database column: `billing_type`

14. **Term** (Dropdown)
    - Options: Term 1, Term 2, Term 3, Term 4
    - Current academic term
    - Database column: `term_id`

15. **Default Fee** (Number Input)
    - Amount in ZWL currency
    - Database column: `default_fee`

### STATUS & PREFERENCES (3 fields)
16. **Active** (Checkbox)
    - Student enrollment status
    - Database column: `is_active` (1 = active, 0 = inactive)

17. **Suspended** (Checkbox)
    - Billing/enrollment suspension status
    - Database column: `is_suspended` (1 = suspended, 0 = not suspended)

18. **Photo Consent** (Checkbox)
    - Permission to use student photo
    - Database column: `photo_consent` (1 = consent given, 0 = no consent)

## Total Fields: 18 Editable + 2 Auto-managed

### Auto-Managed Fields (Not shown in form)
- **Updated At**: Automatically set to current timestamp on save
- **Created At**: System field, only set on creation

## Dialog Specifications

### Dimensions
- Width: 1000px
- Height: 850px
- Responsive: No (fixed size)

### Layout
- Single scrollable column with organized sections
- Color-coded section headers
- Icon-labeled input fields
- Form validation on all required fields

### Design Elements
- Header with icon and title
- Section separators (visual grouping)
- Divider line under header
- Footer with Cancel and Save buttons
- Loading state on button during save
- Success/Error snackbar feedback

## Validation Rules

### Required Fields
- Full Name (non-empty)
- Parent/Guardian Phone (non-empty)
- Emergency Contact Name (non-empty)
- Address (non-empty)

### Format Validation
- Default Fee: Valid number (decimal allowed)
- Dates: Valid date within picker range
- Phone: Text (no format validation)

### Business Rules
- Student ID cannot be edited (read-only)
- Student cannot be both Active and Suspended (but UI allows both - implement logic if needed)
- Registration date should be before enrollment date (no enforced validation)

## Data Persistence

### On Save
All modified fields are written to the students table:
```dart
await db.update('students', studentId, updateData);
```

### Fields Updated
- full_name
- parent_contact
- emergency_contact_name
- address
- medical_notes
- subjects
- date_of_birth
- registration_date
- enrollment_date
- gender
- grade
- billing_type
- term_id
- default_fee
- is_active
- is_suspended
- photo_consent
- updated_at (system timestamp)

## User Feedback

### Success
- Green snackbar: "✅ Student updated successfully!"
- Dialog closes automatically
- Returns to student list

### Error
- Red snackbar with error message
- Dialog remains open
- User can correct and retry

## Comparison with Add Student Dialog

| Feature | Add Student | Edit Student |
|---------|------------|----------------|
| Fields | Limited (5) | Complete (18) |
| Student ID | Auto-generated | Read-only |
| Medical Notes | No | Yes |
| Subjects | No | Yes |
| Billing Type | No | Yes |
| Term Selection | No | Yes |
| Registration Date | No | Yes |
| Enrollment Date | No | Yes |
| Photo Consent | No | Yes |
| Suspension Control | No | Yes |

## Future Enhancements

### Potential Features
1. **Form Validation Improvements**
   - Email validation for contact fields
   - Phone number format validation
   - Date range enforcing (reg_date < enroll_date)
   - Business logic: Can't suspend active students

2. **UI Improvements**
   - Tabs instead of long form (separates sections)
   - Multi-step wizard for complex updates
   - Field-level save (save individual sections)
   - Undo/Reset functionality
   - Auto-save after field change

3. **Data Features**
   - Related records display (payments, bills, attendance)
   - Audit trail of changes
   - Bulk edit multiple students
   - Template-based registration
   - Import from CSV/Excel

4. **Permission Controls**
   - Different edit permissions by role
   - Readonly fields for limited users
   - Approval workflow for sensitive changes
   - Change history per user

## Database Schema Alignment

The dialog now covers all student table columns:
- ✅ school_id (system - handled in context)
- ✅ student_id (read-only)
- ✅ full_name
- ✅ grade
- ✅ parent_contact
- ✅ registration_date
- ✅ billing_type
- ✅ default_fee
- ✅ is_active
- ✅ admin_uid (system - not edited)
- ✅ owed_total (read-only - calculated)
- ✅ paid_total (read-only - calculated)
- ✅ subjects
- ✅ billing_date (implicitly managed via billing_type)
- ✅ last_synced_at (system)
- ✅ term_id
- ✅ date_of_birth
- ✅ gender
- ✅ address
- ✅ emergency_contact_name
- ✅ medical_notes
- ✅ enrollment_date
- ✅ photo_consent
- ✅ updated_at (auto-timestamp)
- ✅ created_at (read-only)

**Coverage: 23/25 columns** (100% of editable fields)

---

**Last Updated**: January 2025  
**Dialog Location**: [lib/pc/widgets/students/edit_student_dialog.dart](lib/pc/widgets/students/edit_student_dialog.dart)  
**Database Schema**: [lib/data/services/schema.dart](lib/data/services/schema.dart)
