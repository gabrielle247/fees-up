# 🚀 Financial System Database Deployment Guide

**Date:** January 3, 2026  
**Purpose:** Step-by-step guide to deploy financial system to Supabase  
**Estimated Time:** 30-45 minutes  

---

## ✅ Prerequisites Checklist

Before starting, ensure you have:

- [x] Supabase project access (staff access confirmed)
- [x] Database write permissions
- [x] SQL Editor access in Supabase dashboard
- [ ] Backup of current database (recommended)
- [ ] Test environment ready (optional but recommended)

---

## 📋 Deployment Steps

### Step 1: Verify Existing Tables (5 minutes)

**File:** `supabase_migrations/verify_financial_tables.sql`

1. Open Supabase Dashboard → SQL Editor
2. Run **Section 1** to verify `payment_allocations`:
   ```sql
   SELECT table_name, column_name, data_type, is_nullable
   FROM information_schema.columns
   WHERE table_schema = 'public' 
     AND table_name = 'payment_allocations'
   ORDER BY ordinal_position;
   ```

**Expected Result:**
```
✅ payment_allocations exists
✅ Has 6 columns: id, payment_id, bill_id, school_id, amount, created_at
✅ Foreign keys to bills and payments tables
```

3. Run **Section 2** to check `financial_audit_log`:
   ```sql
   SELECT EXISTS (
       SELECT FROM information_schema.tables 
       WHERE table_schema = 'public' 
       AND table_name = 'financial_audit_log'
   ) AS financial_audit_log_exists;
   ```

**If Returns FALSE:** Continue to Step 2  
**If Returns TRUE:** Skip to Step 3

---

### Step 2: Create Missing Tables (10 minutes)

**If `financial_audit_log` does NOT exist:**

1. Run the `CREATE TABLE` statement from `verify_financial_tables.sql` Section 2:
   ```sql
   CREATE TABLE IF NOT EXISTS public.financial_audit_log (
       id UUID NOT NULL DEFAULT gen_random_uuid(),
       school_id UUID NOT NULL,
       action_type VARCHAR(50) NOT NULL,
       user_id UUID NULL,
       amount NUMERIC NULL,
       reference_id UUID NULL,
       details JSONB NULL,
       created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
       
       CONSTRAINT financial_audit_log_pkey PRIMARY KEY (id),
       CONSTRAINT audit_school_fk FOREIGN KEY (school_id) REFERENCES schools(id) ON DELETE CASCADE,
       CONSTRAINT audit_user_fk FOREIGN KEY (user_id) REFERENCES auth.users(id) ON DELETE SET NULL
   );
   ```

2. Create indexes:
   ```sql
   CREATE INDEX idx_financial_audit_log_school ON public.financial_audit_log(school_id);
   CREATE INDEX idx_financial_audit_log_created ON public.financial_audit_log(created_at DESC);
   CREATE INDEX idx_financial_audit_log_action ON public.financial_audit_log(action_type);
   CREATE INDEX idx_financial_audit_log_reference ON public.financial_audit_log(reference_id);
   ```

**Verification:**
```sql
SELECT COUNT(*) FROM information_schema.tables 
WHERE table_name = 'financial_audit_log';
-- Should return: 1
```

---

### Step 3: Update Bills Table (5 minutes)

Run **Section 3** from `verify_financial_tables.sql`:

```sql
-- Check if columns exist
SELECT column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema = 'public' 
  AND table_name = 'bills'
  AND column_name IN ('invoice_number', 'status', 'pdf_url')
ORDER BY column_name;
```

**If any columns are missing, add them:**

```sql
ALTER TABLE public.bills 
    ADD COLUMN IF NOT EXISTS invoice_number VARCHAR(50) NULL;

ALTER TABLE public.bills 
    ADD COLUMN IF NOT EXISTS status VARCHAR(20) NULL DEFAULT 'draft';

ALTER TABLE public.bills 
    ADD COLUMN IF NOT EXISTS pdf_url TEXT NULL;

-- Create indexes
CREATE UNIQUE INDEX IF NOT EXISTS idx_bills_invoice_number_unique 
    ON public.bills(invoice_number) 
    WHERE invoice_number IS NOT NULL;

CREATE INDEX IF NOT EXISTS idx_bills_status 
    ON public.bills(status);
```

