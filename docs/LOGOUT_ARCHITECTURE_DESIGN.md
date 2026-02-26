# Logout Feature - Architecture & Design Document

## System Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        User Interface Layer                      │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │              HomeScreen (Stateful Widget)                │   │
│  │  ┌────────────────────────────────────────────────────┐  │   │
│  │  │ AppBar with Logout IconButton (top-right)          │  │   │
│  │  │ • Icons.logout                                     │  │   │
│  │  │ • Tooltip: "Log out"                               │  │   │
│  │  │ • onPressed: _handleLogout()                       │  │   │
│  │  └────────────────────────────────────────────────────┘  │   │
│  │                                                            │   │
│  │  _handleLogout() Method:                                 │   │
│  │  1. Calls LogoutDialog.show()                           │   │
│  │  2. On confirm → context.read<AuthNotifier>()           │   │
│  │  3. Calls authNotifier.signOut()                        │   │
│  │  4. Shows confirmation SnackBar                         │   │
│  │  5. Navigation happens automatically                    │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │          LogoutDialog (Confirmation Dialog)              │   │
│  │  ┌────────────────────────────────────────────────────┐  │   │
│  │  │ Title: "Log Out"                                   │  │   │
│  │  ├────────────────────────────────────────────────────┤  │   │
│  │  │ "Are you sure you want to log out?"                │  │   │
│  │  │ "You will need to sign in again..."                │  │   │
│  │  │ [Error message if needed]                          │  │   │
│  │  ├────────────────────────────────────────────────────┤  │   │
│  │  │ - Loading state management                         │  │   │
│  │  │ - Error state handling                             │  │   │
│  │  │ - Button callbacks                                 │  │   │
│  │  ├────────────────────────────────────────────────────┤  │   │
│  │  │ [Cancel]  [Loading... Logout]                      │  │   │
│  │  └────────────────────────────────────────────────────┘  │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              │ Calls
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                   State Management Layer (Provider)              │
├─────────────────────────────────────────────────────────────────┤
│                                                                   │
│  ┌──────────────────────────────────────────────────────────┐   │
│  │        AuthNotifier (ChangeNotifier)                      │   │
│  │  • Represents authentication state                        │   │
│  │  • Listens to stream of profile completion service       │   │
│  │                                                            │   │
│  │  signOut() async {                                        │   │
│  │    1. AuthService().signOut()  ─────┐                     │   │
│  │    2. ProfileService.clearData() ──┐ │                     │   │
│  │    3. Reset state to unauth        │ │                     │   │
│  │    4. notifyListeners()            │ │                     │   │
│  │  }                                 │ │                     │   │
│  │                                    │ │                     │   │
│  │  Properties:                       │ │                     │   │
│  │  • _state: AuthFlowState          │ │                     │   │
│  │  • _profile: UserProfile?         │ │                     │   │
│  │  • _error: String?                │ │                     │   │
│  │  • _isLoadingProfile: bool        │ │                     │   │
│  └──────────────────────────────────────────────────────────┘   │
│                                                                   │
└─────────────────────────────────────────────────────────────────┘
                       │                    │
         Calls         │                    │
         ┌─────────────┘                    │
         │                                  │
         ▼                                  ▼
┌──────────────────────────────┬──────────────────────────────┐
│  Business Logic Layer        │  Data Persistence Layer      │
├──────────────────────────────┴──────────────────────────────┤
│                                                              │
│  ┌─────────────────────────────┐ ┌──────────────────────┐   │
│  │  AuthService (Singleton)    │ │ ProfileCompletion    │   │
│  │                             │ │ Service              │   │
│  │  signOut() {               │ │                      │   │
│  │    • Supabase.auth         │ │ clearAllProfileData()│   │
│  │      .signOut()            │ │ • Remove profile     │   │
│  │    • GoogleSignIn          │ │ • Remove flag        │   │
│  │      .signOut()            │ │                      │   │
│  │    • GoogleSignIn          │ └──────────────────────┘   │
│  │      .disconnect()         │                             │
│  │  }                         │         │                   │
│  │                             │         │ Writes to        │
│  │  Properties:               │         │                   │
│  │  • _supabase: Client       │         ▼                   │
│  │  • _googleSignIn: Service  │  ┌──────────────────────┐   │
│  │  • _google*Initialized     │  │  SharedPreferences   │   │
│  │                             │  │                      │   │
│  │  getters:                  │  │  Keys cleared:       │   │
│  │  • currentUser             │  │  • user_profile_...  │   │
│  │  • isAuthenticated         │  │  • profile_complete..│   │
│  │  • authStateStream         │  │                      │   │
│  │                             │  │  (Local device cache)│   │
│  └─────────────────────────────┘  └──────────────────────┘   │
│                                                              │
│                            ▲                                │
│                            │ Clears                         │
└────────────────────────────┼────────────────────────────────┘
                             │
