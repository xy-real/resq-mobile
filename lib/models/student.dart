/// Status enum for student safety status
enum StudentStatus {
  safe('SAFE'),
  needsAssistance('NEEDS_ASSISTANCE'),
  critical('CRITICAL'),
  evacuated('EVACUATED'),
  unknown('UNKNOWN');

  const StudentStatus(this.value);
  final String value;

  static StudentStatus fromString(String value) {
    return StudentStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => StudentStatus.unknown,
    );
  }
}

/// Update source enum
enum UpdateSource {
  app('APP'),
  sms('SMS');

  const UpdateSource(this.value);
  final String value;

  static UpdateSource fromString(String value) {
    return UpdateSource.values.firstWhere(
      (source) => source.value == value,
      orElse: () => UpdateSource.app,
    );
  }
}

/// Student model representing a registered student
class Student {
  final String studentId;
  final String name;
  final String? contactNumber;
  final double? homeLat;
  final double? homeLng;
  final String? registeredHomeRiskLabel;
  final double? lastKnownLat;
  final double? lastKnownLng;
  final StudentStatus lastStatus;
  final DateTime? lastUpdateTimestamp;
  final UpdateSource? lastUpdateSource;

  const Student({
    required this.studentId,
    required this.name,
    this.contactNumber,
    this.homeLat,
    this.homeLng,
    this.registeredHomeRiskLabel,
    this.lastKnownLat,
    this.lastKnownLng,
    this.lastStatus = StudentStatus.unknown,
    this.lastUpdateTimestamp,
    this.lastUpdateSource,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      studentId: json['student_id'] as String,
      name: json['name'] as String,
      contactNumber: json['contact_number'] as String?,
      homeLat: json['home_lat'] != null ? (json['home_lat'] as num).toDouble() : null,
      homeLng: json['home_lng'] != null ? (json['home_lng'] as num).toDouble() : null,
      registeredHomeRiskLabel: json['registered_home_risk_label'] as String?,
      lastKnownLat: json['last_known_lat'] != null ? (json['last_known_lat'] as num).toDouble() : null,
      lastKnownLng: json['last_known_lng'] != null ? (json['last_known_lng'] as num).toDouble() : null,
      lastStatus: json['last_status'] != null 
          ? StudentStatus.fromString(json['last_status'] as String)
          : StudentStatus.unknown,
      lastUpdateTimestamp: json['last_update_timestamp'] != null
          ? DateTime.parse(json['last_update_timestamp'] as String)
          : null,
      lastUpdateSource: json['last_update_source'] != null
          ? UpdateSource.fromString(json['last_update_source'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student_id': studentId,
      'name': name,
      'contact_number': contactNumber,
      'home_lat': homeLat,
      'home_lng': homeLng,
      'registered_home_risk_label': registeredHomeRiskLabel,
      'last_known_lat': lastKnownLat,
      'last_known_lng': lastKnownLng,
      'last_status': lastStatus.value,
      'last_update_timestamp': lastUpdateTimestamp?.toIso8601String(),
      'last_update_source': lastUpdateSource?.value,
    };
  }

  Student copyWith({
    String? studentId,
    String? name,
    String? contactNumber,
    double? homeLat,
    double? homeLng,
    String? registeredHomeRiskLabel,
    double? lastKnownLat,
    double? lastKnownLng,
    StudentStatus? lastStatus,
    DateTime? lastUpdateTimestamp,
    UpdateSource? lastUpdateSource,
  }) {
    return Student(
      studentId: studentId ?? this.studentId,
      name: name ?? this.name,
      contactNumber: contactNumber ?? this.contactNumber,
      homeLat: homeLat ?? this.homeLat,
      homeLng: homeLng ?? this.homeLng,
      registeredHomeRiskLabel: registeredHomeRiskLabel ?? this.registeredHomeRiskLabel,
      lastKnownLat: lastKnownLat ?? this.lastKnownLat,
      lastKnownLng: lastKnownLng ?? this.lastKnownLng,
      lastStatus: lastStatus ?? this.lastStatus,
      lastUpdateTimestamp: lastUpdateTimestamp ?? this.lastUpdateTimestamp,
      lastUpdateSource: lastUpdateSource ?? this.lastUpdateSource,
    );
  }
}
