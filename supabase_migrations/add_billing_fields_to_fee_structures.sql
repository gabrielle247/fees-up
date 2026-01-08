-- Migration: Add billing fields to finance.fee_structures
-- Date: 2026-01-08
-- Purpose: Support monthly, termly, yearly billing with suspension windows

BEGIN;

-- Add billing type and recurrence columns
ALTER TABLE finance.fee_structures
ADD COLUMN IF NOT EXISTS billing_type text NOT NULL DEFAULT 'tuition'
  CHECK (billing_type IN ('tuition', 'exam', 'transport', 'penalty', 'discount', 'scholarship'));

ALTER TABLE finance.fee_structures
ADD COLUMN IF NOT EXISTS recurrence text NOT NULL DEFAULT 'none'
  CHECK (recurrence IN ('none', 'monthly', 'termly', 'yearly'));

-- Add billable months (array of 1-12 representing months Jan-Dec)
ALTER TABLE finance.fee_structures
ADD COLUMN IF NOT EXISTS billable_months integer[] DEFAULT '{}';

-- Add suspension windows (array of periods when billing is suspended)
ALTER TABLE finance.fee_structures
ADD COLUMN IF NOT EXISTS suspensions jsonb DEFAULT '[]';

-- Create indexes for efficient queries
CREATE INDEX IF NOT EXISTS idx_fee_structures_recurrence
  ON finance.fee_structures(school_id, recurrence)
  WHERE recurrence != 'none';

CREATE INDEX IF NOT EXISTS idx_fee_structures_academic_year
  ON finance.fee_structures(school_id, academic_year_id);

-- Add comment for documentation
COMMENT ON COLUMN finance.fee_structures.billing_type IS 'Type of billing: tuition, exam, transport, penalty, discount, scholarship';
COMMENT ON COLUMN finance.fee_structures.recurrence IS 'Billing frequency: none (one-time), monthly, termly (3 terms/year), yearly';
COMMENT ON COLUMN finance.fee_structures.billable_months IS 'Array of billable months (1-12). Empty means all months in academic year. Only applies to monthly recurrence.';
COMMENT ON COLUMN finance.fee_structures.suspensions IS 'JSON array of {start: ISO8601, end: ISO8601} suspension windows (holidays, etc.). Periods overlapping these windows are skipped.';

COMMIT;
