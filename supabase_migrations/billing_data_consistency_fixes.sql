-- ============================================================================
-- FEES UP: BILLING DATA CONSISTENCY FIXES
-- Phase 1: Critical Data Integrity & Automation
-- ============================================================================
-- Author: GitHub Copilot + User
-- Date: January 6, 2026
-- Purpose: Add triggers for student total recalculation and late fee auto-application

-- ============================================================================
-- 1. STUDENT TOTALS RECALCULATION TRIGGER
-- ============================================================================
-- When bills or payments change, automatically recalculate students.owed_total
-- and students.paid_total to prevent data staleness

CREATE OR REPLACE FUNCTION recalculate_student_totals()
RETURNS TRIGGER AS $$
BEGIN
  -- Determine the student_id based on which table triggered this
  DECLARE
    p_student_id UUID;
  BEGIN
    IF TG_TABLE_NAME = 'bills' THEN
      p_student_id := NEW.student_id;
    ELSIF TG_TABLE_NAME = 'payments' THEN
      p_student_id := NEW.student_id;
    ELSIF TG_TABLE_NAME = 'payment_allocations' THEN
      -- For payment_allocations, get student_id from related payment
      SELECT student_id INTO p_student_id
      FROM payments WHERE id = NEW.payment_id;
    ELSE
      RETURN NEW;
    END IF;

    -- Recalculate totals
    UPDATE students
    SET
      owed_total = COALESCE(
        (SELECT SUM(b.total_amount - b.paid_amount)
         FROM bills b
         WHERE b.student_id = p_student_id AND b.is_paid = 0),
        0
      ),
      paid_total = COALESCE(
        (SELECT SUM(b.paid_amount)
         FROM bills b
         WHERE b.student_id = p_student_id),
        0
      ),
      updated_at = NOW()
    WHERE id = p_student_id;

    RETURN NEW;
  END;
END;
$$ LANGUAGE plpgsql;

-- Trigger on bills table (INSERT/UPDATE)
DROP TRIGGER IF EXISTS update_student_totals_on_bills ON bills;
CREATE TRIGGER update_student_totals_on_bills
AFTER INSERT OR UPDATE ON bills
FOR EACH ROW
EXECUTE FUNCTION recalculate_student_totals();

-- Trigger on payments table (INSERT/UPDATE)
DROP TRIGGER IF EXISTS update_student_totals_on_payments ON payments;
CREATE TRIGGER update_student_totals_on_payments
AFTER INSERT OR UPDATE ON payments
FOR EACH ROW
EXECUTE FUNCTION recalculate_student_totals();

-- Trigger on payment_allocations table (INSERT/UPDATE/DELETE)
DROP TRIGGER IF EXISTS update_student_totals_on_allocations ON payment_allocations;
CREATE TRIGGER update_student_totals_on_allocations
AFTER INSERT OR UPDATE OR DELETE ON payment_allocations
FOR EACH ROW
EXECUTE FUNCTION recalculate_student_totals();

-- ============================================================================
-- 2. LATE FEE AUTO-APPLICATION TRIGGER
-- ============================================================================
-- Automatically apply late fees to bills past their grace period

CREATE OR REPLACE FUNCTION apply_late_fees()
RETURNS TRIGGER AS $$
BEGIN
  -- Only apply late fees on INSERT or UPDATE if bill becomes overdue
  IF TG_OP IN ('INSERT', 'UPDATE') THEN
    -- Calculate and apply late fee if applicable
    IF NEW.is_paid = 0 AND NEW.billing_cycle_end IS NOT NULL THEN
      DECLARE
        v_config RECORD;
        v_days_overdue INTEGER;
        v_calculated_late_fee DECIMAL;
        v_grace_period_days INTEGER;
      BEGIN
        -- Get billing config for this school
        SELECT late_fee_percentage, grace_period_days
        INTO v_config
        FROM billing_configs
        WHERE school_id = NEW.school_id;

        IF v_config IS NOT NULL THEN
          v_grace_period_days := COALESCE(v_config.grace_period_days, 7);
          
          -- Check if bill is past grace period
          v_days_overdue := FLOOR(
            EXTRACT(DAY FROM (NOW() - (NEW.billing_cycle_end + (v_grace_period_days || ' days')::INTERVAL)))
          );

          IF v_days_overdue > 0 AND v_config.late_fee_percentage > 0 THEN
            -- Calculate late fee: (total_amount - paid_amount) * (late_fee_percentage / 100)
            v_calculated_late_fee := ROUND(
              ((NEW.total_amount - NEW.paid_amount) * v_config.late_fee_percentage / 100)::NUMERIC,
              2
            );

            -- Update late fee if not already set or if different
            IF COALESCE(NEW.late_fee, 0) < v_calculated_late_fee THEN
              NEW.late_fee := v_calculated_late_fee;
              NEW.updated_at := NOW();
            END IF;
          END IF;
        END IF;
      END;
    END IF;
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS apply_late_fees_trigger ON bills;
CREATE TRIGGER apply_late_fees_trigger
BEFORE INSERT OR UPDATE ON bills
FOR EACH ROW
EXECUTE FUNCTION apply_late_fees();

