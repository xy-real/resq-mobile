# Backend Auth Implementation - Quick Start Guide

## What Was Implemented

You now have a complete **Google OAuth authentication + student profile registration system** that integrates with Supabase. Here's what happens:

### The Flow (New User)
1. User taps "Sign in with Google"
2. Google OAuth popup appears
3. User authenticates with their Google account
4. App checks: "Does this user already have a student profile?"
5. **NO** → Shows profile completion form
   - Email auto-filled from Google
   - User enters: Student ID, First Name, Last Name, Phone
6. User submits form
7. **Profile is saved to Supabase STUDENTS table**
8. User sees HomePage

### The Flow (Returning User)
1. User taps "Sign in with Google"
2. Google OAuth popup appears
3. User authenticates
4. App checks: "Does this user already have a student profile?"
5. **YES** → Loads profile from database
6. Skips form, goes straight to HomePage ⚡ (Better UX!)

---

## Files Modified

| File | Changes | Purpose |
|------|---------|---------|
| `lib/services/profile_completion_service.dart` | 5 new methods | Database integration for profiles |
| `lib/providers/auth_provider.dart` | Enhanced state management | Smart profile loading |
| `lib/pages/sign_in_page.dart` | Updated Google handler | Connects auth to new flow |

## How It Works (Technical)

### 1. User Authentication (AuthService.dart)
```
Google Sign-In → Exchange tokens with Supabase → Create auth session
```

### 2. Profile Check (ProfileCompletionService.dart)
```
Query: SELECT * FROM students WHERE user_id = authenticated_user_id
  ├─ Found? → Load profile from database  
  └─ Not found? → Show form for profile completion
```

### 3. Profile Submission (ProfileCompletionService.dart)
```
User fills form → UPSERT into students table
{
  "student_id": "2024-001",
  "user_id": "{auth_user_id}",
  "email": "user@gmail.com",
  "name": "John Doe",
  "contact_number": "555-1234",
  "last_status": "UNKNOWN"
}
```

### 4. State Management (AuthNotifier.dart)
```
authenticatedNeedsProfile (form shown)
           ↓ [user submits]
authenticatedProfileComplete (app shown)
```

---

## Required Setup

### 1. Supabase Configuration
Ensure your Supabase project has:
```sql
-- STUDENTS table exists
CREATE TABLE students (
  student_id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users(id),
  email TEXT,
  name TEXT,
  contact_number TEXT,
  last_status TEXT DEFAULT 'UNKNOWN'
);
```

### 2. RLS Policy (Most Important!)
```sql
-- Allow users to INSERT their own profile
CREATE POLICY "students_insert_own" ON students
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Allow users to SELECT their own profile
CREATE POLICY "students_select_own" ON students
  FOR SELECT USING (auth.uid() = user_id);
```

### 3. Google OAuth Credentials
In `lib/constants/app_constants.dart`:
```dart
static const String googleIosClientId = 'YOUR_IOS_CLIENT_ID';
static const String googleWebClientId = 'YOUR_WEB_CLIENT_ID';
```
Get these from Google Cloud Console → OAuth 2.0 Credentials

---

## Testing Checklist

### ✅ First-Time User Flow
```
1. Open app
2. Tap "Sign in with Google"
3. Select Google account (never used app before)
4. ✓ CompleteProfilePage appears
5. Enter: Student ID, First Name, Last Name, Phone
6. Tap Submit
7. ✓ Wait 1-2 seconds
8. ✓ HomePage appears
9. Verify in Supabase: SELECT * FROM students (should see new record)
```

### ✅ Returning User Flow
```
1. Open app (already signed in as above)
2. Tap Sign Out (if available)
3. Tap "Sign in with Google"
4. Select SAME Google account
5. ✓ HomePage appears immediately (no form!)
6. ✓ Verify profile loaded correctly
```

### ✅ Database Verification
```
Supabase Dashboard → students table:
- See your new record?
- student_id = what you entered?
- name = First Last? (combined)
- user_id = matches auth.users(id)?
```