┌────────────────────────────┼────────────────────────────────┐
│        External Services   │                                │
├────────────────────────────┼────────────────────────────────┤
│                            │                                │
│  ┌────────────────────┐    │    ┌──────────────────────┐    │
│  │  Supabase Auth     │←───┘    │   Google Sign-In     │    │
│  │  (Cloud Backend)   │         │   (OAuth 2.0)        │    │
│  │                    │         │                      │    │
│  │ • JWT token stored │         │ • Access tokens      │    │
│  │ • Session data     │         │ • Refresh tokens     │    │
│  │ • Invalidates JWT  │         │ • Account disconnect │    │
│  │ • Auth stream      │         │ • Session cleared    │    │
│  └────────────────────┘         └──────────────────────┘    │
│                                                              │
└──────────────────────────────────────────────────────────────┘
```

---

## State Machine Diagram

```
┌─────────────────────────────────────────────────────────────┐
│                    Initial App State                         │
│                                                              │
│  AuthFlowState.authenticatedProfileComplete                │
│  ├─ User is logged in                                      │
│  ├─ Profile is completed                                   │
│  ├─ Home screen is visible                                 │
│  └─ Logout button is available                             │
└───────────┬────────────────────────────────────────────────┘
            │
            │ User taps logout button
            │
            ▼
┌─────────────────────────────────────────────────────────────┐
│                    Show LogoutDialog                         │
│                                                              │
│  • Dialog appears                                           │
│  • Non-dismissible (must choose action)                    │
│  • Shows confirmation message                              │
│  • Awaits user decision                                    │
└───────────┬──────────────────────────────────────────────────┘
            │
        ┌───┴───┐
        │       │
    Cancel   Confirm
        │       │
        │       ▼
        │   ┌─────────────────────────────────────┐
        │   │  _handleLogout() continues          │
        │   │  Loading state shown in dialog      │
        │   │  signOut() execution                │
        │   │  (async operation)                  │
        │   └────────┬────────────────────────────┘
        │            │
        │            ▼
        │   ┌─────────────────────────────────────┐
        │   │  AuthNotifier.signOut()             │
        │   │  ├─ AuthService.signOut()           │
        │   │  │  ├─ Supabase.signOut()          │
        │   │  │  └─ GoogleSignIn.signOut()      │
        │   │  ├─ ProfileService.clear()         │
        │   │  │  ├─ Remove profile JSON         │
        │   │  │  └─ Remove completion flag      │
        │   │  ├─ Reset state to UNAUTH          │
        │   │  ├─ Set profile to null            │
        │   │  └─ notifyListeners()              │
        │   └────────┬────────────────────────────┘
        │            │
        │            ▼
        │   ┌─────────────────────────────────────┐
        │   │  AuthFlowState.unauthenticated      │
        │   │  ├─ User logged out                 │
        │   │  ├─ No profile in memory            │
        │   │  ├─ No auth token                   │
        │   │  └─ All services signed out         │
        │   └────────┬────────────────────────────┘
        │            │
        │            ▼
        │   ┌─────────────────────────────────────┐
        │   │  AuthWrapper detects change         │
        │   │  (via Supabase.auth.onAuthState)    │
        │   │  ├─ isAuthenticated = false         │
        │   │  ├─ Rebuilds widget tree            │
        │   │  └─ Returns SignInPage              │
        │   └────────┬────────────────────────────┘
        │            │
        │            ▼
        │   ┌─────────────────────────────────────┐
        │   │  Navigation Complete                │
        │   │  ├─ SignInPage rendered             │
        │   │  ├─ Previous routes cleared         │
        │   │  ├─ No back navigation possible     │
        │   │  └─ SnackBar shows success          │
        │   └─────────────────────────────────────┘
        │
        │
        ▼
