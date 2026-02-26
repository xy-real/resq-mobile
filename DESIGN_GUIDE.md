# Authentication UI Style Guide

## Overview

This style guide ensures consistency in the authentication system and provides guidelines for extending the design system to other parts of the application.

## Color Usage Guide

### Primary Colors

#### Deep Navy (#1e3a5f)
- **Use for**: App bar backgrounds, primary containers
- **Example**: AppBar background, bottom navigation inactive state
- **Accessibility**: AA compliant for white text

#### Primary Blue (#2563eb)
- **Use for**: Primary action buttons, links, focus states
- **Example**: Sign-in button, navigation highlighting
- **Accessibility**: AAA compliant for white text, AA for dark text

#### Surface Blue (#1e293b)
- **Use for**: Input fields, elevated surfaces, cards
- **Example**: Text field backgrounds, dialog surfaces
- **Accessibility**: Better contrast for text overlays

### Secondary Colors

#### Light Blue (#60a5fa)
- **Use for**: Hover states, secondary interactions
- **Example**: Button hover effects, secondary links
- **Accessibility**: AA compliant with dark backgrounds

#### Text Primary (#f1f5f9)
- **Use for**: Primary text content, headlines
- **Example**: Titles, body text, primary labels
- **Accessibility**: AAA contrast ratio with dark backgrounds

#### Text Secondary (#94a3b8)
- **Use for**: Secondary text, hints, disabled states
- **Example**: Helper text, placeholder text, subtext
- **Accessibility**: AA contrast ratio with dark backgrounds

### Status Colors

#### Success Green (#10b981)
- **Use for**: Success states, confirmations, valid inputs
- **Example**: Checkmarks, success messages, valid password indicators

#### Error Red (#ef4444)
- **Use for**: Error states, destructive actions, invalid inputs
- **Example**: Error messages, validation failures, delete buttons

#### Warning Orange (#f97316)
- **Use for**: Warning states, cautions, alerts
- **Example**: Warning messages, important notices

## Typography

### Font Scale

| Style | Size | Weight | Use Case |
|-------|------|--------|----------|
| Display Large | 32px | 700 | Not used in auth pages |
| Display Medium | 28px | 700 | Page titles |
| Headline Small | 20px | 600 | Section headers |
| Title Large | 18px | 600 | Card titles, dialog titles |
| Body Large | 16px | 400 | Primary body text |
| Body Medium | 14px | 400 | Secondary body text, descriptions |
| Label Small | 12px | 500 | Labels, captions |

### Examples

```dart
// Page Title
Text(
  'Welcome Back',
  style: Theme.of(context).textTheme.displayMedium,
)

// Form Label
Text(
  'Email Address',
  style: const TextStyle(
    color: AppTheme.textPrimary,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  ),
)

// Helper Text
Text(
  'Password must contain uppercase and numbers',
  style: Theme.of(context).textTheme.labelSmall,
)
```

## Spacing & Layout

### Standard Spacing Values

```dart
const double spacing4 = 4;   // Extra small
const double spacing8 = 8;   // Small
const double spacing12 = 12; // Medium-small
const double spacing16 = 16; // Medium
const double spacing20 = 20; // Medium-large
const double spacing24 = 24; // Large
const double spacing32 = 32; // Extra large
const double spacing48 = 48; // Jumbo
```

### Padding Guidelines

```dart
// Top-level page padding
const EdgeInsets pagePadding = EdgeInsets.symmetric(horizontal: 24, vertical: 16);

// Input field spacing
const SizedBox fieldSpacing = SizedBox(height: 20);

// Section spacing
const SizedBox sectionSpacing = SizedBox(height: 32);

// Button spacing
const SizedBox buttonSpacing = SizedBox(height: 24);
```

## Component Styling

### Input Fields

```dart
CustomTextField(
  label: 'Email Address',
  hint: 'Enter your email',
  controller: controller,
  keyboardType: TextInputType.emailAddress,
  prefixIcon: Icons.email_outlined,
  validator: (value) {
    if (value?.isEmpty ?? true) {
      return 'Email is required';
    }
    return null;
  },
)
```

**Key Features:**
- Dark background (Surface Blue)
- Focus state shows primary blue border
- Error state shows red border
- Consistent padding: 12px vertical, 16px horizontal
- Icon color: Text Secondary
- Border radius: 8px

### Buttons

#### Elevated Button (Primary Action)
```dart
ElevatedButton(
  onPressed: () {},
  child: const Text('Sign In'),
)
```

**Styling:**
- Background: Primary Blue
- Text: White
- Min height: 48px
- Full width: `double.infinity`
- Border radius: 8px
- Elevation: 2

#### Outlined Button (Secondary Action)
```dart
OutlinedButton(
  onPressed: () {},
  child: const Text('Cancel'),
)
```

