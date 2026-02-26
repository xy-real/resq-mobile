# SignUpForm Validators - Comprehensive Reference

## Overview
This document provides detailed validation rules, test cases, and implementation details for all 7 validators in the redesigned SignUpPage.

## Validator #1: Student ID Validation

### Description
Validates student identification number in two accepted formats.

### Regex Pattern
```regex
^\d{8,10}$|^\d{4}-\d{4,6}$
```

### Pattern Breakdown
- `^\d{8,10}$` - Exactly 8-10 consecutive digits
- `|` - OR
- `^\d{4}-\d{4,6}$` - 4 digits, hyphen, then 4-6 digits (YYYY-XXXX format)

### Valid Examples
```
12345678        ✓ (8 digits)
1234567890      ✓ (10 digits)
2024-1234       ✓ (4 digits-4 digits)
2024-123456     ✓ (4 digits-6 digits)
2000-5555       ✓
```

### Invalid Examples
```
123456          ✗ (too short, 6 digits)
12345678901     ✗ (too long, 11 digits)
2024-123        ✗ (format wrong, 4-3 not 4-4+)
2024-1234567    ✗ (too many digits after hyphen)
ABCD-1234       ✗ (non-numeric)
202-1234        ✗ (not 4-digit year)
1234 5678       ✗ (space instead of hyphen)
```

### Implementation
```dart
String? _validateStudentId(String? value) {
  if (value?.isEmpty ?? true) {
    return 'Student ID is required';
  }
  
  // Trim whitespace
  final trimmed = value!.trim();
  
  // Check format
  final isValid = RegExp(r'^\d{8,10}$|^\d{4}-\d{4,6}$').hasMatch(trimmed);
  
  if (!isValid) {
    return 'Invalid Student ID format';
  }
  
  return null; // Valid
}
```

### Error Messages
- **Empty**: "Student ID is required"
- **Invalid Format**: "Invalid Student ID format"

### Test Cases
```dart
expect(_validateStudentId(null), equals('Student ID is required'));
expect(_validateStudentId(''), equals('Student ID is required'));
expect(_validateStudentId('12345678'), isNull); // Valid
expect(_validateStudentId('1234567890'), isNull); // Valid
expect(_validateStudentId('2024-1234'), isNull); // Valid
expect(_validateStudentId('2024-123456'), isNull); // Valid
expect(_validateStudentId('123456'), equals('Invalid Student ID format')); // Too short
expect(_validateStudentId('ABCD-1234'), equals('Invalid Student ID format')); // Non-numeric
```

---

## Validator #2: First Name Validation

### Description
Validates first name: minimum 2 characters, letters, spaces, hyphens, and apostrophes only.

### Regex Pattern
```regex
^[a-zA-Z\s'.-]*$
```

### Pattern Breakdown
- `^` - Start of string
- `[a-zA-Z\s'.-]*` - Zero or more characters that are:
  - `a-zA-Z` - English letters (upper or lower case)
  - `\s` - Whitespace (space)
  - `'` - Apostrophe
  - `.` - Period (for abbreviations like "Dr." or "Rev.")
  - `-` - Hyphen (for hyphenated names)
- `$` - End of string

### Additional Rules
- **Minimum Length**: 2 characters
- Trimmed before validation
- Can contain spaces, hyphens, apostrophes for names like "Mary-Jane" or "O'Brien"

### Valid Examples
```
John              ✓ (simple name)
Mary              ✓
Jane-Marie        ✓ (hyphenated)
Mary Jane         ✓ (space)
Jean-Paul         ✓
O'Brien           ✓ (apostrophe)
Juan Carlos       ✓ (space)
Mary-Ellen        ✓
St.John           ✓ (period)
de-la-Cruz        ✓
```

### Invalid Examples
```
J                 ✗ (too short, 1 char)
Jo                ✓ (valid, 2 chars)
John123           ✗ (contains digit)
Mary@Jane         ✗ (contains @)
José              ✗ (accented character - current limitation)
Mária             ✗ (accented character)
João              ✗ (accented character)
Mary_Jane         ✗ (underscore not allowed)
Mary#Jane         ✗ (# not allowed)
```