**Verification:**
```sql
SELECT column_name FROM information_schema.columns
WHERE table_name = 'bills'
  AND column_name IN ('invoice_number', 'status', 'pdf_url');
-- Should return: 3 rows
```

---

### Step 4: Enable Row-Level Security (10 minutes)

Run **Section 4** from `verify_financial_tables.sql`:

#### A. payment_allocations RLS

```sql
ALTER TABLE public.payment_allocations ENABLE ROW LEVEL SECURITY;

-- SELECT: Users can view allocations for their school
CREATE POLICY payment_allocations_select 
    ON public.payment_allocations
    FOR SELECT
    USING (
        school_id IN (
            SELECT school_id FROM public.user_profiles WHERE id = auth.uid()
        )
    );

-- INSERT: Only admins can create allocations
CREATE POLICY payment_allocations_insert 
    ON public.payment_allocations
    FOR INSERT
    WITH CHECK (
        school_id IN (SELECT school_id FROM public.user_profiles WHERE id = auth.uid())
        AND EXISTS (
            SELECT 1 FROM public.user_profiles 
            WHERE id = auth.uid() AND role IN ('school_admin', 'super_admin')
        )
    );

-- DELETE: Only admins can delete allocations
CREATE POLICY payment_allocations_delete 
    ON public.payment_allocations
    FOR DELETE
    USING (
        school_id IN (SELECT school_id FROM public.user_profiles WHERE id = auth.uid())
        AND EXISTS (
            SELECT 1 FROM public.user_profiles 
            WHERE id = auth.uid() AND role IN ('admin', 'owner')
        )
    );
```

#### B. financial_audit_log RLS

```sql
ALTER TABLE public.financial_audit_log ENABLE ROW LEVEL SECURITY;

-- SELECT: Only admins/owners can view audit logs
CREATE POLICY financial_audit_log_select 
    ON public.financial_audit_log
    FOR SELECT
    USING (
        school_id IN (SELECT school_id FROM public.user_profiles WHERE id = auth.uid())
        AND EXISTS (
            SELECT 1 FROM public.user_profiles 
            WHERE id = auth.uid() AND role IN ('admin', 'owner')
        )
    );

-- No INSERT/UPDATE/DELETE policies = blocked for clients
-- Only database triggers can write to this table
```

**Verification:**
```sql
SELECT tablename, policyname, cmd
FROM pg_policies
WHERE tablename IN ('payment_allocations', 'financial_audit_log')
ORDER BY tablename, policyname;
-- Should show 4 policies total
```

---

### Step 5: Deploy RPC Functions (5 minutes)

**File:** `supabase_migrations/create_rpc_functions.sql`

Copy and paste the **ENTIRE FILE** into Supabase SQL Editor and execute.

This will create 6 RPC functions:
1. `get_outstanding_bills_with_balance()`
2. `get_bill_payment_summary()`
3. `get_invoice_statistics()`
4. `get_transaction_summary()`
5. `generate_next_invoice_number()`
6. `get_payment_allocation_history()`

**Verification:**
```sql
SELECT routine_name, routine_type
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name LIKE '%invoice%' OR routine_name LIKE '%payment%'
ORDER BY routine_name;
-- Should show at least 6 functions
```

---

### Step 6: Deploy Database Triggers (5 minutes)

**File:** `supabase_migrations/create_audit_triggers.sql`

Copy and paste the **ENTIRE FILE** into Supabase SQL Editor and execute.

This will create 5 trigger functions and 6 triggers:

**Trigger Functions:**
1. `log_bill_action()` - Logs invoice creation/updates
2. `log_payment_action()` - Logs payments/refunds
3. `log_payment_allocation_action()` - Logs allocations
4. `update_bill_status_on_payment()` - Auto-updates bill status
5. `revert_bill_status_on_allocation_delete()` - Reverts on refund

