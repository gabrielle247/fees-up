-- ============================================================================
-- BILLING SUSPENSION SYSTEM - DATABASE SCHEMA MIGRATION
-- ============================================================================
-- 
-- Purpose: Add billing suspension infrastructure to support global and
--          granular billing pause functionality with audit logging
--
-- Created: January 3, 2026
-- Scope: Supabase PostgreSQL database
-- 
-- ============================================================================

BEGIN TRANSACTION;

-- ============================================================================
-- 1. BILLING SUSPENSION PERIODS TABLE
-- ============================================================================
-- Tracks all periods when billing is suspended (globally or by scope)

CREATE TABLE IF NOT EXISTS billing_suspension_periods (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Foreign Keys
  school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  created_by UUID NOT NULL REFERENCES user_profiles(id),
  
  -- Suspension Dates
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ,
  
  -- Details
  reason TEXT NOT NULL,                    -- Required: e.g., 'Term break', 'System maintenance'
  custom_note TEXT,                        -- Optional: Additional notes from school admin
  status VARCHAR(20) NOT NULL DEFAULT 'active' 
    CHECK (status IN ('active', 'completed', 'cancelled')),
  
  -- Scope: null = global, or JSON array of scopes
  -- Example: null = all students
  -- Example: {"type": "grades", "values": ["Grade 1", "Grade 2"]}
  -- Example: {"type": "students", "values": ["student-id-1", "student-id-2"]}
  -- Example: {"type": "fee_types", "values": ["tuition", "transport"]}
  scope JSONB DEFAULT '{}',
  
  -- Audit Trail
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT valid_dates CHECK (
    end_date IS NULL OR end_date > start_date
  ),
  CONSTRAINT valid_reason_length CHECK (
    LENGTH(reason) >= 5 AND LENGTH(reason) <= 500
  )
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_billing_suspension_school_id
  ON billing_suspension_periods(school_id);

CREATE INDEX IF NOT EXISTS idx_billing_suspension_school_status
  ON billing_suspension_periods(school_id, status);

CREATE INDEX IF NOT EXISTS idx_billing_suspension_dates
  ON billing_suspension_periods(school_id, start_date, end_date);

CREATE INDEX IF NOT EXISTS idx_billing_suspension_active
  ON billing_suspension_periods(school_id)
  WHERE status = 'active';

-- RLS Policy: Schools can only see their own suspension periods
ALTER TABLE billing_suspension_periods ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Schools can view own suspension periods"
  ON billing_suspension_periods
  FOR SELECT
  USING (
    school_id = (SELECT school_id FROM user_profiles WHERE id = auth.uid())
  );

CREATE POLICY "Admins can create suspension periods"
  ON billing_suspension_periods
  FOR INSERT
  WITH CHECK (
    school_id = (SELECT school_id FROM user_profiles WHERE id = auth.uid())
    AND (SELECT role FROM user_profiles WHERE id = auth.uid()) IN ('admin', 'superadmin')
  );

CREATE POLICY "Admins can update suspension periods"
  ON billing_suspension_periods
  FOR UPDATE
  USING (
    school_id = (SELECT school_id FROM user_profiles WHERE id = auth.uid())
    AND (SELECT role FROM user_profiles WHERE id = auth.uid()) IN ('admin', 'superadmin')
  );

-- ============================================================================
-- 2. BILLING AUDIT LOG TABLE
-- ============================================================================
-- Comprehensive audit trail for all billing operations

CREATE TABLE IF NOT EXISTS billing_audit_log (
  -- Primary Key
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Foreign Keys
  school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  user_id UUID NOT NULL REFERENCES user_profiles(id),
  
  -- Action
  action VARCHAR(50) NOT NULL,
  -- Allowed values: 'suspend', 'resume', 'backbill', 'config_change', 
  --                 'switch_processing', 'adjustment', 'manual_correction'
  
  -- Details stored as JSON for flexibility
  -- Example: {"suspension_id": "uuid", "scope": {...}, "affected_students": 45}
  details JSONB,
  
  -- Audit Trail
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  -- Constraint
  CONSTRAINT valid_action CHECK (
    action IN ('suspend', 'resume', 'backbill', 'config_change', 
               'switch_processing', 'adjustment', 'manual_correction')
  )
);

-- Indexes for performance
CREATE INDEX IF NOT EXISTS idx_billing_audit_school_id
  ON billing_audit_log(school_id);

CREATE INDEX IF NOT EXISTS idx_billing_audit_action
  ON billing_audit_log(action);

CREATE INDEX IF NOT EXISTS idx_billing_audit_user_id
  ON billing_audit_log(user_id);

CREATE INDEX IF NOT EXISTS idx_billing_audit_created
  ON billing_audit_log(created_at DESC);

CREATE INDEX IF NOT EXISTS idx_billing_audit_school_created
  ON billing_audit_log(school_id, created_at DESC);

-- RLS Policy: Schools can only see their own audit logs
ALTER TABLE billing_audit_log ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Schools can view own audit logs"
  ON billing_audit_log
  FOR SELECT
  USING (
    school_id = (SELECT school_id FROM user_profiles WHERE id = auth.uid())
  );

CREATE POLICY "Audit logs are append-only (no update/delete)"
  ON billing_audit_log
  FOR INSERT
  WITH CHECK (
    school_id = (SELECT school_id FROM user_profiles WHERE id = auth.uid())
  );

-- ============================================================================
-- 3. SCHOOLS TABLE ENHANCEMENTS
-- ============================================================================
-- Add billing suspension tracking columns to existing schools table

ALTER TABLE schools
  ADD COLUMN IF NOT EXISTS billing_suspended BOOLEAN DEFAULT false,
  ADD COLUMN IF NOT EXISTS last_billing_resume_date TIMESTAMPTZ;

-- Index for quick lookup of suspended schools
CREATE INDEX IF NOT EXISTS idx_schools_billing_suspended
  ON schools(billing_suspended)
  WHERE billing_suspended = true;

-- ============================================================================
-- 4. BILL EXTENSIONS TABLE (Optional - for future backbilling)
-- ============================================================================
-- Tracks backbilling and extended billing periods

CREATE TABLE IF NOT EXISTS billing_extensions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  
  -- Foreign Keys
  school_id UUID NOT NULL REFERENCES schools(id) ON DELETE CASCADE,
  student_id UUID NOT NULL REFERENCES students(id) ON DELETE CASCADE,
  suspension_period_id UUID NOT NULL REFERENCES billing_suspension_periods(id),
  
  -- Extension Details
  original_due_date TIMESTAMPTZ NOT NULL,
  extended_due_date TIMESTAMPTZ NOT NULL,
  reason TEXT,
  
  -- Audit
  created_by UUID NOT NULL REFERENCES user_profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  
  CONSTRAINT valid_extension CHECK (
    extended_due_date > original_due_date
  )
);