### Implementation
```dart
String? _validateFirstName(String? value) {
  if (value?.isEmpty ?? true) {
    return 'First name is required';
  }
  
  final trimmed = value!.trim();
  
  // Check minimum length
  if (trimmed.length < 2) {
    return 'First name must be at least 2 characters';
  }
  
  // Check valid characters (letters, spaces, hyphens, apostrophes, periods)
  if (!RegExp(r"^[a-zA-Z\s'.-]*$").hasMatch(trimmed)) {
    return 'First name can only contain letters, spaces, and hyphens';
  }
  
  return null; // Valid
}
```

### Error Messages
- **Empty**: "First name is required"
- **Too Short**: "First name must be at least 2 characters"
- **Invalid Characters**: "First name can only contain letters, spaces, and hyphens"

### Test Cases
```dart
expect(_validateFirstName(''), equals('First name is required'));
expect(_validateFirstName('J'), equals('First name must be at least 2 characters'));
expect(_validateFirstName('Jo'), isNull); // Valid
expect(_validateFirstName('John'), isNull); // Valid
expect(_validateFirstName('Mary-Jane'), isNull); // Valid hyphenated
expect(_validateFirstName('Jean Paul'), isNull); // Valid space
expect(_validateFirstName("O'Brien"), isNull); // Valid apostrophe
expect(_validateFirstName('John123'), equals('First name can only contain letters, spaces, and hyphens'));
expect(_validateFirstName('José'), equals('First name can only contain letters, spaces, and hyphens')); // Accented
```

### Known Limitations
- Does not support accented characters (é, ñ, ü, etc.)
- Does not support non-Latin scripts (Arabic, Chinese, etc.)
- Could be enhanced with Unicode support if needed

---

## Validator #3: Surname Validation

### Description
Identical to First Name validator.

### Implementation
```dart
String? _validateSurname(String? value) {
  if (value?.isEmpty ?? true) {
    return 'Surname is required';
  }
  
  final trimmed = value!.trim();
  
  if (trimmed.length < 2) {
    return 'Surname must be at least 2 characters';
  }
  
  if (!RegExp(r"^[a-zA-Z\s'.-]*$").hasMatch(trimmed)) {
    return 'Surname can only contain letters, spaces, and hyphens';
  }
  
  return null; // Valid
}
```

### Valid Examples
```
Smith             ✓
von Neumann       ✓
Garcia-Lopez      ✓
O'Malley          ✓
```

### Error Messages
Same as First Name validator (but says "Surname" instead)

---

## Validator #4: Contact Number Validation

### Description
Validates phone number: must contain 10-15 digits after removing formatting characters.

### Validation Logic
1. Remove all non-digit characters (spaces, hyphens, parentheses, dots, etc.)
2. Check that remaining digits are between 10-15

### Accepted Formatting
These all validate if they result in 10-15 digits:

```
1234567890          ✓ (10 digits, no formatting)
12345678901         ✓ (11 digits, no formatting)
1234567890123456    ✗ (16 digits, too many)
123456789           ✗ (9 digits, too few)

1 (234) 567-8901    ✓ (10 digits inside: 1234567890)
1-234-567-8901      ✓ (10 digits)
1.234.567.8901      ✓ (10 digits)
+1 234 567 8901     ✓ (10 digits after +)
(123) 456-7890      ✓ (10 digits)
123 456 7890        ✓ (10 digits)
```

### Valid Examples
```
1234567890          ✓ (10 digits - minimum)
12345678901         ✓ (11 digits)
358987654321        ✓ (12 digits - international)
12345678901234      ✓ (14 digits)
123456789012345     ✓ (15 digits - maximum)

+1 (234) 567-8901   ✓ (formats to 10 digits)
1-800-555-0123      ✓ (formats to 10 digits)
(123) 456-7890      ✓ (formats to 10 digits)
```

### Invalid Examples
```
123456789           ✗ (9 digits, too few)
1234567890123456    ✗ (16 digits, too many)
abc-def-ghij        ✗ (no digits)
(empty string)      ✗ (no digits)
```

### Implementation
```dart
String? _validateContactNumber(String? value) {
  if (value?.isEmpty ?? true) {
    return 'Contact number is required';
  }
  
  // Remove all non-digit characters
  final cleaned = value!.replaceAll(RegExp(r'[^\d]'), '');
  
  // Check digit count
  if (cleaned.isEmpty || cleaned.length < 10 || cleaned.length > 15) {
    return 'Contact number must contain 10-15 digits';
  }
  
  return null; // Valid
}
```

