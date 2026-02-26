import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/auth_service.dart';
import '../pages/sign_in_page.dart';
import '../pages/sign_up_page.dart';
import '../pages/home_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final AuthService _authService = AuthService();
  bool _showSignUp = false;

  @override
  void initState() {
    super.initState();
  }

  void _toggleAuthView() {
    setState(() {
      _showSignUp = !_showSignUp;
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<AuthState>(
      stream: _authService.authStateStream,
      builder: (context, snapshot) {
        // User is authenticated
        if (_authService.isAuthenticated) {
          return const HomePage();
        }

        // User is not authenticated - show sign in/up pages
        return _showSignUp
            ? SignUpPage(
                onSignInTap: _toggleAuthView,
                onSignUpSuccess: () {
                  // After successful sign up, show sign in page
                  setState(() {
                    _showSignUp = false;
                  });
                },
              )
            : SignInPage(
                onSignUpTap: _toggleAuthView,
                onSignInSuccess: () {
                  // Auth state will automatically update via stream
                },
              );
      },
    );
  }
}
