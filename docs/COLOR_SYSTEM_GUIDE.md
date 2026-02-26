# 🎨 ResQ Mobile Color System Guide
**Quick Reference for Developers**

---

## Overview

All colors in ResQ Mobile are centralized in **`lib/theme/app_theme.dart`**. Never use hardcoded color values directly in your components.

---

## Core Color Constants

### Background Colors
```dart
// Page and screen backgrounds
AppTheme.backgroundDark         // Color(0xFF0f172a) - Primary page background

// Surface colors for cards and containers
AppTheme.surface                // Color(0xFF1e293b) - Primary surface
AppTheme.surfaceElevated        // Color(0xFF334155) - Elevated cards
AppTheme.surfaceHighlight       // Color(0xFF475569) - Highlighted surfaces
```

### Text Colors
```dart
AppTheme.textPrimary            // Color(0xFFf1f5f9) - Main text
AppTheme.textSecondary          // Color(0xFF94a3b8) - Helper text
AppTheme.textMuted              // Color(0xFF64748b) - Disabled/muted text
```

### Status Indicator Colors
```dart
AppTheme.statusSafe             // Color(0xFF10b981) - Green (Safe status)
AppTheme.statusNeedsHelp        // Color(0xFFf59e0b) - Amber (Needs Help)
AppTheme.statusCritical         // Color(0xFFef4444) - Red (Critical)
AppTheme.statusEvacuated        // Color(0xFF3b82f6) - Blue (Evacuated)
```

### Primary & Accent Colors
```dart
AppTheme.primary                // Color(0xFF1e3a8a) - Deep Blue (brand)
AppTheme.primaryLight           // Color(0xFF3b82f6) - Lighter blue
AppTheme.accentCyan             // Color(0xFF5b9fc6) - Cyan accent (links, etc.)
```

### Sign In Page Specific
```dart
AppTheme.signInGradientTopStart     // Color(0xFF0f4c6b) - Gradient top
AppTheme.signInGradientBottomEnd    // Color(0xFF0a0e27) - Gradient bottom
AppTheme.buttonGradientStart        // Color(0xFF00d4ff) - Button gradient start
AppTheme.buttonGradientEnd          // Color(0xFF3b82f6) - Button gradient end
```

---

## Usage Examples

### ❌ WRONG - Never do this:
```dart
Container(
  color: const Color(0xFF0f172a),  // ❌ Hardcoded!
  child: Text('Hello'),
)
```

### ✅ CORRECT - Always use theme:
```dart
Container(
  color: AppTheme.backgroundDark,  // ✅ Theme-based!
  child: Text('Hello'),
)
```

---

## Color Usage Patterns

### 1. Page Backgrounds
```dart
// Use ThemeData's scaffoldBackgroundColor (no need to specify)
@override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: AppTheme.backgroundDark,
    ),
    body: SingleChildScrollView(
      child: /* content */,
    ),
  );
}
```

**Result:** Scaffold automatically uses `AppTheme.backgroundDark`

### 2. Card & Container Backgrounds
```dart
Container(
  decoration: BoxDecoration(
    color: AppTheme.surfaceElevated,  // For elevated cards
    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
  ),
  child: /* content */,
)
```

### 3. Text Colors
```dart
Text(
  'Primary text',
  style: TextStyle(color: AppTheme.textPrimary),  // Main content
)

Text(
  'Helper text',
  style: TextStyle(color: AppTheme.textSecondary),  // Subtext/labels
)

Text(
  'Disabled text',
  style: TextStyle(color: AppTheme.textMuted),  // Disabled state
)
```

### 4. Gradients
```dart
// Sign In page gradient
decoration: BoxDecoration(
  gradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      AppTheme.signInGradientTopStart.withValues(alpha: 0.95),
      AppTheme.signInGradientBottomEnd,
    ],
  ),
)

// Button gradient
decoration: BoxDecoration(
  gradient: LinearGradient(
    colors: [
      AppTheme.buttonGradientStart,
      AppTheme.buttonGradientEnd,
    ],
  ),
)
```

### 5. Status Indicators
```dart
// Safe status
Container(
  decoration: BoxDecoration(
    color: AppTheme.statusSafe.withValues(alpha: 0.1),  // Light background
    border: Border.all(color: AppTheme.statusSafe),
  ),
)

// Critical status
Container(
  decoration: BoxDecoration(
    color: AppTheme.backgroundError,  // Dark red background
    border: Border.all(color: AppTheme.statusCritical),
  ),
)
```

