-- =====================================================
-- FINANCIAL SYSTEM RPC FUNCTIONS
-- Date: January 3, 2026
-- Purpose: Server-side business logic for financial operations
-- =====================================================

-- =====================================================
-- 1. GET OUTSTANDING BILLS WITH BALANCE
-- Returns unpaid/partially paid bills for a student
-- =====================================================

CREATE OR REPLACE FUNCTION get_outstanding_bills_with_balance(
    p_student_id UUID
)
RETURNS TABLE (
    bill_id UUID,
    invoice_number VARCHAR,
    title TEXT,
    total_amount NUMERIC,
    paid_amount NUMERIC,
    balance NUMERIC,
    due_date TIMESTAMP WITH TIME ZONE,
    status VARCHAR,
    bill_type VARCHAR
) 
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    -- Verify user has access to this student's data
    IF NOT EXISTS (
        SELECT 1 FROM user_profiles up
        JOIN students s ON s.school_id = up.school_id
        WHERE up.id = auth.uid()
        AND s.id = p_student_id
    ) THEN
        RAISE EXCEPTION 'Access denied: You do not have permission to view this student''s bills';
    END IF;

    RETURN QUERY
    SELECT 
        b.id AS bill_id,
        b.invoice_number,
        b.title,
        b.total_amount,
        COALESCE(b.paid_amount, 0) AS paid_amount,
        (b.total_amount - COALESCE(b.paid_amount, 0)) AS balance,
        b.due_date::TIMESTAMP WITH TIME ZONE,
        COALESCE(b.status, 'pending') AS status,
        b.bill_type
    FROM bills b
    WHERE b.student_id = p_student_id
        AND b.is_paid = 0
        AND (b.total_amount - COALESCE(b.paid_amount, 0)) > 0
    ORDER BY b.due_date ASC NULLS LAST, b.created_at DESC;
END;
$$;

COMMENT ON FUNCTION get_outstanding_bills_with_balance IS 
    'Returns all unpaid/partially paid bills for a student with calculated balance';


-- =====================================================
-- 2. GET BILL PAYMENT SUMMARY
-- Returns payment allocation breakdown for a specific bill
-- =====================================================