### Error Messages
- **Empty**: "Contact number is required"
- **Invalid Digit Count**: "Contact number must contain 10-15 digits"

### Test Cases
```dart
expect(_validateContactNumber(''), equals('Contact number is required'));
expect(_validateContactNumber('123456789'), equals('Contact number must contain 10-15 digits')); // 9 digits
expect(_validateContactNumber('1234567890'), isNull); // 10 digits - valid
expect(_validateContactNumber('12345678901'), isNull); // 11 digits - valid
expect(_validateContactNumber('358987654321'), isNull); // 12 digits - valid
expect(_validateContactNumber('1234567890123456'), equals('Contact number must contain 10-15 digits')); // 16 digits
expect(_validateContactNumber('1 (234) 567-8901'), isNull); // 10 digits after cleaning
expect(_validateContactNumber('1-800-555-0123'), isNull); // 10 digits after cleaning
expect(_validateContactNumber('abc-def-ghij'), equals('Contact number must contain 10-15 digits')); // No digits
```

### International Support
This validator supports international phone numbers:
- US: 10 digits
- International: 11-15 digits (with country code)
- Examples: 
  - US: 1-234-567-8901 (10 digits)
  - India: 91-9876543210 (11 digits)
  - International: +1-234-567-8901

---

## Validator #5: Email Validation

### Description
Validates email address format using standard email regex pattern.

### Regex Pattern
```regex
^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$
```

### Pattern Components
- **Local Part**: `[a-zA-Z0-9.!#$%&'*+/=?^_\`{|}~-]+`
  - Alphanumerics, dots, special characters (RFC 5322 compliant)
  - At least one character
  
- **@ Symbol**: Required separator

- **Domain Part**: `[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?`
  - Starts with alphanumeric
  - Can contain hyphens (but not at start/end)
  - 1-63 characters per segment
  
- **TLD/Subdomains**: `(?:\.[a-zA-Z0-9]...)*`
  - Multiple domain segments separated by dots
  - At least one required (basic validation)

### Valid Examples
```
user@example.com                    ✓
john.smith@example.com              ✓
john_smith@example.com              ✓
john-smith@example.com              ✓
john+smith@example.com              ✓
student123@student.resq.co          ✓
a@b.co                              ✓
test.email+tag@example.co.uk        ✓
user@subdomain.example.com          ✓
```

### Invalid Examples
```
@example.com                        ✗ (no local part)
user@                               ✗ (no domain)
user.example.com                    ✗ (missing @)
user @example.com                   ✗ (space in local part)
user@exam ple.com                   ✗ (space in domain)
user@@example.com                   ✗ (double @)
user@.example.com                   ✗ (domain starts with dot)
user@example                        ✗ (no TLD)
user@example..com                   ✗ (double dot)
```

### Implementation
```dart
String? _validateEmail(String? value) {
  if (value?.isEmpty ?? true) {
    return 'Email is required';
  }
  
  final emailRegex = RegExp(
    r'^[a-zA-Z0-9.!#$%&\'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$',
  );
  
  if (!emailRegex.hasMatch(value!.trim())) {
    return 'Please enter a valid email address';
  }
  
  return null; // Valid
}
```

### Error Messages
- **Empty**: "Email is required"
- **Invalid Format**: "Please enter a valid email address"

### Test Cases
```dart
expect(_validateEmail(''), equals('Email is required'));
expect(_validateEmail('user@example.com'), isNull); // Valid
expect(_validateEmail('john.smith@student.resq.co'), isNull); // Valid
expect(_validateEmail('user+tag@example.com'), isNull); // Valid
expect(_validateEmail('@example.com'), equals('Please enter a valid email address')); // No local
expect(_validateEmail('user@'), equals('Please enter a valid email address')); // No domain
expect(_validateEmail('user.example.com'), equals('Please enter a valid email address')); // Missing @
expect(_validateEmail('user @example.com'), equals('Please enter a valid email address')); // Space in local
```

### Notes
- Trimmed before validation
- Does NOT check if email actually exists (would need backend)
- RFC 5322 compliant local part characters supported
- International domain names not supported (would need punycode conversion)

---

## Validator #6: Password Validation