---

## Key Code Changes Explained

### Change 1: submitProfile() now saves to database
**Before:** Saved to local storage only
**After:** 
```dart
await _supabase.from('students').upsert({
  'student_id': profile.studentId,
  'user_id': user.id,
  'email': profile.email,
  'name': fullName,
  'contact_number': profile.contactNumber,
  'last_status': 'UNKNOWN',
}, onConflict: 'student_id');
```

### Change 2: Smart profile loading
**New method:** `handleGoogleSignInComplete()`
```dart
// Check if profile exists
bool exists = await _profileService.studentRecordExists();

if (exists) {
  // Returning user - load & go to home
  _profile = await _profileService.loadProfileFromDatabase();
  _state = AuthFlowState.authenticatedProfileComplete;
} else {
  // New user - show form
  _state = AuthFlowState.authenticatedNeedsProfile;
}
```

### Change 3: Updated Google sign-in handler
**In SignInPage:**
```dart
// OLD: setGoogleAuthenticatedNeedsProfile()
// NEW: handleGoogleSignInComplete()
await context.read<AuthNotifier>().handleGoogleSignInComplete();
```

---

## What Happens Behind the Scenes

### Local Caching
- Profiles cached in SharedPreferences
- Offline first: use cache if available
- Database sync when online

### Error Handling
- Network error? → Gracefully falls back
- Invalid student ID? → Database rejects
- RLS violation? → Database blocks access (security)

### Data Flow
```
Google OAuth ──→ Supabase Auth ──→ Firebase Notifier
     ↓                ↓                    ↓
 Exchange      Create Session    handleGoogleSignInComplete()
 Tokens           + User ID
                   ↓
            Check STUDENTS table
                   ↓
            ┌──────┴──────┐
            ↓             ↓
         Exists      Doesn't Exist
            ↓             ↓
         Load Db     Show Form
            ↓             ↓
        HomePage    Submit Form → SaveDb → HomePage
```

---

## Security Features

✅ **RLS Policies**
- Students can only see/modify their own record
- Database enforces: `auth.uid() = user_id`

✅ **Google OAuth**
- Email automatically verified by Google
- No password storage needed
- Tokens managed by Supabase

✅ **Data Validation**
- Student ID checked in database (unique)
- Name fields trimmed
- Phone number format validated in UI

✅ **Isolation**
- Each user's data isolated via RLS
- User can't access other users' profiles
- Future: Admins can see all (separate RLS)

---

## Troubleshooting

### Problem: "User not authenticated"
**Solution:** Ensure Google sign-in completed successfully. Check auth logs in Supabase Dashboard.

### Problem: "Student record not saving"
**Solution:** 
1. Check RLS policy is created in Supabase
2. Verify STUDENTS table exists
3. Check browser console for errors

### Problem: "Form shows for returning users"
**Solution:** 
1. Check `studentRecordExists()` query is correct
2. Verify `user_id` is being saved (not NULL)
3. Check for database connection errors

### Problem: "Email not pre-filled"
**Solution:** Verify `_profileService.getGoogleEmail()` returns value. Check Google OAuth is succeeding.

---

## Next Steps (For Future)

1. **Profile Updates**
   - Allow users to edit profile after submission
   - Add profile picture upload

2. **Location Tracking**
   - Auto-save location after profile completion
   - Update `last_known_lat`, `last_known_lng`

3. **SMS Integration**
   - Allow status updates via SMS
   - Parse SMS and insert into STATUS_LOGS table

4. **Admin Dashboard**
   - Build admin panel to manage students
   - View all student statuses
   - Activate disaster mode

---

## Summary

✨ **You now have:**
- ✅ Google OAuth authentication
- ✅ First-time user profile collection
- ✅ Student data persisted to Supabase
- ✅ Returning user shortcut (skip form)
- ✅ RLS policy enforcement
- ✅ Local caching for offline support

🎉 **Ready to test!**