CREATE OR REPLACE FUNCTION get_bill_payment_summary(
    p_bill_id UUID
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result JSON;
    v_school_id UUID;
BEGIN
    -- Get school_id for access check
    SELECT school_id INTO v_school_id
    FROM bills
    WHERE id = p_bill_id;

    IF v_school_id IS NULL THEN
        RAISE EXCEPTION 'Bill not found';
    END IF;

    -- Verify user has access
    IF NOT EXISTS (
        SELECT 1 FROM user_profiles
        WHERE id = auth.uid()
        AND school_id = v_school_id
    ) THEN
        RAISE EXCEPTION 'Access denied';
    END IF;

    -- Build comprehensive payment summary
    SELECT json_build_object(
        'bill_id', b.id,
        'invoice_number', b.invoice_number,
        'title', b.title,
        'total_amount', b.total_amount,
        'paid_amount', COALESCE(b.paid_amount, 0),
        'balance', (b.total_amount - COALESCE(b.paid_amount, 0)),
        'is_paid', b.is_paid,
        'status', COALESCE(b.status, 'pending'),
        'allocations', COALESCE(
            (
                SELECT json_agg(
                    json_build_object(
                        'allocation_id', pa.id,
                        'payment_id', pa.payment_id,
                        'amount', pa.amount,
                        'payment_date', p.date_paid,
                        'payment_method', p.method,
                        'payer_name', p.payer_name,
                        'created_at', pa.created_at
                    )
                    ORDER BY pa.created_at DESC
                )
                FROM payment_allocations pa
                JOIN payments p ON p.id = pa.payment_id
                WHERE pa.bill_id = p_bill_id
            ),
            '[]'::json
        ),
        'payment_count', (
            SELECT COUNT(*) 
            FROM payment_allocations 
            WHERE bill_id = p_bill_id
        )
    ) INTO v_result
    FROM bills b
    WHERE b.id = p_bill_id;

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION get_bill_payment_summary IS 
    'Returns detailed payment allocation breakdown for a specific bill';


-- =====================================================
-- 3. GET INVOICE STATISTICS
-- Returns invoice metrics for a school
-- =====================================================

CREATE OR REPLACE FUNCTION get_invoice_statistics(
    p_school_id UUID,
    p_start_date DATE DEFAULT NULL,
    p_end_date DATE DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result JSON;
BEGIN
    -- Verify user has access
    IF NOT EXISTS (
        SELECT 1 FROM user_profiles
        WHERE id = auth.uid()
        AND school_id = p_school_id
    ) THEN
        RAISE EXCEPTION 'Access denied';
    END IF;

    SELECT json_build_object(
        'total_invoices', COUNT(*),
        'draft_count', COUNT(*) FILTER (WHERE status = 'draft'),
        'sent_count', COUNT(*) FILTER (WHERE status = 'sent'),
        'paid_count', COUNT(*) FILTER (WHERE status = 'paid' OR is_paid = 1),
        'overdue_count', COUNT(*) FILTER (WHERE status = 'overdue'),
        'total_billed', COALESCE(SUM(total_amount), 0),
        'total_collected', COALESCE(SUM(paid_amount), 0),
        'total_outstanding', COALESCE(SUM(total_amount - COALESCE(paid_amount, 0)), 0),
        'collection_rate', CASE 
            WHEN SUM(total_amount) > 0 
            THEN ROUND((SUM(COALESCE(paid_amount, 0)) / SUM(total_amount) * 100)::NUMERIC, 2)
            ELSE 0 
        END
    ) INTO v_result
    FROM bills
    WHERE school_id = p_school_id
        AND bill_type = 'adhoc'
        AND (p_start_date IS NULL OR created_at::DATE >= p_start_date)
        AND (p_end_date IS NULL OR created_at::DATE <= p_end_date);

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION get_invoice_statistics IS 
    'Returns comprehensive invoice statistics for a school with optional date filtering';


-- =====================================================
-- 4. GET TRANSACTION SUMMARY
-- Returns financial transaction summary for dashboard
-- =====================================================

CREATE OR REPLACE FUNCTION get_transaction_summary(
    p_school_id UUID,
    p_start_date DATE DEFAULT NULL,
    p_end_date DATE DEFAULT NULL
)
RETURNS JSON
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_result JSON;
BEGIN
    -- Verify user has access
    IF NOT EXISTS (
        SELECT 1 FROM user_profiles
        WHERE id = auth.uid()
        AND school_id = p_school_id
    ) THEN
        RAISE EXCEPTION 'Access denied';
    END IF;

    SELECT json_build_object(
        'total_revenue', COALESCE(SUM(amount) FILTER (WHERE amount > 0), 0),
        'total_refunds', COALESCE(ABS(SUM(amount)) FILTER (WHERE amount < 0), 0),
        'net_revenue', COALESCE(SUM(amount), 0),
        'transaction_count', COUNT(*),
        'payment_count', COUNT(*) FILTER (WHERE amount > 0),
        'refund_count', COUNT(*) FILTER (WHERE amount < 0),
        'payment_methods', (
            SELECT json_object_agg(method, method_count)
            FROM (
                SELECT 
                    method,
                    COUNT(*) AS method_count
                FROM payments
                WHERE school_id = p_school_id
                    AND amount > 0
                    AND (p_start_date IS NULL OR date_paid::DATE >= p_start_date)
                    AND (p_end_date IS NULL OR date_paid::DATE <= p_end_date)
                GROUP BY method
            ) methods
        ),
        'average_payment', CASE 
            WHEN COUNT(*) FILTER (WHERE amount > 0) > 0 
            THEN ROUND((SUM(amount) FILTER (WHERE amount > 0) / COUNT(*) FILTER (WHERE amount > 0))::NUMERIC, 2)
            ELSE 0 
        END
    ) INTO v_result
    FROM payments
    WHERE school_id = p_school_id
        AND (p_start_date IS NULL OR date_paid::DATE >= p_start_date)
        AND (p_end_date IS NULL OR date_paid::DATE <= p_end_date);

    RETURN v_result;
END;
$$;

COMMENT ON FUNCTION get_transaction_summary IS 
    'Returns financial transaction summary including revenue, refunds, and payment method breakdown';


-- =====================================================
-- 5. GENERATE NEXT INVOICE NUMBER
-- Returns the next sequential invoice number for a school
-- =====================================================

CREATE OR REPLACE FUNCTION generate_next_invoice_number(
    p_school_id UUID
)
RETURNS VARCHAR(50)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_max_number INT;
    v_next_number VARCHAR(50);
BEGIN
    -- Verify user has access
    IF NOT EXISTS (
        SELECT 1 FROM user_profiles
        WHERE id = auth.uid()
        AND school_id = p_school_id
        AND role IN ('school_admin', 'super_admin')
    ) THEN
        RAISE EXCEPTION 'Access denied: Only admins can generate invoice numbers';
    END IF;

    -- Get the highest invoice number for this school
    SELECT COALESCE(
        MAX(
            CASE 
                WHEN invoice_number ~ '^INV-[0-9]+$' 
                THEN SUBSTRING(invoice_number FROM 5)::INT
                ELSE 0
            END
        ), 
        0
    ) INTO v_max_number
    FROM bills
    WHERE school_id = p_school_id
        AND invoice_number IS NOT NULL;

    -- Generate next number with zero-padding
    v_next_number := 'INV-' || LPAD((v_max_number + 1)::TEXT, 5, '0');

    RETURN v_next_number;
END;
$$;

COMMENT ON FUNCTION generate_next_invoice_number IS 
    'Generates the next sequential invoice number in format INV-XXXXX';


-- =====================================================
-- 6. GET PAYMENT ALLOCATION HISTORY
-- Returns payment allocation history for a student
-- =====================================================

CREATE OR REPLACE FUNCTION get_payment_allocation_history(
    p_student_id UUID,
    p_limit INT DEFAULT 50
)
RETURNS TABLE (
    allocation_id UUID,
    payment_id UUID,
    bill_id UUID,
    invoice_number VARCHAR,
    bill_title TEXT,
    amount NUMERIC,
    payment_date DATE,
    payment_method VARCHAR,
    payer_name TEXT,
    created_at TIMESTAMPTZ
)
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_school_id UUID;
BEGIN
    -- Get school_id for access check
    SELECT school_id INTO v_school_id
    FROM students
    WHERE id = p_student_id;

    IF v_school_id IS NULL THEN
        RAISE EXCEPTION 'Student not found';
    END IF;

    -- Verify user has access
    IF NOT EXISTS (
        SELECT 1 FROM user_profiles
        WHERE id = auth.uid()
        AND school_id = v_school_id
    ) THEN
        RAISE EXCEPTION 'Access denied';
    END IF;

    RETURN QUERY
    SELECT 
        pa.id AS allocation_id,
        pa.payment_id,
        pa.bill_id,
        b.invoice_number,
        b.title AS bill_title,
        pa.amount,
        p.date_paid::DATE AS payment_date,
        p.method AS payment_method,
        p.payer_name,
        pa.created_at
    FROM payment_allocations pa
    JOIN payments p ON p.id = pa.payment_id
    JOIN bills b ON b.id = pa.bill_id
    WHERE p.student_id = p_student_id
    ORDER BY pa.created_at DESC
    LIMIT p_limit;
END;
$$;

COMMENT ON FUNCTION get_payment_allocation_history IS 
    'Returns payment allocation history for a student with bill and payment details';


-- =====================================================
-- GRANT EXECUTE PERMISSIONS
-- =====================================================

GRANT EXECUTE ON FUNCTION get_outstanding_bills_with_balance TO authenticated;
GRANT EXECUTE ON FUNCTION get_bill_payment_summary TO authenticated;
GRANT EXECUTE ON FUNCTION get_invoice_statistics TO authenticated;
GRANT EXECUTE ON FUNCTION get_transaction_summary TO authenticated;
GRANT EXECUTE ON FUNCTION generate_next_invoice_number TO authenticated;
GRANT EXECUTE ON FUNCTION get_payment_allocation_history TO authenticated;


-- =====================================================
-- VERIFICATION QUERIES
-- =====================================================

/*
Test the RPC functions with sample data:

-- Test 1: Get outstanding bills (replace with actual student_id)
SELECT * FROM get_outstanding_bills_with_balance('your-student-uuid');

-- Test 2: Get bill payment summary (replace with actual bill_id)
SELECT get_bill_payment_summary('your-bill-uuid');

-- Test 3: Get invoice statistics (replace with actual school_id)
SELECT get_invoice_statistics('your-school-uuid');

-- Test 4: Get transaction summary (replace with actual school_id)
SELECT get_transaction_summary('your-school-uuid');

-- Test 5: Generate next invoice number (replace with actual school_id)
SELECT generate_next_invoice_number('your-school-uuid');

-- Test 6: Get payment allocation history (replace with actual student_id)
SELECT * FROM get_payment_allocation_history('your-student-uuid');
*/
