import 'package:powersync/powersync.dart';

/// The Local SQLite Schema matching the Supabase Postgres Schema
/// based on the Fees Up Rules.
const Schema appSchema = Schema([
  
  // ============================================================
  // CORE SCHOOL DATA
  // ============================================================
  Table('schools', [
    Column.text('name'),
    Column.text('subscription_tier'),
    Column.integer('max_students'),
    Column.integer('is_suspended'), 
    Column.text('created_at'),
  ]),

  Table('user_profiles', [
    Column.text('email'),
    Column.text('full_name'),
    Column.text('role'),
    Column.text('school_id'),
    Column.integer('is_banned'),
    Column.text('avatar_url'),
    Column.text('created_at'),
  ]),

  Table('notifications', [
    Column.text('user_id'),
    Column.text('school_id'),
    Column.text('title'),
    Column.text('body'),
    Column.text('type'),
    Column.integer('is_read'),
    Column.text('created_at'),
  ]),

  // ============================================================
  // PEOPLE (Students, Teachers, Access)
  // ============================================================
  Table('students', [
    Column.text('school_id'),
    Column.text('student_id'), 
    Column.text('full_name'),
    Column.text('grade'),
    Column.text('parent_contact'),
    Column.text('registration_date'),
    Column.text('billing_type'),
    Column.real('default_fee'),
    Column.integer('is_active'),
    Column.text('admin_uid'),
    Column.real('owed_total'),
    Column.real('paid_total'),
    Column.text('subjects'),
    Column.text('billing_date'),
    Column.text('last_synced_at'),
    Column.text('term_id'),
    Column.text('date_of_birth'),
    Column.text('gender'),
    Column.text('address'),
    Column.text('emergency_contact_name'),
    Column.text('medical_notes'),
    Column.text('enrollment_date'),
    Column.integer('photo_consent'),
    Column.text('updated_at'),
    Column.text('created_at'),
  ]),

  Table('teachers', [
    Column.text('school_id'),
    Column.text('full_name'),
    Column.text('admin_uid'),
    Column.text('created_at'),
    Column.text('updated_at'),
  ]),

  Table('teacher_access_tokens', [
    Column.text('school_id'),
    Column.text('teacher_id'),
    Column.text('granted_by_teacher_id'),
    Column.text('access_code'),
    Column.text('permission_type'),
    Column.integer('is_used'),
    Column.text('used_at'),
    Column.text('expires_at'),
    Column.text('created_at'),
  ]),

  // ============================================================
  // ACADEMICS (Classes, Enrollment, Terms)
  // ============================================================
  Table('classes', [
    Column.text('school_id'),
    Column.text('name'),
    Column.text('teacher_id'),
    Column.text('room_number'),
    Column.text('subject_code'),
    Column.text('admin_uid'),
    Column.text('created_at'),
  ]),

  Table('enrollments', [
    Column.text('school_id'),
    Column.text('student_id'),
    Column.text('class_id'),
    Column.text('enrolled_at'),
    Column.text('created_at'),
  ]),

  Table('school_years', [
    Column.text('school_id'),
    Column.text('year_label'),
    Column.text('start_date'),
    Column.text('end_date'),
    Column.text('description'),
    Column.integer('active'),
    Column.text('created_at'),
  ]),

  Table('school_year_months', [
    Column.text('school_year_id'),
    Column.text('school_id'),
    Column.text('name'),
    Column.integer('month_index'),
    Column.text('start_date'),
    Column.text('end_date'),
    Column.integer('is_billable'),
    Column.text('created_at'),
  ]),

  Table('school_terms', [
    Column.text('school_id'),
    Column.text('name'),
    Column.text('start_date'),
    Column.text('end_date'),
    Column.integer('academic_year'),
    Column.text('created_at'),
  ]),

  // ============================================================
  // ATTENDANCE
  // ============================================================
  Table('attendance', [
    Column.text('school_id'),
    Column.text('student_id'),
    Column.text('class_id'),
    Column.text('date'),
    Column.text('status'),
    Column.text('remarks'),
    Column.text('recorded_by'),
    Column.text('created_at'),
  ]),

  Table('attendance_sessions', [
    Column.text('school_id'),
    Column.text('class_id'),
    Column.text('teacher_id'),
    Column.text('student_admin_id'),
    Column.text('access_token_id'),
    Column.text('session_date'),
    Column.integer('is_confirmed_by_teacher'),
    Column.text('confirmed_at'),
    Column.text('created_at'),
  ]),

  // ============================================================
  // FINANCE (Billing, Payments, Expenses)
  // ============================================================
  Table('billing_configs', [
    Column.text('school_id'),
    Column.text('currency_code'),
    Column.real('late_fee_percentage'),
    Column.text('invoice_footer_note'),
    Column.integer('allow_partial_payments'),
    Column.real('default_fee'),
    Column.text('updated_at'),
  ]),

  Table('bills', [
    Column.text('school_id'),
    Column.text('student_id'),
    Column.text('title'),
    
    // --- NEW COLUMNS FOR INVOICING ---
    Column.text('invoice_number'), // e.g. "INV-00231"
    Column.text('status'),         // e.g. "draft", "sent", "paid", "overdue"
    Column.text('pdf_url'),        // Link to Supabase Storage bucket
    // ---------------------------------

    Column.real('total_amount'),
    Column.integer('is_paid'), // Keep for backward compatibility/quick checks
    Column.text('bill_type'),
    Column.text('billing_cycle_end'),
    Column.text('billing_cycle_start'),
    Column.real('paid_amount'), // Cache for performance
    Column.text('term_id'),
    Column.text('month_year'),
    Column.text('due_date'),
    Column.text('cycle_interval'),
    Column.integer('is_closed'),
    Column.real('credited_amount'),
    Column.text('school_year_id'),
    Column.integer('month_index'),
    Column.text('updated_at'),
    Column.text('created_at'),
  ]),

  Table('bill_items', [
    Column.text('bill_id'),
    Column.text('school_id'),
    Column.text('description'),
    Column.real('amount'),
    Column.integer('quantity'),
    Column.text('created_at'),
  ]),

  Table('payments', [
    Column.text('school_id'),
    Column.text('student_id'),
    Column.real('amount'),
    Column.text('date_paid'),
    Column.text('category'),
    Column.text('payer_name'),
    Column.text('bill_id'),
    Column.text('method'),
    Column.text('admin_uid'),
    Column.text('created_at'),
  ]),

  Table('payment_allocations', [
    Column.text('payment_id'),
    Column.text('bill_id'),
    Column.text('school_id'),
    Column.real('amount'),
    Column.text('created_at'),
  ]),

  Table('credits', [
    Column.text('credit_id'),
    Column.text('school_id'),
    Column.text('student_id'),
    Column.text('bill_id'),
    Column.real('amount'),
    Column.text('reason'),
    Column.text('admin_uid'),
    Column.text('created_at'),
  ]),

  Table('expenses', [
    Column.text('school_id'),
    Column.text('title'),
    Column.real('amount'),
    Column.text('category'),
    Column.text('incurred_at'),
    Column.text('description'),
    Column.text('recipient'),
    Column.text('created_at'),
  ]),

  // ============================================================
  // FUNDRAISER & AUDIT
  // ============================================================
  Table('campaigns', [
    Column.text('school_id'),
    Column.text('class_id'),
    Column.text('created_by_id'),
    Column.text('teacher_id'),
    Column.text('name'),
    Column.text('description'),
    Column.text('campaign_type'),
    Column.text('status'),
    Column.real('goal_amount'),
    Column.text('created_at'),
  ]),

  Table('campaign_donations', [
    Column.text('campaign_id'),
    Column.text('school_id'),
    Column.text('donor_name'),
    Column.real('amount'),
    Column.text('payment_method'),
    Column.text('date_received'),
    Column.text('notes'),
    Column.text('student_id'),
    Column.text('collected_by'),
    Column.text('approved_by'),
    Column.real('expected_cash'),
    Column.real('actual_cash'),
    Column.real('variance'),
    Column.text('updated_at'),
    Column.text('created_at'),
  ]),

  Table('campaign_expenses', [
    Column.text('campaign_id'),
    Column.text('school_id'),
    Column.text('category'),
    Column.real('amount'),
    Column.text('incurred_by'),
    Column.text('approved_by'),
    Column.text('notes'),
    Column.text('created_at'),
  ]),

  Table('campaign_funds', [
    Column.text('campaign_id'),
    Column.text('school_id'),
    Column.text('fund_name'),
    Column.integer('restricted'),
    Column.real('balance'),
    Column.text('updated_at'),
  ]),

  Table('banking_register', [
    Column.text('campaign_id'),
    Column.text('student_id'),
    Column.real('amount'),
    Column.text('direction'), 
    Column.text('recorded_by'),
    Column.text('approved_by'),
    Column.text('reference'),
    Column.text('school_id'),
    Column.text('created_at'),
  ]),

  // ============================================================
  // ARCHIVES
  // ============================================================
  Table('student_archives', [
    Column.text('school_id'),
    Column.text('full_name'),
    Column.text('reason'),
    Column.text('archived_at'),
    Column.text('original_data'),
    Column.text('created_at'),
  ]),
]);