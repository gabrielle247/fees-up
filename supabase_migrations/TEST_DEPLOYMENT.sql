-- =====================================================
-- DEPLOYMENT VERIFICATION & TESTING SCRIPT
-- Date: January 3, 2026
-- Purpose: Verify all financial system components are working
-- =====================================================

-- =====================================================
-- STEP 1: Verify RLS Policies Enabled
-- =====================================================
SELECT 
    schemaname,
    tablename,
    policyname,
    permissive,
    cmd
FROM pg_policies
WHERE tablename IN ('payment_allocations', 'financial_audit_log')
ORDER BY tablename, policyname;

-- Expected Output:
-- payment_allocations should have 3 policies (select, insert, delete)
-- financial_audit_log should have 1 policy (select)


-- =====================================================
-- STEP 2: Verify RPC Functions Exist
-- =====================================================
SELECT 
    routine_name,
    routine_type,
    security_type
FROM information_schema.routines
WHERE routine_schema = 'public'
    AND routine_name IN (
        'get_outstanding_bills_with_balance',
        'get_bill_payment_summary',
        'get_invoice_statistics',
        'get_transaction_summary',
        'generate_next_invoice_number',
        'get_payment_allocation_history'
    )
ORDER BY routine_name;

-- Expected Output: 6 functions with DEFINER security


-- =====================================================
-- STEP 3: Verify Database Triggers Exist
-- =====================================================
SELECT 
    trigger_name,
    event_object_table,
    event_manipulation,
    action_timing,
    action_orientation
FROM information_schema.triggers
WHERE trigger_schema = 'public'
    AND trigger_name IN (
        'bill_audit_trigger',
        'payment_audit_trigger',
        'payment_allocation_audit_trigger',
        'update_bill_status_trigger',
        'revert_bill_status_trigger'
    )
ORDER BY trigger_name;

-- Expected Output: 5+ triggers on bills, payments, payment_allocations tables


-- =====================================================
-- STEP 4: Test Invoice Number Generation
-- =====================================================
-- Replace 'your-school-uuid' with actual school_id from your database
/*
SELECT generate_next_invoice_number('your-school-uuid');
-- Expected Output: 'INV-00001' (or next sequential number)
*/


-- =====================================================
-- STEP 5: Test Bill Creation with Audit Logging
-- =====================================================
-- This will test:
-- 1. Bill creation
-- 2. Automatic audit log entry via trigger
-- 3. Invoice number assignment
-- 4. Status field

/*
-- Replace UUIDs with actual values from your database
INSERT INTO bills (
    id,
    school_id,
    student_id,
    title,
    invoice_number,
    status,
    total_amount,
    paid_amount,
    is_paid,
    due_date,
    bill_type,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    'your-school-uuid',
    'your-student-uuid',
    'Test Invoice - Q1 Tuition',
    'INV-00001',  -- Use the number from generate_next_invoice_number
    'sent',
    5000.00,
    0.00,
    0,
    NOW() + INTERVAL '30 days',
    'adhoc',
    NOW(),
    NOW()
) RETURNING id;

-- Save the returned bill_id for next steps
*/


-- =====================================================
-- STEP 6: Verify Audit Log Entry Created
-- =====================================================
-- Check that the bill creation triggered an audit log entry

/*
SELECT 
    id,
    action_type,
    user_id,
    amount,
    reference_id,
    details,
    created_at
FROM financial_audit_log
WHERE action_type = 'bill_created'
ORDER BY created_at DESC
LIMIT 5;

-- Expected: Should see entry with action_type='bill_created'
-- and reference_id matching the bill_id from Step 5
*/


-- =====================================================
-- STEP 7: Test Payment Recording with Allocation
-- =====================================================
-- This will test:
-- 1. Payment creation
-- 2. Payment allocation
-- 3. Automatic bill.paid_amount update via trigger
-- 4. Automatic bill.status update via trigger
-- 5. Audit log entries

/*
-- Step 7a: Create payment
INSERT INTO payments (
    id,
    school_id,
    student_id,
    amount,
    method,
    category,
    date_paid,
    payer_name,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    'your-school-uuid',
    'your-student-uuid',
    2000.00,
    'Bank Transfer',
    'Tuition',
    CURRENT_DATE,
    'John Doe (Parent)',
    NOW(),
    NOW()
) RETURNING id;

-- Save the returned payment_id for Step 7b
*/

/*
-- Step 7b: Allocate payment to bill
INSERT INTO payment_allocations (
    id,
    payment_id,
    bill_id,
    school_id,
    amount,
    created_at
) VALUES (
    gen_random_uuid(),
    'payment-uuid-from-step-7a',
    'bill-uuid-from-step-5',
    'your-school-uuid',
    2000.00,
    NOW()
) RETURNING id;

-- This should trigger:
-- 1. payment_allocation_audit_trigger → audit log entry
-- 2. update_bill_status_trigger → bill.paid_amount = 2000, status = 'partial'
*/


