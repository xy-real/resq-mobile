import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import '../constants/app_constants.dart';

class SignInPage extends StatefulWidget {
  final VoidCallback onSignUpTap;
  final VoidCallback? onSignInSuccess;

  const SignInPage({
    super.key,
    required this.onSignUpTap,
    this.onSignInSuccess,
  });

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late FocusNode _emailFocus;
  late FocusNode _passwordFocus;

  bool _isLoading = false;
  bool _googleLoading = false;
  // ignore: unused_field
  final bool _facebookLoading = false;
  bool _passwordVisible = false;
  bool _rememberMe = false;
  String? _errorMessage;

  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _clearError() {
    if (_errorMessage != null) {
      setState(() => _errorMessage = null);
    }
  }

  Future<void> _handleSignIn() async {
    _clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      if (mounted) {
        widget.onSignInSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed in successfully'),
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
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    _clearError();
    setState(() => _googleLoading = true);

    try {
      await _authService.signInWithGoogle(
        iosClientId: AppConstants.googleIosClientId,
        webClientId: AppConstants.googleWebClientId,
      );

      if (mounted) {
        // Handle the Google sign-in completion with backend profile check
        // This will determine if the user needs to complete profile or if
        // they already have a student record in the database
        await context.read<AuthNotifier>().handleGoogleSignInComplete();
        widget.onSignInSuccess?.call();
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

  String _parseError(String error) {
    if (error.contains('Invalid login credentials')) {
      return 'Invalid email or password';
    } else if (error.contains('User not found')) {
      return 'No account found with this email';
    } else if (error.contains('Email not confirmed')) {
      return 'Please confirm your email first';
    } else if (error.contains('Sign in cancelled')) {
      return 'Sign in was cancelled';
    }
    return 'An error occurred. Please try again';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.signInGradientTopStart.withValues(alpha: 0.95),
              AppTheme.signInGradientBottomEnd,
            ],
            stops: const [0.0, 1.0],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - 24,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacing20,
                  vertical: AppTheme.spacing24,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                  // ==================== Header ====================
                  const SizedBox(height: AppTheme.spacing16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SvgPicture.asset(
                        'assets/images/logo.svg',
                        height: 50,
                        width: 50,
                        colorFilter: const ColorFilter.mode(
                          Colors.blue,
                          BlendMode.srcIn,
                        ),
                      ),
                      const SizedBox(width: AppTheme.spacing12),
                      Text(
                        'ResQ',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.accentCyan,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1.2,
                          fontSize: 28,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing20),
                  Text(
                    'Log In',
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 32,
                      letterSpacing: -0.5,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // ==================== Error ====================
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing12),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundError.withValues(alpha: 0.8),
                        border: Border.all(
                          color: AppTheme.errorRed,
                          width: 1.5,
                        ),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
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
                              _errorMessage!,
                              style: const TextStyle(
                                color: AppTheme.errorRed,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing24),
                  ],

                  // ==================== Form ====================
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email Field
                        _buildTextField(
                          label: 'Email Address',
                          hint: 'Enter your email',
                          controller: _emailController,
                          focusNode: _emailFocus,
                          nextFocus: _passwordFocus,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Email is required';
                            }
                            if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                .hasMatch(value!.trim())) {
                              return 'Please enter a valid email';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: AppTheme.spacing20),

                        // Password Field
                        _buildTextField(
                          label: 'Password',
                          hint: 'Enter your password',
                          controller: _passwordController,
                          focusNode: _passwordFocus,
                          keyboardType: TextInputType.text,
                          prefixIcon: Icons.lock_outlined,
                          isPassword: true,
                          showPasswordToggle: true,
                          passwordVisible: _passwordVisible,
                          onPasswordVisibilityChanged: (visible) {
                            setState(() => _passwordVisible = visible);
                          },
                          validator: (value) {
                            if (value?.isEmpty ?? true) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),

                  // ==================== Remember Me & Forgot ====================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() => _rememberMe = !_rememberMe);
                        },
                        child: Row(
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: _rememberMe,
                                onChanged: (value) {
                                  setState(() => _rememberMe = value ?? false);
                                },
                                fillColor: WidgetStateProperty.resolveWith(
                                  (states) {
                                    if (states.contains(WidgetState.selected)) {
                                      return AppTheme.accentCyan;
                                    }
                                    return Colors.transparent;
                                  },
                                ),
                                side: BorderSide(
                                  color: _rememberMe
                                      ? AppTheme.accentCyan
                                      : AppTheme.border,
                                  width: 1.5,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing8),
                            Text(
                              'Remember Me',
                              style: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          // Navigate to forgot password
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: const Size(0, 0),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Forgotten Password?',
                          style: TextStyle(
                            color: AppTheme.accentCyan,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // ==================== Log In Button ====================
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.buttonGradientStart,
                          AppTheme.buttonGradientEnd,
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.buttonGradientEnd.withValues(alpha: 0.4),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: _isLoading ? null : _handleSignIn,
                        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacing14),
                          alignment: Alignment.center,
                          child: _isLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Log In',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // ==================== Divider ====================
                  Row(
                    children: [
                      Expanded(
                        child: Divider(
                          color: AppTheme.border.withValues(alpha: 0.5),
                          height: 1,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacing12),
                        child: Text(
                          'Or Log in with',
                          style: TextStyle(
                            color: AppTheme.textSecondary.withValues(alpha: 0.7),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(
                          color: AppTheme.border.withValues(alpha: 0.5),
                          height: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // ==================== Social Buttons ====================
                  _buildSocialButton(
                    label: 'Google',
                    icon: Icons.g_mobiledata,
                    isLoading: _googleLoading,
                    onPressed: _handleGoogleSignIn,
                    imageAsset: 'assets/images/google.png',
                  ),
                  const SizedBox(height: AppTheme.spacing32),

                  // ==================== Sign Up Link ====================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onSignUpTap,
                        child: const Text(
                          'Create Account',
                          style: TextStyle(
                            color: AppTheme.accentCyan,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing16),
                ],
              ),
            ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required FocusNode focusNode,
    FocusNode? nextFocus,
    required TextInputType keyboardType,
    required IconData prefixIcon,
    bool isPassword = false,
    bool showPasswordToggle = false,
    bool passwordVisible = false,
    Function(bool)? onPasswordVisibilityChanged,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: AppTheme.spacing8),
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          keyboardType: keyboardType,
          textInputAction: nextFocus != null ? TextInputAction.next : TextInputAction.done,
          onFieldSubmitted: (_) {
            if (nextFocus != null) {
              FocusScope.of(context).requestFocus(nextFocus);
            }
          },
          obscureText: isPassword && !passwordVisible,
          validator: validator,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontSize: 15,
            fontWeight: FontWeight.w500,
            height: 1.4,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: AppTheme.textSecondary.withValues(alpha: 0.6),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              letterSpacing: 0.2,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: AppTheme.spacing16, right: AppTheme.spacing12),
              child: Icon(
                prefixIcon,
                color: AppTheme.accentCyan,
                size: 20,
              ),
            ),
            suffixIcon: showPasswordToggle
                ? Padding(
                    padding: const EdgeInsets.only(right: AppTheme.spacing12),
                    child: GestureDetector(
                      onTap: () {
                        onPasswordVisibilityChanged?.call(!passwordVisible);
                      },
                      child: Icon(
                        passwordVisible ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                    ),
                  )
                : null,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
              vertical: AppTheme.spacing14,
            ),
            isDense: false,
            constraints: const BoxConstraints(minHeight: AppTheme.spacing48),
            filled: true,
            fillColor: AppTheme.surface.withValues(alpha: 0.3),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              borderSide: BorderSide(
                color: AppTheme.border.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              borderSide: BorderSide(
                color: AppTheme.border.withValues(alpha: 0.3),
                width: 1.2,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              borderSide: const BorderSide(
                color: AppTheme.accentCyan,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              borderSide: const BorderSide(
                color: AppTheme.errorRed,
                width: 1.2,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              borderSide: const BorderSide(
                color: AppTheme.errorRed,
                width: 2,
              ),
            ),
            errorStyle: const TextStyle(
              color: AppTheme.errorRed,
              fontSize: 12,
              fontWeight: FontWeight.w500,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String label,
    required IconData icon,
    required bool isLoading,
    required VoidCallback onPressed,
    String? imageAsset,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.border.withValues(alpha: 0.4),
          width: 1.2,
        ),
        color: AppTheme.surface.withValues(alpha: 0.4),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing16,
              vertical: AppTheme.spacing12,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (!isLoading)
                  Padding(
                    padding: const EdgeInsets.only(right: AppTheme.spacing8),
                    child: imageAsset != null
                        ? Image.asset(
                            imageAsset,
                            height: 20,
                            width: 20,
                          )
                        : Icon(
                            icon,
                            color: AppTheme.accentCyan,
                            size: 20,
                          ),
                  ),
                if (isLoading)
                  Padding(
                    padding: const EdgeInsets.only(right: AppTheme.spacing8),
                    child: SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.accentCyan.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  ),
                Text(
                  isLoading ? 'Signing in...' : label,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
