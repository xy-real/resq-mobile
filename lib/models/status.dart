/// Status update model representing a student's status change
class StatusUpdate {
  final String studentId;
  final String status;
  final DateTime timestamp;
  final String source;
  final double? latitude;
  final double? longitude;
  final String? accuracy;
  final bool validationFlag;

  const StatusUpdate({
    required this.studentId,
    required this.status,
    required this.timestamp,
    required this.source,
    this.latitude,
    this.longitude,
    this.accuracy,
    this.validationFlag = true,
  });

  /// Convert to JSON for Supabase database operations
  Map<String, dynamic> toJson() => {
    'student_id': studentId,
    'status': status,
    'timestamp': timestamp.toUtc().toIso8601String(),
    'source': source,
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'validation_flag': validationFlag,
  };

  /// Create StatusUpdate from JSON response
  factory StatusUpdate.fromJson(Map<String, dynamic> json) {
    return StatusUpdate(
      studentId: json['student_id'] ?? '',
      status: json['status'] ?? 'UNKNOWN',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      source: json['source'] ?? 'APP',
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      accuracy: json['accuracy']?.toString(),
      validationFlag: json['validation_flag'] ?? true,
    );
  }

  @override
  String toString() => 'StatusUpdate('
      'studentId: $studentId, '
      'status: $status, '
      'timestamp: $timestamp, '
      'source: $source, '
      'latitude: $latitude, '
      'longitude: $longitude)';
}

/// Valid status values from the ERD specification
enum StatusValue {
  safe('SAFE'),
  needsAssistance('NEEDS_ASSISTANCE'),
  critical('CRITICAL'),
  evacuated('EVACUATED'),
  unknown('UNKNOWN');

  final String value;
  const StatusValue(this.value);

  /// Get display name for UI
  String get displayName {
    switch (this) {
      case StatusValue.safe:
        return 'Safe';
      case StatusValue.needsAssistance:
        return 'Needs Assistance';
      case StatusValue.critical:
        return 'Critical';
      case StatusValue.evacuated:
        return 'Evacuated';
      case StatusValue.unknown:
        return 'Unknown';
    }
  }

  /// Parse string to StatusValue
  static StatusValue fromString(String value) {
    return StatusValue.values.firstWhere(
      (status) => status.value == value.toUpperCase(),
      orElse: () => StatusValue.unknown,
    );
  }
}