-- =====================================================
-- STEP 8: Verify Automatic Bill Status Update
-- =====================================================
/*
SELECT 
    id,
    invoice_number,
    title,
    total_amount,
    paid_amount,
    status,
    is_paid
FROM bills
WHERE id = 'bill-uuid-from-step-5';

-- Expected Output:
-- paid_amount: 2000.00
-- status: 'partial' (since 2000 < 5000)
-- is_paid: 0 (false)
*/


-- =====================================================
-- STEP 9: Verify All Audit Log Entries
-- =====================================================
/*
SELECT 
    id,
    action_type,
    amount,
    reference_id,
    details,
    created_at
FROM financial_audit_log
WHERE reference_id IN ('bill-uuid-from-step-5', 'payment-uuid-from-step-7a')
ORDER BY created_at ASC;

-- Expected Output: Should see entries for:
-- 1. bill_created (total_amount: 5000)
-- 2. payment_recorded (amount: 2000)
-- 3. payment_allocated (amount: 2000)
*/


-- =====================================================
-- STEP 10: Test RPC Functions
-- =====================================================

/*
-- Test 10a: Get outstanding bills
SELECT * FROM get_outstanding_bills_with_balance('your-student-uuid');
-- Expected: Should show the test bill with balance = 3000 (5000 - 2000)
*/

/*
-- Test 10b: Get bill payment summary
SELECT get_bill_payment_summary('bill-uuid-from-step-5');
-- Expected: JSON with bill details and allocations array
*/

/*
-- Test 10c: Get invoice statistics
SELECT get_invoice_statistics('your-school-uuid');
-- Expected: JSON with counts, totals, and collection_rate
*/

/*
-- Test 10d: Get transaction summary
SELECT get_transaction_summary('your-school-uuid');
-- Expected: JSON with revenue, payment methods breakdown
*/

/*
-- Test 10e: Get payment allocation history
SELECT * FROM get_payment_allocation_history('your-student-uuid');
-- Expected: Rows showing allocation history with payment details
*/


-- =====================================================
-- STEP 11: Test Full Payment Scenario
-- =====================================================
-- Pay the remaining balance to test status change to 'paid'

/*
-- Create second payment
INSERT INTO payments (
    id,
    school_id,
    student_id,
    amount,
    method,
    category,
    date_paid,
    payer_name,
    created_at,
    updated_at
) VALUES (
    gen_random_uuid(),
    'your-school-uuid',
    'your-student-uuid',
    3000.00,
    'Cash',
    'Tuition',
    CURRENT_DATE,
    'John Doe (Parent)',
    NOW(),
    NOW()
) RETURNING id;
*/

/*
-- Allocate second payment (remaining balance)
INSERT INTO payment_allocations (
    id,
    payment_id,
    bill_id,
    school_id,
    amount,
    created_at
) VALUES (
    gen_random_uuid(),
    'second-payment-uuid',
    'bill-uuid-from-step-5',
    'your-school-uuid',
    3000.00,
    NOW()
);

-- This should trigger:
-- Bill.paid_amount = 5000 (2000 + 3000)
-- Bill.status = 'paid' (paid_amount >= total_amount)
-- Bill.is_paid = 1 (true)
*/

/*
-- Verify final bill status
SELECT 
    invoice_number,
    total_amount,
    paid_amount,
    status,
    is_paid,
    (total_amount - paid_amount) AS remaining_balance
FROM bills
WHERE id = 'bill-uuid-from-step-5';

-- Expected:
-- paid_amount: 5000.00
-- status: 'paid'
-- is_paid: 1
-- remaining_balance: 0.00
*/


-- =====================================================
-- STEP 12: Test Refund/Allocation Deletion
-- =====================================================
-- Test the revert_bill_status_trigger

/*
-- Delete one allocation (simulating refund)
DELETE FROM payment_allocations
WHERE payment_id = 'second-payment-uuid'
RETURNING *;

-- This should trigger:
-- Bill.paid_amount recalculated = 2000 (only first payment remains)
-- Bill.status = 'partial'
-- Bill.is_paid = 0
*/

/*
-- Verify bill status reverted
SELECT 
    invoice_number,
    total_amount,
    paid_amount,
    status,
    is_paid
FROM bills
WHERE id = 'bill-uuid-from-step-5';

-- Expected:
-- paid_amount: 2000.00
-- status: 'partial'
-- is_paid: 0
*/


-- =====================================================
-- STEP 13: Verify RLS Security
-- =====================================================
-- These should fail with "Access denied" if RLS is working

/*
-- Try to access another school's data (should fail)
-- First, get a school_id you DON'T have access to
SELECT get_invoice_statistics('different-school-uuid');
-- Expected: ERROR: Access denied
*/


-- =====================================================
-- CLEANUP TEST DATA (OPTIONAL)
-- =====================================================
-- Remove test data after verification

