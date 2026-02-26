# Quick Reference Card

## File Locations

| What | Where |
|------|-------|
| Main App | `lib/main.dart` |
| Theme Colors | `lib/theme/app_theme.dart` |
| Auth Logic | `lib/services/auth_service.dart` |
| Sign-In UI | `lib/pages/sign_in_page.dart` |
| Sign-Up UI | `lib/pages/sign_up_page.dart` |
| Home Page | `lib/pages/home_page.dart` |
| Auth Routing | `lib/screens/auth_wrapper.dart` |
| UI Components | `lib/widgets/auth_widgets.dart` |
| Constants | `lib/constants/app_constants.dart` |

## Color Palette Quick Reference

```dart
// Primary Colors
AppTheme.primaryBlue        // #2563eb - Main action color
AppTheme.primaryDark        // #1e3a5f - App bar background
AppTheme.surfaceBlue        // #1e293b - Input fields/cards
AppTheme.backgroundDark     // #0f172a - Screen background

// Status Colors
AppTheme.successGreen       // #10b981 - Success states
AppTheme.errorRed           // #ef4444 - Error states
AppTheme.warningOrange      // #f97316 - Warning states

// Text Colors
AppTheme.textPrimary        // #f1f5f9 - Main text
AppTheme.textSecondary      // #94a3b8 - Secondary text
AppTheme.dividerColor       // #334155 - Dividers/borders
```

## Common Imports

```dart
// Theme
import 'package:resq_mobile/theme/app_theme.dart';

// Services
import 'package:resq_mobile/services/auth_service.dart';

// Pages
import 'package:resq_mobile/pages/sign_in_page.dart';
import 'package:resq_mobile/pages/sign_up_page.dart';
import 'package:resq_mobile/pages/home_page.dart';

// Widgets
import 'package:resq_mobile/widgets/auth_widgets.dart';

// Constants
import 'package:resq_mobile/constants/app_constants.dart';
```

## Quick Code Snippets

### Check if User is Authenticated
```dart
final authService = AuthService();
if (authService.isAuthenticated) {
  // User is logged in
}
```

### Get Current User Email
```dart
final authService = AuthService();
final email = authService.currentUser?.email;
```

### Sign Out User
```dart
final authService = AuthService();
try {
  await authService.signOut();
} catch (e) {
  print('Sign out failed: $e');
}
```

### Listen to Auth Changes
```dart
StreamBuilder<AuthState>(
  stream: AuthService().authStateStream,
  builder: (context, snapshot) {
    // React to auth state changes
  },
)
```

### Show Error Message
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Error message'),
    backgroundColor: AppTheme.errorRed,
  ),
);
```

### Show Success Message
```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: const Text('Success!'),
    backgroundColor: AppTheme.successGreen,
  ),
);
```

## Component Usage

### Custom Text Field
```dart
CustomTextField(
  label: 'Email',
  hint: 'Enter email',
  controller: controller,
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icons.email_outlined,
  validator: (value) => null,
)
```

### Social Button
```dart
SocialButton(
  label: 'Sign in with Google',
  icon: Icons.g_mobiledata,
  isLoading: false,
  onPressed: () {},
).build2(context)
```

### Divider with Text
```dart
DividerWithText(text: 'Or continue with')
```

### Auth Link
```dart
AuthLink(
  text: 'No account?',
  linkText: 'Sign up',
  onTap: () {},
)
```

## Environment Setup

### .env File
```env
SUPABASE_URL=https://xxxxx.supabase.co
SUPABASE_ANON_KEY=xxxxxxxxxxxxx
```

### Add to .gitignore
```
.env
.env.local
```

## Theme Customization

### Change Primary Color
Edit `lib/theme/app_theme.dart`:
```dart
static const Color primaryBlue = Color(0xFF2563eb); // Change this
```

Update in three places:
1. `primaryBlue` constant
2. `primaryColor` in `darkTheme`
3. All usages throughout app

## Running the App

```bash
# Get dependencies
flutter pub get

# Run development
flutter run

# Run release
flutter run --release

# Run on specific device
flutter run -d <device_id>
```

## Debugging

### Print Debug Info
```dart
debugPrint('Auth state: ${AuthService().isAuthenticated}');
debugPrint('User: ${AuthService().currentUser?.email}');
```

### Enable Network Logs
Use Flutter DevTools Network tab to inspect Supabase API calls.

### Check Compilation Errors
```bash
flutter analyze
```

## Common Issues & Solutions

| Issue | Solution |
|-------|----------|
| Google Sign-in fails | Verify SHA-1 in Firebase Console |
| Email auth fails | Check Supabase credentials in .env |
| Can't find widget | Verify import statements |
| Theme not applying | Restart app with `flutter run` |
| Build fails | Run `flutter clean && flutter pub get` |

## Text Styles

```dart
// Display Large - Page titles
Theme.of(context).textTheme.displayLarge

// Headline Small - Section headers
Theme.of(context).textTheme.headlineSmall

// Body Large - Main text
Theme.of(context).textTheme.bodyLarge

// Body Medium - Secondary text
Theme.of(context).textTheme.bodyMedium

// Label Small - Captions
Theme.of(context).textTheme.labelSmall
```

## Spacing Standards

```dart
const double xs = 4;    // Extra small
const double sm = 8;    // Small
const double md = 16;   // Medium
const double lg = 24;   // Large
const double xl = 32;   // Extra large
const double xxl = 48;  // Jumbo

// Usage
SizedBox(height: md)
EdgeInsets.all(lg)
Padding(padding: const EdgeInsets.symmetric(horizontal: lg))
```

## Password Requirements

☑️ Minimum 8 characters
☑️ Uppercase letters
☑️ Lowercase letters
☑️ Numbers

Code:
```dart
String _validatePassword(String? value) {
  if ((value?.length ?? 0) < 8) return 'Min 8 chars';
  if (!RegExp(r'[A-Z]').hasMatch(value!)) return 'Need uppercase';
  if (!RegExp(r'[a-z]').hasMatch(value)) return 'Need lowercase';
  if (!RegExp(r'\d').hasMatch(value)) return 'Need number';
  return null;
}
```

## Status Indicators

```dart
// Success - Green checkmark
Icon(Icons.check_circle, color: AppTheme.successGreen)

// Error - Red X
Icon(Icons.error_outline, color: AppTheme.errorRed)

// Warning - Orange alert
Icon(Icons.warning, color: AppTheme.warningOrange)

// Loading - Spinner
CircularProgressIndicator(
  valueColor: AlwaysStoppedAnimation(AppTheme.primaryBlue),
)
```

## Form Validation Pattern

```dart
final _formKey = GlobalKey<FormState>();

// In build:
Form(
  key: _formKey,
  child: Column(
    children: [
      CustomTextField(
        validator: (value) {
          if (value?.isEmpty ?? true) return 'Required';
          return null;
        },
      ),
    ],
  ),
)

// On submit:
if (!_formKey.currentState!.validate()) return;
// Process form
```

## Documentation References

Quick links to guides:
- System Overview: `IMPLEMENTATION_SUMMARY.md`
- Setup & Config: `AUTHENTICATION.md`
- UI/UX Standards: `DESIGN_GUIDE.md`
- Development: `INTEGRATION_GUIDE.md`

---

**Print this out and keep it handy!** 🖨️