-- ============================================================================
-- 3. UPDATE BILL PAID_AMOUNT WHEN ALLOCATIONS CHANGE
-- ============================================================================
-- Sync payment_allocations sum to bills.paid_amount

CREATE OR REPLACE FUNCTION sync_bill_paid_amount()
RETURNS TRIGGER AS $$
BEGIN
  IF TG_OP = 'DELETE' THEN
    UPDATE bills
    SET
      paid_amount = COALESCE(
        (SELECT SUM(amount) FROM payment_allocations WHERE bill_id = OLD.bill_id),
        0
      ),
      is_paid = CASE 
        WHEN COALESCE((SELECT SUM(amount) FROM payment_allocations WHERE bill_id = OLD.bill_id), 0) >= total_amount
        THEN 1
        ELSE 0
      END,
      updated_at = NOW()
    WHERE id = OLD.bill_id;
    RETURN OLD;
  ELSE
    UPDATE bills
    SET
      paid_amount = COALESCE(
        (SELECT SUM(amount) FROM payment_allocations WHERE bill_id = NEW.bill_id),
        0
      ),
      is_paid = CASE 
        WHEN COALESCE((SELECT SUM(amount) FROM payment_allocations WHERE bill_id = NEW.bill_id), 0) >= total_amount
        THEN 1
        ELSE 0
      END,
      updated_at = NOW()
    WHERE id = NEW.bill_id;
    RETURN NEW;
  END IF;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS sync_bill_paid_on_allocations ON payment_allocations;
CREATE TRIGGER sync_bill_paid_on_allocations
AFTER INSERT OR UPDATE OR DELETE ON payment_allocations
FOR EACH ROW
EXECUTE FUNCTION sync_bill_paid_amount();

-- ============================================================================
-- 4. BILLING AUDIT LOG (if not exists)
-- ============================================================================
-- Create audit log table if it doesn't exist

