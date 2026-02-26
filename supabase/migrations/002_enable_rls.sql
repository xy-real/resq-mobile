-- ResQ Disaster Response System - Row Level Security
-- Migration 002: Enable RLS and Create Policies

-- ============================================
-- ENABLE RLS ON ALL TABLES
-- ============================================
ALTER TABLE students ENABLE ROW LEVEL SECURITY;
ALTER TABLE status_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE evacuation_centers ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_settings ENABLE ROW LEVEL SECURITY;
ALTER TABLE admins ENABLE ROW LEVEL SECURITY;

-- ============================================
-- STUDENTS TABLE POLICIES
-- ============================================

-- Students can view their own record
CREATE POLICY students_select_own ON students
    FOR SELECT
    TO authenticated
    USING (auth.uid()::text = student_id);

-- Students can update their own status and location
CREATE POLICY students_update_own_status ON students
    FOR UPDATE
    TO authenticated
    USING (auth.uid()::text = student_id)
    WITH CHECK (auth.uid()::text = student_id);

-- Admins can view all students
CREATE POLICY admins_select_all_students ON students
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM admins 
            WHERE email = auth.jwt()->>'email'
        )
    );

-- Super admins can update any student (manual overrides)
CREATE POLICY admins_update_all_students ON students
    FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM admins 
            WHERE email = auth.jwt()->>'email' 
            AND role = 'SUPER_ADMIN'
        )
    );

-- ============================================
-- STATUS_LOGS TABLE POLICIES
-- ============================================

-- Students can insert their own logs
CREATE POLICY students_insert_own_logs ON status_logs
    FOR INSERT
    TO authenticated
    WITH CHECK (auth.uid()::text = student_id);

-- Students can view their own logs
CREATE POLICY students_select_own_logs ON status_logs
    FOR SELECT
    TO authenticated
    USING (auth.uid()::text = student_id);

-- Admins can view all logs
CREATE POLICY admins_select_all_logs ON status_logs
    FOR SELECT
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM admins 
            WHERE email = auth.jwt()->>'email'
        )
    );

-- Super admins can insert logs (for SMS gateway and manual overrides)
CREATE POLICY admins_insert_logs ON status_logs
    FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM admins 
            WHERE email = auth.jwt()->>'email' 
            AND role = 'SUPER_ADMIN'
        )
    );

-- ============================================
-- EVACUATION_CENTERS TABLE POLICIES
-- ============================================

-- All authenticated users can view evacuation centers
CREATE POLICY public_select_centers ON evacuation_centers
    FOR SELECT
    TO authenticated
    USING (true);

-- Only super admins can manage evacuation centers
CREATE POLICY admins_insert_centers ON evacuation_centers
    FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM admins 
            WHERE email = auth.jwt()->>'email' 
            AND role = 'SUPER_ADMIN'
        )
    );

CREATE POLICY admins_update_centers ON evacuation_centers
    FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM admins 
            WHERE email = auth.jwt()->>'email' 
            AND role = 'SUPER_ADMIN'
        )
    );

CREATE POLICY admins_delete_centers ON evacuation_centers
    FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM admins 
            WHERE email = auth.jwt()->>'email' 
            AND role = 'SUPER_ADMIN'
        )
    );

-- ============================================
-- SYSTEM_SETTINGS TABLE POLICIES
-- ============================================

-- All authenticated users can view system settings (need to know if disaster mode is active)
CREATE POLICY public_select_settings ON system_settings
    FOR SELECT
    TO authenticated
    USING (true);

-- Only super admins can update system settings
CREATE POLICY admins_update_settings ON system_settings
    FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM admins 
            WHERE email = auth.jwt()->>'email' 
            AND role = 'SUPER_ADMIN'
        )
    );

-- ============================================
-- ADMINS TABLE POLICIES
-- ============================================

-- Admins can view their own record
CREATE POLICY admins_select_own ON admins
    FOR SELECT
    TO authenticated
    USING (email = auth.jwt()->>'email');

-- Super admins can manage other admins
CREATE POLICY super_admins_insert_admins ON admins
    FOR INSERT
    TO authenticated
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM admins 
            WHERE email = auth.jwt()->>'email' 
            AND role = 'SUPER_ADMIN'
        )
    );

CREATE POLICY super_admins_update_admins ON admins
    FOR UPDATE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM admins 
            WHERE email = auth.jwt()->>'email' 
            AND role = 'SUPER_ADMIN'
        )
    );

CREATE POLICY super_admins_delete_admins ON admins
    FOR DELETE
    TO authenticated
    USING (
        EXISTS (
            SELECT 1 FROM admins 
            WHERE email = auth.jwt()->>'email' 
            AND role = 'SUPER_ADMIN'
        )
    );
