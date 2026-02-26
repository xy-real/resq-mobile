import 'package:latlong2/latlong.dart';

/// Represents an evacuation center within VSU campus
class EvacuationCenter {
  final String id;
  final String name;
  final String label; // Displayed on map (e.g., "Evacuation Center A")
  final double latitude;
  final double longitude;
  final String description;
  final String capacity; // e.g., "500 people"
  final List<String> facilities; // e.g., ["First Aid", "Water", "Food"]
  final bool isActive;
  final DateTime createdAt;

  const EvacuationCenter({
    required this.id,
    required this.name,
    required this.label,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.capacity,
    required this.facilities,
    this.isActive = true,
    required this.createdAt,
  });

  /// Get LatLng for map integration
  LatLng get position => LatLng(latitude, longitude);

  /// Convert to JSON for storage or transmission
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'label': label,
    'latitude': latitude,
    'longitude': longitude,
    'description': description,
    'capacity': capacity,
    'facilities': facilities,
    'isActive': isActive,
    'createdAt': createdAt.toIso8601String(),
  };

  /// Create from JSON
  factory EvacuationCenter.fromJson(Map<String, dynamic> json) {
    return EvacuationCenter(
      id: json['id'] as String,
      name: json['name'] as String,
      label: json['label'] as String,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      description: json['description'] as String,
      capacity: json['capacity'] as String,
      facilities: List<String>.from(json['facilities'] as List),
      isActive: json['isActive'] as bool? ?? true,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  @override
  String toString() => 'EvacuationCenter(id: $id, name: $name, label: $label)';
}

/// Mock evacuation centers data for VSU campus
/// 
/// Coordinates are approximate locations within VSU campus
/// These are hardcoded for demonstration purposes
final List<EvacuationCenter> mockEvacuationCenters = [
  EvacuationCenter(
    id: 'ec001',
    name: 'VSU Main Gymnasium',
    label: 'Evacuation Center A',
    latitude: 10.2968,
    longitude: 124.2089,
    description: 'Large gymnasium with open space for evacuation',
    capacity: '800 people',
    facilities: ['First Aid', 'Water', 'Food', 'Restrooms', 'Power Outlets'],
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
  ),
  EvacuationCenter(
    id: 'ec002',
    name: 'VSU Student Center',
    label: 'Evacuation Center B',
    latitude: 10.2975,
    longitude: 124.2095,
    description: 'Multi-story student facility with multiple rooms',
    capacity: '600 people',
    facilities: ['First Aid', 'Water', 'Food', 'Restrooms', 'Sleeping Areas'],
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
  ),
  EvacuationCenter(
    id: 'ec003',
    name: 'VSU Library Building',
    label: 'Evacuation Center C',
    latitude: 10.2960,
    longitude: 124.2075,
    description: 'Climate-controlled library space',
    capacity: '400 people',
    facilities: ['First Aid', 'Water', 'Restrooms', 'Power Outlets'],
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
  ),
  EvacuationCenter(
    id: 'ec004',
    name: 'VSU Medical Center',
    label: 'Evacuation Center D',
    latitude: 10.2980,
    longitude: 124.2100,
    description: 'Facility with medical and nursing staff on-site',
    capacity: '200 people',
    facilities: ['Medical Care', 'First Aid', 'Water', 'Medicine', 'Restrooms'],
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
  ),
  EvacuationCenter(
    id: 'ec005',
    name: 'VSU Open Grounds',
    label: 'Evacuation Center E',
    latitude: 10.2950,
    longitude: 124.2085,
    description: 'Large outdoor area for emergency gathering',
    capacity: '1000+ people',
    facilities: ['Open Space', 'Water Stations', 'Temporary Shelter'],
    isActive: true,
    createdAt: DateTime(2026, 1, 1),
  ),
];