/*
DELETE FROM payment_allocations WHERE bill_id = 'bill-uuid-from-step-5';
DELETE FROM payments WHERE student_id = 'your-student-uuid' AND payer_name = 'John Doe (Parent)';
DELETE FROM bills WHERE id = 'bill-uuid-from-step-5';
-- Note: Audit log entries remain (immutable audit trail)
*/


-- =====================================================
-- DEPLOYMENT VERIFICATION CHECKLIST
-- =====================================================

/*
✅ Verification Results:

Step 1: RLS Policies
[ ] payment_allocations has 3 policies (select, insert, delete)
[ ] financial_audit_log has 1 policy (select only)

Step 2: RPC Functions
[ ] All 6 functions exist with DEFINER security

Step 3: Database Triggers  
[ ] All 5 triggers exist on correct tables

Step 4: Invoice Generation
[ ] generate_next_invoice_number returns sequential INV-XXXXX

Step 5: Bill Creation
[ ] Bill created successfully with invoice_number and status

Step 6: Audit Logging
[ ] bill_created entry appears in financial_audit_log

Step 7: Payment & Allocation
[ ] Payment recorded and allocated to bill

Step 8: Auto Status Update
[ ] Bill.paid_amount updated automatically
[ ] Bill.status changed to 'partial' automatically

Step 9: Audit Trail
[ ] All financial actions logged (created, recorded, allocated)

Step 10: RPC Functions
[ ] All 6 RPC functions return correct data

Step 11: Full Payment
[ ] Bill.status changed to 'paid' when fully paid
[ ] Bill.is_paid = 1

Step 12: Refund/Reversal
[ ] Bill status reverted correctly on allocation deletion

Step 13: RLS Security
[ ] Cross-school access denied properly

If all checks pass: ✅ DEPLOYMENT SUCCESSFUL
*/


-- =====================================================
-- QUICK HEALTH CHECK (Run this first)
-- =====================================================

-- Detailed breakdown of deployed components
SELECT 
    'Financial RLS Policies' AS component,
    COUNT(*) AS deployed,
    '4 required' AS expected,
    CASE WHEN COUNT(*) = 4 THEN '✅' ELSE '⚠️' END AS status
FROM pg_policies
WHERE tablename IN ('payment_allocations', 'financial_audit_log')

UNION ALL

SELECT 
    'Financial RPC Functions' AS component,
    COUNT(*) AS deployed,
    '6 required' AS expected,
    CASE WHEN COUNT(*) = 6 THEN '✅' ELSE '⚠️' END AS status
FROM information_schema.routines
WHERE routine_schema = 'public'
    AND routine_name IN (
        'get_outstanding_bills_with_balance',
        'get_bill_payment_summary',
        'get_invoice_statistics',
        'get_transaction_summary',
        'generate_next_invoice_number',
        'get_payment_allocation_history'
    )

UNION ALL

SELECT 
    'Financial Triggers' AS component,
    COUNT(*) AS deployed,
    '5 required' AS expected,
    CASE WHEN COUNT(*) >= 5 THEN '✅' ELSE '⚠️' END AS status
FROM information_schema.triggers
WHERE trigger_schema = 'public'
    AND trigger_name IN (
        'bill_audit_trigger',
        'payment_audit_trigger',
        'payment_allocation_audit_trigger',
        'update_bill_status_trigger',
        'revert_bill_status_trigger'
    );


-- =====================================================
-- DETAILED COMPONENT LISTING
-- =====================================================

-- List all financial RLS policies
SELECT 
    '📋 RLS POLICIES' AS section,
    tablename AS table_name,
    policyname AS policy_name,
    cmd AS operation
FROM pg_policies
WHERE tablename IN ('payment_allocations', 'financial_audit_log')
ORDER BY tablename, policyname;

-- List all financial RPC functions
SELECT 
    '⚙️ RPC FUNCTIONS' AS section,
    routine_name AS function_name,
    'FUNCTION' AS type,
    security_type AS security
FROM information_schema.routines
WHERE routine_schema = 'public'
    AND routine_name IN (
        'get_outstanding_bills_with_balance',
        'get_bill_payment_summary',
        'get_invoice_statistics',
        'get_transaction_summary',
        'generate_next_invoice_number',
        'get_payment_allocation_history'
    )
ORDER BY routine_name;

-- List all financial triggers
SELECT 
    '🔔 DATABASE TRIGGERS' AS section,
    trigger_name,
    event_object_table AS table_name,
    string_agg(event_manipulation, ', ') AS events,
    action_timing AS timing
FROM information_schema.triggers
WHERE trigger_schema = 'public'
    AND trigger_name IN (
        'bill_audit_trigger',
        'payment_audit_trigger',
        'payment_allocation_audit_trigger',
        'update_bill_status_trigger',
        'revert_bill_status_trigger'
    )
GROUP BY trigger_name, event_object_table, action_timing
ORDER BY trigger_name;
