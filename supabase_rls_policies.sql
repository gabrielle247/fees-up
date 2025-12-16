-- ============================================================================
-- SUPABASE ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================
-- This file defines RLS policies for multi-tenant data isolation
-- Enforces school-level data access control based on user roles

-- ============================================================================
-- 0. HELPER FUNCTION - GET USER'S SCHOOL_ID (BYPASSES RLS)
-- ============================================================================

-- Create a security definer function to get the current user's school_id
-- This bypasses RLS recursion by relying on the JWT claim instead of querying tables
CREATE OR REPLACE FUNCTION public.get_current_user_school_id()
RETURNS uuid
LANGUAGE sql
SECURITY DEFINER
STABLE
AS $$
  SELECT (auth.jwt() ->> 'school_id')::uuid;
$$;

-- ============================================================================
-- 1. USER_PROFILES TABLE - SIMPLE POLICY (NO RECURSION)
-- ============================================================================

-- Allow users to read their own profile
DROP POLICY IF EXISTS "Users can read own profile" ON public.user_profiles;
CREATE POLICY "Users can read own profile"
ON public.user_profiles FOR SELECT
USING (auth.uid() = id);

-- Allow users to update their own profile
DROP POLICY IF EXISTS "Users can update own profile" ON public.user_profiles;
CREATE POLICY "Users can update own profile"
ON public.user_profiles FOR UPDATE
USING (auth.uid() = id)
WITH CHECK (auth.uid() = id);

-- ============================================================================
-- 2. SCHOOLS TABLE
-- ============================================================================

-- Users can read their school
DROP POLICY IF EXISTS "Users can read their school" ON public.schools;
CREATE POLICY "Users can read their school"
ON public.schools FOR SELECT
USING (id = public.get_current_user_school_id());

-- ============================================================================
-- 3. STUDENTS TABLE
-- ============================================================================

-- Users can read students from their school
DROP POLICY IF EXISTS "Users can read students in their school" ON public.students;
CREATE POLICY "Users can read students in their school"
ON public.students FOR SELECT
USING (school_id = public.get_current_user_school_id());

-- School admin can insert students
DROP POLICY IF EXISTS "School admins can create students" ON public.students;
CREATE POLICY "School admins can create students"
ON public.students FOR INSERT
WITH CHECK (school_id = public.get_current_user_school_id());

-- School admin can update students in their school
DROP POLICY IF EXISTS "School admins can update students" ON public.students;
CREATE POLICY "School admins can update students"
ON public.students FOR UPDATE
USING (school_id = public.get_current_user_school_id())
WITH CHECK (school_id = public.get_current_user_school_id());

-- ============================================================================
-- 4. CLASSES TABLE
-- ============================================================================

DROP POLICY IF EXISTS "Users can read classes in their school" ON public.classes;
CREATE POLICY "Users can read classes in their school"
ON public.classes FOR SELECT
USING (school_id = public.get_current_user_school_id());

DROP POLICY IF EXISTS "School admins can manage classes" ON public.classes;
CREATE POLICY "School admins can manage classes"
ON public.classes FOR INSERT
WITH CHECK (school_id = public.get_current_user_school_id());

DROP POLICY IF EXISTS "School admins can update classes" ON public.classes;
CREATE POLICY "School admins can update classes"
ON public.classes FOR UPDATE
USING (school_id = public.get_current_user_school_id())
WITH CHECK (school_id = public.get_current_user_school_id());

-- ============================================================================
-- 5. TEACHER_ACCESS_TOKENS TABLE
-- ============================================================================

DROP POLICY IF EXISTS "Users can read their access tokens" ON public.teacher_access_tokens;
CREATE POLICY "Users can read their access tokens"
ON public.teacher_access_tokens FOR SELECT
USING (school_id = public.get_current_user_school_id());

DROP POLICY IF EXISTS "School admins can create access tokens" ON public.teacher_access_tokens;
CREATE POLICY "School admins can create access tokens"
ON public.teacher_access_tokens FOR INSERT
WITH CHECK (school_id = public.get_current_user_school_id());

