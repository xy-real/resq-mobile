import 'student.dart';

/// Status log model representing a status update entry
class StatusLog {
  final String id;
  final String studentId;
  final StudentStatus status;
  final DateTime timestamp;
  final UpdateSource source;
  final bool validationFlag;

  const StatusLog({
    required this.id,
    required this.studentId,
    required this.status,
    required this.timestamp,
    required this.source,
    this.validationFlag = true,
  });

  factory StatusLog.fromJson(Map<String, dynamic> json) {
    return StatusLog(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      status: StudentStatus.fromString(json['status'] as String),
      timestamp: DateTime.parse(json['timestamp'] as String),
      source: UpdateSource.fromString(json['source'] as String),
      validationFlag: json['validation_flag'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'student_id': studentId,
      'status': status.value,
      'timestamp': timestamp.toIso8601String(),
      'source': source.value,
      'validation_flag': validationFlag,
    };
  }
}
