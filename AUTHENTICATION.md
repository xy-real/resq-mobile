# Authentication System Documentation

## Overview

This document describes the professional authentication system implemented for the RESQ Mobile app. The system includes sign-in and sign-up pages with a modern dark blue color palette, industry-standard security practices, and comprehensive error handling.

## Project Structure

```
lib/
├── main.dart                          # Application entry point
├── theme/
│   └── app_theme.dart                 # Dark blue theme configuration
├── services/
│   └── auth_service.dart              # Authentication service layer
├── pages/
│   ├── sign_in_page.dart              # Sign-in page UI
│   ├── sign_up_page.dart              # Sign-up page UI
│   └── home_page.dart                 # Home page (post-authentication)
├── screens/
│   └── auth_wrapper.dart              # Authentication state manager
└── widgets/
    └── auth_widgets.dart              # Reusable auth widgets
```

## Color Palette

The app uses a professional dark blue color scheme:

- **Primary Blue**: `#2563eb` - Main action color
- **Deep Navy**: `#1e3a5f` - Primary dark background
- **Surface Blue**: `#1e293b` - Elevated surface
- **Background**: `#0f172a` - Dark background
- **Light Blue**: `#60a5fa` - Interactive elements
- **Success**: `#10b981` - Success states
- **Error**: `#ef4444` - Error states
- **Text Primary**: `#f1f5f9` - Main text
- **Text Secondary**: `#94a3b8` - Secondary text

## Features

### Sign-In Page
- Email/password authentication
- Form validation
- Google Sign-In integration
- Apple Sign-In support (ready for implementation)
- "Forgot Password" link
- Error handling with user-friendly messages
- Loading states
- Navigation to sign-up page

### Sign-Up Page
- Email validation
- Strong password requirements:
  - Minimum 8 characters
  - Uppercase and lowercase letters
  - Numeric characters
- Password confirmation
- Real-time password requirements indicator
- Terms & Conditions acceptance
- Social sign-up options (Google, Apple)
- Error handling
- Navigation to sign-in page

### Authentication Service
- Centralized authentication logic
- Supabase integration
- Google Sign-In support
- Password reset functionality
- Auth state streaming
- Error handling

### Theme System
- Complete dark blue color palette
- Consistent input field styling
- Professional button styles
- Text hierarchy
- Dark mode optimized
- Material Design 3 principles

## Setup Instructions

### 1. Environment Variables
Create a `.env` file in the project root:
```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
```

### 2. Google Sign-In Setup

#### iOS Configuration
1. Add to `ios/Runner/Info.plist`:
```xml
<key>GIDClientID</key>
<string>594868454705-ajffnc43hi4jleoj01mouapoen324gu4.apps.googleusercontent.com</string>
```

#### Android Configuration
1. The Client ID is already configured in the code
2. Ensure your SHA-1 fingerprint is registered in Firebase Console

### 3. Apple Sign-In Setup
- Register Apple Sign-In capability in Xcode
- Configure associated domains
- Add to entitlements file

## Usage

The authentication flow is automatically managed by the `AuthWrapper` widget:

1. **Not Authenticated**: User sees sign-in/sign-up pages
2. **Authenticating**: Loading states show progress
3. **Authenticated**: User sees home page
4. **Error**: User-friendly error messages with recovery options

### Customization

#### Change Color Palette
Edit `lib/theme/app_theme.dart` and update the color constants:
```dart
static const Color primaryBlue = Color(0xFF2563eb); // Change this
```

#### Add Custom Validators
Modify validators in `sign_in_page.dart` or `sign_up_page.dart`:
```dart
validator: (value) {
  // Add your custom validation logic
  return null;
}
```

#### Implement Apple Sign-In
Replace the TODO in both sign-in and sign-up pages:
```dart
onPressed: () {
  // Implement Apple Sign In using sign_in_with_apple package
}
```

## Error Handling

The system includes comprehensive error handling:
- Invalid credentials
- User not found
- Email not confirmed
- Weak passwords
- Network errors
- Sign-in cancellation

Each error is parsed and displayed as a user-friendly message.

## Security Best Practices

✅ **Implemented:**
- Password validation (minimum 8 characters with complexity)
- HTTPS for all network communication
- Secure credential storage via Supabase
- Email verification
- Session management
- CSRF protection via Supabase

✅ **Recommended:**
- Implement rate limiting on authorization endpoints
- Add two-factor authentication (2FA)
- Implement biometric authentication
- Add account lockout after failed attempts
- Monitor suspicious activity

## Dependencies

```yaml
- flutter (SDK)
- flutter_dotenv: ^5.0.2 (Environment variables)
- supabase_flutter: ^1.4.0 (Backend)
- google_sign_in: ^6.2.1 (Google authentication)
- sign_in_with_apple: ^7.0.1 (Apple authentication)
```

## Testing Scenarios

### Test Email Sign-Up
1. Navigate to sign-up page
2. Enter valid email
3. Create strong password
4. Accept terms
5. Verify email in mailbox

### Test Email Sign-In
1. Navigate to sign-in page
2. Enter registered email
3. Enter correct password
4. Verify navigation to home

### Test Social Sign-In
1. Click "Sign in with Google" (or Apple)
2. Complete provider authentication
3. Verify account creation/linking
4. Verify navigation to home

### Test Error Handling
- Invalid email format
- Weak password
- Password mismatch
- Unconfirmed email
- Non-existent account

## Future Enhancements

- [ ] Two-factor authentication (2FA)
- [ ] Biometric authentication (Face ID, Touch ID)
- [ ] Social sign-in with more providers (GitHub, Microsoft)
- [ ] Account recovery customization
- [ ] Profile completion after sign-up
- [ ] Session timeout handling
- [ ] Offline support
- [ ] Advanced analytics integration

## Support & Troubleshooting

### Common Issues

**Google Sign-In Not Working:**
- Verify SHA-1 fingerprint in Firebase Console
- Check Google OAuth credentials
- Ensure internet connectivity

**Apple Sign-In Not Working:**
- Verify Apple Sign-In capability in Xcode
- Check certificate provisioning
- Ensure associated domains configured

**Email Authentication Failing:**
- Verify Supabase credentials in `.env`
- Check email validation rules
- Ensure SMTP is configured in Supabase

### Debug Mode

Enable debug logging:
```dart
// In auth_service.dart
try {
  // Auth operations
} catch (e) {
  debugPrint('Auth Error: $e');
  rethrow;
}
```

## License

This authentication system is part of the RESQ Mobile application.

---

**Version**: 1.0.0
**Last Updated**: February 2026
**Status**: Production Ready
