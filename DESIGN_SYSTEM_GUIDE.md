# Design System Implementation Guide
## Quick Reference for the Redesigned Status Screen

---

## 1. Typography Scale

Use this exact typography for consistency across the app:

### Display/Heading (Section Titles)
```dart
Text(
  'Select Your Status',
  style: const TextStyle(
    fontSize: 20,        // Section headings
    fontWeight: FontWeight.w600,  // Semibold
    color: AppTheme.textPrimary,
    letterSpacing: 0.3,
  ),
)
```
**Usage:** Screen section headers, major headings

### Body Large (Button Labels, Status Text)
```dart
Text(
  'Needs Assistance',
  style: const TextStyle(
    fontSize: 18,        // Primary content
    fontWeight: FontWeight.w600,  // Semibold
    color: AppTheme.textPrimary,
    letterSpacing: 0.3,
  ),
)
```
**Usage:** Status button labels, prominent values

### Body (Standard Text)
```dart
Text(
  'Choose the option that best describes your situation',
  style: const TextStyle(
    fontSize: 14,        // Supporting text
    fontWeight: FontWeight.w400,  // Regular
    color: AppTheme.textSecondary,
    letterSpacing: 0.2,
  ),
)
```
**Usage:** Descriptions, helper text, instructions

### Label (Captions, Field Labels)
```dart
Text(
  'Student ID',
  style: const TextStyle(
    fontSize: 12,        // Small labels
    fontWeight: FontWeight.w500,  // Medium
    color: AppTheme.textSecondary,
    letterSpacing: 0.3,
  ),
)
```
**Usage:** Field labels, captions, metadata headers

### Metadata (Small Tertiary Text)
```dart
Text(
  'Last updated: 5 minutes ago',
  style: const TextStyle(
    fontSize: 12,        // Small secondary
    fontWeight: FontWeight.w400,  // Regular
    color: AppTheme.textMuted,
    letterSpacing: 0.2,
  ),
)
```
**Usage:** Timestamps, status badges, muted information

---

## 2. Spacing System (8pt Base Unit)

Always use multiples of 8 for consistency:

```dart
// Base unit
const double spacing8 = 8.0;

// Derived values (already in AppTheme)
const double spacing4 = 4.0;    // Half unit (micro-spacing)
const double spacing12 = 12.0;  // 1.5x spacing
const double spacing16 = 16.0;  // 2x spacing (primary)
const double spacing20 = 20.0;  // 2.5x spacing (cards)
const double spacing24 = 24.0;  // 3x spacing (sections)
const double spacing32 = 32.0;  // 4x spacing (major sections)
```

### Common Spacing Patterns

**Between buttons:**
```dart
const SizedBox(height: 12)  // Gap between status buttons
```

**Card padding:**
```dart
padding: const EdgeInsets.symmetric(
  horizontal: 20,  // spacing20
  vertical: 16,    // spacing16
)
```

**Section spacing:**
```dart
const SizedBox(height: AppTheme.spacing24)  // Between header and buttons
```

**Field spacing:**
```dart
const SizedBox(height: 8)  // Between label and input
```

---

## 3. Shadow System

### Soft Elevation (Subtle, Inactive)
```dart
boxShadow: [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.08),  // 8% opacity
    blurRadius: 4,
    offset: const Offset(0, 1),
  ),
],
```
**Usage:** Inactive buttons, default card states

### Standard Elevation (Visible, Active/Highlighted)
```dart
boxShadow: [
  BoxShadow(
    color: widget.statusColor.withValues(alpha: 0.12),  // 12% opacity
    blurRadius: 8,
    offset: const Offset(0, 2),
  ),
],
```
**Usage:** Active buttons, focused cards

### No Glow/Spread
❌ **NEVER use:**
```dart
// ❌ DO NOT DO THIS
spreadRadius: 2,                    // Creates bloat effect
color: ...withValues(alpha: 0.25),  // Too bright (glowing)
blurRadius: 16,                     // Too soft
```

---

## 4. Border Radius