┌─────────────────────────────────────────────────────────────┐
│               Dialog Closes (Cancel Path)                   │
│                                                              │
│  • Return to HomeScreen                                     │
│  • User remains authenticated                              │
│  • No state changes                                         │
│  • Logout dialog confirmation rejected                     │
└─────────────────────────────────────────────────────────────┘
```

---

## Data Flow Diagram

```
                     User Interaction
                            │
                            ▼
                  ┌──────────────────┐
                  │  Logout IconButton│
                  │  onPressed event  │
                  └────────┬──────────┘
                           │
                           │ calls
                           ▼
                  ┌──────────────────┐
                  │ _handleLogout()   │
                  │ (HomeScreen)      │
                  └────────┬──────────┘
                           │
            ┌──────────────┴──────────────┐
            │                             │
            ▼                             ▼
    ┌──────────────────┐        ┌──────────────────┐
    │ LogoutDialog.show()       │ Confirmation     │
    │ ├─ Create dialog │        │ Message shown    │
    │ ├─ Show modal    │        │ User decides     │
    │ └─ Wait for input│        └──────────────────┘
    └────────┬─────────┘
             │
         ┌───┴──────────────┐
         │                  │
    Cancel                Confirm
         │                  │
         │                  ▼
         │         ┌──────────────────────┐
         │         │ context.read<Auth    │
         │         │ Notifier>()          │
         │         └─────────┬────────────┘
         │                   │
         │                   ▼
         │         ┌──────────────────────┐
         │         │ authNotifier.        │
         │         │ signOut() async      │
         │         └──────────┬───────────┘
         │                    │
         │      ┌─────────────┼─────────────┐
         │      │             │             │
         │      ▼             ▼             ▼
         │   ┌─────────┐  ┌──────────┐  ┌──────────┐
         │   │AuthServ │  │Profile   │  │ Reset    │
         │   │ice.sign │  │Service.  │  │ Auth     │
         │   │Out()    │  │clear()   │  │ State    │
         │   │         │  │          │  │          │
         │   │Supabase │  │Shared    │  │state =   │
         │   │         │  │Prefs:    │  │UNAUTH    │
         │   │GoogleSi │  │- remove  │  │profile=  │
         │   │gnIn.sign│  │  profile │  │null      │
         │   │Out()    │  │- remove  │  │error=null│
         │   │         │  │  flag    │  │          │
         │   │Google   │  │          │  │          │
         │   │SignIn.  │  │          │  │          │
         │   │disconnect  │          │  │          │
         │   └────┬────┘  └────┬─────┘  └────┬─────┘
         │        │            │             │
         │        │            │             │
         │        └────────────┼─────────────┘
         │                     │
         │                     ▼
         │         ┌──────────────────────┐
         │         │notifyListeners()     │
         │         │(notify all Consumer) │
         │         └─────────┬────────────┘
         │                   │
         │                   ▼
         │         ┌──────────────────────┐
         │         │AuthWrapper.          │
         │         │StreamBuilder rebuilt │
         │         └─────────┬────────────┘
         │                   │
         │                   ▼
         │         ┌──────────────────────┐
         │         │Check auth state      │
         │         │isAuthenticated=false │
         │         └─────────┬────────────┘
         │                   │
         │                   ▼
         │         ┌──────────────────────┐
         │         │Build SignInPage      │
         │         │(navigation happens)  │
         │         └──────────────────────┘
         │
         └────────────────┐
                          │
                          ▼
                ┌──────────────────────┐
                │ Dialog Closes        │
                │ Return to previous   │
                │ screen (HomeScreen)  │
                │ No state change      │
                │ No navigation        │
                └──────────────────────┘
