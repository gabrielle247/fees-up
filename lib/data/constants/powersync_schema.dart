// ==========================================
// FILE: ./constants/powersync_schema.dart
// ==========================================

import 'package:powersync/powersync.dart';

const Schema powersyncSchema = Schema([
  // ====================
  // SAAS Schema
  // ====================
  Table('plans', [
    Column.text('code'),
    Column.text('name'),
    Column.text('monthly_price'),
    Column.text('limits'),
    Column.text('is_active'),
    Column.text('created_at'),
  ]),

  Table('schools', [
    Column.text('name'),
    Column.text('subdomain'),
    Column.text('logo_url'),
    Column.text('current_plan_id'),
    Column.text('subscription_status'),
    Column.text('valid_until'),
    Column.text('address_line1'),
    Column.text('city'),
    Column.text('country'),
    Column.text('phone_number'),
    Column.text('email_address'),
    Column.text('tax_id'),
    Column.text('website'),
    Column.text('created_at'),
    Column.text('updated_at'),
    Column.text('owner_id'),
  ]),

  // ====================
  // ACCESS Schema
  // ====================
  Table('profiles', [
    Column.text('school_id'),
    Column.text('full_name'),
    Column.text('email'),
    Column.text('role_id'),
    Column.text('is_banned'),
    Column.text('avatar_url'),
    Column.text('created_at'),
    Column.text('updated_at'),
  ]),

  Table('roles', [
    Column.text('description'),
  ]),

  // ====================
  // ACADEMIC Schema
  // ====================
  Table('academic_years', [
    Column.text('school_id'),
    Column.text('name'),
    Column.text('start_date'),
    Column.text('end_date'),
    Column.text('is_active'),
    Column.text('created_at'),
    Column.text('is_locked'),
    Column.text('locked_at'),
    Column.text('locked_by'),
    Column.text('updated_at'),
  ]),

  Table('terms', [
    Column.text('school_id'),
    Column.text('academic_year_id'),
    Column.text('name'),
    Column.text('start_date'),
    Column.text('end_date'),
    Column.text('due_date'),
    Column.text('is_current'),
    Column.text('created_at'),
  ]),

  Table('enrollments', [
    Column.text('school_id'),
    Column.text('student_id'),
    Column.text('academic_year_id'),
    Column.text('grade_level'),
    Column.text('class_stream'),
    Column.text('is_active'),
    Column.text('created_at'),
  ]),

  // ====================
  // PEOPLE Schema
  // ====================
  Table('students', [
    Column.text('school_id'),
    Column.text('first_name'),
    Column.text('last_name'),
    Column.text('national_id'),
    Column.text('dob'),
    Column.text('gender'),
    Column.text('status'),
    Column.text('enrollment_date'),
    Column.text('created_at'),
    Column.text('admission_number'),
    Column.text('guardian_name'),
    Column.text('guardian_phone'),
    Column.text('guardian_email'),
    Column.text('guardian_relationship'),
    Column.text('student_type'),
    Column.text('admission_date'),
    Column.text('is_archived'),
    Column.text('updated_at'),
    Column.text('fees_owed'),
  ]),

  // ====================
  // FINANCE Schema
  // ====================
  Table('fee_categories', [
    Column.text('school_id'),
    Column.text('name'),
    Column.text('is_taxable'),
    Column.text('created_at'),
  ]),

  Table('fee_structures', [
    Column.text('school_id'),
    Column.text('academic_year_id'),
    Column.text('category_id'),
    Column.text('name'),
    Column.text('amount'),
    Column.text('currency'),
    Column.text('target_grade'),
    Column.text('created_at'),
    Column.text('billing_type'),
    Column.text('recurrence'),
    Column.text('billable_months'),
    Column.text('suspensions'),
  ]),

  Table('discounts', [
    Column.text('school_id'),
    Column.text('name'),
    Column.text('percentage'),
    Column.text('is_active'),
    Column.text('created_at'),
  ]),

  Table('student_discounts', [
    Column.text('student_id'),
    Column.text('discount_id'),
    Column.text('academic_year_id'),
    Column.text('assigned_at'),
  ]),

  Table('invoice_items', [
    Column.text('invoice_id'),
    Column.text('fee_structure_id'),
    Column.text('description'),
    Column.text('amount'),
    Column.text('quantity'),
    Column.text('created_at'),
    Column.text('school_id'),
  ]),

  Table('invoices', [
    Column.text('school_id'),
    Column.text('student_id'),
    Column.text('invoice_number'),
    Column.text('term_id'),
    Column.text('due_date'),
    Column.text('status'),
    Column.text('snapshot_grade'),
    Column.text('created_at'),
  ]),

  Table('ledger', [
    Column.text('school_id'),
    Column.text('student_id'),
    Column.text('type'),
    Column.text('category'),
    Column.text('amount'),
    Column.text('currency'),
    Column.text('invoice_id'),
    Column.text('reference_code'),
    Column.text('description'),
    Column.text('occurred_at'),
    Column.text('created_at'),
  ]),

  Table('payment_allocations', [
    Column.text('payment_id'),
    Column.text('invoice_item_id'),
    Column.text('amount_allocated'),
    Column.text('created_at'),
    Column.text('school_id'),
  ]),

  Table('payments', [
    Column.text('school_id'),
    Column.text('student_id'),
    Column.text('amount'),
    Column.text('method'),
    Column.text('reference_code'),
    Column.text('received_at'),
    Column.text('created_at'),
  ]),
]);