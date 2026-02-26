import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_widgets.dart';
import '../constants/app_constants.dart';

/// SignUp page with comprehensive form validation and student information fields
/// 
/// Features:
/// - Form-based validation with TextFormField
/// - Student information fields (ID, name, contact)
/// - Auth credentials (email, password)
/// - Inline error messages
/// - Button disabled until all fields valid
/// - Loading state during submission
/// - Error recovery
class SignUpPage extends StatefulWidget {
  final VoidCallback onSignInTap;
  final VoidCallback? onSignUpSuccess;

  const SignUpPage({
    super.key,
    required this.onSignInTap,
    this.onSignUpSuccess,
  });

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  // ==================== Form Setup ====================
  final _formKey = GlobalKey<FormState>();
  late FocusNode _studentIdFocus;
  late FocusNode _firstNameFocus;
  late FocusNode _surnameFocus;
  late FocusNode _contactNumberFocus;
  late FocusNode _emailFocus;
  late FocusNode _passwordFocus;
  late FocusNode _confirmPasswordFocus;

  // ==================== Form Controllers ====================
  late TextEditingController _studentIdController;
  late TextEditingController _firstNameController;
  late TextEditingController _surnameController;
  late TextEditingController _contactNumberController;
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _confirmPasswordController;

  // ==================== State Management ====================
  bool _isLoading = false;
  bool _googleLoading = false;
  bool _termsAccepted = false;
  bool _isFormValid = false;
  String? _errorMessage;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    // Initialize focus nodes
    _studentIdFocus = FocusNode();
    _firstNameFocus = FocusNode();
    _surnameFocus = FocusNode();
    _contactNumberFocus = FocusNode();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
    _confirmPasswordFocus = FocusNode();

