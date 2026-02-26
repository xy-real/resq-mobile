/// System settings model for disaster mode configuration
class SystemSettings {
  final int id;
  final bool isDisasterModeActive;
  final DateTime? modeActivatedAt;

  const SystemSettings({
    this.id = 1,
    required this.isDisasterModeActive,
    this.modeActivatedAt,
  });

  factory SystemSettings.fromJson(Map<String, dynamic> json) {
    return SystemSettings(
      id: json['id'] as int? ?? 1,
      isDisasterModeActive: json['is_disaster_mode_active'] as bool,
      modeActivatedAt: json['mode_activated_at'] != null
          ? DateTime.parse(json['mode_activated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_disaster_mode_active': isDisasterModeActive,
      'mode_activated_at': modeActivatedAt?.toIso8601String(),
    };
  }

  SystemSettings copyWith({
    int? id,
    bool? isDisasterModeActive,
    DateTime? modeActivatedAt,
  }) {
    return SystemSettings(
      id: id ?? this.id,
      isDisasterModeActive: isDisasterModeActive ?? this.isDisasterModeActive,
      modeActivatedAt: modeActivatedAt ?? this.modeActivatedAt,
    );
  }
}
