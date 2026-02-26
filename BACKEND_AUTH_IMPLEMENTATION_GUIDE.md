# ResQ Mobile - Backend Authentication Implementation Guide

## Overview

This document describes the complete backend authentication and student profile registration flow implemented in the ResQ Mobile app.

## Architecture

### Key Components

1. **AuthService** (`lib/services/auth_service.dart`)
   - Handles Supabase authentication (Google OAuth, Email/Password)
   - Manages Google Sign-In initialization and token exchange
   - Provides sign out functionality

2. **ProfileCompletionService** (`lib/services/profile_completion_service.dart`)
   - Manages student profile data persistence (local + database)
   - Submits profiles to Supabase STUDENTS table
   - Checks if student records already exist in database
   - Loads existing profiles from database

3. **AuthNotifier/AuthProvider** (`lib/providers/auth_provider.dart`)
   - Manages authentication flow state (6 states)
   - Coordinates between AuthService and ProfileCompletionService
   - Notifies UI of state changes (loading, authenticated, needs profile, etc.)

4. **UI Pages**
   - **SignInPage**: Google and Email/Password authentication
   - **CompleteProfilePage**: Student profile form (shown for first-time users)
   - **HomePage**: Main app (shown for authenticated users with complete profile)

---

## Authentication Flow

### Google OAuth Sign-In Flow

```
┌─────────────────────────────────────────────────────────────────┐
│ 1. User taps "Sign in with Google" on SignInPage                 │
├─────────────────────────────────────────────────────────────────┤
│ 2. _handleGoogleSignIn() initiates Google authentication         │
│    - Clears any existing Google session                          │
│    - Performs Google sign-in with configured credentials         │
│    - Exchanges Google tokens for Supabase auth tokens            │
├─────────────────────────────────────────────────────────────────┤
│ 3. After successful auth → handleGoogleSignInComplete()          │
│    a. Check if student record EXISTS in STUDENTS table           │
│       - Query: SELECT student_id FROM students                   │
│                 WHERE user_id = auth.uid()                       │
├─────────────────────────────────────────────────────────────────┤
│ 4a. IF Student Record EXISTS:                                    │
│    - Load profile from database                                  │
│    - Mark profile as complete locally                            │
│    - Transition to authenticatedProfileComplete state            │
│    - User sees HomePage                                          │
│                                                                  │
│ 4b. IF Student Record DOES NOT EXIST:                            │
│    - Initialize empty profile with Google email                  │
│    - Transition to authenticatedNeedsProfile state               │
│    - User sees CompleteProfilePage                               │
├─────────────────────────────────────────────────────────────────┤
│ 5. User fills profile form and submits                           │
│    - Student ID (university ID)                                  │
│    - First Name & Surname (auto-capitalized)                     │
│    - Optional: Middle Initial, Extension (Jr., Sr., etc.)        │
│    - Contact Number (with validation)                            │
├─────────────────────────────────────────────────────────────────┤
│ 6. submitProfile() inserts into STUDENTS table:                  │
│    INSERT INTO students (                                        │
│      student_id,                                                 │
│      user_id,        -- Links to auth.users(id)                 │
│      email,          -- From Google account                      │
│      name,           -- Full name: firstName + surname           │
│      contact_number, -- Phone or emergency contact               │
│      last_status     -- Initial: 'UNKNOWN'                       │
│    ) VALUES (...)                                                │
│    ON CONFLICT (student_id) DO UPDATE -- Handle updates          │
└─────────────────────────────────────────────────────────────────┘
```

### Email/Password Sign-Up Flow (For Reference)

Email/password registration requires the same profile completion step after signup.

---

## Database Integration

### Supabase STUDENTS Table Schema

```json
{
  "student_id": "TEXT (PRIMARY KEY)",
  "user_id": "UUID (FOREIGN KEY → auth.users)",
  "email": "TEXT",
  "name": "TEXT (full name)",
  "contact_number": "TEXT",
  "last_status": "TEXT (default: 'UNKNOWN')",
  "last_known_lat": "DECIMAL",
  "last_known_lng": "DECIMAL",
  "last_update_timestamp": "TIMESTAMP",
  "last_update_source": "TEXT"
}
```

### Row-Level Security (RLS) Policies

The STUDENTS table has the following RLS policies:

1. **students_insert_own** (INSERT)
   - Allows authenticated users to INSERT their own record
   - Condition: `auth.uid() = user_id`
   - ✅ This policy enables our profile completion flow

2. **students_update_own_status** (UPDATE)
   - Allows authenticated users to UPDATE only their status/location
   - Condition: `auth.uid() = user_id`

3. **admins_select_all_students** (SELECT)
   - Allows admin users to view all student records

---

## State Management

### AuthFlowState Enum

```
initial                    → App starting up
loading                    → Checking auth status
unauthenticated           → User not logged in (show SignInPage)
authenticatedNeedsProfile → Logged in, no profile (show CompleteProfilePage)
authenticatedProfileComplete → Logged in, profile complete (show HomePage)
error                     → Error occurred
```

### State Transitions

```
unauthenticated
    ↓
    └─→ Google Sign-In Success
        ↓
        ├─→ [Student record exists in DB]
        │   ↓
        │   authenticatedProfileComplete
        │   ↓
        │   HomePage
        │
        └─→ [No student record in DB]
            ↓
            authenticatedNeedsProfile
            ↓
            CompleteProfilePage (form)
            ↓
            [User submits form]
            ↓
            submitProfile() → saves to STUDENTS table
            ↓
            authenticatedProfileComplete
            ↓
            HomePage
```

---

## Implementation Details

### 1. Google Sign-In with Supabase

**File**: `lib/services/auth_service.dart`