### Buttons & Action Elements
```dart
borderRadius: BorderRadius.circular(16)  // Modern, rounded but not circular
```

### Cards & Containers
```dart
borderRadius: BorderRadius.circular(12)  // Standard card radius
```

### Small Elements (Input fields, badges)
```dart
borderRadius: BorderRadius.circular(6)   // Subtle curvature
```

---

## 5. Color Usage

### Status Semantic Colors (No Changes)
```dart
// Status Option Colors (from StatusOption enum)
Color.safe         = Color(0xFF10b981)      // Green
Color.assistance   = Color(0xFff97316)      // Amber
Color.critical     = Color(0xFFef4444)      // Red
Color.evacuated    = Color(0xFF3b82f6)      // Blue

// Always use as semantic meaning:
// - Background for active state
// - Text indicator for inactive state
// - Icon accent for highlighting
```

### Background & Surface Colors
```dart
AppTheme.backgroundDark    = Color(0xFF0f172a)  // Screen background
AppTheme.surfaceElevated   = Color(0xFF334155)  // Card/button background
AppTheme.surfaceBlue       = Color(0xFF1e293b)  // Secondary surfaces
```

### Text Colors (3-tier System)
```dart
AppTheme.textPrimary       = Color(0xFFf1f5f9)  // Main content (20pt+)
AppTheme.textSecondary     = Color(0xFF94a3b8)  // Supporting text (14pt)
AppTheme.textMuted         = Color(0xFF64748b)  // Metadata (12pt)
```

### Color Application Rule
```
For Buttons:
- Inactive: background = surfaceElevated, text = textPrimary
- Active: background = semantic color, text = white
- Disabled: opacity = 0.6

For Cards:
- background = surfaceElevated
- text = textPrimary + textSecondary layers
- metadata = textMuted

For Icons:
- Interactive (active): semantic color
- Inactive: textSecondary or textMuted
- Decorative: very light (0.2 alpha)
```

---

## 6. Button Design Template

### Reference Implementation
```dart
class ModernButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final bool isActive;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 48),  // Accessibility
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),  // Modern radius
        boxShadow: [
          BoxShadow(
            color: isActive 
              ? backgroundColor.withValues(alpha: 0.12)
              : Colors.black.withValues(alpha: 0.08),
            blurRadius: isActive ? 8 : 4,
            offset: const Offset(0, isActive ? 2 : 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.1),
          highlightColor: Colors.white.withValues(alpha: 0.05),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isActive ? Colors.white : AppTheme.textPrimary,
                    letterSpacing: 0.3,
                  ),
                ),
                if (isActive)
                  Icon(Icons.check_rounded, color: Colors.white, size: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## 7. Common Components Spec

### Status Button
```
Height (minimum): 48px
Padding: 16px vertical, 20px horizontal
Border radius: 16px
Font: 18pt, w600
Shadow (inactive): blur 4px, alpha 0.08
Shadow (active): blur 8px, alpha 0.12
Icon: 24px, right-aligned (active only)
States: default, active, loading, disabled
```

### Status Header Card
```
Padding: 20px horizontal, 16px vertical
Border radius: 12px
Shadow: blur 4px, alpha 0.08
Divider: 1px solid, dividerColor
Field label font: 12pt, w500, textSecondary
Field value font: 16pt, w600, textPrimary
Status value font: 18pt, w600, textPrimary
Metadata font: 12pt, w400, textMuted
```

### Section Header
```
Font: 20pt, w600, textPrimary
Letter spacing: 0.3
Below section: gap = spacing20
Subtitle: 14pt, w400, textSecondary (optional)
Icon badge: NO (removed)
```

---

## 8. Accessibility Checklist

When building new components with this design system:

- [ ] Minimum touch target: 48px height/width
- [ ] Minimum text size: 12pt (never smaller)
- [ ] Contrast ratio AAA (21:1 white on color, 14:1 dark text)
- [ ] Color not sole indicator (icon, text, or shape also indicates)
- [ ] No all-caps for long content (use sentence case)
- [ ] Icons have `semanticLabel` for screen readers
- [ ] Focus states visible (inherent with InkWell)
- [ ] No flashing/blinking elements
- [ ] Text scales with system font size setting

---

## 9. Do's and Don'ts

### DO ✓

```dart
// DO: Use semantic colors for meaning
Container(
  color: StatusOption.safe.color,  // Green = safe
  child: Text('Safe', style: TextStyle(color: Colors.white))
)

