# Quick Integration Guide

## Quick Start

The authentication system is fully integrated and ready to use. The app automatically handles authentication state management through the `AuthWrapper` widget.

## Architecture Overview

```
Authentication Flow

    ┌─────────────┐
    │  AuthWrapper│ (Manages auth state)
    └──────┬──────┘
           │
    ┌──────▼──────────────────────┐
    │  User Authenticated?        │
    └──────┬───┬──────────────────┘
           │   │
       No  │   │ Yes
           │   │
    ┌──────▼┐ ┌▼──────────────┐
    │SignIn │ │  HomePage     │
    │SignUp │ │ (Protected)   │
    └───────┘ └───────────────┘
```

## Using AuthService in Other Pages

### Example: Protected Page

```dart
import 'package:flutter/material.dart';
import 'package:resq_mobile/services/auth_service.dart';

class ProtectedPage extends StatefulWidget {
  const ProtectedPage({super.key});

  @override
  State<ProtectedPage> createState() => _ProtectedPageState();
}

class _ProtectedPageState extends State<ProtectedPage> {
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Check if user is authenticated
    if (!_authService.isAuthenticated) {
      Navigator.of(context).pushReplacementNamed('/signin');
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _authService.currentUser;
    
    return Scaffold(
      appBar: AppBar(title: const Text('Protected Page')),
      body: Center(
        child: Text('Welcome, ${user?.email}!'),
      ),
    );
  }
}
```

### Example: Getting Current User

```dart
final authService = AuthService();

// Check if user is logged in
if (authService.isAuthenticated) {
  final user = authService.currentUser;
  final email = user?.email;
  final userId = user?.id;
}
```

### Example: Listening to Auth State Changes

```dart
class MyPage extends StatefulWidget {
  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authService.authStateStream,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          // User authenticated
          return const HomePage();
        }
        // User not authenticated
        return const SignInPage(onSignUpTap: () {});
      },
    );
  }
}
```

### Example: Sign Out

```dart
Future<void> _handleSignOut() async {
  try {
    await _authService.signOut();
    // Navigate to sign-in page
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/signin');
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}
```

## Using Theme Colors in Custom Widgets

```dart
import 'package:flutter/material.dart';
import 'package:resq_mobile/theme/app_theme.dart';

class CustomCard extends StatelessWidget {
  final String title;
  final String description;

  const CustomCard({
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
```

## Common Integration Patterns

### Pattern 1: User Profile Page

```dart
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final AuthService _authService = AuthService();
  late String _userEmail;

  @override
  void initState() {
    super.initState();
    _userEmail = _authService.currentUser?.email ?? 'Unknown';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Column(
        children: [
          ListTile(
            title: const Text('Email'),
            subtitle: Text(_userEmail),
          ),
          ElevatedButton(
            onPressed: () async {
              await _authService.signOut();
              if (mounted) {
                Navigator.of(context).pushReplacementNamed('/signin');
              }
            },
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }
}
```

### Pattern 2: Route Protection

```dart
// In main.dart
return MaterialApp(
  routes: {
    '/': (context) => const AuthWrapper(),
    '/signin': (context) => const SignInPage(onSignUpTap: () {}),
    '/signup': (context) => const SignUpPage(onSignInTap: () {}),
    '/home': (context) => const HomePage(),
    '/profile': (context) => _isAuthenticated
        ? const ProfilePage()
        : const SignInPage(onSignUpTap: () {}),
  },
);
```

### Pattern 3: Request with Authentication

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

class DataService {
  final SupabaseClient _supabase;

  DataService(this._supabase);

  Future<List<Map<String, dynamic>>> fetchUserData() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      
      final response = await _supabase
          .from('user_data')
          .select()
          .eq('user_id', userId)
          .order('created_at', ascending: false);
      
      return response;
    } catch (e) {
      rethrow;
    }
  }
}
```

## Adding New Authentication Methods

### Adding a New Social Provider

1. **Add dependency to pubspec.yaml**
```yaml
dependencies:
  flutter_facebook_sdk: ^version
```

2. **Extend AuthService**
```dart
Future<AuthResponse> signInWithFacebook() async {
  try {
    // Implement Facebook sign-in
    final credentials = await _getFacebookCredentials();
    
    return await _supabase.auth.signInWithIdToken(
      provider: Provider.facebook,
      idToken: credentials.idToken,
      accessToken: credentials.accessToken,
    );
  } catch (e) {
    rethrow;
  }
}
```

3. **Add button to sign-in page**
```dart
SocialButton(
  label: 'Sign in with Facebook',
  icon: Icons.facebook,
  isLoading: _facebookLoading,
  onPressed: _handleFacebookSignIn,
).build2(context),
```

## Environment Variables

The app uses Supabase credentials from `.env` file:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your-anon-key-here
```

**Never commit `.env` file to version control!**

Add to `.gitignore`:
```
.env
.env.local
```

## Debugging Tips

### Enable Auth Debug Logging

```dart
// In auth_service.dart
Future<AuthResponse> signInWithEmail({...}) async {
  try {
    debugPrint('Attempting sign-in with email: $email');
    final response = await _supabase.auth.signInWithPassword(...);
    debugPrint('Sign-in successful');
    return response;
  } catch (e) {
    debugPrint('Sign-in error: $e');
    rethrow;
  }
}
```

### Check Auth State

```dart
// Run in main() during development
void debugPrintAuthState() {
  final user = Supabase.instance.client.auth.currentUser;
  print('Current user: $user');
  print('Is authenticated: ${user != null}');
}
```

### Test Email Sign-in

Use a test email/password combination:
- Email: `test@example.com`
- Password: `TestPassword123!`

### Monitor Network Requests

Use Flutter DevTools Network tab to inspect API calls to Supabase.

## Performance Optimization

### Lazy Load Auth Service

```dart
final AuthService _authService = AuthService(); // Singleton pattern

// Better: Lazy initialization
late final AuthService _authService;

@override
void initState() {
  super.initState();
  _authService = AuthService();
}
```

### Cache User Data

```dart
class CachedAuthService {
  User? _cachedUser;
  
  User? get currentUser {
    _cachedUser ??= AuthService().currentUser;
    return _cachedUser;
  }
  
  void clearCache() {
    _cachedUser = null;
  }
}
```

## Troubleshooting

### Sign-in Not Working

1. Check `.env` file has correct credentials
2. Verify Supabase project is active
3. Check email provider settings in Supabase
4. Ensure network connectivity

### Google Sign-in Failing

1. Verify SHA-1 fingerprint matches Firebase
2. Check Google OAuth consent screen
3. Verify Google credentials in `.env`

### Tests Failing

1. Mock AuthService in unit tests
2. Create test fixtures for users
3. Use `mockito` package for mocking

## Next Steps

1. ✅ Review the authentication implementation
2. ✅ Test sign-in and sign-up flows
3. ✅ Configure email and social providers in Supabase
4. ✅ Add password reset functionality (ready in AuthService)
5. ✅ Implement user profile page
6. ✅ Add two-factor authentication
7. ✅ Set up analytics tracking

## Support Resources

- [Supabase Auth Documentation](https://supabase.com/docs/guides/auth)
- [Flutter Documentation](https://flutter.dev/docs)
- [Material Design 3](https://m3.material.io/)
- [Dart Documentation](https://dart.dev/guides)

---

**Need Help?**
Check the authenticaton flow in `AuthWrapper` to understand how pages are switched based on auth state.
