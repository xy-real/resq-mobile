import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../main.dart';
import '../models/student.dart';

/// Service for updating student status with offline queue support
class StatusService {
  static const String _offlineQueueKey = 'status_updates_queue';

  /// Update student status
  /// Automatically queues update if offline
  Future<bool> updateStatus({
    required String studentId,
    required StudentStatus status,
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Try to update via Supabase function
      await supabase.rpc('update_student_status', params: {
        'p_student_id': studentId,
        'p_status': status.value,
        'p_source': UpdateSource.app.value,
        'p_lat': latitude,
        'p_lng': longitude,
        'p_validation_flag': true,
      });

      return true;
    } catch (e) {
      // If update fails, queue it for later
      await _queueStatusUpdate(
        studentId: studentId,
        status: status,
        latitude: latitude,
        longitude: longitude,
      );
      return false;
    }
  }

  /// Get student's current status from database
  Future<Student?> getStudentStatus(String studentId) async {
    try {
      final response = await supabase
          .from('students')
          .select()
          .eq('student_id', studentId)
          .single();

      return Student.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch student status: ${e.toString()}');
    }
  }

  /// Get student's status history
  Future<List<Map<String, dynamic>>> getStatusHistory(
    String studentId, {
    int limit = 20,
  }) async {
    try {
      final response = await supabase
          .from('status_logs')
          .select()
          .eq('student_id', studentId)
          .eq('validation_flag', true)
          .order('timestamp', ascending: false)
          .limit(limit);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Failed to fetch status history: ${e.toString()}');
    }
  }

  /// Queue a status update for offline sync
  Future<void> _queueStatusUpdate({
    required String studentId,
    required StudentStatus status,
    double? latitude,
    double? longitude,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final queue = await _getOfflineQueue();

    queue.add({
      'student_id': studentId,
      'status': status.value,
      'latitude': latitude,
      'longitude': longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });

    await prefs.setString(_offlineQueueKey, jsonEncode(queue));
  }

  /// Get offline queue
  Future<List<Map<String, dynamic>>> _getOfflineQueue() async {
    final prefs = await SharedPreferences.getInstance();
    final queueJson = prefs.getString(_offlineQueueKey);

    if (queueJson == null) return [];

    final List<dynamic> queueList = jsonDecode(queueJson);
    return queueList.cast<Map<String, dynamic>>();
  }

  /// Process offline queue
  Future<int> processOfflineQueue() async {
    final queue = await _getOfflineQueue();
    if (queue.isEmpty) return 0;

    int successCount = 0;
    final failedUpdates = <Map<String, dynamic>>[];

    for (final update in queue) {
      try {
        await supabase.rpc('update_student_status', params: {
          'p_student_id': update['student_id'],
          'p_status': update['status'],
          'p_source': UpdateSource.app.value,
          'p_lat': update['latitude'],
          'p_lng': update['longitude'],
          'p_validation_flag': true,
        });
        successCount++;
      } catch (e) {
        // Keep failed updates in queue
        failedUpdates.add(update);
      }
    }

    // Update queue with only failed updates
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_offlineQueueKey, jsonEncode(failedUpdates));

    return successCount;
  }

  /// Get count of pending offline updates
  Future<int> getPendingUpdateCount() async {
    final queue = await _getOfflineQueue();
    return queue.length;
  }

  /// Clear offline queue
  Future<void> clearOfflineQueue() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_offlineQueueKey);
  }

  /// Check if status requires confirmation (CRITICAL)
  bool requiresConfirmation(StudentStatus status) {
    return status == StudentStatus.critical;
  }
}
