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

  /// Submit completed profile to STUDENTS table in Supabase
  /// 
  /// This method:
  /// 1. Validates the user is authenticated
  /// 2. Creates a student record in the STUDENTS table with the profile data
  /// 3. Saves the profile to local storage for offline access
  /// 4. Returns the completed profile
  /// 
  /// Parameters:
  ///   - profile: The complete user profile to save
  /// 
  /// Returns: The saved profile with profileCompleted flag set to true
  /// 
  /// Throws: Exception if user is not authenticated or database insertion fails
  Future<UserProfile> submitProfile(UserProfile profile) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Combine first name and surname as the full name for the database
      final fullName = '${profile.firstName} ${profile.surname}'.trim();

      // Insert/update student record in the STUDENTS table
      // The RLS policy allows authenticated users to insert their own student record
      await _supabase.from('students').upsert(
        {
          'student_id': profile.studentId,
          'user_id': user.id,
          'email': profile.email,
          'name': fullName,
          'contact_number': profile.contactNumber,
          'last_status': 'UNKNOWN', // Initial status
        },
        onConflict: 'student_id', // Use student_id as the unique identifier
      );

      final completedProfile = profile.copyWith(profileCompleted: true);
      final profileJson = jsonEncode(completedProfile.toJson());
      
      // Save to local storage for offline access
      await _prefs.setString(_profileCompletionKey, profileJson);
      await _prefs.setBool(_profileCompleteStatusKey, true);

      debugPrint('Profile submitted successfully for student: ${profile.studentId}');
      return completedProfile;
    } catch (e) {
      debugPrint('Error submitting profile: $e');
      rethrow;
    }
  }

  /// Mark the profile as complete in local storage
  /// 
  /// This is called after successfully saving a profile to the database
  /// or when loading an existing profile from the database.
  Future<void> markProfileComplete() async {
    try {
      await _prefs.setBool(_profileCompleteStatusKey, true);
    } catch (e) {
      debugPrint('Error marking profile as complete: $e');
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

  /// Check if the authenticated user already has a student record in the database
  /// 
  /// This method queries the STUDENTS table for an existing record associated
  /// with the currently authenticated user. Used to determine if profile 
  /// completion is needed.
  /// 
  /// Returns: true if student record exists, false otherwise
  /// 
  /// Throws: Exception if not authenticated or database query fails
  Future<bool> studentRecordExists() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return false;
      }

      final response = await _supabase
          .from('students')
          .select('student_id')
          .eq('user_id', user.id)
          .maybeSingle(); // Returns null if no record found

      return response != null;
    } catch (e) {
      debugPrint('Error checking student record: $e');
      // If there's an error, assume record doesn't exist to prompt for profile
      return false;
    }
  }

  /// Load the authenticated user's profile from the database
  /// 
  /// This method fetches the student record (if it exists) from the database
  /// and returns it as a UserProfile object.
  /// 
  /// Returns: UserProfile if found, null if no record exists
  /// 
  /// Throws: Exception if database query fails
  Future<UserProfile?> loadProfileFromDatabase() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return null;
      }

      final response = await _supabase
          .from('students')
          .select()
          .eq('user_id', user.id)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      // Parse the database response into a UserProfile
      return UserProfile(
        studentId: response['student_id'] ?? '',
        firstName: (response['name'] ?? '').split(' ').first,
        surname: (response['name'] ?? '').split(' ').skip(1).join(' '),
        email: response['email'] ?? '',
        contactNumber: response['contact_number'] ?? '',
        profileCompleted: true,
      );
    } catch (e) {
      debugPrint('Error loading profile from database: $e');
      return null;
    }
  }
}