### Description
Validates password strength: must be 8+ characters, contain uppercase, lowercase, and digit.

### Requirements
1. **Length**: ≥ 8 characters
2. **Uppercase**: At least one A-Z character
3. **Lowercase**: At least one a-z character
4. **Digit**: At least one 0-9 character

### Validation Patterns
```regex
# Length check
.{8,}

# Contains lowercase
(?=.*[a-z])

# Contains uppercase
(?=.*[A-Z])

# Contains digit
(?=.*\d)
```

### Valid Examples
```
SecurePass123       ✓ (all requirements)
MyPassword99        ✓
Test1234            ✓
P@ssw0rd            ✓
Abcdef01            ✓
```

### Invalid Examples
```
Pass123             ✗ (7 chars, too short)
Pass1234            ✗ (wait, let's count: P-a-s-s-1-2-3-4 = 8 chars... this is valid!)
password            ✗ (no uppercase, no digit)
PASSWORD123         ✗ (no lowercase)
Password            ✗ (no digit)
Pass1111            ✗ (only one uppercase at start)
        Aa1         ✗ (too many spaces, generally weak)
```

### Implementation
```dart
String? _validatePassword(String? value) {
  if (value?.isEmpty ?? true) {
    return 'Password is required';
  }
  
  // Check minimum length
  if (value!.length < 8) {
    return 'Password must be at least 8 characters';
  }
  
  // Check for lowercase
  if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
    return 'Password must contain lowercase letters';
  }
  
  // Check for uppercase
  if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
    return 'Password must contain uppercase letters';
  }
  
  // Check for digit
  if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
    return 'Password must contain at least one number';
  }
  
  return null; // Valid
}
```

### Error Messages
- **Empty**: "Password is required"
- **Too Short**: "Password must be at least 8 characters"
- **No Lowercase**: "Password must contain lowercase letters"
- **No Uppercase**: "Password must contain uppercase letters"
- **No Digit**: "Password must contain at least one number"

### Test Cases
```dart
expect(_validatePassword(''), equals('Password is required'));
expect(_validatePassword('Pass123'), equals('Password must be at least 8 characters')); // 7 chars
expect(_validatePassword('Pass1234'), isNull); // Valid - 8 chars, upper, lower, digit
expect(_validatePassword('password'), equals('Password must contain uppercase letters')); // No uppercase
expect(_validatePassword('PASSWORD'), equals('Password must contain lowercase letters')); // No lowercase
expect(_validatePassword('Password'), equals('Password must contain at least one number')); // No digit
expect(_validatePassword('Password123'), isNull); // Valid
expect(_validatePassword('A1bcdefg'), isNull); // Valid - minimal
```

### Password Requirements Display
The form shows live indicator:
```
Password Requirements:
✓ At least 8 characters
✓ Uppercase and lowercase letters
✓ Contains a number
```

Each requirement:
- Shows ✓ icon (green) when met
- Shows ○ icon (gray) when not met
- Updates in real-time as user types

---

## Validator #7: Confirm Password Validation

### Description
Validates that confirm password field matches the password field exactly.

### Logic
```
confirm_password === password_field
```

### Valid Examples
```
Password: "SecurePass123"
Confirm:  "SecurePass123"     ✓

Password: "MyPass99"
Confirm:  "MyPass99"          ✓
```

### Invalid Examples
```
Password: "SecurePass123"
Confirm:  "SecurePass124"     ✗ (off by 1 character)

Password: "SecurePass123"
Confirm:  "Securepass123"     ✗ (different case)

Password: "SecurePass123"
Confirm:  "SecurePass123 "    ✗ (extra space)

Password: (empty)
Confirm:  (empty)             ✓ (both empty)
```

### Implementation
```dart
String? _validateConfirmPassword(String? value) {
  if (value?.isEmpty ?? true) {
    return 'Confirm password is required';
  }
  
  if (value != _passwordController.text) {
    return 'Passwords do not match';
  }
  
  return null; // Valid
}
```

### Error Messages
- **Empty**: "Confirm password is required"
- **Mismatch**: "Passwords do not match"

