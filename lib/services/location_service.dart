import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';

// Export LocationPermission enum for use in other parts of the app
export 'package:geolocator/geolocator.dart' show LocationPermission;

/// Represents a geographic location with coordinates and metadata
class LocationData {
  final double latitude;
  final double longitude;
  final double? accuracy;
  final double? altitude;
  final DateTime timestamp;

  LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    required this.timestamp,
  });

  /// Format location as a readable string for display
  String get displayString =>
      '$latitude, $longitude';

  /// Convert to compact format for sending to backend
  Map<String, dynamic> toJson() => {
    'latitude': latitude,
    'longitude': longitude,
    'accuracy': accuracy,
    'altitude': altitude,
    'timestamp': timestamp.toIso8601String(),
  };

  @override
  String toString() =>
      'LocationData(lat: $latitude, lng: $longitude, accuracy: $accuracy)';
}

/// Service for handling device location requests and permissions
class LocationService {
  /// Check if location services are enabled on the device
  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Get current location permission status
  static Future<LocationPermission> getPermissionStatus() async {
    return await Geolocator.checkPermission();
  }

  /// Request location permission from the user
  static Future<LocationPermission> requestPermission() async {
    return await Geolocator.requestPermission();
  }

  /// Get the current GPS location
  /// 
  /// Returns null if:
  /// - Location services are disabled
  /// - Location permission is denied
  /// - Location is unavailable
  static Future<LocationData?> getCurrentLocation() async {
    try {
      // Check if location services are enabled
      final serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return null;
      }

      // Check permission status
      final permission = await getPermissionStatus();

      // If permission is denied, request it
      if (permission == LocationPermission.denied) {
        final result = await requestPermission();
        if (result == LocationPermission.denied) {
          debugPrint('Location permission denied');
          return null;
        }
        if (result == LocationPermission.deniedForever) {
          debugPrint(
              'Location permission permanently denied, opening app settings');
          await Geolocator.openLocationSettings();
          return null;
        }
      }

      // If permission is denied forever, ask user to enable in settings
      if (permission == LocationPermission.deniedForever) {
        debugPrint(
            'Location permission permanently denied, opening app settings');
        await Geolocator.openLocationSettings();
        return null;
      }

      // Get the current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
      );

      return LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          position.timestamp.millisecondsSinceEpoch,
        ),
      );
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  /// Open app location settings
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// Open app settings
  static Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }
}
