import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../utils/profile_validation.dart';

class CompleteProfilePage extends StatefulWidget {
  final String? googleEmail;

  const CompleteProfilePage({
    super.key,
    this.googleEmail,
  });

  @override
  State<CompleteProfilePage> createState() => _CompleteProfilePageState();
}

class _CompleteProfilePageState extends State<CompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  late final TextEditingController _studentIdController;
  late final TextEditingController _firstNameController;
  late final TextEditingController _surnameController;
  late final TextEditingController _middleInitialController;
  late final TextEditingController _extensionController;
  late final TextEditingController _emailController;
  late final TextEditingController _contactNumberController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _showPassword = false;
  bool _showConfirmPassword = false;
  bool _agreedToTerms = false;

  @override
  void initState() {
    super.initState();
    _studentIdController = TextEditingController();
    _firstNameController = TextEditingController();
    _surnameController = TextEditingController();
    _middleInitialController = TextEditingController();
    _extensionController = TextEditingController();
    _emailController = TextEditingController(text: widget.googleEmail ?? '');
    _contactNumberController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();

    // Load draft profile if exists
    _loadDraftProfile();
  }

  void _loadDraftProfile() {
    final authNotifier = context.read<AuthNotifier>();
    if (authNotifier.profile != null) {
      final profile = authNotifier.profile!;
      _studentIdController.text = profile.studentId;
      _firstNameController.text = profile.firstName;
      _surnameController.text = profile.surname;
      _middleInitialController.text = profile.middleInitial ?? '';
      _extensionController.text = profile.extension ?? '';
      _contactNumberController.text = profile.contactNumber;
    }
  }

  @override
  void dispose() {
    _studentIdController.dispose();
    _firstNameController.dispose();
    _surnameController.dispose();
    _middleInitialController.dispose();
    _extensionController.dispose();
    _emailController.dispose();
    _contactNumberController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  bool _isFormValid() {
    return (_formKey.currentState?.validate() ?? false) && _agreedToTerms;
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please agree to the terms and conditions'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    final profile = UserProfile(
      studentId: _studentIdController.text.trim(),
      firstName: _firstNameController.text.trim(),
      surname: _surnameController.text.trim(),
      middleInitial: _middleInitialController.text.trim().isEmpty
          ? null
          : _middleInitialController.text.trim(),
      extension: _extensionController.text.trim().isEmpty
          ? null
          : _extensionController.text.trim(),
      email: _emailController.text.trim(),
      contactNumber: _contactNumberController.text.trim(),
    );

    try {
      final authNotifier = context.read<AuthNotifier>();
      await authNotifier.submitProfile(profile);
      
      if (mounted) {
        // Check if submission was successful by verifying there's no error
        if (authNotifier.error != null) {
          // Error occurred during submission - error is already displayed in error container
          // Show snackbar to alert user
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(authNotifier.error!),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        } else {
          // Submission succeeded - show success and navigation will happen automatically
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile completed successfully! Redirecting...'),
              backgroundColor: AppTheme.statusSafe,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _saveDraft() {
    try {
      final profile = UserProfile(
        studentId: _studentIdController.text.trim(),
        firstName: _firstNameController.text.trim(),
        surname: _surnameController.text.trim(),
        middleInitial: _middleInitialController.text.trim().isEmpty
            ? null
            : _middleInitialController.text.trim(),
        extension: _extensionController.text.trim().isEmpty
            ? null
            : _extensionController.text.trim(),
        email: _emailController.text.trim(),
        contactNumber: _contactNumberController.text.trim(),
      );

      final authNotifier = context.read<AuthNotifier>();
      authNotifier.saveDraftProfile(profile);
    } catch (e) {
      debugPrint('Error saving draft: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) async {
        // Save draft before leaving
        _saveDraft();
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppTheme.backgroundDark,
          leading: const SizedBox.shrink(),
          automaticallyImplyLeading: false,
        ),
        body: Consumer<AuthNotifier>(
          builder: (context, authNotifier, child) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacing16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      'Complete Your Profile',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    Text(
                      'Your email has been verified. Please fill in your details to continue.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing16),

                    // Verified Email Indicator
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing12),
                      decoration: BoxDecoration(
                        color: AppTheme.statusSafe.withValues(alpha: 0.1),
                        border: Border.all(
                          color: AppTheme.statusSafe,
                          width: 1.5,
                        ),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.verified_user,
                            color: AppTheme.statusSafe,
                            size: 20,
                          ),
                          const SizedBox(width: AppTheme.spacing12),
                          Expanded(
                            child: Text(
                              widget.googleEmail ?? 'Google Email',
                              style: const TextStyle(
                                color: AppTheme.statusSafe,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing32),

                    // Error Message
                    if (authNotifier.error != null)
                      Container(
                        padding: const EdgeInsets.all(AppTheme.spacing12),
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundError,
                          border: Border.all(
                            color: AppTheme.errorRed,
                            width: 1.5,
                          ),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppTheme.errorRed,
                              size: 20,
                            ),
                            const SizedBox(width: AppTheme.spacing12),
                            Expanded(
                              child: Text(
                                authNotifier.error!,
                                style: const TextStyle(
                                  color: AppTheme.errorRed,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (authNotifier.error != null)
                      const SizedBox(height: AppTheme.spacing24),

                    // Form
                    Form(
                      key: _formKey,
                      onChanged: _saveDraft,
                      child: Column(
                        children: [
                          // Student ID
                          _buildTextField(
                            label: 'Student ID',
                            hint: 'Enter your student ID',
                            controller: _studentIdController,
                            validator: ProfileValidation.validateStudentId,
                            prefixIcon: Icons.badge_outlined,
                          ),
                          const SizedBox(height: AppTheme.spacing20),

                          // First Name
                          _buildTextField(
                            label: 'First Name',
                            hint: 'Enter your first name',
                            controller: _firstNameController,
                            validator: ProfileValidation.validateFirstName,
                            prefixIcon: Icons.person_outlined,
                          ),
                          const SizedBox(height: AppTheme.spacing20),

                          // Surname
                          _buildTextField(
                            label: 'Surname',
                            hint: 'Enter your surname',
                            controller: _surnameController,
                            validator: ProfileValidation.validateSurname,
                            prefixIcon: Icons.person_outlined,
                          ),
                          const SizedBox(height: AppTheme.spacing20),

                          // Middle Initial & Extension (Row)
                          Row(
                            children: [
                              Expanded(
                                flex: 1,
                                child: _buildTextField(
                                  label: 'Middle Initial',
                                  hint: 'M.I.',
                                  controller: _middleInitialController,
                                  validator:
                                      ProfileValidation.validateMiddleInitial,
                                  maxLength: 1,
                                  prefixIcon: Icons.text_fields,
                                ),
                              ),
                              const SizedBox(width: AppTheme.spacing16),
                              Expanded(
                                flex: 2,
                                child: _buildTextField(
                                  label: 'Extension',
                                  hint: 'Jr., Sr., III',
                                  controller: _extensionController,
                                  validator: ProfileValidation.validateExtension,
                                  prefixIcon: Icons.text_fields_outlined,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.spacing20),

                          // Email (Read-only)
                          _buildTextField(
                            label: 'Email Address',
                            hint: 'Verified via Google',
                            controller: _emailController,
                            validator: ProfileValidation.validateEmail,
                            prefixIcon: Icons.email_outlined,
                            readOnly: true,
                            suffixIcon: Icons.verified_user,
                            suffixIconColor: AppTheme.statusSafe,
                          ),
                          const SizedBox(height: AppTheme.spacing20),

                          // Contact Number
                          _buildTextField(
                            label: 'Contact Number',
                            hint: '09xxxxxxxxx or +639xxxxxxxxx',
                            controller: _contactNumberController,
                            validator: ProfileValidation.validatePhoneNumber,
                            prefixIcon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: AppTheme.spacing20),

                          // Password
                          _buildPasswordField(
                            label: 'Password',
                            hint: 'Create a strong password',
                            controller: _passwordController,
                            isVisible: _showPassword,
                            onVisibilityToggle: () {
                              setState(
                                  () => _showPassword = !_showPassword);
                            },
                            validator: ProfileValidation.validatePassword,
                          ),
                          const SizedBox(height: AppTheme.spacing12),
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacing12),
                            decoration: BoxDecoration(
                              color: AppTheme.surface.withValues(alpha: 0.5),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Text(
                              'Password must be at least 8 characters with at least one uppercase letter and one number',
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacing20),

                          // Confirm Password
                          _buildPasswordField(
                            label: 'Confirm Password',
                            hint: 'Confirm your password',
                            controller: _confirmPasswordController,
                            isVisible: _showConfirmPassword,
                            onVisibilityToggle: () {
                              setState(() =>
                                  _showConfirmPassword = !_showConfirmPassword);
                            },
                            validator: (value) =>
                                ProfileValidation.validatePasswordConfirmation(
                              value,
                              _passwordController.text,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing24),

                    // Terms & Conditions
                    CheckboxListTile(
                      value: _agreedToTerms,
                      onChanged: (value) {
                        setState(() => _agreedToTerms = value ?? false);
                      },
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(
                        'I agree to the Terms of Service and Privacy Policy',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing24),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed:
                            _isFormValid() && !authNotifier.isLoadingProfile
                                ? _handleSubmit
                                : null,
                        child: authNotifier.isLoadingProfile
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              )
                            : const Text('Complete Profile & Continue'),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing24),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FormFieldValidator<String> validator,
    IconData? prefixIcon,
    IconData? suffixIcon,
    Color? suffixIconColor,
    TextInputType keyboardType = TextInputType.text,
    int? maxLength,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          keyboardType: keyboardType,
          maxLength: maxLength,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
            suffixIcon: suffixIcon != null
                ? Icon(suffixIcon, color: suffixIconColor)
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              borderSide: const BorderSide(
                color: AppTheme.border,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            counterText: '',
          ),
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required bool isVisible,
    required VoidCallback onVisibilityToggle,
    required FormFieldValidator<String> validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          obscureText: !isVisible,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outlined),
            suffixIcon: IconButton(
              icon: Icon(
                isVisible ? Icons.visibility : Icons.visibility_off,
                color: AppTheme.textSecondary,
              ),
              onPressed: onVisibilityToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              borderSide: const BorderSide(
                color: AppTheme.border,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
          ),
          style: const TextStyle(
            fontSize: 16,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