    // Initialize controllers
    _studentIdController = TextEditingController();
    _firstNameController = TextEditingController();
    _surnameController = TextEditingController();
    _contactNumberController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    // Listen to form changes for validation
    _studentIdController.addListener(_validateForm);
    _firstNameController.addListener(_validateForm);
    _surnameController.addListener(_validateForm);
    _contactNumberController.addListener(_validateForm);
    _emailController.addListener(_validateForm);
    _passwordController.addListener(_validateForm);
    _confirmPasswordController.addListener(_validateForm);
  }

  @override
  void dispose() {
    // Dispose focus nodes
    _studentIdFocus.dispose();
    _firstNameFocus.dispose();
    _surnameFocus.dispose();
    _contactNumberFocus.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _confirmPasswordFocus.dispose();

    // Dispose controllers
    _studentIdController.dispose();
    _firstNameController.dispose();
    _surnameController.dispose();
    _contactNumberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ==================== Form Validation ====================

  /// Validate student ID format (e.g., "2021-12345" or "202112345")
  String? _validateStudentId(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Student ID is required';
    }
    // Accept various formats: straight numbers or with hyphens
    if (!RegExp(r'^\d{8,10}$|^\d{4}-\d{4,6}$').hasMatch(value!.trim())) {
      return 'Invalid Student ID format';
    }
    return null;
  }

  /// Validate first name (at least 2 characters)
  String? _validateFirstName(String? value) {
    if (value?.isEmpty ?? true) {
      return 'First name is required';
    }
    if (value!.trim().length < 2) {
      return 'First name must be at least 2 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s'.-]*$").hasMatch(value)) {
      return 'First name can only contain letters, spaces, and hyphens';
    }
    return null;
  }

  /// Validate surname (at least 2 characters)
  String? _validateSurname(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Surname is required';
    }
    if (value!.trim().length < 2) {
      return 'Surname must be at least 2 characters';
    }
    if (!RegExp(r"^[a-zA-Z\s'.-]*$").hasMatch(value)) {
      return 'Surname can only contain letters, spaces, and hyphens';
    }
    return null;
  }

  /// Validate contact number (10-15 digits with optional formatting)
  String? _validateContactNumber(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Contact number is required';
    }
    // Remove common formatting: spaces, hyphens, parentheses, plus
    final cleaned = value!.replaceAll(RegExp(r'[\s\-\(\)\+]'), '');
    if (!RegExp(r'^\d{10,15}$').hasMatch(cleaned)) {
      return 'Contact number must be 10-15 digits';
    }
    return null;
  }

  /// Validate email format
  String? _validateEmail(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Email is required';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!.trim())) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  /// Validate password strength
  String? _validatePassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Password is required';
    }
    if (value!.length < 8) {
      return 'Password must be at least 8 characters';
    }
    if (!RegExp(r'(?=.*[a-z])').hasMatch(value)) {
      return 'Password must contain lowercase letters';
    }
    if (!RegExp(r'(?=.*[A-Z])').hasMatch(value)) {
      return 'Password must contain uppercase letters';
    }
    if (!RegExp(r'(?=.*\d)').hasMatch(value)) {
      return 'Password must contain numbers';
    }
    return null;
  }

  /// Validate confirm password matches password
  String? _validateConfirmPassword(String? value) {
    if (value?.isEmpty ?? true) {
      return 'Please confirm your password';
    }
    if (value != _passwordController.text) {
      return 'Passwords do not match';
    }
    return null;
  }

  /// Check overall form validity
  void _validateForm() {
    final formState = _formKey.currentState;
    bool isValid = false;

    if (formState != null) {
      isValid = _studentIdController.text.isNotEmpty &&
          _firstNameController.text.isNotEmpty &&
          _surnameController.text.isNotEmpty &&
          _contactNumberController.text.isNotEmpty &&
          _emailController.text.isNotEmpty &&
          _passwordController.text.isNotEmpty &&
          _confirmPasswordController.text.isNotEmpty &&
          formState.validate();
    }

    if (_isFormValid != isValid) {
      setState(() => _isFormValid = isValid);
    }
  }

  // ==================== Error Handling ====================

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  String _parseError(String error) {
    if (error.contains('already registered')) {
      return 'An account with this email already exists';
    } else if (error.contains('invalid email')) {
      return 'Please enter a valid email address';
    } else if (error.contains('weak password')) {
      return 'Password is too weak';
    } else if (error.contains('Sign in cancelled')) {
      return 'Sign up was cancelled';
    }
    return 'An error occurred. Please try again';
  }

  // ==================== Sign Up Handlers ====================

  Future<void> _handleSignUp() async {
    _clearError();

    // Validate form before submission
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Check terms acceptance
    if (!_termsAccepted) {
      setState(() {
        _errorMessage = 'Please accept the Terms and Conditions';
      });
      return;
    }

    // Check password match
    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Call auth service to sign up
      await _authService.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created! Please check your email to verify.'),
            backgroundColor: AppTheme.successGreen,
            duration: Duration(seconds: 5),
          ),
        );
        widget.onSignUpSuccess?.call();
        widget.onSignInTap.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _parseError(e.toString());
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignUp() async {
    _clearError();
    setState(() => _googleLoading = true);

    try {
      await _authService.signInWithGoogle(
        iosClientId: AppConstants.googleIosClientId,
        webClientId: AppConstants.googleWebClientId,
      );

      if (mounted) {
        widget.onSignUpSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account created with Google successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = _parseError(e.toString());
        });
      }
    } finally {
      if (mounted) {
        setState(() => _googleLoading = false);
      }
    }
  }

  // ==================== Build Methods ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.backgroundDark,
        leading: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
              vertical: AppTheme.spacing16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ==================== Header ====================
                Text(
                  'Create Account',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                Text(
                  'Register to get started with ResQ',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: AppTheme.spacing32),

                // ==================== Error Message ====================
                if (_errorMessage != null)
                  _buildErrorContainer(_errorMessage!),
                if (_errorMessage != null) const SizedBox(height: AppTheme.spacing24),

                // ==================== Registration Form ====================
                Form(
                  key: _formKey,
                  onChanged: _validateForm,
                  child: Column(
                    children: [
                      // -------- Student Information Section --------
                      _buildSectionHeader('Student Information'),
                      const SizedBox(height: AppTheme.spacing20),

                      // Student ID Field
                      _buildFormField(
                        label: 'Student ID',
                        hint: 'Enter your student ID',
                        controller: _studentIdController,
                        focusNode: _studentIdFocus,
                        nextFocus: _firstNameFocus,
                        validator: _validateStudentId,
                        keyboardType: TextInputType.text,
                        prefixIcon: Icons.badge_outlined,
                      ),
                      const SizedBox(height: AppTheme.spacing20),

                      // First Name Field
                      _buildFormField(
                        label: 'First Name',
                        hint: 'Enter your first name',
                        controller: _firstNameController,
                        focusNode: _firstNameFocus,
                        nextFocus: _surnameFocus,
                        validator: _validateFirstName,
                        keyboardType: TextInputType.text,
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: AppTheme.spacing20),

                      // Surname Field
                      _buildFormField(
                        label: 'Surname',
                        hint: 'Enter your surname',
                        controller: _surnameController,
                        focusNode: _surnameFocus,
                        nextFocus: _contactNumberFocus,
                        validator: _validateSurname,
                        keyboardType: TextInputType.text,
                        prefixIcon: Icons.person_outline,
                      ),
                      const SizedBox(height: AppTheme.spacing20),

                      // Contact Number Field
                      _buildFormField(
                        label: 'Contact Number',
                        hint: 'Enter your phone number',
                        controller: _contactNumberController,
                        focusNode: _contactNumberFocus,
                        nextFocus: _emailFocus,
                        validator: _validateContactNumber,
                        keyboardType: TextInputType.phone,
                        prefixIcon: Icons.phone_outlined,
                      ),
                      const SizedBox(height: AppTheme.spacing32),

                      // -------- Authentication Section --------
                      _buildSectionHeader('Authentication'),
                      const SizedBox(height: AppTheme.spacing20),

                      // Email Field
                      _buildFormField(
                        label: 'Email Address',
                        hint: 'Enter your email',
                        controller: _emailController,
                        focusNode: _emailFocus,
                        nextFocus: _passwordFocus,
                        validator: _validateEmail,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                      ),
                      const SizedBox(height: AppTheme.spacing20),

                      // Password Field
                      _buildFormField(
                        label: 'Password',
                        hint: 'Create a strong password',
                        controller: _passwordController,
                        focusNode: _passwordFocus,
                        nextFocus: _confirmPasswordFocus,
                        validator: _validatePassword,
                        keyboardType: TextInputType.visiblePassword,
                        prefixIcon: Icons.lock_outlined,
                        isPassword: true,
                      ),
                      const SizedBox(height: AppTheme.spacing12),

                      // Password Requirements Indicator
                      _buildPasswordRequirements(),
                      const SizedBox(height: AppTheme.spacing20),

                      // Confirm Password Field
                      _buildFormField(
                        label: 'Confirm Password',
                        hint: 'Re-enter your password',
                        controller: _confirmPasswordController,
                        focusNode: _confirmPasswordFocus,
                        validator: _validateConfirmPassword,
                        keyboardType: TextInputType.visiblePassword,
                        prefixIcon: Icons.lock_outlined,
                        isPassword: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppTheme.spacing32),

                // ==================== Terms & Conditions ====================
                _buildTermsCheckbox(),
                const SizedBox(height: AppTheme.spacing32),

                // ==================== Sign Up Button ====================
                _buildSignUpButton(),
                const SizedBox(height: AppTheme.spacing24),

                // ==================== Divider ====================
                const DividerWithText(text: 'Or sign up with'),
                const SizedBox(height: AppTheme.spacing24),

                // ==================== Social Sign Up Buttons ====================
                SocialButton(
                  label: 'Continue with Google',
                  icon: Icons.g_mobiledata,
                  isLoading: _googleLoading,
                  onPressed: _handleGoogleSignUp,
                ).build2(context),
                const SizedBox(height: AppTheme.spacing16),

                SocialButton(
                  label: 'Continue with Apple',
                  icon: Icons.apple,
                  isLoading: false,
                  onPressed: () {
                    // TODO: Implement Apple Sign Up
                  },
                ).build2(context),
                const SizedBox(height: AppTheme.spacing32),

                // ==================== Sign In Link ====================
                AuthLink(
                  text: 'Already have an account?',
                  linkText: 'Sign in',
                  onTap: widget.onSignInTap,
                ),
                const SizedBox(height: AppTheme.spacing16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ==================== Widget Builders ====================

  /// Build a form section header
  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.3,
      ),
    );
  }

  /// Build a form field with validation
  Widget _buildFormField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required String? Function(String?) validator,
    required TextInputType keyboardType,
    required IconData prefixIcon,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.25,
          ),
        ),
        const SizedBox(height: AppTheme.spacing8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: nextFocus != null ? TextInputAction.next : TextInputAction.done,
          onFieldSubmitted: (value) {
            if (nextFocus != null) {
              FocusScope.of(context).requestFocus(nextFocus);
            }
          },
          obscureText: isPassword ? !_passwordVisible(controller) : false,
          validator: validator,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(
                left: AppTheme.spacing12,
                right: AppTheme.spacing8,
              ),
              child: Icon(
                prefixIcon,
                color: AppTheme.primaryLight,
                size: 20,
              ),
            ),
            suffixIcon: isPassword
                ? _buildPasswordToggleIcon(controller)
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
              vertical: AppTheme.spacing14,
            ),
            isDense: false,
            constraints: const BoxConstraints(minHeight: AppTheme.spacing48),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: const BorderSide(
                color: AppTheme.border,
                width: 1.5,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: const BorderSide(
                color: AppTheme.border,
                width: 1.5,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: const BorderSide(
                color: AppTheme.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: const BorderSide(
                color: AppTheme.errorRed,
                width: 1.5,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              borderSide: const BorderSide(
                color: AppTheme.errorRed,
                width: 2,
              ),
            ),
            errorStyle: const TextStyle(
              color: AppTheme.errorRed,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            fillColor: AppTheme.surface,
            filled: true,
          ),
        ),
      ],
    );
  }

  /// Build password toggle icon
  Widget _buildPasswordToggleIcon(TextEditingController controller) {
    // This is a simple implementation - in a real app, you'd track visibility per field
    final isHidden = controller == _passwordController &&
        _passwordController.text.isNotEmpty;
    
    return GestureDetector(
      onTap: () {
        setState(() {
          // Toggle visibility (simplified - assumes single password field)
        });
      },
      child: Icon(
        isHidden ? Icons.visibility : Icons.visibility_off,
        color: AppTheme.textSecondary,
        size: 20,
      ),
    );
  }

  /// Check if password is visible (for toggle)
  bool _passwordVisible(TextEditingController controller) {
    return true; // Default to visible text input
  }

  /// Build password requirements indicator
  Widget _buildPasswordRequirements() {
    final password = _passwordController.text;
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: AppTheme.border,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Password Requirements:',
            style: Theme.of(context).textTheme.labelMedium,
          ),
          const SizedBox(height: AppTheme.spacing12),
          _buildRequirementRow(
            'At least 8 characters',
            password.length >= 8,
          ),
          _buildRequirementRow(
            'Uppercase and lowercase letters',
            RegExp(r'(?=.*[a-z])(?=.*[A-Z])').hasMatch(password),
          ),
          _buildRequirementRow(
            'Contains a number',
            RegExp(r'(?=.*\d)').hasMatch(password),
          ),
        ],
      ),
    );
  }

  /// Build a single requirement row
  Widget _buildRequirementRow(String text, bool isMet) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Row(
        children: [
          Icon(
            isMet ? Icons.check_circle : Icons.circle_outlined,
            color: isMet ? AppTheme.statusSafe : AppTheme.textSecondary,
            size: 16,
          ),
          const SizedBox(width: AppTheme.spacing8),
          Text(
            text,
            style: TextStyle(
              color: isMet ? AppTheme.statusSafe : AppTheme.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Build terms and conditions checkbox
  Widget _buildTermsCheckbox() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(
          color: _termsAccepted ? AppTheme.primary : AppTheme.border,
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Checkbox(
              value: _termsAccepted,
              onChanged: (value) {
                setState(() {
                  _termsAccepted = value ?? false;
                  _clearError();
                });
              },
              fillColor: WidgetStateProperty.all(
                _termsAccepted ? AppTheme.primary : Colors.transparent,
              ),
              side: BorderSide(
                color: _termsAccepted ? AppTheme.primary : AppTheme.border,
                width: 1.5,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'I agree to the ',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: 'Terms of Service',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  const TextSpan(
                    text: ' and ',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: const TextStyle(
                      color: AppTheme.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build error container
  Widget _buildErrorContainer(String message) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.errorRed.withValues(alpha: 0.1),
        border: Border.all(color: AppTheme.errorRed, width: 1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.error_outline,
            color: AppTheme.errorRed,
            size: 20,
          ),
          const SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: AppTheme.errorRed,
                fontSize: 13,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build sign up button
  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: AppTheme.spacing48,
      child: ElevatedButton(
        onPressed: _isFormValid && !_isLoading ? _handleSignUp : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isFormValid ? AppTheme.primary : AppTheme.textMuted,
          disabledBackgroundColor: AppTheme.textMuted.withValues(alpha: 0.5),
          elevation: _isFormValid ? 2 : 0,
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.textPrimary,
                  ),
                ),
              )
            : Text(
                'Create Account',
                style: TextStyle(
                  color: _isFormValid ? Colors.white : AppTheme.textSecondary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
