-- =====================================================
-- FINANCIAL AUDIT TRIGGERS
-- Date: January 3, 2026
-- Purpose: Automatic audit logging for all financial operations
-- =====================================================

-- =====================================================
-- TRIGGER FUNCTION 1: Log Bill Actions
-- Logs whenever a bill is created or updated
-- =====================================================

CREATE OR REPLACE FUNCTION log_bill_action()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_action_type VARCHAR(50);
    v_amount NUMERIC;
    v_details JSONB;
BEGIN
    -- Determine action type
    IF (TG_OP = 'INSERT') THEN
        v_action_type := 'invoice_created';
        v_amount := NEW.total_amount;
        v_details := jsonb_build_object(
            'invoice_number', NEW.invoice_number,
            'bill_type', NEW.bill_type,
            'title', NEW.title,
            'total_amount', NEW.total_amount,
            'status', COALESCE(NEW.status, 'draft'),
            'student_id', NEW.student_id
        );
    ELSIF (TG_OP = 'UPDATE') THEN
        -- Only log if significant fields changed
        IF (OLD.status IS DISTINCT FROM NEW.status) THEN
            v_action_type := 'invoice_status_changed';
            v_amount := NEW.total_amount;
            v_details := jsonb_build_object(
                'invoice_number', NEW.invoice_number,
                'old_status', OLD.status,
                'new_status', NEW.status,
                'total_amount', NEW.total_amount,
                'paid_amount', NEW.paid_amount
            );
        ELSIF (OLD.paid_amount IS DISTINCT FROM NEW.paid_amount) THEN
            v_action_type := 'bill_payment_updated';
            v_amount := NEW.paid_amount - OLD.paid_amount;
            v_details := jsonb_build_object(
                'invoice_number', NEW.invoice_number,
                'old_paid_amount', OLD.paid_amount,
                'new_paid_amount', NEW.paid_amount,
                'total_amount', NEW.total_amount
            );
        ELSE
            -- Don't log minor updates
            RETURN NEW;
        END IF;
    END IF;

    -- Insert audit log
    INSERT INTO financial_audit_log (
        school_id,
        action_type,
        user_id,
        amount,
        reference_id,
        details
    ) VALUES (
        NEW.school_id,
        v_action_type,
        auth.uid(),
        v_amount,
        NEW.id,
        v_details
    );

    RETURN NEW;
END;
$$;

-- Create trigger on bills table
DROP TRIGGER IF EXISTS bill_audit_trigger ON bills;
CREATE TRIGGER bill_audit_trigger
    AFTER INSERT OR UPDATE ON bills
    FOR EACH ROW
    EXECUTE FUNCTION log_bill_action();

COMMENT ON FUNCTION log_bill_action IS 
    'Automatically logs bill creation and significant updates to financial_audit_log';


-- =====================================================
-- TRIGGER FUNCTION 2: Log Payment Actions
-- Logs whenever a payment is recorded
-- =====================================================

CREATE OR REPLACE FUNCTION log_payment_action()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_action_type VARCHAR(50);
    v_details JSONB;
BEGIN
    -- Determine if this is a payment or refund
    IF (NEW.amount > 0) THEN
        v_action_type := 'payment_recorded';
    ELSE
        v_action_type := 'refund_processed';
    END IF;

    -- Build details object
    v_details := jsonb_build_object(
        'amount', NEW.amount,
        'method', NEW.method,
        'category', NEW.category,
        'payer_name', NEW.payer_name,
        'date_paid', NEW.date_paid,
        'student_id', NEW.student_id,
        'bill_id', NEW.bill_id
    );

    -- Insert audit log
    INSERT INTO financial_audit_log (
        school_id,
        action_type,
        user_id,
        amount,
        reference_id,
        details
    ) VALUES (
        NEW.school_id,
        v_action_type,
        auth.uid(),
        NEW.amount,
        NEW.id,
        v_details
    );

    RETURN NEW;
END;
$$;

-- Create trigger on payments table
DROP TRIGGER IF EXISTS payment_audit_trigger ON payments;
CREATE TRIGGER payment_audit_trigger
    AFTER INSERT ON payments
    FOR EACH ROW
    EXECUTE FUNCTION log_payment_action();

