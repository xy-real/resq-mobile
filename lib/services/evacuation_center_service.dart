import '../main.dart';
import '../models/evacuation_center.dart';

/// Service for managing evacuation centers
class EvacuationCenterService {
  /// Fetch all evacuation centers from database
  Future<List<EvacuationCenter>> getEvacuationCenters() async {
    try {
      final response = await supabase
          .from('evacuation_centers')
          .select()
          .order('center_name');

      return (response as List)
          .map((json) => EvacuationCenter.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch evacuation centers: ${e.toString()}');
    }
  }

  /// Get evacuation center by ID
  Future<EvacuationCenter?> getEvacuationCenterById(String id) async {
    try {
      final response = await supabase
          .from('evacuation_centers')
          .select()
          .eq('id', id)
          .single();

      return EvacuationCenter.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Find nearest evacuation center to given coordinates
  Future<EvacuationCenter?> findNearestCenter({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final centers = await getEvacuationCenters();
      
      if (centers.isEmpty) return null;

      // Calculate distances and sort
      centers.sort((a, b) {
        final distanceA = a.distanceFrom(latitude, longitude);
        final distanceB = b.distanceFrom(latitude, longitude);
        return distanceA.compareTo(distanceB);
      });

      return centers.first;
    } catch (e) {
      return null;
    }
  }

  /// Get evacuation centers within radius (in meters)
  Future<List<EvacuationCenter>> getCentersWithinRadius({
    required double latitude,
    required double longitude,
    required double radiusMeters,
  }) async {
    try {
      final centers = await getEvacuationCenters();
      
      return centers.where((center) {
        final distance = center.distanceFrom(latitude, longitude);
        return distance <= radiusMeters;
      }).toList();
    } catch (e) {
      return [];
    }
  }

  /// Format distance for display
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.toStringAsFixed(0)} m';
    } else {
      final km = meters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  /// Get center details with distance from user location
  Future<Map<String, dynamic>> getCenterWithDistance({
    required String centerId,
    required double userLat,
    required double userLng,
  }) async {
    final center = await getEvacuationCenterById(centerId);
    
    if (center == null) {
      throw Exception('Center not found');
    }

    final distance = center.distanceFrom(userLat, userLng);

    return {
      'center': center,
      'distance_meters': distance,
      'distance_formatted': formatDistance(distance),
    };
  }
}
