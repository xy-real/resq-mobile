import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/supabase_config.dart';
import 'dart:async';

/// Service for GPS location tracking with battery efficiency
class LocationService {
  Position? _lastPosition;
  StreamSubscription<Position>? _positionStream;
  Timer? _pollTimer;

  /// Request location permissions
  Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    final status = await Permission.location.status;
    return status.isGranted;
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current location
  Future<Position?> getCurrentLocation() async {
    try {
      // Check permissions
      if (!await hasLocationPermission()) {
        final granted = await requestLocationPermission();
        if (!granted) return null;
      }

      // Check if location service is enabled
      if (!await isLocationServiceEnabled()) {
        throw Exception('Location services are disabled');
      }

      // Get current position with balanced accuracy for battery efficiency
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          distanceFilter: 100, // Only update if moved 100m
        ),
      );

      _lastPosition = position;
      return position;
    } catch (e) {
      throw Exception('Failed to get location: ${e.toString()}');
    }
  }

  /// Start location tracking with polling interval
  /// Only polls when disaster mode is active
  Stream<Position> startLocationTracking({
    Duration? interval,
  }) {
    final pollInterval = interval ?? 
        Duration(seconds: SupabaseConfig.locationUpdateInterval);

    final controller = StreamController<Position>();

    _pollTimer = Timer.periodic(pollInterval, (timer) async {
      try {
        final position = await getCurrentLocation();
        if (position != null && _shouldUpdateLocation(position)) {
          controller.add(position);
          _lastPosition = position;
        }
      } catch (e) {
        controller.addError(e);
      }
    });

    return controller.stream;
  }

  /// Stop location tracking
  void stopLocationTracking() {
    _positionStream?.cancel();
    _pollTimer?.cancel();
    _positionStream = null;
    _pollTimer = null;
  }

  /// Check if location update should be sent based on 100m threshold
  bool _shouldUpdateLocation(Position newPosition) {
    if (_lastPosition == null) return true;

    final distance = Geolocator.distanceBetween(
      _lastPosition!.latitude,
      _lastPosition!.longitude,
      newPosition.latitude,
      newPosition.longitude,
    );

    return distance >= SupabaseConfig.locationDistanceThreshold;
  }

  /// Calculate distance between two positions (in meters)
  double calculateDistance({
    required double lat1,
    required double lon1,
    required double lat2,
    required double lon2,
  }) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Get last known position
  Position? get lastPosition => _lastPosition;

  /// Check if location has changed significantly
  bool hasLocationChangedSignificantly(Position newPosition) {
    return _shouldUpdateLocation(newPosition);
  }

  /// Get location accuracy level description
  String getAccuracyDescription(Position position) {
    if (position.accuracy <= 10) return 'Excellent';
    if (position.accuracy <= 30) return 'Good';
    if (position.accuracy <= 100) return 'Fair';
    return 'Poor';
  }

  /// Format coordinates for display
  String formatCoordinates(double latitude, double longitude) {
    final latDir = latitude >= 0 ? 'N' : 'S';
    final lonDir = longitude >= 0 ? 'E' : 'W';
    
    return '${latitude.abs().toStringAsFixed(6)}°$latDir, '
           '${longitude.abs().toStringAsFixed(6)}°$lonDir';
  }

  /// Open device location settings
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Get location status summary
  Future<Map<String, dynamic>> getLocationStatus() async {
    final hasPermission = await hasLocationPermission();
    final isEnabled = await isLocationServiceEnabled();
    final lastPos = _lastPosition;

    return {
      'hasPermission': hasPermission,
      'isEnabled': isEnabled,
      'hasLastPosition': lastPos != null,
      'isTracking': _pollTimer?.isActive ?? false,
      'lastPosition': lastPos != null ? {
        'latitude': lastPos.latitude,
        'longitude': lastPos.longitude,
        'accuracy': lastPos.accuracy,
        'timestamp': lastPos.timestamp.toIso8601String(),
      } : null,
    };
  }

  /// Dispose resources
  void dispose() {
    stopLocationTracking();
  }
}
