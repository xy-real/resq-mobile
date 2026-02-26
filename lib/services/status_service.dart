import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/status.dart';

/// Service for handling status updates to Supabase backend
/// 
/// This service manages:
/// - Updating student status in the STUDENTS table
/// - Creating status history entries in the STATUS_LOGS table
/// - Handling location data with status updates
/// - All communication with Supabase database
class StatusService {
  static final StatusService _instance = StatusService._internal();
  final SupabaseClient _supabase = Supabase.instance.client;

  factory StatusService() {
    return _instance;
  }

  StatusService._internal();

  // Getters
  SupabaseClient get supabase => _supabase;
  User? get currentUser => _supabase.auth.currentUser;

  /// Normalize status value to match database enum format
  /// 
  /// Converts various formats to the standard database format:
  /// - "NEEDS ASSISTANCE" → "NEEDS_ASSISTANCE"
  /// - "Needs Assistance" → "NEEDS_ASSISTANCE"
  /// - "needs assistance" → "NEEDS_ASSISTANCE"
  /// - Already formatted values remain unchanged
  String _normalizeStatus(String status) {
    // Replace spaces with underscores and convert to uppercase
    final normalized = status.replaceAll(' ', '_').toUpperCase();
    return normalized;
  }

  /// Get the student ID for the currently authenticated user
  /// 
  /// Queries the STUDENTS table to find the student_id associated with
  /// the current auth user's user_id
  /// 
  /// Returns the student_id string, or null if not found
  /// Throws an exception if not authenticated or query fails
  Future<String?> getStudentId() async {
    try {
      if (!isAuthenticated) {
        throw 'User not authenticated';
      }

      final response = await _supabase
          .from('students')
          .select('student_id')
          .eq('user_id', currentUser!.id)
          .single();

      return response['student_id'] as String?;
    } catch (e) {
      debugPrint('Error fetching student ID: $e');
      rethrow;
    }
  }

  /// Update student status in the database
  /// 
  /// This method:
  /// 1. Normalizes the status value (handles space vs underscore)
  /// 2. Updates the STUDENTS table with the new status and location
  /// 3. Creates an entry in STATUS_LOGS for audit trail
  /// 
  /// Parameters:
  ///   - status: The new status (SAFE, NEEDS_ASSISTANCE, CRITICAL, EVACUATED, UNKNOWN)
  ///     Accepts formats with spaces (e.g., "NEEDS ASSISTANCE") or underscores
  ///   - latitude: Optional GPS latitude
  ///   - longitude: Optional GPS longitude
  ///   - accuracy: Optional location accuracy in meters
  /// 
  /// Returns: StatusUpdate object with the saved data
  /// Throws: Exception if update fails
  Future<StatusUpdate> updateStatus({
    required String status,
    double? latitude,
    double? longitude,
    double? accuracy,
  }) async {
    try {
      if (!isAuthenticated) {
        throw 'User not authenticated. Cannot update status.';
      }

      // Normalize status value to database format (replace spaces with underscores)
      final normalizedStatus = _normalizeStatus(status);

      // Get student ID for current user
      final studentId = await getStudentId();
      if (studentId == null) {
        throw 'Student profile not found. Please complete your profile first.';
      }

      final now = DateTime.now().toUtc();
      final accuracyStr = accuracy?.toStringAsFixed(2);

      // Create StatusUpdate object with normalized status
      final statusUpdate = StatusUpdate(
        studentId: studentId,
        status: normalizedStatus,
        timestamp: now,
        source: 'APP',
        latitude: latitude,
        longitude: longitude,
        accuracy: accuracyStr,
        validationFlag: true,
      );

      // Update STUDENTS table with normalized status and location
      await _supabase
          .from('students')
          .update({
            'last_status': normalizedStatus,
            'last_known_lat': latitude,
            'last_known_lng': longitude,
            'last_update_timestamp': now.toIso8601String(),
            'last_update_source': 'APP',
          })
          .eq('student_id', studentId);

      // Insert into STATUS_LOGS for audit trail with normalized status
      await _supabase
          .from('status_logs')
          .insert({
            'student_id': studentId,
            'status': normalizedStatus,
            'timestamp': now.toIso8601String(),
            'source': 'APP',
            'validation_flag': true,
          });

      debugPrint('Status updated successfully: $status for student $studentId');
      return statusUpdate;
    } catch (e) {
      debugPrint('Error updating status: $e');
      rethrow;
    }
  }

  /// Get the latest status for the current user
  /// 
  /// Queries the STUDENTS table to get the current status
  /// and related location/timestamp information
  /// 
  /// Returns: StatusUpdate with current status data
  /// Throws: Exception if query fails or user not authenticated
  Future<StatusUpdate?> getCurrentStatus() async {
    try {
      if (!isAuthenticated) {
        throw 'User not authenticated';
      }

      final studentId = await getStudentId();
      if (studentId == null) {
        return null;
      }

      final response = await _supabase
          .from('students')
          .select(
            'student_id, last_status, last_known_lat, last_known_lng, last_update_timestamp',
          )
          .eq('student_id', studentId)
          .single();

      return StatusUpdate(
        studentId: response['student_id'],
        status: response['last_status'] ?? 'UNKNOWN',
        timestamp: DateTime.tryParse(response['last_update_timestamp']) ?? DateTime.now(),
        source: 'APP',
        latitude: (response['last_known_lat'] as num?)?.toDouble(),
        longitude: (response['last_known_lng'] as num?)?.toDouble(),
      );
    } catch (e) {
      debugPrint('Error fetching current status: $e');
      return null;
    }
  }

  /// Get status history for the current user
  /// 
  /// Queries the STATUS_LOGS table to get previous status updates
  /// Limited to the most recent 50 entries
  /// 
  /// Returns: List of StatusUpdate objects in reverse chronological order
  /// Throws: Exception if query fails or user not authenticated
  Future<List<StatusUpdate>> getStatusHistory({int limit = 50}) async {
    try {
      if (!isAuthenticated) {
        throw 'User not authenticated';
      }

      final studentId = await getStudentId();
      if (studentId == null) {
        return [];
      }

      final response = await _supabase
          .from('status_logs')
          .select()
          .eq('student_id', studentId)
          .order('timestamp', ascending: false)
          .limit(limit);

      return (response as List)
          .map((data) => StatusUpdate.fromJson(data))
          .toList();
    } catch (e) {
      debugPrint('Error fetching status history: $e');
      return [];
    }
  }

  /// Check if user is authenticated
  bool get isAuthenticated => currentUser != null;

  /// Get current authenticated user
  User? get user => currentUser;
}
