-- ResQ Disaster Response System - Database Schema
-- Migration 001: Create Tables

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ============================================
-- 1. STUDENTS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS students (
    student_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    contact_number TEXT,
    home_lat DECIMAL(10,8),
    home_lng DECIMAL(11,8),
    registered_home_risk_label TEXT,
    last_known_lat DECIMAL(10,8),
    last_known_lng DECIMAL(11,8),
    last_status TEXT DEFAULT 'UNKNOWN' CHECK (last_status IN ('SAFE', 'NEEDS_ASSISTANCE', 'CRITICAL', 'EVACUATED', 'UNKNOWN')),
    last_update_timestamp TIMESTAMPTZ,
    last_update_source TEXT CHECK (last_update_source IN ('APP', 'SMS'))
);

COMMENT ON TABLE students IS 'Primary user directory containing all registered students';
COMMENT ON COLUMN students.student_id IS 'Unique student identifier (Primary Key)';
COMMENT ON COLUMN students.last_status IS 'Current status: SAFE, NEEDS_ASSISTANCE, CRITICAL, EVACUATED, UNKNOWN';
COMMENT ON COLUMN students.last_update_source IS 'Source of last update: APP or SMS';

-- ============================================
-- 2. STATUS_LOGS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS status_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    student_id TEXT NOT NULL REFERENCES students(student_id) ON DELETE CASCADE,
    status TEXT NOT NULL CHECK (status IN ('SAFE', 'NEEDS_ASSISTANCE', 'CRITICAL', 'EVACUATED', 'UNKNOWN')),
    timestamp TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    source TEXT NOT NULL CHECK (source IN ('APP', 'SMS')),
    validation_flag BOOLEAN DEFAULT TRUE
);

COMMENT ON TABLE status_logs IS 'Append-only ledger of all status updates from students';
COMMENT ON COLUMN status_logs.validation_flag IS 'FALSE for malformed SMS messages';

-- ============================================
-- 3. EVACUATION_CENTERS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS evacuation_centers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    center_name TEXT NOT NULL,
    latitude DECIMAL(10,8) NOT NULL,
    longitude DECIMAL(11,8) NOT NULL
);

COMMENT ON TABLE evacuation_centers IS 'Locations of designated evacuation sites';

-- ============================================
-- 4. SYSTEM_SETTINGS TABLE (Singleton)
-- ============================================
CREATE TABLE IF NOT EXISTS system_settings (
    id INTEGER PRIMARY KEY DEFAULT 1 CHECK (id = 1),
    is_disaster_mode_active BOOLEAN DEFAULT FALSE,
    mode_activated_at TIMESTAMPTZ
);

COMMENT ON TABLE system_settings IS 'Global configuration for disaster mode (single-row table)';

-- Insert default row
INSERT INTO system_settings (id, is_disaster_mode_active, mode_activated_at)
VALUES (1, FALSE, NULL)
ON CONFLICT (id) DO NOTHING;

-- ============================================
-- 5. ADMINS TABLE
-- ============================================
CREATE TABLE IF NOT EXISTS admins (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email TEXT UNIQUE NOT NULL,
    role TEXT NOT NULL CHECK (role IN ('SUPER_ADMIN', 'VIEWER'))
);

COMMENT ON TABLE admins IS 'Authorized admin users for dashboard access';
COMMENT ON COLUMN admins.role IS 'Admin role: SUPER_ADMIN or VIEWER';