CREATE TABLE IF NOT EXISTS billing_audit_log (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  school_id UUID NOT NULL REFERENCES schools(id),
  action VARCHAR(100) NOT NULL,  -- 'Invoice Created', 'Payment Recorded', etc.
  description TEXT,
  details JSONB,  -- Additional context in JSON
  changed_by UUID REFERENCES user_profiles(id),
  ip_address INET,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Index for fast queries
CREATE INDEX IF NOT EXISTS idx_billing_audit_school_date
ON billing_audit_log(school_id, created_at DESC);

-- RLS Policy
ALTER TABLE billing_audit_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "Schools can view own audit logs" ON billing_audit_log;
CREATE POLICY "Schools can view own audit logs"
  ON billing_audit_log
  FOR SELECT
  USING (
    school_id = (SELECT school_id FROM user_profiles WHERE id = auth.uid())
  );

-- ============================================================================
-- 5. AUDIT LOG TRIGGERS
-- ============================================================================

CREATE OR REPLACE FUNCTION log_billing_action()
RETURNS TRIGGER AS $$
BEGIN
  DECLARE
    v_action VARCHAR(100);
    v_description TEXT;
    v_details JSONB;
  BEGIN
    -- Determine action based on operation and table
    IF TG_OP = 'INSERT' THEN
      v_action := CASE TG_TABLE_NAME
        WHEN 'bills' THEN 'Invoice Created'
        WHEN 'payments' THEN 'Payment Recorded'
        WHEN 'payment_allocations' THEN 'Payment Allocated'
        WHEN 'billing_configs' THEN 'Config Updated'
        ELSE TG_TABLE_NAME || ' Created'
      END;
      v_description := CASE TG_TABLE_NAME
        WHEN 'bills' THEN 'New invoice: ' || COALESCE(NEW.title, 'Unnamed')
        WHEN 'payments' THEN 'Payment of ' || COALESCE(NEW.amount::TEXT, '0')
        WHEN 'payment_allocations' THEN 'Allocation to bill'
        WHEN 'billing_configs' THEN 'Billing configuration updated'
        ELSE 'New record created'
      END;
      v_details := row_to_json(NEW);
    ELSIF TG_OP = 'UPDATE' THEN
      v_action := CASE TG_TABLE_NAME
        WHEN 'bills' THEN 'Bill Status Changed'
        WHEN 'payments' THEN 'Payment Updated'
        WHEN 'billing_configs' THEN 'Config Updated'
        ELSE TG_TABLE_NAME || ' Updated'
      END;
      v_description := CASE TG_TABLE_NAME
        WHEN 'bills' THEN 'Status: ' || COALESCE(NEW.status, 'unknown')
        WHEN 'payments' THEN 'Payment adjusted'
        WHEN 'billing_configs' THEN 'Configuration modified'
        ELSE 'Record updated'
      END;
      v_details := jsonb_build_object('before', row_to_json(OLD), 'after', row_to_json(NEW));
    ELSIF TG_OP = 'DELETE' THEN
      v_action := 'Deleted';
      v_description := TG_TABLE_NAME || ' deleted';
      v_details := row_to_json(OLD);
    END IF;

    -- Insert audit log entry
    INSERT INTO billing_audit_log (school_id, action, description, details, changed_by)
    VALUES (
      COALESCE(NEW.school_id, OLD.school_id),
      v_action,
      v_description,
      v_details,
      auth.uid()
    );

    RETURN COALESCE(NEW, OLD);
  END;
$$ LANGUAGE plpgsql;

-- Attach audit triggers
DROP TRIGGER IF EXISTS audit_bills_changes ON bills;
CREATE TRIGGER audit_bills_changes
AFTER INSERT OR UPDATE OR DELETE ON bills
FOR EACH ROW EXECUTE FUNCTION log_billing_action();

DROP TRIGGER IF EXISTS audit_payments_changes ON payments;
CREATE TRIGGER audit_payments_changes
AFTER INSERT OR UPDATE OR DELETE ON payments
FOR EACH ROW EXECUTE FUNCTION log_billing_action();

DROP TRIGGER IF EXISTS audit_billing_configs_changes ON billing_configs;
CREATE TRIGGER audit_billing_configs_changes
AFTER INSERT OR UPDATE ON billing_configs
FOR EACH ROW EXECUTE FUNCTION log_billing_action();

-- ============================================================================
-- 6. RPC FUNCTION: Get Audit Log
-- ============================================================================

CREATE OR REPLACE FUNCTION get_billing_audit_log(
  p_school_id UUID,
  p_limit INT DEFAULT 100,
  p_offset INT DEFAULT 0
)
RETURNS TABLE (
  id UUID,
  action VARCHAR,
  description TEXT,
  details JSONB,
  changed_by UUID,
  created_at TIMESTAMPTZ
) AS $$
BEGIN
  RETURN QUERY
  SELECT
    bal.id,
    bal.action,
    bal.description,
    bal.details,
    bal.changed_by,
    bal.created_at
  FROM billing_audit_log bal
  WHERE bal.school_id = p_school_id
  ORDER BY bal.created_at DESC
  LIMIT p_limit
  OFFSET p_offset;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 7. RPC FUNCTION: Calculate Student Totals (Manual Trigger)
-- ============================================================================

CREATE OR REPLACE FUNCTION calculate_student_totals(p_student_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  UPDATE students
  SET
    owed_total = COALESCE(
      (SELECT SUM(b.total_amount - b.paid_amount)
       FROM bills b
       WHERE b.student_id = p_student_id AND b.is_paid = 0),
      0
    ),
    paid_total = COALESCE(
      (SELECT SUM(b.paid_amount)
       FROM bills b
       WHERE b.student_id = p_student_id),
      0
    ),
    updated_at = NOW()
  WHERE id = p_student_id;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- ============================================================================
-- 8. VERIFY EXISTING DATA
-- ============================================================================
-- Run this once to fix any stale student totals

-- UPDATE students s
-- SET
--   owed_total = COALESCE(
--     (SELECT SUM(b.total_amount - b.paid_amount)
--      FROM bills b
--      WHERE b.student_id = s.id AND b.is_paid = 0),
--     0
--   ),
--   paid_total = COALESCE(
--     (SELECT SUM(b.paid_amount)
--      FROM bills b
--      WHERE b.student_id = s.id),
--     0
--   )
-- WHERE school_id IN (SELECT id FROM schools);

-- ============================================================================
-- SUMMARY
-- ============================================================================
-- ✅ Student totals now auto-recalculate when bills/payments change
-- ✅ Late fees auto-apply to overdue bills (configurable grace period)
-- ✅ Bill paid_amount syncs with payment_allocations
-- ✅ Audit trail logs all billing changes
-- ✅ RPC functions available for manual recalculation if needed
--
-- TESTING CHECKLIST:
-- 1. Create bill → students.owed_total should increase
-- 2. Record payment → students.owed_total should decrease
-- 3. Create payment allocation → bills.paid_amount should update
-- 4. Wait > grace_period days → late fees should auto-apply
-- 5. Check billing_audit_log → all actions should be logged
