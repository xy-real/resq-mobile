-- ResQ Disaster Response System - Database Functions
-- Migration 004: Create Helper Functions

-- ============================================
-- FUNCTION: Update Student Status
-- ============================================
-- This function updates a student's status and creates a log entry
-- Used by mobile app and SMS gateway

CREATE OR REPLACE FUNCTION update_student_status(
    p_student_id TEXT,
    p_status TEXT,
    p_source TEXT,
    p_lat DECIMAL DEFAULT NULL,
    p_lng DECIMAL DEFAULT NULL,
    p_validation_flag BOOLEAN DEFAULT TRUE
)
RETURNS VOID AS $$
BEGIN
    -- Insert into status logs
    INSERT INTO status_logs (student_id, status, source, validation_flag, timestamp)
    VALUES (p_student_id, p_status, p_source, p_validation_flag, NOW());

    -- Update student record (only if validation flag is true)
    IF p_validation_flag THEN
        UPDATE students
        SET 
            last_status = p_status,
            last_update_timestamp = NOW(),
            last_update_source = p_source,
            last_known_lat = COALESCE(p_lat, last_known_lat),
            last_known_lng = COALESCE(p_lng, last_known_lng)
        WHERE student_id = p_student_id;
    END IF;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION update_student_status IS 'Updates student status and creates audit log entry';

-- ============================================
-- FUNCTION: Auto-Triage Students
-- ============================================
-- Marks students as UNKNOWN if they haven't updated in 6 hours
-- Called by cron job when disaster mode is active

CREATE OR REPLACE FUNCTION auto_triage_students()
RETURNS TABLE(affected_count INTEGER) AS $$
DECLARE
    v_mode_active BOOLEAN;
    v_mode_activated_at TIMESTAMPTZ;
    v_cutoff_time TIMESTAMPTZ;
    v_count INTEGER := 0;
BEGIN
    -- Get disaster mode status
    SELECT is_disaster_mode_active, mode_activated_at
    INTO v_mode_active, v_mode_activated_at
    FROM system_settings
    WHERE id = 1;

    -- Only run if disaster mode is active
    IF NOT v_mode_active THEN
        RETURN QUERY SELECT 0;
        RETURN;
    END IF;

    -- Calculate cutoff time (6 hours ago)
    v_cutoff_time := NOW() - INTERVAL '6 hours';

    -- Update students who haven't updated since cutoff
    WITH updated_students AS (
        UPDATE students
        SET 
            last_status = 'UNKNOWN',
            last_update_timestamp = NOW(),
            last_update_source = 'APP'
        WHERE 
            last_status != 'UNKNOWN'
            AND (
                last_update_timestamp < v_cutoff_time
                OR last_update_timestamp IS NULL
            )
        RETURNING student_id
    )
    SELECT COUNT(*)::INTEGER INTO v_count FROM updated_students;

    -- Log the auto-triage action for each affected student
    INSERT INTO status_logs (student_id, status, source, timestamp)
    SELECT student_id, 'UNKNOWN', 'APP', NOW()
    FROM students
    WHERE last_status = 'UNKNOWN' 
    AND last_update_timestamp >= NOW() - INTERVAL '1 minute';

    RETURN QUERY SELECT v_count;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION auto_triage_students IS 'Marks inactive students as UNKNOWN after 6 hours';

-- ============================================
-- FUNCTION: Get Dashboard Metrics
-- ============================================
-- Returns real-time counts of students by status

CREATE OR REPLACE FUNCTION get_dashboard_metrics()
RETURNS TABLE(
    total_students BIGINT,
    safe_count BIGINT,
    needs_assistance_count BIGINT,
    critical_count BIGINT,
    evacuated_count BIGINT,
    unknown_count BIGINT,
    is_disaster_active BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*)::BIGINT as total_students,
        COUNT(*) FILTER (WHERE last_status = 'SAFE')::BIGINT as safe_count,
        COUNT(*) FILTER (WHERE last_status = 'NEEDS_ASSISTANCE')::BIGINT as needs_assistance_count,
        COUNT(*) FILTER (WHERE last_status = 'CRITICAL')::BIGINT as critical_count,
        COUNT(*) FILTER (WHERE last_status = 'EVACUATED')::BIGINT as evacuated_count,
        COUNT(*) FILTER (WHERE last_status = 'UNKNOWN')::BIGINT as unknown_count,
        (SELECT is_disaster_mode_active FROM system_settings WHERE id = 1) as is_disaster_active
    FROM students;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION get_dashboard_metrics IS 'Returns student counts by status for admin dashboard';

-- ============================================
-- FUNCTION: Toggle Disaster Mode
-- ============================================
-- Activates or deactivates disaster mode

CREATE OR REPLACE FUNCTION toggle_disaster_mode(p_activate BOOLEAN)
RETURNS VOID AS $$
BEGIN
    UPDATE system_settings
    SET 
        is_disaster_mode_active = p_activate,
        mode_activated_at = CASE 
            WHEN p_activate THEN NOW() 
            ELSE mode_activated_at 
        END
    WHERE id = 1;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

COMMENT ON FUNCTION toggle_disaster_mode IS 'Activates or deactivates disaster mode';

-- ============================================
-- FUNCTION: Validate Location Update
-- ============================================
-- Checks if location update is valid (movement threshold)

CREATE OR REPLACE FUNCTION is_location_valid(
    p_old_lat DECIMAL,
    p_old_lng DECIMAL,
    p_new_lat DECIMAL,
    p_new_lng DECIMAL,
    p_threshold_meters INTEGER DEFAULT 100
)
RETURNS BOOLEAN AS $$
DECLARE
    v_distance_meters DECIMAL;
BEGIN
    -- If no previous location, accept new location
    IF p_old_lat IS NULL OR p_old_lng IS NULL THEN
        RETURN TRUE;
    END IF;

    -- Calculate distance using Haversine formula (approximate)
    -- For more accuracy, use PostGIS ST_Distance
    v_distance_meters := 
        6371000 * acos(
            cos(radians(p_old_lat)) * 
            cos(radians(p_new_lat)) * 
            cos(radians(p_new_lng) - radians(p_old_lng)) + 
            sin(radians(p_old_lat)) * 
            sin(radians(p_new_lat))
        );

    -- Return true if movement exceeds threshold
    RETURN v_distance_meters >= p_threshold_meters;
END;
$$ LANGUAGE plpgsql IMMUTABLE;

COMMENT ON FUNCTION is_location_valid IS 'Validates location update against 100m movement threshold';

-- ============================================
-- GRANT PERMISSIONS
-- ============================================
-- Allow authenticated users to call these functions

GRANT EXECUTE ON FUNCTION update_student_status TO authenticated;
GRANT EXECUTE ON FUNCTION get_dashboard_metrics TO authenticated;
GRANT EXECUTE ON FUNCTION is_location_valid TO authenticated;

-- Only service role can call auto_triage (via cron)
GRANT EXECUTE ON FUNCTION auto_triage_students TO service_role;
GRANT EXECUTE ON FUNCTION toggle_disaster_mode TO authenticated;