**Styling:**
- Border: 1.5px Primary Blue
- Text: Primary Blue
- Min height: 48px
- Border radius: 8px
- No fill color

#### Social Button
```dart
SocialButton(
  label: 'Sign in with Google',
  icon: Icons.g_mobiledata,
  isLoading: false,
  onPressed: () {},
).build2(context)
```

**Styling:**
- Border: 1px Divider Color
- Text: Text Primary
- Height: 48px
- Icon size: 20px
- Loading indicator: Centered spinner

### Text Links

```dart
AuthLink(
  text: 'Don\'t have an account?',
  linkText: 'Sign up',
  onTap: () {},
)
```

**Styling:**
- Main text: Text Secondary
- Link text: Primary Blue with underline
- Font size: 14px

## Dark Mode Best Practices

✅ **Do's:**
- Use text colors from the color palette
- Test contrast ratios (minimum AA)
- Use subtle borders/dividers
- Reserve bright colors for important states
- Maintain consistency across screens

❌ **Don'ts:**
- Use pure white (#FFFFFF)
- Use pure black (#000000)
- Create harsh color contrasts
- Mix different color schemes
- Use secondary colors for primary actions

## Animation Guidelines

### Duration Standards

```dart
// Quick feedback
const Duration quickAnimation = Duration(milliseconds: 200);

// Standard interaction
const Duration standardAnimation = Duration(milliseconds: 400);

// Complex transitions
const Duration slowAnimation = Duration(milliseconds: 800);
```

### Common Patterns

```dart
// Fade transition
AnimatedOpacity(
  opacity: isLoading ? 0.5 : 1.0,
  duration: const Duration(milliseconds: 300),
  child: // widget
)

// Scale transition
ScaleTransition(
  scale: animation,
  child: // widget
)
```

## Error States

### Error Message Box

```dart
Container(
  padding: const EdgeInsets.all(12),
  decoration: BoxDecoration(
    color: AppTheme.errorRed.withOpacity(0.1),
    border: Border.all(color: AppTheme.errorRed),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Row(
    children: [
      const Icon(Icons.error_outline, color: AppTheme.errorRed),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          errorMessage,
          style: const TextStyle(color: AppTheme.errorRed),
        ),
      ),
    ],
  ),
)
```

### Validation Feedback

**Real-time validation indicators:**
- ✓ Green checkmark for valid state
- ○ Outline for incomplete state
- ✗ Red X for invalid state

## Accessibility Checklist

- [ ] Text contrast ratio is at least AA (4.5:1 for normal text)
- [ ] Interactive elements are at least 48x48 dp
- [ ] Focus states are clearly visible
- [ ] Color is not the only means of conveying information
- [ ] Form labels are associated with inputs
- [ ] Error messages are clear and actionable
- [ ] Loading states are properly indicated
- [ ] Touch targets have appropriate spacing

## Responsive Design

### Breakpoints

- **Mobile**: < 600dp
- **Tablet**: 600dp - 1200dp
- **Desktop**: > 1200dp

### Current Focus

The authentication pages are optimized for mobile (< 600dp).

For tablet/desktop extensions, modify:

```dart
// Adapt padding for wider screens
final horizontalPadding = MediaQuery.of(context).size.width > 600 ? 64.0 : 24.0;

// Limit form width for better UX
Container(
  constraints: const BoxConstraints(maxWidth: 400),
  child: // form
)
```

## Component Library

### Available Widgets

1. **CustomTextField**
   - Email validation
   - Password visibility toggle
   - Icon support
   - Error states

2. **SocialButton**
   - Google/Apple preset
   - Loading states
   - Customizable

3. **DividerWithText**
   - Centered text divider
   - Consistent spacing

4. **AuthLink**
   - Clickable link text
   - Navigation support

### Extending Components

```dart
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final Color backgroundColor;
  final Color textColor;

  const CustomButton({
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.backgroundColor = AppTheme.primaryBlue,
    this.textColor = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    // Implementation
  }
}
```

## Testing the Design

### Visual Testing Checklist

- [ ] All text readable on dark background
- [ ] Focus states visible when navigating with keyboard
- [ ] Error messages clearly visible
- [ ] Loading indicators show progress
- [ ] Icons match the color scheme
- [ ] Spacing is consistent
- [ ] Border radius consistent at 8px

### Device Testing

Test on:
- iPhone 12/13/14 (375dp width)
- Samsung Galaxy S20 (360dp width)
- iPad (768dp width)
- Desktop (1920dp width)

## Future Updates

When adding new features to the authentication system:

1. Refer to this guide for color/spacing/typography
2. Use existing components (CustomTextField, etc.)
3. Test contrast ratios and accessibility
4. Verify dark mode appearance
5. Document new components

---

**Version**: 1.0.0
**Last Updated**: February 2026
