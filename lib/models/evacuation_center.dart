/// Evacuation center model
class EvacuationCenter {
  final String id;
  final String centerName;
  final double latitude;
  final double longitude;

  const EvacuationCenter({
    required this.id,
    required this.centerName,
    required this.latitude,
    required this.longitude,
  });

  factory EvacuationCenter.fromJson(Map<String, dynamic> json) {
    return EvacuationCenter(
      id: json['id'] as String,
      centerName: json['center_name'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'center_name': centerName,
      'latitude': latitude,
      'longitude': longitude,
    };
  }

  /// Calculate distance to this center from given coordinates (in meters)
  /// Using Haversine formula
  double distanceFrom(double lat, double lng) {
    const double earthRadius = 6371000; // meters
    final double dLat = _toRadians(latitude - lat);
    final double dLng = _toRadians(longitude - lng);

    final double a = _sin(dLat / 2) * _sin(dLat / 2) +
        _cos(_toRadians(lat)) *
            _cos(_toRadians(latitude)) *
            _sin(dLng / 2) *
            _sin(dLng / 2);

    final double c = 2 * _atan2(_sqrt(a), _sqrt(1 - a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * 3.141592653589793 / 180.0;
  double _sin(double x) => x - (x * x * x) / 6 + (x * x * x * x * x) / 120;
  double _cos(double x) => 1 - (x * x) / 2 + (x * x * x * x) / 24;
  double _sqrt(double x) => x < 0 ? 0 : _pow(x, 0.5);
  double _pow(double x, double y) {
    if (y == 0.5) {
      // Simple square root approximation
      double guess = x / 2;
      for (int i = 0; i < 10; i++) {
        guess = (guess + x / guess) / 2;
      }
      return guess;
    }
    return x;
  }
  double _atan2(double y, double x) {
    if (x > 0) return _atan(y / x);
    if (x < 0 && y >= 0) return _atan(y / x) + 3.141592653589793;
    if (x < 0 && y < 0) return _atan(y / x) - 3.141592653589793;
    if (x == 0 && y > 0) return 3.141592653589793 / 2;
    if (x == 0 && y < 0) return -3.141592653589793 / 2;
    return 0;
  }
  double _atan(double x) => x - (x * x * x) / 3 + (x * x * x * x * x) / 5;
}
