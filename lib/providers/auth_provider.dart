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
  Future<void> initialize() async {
    _state = AuthFlowState.loading;
    notifyListeners();

    try {
      // Check if user profile is completed
      final isComplete = await _profileService.isProfileCompleted();
      
      if (isComplete) {
        _state = AuthFlowState.authenticatedProfileComplete;
      } else {
        // Try to load draft profile
        _profile = _profileService.getCachedProfile();
        _state = AuthFlowState.authenticatedNeedsProfile;
      }
    } catch (e) {
      _error = 'Failed to initialize auth state: $e';
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