```dart
Future<AuthResponse> signInWithGoogle({
  required String iosClientId,
  required String webClientId,
}) async {
  _initializeGoogleSignIn(...)
  await _googleSignIn.signOut();  // Clear previous session
  final googleUser = await _googleSignIn.signIn();
  final googleAuth = await googleUser.authentication;
  
  return await _supabase.auth.signInWithIdToken(
    provider: OAuthProvider.google,
    idToken: idToken,
    accessToken: accessToken,
  );
}
```

**Key Points**:
- Credentials obtained from Google Cloud Console
- IOS client ID and Web client ID configured in AppConstants
- ID token exchange with Supabase for secure auth

### 2. Profile Completion with Database Integration

**File**: `lib/services/profile_completion_service.dart`

```dart
Future<UserProfile> submitProfile(UserProfile profile) async {
  final user = _supabase.auth.currentUser;
  if (user == null) throw Exception('User not authenticated');
  
  final fullName = '${profile.firstName} ${profile.surname}'.trim();
  
  // Save to STUDENTS table
  await _supabase.from('students').upsert({
    'student_id': profile.studentId,
    'user_id': user.id,              // Links to authenticated user
    'email': profile.email,
    'name': fullName,
    'contact_number': profile.contactNumber,
    'last_status': 'UNKNOWN',
  }, onConflict: 'student_id');
  
  // Cache locally
  await _prefs.setString(_profileCompletionKey, jsonEncode(...));
  await _prefs.setBool(_profileCompleteStatusKey, true);
  
  return profile.copyWith(profileCompleted: true);
}
```

### 3. Checking Existing Profiles

**New Method**: `studentRecordExists()`

```dart
Future<bool> studentRecordExists() async {
  final user = _supabase.auth.currentUser;
  final response = await _supabase
      .from('students')
      .select('student_id')
      .eq('user_id', user.id)
      .maybeSingle();
  return response != null;
}
```

This allows returning users to skip the profile form.

### 4. Post-Sign-In Profile Handling

**New Method in AuthNotifier**: `handleGoogleSignInComplete()`

```dart
Future<void> handleGoogleSignInComplete() async {
  final recordExists = await _profileService.studentRecordExists();
  
  if (recordExists) {
    // Load existing profile
    _profile = await _profileService.loadProfileFromDatabase();
    _state = AuthFlowState.authenticatedProfileComplete;
    await _profileService.saveDraftProfile(_profile!);
    await _profileService.markProfileComplete();
  } else {
    // Initialize form with Google email
    _state = AuthFlowState.authenticatedNeedsProfile;
    _profile = UserProfile(
      studentId: '',
      firstName: '',
      surname: '',
      email: _profileService.getGoogleEmail() ?? '',
      contactNumber: '',
    );
  }
  notifyListeners();
}
```

---

## Security Considerations

### Authentication

- ✅ Google OAuth handles authentication (Supabase managed)
- ✅ No passwords stored in custom tables
- ✅ All queries respect RLS policies

### Authorization

- ✅ Students can only INSERT/UPDATE their own records
- ✅ Admins have read access to all student records
- ✅ `auth.uid()` is used server-side for policy enforcement

### Data Validation

- ✅ Student ID uniqueness enforced at database level
- ✅ Email verification required for email/password auth
- ✅ Contact number validation in UI (7-11 digits)
- ✅ Name fields stripped of leading/trailing whitespace

---

## Error Handling

### Common Errors and Solutions

| Error | Cause | Solution |
|-------|-------|----------|
| "User not authenticated" | No current Supabase user | Ensure Google sign-in succeeds |
| "student_id already exists" | Duplicate student ID in form | Check database, user must use unique ID |
| "RLS policy violation" | User trying to modify another's record | RLS prevents this automatically |
| "No ID token found" | Google auth incomplete | Retry sign-in, check credentials |

### Debugging

Enable debug output:
```dart
debugPrint('Profile submitted successfully for student: ${profile.studentId}');
```

Check Supabase logs:
- Go to Supabase Dashboard → Logs
- Filter by table name "students"
- Review RLS policy violations

---

## Testing Checklist

### Manual Testing

- [ ] Google sign-in with new Google account (no student record)
  - Should show CompleteProfilePage
  - Form submission should save to STUDENTS table

- [ ] Google sign-in with existing account (has student record)
  - Should skip CompleteProfilePage
  - Should go directly to HomePage

- [ ] Profile form validation
  - [ ] Student ID required
  - [ ] First name required
  - [ ] Surname required
  - [ ] Contact number format validation

- [ ] Sign out and local data clearing
  - [ ] All cached profile data removed
  - [ ] Page navigation to SignInPage
  - [ ] Next sign-in prompts for fresh profile (if needed)

### Database Testing

```sql
-- Check students table
SELECT student_id, user_id, email, name, contact_number, last_status 
FROM students;

-- Check RLS policy works (as authenticated user)
SELECT * FROM students WHERE user_id = auth.uid();

-- Verify foreign key constraint
SELECT s.student_id, s.user_id, u.email 
FROM students s
JOIN auth.users u ON s.user_id = u.id;
```

---

## Future Enhancements

1. **Location Tracking**
   - Auto-save location after profile completion
   - Populate `last_known_lat`, `last_known_lng`

2. **SMS Gateway Integration**
   - SMS-based status updates
   - SMS parser to insert STATUS_LOGS

3. **Profile Updates**
   - Allow users to edit profile after initial completion
   - Phone number updates trigger re-verification

4. **Admin Dashboard**
   - Bulk student import
   - Profile verification process

---

## Related Documentation

- [ERD.txt](./ERD.txt) - Complete database schema
- [Authentication Guide](./AUTHENTICATION.md) - General auth concepts
- [Integration Guide](./INTEGRATION_GUIDE.md) - External service integrations

