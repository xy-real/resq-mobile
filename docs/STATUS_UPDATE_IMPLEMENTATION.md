# Status Update Backend Implementation

## Overview
This document explains the backend implementation for status updates in ResQ Mobile. The system allows users to update their status (Safe, Needs Assistance, Critical, Evacuated) and send that data to the Supabase backend.

## Architecture

### Flow Diagram
```
User selects status in HomeScreen
    ↓
HomeScreen._updateStatus() called
    ↓
AppStateNotifier.updateStatus(status)
    ↓
StatusService.updateStatus()
    ├── Gets student_id from auth user
    ├── Updates STUDENTS table
    ├── Inserts into STATUS_LOGS table
    └── Returns StatusUpdate object
    ↓
Local state updated
    ↓
UI refreshed with new status
```

## Components

### 1. Status Model (`lib/models/status.dart`)
**Purpose:** Defines data structures for status updates

**Key Classes:**
- `StatusUpdate`: Represents a single status update with:
  - `studentId`: Unique identifier for the student
  - `status`: Current status (SAFE, NEEDS_ASSISTANCE, CRITICAL, EVACUATED, UNKNOWN)
  - `timestamp`: When the status was updated
  - `source`: Where the update came from (APP, SMS)
  - `latitude`/`longitude`: GPS coordinates
  - `accuracy`: Location accuracy in meters
  - `validationFlag`: Whether the update is valid

- `StatusValue` enum: Type-safe status values with display names and parsing

**Methods:**
- `toJson()`: Convert to JSON for database operations
- `fromJson()`: Create from database response
- `StatusValue.fromString()`: Parse string to enum

### 2. StatusService (`lib/services/status_service.dart`)
**Purpose:** Handle all backend database operations for status updates

**Key Methods:**

#### `getStudentId()`
- Retrieves the `student_id` for the currently authenticated user
- Queries the STUDENTS table using the auth user's `user_id`
- Returns: `String?` (student ID or null)

#### `updateStatus()`
```dart
Future<StatusUpdate> updateStatus({
  required String status,
  double? latitude,
  double? longitude,
  double? accuracy,
})
```
**What it does:**
1. Validates user is authenticated
2. Gets the student ID for the current user
3. Updates STUDENTS table with:
   - `last_status`: New status
   - `last_known_lat`/`last_known_lng`: Current location
   - `last_update_timestamp`: Current UTC time
   - `last_update_source`: "APP"
4. Inserts record into STATUS_LOGS for audit trail with:
   - `student_id`: Student's ID
   - `status`: New status
   - `timestamp`: Update time (UTC)
   - `source`: "APP"
   - `validation_flag`: true

**Returns:** `StatusUpdate` object with saved data
**Throws:** Exception if update fails (not authenticated, student not found, database error)

#### `getCurrentStatus()`
- Retrieves latest status for current user
- Returns: `StatusUpdate?` (current status or null)

#### `getStatusHistory()`
- Gets previous status updates (default: last 50)
- Returns: `List<StatusUpdate>` in reverse chronological order

### 3. Updated AppStateNotifier (`lib/providers/app_state_provider.dart`)
**Changes Made:**
- Added import for `StatusService`
- Updated `updateStatus()` method to:
  1. Call `StatusService.updateStatus()` with current location data (if available)
  2. Wait for backend response before updating local state
  3. Update local preferences only after successful backend update
  4. Notify listeners to refresh UI

**Benefits:**
- Backend is now the source of truth
- Local state stays in sync with database
- Location data is automatically included with status updates

## Database Tables Updated

### STUDENTS Table
The following columns are updated when status is sent:
```
- last_status: SAFE | NEEDS_ASSISTANCE | CRITICAL | EVACUATED | UNKNOWN
- last_known_lat: Decimal(10,8) - latitude from device GPS
- last_known_lng: Decimal(11,8) - longitude from device GPS
- last_update_timestamp: TIMESTAMPTZ - when update was sent
- last_update_source: "APP" (vs SMS or other sources)
```

### STATUS_LOGS Table
A new record is inserted for each status update:
```
- id: UUID (auto-generated)
- student_id: The student's ID
- status: The new status value
- timestamp: When the update was made (UTC)
- source: "APP"
- validation_flag: true (valid update)
```

## Security

### Row-Level Security (RLS)
The implementation respects RLS policies:
- Students can update only their own status
- The `auth.uid()` context is used by Supabase RLS policies
- Students can insert into their own STATUS_LOGS entries
- All operations are protected by table-level RLS policies

### Authentication
- Status updates only work for authenticated users
- `StatusService` checks `isAuthenticated` before any operation
- If not authenticated, an exception is thrown with a clear message

## Usage in Frontend

### From HomeScreen
```dart
// In _updateStatus method, when user taps a status button:
await appStateProvider.updateStatus(status);
```

The method automatically:
1. Includes current location (if location permission granted)
2. Handles errors and shows SnackBar messages
3. Updates the UI through the provider

### Finding Student ID
The `StatusService` automatically handles mapping from `auth.uid()` to `student_id`:
```dart
// Service does this internally:
final studentId = await statusService.getStudentId();
// Then uses studentId for database operations
```

## Error Handling

### Possible Errors
1. **Not Authenticated**: "User not authenticated. Cannot update status."
2. **Student Profile Not Found**: "Student profile not found. Please complete your profile first."
3. **Database Errors**: Rethrown with debug prints

### Error Recovery
- HomeScreen catches exceptions and shows SnackBar messages
- Local state is not updated if backend update fails
- User can retry the status update

## Location Integration

### Automatic Location Inclusion
When a status is sent:
1. AppState's `currentLocation` is checked
2. If available, `latitude`, `longitude`, and `accuracy` are included
3. Location is stored in STUDENTS table for future reference
4. Location data helps with mapping and emergency response

### Optional Location
- Location is optional - status can be sent without GPS data
- If location permission is denied, status updates still work

## Testing the Implementation

### To test status updates:
1. Log in to the app
2. Grant location permission (optional but recommended)
3. Tap any status button (Safe, Needs Assistance, Critical, Evacuated)
4. Observe:
   - Status updates in real-time on the screen
   - "Status updated to: X" SnackBar appears
   - Check Supabase dashboard to verify data in STUDENTS and STATUS_LOGS tables

### Expected Behavior
- Status change appears immediately in the app
- Data is persisted in Supabase
- STATUS_LOGS creates an audit trail
- Location is captured if available
- All updates are timestamped in UTC

## Database Validation

In Supabase:
```sql
-- Check latest status for a student:
SELECT student_id, last_status, last_update_timestamp, last_known_lat, last_known_lng 
FROM students 
WHERE student_id = 'YOUR_STUDENT_ID';

-- Check status history:
SELECT * FROM status_logs 
WHERE student_id = 'YOUR_STUDENT_ID'
ORDER BY timestamp DESC;
```

## Future Enhancements

1. **SMS Gateway**: When enabled, SMS updates would also insert into STATUS_LOGS with source='SMS'
2. **Offline Support**: Queue status updates when offline, sync when online
3. **Status Notifications**: Notify admins when critical status is sent
4. **Auto-Triage**: Implement the `auto_triage_students()` function to mark inactive students as UNKNOWN
5. **Real-time Updates**: Use Supabase Realtime to sync status across multiple app instances

## Summary

The implementation provides a complete backend integration for status updates:
✅ Status selected by user in frontend
✅ StatusService handles all Supabase operations
✅ StatusModel provides type-safe data structures
✅ AppStateNotifier orchestrates the flow
✅ Location data is automatically included
✅ Database audit trail is created
✅ RLS policies enforce security
✅ Error handling and user feedback
