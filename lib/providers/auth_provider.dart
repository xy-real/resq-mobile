import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../services/profile_completion_service.dart';

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

  /// Sign out and clear all auth data
  Future<void> signOut() async {
    try {
      await _profileService.clearAllProfileData();
      _state = AuthFlowState.unauthenticated;
      _profile = null;
      _error = null;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to sign out: $e';
      notifyListeners();
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