### 6. Links & Interactive Elements
```dart
TextButton(
  onPressed: () {},
  child: Text(
    'Tap here',
    style: TextStyle(color: AppTheme.accentCyan),  // Link color
  ),
)

Icon(
  Icons.link,
  color: AppTheme.accentCyan,  // Interactive icon
)
```

---

## Color Transparency

Use `.withValues(alpha: x)` for transparency:

```dart
// 50% transparent
AppTheme.surfaceElevated.withValues(alpha: 0.5)

// 10% tint effect
AppTheme.primary.withValues(alpha: 0.1)
```

---

## Common Mistakes to Avoid

### ❌ Mistake 1: Hardcoded Colors
```dart
// BAD
color: const Color(0xFF0f172a),
```

### ❌ Mistake 2: Using wrong status color
```dart
// BAD - Using green for errors
backgroundColor: AppTheme.statusSafe,  // Wrong!
```

### ❌ Mistake 3: Inconsistent text colors
```dart
// BAD - Mix of colors
Text('Hello', style: TextStyle(color: Color(0xFF94a3b8))),
Text('World', style: TextStyle(color: AppTheme.textSecondary)),
```

---

## Adding New Colors

If you need a new color, **don't add hardcoded values**:

### ❌ DON'T:
```dart
// In your widget
color: const Color(0xFFabcdef),
```

### ✅ DO:
1. Add to `lib/theme/app_theme.dart`:
```dart
static const Color myNewColor = Color(0xFFabcdef);
```

2. Use in your widget:
```dart
color: AppTheme.myNewColor,
```

---

## Color Accessibility

All colors in AppTheme are designed with WCAG AA contrast requirements in mind:

- Text on dark backgrounds: ✓ Sufficient contrast
- Status indicators: ✓ Distinct and clearly visible
- Interactive elements: ✓ Clickable and visible

---

## Theme Inheritance

The Scaffold automatically inherits colors from `ThemeData`:

```dart
// ThemeData configuration in app_theme.dart
ThemeData(
  scaffoldBackgroundColor: backgroundDark,  // All Scaffolds use this
  appBarTheme: AppBarTheme(
    backgroundColor: backgroundDark,
  ),
  // ... more theme properties
)
```

**Result:** You don't need to specify backgroundColor on every Scaffold!

---

## Debugging Colors

If a color looks wrong, check:

1. **Am I using the right constant?**
   - `AppTheme.backgroundDark` vs `AppTheme.surface`
   - Check color definitions in `app_theme.dart`

2. **Is transparency applied?**
   ```dart
   // Check if alpha is unexpected
   AppTheme.statusSafe.withValues(alpha: 0.1)  // Should be 10% opacity
   ```

3. **Is the widget inheriting from theme?**
   - Scaffold backgrounds inherit automatically
   - Other widgets don't inherit color automatically, specify explicitly

4. **Check on the actual device**
   - Colors may look slightly different on different displays
   - Test on device, not just emulator

---

## Color Palette Visual Reference

```
BACKGROUNDS:
┌─────────────────────────────────────────┐
│ Dark Navy:     #0f172a (AppTheme)       │
│ Slate:         #1e293b (AppTheme)       │
│ Light Slate:   #334155 (AppTheme)       │
└─────────────────────────────────────────┘

TEXT:
┌─────────────────────────────────────────┐
│ Primary:       #f1f5f9 (Off-white)      │
│ Secondary:     #94a3b8 (Light gray)    │
│ Muted:         #64748b (Medium gray)   │
└─────────────────────────────────────────┘

STATUS:
┌─────────────────────────────────────────┐
│ Safe:          #10b981 (Green)          │
│ Help:          #f59e0b (Amber)          │
│ Critical:      #ef4444 (Red)            │
│ Evacuated:     #3b82f6 (Blue)           │
└─────────────────────────────────────────┘

ACCENTS:
┌─────────────────────────────────────────┐
│ Primary Blue:  #1e3a8a (Deep)           │
│ Light Blue:    #3b82f6 (Bright)         │
│ Cyan:          #5b9fc6 (Accent)         │
└─────────────────────────────────────────┘
```

---

## Questions?

For more information:
- See `lib/theme/app_theme.dart` for all color definitions
- See `COLOR_CONSISTENCY_AUDIT_REPORT.md` for audit details
- Check example usage in pages: `sign_in_page.dart`, `home_screen.dart`

---

**Last Updated:** February 27, 2026  
**Status:** ✅ Active & Enforced
