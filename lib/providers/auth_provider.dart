import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/profile_completion_service.dart';
import '../services/auth_service.dart';

/// Represents the authentication and profile completion state
enum AuthFlowState {
  initial,
  loading,
  unauthenticated,
  authenticatedNeedsProfile,
  authenticatedProfileComplete,
  error,
}

/// Provider for managing authentication and profile completion flow
class AuthNotifier extends ChangeNotifier {
  final ProfileCompletionService _profileService = ProfileCompletionService();

  AuthFlowState _state = AuthFlowState.initial;
  UserProfile? _profile;
  String? _error;
  bool _isLoadingProfile = false;

  // Getters
  AuthFlowState get state => _state;
  UserProfile? get profile => _profile;
  String? get error => _error;
  bool get isLoadingProfile => _isLoadingProfile;

  bool get isAuthenticated =>
      _state == AuthFlowState.authenticatedNeedsProfile ||
      _state == AuthFlowState.authenticatedProfileComplete;

  bool get isProfileComplete =>
      _state == AuthFlowState.authenticatedProfileComplete;

  /// Initialize auth state (call on app startup)
  /// 
  /// This method determines the current auth flow state by:
  /// 1. Checking if a user is authenticated
  /// 2. Checking if their profile is completed (locally cached)
  /// 3. If not cached, querying the database to see if record exists
  /// 
  /// Sets _state to one of:
  /// - unauthenticated: User is not logged in
  /// - authenticatedProfileComplete: User is logged in with complete profile
  /// - authenticatedNeedsProfile: User is logged in but profile needs completion
  Future<void> initialize() async {
    _state = AuthFlowState.loading;
    notifyListeners();

    try {
      final authService = AuthService();
      
      // If no authenticated user, they're unauthenticated
      if (authService.currentUser == null) {
        _state = AuthFlowState.unauthenticated;
        notifyListeners();
        return;
      }

      // Check if profile is cached locally
      final isCompleted = await _profileService.isProfileCompleted();
      
      if (isCompleted) {
        // Profile was previously completed, load from cache
        _profile = _profileService.getCachedProfile();
        _state = AuthFlowState.authenticatedProfileComplete;
      } else {
        // Check if student record exists in database
        final recordExists = await _profileService.studentRecordExists();
        
        if (recordExists) {
          // Student record exists in database, load it
          _profile = await _profileService.loadProfileFromDatabase();
          _state = AuthFlowState.authenticatedProfileComplete;
          
          // Cache it locally for faster future loads
          if (_profile != null) {
            await _profileService.saveDraftProfile(_profile!);
            await _profileService.markProfileComplete();
          }
        } else {
          // No profile exists, prompt for completion
          _profile = _profileService.getCachedProfile();
          _state = AuthFlowState.authenticatedNeedsProfile;
        }
      }
    } catch (e) {
      _error = 'Failed to initialize auth state: $e';
      _state = AuthFlowState.error;
    }

    notifyListeners();
  }

  /// Call after successful Google sign-in
  /// 
  /// After a user successfully authenticates with Google, this method:
  /// 1. Checks if a student record already exists in the database
  /// 2. If it exists, loads it and marks profile as complete
  /// 3. If it doesn't exist, initializes a form with the Google email
  ///    and transitions to authenticatedNeedsProfile state
  /// 
  /// This allows returning users (who previously completed their profile)
  /// to skip the form and go straight to the main app.
  Future<void> handleGoogleSignInComplete() async {
    _error = null;
    notifyListeners();

    try {
      final recordExists = await _profileService.studentRecordExists();
      
      if (recordExists) {
        // User has previously completed their profile
        _profile = await _profileService.loadProfileFromDatabase();
        _state = AuthFlowState.authenticatedProfileComplete;
        
        // Cache it locally
        if (_profile != null) {
          await _profileService.saveDraftProfile(_profile!);
          await _profileService.markProfileComplete();
        }
      } else {
        // New user - initialize form with Google email
        final googleEmail = _profileService.getGoogleEmail();
        _state = AuthFlowState.authenticatedNeedsProfile;
        _profile = UserProfile(
          studentId: '',
          firstName: '',
          surname: '',
          email: googleEmail ?? '',
          contactNumber: '',
        );
      }
    } catch (e) {
      _error = 'Failed to process Google sign-in: $e';
      _state = AuthFlowState.error;
    }

    notifyListeners();
  }

  /// Call after successful Google sign-in with user email
  void setGoogleAuthenticatedNeedsProfile({required String email}) {
    _state = AuthFlowState.authenticatedNeedsProfile;
    _profile = UserProfile(
      studentId: '',
      firstName: '',
      surname: '',
      email: email,
      contactNumber: '',
    );
    _error = null;
    notifyListeners();
  }

  /// Update draft profile as user fills form
  void updateProfileDraft(UserProfile profile) {
    _profile = profile;
    notifyListeners();
  }

  /// Save profile draft to persistent storage
  Future<void> saveDraftProfile(UserProfile profile) async {
    try {
      _profile = profile;
      await _profileService.saveDraftProfile(profile);
    } catch (e) {
      _error = 'Failed to save draft: $e';
      notifyListeners();
    }
  }

  /// Submit completed profile
  Future<void> submitProfile(UserProfile profile) async {
    _isLoadingProfile = true;
    _error = null;
    notifyListeners();

    try {
      final completedProfile = await _profileService.submitProfile(profile);
      _profile = completedProfile;
      _state = AuthFlowState.authenticatedProfileComplete;
    } catch (e) {
      _error = 'Failed to complete profile: $e';
      _state = AuthFlowState.authenticatedNeedsProfile;
    } finally {
      _isLoadingProfile = false;
      notifyListeners();
    }
  }

  /// Sign out and clear all authentication data
  /// 
  /// This method performs comprehensive logout by:
  /// 1. Clearing Supabase authentication session (via AuthService)
  /// 2. Clearing all cached profile data and session flags
  /// 3. Resetting the auth state to unauthenticated
  /// 
  /// After this method completes:
  /// - All auth tokens are cleared
  /// - All profile data is removed from local storage
  /// - All session flags (like profileCompleted) are reset
  /// - Auth state listeners will be notified and can trigger navigation
  /// 
  /// Throws an exception if authentication cleanup fails.
  Future<void> signOut() async {
    try {
      // Clear Supabase session and Google Sign-In
      final authService = AuthService();
      await authService.signOut();

      // Clear all cached profile data and session flags
      await _profileService.clearAllProfileData();

      // Reset the auth state
      _state = AuthFlowState.unauthenticated;
      _profile = null;
      _error = null;
      _isLoadingProfile = false;

      debugPrint('User successfully signed out - all auth data cleared');
      notifyListeners();
    } catch (e) {
      _error = 'Failed to sign out: $e';
      debugPrint('Sign-out error: $e');
      notifyListeners();
      rethrow;
    }
  }

  /// Clear error message
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

// Global instance for easy access
late AuthNotifier authNotifier;

/// Initialize the auth notifier
Future<void> initializeAuthNotifier() async {
  authNotifier = AuthNotifier();
  await authNotifier.initialize();
}
