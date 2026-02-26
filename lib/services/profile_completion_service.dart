import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

/// Service for managing user profile completion
class ProfileCompletionService {
  static final ProfileCompletionService _instance =
      ProfileCompletionService._internal();
  final SupabaseClient _supabase = Supabase.instance.client;
  late SharedPreferences _prefs;

  factory ProfileCompletionService() {
    return _instance;
  }

  ProfileCompletionService._internal();

  // Persistence keys
  static const String _profileCompletionKey = 'user_profile_completion';
  static const String _profileCompleteStatusKey = 'profile_complete_status';

  /// Initialize the service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
  }

  /// Check if user's profile is completed
  Future<bool> isProfileCompleted() async {
    try {
      // For MVP: Check local storage only
      // TODO: Sync with backend when ready
      final isCompleted = _prefs.getBool(_profileCompleteStatusKey) ?? false;
      return isCompleted;
    } catch (e) {
      debugPrint('Error checking profile completion status: $e');
      return false;
    }
  }

  /// Get cached profile from local storage
  UserProfile? getCachedProfile() {
    try {
      final profileJson = _prefs.getString(_profileCompletionKey);
      if (profileJson != null) {
        final decoded = jsonDecode(profileJson) as Map<String, dynamic>;
        return UserProfile.fromJson(decoded);
      }
      return null;
    } catch (e) {
      debugPrint('Error loading cached profile: $e');
      return null;
    }
  }

  /// Save profile temporarily to local storage (for incomplete profiles)
  Future<void> saveDraftProfile(UserProfile profile) async {
    try {
      final profileJson = jsonEncode(profile.toJson());
      await _prefs.setString(_profileCompletionKey, profileJson);
    } catch (e) {
      debugPrint('Error saving draft profile: $e');
      rethrow;
    }
  }

  /// Submit completed profile (local storage only for MVP - backend integration comes later)
  Future<UserProfile> submitProfile(UserProfile profile) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw 'User not authenticated';
      }

      // For MVP: Save profile locally only
      // TODO: Add Supabase integration when backend is ready
      final completedProfile = profile.copyWith(profileCompleted: true);
      final profileJson = jsonEncode(completedProfile.toJson());
      
      // Save to local storage
      await _prefs.setString(_profileCompletionKey, profileJson);
      await _prefs.setBool(_profileCompleteStatusKey, true);

      // Simulate network delay for better UX
      await Future.delayed(const Duration(milliseconds: 500));

      return completedProfile;
    } catch (e) {
      debugPrint('Error submitting profile: $e');
      rethrow;
    }
  }

  /// Clear draft profile
  Future<void> clearDraftProfile() async {
    try {
      await _prefs.remove(_profileCompletionKey);
    } catch (e) {
      debugPrint('Error clearing draft profile: $e');
      rethrow;
    }
  }

  /// Clear all profile-related data
  Future<void> clearAllProfileData() async {
    try {
      await _prefs.remove(_profileCompletionKey);
      await _prefs.remove(_profileCompleteStatusKey);
    } catch (e) {
      debugPrint('Error clearing profile data: $e');
      rethrow;
    }
  }

  /// Get user's email from Google authentication
  String? getGoogleEmail() {
    try {
      final user = _supabase.auth.currentUser;
      return user?.email;
    } catch (e) {
      debugPrint('Error getting Google email: $e');
      return null;
    }
  }
}
