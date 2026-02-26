# API Reference

## Overview
This document describes the Supabase API endpoints and database functions for the ResQ system.

---

## Database Functions

### 1. update_student_status()

Updates a student's status and creates an audit log entry.

**Parameters:**
```sql
p_student_id TEXT       -- Student ID
p_status TEXT          -- Status: SAFE, NEEDS_ASSISTANCE, CRITICAL, EVACUATED
p_source TEXT          -- Source: APP or SMS
p_lat DECIMAL          -- Optional: New latitude
p_lng DECIMAL          -- Optional: New longitude
p_validation_flag BOOLEAN  -- Default TRUE, FALSE for invalid SMS
```

**Usage (from mobile app):**
```javascript
const { error } = await supabase.rpc('update_student_status', {
  p_student_id: userId,
  p_status: 'SAFE',
  p_source: 'APP',
  p_lat: 14.5995,
  p_lng: 120.9842,
  p_validation_flag: true
});
```

---

### 2. get_dashboard_metrics()

Returns real-time student counts by status.

**Returns:**
```typescript
{
  total_students: number;
  safe_count: number;
  needs_assistance_count: number;
  critical_count: number;
  evacuated_count: number;
  unknown_count: number;
  is_disaster_active: boolean;
}
```

**Usage (from admin dashboard):**
```javascript
const { data, error } = await supabase.rpc('get_dashboard_metrics');
```

---

### 3. auto_triage_students()

Marks students as UNKNOWN if inactive for 6+ hours. Called by cron job.

**Returns:**
```typescript
{ affected_count: number }
```

**Usage (cron/service role only):**
```javascript
const { data, error } = await supabase.rpc('auto_triage_students');
console.log(`Marked ${data[0].affected_count} students as UNKNOWN`);
```

---

### 4. toggle_disaster_mode()

Activates or deactivates disaster mode.

**Parameters:**
```sql
p_activate BOOLEAN  -- TRUE to activate, FALSE to deactivate
```

**Usage (admin dashboard):**
```javascript
const { error } = await supabase.rpc('toggle_disaster_mode', {
  p_activate: true
});
```

---

### 5. is_location_valid()

Validates if location update exceeds 100m threshold.

**Parameters:**
```sql
p_old_lat DECIMAL
p_old_lng DECIMAL
p_new_lat DECIMAL
p_new_lng DECIMAL
p_threshold_meters INTEGER -- Default 100
```

**Returns:** `BOOLEAN`

**Usage:**
```javascript
const { data, error } = await supabase.rpc('is_location_valid', {
  p_old_lat: 14.5995,
  p_old_lng: 120.9842,
  p_new_lat: 14.6005,
  p_new_lng: 120.9852,
  p_threshold_meters: 100
});
```

---

## Direct Table Queries

### Students Table

**Get own student record:**
```javascript
const { data, error } = await supabase
  .from('students')
  .select('*')
  .eq('student_id', userId)
  .single();
```

**Admin: Get all students:**
```javascript
const { data, error } = await supabase
  .from('students')
  .select('*')
  .order('last_update_timestamp', { ascending: false });
```

**Filter by status:**
```javascript
const { data, error } = await supabase
  .from('students')
  .select('*')
  .eq('last_status', 'CRITICAL');
```

---

### Status Logs Table

**Get student's own history:**
```javascript
const { data, error } = await supabase
  .from('status_logs')
  .select('*')
  .eq('student_id', userId)
  .order('timestamp', { ascending: false })
  .limit(20);
```

**Admin: Get all logs with validation filter:**
```javascript
const { data, error } = await supabase
  .from('status_logs')
  .select('*, students(name)')
  .eq('validation_flag', true)
  .order('timestamp', { ascending: false });
```

---

### Evacuation Centers Table

**Get all centers:**
```javascript
const { data, error } = await supabase
  .from('evacuation_centers')
  .select('*');
```

**Admin: Add new center:**
```javascript
const { error } = await supabase
  .from('evacuation_centers')
  .insert({
    center_name: 'City Hall Evacuation Center',
    latitude: 14.5995,
    longitude: 120.9842
  });
```

---

### System Settings Table

**Get disaster mode status:**
```javascript
const { data, error } = await supabase
  .from('system_settings')
  .select('is_disaster_mode_active, mode_activated_at')
  .eq('id', 1)
  .single();
```

---

## Real-time Subscriptions

### Subscribe to disaster mode changes:
```javascript
const subscription = supabase
  .channel('system-settings')
  .on('postgres_changes', {
    event: 'UPDATE',
    schema: 'public',
    table: 'system_settings'
  }, (payload) => {
    console.log('Disaster mode changed:', payload.new);
  })
  .subscribe();
```

### Subscribe to student status updates (admin):
```javascript
const subscription = supabase
  .channel('students-updates')
  .on('postgres_changes', {
    event: 'UPDATE',
    schema: 'public',
    table: 'students'
  }, (payload) => {
    console.log('Student updated:', payload.new);
  })
  .subscribe();
```

### Subscribe to new status logs:
```javascript
const subscription = supabase
  .channel('status-logs')
  .on('postgres_changes', {
    event: 'INSERT',
    schema: 'public',
    table: 'status_logs',
    filter: 'validation_flag=eq.true'
  }, (payload) => {
    console.log('New status log:', payload.new);
  })
  .subscribe();
```

---

## SMS Gateway Integration

### Webhook Endpoint (Edge Function)

**POST** `/functions/v1/sms-webhook`

**Request Body:**
```json
{
  "from": "+639123456789",
  "message": "VSU 2021-00001 SAFE"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Status updated successfully",
  "parsed": {
    "student_id": "2021-00001",
    "status": "SAFE"
  }
}
```

**Error Response:**
```json
{
  "success": false,
  "error": "Invalid SMS format",
  "message": "Expected format: VSU <StudentID> <STATUS>"
}
```

---

## Error Handling

All API calls should handle these common errors:

- **403 Forbidden:** RLS policy denied access
- **404 Not Found:** Record doesn't exist
- **422 Unprocessable:** Invalid enum value or constraint violation
- **500 Internal Server Error:** Database error

**Example:**
```javascript
const { data, error } = await supabase.rpc('update_student_status', params);

if (error) {
  if (error.code === '403') {
    console.error('Access denied');
  } else if (error.code === '23505') {
    console.error('Duplicate entry');
  } else {
    console.error('Database error:', error.message);
  }
}
```
