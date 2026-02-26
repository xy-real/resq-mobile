import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../models/evacuation_center.dart';

/// Widget to display evacuation centers on a map
class EvacuationCenterMapWidget extends StatelessWidget {
  final List<EvacuationCenter> centers;
  final Position? userLocation;
  final Function(EvacuationCenter)? onCenterTapped;
  final double initialZoom;

  const EvacuationCenterMapWidget({
    super.key,
    required this.centers,
    this.userLocation,
    this.onCenterTapped,
    this.initialZoom = 13.0,
  });

  @override
  Widget build(BuildContext context) {
    // Calculate initial center (user location or first center or default)
    LatLng initialCenter;
    
    if (userLocation != null) {
      initialCenter = LatLng(userLocation!.latitude, userLocation!.longitude);
    } else if (centers.isNotEmpty) {
      initialCenter = LatLng(centers.first.latitude, centers.first.longitude);
    } else {
      // Default to Philippines center
      initialCenter = const LatLng(14.5995, 120.9842);
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: initialCenter,
        initialZoom: initialZoom,
        minZoom: 5.0,
        maxZoom: 18.0,
      ),
      children: [
        // Map tiles layer (OpenStreetMap)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.resq.mobile',
          maxZoom: 19,
        ),
        
        // Evacuation center markers
        MarkerLayer(
          markers: centers.map((center) {
            return Marker(
              point: LatLng(center.latitude, center.longitude),
              width: 40,
              height: 40,
              child: GestureDetector(
                onTap: () => onCenterTapped?.call(center),
                child: const Icon(
                  Icons.location_on,
                  color: Colors.red,
                  size: 40,
                ),
              ),
            );
          }).toList(),
        ),
        
        // User location marker (if available)
        if (userLocation != null)
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(userLocation!.latitude, userLocation!.longitude),
                width: 30,
                height: 30,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.7),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

/// Bottom sheet to show evacuation center details
class EvacuationCenterDetailsSheet extends StatelessWidget {
  final EvacuationCenter center;
  final Position? userLocation;

  const EvacuationCenterDetailsSheet({
    super.key,
    required this.center,
    this.userLocation,
  });

  String _formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  @override
  Widget build(BuildContext context) {
    String? distanceText;
    
    if (userLocation != null) {
      final distance = center.distanceFrom(
        userLocation!.latitude,
        userLocation!.longitude,
      );
      distanceText = _formatDistance(distance);
    }

    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.red, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  center.centerName,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Coordinates
          Row(
            children: [
              const Icon(Icons.map, size: 20, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                '${center.latitude.toStringAsFixed(6)}, ${center.longitude.toStringAsFixed(6)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          // Distance (if user location available)
          if (distanceText != null)
            Row(
              children: [
                const Icon(Icons.directions, size: 20, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Distance: $distanceText',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          
          const SizedBox(height: 20),
          
          // Action button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // TODO: Open in maps app
                Navigator.pop(context);
              },
              icon: const Icon(Icons.directions),
              label: const Text('Get Directions'),
            ),
          ),
        ],
      ),
    );
  }
}
