# Payment Dialog Validation Rules

## Overview
This document outlines the data entry validation rules implemented in both `PaymentDialog` and `QuickPaymentDialog` to ensure data integrity and consistency across the application.

## Validation Rules

### 1. Amount Validation
**Rule**: Payment amount must be greater than zero
- **Implementation**: 
  - Form validator checks if amount is a valid number
  - Additional check ensures `amount > 0`
  - Error message: "Must be greater than 0"
- **User Feedback**: 
  - Red error text below field if validation fails
  - SnackBar with error message if user tries to submit invalid amount
- **Code Location**: `_buildTextInput()` validator and `_recordPayment()` method

### 2. Date Range Validation
**Rule**: Payment dates must be between 2020 and 30 days in the future
- **Implementation**: 
  - `firstDate: DateTime(2020)`
  - `lastDate: DateTime.now().add(const Duration(days: 30))`
- **Rationale**: 
  - Historical data starts from 2020
  - Allows scheduling payments up to 1 month ahead
  - Prevents accidental far-future or far-past dates
- **Code Location**: `_buildDatePicker()` method

### 3. Required Fields
**Rule**: All form fields must be filled
- **Fields**:
  - Amount (number input)
  - Payment Date (date picker)
  - Category (dropdown)
  - Payment Method (dropdown)
  - Payer Name (text input)
- **Implementation**: Form validator checks for empty/null values
- **Error Message**: "Required"
- **Code Location**: `_buildTextInput()` and `_buildDropdown()` validators

### 4. Student Selection (PaymentDialog only)
**Rule**: Student must be selected before payment can be recorded
- **Implementation**: Check `_selectedStudentId != null`
- **Error Message**: "Please search and select a valid student from the list"
- **Note**: QuickPaymentDialog pre-selects student from context, so this check is not needed

### 5. Number Format Validation
**Rule**: Amount field must contain valid decimal number
- **Implementation**: 
  - `TextInputType.numberWithOptions(decimal: true)`
  - `double.tryParse()` validation
- **Error Message**: "Invalid number"
- **Code Location**: `_buildTextInput()` validator

## Visual Feedback

### Payment Method Indicators
Color-coded indicators help users quickly identify payment methods:

| Method | Color | Icon |
|--------|-------|------|
| Cash | Green (`successGreen`) | `Icons.money` |
| Bank Transfer | Blue (`primaryBlue`) | `Icons.account_balance` |
| Mobile Money | Orange (`warningOrange`) | `Icons.phone_android` |
| Cheque | White/Grey (`textWhite70`) | `Icons.receipt` |

**Implementation**: 
- `_getMethodColor(String method)` returns appropriate color
- `_getMethodIcon(String method)` returns appropriate icon
- Used in payment history list items for visual consistency

### Amount Prefix Styling
- Prefix character: `$`
- Style: Bold white text
- Purpose: Clear indication of currency and professional appearance

## Business Logic

### Bill Linking
When recording a payment:
1. Find all unpaid bills for the student (ordered by date)
2. Allocate payment amount to oldest bills first
3. Mark bills as paid when amount covers total
4. Create payment record with proper linkage

### Outstanding Amount Alert
- Displays if student has unpaid bills
- Shows total outstanding amount in red alert box
- Pre-fills amount field with outstanding total
- Helps prevent under-payment errors

## Error Handling

### Form Validation Flow
1. User clicks "Record Payment"
2. Form validator runs on all fields
3. If any field fails, red error text appears
4. Focus moves to first invalid field
5. User corrects errors and resubmits

### Database Error Handling
```dart
try {
  // Database operations
  await db.insert(...);
  await db.update(...);
} catch (e) {
  // Show error snackbar
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text('Error: $e'), backgroundColor: errorRed)
  );
} finally {
  // Always reset loading state
  setState(() => _isLoading = false);
}
```

## Testing Checklist

### Amount Validation Tests
- [ ] Enter amount = 0 → Should show error
- [ ] Enter negative amount → Should show error
- [ ] Enter text in amount field → Should show "Invalid number"
- [ ] Enter valid amount > 0 → Should accept

### Date Validation Tests
- [ ] Try selecting date before 2020 → Should be disabled in picker
- [ ] Try selecting date > 30 days future → Should be disabled in picker
- [ ] Select valid date → Should accept

### Required Fields Tests
- [ ] Leave amount empty → Should show "Required"
- [ ] Leave payer name empty → Should show "Required"
- [ ] Fill all fields → Should accept

### Visual Feedback Tests
- [ ] Cash payment → Green icon and background
- [ ] Bank Transfer → Blue icon and background
- [ ] Mobile Money → Orange icon and background
- [ ] Cheque → Grey icon and background

### Integration Tests
- [ ] Record payment with valid data → Should create payment record
- [ ] Record payment that covers outstanding bills → Bills should be marked paid
- [ ] Outstanding amount alert → Should show correct total
- [ ] Payment history → Should update in real-time

## Differences: PaymentDialog vs QuickPaymentDialog

| Feature | PaymentDialog | QuickPaymentDialog |
|---------|---------------|-------------------|
| Student Selection | Required (with search) | Pre-selected from context |
| Student Search | Yes | No (name shown read-only) |
| Outstanding Alert | Yes | Yes |
| Amount Validation | Yes | Yes |
| Date Range | 2020 to now+30 | 2020 to now+30 |
| Payment History | Yes (right panel) | Yes (right panel) |
| Layout | 1100x700 split-panel | 1100x700 split-panel |
| Visual Helpers | Yes | Yes |

## Consistency Standards

### All Payment Dialogs Should:
1. Use 1100x700 split-panel layout
2. Validate amount > 0
3. Restrict dates to 2020 - now+30
4. Show payment history on right panel
5. Use color-coded payment method indicators
6. Display outstanding amount alert when applicable
7. Handle errors gracefully with user feedback
8. Maintain loading state during async operations

### Code Reusability
Consider extracting common validation logic into:
- `lib/pc/utils/payment_validators.dart` - Shared validation functions
- `lib/pc/widgets/common/payment_method_indicator.dart` - Reusable method indicator widget
- `lib/pc/widgets/common/payment_amount_field.dart` - Reusable amount input with validation

## Future Enhancements

### Potential Improvements
1. **Maximum Amount Limit**: Prevent accidentally large payments
2. **Receipt Generation**: Auto-generate PDF receipt after payment
3. **Payment Notes**: Optional field for additional context
4. **Bulk Payments**: Record multiple payments at once
5. **Payment Reversal**: Ability to void/refund payments with audit trail
6. **Currency Selection**: Support multiple currencies
7. **Payment Plans**: Schedule recurring payments
8. **SMS Confirmation**: Send payment confirmation to parent

### Data Quality Improvements
1. **Duplicate Detection**: Warn if similar payment exists (same amount, date, student)
2. **Unusual Amount Alert**: Flag payments significantly above/below typical range
3. **Historical Analysis**: Show payment trends and patterns
4. **Validation Rules Engine**: Configurable rules in database
5. **Approval Workflow**: Large payments require manager approval

---

**Last Updated**: January 2025  
**Maintained By**: Development Team  
**Related Files**: 
- `lib/pc/widgets/payments/payment_dialog.dart`
- `lib/pc/widgets/students/quick_payment_dialog.dart`
