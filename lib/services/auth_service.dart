import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io' show Platform;

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final SupabaseClient _supabase = Supabase.instance.client;
  late GoogleSignIn _googleSignIn;
  bool _googleSignInInitialized = false;

  factory AuthService() {
    return _instance;
  }

  AuthService._internal();

  // Initialize Google Sign-In with proper credentials
  void _initializeGoogleSignIn({
    required String iosClientId,
    required String webClientId,
  }) {
    if (!_googleSignInInitialized) {
      _googleSignIn = GoogleSignIn(
        clientId: Platform.isIOS ? iosClientId : null,
        serverClientId: webClientId,
        scopes: ['email', 'profile'],
      );
      _googleSignInInitialized = true;
    }
  }

  // Getters
  SupabaseClient get supabase => _supabase;
  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  // Email Sign Up
  Future<AuthResponse> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signUp(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Email Sign In
  Future<AuthResponse> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Google Sign In
  Future<AuthResponse> signInWithGoogle({
    required String iosClientId,
    required String webClientId,
  }) async {
    try {
      // Initialize Google Sign-In with proper credentials
      _initializeGoogleSignIn(
        iosClientId: iosClientId,
        webClientId: webClientId,
      );

      // Ensure previous Google session is cleared before new sign-in
      await _googleSignIn.signOut();

      // Perform the sign in
      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        throw 'Sign in cancelled';
      }

      final googleAuth = await googleUser.authentication;
      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;

      if (accessToken == null) {
        throw 'No access token found';
      }
      if (idToken == null) {
        throw 'No ID token found';
      }

      return await _supabase.auth.signInWithIdToken(
        provider: Provider.google,
        idToken: idToken,
        accessToken: accessToken,
      );
    } catch (e) {
      rethrow;
    }
  }

  /// Sign out and clear all authentication sessions
  /// 
  /// This method performs comprehensive logout by:
  /// 1. Clearing Supabase authentication session
  /// 2. Signing out and disconnecting Google Sign-In account
  /// 
  /// The auth state stream will automatically notify listeners of the logout,
  /// allowing the UI to react and navigate to the login screen.
  /// 
  /// Throws an exception if Supabase sign-out fails, but Google sign-out errors
  /// are logged and ignored to ensure logout can complete even if Google Sign-In
  /// encounters issues.
  Future<void> signOut() async {
    try {
      // Sign out from Supabase - clears auth token and session
      await _supabase.auth.signOut();

      // Sign out from Google if initialized
      if (_googleSignInInitialized) {
        try {
          // Sign out from Google
          await _googleSignIn.signOut();
          
          // Also disconnect the account for extra security
          // This ensures the next sign-in requires full authentication
          await _googleSignIn.disconnect();
          
          debugPrint('Successfully signed out from Google Sign-In');
        } catch (e) {
          // Google sign-out might fail if not previously signed in with Google,
          // or if Google Sign-In wasn't properly initialized. Log it but continue
          // logout flow to prevent blocking the user.
          debugPrint('Google Sign-Out warning (non-critical): $e');
        }
      }
      
      debugPrint('User successfully signed out');
    } catch (e) {
      debugPrint('Sign-out error: $e');
      rethrow;
    }
  }

  // Password Reset
  Future<void> resetPassword({
    required String email,
  }) async {
    try {
      await _supabase.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Stream of auth changes
  Stream<AuthState> get authStateStream => _supabase.auth.onAuthStateChange;
}
