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

  // Sign Out - Clear both Supabase and Google Sign-In sessions
  Future<void> signOut() async {
    try {
      // Sign out from Supabase
      await _supabase.auth.signOut();

      // Sign out from Google if initialized
      if (_googleSignInInitialized) {
        try {
          await _googleSignIn.signOut();
          // Also disconnect the account for extra security
          await _googleSignIn.disconnect();
        } catch (e) {
          // Google sign-out might fail if not previously signed in, continue anyway
          debugPrint('Google Sign-Out error: $e');
        }
      }
    } catch (e) {
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