COMMENT ON FUNCTION log_payment_action IS 
    'Automatically logs payment and refund transactions to financial_audit_log';


-- =====================================================
-- TRIGGER FUNCTION 3: Log Payment Allocation Actions
-- Logs whenever a payment is allocated to a bill
-- =====================================================

CREATE OR REPLACE FUNCTION log_payment_allocation_action()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_action_type VARCHAR(50);
    v_details JSONB;
    v_payment_amount NUMERIC;
    v_invoice_number VARCHAR;
BEGIN
    IF (TG_OP = 'INSERT') THEN
        v_action_type := 'payment_allocated';
        
        -- Get payment amount and invoice number for context
        SELECT p.amount, b.invoice_number
        INTO v_payment_amount, v_invoice_number
        FROM payments p
        LEFT JOIN bills b ON b.id = NEW.bill_id
        WHERE p.id = NEW.payment_id;

        v_details := jsonb_build_object(
            'allocation_amount', NEW.amount,
            'total_payment_amount', v_payment_amount,
            'invoice_number', v_invoice_number,
            'payment_id', NEW.payment_id,
            'bill_id', NEW.bill_id
        );

        -- Insert audit log
        INSERT INTO financial_audit_log (
            school_id,
            action_type,
            user_id,
            amount,
            reference_id,
            details
        ) VALUES (
            NEW.school_id,
            v_action_type,
            auth.uid(),
            NEW.amount,
            NEW.id,
            v_details
        );
    ELSIF (TG_OP = 'DELETE') THEN
        v_action_type := 'payment_allocation_reversed';
        
        v_details := jsonb_build_object(
            'allocation_amount', OLD.amount,
            'payment_id', OLD.payment_id,
            'bill_id', OLD.bill_id,
            'reason', 'allocation_deleted'
        );

        -- Insert audit log
        INSERT INTO financial_audit_log (
            school_id,
            action_type,
            user_id,
            amount,
            reference_id,
            details
        ) VALUES (
            OLD.school_id,
            v_action_type,
            auth.uid(),
            OLD.amount,
            OLD.id,
            v_details
        );
    END IF;

    IF (TG_OP = 'DELETE') THEN
        RETURN OLD;
    ELSE
        RETURN NEW;
    END IF;
END;
$$;

-- Create trigger on payment_allocations table
DROP TRIGGER IF EXISTS payment_allocation_audit_trigger ON payment_allocations;
CREATE TRIGGER payment_allocation_audit_trigger
    AFTER INSERT OR DELETE ON payment_allocations
    FOR EACH ROW
    EXECUTE FUNCTION log_payment_allocation_action();

COMMENT ON FUNCTION log_payment_allocation_action IS 
    'Automatically logs payment allocation and reversal actions to financial_audit_log';


-- =====================================================
-- TRIGGER FUNCTION 4: Automatic Bill Status Update
-- Updates bill status based on payment amount
-- =====================================================

CREATE OR REPLACE FUNCTION update_bill_status_on_payment()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_total_allocated NUMERIC;
    v_bill_total NUMERIC;
    v_new_status VARCHAR(20);
BEGIN
    -- Calculate total allocated to this bill
    SELECT 
        COALESCE(SUM(amount), 0),
        b.total_amount
    INTO v_total_allocated, v_bill_total
    FROM payment_allocations pa
    LEFT JOIN bills b ON b.id = NEW.bill_id
    WHERE pa.bill_id = NEW.bill_id
    GROUP BY b.total_amount;

    -- Determine new status
    IF (v_total_allocated >= v_bill_total) THEN
        v_new_status := 'paid';
    ELSIF (v_total_allocated > 0) THEN
        v_new_status := 'partial';
    ELSE
        v_new_status := 'sent';
    END IF;

    -- Update bill status and paid_amount
    UPDATE bills
    SET 
        paid_amount = v_total_allocated,
        is_paid = CASE WHEN v_total_allocated >= total_amount THEN 1 ELSE 0 END,
        status = v_new_status,
        updated_at = NOW()
    WHERE id = NEW.bill_id;

    RETURN NEW;