// DO: Use 8pt spacing multiples
SizedBox(height: AppTheme.spacing16)  // Always multiple of 8

// DO: Single shadow per state
BoxShadow(
  color: Colors.black.withValues(alpha: 0.08),
  blurRadius: 4,
  offset: const Offset(0, 1),
)

// DO: Clear visual hierarchy
Text('Header', style: titleStyle)
Text('Description', style: captionStyle)
Text('Metadata', style: metadataStyle)

// DO: Flat backgrounds
color: AppTheme.surfaceElevated  // Direct color, no gradient

// DO: Readable labels
label: 'Needs Assistance'  // Clear, descriptive

// DO: Multiple state indicators
Icon(...) + Text(...) + Color(...)  // Redundant signals
```

### DON'T ✘

```dart
// ❌ DON'T: Multiple shadow layers
BoxShadow(...),
BoxShadow(...),

// ❌ DON'T: Spread radius
spreadRadius: 2,

// ❌ DON'T: High alpha shadows (glowing)
color: ...withValues(alpha: 0.25)  // Too bright

// ❌ DON'T: Duplicate spacing values
const SizedBox(height: 17)  // Not a multiple of 8

// ❌ DON'T: Gradients on backgrounds
gradient: LinearGradient(...)  // Use flat colors

// ❌ DON'T: ALL CAPS labels
'NEEDS ASSISTANCE'  // Hard to read, wrong tone

// ❌ DON'T: Text-only state indication
'Active'  // Color must be primary indicator

// ❌ DON'T: Small touch targets
height: 40,  // Should be 44+ minimum

// ❌ DON'T: Decorative elements just for looks
badge: Container(...),  // Use only semantic icons

// ❌ DON'T: Mix different border radius values
radius: 12,   // Button
radius: 8,    // Card (be consistent)
```

---

## 10. Responsive Design

### Screen Size Breakpoints
```dart
// Small phones (< 360px)
- Use spacing16 minimum padding
- Full-width buttons
- Single-column layout

// Standard phones (360-600px)
- spacing20 padding (current design)
- Full-width buttons
- Single-column layout

// Tablets (600px+)
- Consider 2-column layouts
- Wider padding (spacing24)
- Maintain button width limits

// Desktop (1200px+)
- Maximum width container (800px)
- Center content
- spacing32 padding
```

### Implementation Pattern
```dart
double getPadding(BuildContext context) {
  final width = MediaQuery.of(context).size.width;
  if (width < 360) return AppTheme.spacing16;
  if (width < 800) return AppTheme.spacing20;
  return AppTheme.spacing24;
}
```

---

## 11. Theme Switching (Dark to Light)

All colors use semantic tokens. To implement light theme:

```dart
// Light theme equivalents
textPrimary_light       = Color(0xFF1a1a1a);     // Dark text
textSecondary_light     = Color(0xFF666666);     // Gray text
textMuted_light         = Color(0xFF999999);     // Light gray

backgroundColor_light   = Color(0xFFfafafa);     // Off-white
surfaceElevated_light   = Color(0xFFf0f0f0);     // Light gray surface

// Status colors remain SAME (semantic - red is always urgent, green is always safe)
```

---

## 12. Code Quality Standards

### Naming Conventions
```dart
// ✓ Clear and purposeful
Container(
  decoration: BoxDecoration(
    color: widget.isActive ? widget.status.color : AppTheme.surfaceElevated,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [BoxShadow(...)],
  ),
)

