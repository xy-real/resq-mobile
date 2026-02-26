-- ResQ Disaster Response System - Database Indexes
-- Migration 003: Create Indexes for Performance

-- ============================================
-- STATUS_LOGS INDEXES
-- ============================================

-- Index for filtering logs by student
CREATE INDEX IF NOT EXISTS idx_status_logs_student_id 
ON status_logs(student_id);

-- Index for sorting logs by timestamp (most recent first)
CREATE INDEX IF NOT EXISTS idx_status_logs_timestamp 
ON status_logs(timestamp DESC);

-- Composite index for filtering valid logs by student and time
CREATE INDEX IF NOT EXISTS idx_status_logs_student_valid 
ON status_logs(student_id, timestamp DESC) 
WHERE validation_flag = TRUE;

-- Index for filtering by source
CREATE INDEX IF NOT EXISTS idx_status_logs_source 
ON status_logs(source);

-- ============================================
-- STUDENTS INDEXES
-- ============================================

-- Index for filtering students by status (for dashboard metrics)
CREATE INDEX IF NOT EXISTS idx_students_last_status 
ON students(last_status);

-- Index for sorting students by last update time
CREATE INDEX IF NOT EXISTS idx_students_last_update 
ON students(last_update_timestamp DESC);

-- Spatial index for location queries (if using PostGIS in future)
-- CREATE INDEX IF NOT EXISTS idx_students_location 
-- ON students USING GIST (ll_to_earth(last_known_lat, last_known_lng));

-- ============================================
-- EVACUATION_CENTERS INDEXES
-- ============================================

-- Spatial index for evacuation centers (if using PostGIS in future)
-- CREATE INDEX IF NOT EXISTS idx_evacuation_centers_location 
-- ON evacuation_centers USING GIST (ll_to_earth(latitude, longitude));

-- ============================================
-- ADMINS INDEXES
-- ============================================

-- Index for admin email lookups (for RLS policies)
CREATE INDEX IF NOT EXISTS idx_admins_email 
ON admins(email);

-- Index for filtering by role
CREATE INDEX IF NOT EXISTS idx_admins_role 
ON admins(role);

-- ============================================
-- PERFORMANCE NOTES
-- ============================================
-- These indexes optimize:
-- 1. Dashboard queries: Counting students by status
-- 2. Real-time updates: Filtering recent status changes
-- 3. Student lookup: Finding records by student_id
-- 4. Admin authentication: Email-based RLS policy checks
-- 5. Auto-triage: Finding students with old last_update_timestamp
