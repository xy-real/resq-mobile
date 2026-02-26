/// Validation utilities for profile completion form fields
class ProfileValidation {
  /// Validate student ID (must not be empty)
  static String? validateStudentId(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Student ID is required';
    }
    if (value!.length < 3) {
      return 'Student ID must be at least 3 characters';
    }
    if (value.length > 20) {
      return 'Student ID must not exceed 20 characters';
    }
    return null;
  }

  /// Validate first name (must not be empty)
  static String? validateFirstName(String? value) {
    if (value?.isEmpty ?? true) {
      return 'First name is required';
    }
    if (value!.length < 2) {
      return 'First name must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'First name must not exceed 50 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s\-\.']").hasMatch(value)) {
      return 'First name can only contain letters, spaces, hyphens, and apostrophes';
    }
    return null;
  }

  /// Validate surname (must not be empty)
  static String? validateSurname(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Surname is required';
    }
    if (value!.length < 2) {
      return 'Surname must be at least 2 characters';
    }
    if (value.length > 50) {
      return 'Surname must not exceed 50 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s\-\.']").hasMatch(value)) {
      return 'Surname can only contain letters, spaces, hyphens, and apostrophes';
    }
    return null;
  }

  /// Validate middle initial (optional, max 1 character)
  static String? validateMiddleInitial(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    if (value.length > 1) {
      return 'Middle initial must be a single character';
    }
    if (!RegExp(r'^[a-zA-Z]$').hasMatch(value)) {
      return 'Middle initial must be a letter';
    }
    return null;
  }

  /// Validate extension (optional)
  static String? validateExtension(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Optional field
    }
    if (value.length > 10) {
      return 'Extension must not exceed 10 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9\s\-]$').hasMatch(value)) {
      return 'Extension can only contain letters, numbers, spaces, and hyphens';
    }
    return null;
  }

  /// Validate email address
  static String? validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Email is required';
    }
    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(value!)) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate Philippine contact number
  /// Accepts formats: 09xxxxxxxxx, +639xxxxxxxxx, 639xxxxxxxxx, (09)xxxxxxxxx
  static String? validatePhoneNumber(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Contact number is required';
    }
    
    // Remove all non-digit characters except leading +
    String cleaned = value!.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Check if it starts with country code
    if (cleaned.startsWith('+')) {
      // Format: +639xxxxxxxxx
      if (!RegExp(r'^\+639\d{9}$').hasMatch(cleaned)) {
        return 'Contact number must be a valid Philippine number (11 digits)';
      }
    } else if (cleaned.startsWith('63')) {
      // Format: 639xxxxxxxxx
      if (!RegExp(r'^639\d{9}$').hasMatch(cleaned)) {
        return 'Contact number must be a valid Philippine number (11 digits)';
      }
    } else if (cleaned.startsWith('9')) {
      // Format: 9xxxxxxxxx (assumes Philippine)
      if (!RegExp(r'^9\d{9}$').hasMatch(cleaned)) {
        return 'Contact number must be a valid Philippine number (10 digits without country code)';
      }
    } else if (cleaned.startsWith('09')) {
      // Format: 09xxxxxxxxx
      if (!RegExp(r'^09\d{9}$').hasMatch(cleaned)) {
        return 'Contact number must be a valid Philippine number (11 digits)';
      }
    } else {
      return 'Please enter a valid Philippine contact number';
    }
    
    return null;
  }

  /// Validate password
  /// Minimum 8 characters, at least 1 uppercase letter and 1 number
  static String? validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Password is required';
    }
    if (value!.length < 8) {
      return 'Password must be at least 8 characters long';
    }
    if (!RegExp(r'[A-Z]').hasMatch(value)) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!RegExp(r'[0-9]').hasMatch(value)) {
      return 'Password must contain at least one number';
    }
    return null;
  }

  /// Validate password confirmation
  static String? validatePasswordConfirmation(String? value, String? password) {
    if (value?.isEmpty ?? true) {
      return 'Please confirm your password';
    }
    if (value != password) {
      return 'Passwords do not match';
    }
    return null;
  }
}
