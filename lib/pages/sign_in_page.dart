import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../theme/app_theme.dart';
import '../widgets/auth_widgets.dart';
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
  
  bool _isLoading = false;
  bool _googleLoading = false;
  final bool _appleLoading = false;
  String? _errorMessage;

  final AuthService _authService = AuthService();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
        widget.onSignInSuccess?.call();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signed in with Google successfully'),
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
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.backgroundDark,
        leading: const SizedBox.shrink(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Text(
                  'Welcome Back',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sign in to your account to continue',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 32),

                // Error Message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.errorRed.withValues(alpha: 0.1),
                      border: Border.all(color: AppTheme.errorRed),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: AppTheme.errorRed),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: AppTheme.errorRed,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (_errorMessage != null) const SizedBox(height: 24),

                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Email Address',
                        hint: 'Enter your email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: Icons.email_outlined,
                        validator: (value) {
                          if (value?.isEmpty ?? true) {
                            return 'Email is required';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value!)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Password',
                        hint: 'Enter your password',
                        controller: _passwordController,
                        isPassword: true,
                        prefixIcon: Icons.lock_outlined,
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
                const SizedBox(height: 12),

                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // Navigate to forgot password
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Forgot Password?',
                      style: TextStyle(
                        color: AppTheme.primaryBlue,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sign In Button
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleSignIn,
                  child: _isLoading
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
                      : const Text('Sign In'),
                ),
                const SizedBox(height: 24),

                // Divider
                const DividerWithText(text: 'Or continue with'),
                const SizedBox(height: 24),

                // Social Sign In Buttons
                SocialButton(
                  label: 'Sign in with Google',
                  icon: Icons.g_mobiledata,
                  isLoading: _googleLoading,
                  onPressed: _handleGoogleSignIn,
                ).build2(context),
                const SizedBox(height: 16),

                SocialButton(
                  label: 'Sign in with Apple',
                  icon: Icons.apple,
                  isLoading: _appleLoading,
                  onPressed: () {
                    // TODO: Implement Apple Sign In
                  },
                ).build2(context),
                const SizedBox(height: 32),

                // Sign Up Link
                AuthLink(
                  text: "Don't have an account?",
                  linkText: 'Sign up',
                  onTap: widget.onSignUpTap,
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