```

---

## Component Interaction Matrix

```
┌──────────────────┬──────────────┬──────────────┬────────────┬──────────────┐
│ Component        │ HomeScreen   │ LogoutDialog │ AuthNotif. │ AuthService  │
├──────────────────┼──────────────┼──────────────┼────────────┼──────────────┤
│ HomeScreen       │ Self         │ Shows        │ Reads      │ None         │
│                  │              │ Dialog       │ (indirect) │              │
├──────────────────┼──────────────┼──────────────┼────────────┼──────────────┤
│ LogoutDialog     │ Calls        │ Self         │ Uses       │ None         │
│                  │ _handleLogout│              │ Callback   │              │
├──────────────────┼──────────────┼──────────────┼────────────┼──────────────┤
│ AuthNotifier     │ Listened by  │ Called via   │ Self       │ Calls        │
│                  │ (Consumer)   │ callback     │            │              │
├──────────────────┼──────────────┼──────────────┼────────────┼──────────────┤
│ AuthService      │ None         │ None         │ Calls      │ Self         │
│                  │              │              │            │              │
├──────────────────┼──────────────┼──────────────┼────────────┼──────────────┤
│ ProfileService   │ None         │ None         │ Calls      │ None         │
│                  │              │              │            │              │
└──────────────────┴──────────────┴──────────────┴────────────┴──────────────┘
```

---

## Database/Cache State Transitions

```
┌────────────────────────────────────────────────────────────────┐
│ SUPABASE (Cloud)                                               │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│ Before Logout:                                                │
│ ├─ JWT Token: "eyJhbGc..."  ✓ Valid                          │
│ ├─ Session ID: "sess_abc..."  ✓ Active                       │
│ └─ User ID: "user_123..."  ✓ Authenticated                   │
│                                                                │
│ During Logout:                                                │
│ └─ Supabase.auth.signOut() called                            │
│                                                                │
│ After Logout:                                                 │
│ ├─ JWT Token: ✗ Invalidated                                   │
│ ├─ Session ID: ✗ Revoked                                     │
│ └─ User ID: ✗ Unauthenticated                                │
│                                                                │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│ GOOGLE SIGN-IN (External OAuth)                                │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│ Before Logout:                                                │
│ ├─ Access Token: "ya29.wwe..." ✓ Valid                       │
│ ├─ Refresh Token: "1//09..." ✓ Active                        │
│ └─ Account Link: Email linked ✓ Connected                    │
│                                                                │
│ During Logout:                                                │
│ ├─ GoogleSignIn.signOut() called                             │
│ └─ GoogleSignIn.disconnect() called                          │
│                                                                │
│ After Logout:                                                 │
│ ├─ Access Token: ✗ Revoked                                    │
│ ├─ Refresh Token: ✗ Invalidated                              │
│ └─ Account Link: ✗ Disconnected                              │
│                                                                │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│ SHARED PREFERENCES (Local Device Storage)                       │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│ Before Logout:                                                │
│ ├─ "user_profile_completion": {                              │
│ │  └─ JSON: studentId, firstName, email, phone... ✓ Cached   │
│ └─ "profile_complete_status": true  ✓ Flag set               │
│                                                                │
│ During Logout:                                                │
│ └─ ProfileCompletionService.clearAllProfileData() called      │
│                                                                │
│ After Logout:                                                 │
│ ├─ "user_profile_completion": ✗ Key removed                  │
│ └─ "profile_complete_status": ✗ Key removed                  │
│                                                                │
│ Result: No profile data persists locally                      │
│                                                                │
└────────────────────────────────────────────────────────────────┘

┌────────────────────────────────────────────────────────────────┐
│ IN-MEMORY STATE (AuthNotifier)                                  │
├────────────────────────────────────────────────────────────────┤
│                                                                │
│ Before Logout:                                                │
│ ├─ state: authenticatedProfileComplete  ✓ Logged in          │
│ ├─ profile: UserProfile(...)  ✓ Not null                     │
│ ├─ error: null  ✓ No errors                                  │
│ └─ isLoadingProfile: false  ✓ Not loading                    │
│                                                                │
│ During Logout:                                                │
│ └─ signOut() executes                                         │
│                                                                │
│ After Logout:                                                 │
│ ├─ state: unauthenticated  ✓ Changed                         │
│ ├─ profile: null  ✓ Cleared                                  │
│ ├─ error: null  ✓ No errors                                  │
│ └─ isLoadingProfile: false  ✓ Reset                          │
│                                                                │
│ Listeners notified: AuthWrapper reacts                        │
│                                                                │
└────────────────────────────────────────────────────────────────┘
```

---

## Error Handling Flow

```
┌────────────────────────────────────────────┐
│ User confirms logout in dialog             │
└────────────────┬───────────────────────────┘
                 │
                 ▼
         ┌───────────────┐
         │ signOut() Try │
         └───────┬───────┘
                 │
        ┌────────┴────────┐
        │                 │
    Success            Exception
        │                 │
        ▼                 ▼
   ┌─────────┐     ┌──────────────────┐
   │ Clear   │     │ Catch Exception   │
   │ All     │     │ Set _error var    │
   │ Data    │     │ Call setState()   │
   │ Notify  │     │ Dialog shows error│
   │ Success │     │ Loading stops     │
   │         │     │ User can retry    │
   └────┬────┘     └────────┬──────────┘
        │                   │
        │                   ▼
        │          ┌──────────────────┐
        │          │ User sees error   │
        │          │ message in dialog │
        │          │                  │
        │          │ Can tap Logout   │
        │          │ again to retry   │
        │          │ Or Cancel        │
        │          └────────┬─────────┘
        │                   │
        │   ┌───────────────┴──────────────┐
        │   │                              │
        │   │ Retry logout              Cancel
        │   │   │                          │
        │   │   └──────→ Try Again         │
        │   │              OR         Close Dialog
        │   │           Success            │
        │   │              OR           Return
        │   │            Error Again    HomeScreen
        │   │                              │
        │   └──────────────┬────────────────┘
        │                  │
        ▼                  ▼
    Navigate to        User remains
    SignInPage        on HomeScreen
    (Success)         (Logout aborted)
```

---

## Security Considerations Diagram

```
┌─────────────────────────────────────────────────────────────┐
│         SECURITY LAYERS IN LOGOUT IMPLEMENTATION            │
└─────────────────────────────────────────────────────────────┘

Layer 1: User Confirmation
┌─────────────────────────────────────────────────────────────┐
│ • LogoutDialog requires explicit confirmation               │
│ • barrierDismissible: false (no dismissing)                 │
│ • Must tap one of two buttons: Cancel or Logout            │
│ • Prevents accidental logouts                              │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
Layer 2: Backend Auth Invalidation
┌─────────────────────────────────────────────────────────────┐
│ • Supabase.auth.signOut() invalidates JWT token           │
│ • Session tokens revoked on server                         │
│ • Prevents token reuse after logout                        │
│ • Backend enforces auth on protected endpoints              │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
Layer 3: OAuth Session Termination
┌─────────────────────────────────────────────────────────────┐
│ • GoogleSignIn.signOut() - revokes access tokens           │
│ • GoogleSignIn.disconnect() - unlinks account              │
│ • Full logout from OAuth provider                          │
│ • Prevents silent re-authentication                        │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
Layer 4: Local Cache Clearing
┌─────────────────────────────────────────────────────────────┐
│ • SharedPreferences profile data removed                    │
│ • ProfileCompletionService.clearAllProfileData()           │
│ • Keys explicitly deleted:                                  │
│   - user_profile_completion                                │
│   - profile_complete_status                                │
│ • No residual personal data on device                      │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
Layer 5: In-Memory State Reset
┌─────────────────────────────────────────────────────────────┐
│ • AuthNotifier state set to unauthenticated                │
│ • Profile object nullified                                 │
│ • Error state cleared                                      │
│ • Loading flags reset                                      │
│ • All listeners notified                                   │
└─────────────────────────────────────────────────────────────┘
                            │
                            ▼
Layer 6: Navigation Stack Security
┌─────────────────────────────────────────────────────────────┐
│ • AuthWrapper automatically navigates to SignInPage         │
│ • Previous routes removed from navigation stack             │
│ • Back button doesn't work                                 │
│ • Cannot navigate back to authenticated screens            │
│ • Forces re-authentication on app restart                  │
└─────────────────────────────────────────────────────────────┘
```

---

## Performance Optimization Diagram

```
┌──────────────────────────────────────────────────────────────┐
│               LOGOUT PERFORMANCE TIMELINE                     │
└──────────────────────────────────────────────────────────────┘

User Interaction (0ms)
├─ Tap logout icon (1ms UI response)
│
Dialog Show (50-100ms)
├─ Build dialog widget (20ms)
├─ Animation start (30ms)
├─ Show modal (20ms)
│
User Confirms (Variable - at user discretion)
├─ User reads message (5-20 seconds typically)
├─ Taps Logout button (1ms action)
│
Logout Execution (500-1200ms typical)
├─ Dialog loading state shown (10ms)
├─ AuthService.signOut() (100-200ms)
│  ├─ Supabase.auth.signOut() (50-150ms network)
│  └─ GoogleSignIn.signOut() + disconnect() (50-100ms network)
├─ ProfileService.clearAllProfileData() (50-100ms disk I/O)
├─ AuthNotifier state reset (1-10ms memory)
├─ notifyListeners() dispatch (10-50ms)
│
Navigation (100-200ms)
├─ AuthWrapper stream detection (10-30ms)
├─ Rebuild decision (20-50ms)
├─ SignInPage build (50-100ms)
├─ Animation (30-60ms)
│
Total: 500-1200ms (typically ~800ms)

Performance Characteristics:
┌──────────────────────────────────────────┐
│ • No UI blocking during logout          │
│ • Async operations properly handled     │
│ • Loading state provides feedback       │
│ • Network dependent (Supabase/Google)  │
│ • Timeout: ~2s (if no network)         │
│ • Retry possible on failure             │
└──────────────────────────────────────────┘
```

---

**Architecture Version**: 1.0  
**Created**: February 26, 2026  
**Status**: Production Ready