DROP POLICY IF EXISTS "Token owners can mark as used" ON public.teacher_access_tokens;
CREATE POLICY "Token owners can mark as used"
ON public.teacher_access_tokens FOR UPDATE
USING (teacher_id = auth.uid())
WITH CHECK (teacher_id = auth.uid());

-- ============================================================================
-- 6. ATTENDANCE_SESSIONS TABLE
-- ============================================================================

DROP POLICY IF EXISTS "Users can read attendance sessions in their school" ON public.attendance_sessions;
CREATE POLICY "Users can read attendance sessions in their school"
ON public.attendance_sessions FOR SELECT
USING (school_id = public.get_current_user_school_id());

DROP POLICY IF EXISTS "Student admins can create attendance sessions" ON public.attendance_sessions;
CREATE POLICY "Student admins can create attendance sessions"
ON public.attendance_sessions FOR INSERT
WITH CHECK (school_id = public.get_current_user_school_id());

DROP POLICY IF EXISTS "Teachers can confirm attendance sessions" ON public.attendance_sessions;
CREATE POLICY "Teachers can confirm attendance sessions"
ON public.attendance_sessions FOR UPDATE
USING (teacher_id = auth.uid())
WITH CHECK (teacher_id = auth.uid());

-- ============================================================================
-- 7. ATTENDANCE TABLE
-- ============================================================================

DROP POLICY IF EXISTS "Users can read attendance in their school" ON public.attendance;
CREATE POLICY "Users can read attendance in their school"
ON public.attendance FOR SELECT
USING (school_id = public.get_current_user_school_id());

DROP POLICY IF EXISTS "Users can create attendance in their school" ON public.attendance;
CREATE POLICY "Users can create attendance in their school"
ON public.attendance FOR INSERT
WITH CHECK (school_id = public.get_current_user_school_id());

-- ============================================================================
-- 8. BILLS TABLE
-- ============================================================================

DROP POLICY IF EXISTS "Users can read bills in their school" ON public.bills;
CREATE POLICY "Users can read bills in their school"
ON public.bills FOR SELECT
USING (school_id = public.get_current_user_school_id());

DROP POLICY IF EXISTS "School admins can create bills" ON public.bills;
CREATE POLICY "School admins can create bills"
ON public.bills FOR INSERT
WITH CHECK (school_id = public.get_current_user_school_id());

-- ============================================================================
-- 9. PAYMENTS TABLE
-- ============================================================================

DROP POLICY IF EXISTS "Users can read payments in their school" ON public.payments;
CREATE POLICY "Users can read payments in their school"
ON public.payments FOR SELECT
USING (school_id = public.get_current_user_school_id());

DROP POLICY IF EXISTS "Users can create payments in their school" ON public.payments;
CREATE POLICY "Users can create payments in their school"
ON public.payments FOR INSERT
WITH CHECK (school_id = public.get_current_user_school_id());

-- ============================================================================
-- 10. ENROLLMENTS TABLE
-- ============================================================================

DROP POLICY IF EXISTS "Users can read enrollments in their school" ON public.enrollments;
CREATE POLICY "Users can read enrollments in their school"
ON public.enrollments FOR SELECT
USING (school_id = public.get_current_user_school_id());

DROP POLICY IF EXISTS "School admins can manage enrollments" ON public.enrollments;
CREATE POLICY "School admins can manage enrollments"
ON public.enrollments FOR INSERT
WITH CHECK (school_id = public.get_current_user_school_id());

-- ============================================================================
-- 11. CAMPAIGNS TABLE
-- ============================================================================

DROP POLICY IF EXISTS "Users can read campaigns in their school" ON public.campaigns;
CREATE POLICY "Users can read campaigns in their school"
ON public.campaigns FOR SELECT
USING (school_id = public.get_current_user_school_id());

DROP POLICY IF EXISTS "School admins can create campaigns" ON public.campaigns;
CREATE POLICY "School admins can create campaigns"
ON public.campaigns FOR INSERT
WITH CHECK (school_id = public.get_current_user_school_id());

DROP POLICY IF EXISTS "School admins can update campaigns" ON public.campaigns;
CREATE POLICY "School admins can update campaigns"
ON public.campaigns FOR UPDATE
USING (school_id = public.get_current_user_school_id())
WITH CHECK (school_id = public.get_current_user_school_id());