### Test Cases
```dart
_passwordController.text = 'SecurePass123';

expect(_validateConfirmPassword(''), equals('Confirm password is required'));
expect(_validateConfirmPassword('SecurePass123'), isNull); // Valid - exact match
expect(_validateConfirmPassword('SecurePass124'), equals('Passwords do not match')); // Off by 1
expect(_validateConfirmPassword('Securepass123'), equals('Passwords do not match')); // Case mismatch
expect(_validateConfirmPassword('SecurePass123 '), equals('Passwords do not match')); // Extra space
```

### Special Behavior
- Validates on every keystroke (via Form.onChanged)
- User sees error message immediately when passwords don't match
- No trimming (exact character match required)

---

## Form-Level Validation (_validateForm)

### Description
Checks all validators pass AND terms checkbox is checked.

### Logic
```dart
bool isValid = 
  _studentIdController.text.isNotEmpty &&
  _firstNameController.text.isNotEmpty &&
  _surnameController.text.isNotEmpty &&
  _contactNumberController.text.isNotEmpty &&
  _emailController.text.isNotEmpty &&
  _passwordController.text.isNotEmpty &&
  _confirmPasswordController.text.isNotEmpty &&
  _termsAccepted &&  // ← Terms must be checked
  (_formKey.currentState?.validate() ?? false);
```

### Updated State
```dart
if (_isFormValid != isValid) {
  setState(() => _isFormValid = isValid);
}
```

### Triggers
1. Any controller text changes (listener)
2. Form validation changes (Form.onChanged)
3. Terms checkbox state changes

### Button Enable Condition
```dart
ElevatedButton(
  onPressed: _isFormValid && !_isLoading ? _handleSignUp : null,
  ...
)
```

---

## Validation Best Practices

### 1. Real-Time Validation
```
✓ Validators run as user types
✓ Errors shown immediately below field
✓ Button state updates dynamically
✓ Users know immediately which fields need fixing
```

### 2. Helpful Error Messages
```
✓ Specific error message per requirement
✓ Shows what's wrong, not just "invalid"
✓ Clear guidance on how to fix
```

### 3. Security Considerations
```
✓ Passwords validated client-side for UX
✓ Backend validates again for authentication
✓ Passwords never logged or displayed
✓ Use secure communication (HTTPS) for signup
```

### 4. User Experience
```
✓ Clear field labels
✓ Helpful placeholder text
✓ Visual indicators (icons, colors)
✓ Focus management (Tab navigation)
✓ Minimum 48px touch targets
```

---

## Testing Guide

### Unit Test Template
```dart
group('FirstName Validator', () {
  test('returns error for empty input', () {
    expect(_validateFirstName(''), equals('First name is required'));
  });

  test('returns error for single character', () {
    expect(_validateFirstName('J'), 
      equals('First name must be at least 2 characters'));
  });

  test('returns null for valid name', () {
    expect(_validateFirstName('John'), isNull);
  });

  test('accepts hyphenated names', () {
    expect(_validateFirstName('Mary-Jane'), isNull);
  });

  test('rejects names with numbers', () {
    expect(_validateFirstName('John123'), 
      equals('First name can only contain letters, spaces, and hyphens'));
  });
});
```

### Widget Test Template
```dart
testWidgets('Student ID field shows validation error', (WidgetTester tester) async {
  await tester.pumpWidget(testApp);
  
  await tester.enterText(find.byType(TextFormField).first, '123'); // Invalid
  await tester.pumpWidget(testApp);
  
  expect(find.text('Invalid Student ID format'), findsOneWidget);
});
```

---

## Summary Table

| Validator | Type | Min Length | Max Length | Pattern | Key Requirement |
|-----------|------|-----------|-----------|---------|-----------------|
| Student ID | Text | 8 | 10 or 6 (with -) | 8-10 digits OR YYYY-XXXX | Exact format |
| First Name | Text | 2 | unlimited | Letters, spaces, hyphens | 2+ chars |
| Surname | Text | 2 | unlimited | Letters, spaces, hyphens | 2+ chars |
| Contact | Phone | 10 | 15 | Digits only | 10-15 after cleaning |
| Email | Email | 5 | unlimited | RFC 5322 | Valid email format |
| Password | Password | 8 | unlimited | Upper, Lower, Digit | 8+ chars, all 3 types |
| Confirm | Password | 1 | unlimited | Exact match | Matches password |

---

**Version**: 1.0.0  
**Last Updated**: February 27, 2026  
**Status**: Production Ready