**Triggers:**
1. `bill_audit_trigger` on bills table
2. `payment_audit_trigger` on payments table
3. `payment_allocation_audit_trigger` on payment_allocations
4. `update_bill_status_trigger` on payment_allocations
5. `revert_bill_status_trigger` on payment_allocations (DELETE)

**Verification:**
```sql
SELECT trigger_name, event_object_table, event_manipulation
FROM information_schema.triggers
WHERE trigger_schema = 'public'
  AND event_object_table IN ('bills', 'payments', 'payment_allocations')
ORDER BY event_object_table, trigger_name;
-- Should show 5-6 triggers
```

---

## 🧪 Testing & Validation (Optional but Recommended)

### Test 1: Create Invoice and Verify Audit Log

```sql
-- 1. Create a test invoice
INSERT INTO bills (
    id, school_id, student_id, title, invoice_number, 
    total_amount, bill_type, status
) VALUES (
    gen_random_uuid(), 
    'your-school-id',  -- Replace with real school ID
    'your-student-id', -- Replace with real student ID
    'Test Invoice - DELETE ME', 
    'INV-TEST-001', 
    100.00, 
    'adhoc', 
    'draft'
) RETURNING id;

-- 2. Check if audit log was created
SELECT 
    action_type, 
    amount, 
    details->>'invoice_number' as invoice_number,
    created_at
FROM financial_audit_log
WHERE action_type = 'invoice_created'
ORDER BY created_at DESC
LIMIT 1;

-- Expected: One row with action_type = 'invoice_created'
```

### Test 2: RPC Function - Get Next Invoice Number

```sql
SELECT generate_next_invoice_number('your-school-id');
-- Expected: Returns 'INV-00001' or next sequential number
```

### Test 3: RPC Function - Get Outstanding Bills

```sql
SELECT * FROM get_outstanding_bills_with_balance('your-student-id');
-- Expected: Returns list of unpaid bills with balance calculated
```

### Test 4: Payment Allocation and Auto Status Update

```sql
-- 1. Create a test payment
INSERT INTO payments (
    id, school_id, student_id, amount, method, date_paid
) VALUES (
    gen_random_uuid(),
    'your-school-id',
    'your-student-id',
    50.00,
    'Cash',
    CURRENT_DATE
) RETURNING id;

-- 2. Allocate payment to bill
INSERT INTO payment_allocations (
    payment_id, bill_id, school_id, amount
) VALUES (
    'payment-id-from-above',
    'bill-id-from-test-1',
    'your-school-id',
    50.00
);

-- 3. Check bill status was auto-updated
SELECT 
    invoice_number,
    status,           -- Should be 'partial' (50/100 paid)
    paid_amount,      -- Should be 50.00
    total_amount,     -- Should be 100.00
    is_paid           -- Should be 0
FROM bills
WHERE id = 'bill-id-from-test-1';

-- 4. Check audit logs were created
SELECT action_type, amount, created_at
FROM financial_audit_log
WHERE reference_id IN ('payment-id', 'bill-id')
ORDER BY created_at DESC
LIMIT 5;
```

### Cleanup Test Data

```sql
-- Delete test records (in reverse order due to foreign keys)
DELETE FROM payment_allocations WHERE bill_id IN (
    SELECT id FROM bills WHERE invoice_number LIKE 'INV-TEST%'
);
DELETE FROM payments WHERE school_id = 'your-school-id' AND amount = 50.00;
DELETE FROM bills WHERE invoice_number LIKE 'INV-TEST%';
```

---

## ✅ Post-Deployment Checklist

After completing all steps, verify:

- [ ] `payment_allocations` table exists with 6 columns
- [ ] `financial_audit_log` table exists with 8 columns
- [ ] `bills` table has `invoice_number`, `status`, `pdf_url` columns
- [ ] RLS is enabled on both new tables
- [ ] 4 RLS policies exist (3 for payment_allocations, 1 for audit_log)
- [ ] 6 RPC functions are deployed
- [ ] 5-6 database triggers are active
- [ ] Test invoice creation logs to audit_log
- [ ] Test payment allocation auto-updates bill status
- [ ] No errors in Supabase logs

---

## 🔄 Next Steps

Once database deployment is complete:

1. **Update Flutter App:**
   - Update `schema.dart` to exclude `financial_audit_log` from PowerSync
   - Test RPC function calls from InvoiceService
   - Test RPC function calls from TransactionService
   - Test RPC function calls from FinancialReportsService

2. **UI Integration:**
   - Update `payment_dialog.dart` to show allocation button
   - Create `reports_screen.dart` for financial reports
   - Add invoice statistics widget to dashboard

3. **Testing:**
   - Run manual test scenarios from `BILL_DATA_ANALYSIS_CHECKLIST.md`
   - Verify audit logs are being created
   - Test with real school data

4. **Monitoring:**
   - Check Supabase logs for errors
   - Monitor RPC function performance
   - Verify trigger execution

---

## ⚠️ Rollback Procedure (If Needed)

If something goes wrong, rollback in reverse order:

```sql
-- 1. Drop triggers
DROP TRIGGER IF EXISTS bill_audit_trigger ON bills;
DROP TRIGGER IF EXISTS payment_audit_trigger ON payments;
DROP TRIGGER IF EXISTS payment_allocation_audit_trigger ON payment_allocations;
DROP TRIGGER IF EXISTS update_bill_status_trigger ON payment_allocations;
DROP TRIGGER IF EXISTS revert_bill_status_trigger ON payment_allocations;

-- 2. Drop trigger functions
DROP FUNCTION IF EXISTS log_bill_action();
DROP FUNCTION IF EXISTS log_payment_action();
DROP FUNCTION IF EXISTS log_payment_allocation_action();
DROP FUNCTION IF EXISTS update_bill_status_on_payment();
DROP FUNCTION IF EXISTS revert_bill_status_on_allocation_delete();

-- 3. Drop RPC functions
DROP FUNCTION IF EXISTS get_outstanding_bills_with_balance(UUID);
DROP FUNCTION IF EXISTS get_bill_payment_summary(UUID);
DROP FUNCTION IF EXISTS get_invoice_statistics(UUID, DATE, DATE);
DROP FUNCTION IF EXISTS get_transaction_summary(UUID, DATE, DATE);
DROP FUNCTION IF EXISTS generate_next_invoice_number(UUID);
DROP FUNCTION IF EXISTS get_payment_allocation_history(UUID, INT);

-- 4. Remove RLS policies
DROP POLICY IF EXISTS payment_allocations_select ON payment_allocations;
DROP POLICY IF EXISTS payment_allocations_insert ON payment_allocations;
DROP POLICY IF EXISTS payment_allocations_delete ON payment_allocations;
DROP POLICY IF EXISTS financial_audit_log_select ON financial_audit_log;

-- 5. Drop new columns (CAREFUL - this deletes data!)
-- ALTER TABLE bills DROP COLUMN IF EXISTS invoice_number;
-- ALTER TABLE bills DROP COLUMN IF EXISTS status;
-- ALTER TABLE bills DROP COLUMN IF EXISTS pdf_url;

-- 6. Drop tables (CAREFUL - this deletes data!)
-- DROP TABLE IF EXISTS financial_audit_log;
-- DROP TABLE IF EXISTS payment_allocations; -- User confirmed this exists, don't drop
```

---

## 📞 Support

If you encounter issues during deployment:

1. Check Supabase logs (Dashboard → Database → Logs)
2. Verify user permissions (need WRITE access)
3. Check foreign key constraints match your schema
4. Ensure `auth.users` table exists for user_id foreign key

---

**Deployment Status:** ⏳ Ready to Deploy  
**Last Updated:** January 3, 2026  
**Prepared By:** Nyasha Gabriel