// ✗ Vague
Container(
  decoration: BoxDecoration(
    color: color1,
    borderRadius: BorderRadius.circular(r1),
    boxShadow: shadows,
  ),
)
```

### Comments for Complex Styling
```dart
// Soft elevation shadow - subtle awareness of button press state
boxShadow: [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.08),
    blurRadius: 4,
    offset: const Offset(0, 1),
  ),
],
```

### Reusable Constants
```dart
// ✓ Extract repeated values
const double _buttonBorderRadius = 16;
const double _cardBorderRadius = 12;
const EdgeInsets _buttonPadding = EdgeInsets.symmetric(horizontal: 20, vertical: 16);

// Use them
borderRadius: BorderRadius.circular(_buttonBorderRadius),
padding: _buttonPadding,
```

---

## 13. Testing & Validation

### Visual Testing Checklist
- [ ] Colors match specification (use color picker)
- [ ] Spacing follows 8pt grid (measure paddings)
- [ ] Shadows are subtle (not glowing)
- [ ] Border radius consistent (16px buttons, 12px cards)
- [ ] Text sizes correct (20pt headers, 18pt buttons)

### Accessibility Testing Checklist
- [ ] Run Lighthouse accessibility audit (target: 95+)
- [ ] Check color contrast with WCAG validator
- [ ] Test with screen reader (VoiceOver/TalkBack)
- [ ] Verify touch target sizes (44px minimum)
- [ ] Test with high font size scaling

### Cross-Device Testing
- [ ] iPhone SE / Small Android (360px)
- [ ] iPhone 12 / Standard Android (375px)
- [ ] iPad / Android Tablet (768px)
- [ ] Landscape orientation
- [ ] Dark mode / Light mode

---

## 14. Animation Guidelines

### Allowed Animations
```dart
// ✓ Subtle state changes
opacity: isLoading ? 1.0 : 0.6
duration: Duration(milliseconds: 200)

// ✓ InkWell ripple (system default)
splashColor: Colors.white.withValues(alpha: 0.1)
highlightColor: Colors.white.withValues(alpha: 0.05)

// ✓ Smooth transition on color change
color: isActive ? statusColor : surfaceColor
duration: Duration(milliseconds: 300)
```

### Avoid Animations
```dart
// ❌ Avoid complex animations in emergency interface
AnimationController with multiple interpolations
Transform.scale() bouncing effects
Rotation animations
Long duration animations (> 500ms)
```

---

## 15. Component Library

### Pre-built Components Using This System
- ✓ StatusButton (status_button.dart)
- ✓ StatusHeader (status_header.dart)
- ✓ SocialButton (auth_widgets.dart) - uses same system

### Extending Components
When creating new components, follow these principles:

1. **Start with AppTheme constants**
2. **Use 8pt spacing multiples**
3. **Apply single soft shadows**
4. **Use 12pt minimum font**
5. **Maintain 48px touch targets**
6. **Avoid gradients and decorative elements**
7. **Test accessibility standards**

---

## Quick Copy-Paste Templates

### Readable Card
```dart
Container(
  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
  decoration: BoxDecoration(
    color: AppTheme.surfaceElevated,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.08),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ],
  ),
  child: // Your content
)
```

### Modern Button
```dart
Container(
  decoration: BoxDecoration(
    color: buttonColor,
    borderRadius: BorderRadius.circular(16),
    boxShadow: [
      BoxShadow(
        color: buttonColor.withValues(alpha: 0.12),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  ),
  child: Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: // Your button content
      ),
    ),
  ),
)
```

### Text Hierarchy
```dart
Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('Label', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.textSecondary)),
    const SizedBox(height: 8),
    Text('Primary Content', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
    const SizedBox(height: 12),
    Text('Supporting text', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: AppTheme.textSecondary)),
  ],
)
```

---

## Version History & Updates

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | Feb 26, 2026 | Initial design system documentation |

## Support & Questions

For questions about the design system or implementation details, refer to:
- [Design Redesign Summary](DESIGN_REDESIGN_SUMMARY.md)
- [Before/After Comparison](DESIGN_BEFORE_AFTER.md)
- [Material Design 3 Documentation](https://m3.material.io)
- [Flutter Best Practices](https://flutter.dev/docs)

---

**Last Updated:** February 26, 2026  
**Design System Version:** 1.0  
**Status:** Ready for Production
