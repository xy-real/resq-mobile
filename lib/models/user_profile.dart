/// User profile model representing complete user information
class UserProfile {
  final String studentId;
  final String firstName;
  final String surname;
  final String? middleInitial;
  final String? extension;
  final String email;
  final String contactNumber;
  final bool profileCompleted;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserProfile({
    required this.studentId,
    required this.firstName,
    required this.surname,
    this.middleInitial,
    this.extension,
    required this.email,
    required this.contactNumber,
    this.profileCompleted = false,
    this.createdAt,
    this.updatedAt,
  });

  /// Create a copy of this profile with some fields replaced
  UserProfile copyWith({
    String? studentId,
    String? firstName,
    String? surname,
    String? middleInitial,
    String? extension,
    String? email,
    String? contactNumber,
    bool? profileCompleted,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      studentId: studentId ?? this.studentId,
      firstName: firstName ?? this.firstName,
      surname: surname ?? this.surname,
      middleInitial: middleInitial ?? this.middleInitial,
      extension: extension ?? this.extension,
      email: email ?? this.email,
      contactNumber: contactNumber ?? this.contactNumber,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Convert to JSON for API requests
  Map<String, dynamic> toJson() => {
    'student_id': studentId,
    'first_name': firstName,
    'surname': surname,
    'middle_initial': middleInitial,
    'extension': extension,
    'email': email,
    'contact_number': contactNumber,
    'profile_completed': profileCompleted,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
  };

  /// Create from JSON (API response)
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      studentId: json['student_id'] ?? '',
      firstName: json['first_name'] ?? '',
      surname: json['surname'] ?? '',
      middleInitial: json['middle_initial'],
      extension: json['extension'],
      email: json['email'] ?? '',
      contactNumber: json['contact_number'] ?? '',
      profileCompleted: json['profile_completed'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  @override
  String toString() => 'UserProfile('
      'studentId: $studentId, '
      'firstName: $firstName, '
      'surname: $surname, '
      'email: $email, '
      'profileCompleted: $profileCompleted)';
}