-- Indexes
CREATE INDEX IF NOT EXISTS idx_billing_extensions_school
  ON billing_extensions(school_id);

CREATE INDEX IF NOT EXISTS idx_billing_extensions_student
  ON billing_extensions(school_id, student_id);

CREATE INDEX IF NOT EXISTS idx_billing_extensions_suspension
  ON billing_extensions(suspension_period_id);

-- RLS Policy
ALTER TABLE billing_extensions ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Schools can view own extensions"
  ON billing_extensions
  FOR SELECT
  USING (
    school_id = (SELECT school_id FROM user_profiles WHERE id = auth.uid())
  );

-- ============================================================================
-- 5. CREATE HELPER FUNCTION: Check if billing is suspended
-- ============================================================================

CREATE OR REPLACE FUNCTION is_billing_suspended(
  p_school_id UUID,
  p_check_date TIMESTAMPTZ DEFAULT NOW()
)
RETURNS BOOLEAN AS $$
BEGIN
  RETURN EXISTS (
    SELECT 1
    FROM billing_suspension_periods
    WHERE school_id = p_school_id
      AND status = 'active'
      AND start_date <= p_check_date
      AND (end_date IS NULL OR end_date > p_check_date)
  );
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================================================
-- 6. CREATE HELPER FUNCTION: Get active suspension periods
-- ============================================================================

CREATE OR REPLACE FUNCTION get_active_suspensions(
  p_school_id UUID,
  p_check_date TIMESTAMPTZ DEFAULT NOW()
)
RETURNS TABLE (
  suspension_id UUID,
  start_date TIMESTAMPTZ,
  end_date TIMESTAMPTZ,
  reason TEXT,
  scope JSONB
) AS $$
BEGIN
  RETURN QUERY
  SELECT 
    id,
    start_date,
    end_date,
    reason,
    scope
  FROM billing_suspension_periods
  WHERE school_id = p_school_id
    AND status = 'active'
    AND start_date <= p_check_date
    AND (end_date IS NULL OR end_date > p_check_date)
  ORDER BY start_date DESC;
END;
$$ LANGUAGE plpgsql STABLE;

-- ============================================================================
-- 7. CREATE TRIGGER: Update billing_suspended flag automatically
-- ============================================================================

CREATE OR REPLACE FUNCTION update_school_billing_suspended()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE schools
  SET billing_suspended = is_billing_suspended(NEW.school_id)
  WHERE id = NEW.school_id;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_billing_suspended
AFTER INSERT OR UPDATE OR DELETE ON billing_suspension_periods
FOR EACH ROW
EXECUTE FUNCTION update_school_billing_suspended();

-- ============================================================================
-- 8. INITIAL DATA VERIFICATION
-- ============================================================================

-- Verify all schools have the new columns
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.columns
    WHERE table_name = 'schools'
      AND column_name = 'billing_suspended'
  ) THEN
    RAISE EXCEPTION 'Column billing_suspended not found on schools table';
  END IF;
  
  IF NOT EXISTS (
    SELECT 1
    FROM information_schema.tables
    WHERE table_name = 'billing_suspension_periods'
  ) THEN
    RAISE EXCEPTION 'Table billing_suspension_periods not created';
  END IF;
  
  RAISE NOTICE 'Billing suspension schema created successfully';
END $$;

-- ============================================================================
-- END TRANSACTION
-- ============================================================================

COMMIT;

-- ============================================================================
-- VERIFICATION QUERIES (Run these to verify installation)
-- ============================================================================

-- Verify tables exist
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
  AND table_name IN ('billing_suspension_periods', 'billing_audit_log', 'billing_extensions');

-- Verify columns on schools table
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'schools'
  AND column_name IN ('billing_suspended', 'last_billing_resume_date');

-- Verify indexes exist
SELECT indexname 
FROM pg_indexes
WHERE tablename IN ('billing_suspension_periods', 'billing_audit_log', 'billing_extensions')
ORDER BY tablename, indexname;

-- Verify functions exist
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
  AND routine_name IN ('is_billing_suspended', 'get_active_suspensions', 'update_school_billing_suspended');