END;
$$;

-- Create trigger on payment_allocations table
DROP TRIGGER IF EXISTS update_bill_status_trigger ON payment_allocations;
CREATE TRIGGER update_bill_status_trigger
    AFTER INSERT ON payment_allocations
    FOR EACH ROW
    EXECUTE FUNCTION update_bill_status_on_payment();

COMMENT ON FUNCTION update_bill_status_on_payment IS 
    'Automatically updates bill status and paid_amount when payment is allocated';


-- =====================================================
-- TRIGGER FUNCTION 5: Revert Bill Status on Allocation Delete
-- Recalculates bill status when allocation is removed
-- =====================================================

CREATE OR REPLACE FUNCTION revert_bill_status_on_allocation_delete()
RETURNS TRIGGER
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_total_allocated NUMERIC;
    v_bill_total NUMERIC;
    v_new_status VARCHAR(20);
BEGIN
    -- Recalculate total allocated to this bill (after deletion)
    SELECT 
        COALESCE(SUM(amount), 0),
        b.total_amount
    INTO v_total_allocated, v_bill_total
    FROM payment_allocations pa
    RIGHT JOIN bills b ON b.id = OLD.bill_id
    WHERE pa.bill_id = OLD.bill_id OR b.id = OLD.bill_id
    GROUP BY b.total_amount;

    -- Determine new status
    IF (v_total_allocated >= v_bill_total) THEN
        v_new_status := 'paid';
    ELSIF (v_total_allocated > 0) THEN
        v_new_status := 'partial';
    ELSE
        v_new_status := 'sent';
    END IF;

    -- Update bill status and paid_amount
    UPDATE bills
    SET 
        paid_amount = v_total_allocated,
        is_paid = CASE WHEN v_total_allocated >= total_amount THEN 1 ELSE 0 END,
        status = v_new_status,
        updated_at = NOW()
    WHERE id = OLD.bill_id;

    RETURN OLD;
END;
$$;

-- Create trigger on payment_allocations table
DROP TRIGGER IF EXISTS revert_bill_status_trigger ON payment_allocations;
CREATE TRIGGER revert_bill_status_trigger
    AFTER DELETE ON payment_allocations
    FOR EACH ROW
    EXECUTE FUNCTION revert_bill_status_on_allocation_delete();

COMMENT ON FUNCTION revert_bill_status_on_allocation_delete IS 
    'Recalculates bill status when payment allocation is deleted (refund scenario)';


-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

/*
Test the triggers with sample operations:

-- Test 1: Create a bill and check audit log
INSERT INTO bills (id, school_id, student_id, title, invoice_number, total_amount, bill_type, status)
VALUES (gen_random_uuid(), 'your-school-id', 'your-student-id', 'Test Invoice', 'INV-99999', 100.00, 'adhoc', 'draft');

SELECT * FROM financial_audit_log WHERE action_type = 'invoice_created' ORDER BY created_at DESC LIMIT 1;

-- Test 2: Record a payment and check audit log
INSERT INTO payments (id, school_id, student_id, amount, method, date_paid)
VALUES (gen_random_uuid(), 'your-school-id', 'your-student-id', 50.00, 'Cash', CURRENT_DATE);

SELECT * FROM financial_audit_log WHERE action_type = 'payment_recorded' ORDER BY created_at DESC LIMIT 1;

-- Test 3: Allocate payment to bill and verify status update
INSERT INTO payment_allocations (payment_id, bill_id, school_id, amount)
VALUES ('payment-id', 'bill-id', 'school-id', 50.00);

SELECT status, paid_amount FROM bills WHERE id = 'bill-id';
SELECT * FROM financial_audit_log WHERE action_type = 'payment_allocated' ORDER BY created_at DESC LIMIT 1;

-- Test 4: Check all triggers are active
SELECT 
    trigger_name,
    event_manipulation,
    event_object_table,
    action_timing,
    action_statement
FROM information_schema.triggers
WHERE trigger_schema = 'public'
    AND event_object_table IN ('bills', 'payments', 'payment_allocations')
ORDER BY event_object_table, trigger_name;
*/
