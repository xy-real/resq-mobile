import 'dart:math' as math;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart';
import '../models/evacuation_center.dart';

/// Service for fetching evacuation center data from Supabase backend
/// 
/// This service manages:
/// - Fetching evacuationcenters from the EVACUATION_CENTERS table
/// - Caching evacuation center data locally
/// - All communication with Supabase database
class EvacuationCenterService {
  static final EvacuationCenterService _instance = EvacuationCenterService._internal();
  final SupabaseClient _supabase = Supabase.instance.client;
  
  // Cache for evacuation centers
  List<EvacuationCenter>? _cachedCenters;
  DateTime? _cacheTime;
  static const Duration _cacheDuration = Duration(minutes: 30);

  factory EvacuationCenterService() {
    return _instance;
  }

  EvacuationCenterService._internal();

  // Getters
  SupabaseClient get supabase => _supabase;
  User? get currentUser => _supabase.auth.currentUser;
  bool get isAuthenticated => currentUser != null;

  /// Fetch all evacuation centers from the database
  /// 
  /// Returns cached data if available and fresh (within 30 minutes).
  /// Otherwise, fetches from Supabase and caches the result.
  /// 
  /// All authenticated users can view evacuation centers per RLS policy.
  /// 
  /// Returns: List of EvacuationCenter objects ordered by center_name
  /// Throws: Exception if query fails or user not authenticated
  Future<List<EvacuationCenter>> getEvacuationCenters({bool forceRefresh = false}) async {
    try {
      if (!isAuthenticated) {
        throw 'User not authenticated. Cannot fetch evacuation centers.';
      }

      // Return cached data if valid and not forcing refresh
      if (!forceRefresh && _cachedCenters != null && _cacheTime != null) {
        final now = DateTime.now();
        if (now.difference(_cacheTime!) < _cacheDuration) {
          debugPrint('Returning cached evacuation centers (${_cachedCenters!.length} centers)');
          return _cachedCenters!;
        }
      }

      // Fetch from Supabase
      final response = await _supabase
          .from('evacuation_centers')
          .select()
          .order('center_name');

      debugPrint('Fetched ${response.length} evacuation centers from Supabase');

      // Convert to EvacuationCenter objects
      final centers = (response as List)
          .map((data) => _parseEvacuationCenter(data))
          .toList();

      // Cache the results
      _cachedCenters = centers;
      _cacheTime = DateTime.now();

      return centers;
    } catch (e) {
      debugPrint('Error fetching evacuation centers: $e');
      
      // Return cached data even if expired, as fallback
      if (_cachedCenters != null) {
        debugPrint('Returning stale cached evacuation centers as fallback');
        return _cachedCenters!;
      }
      
      rethrow;
    }
  }

  /// Get a specific evacuation center by ID
  /// 
  /// Parameters:
  ///   - centerId: The UUID of the evacuation center
  /// 
  /// Returns: EvacuationCenter object or null if not found
  /// Throws: Exception if query fails
  Future<EvacuationCenter?> getEvacuationCenter(String centerId) async {
    try {
      if (!isAuthenticated) {
        throw 'User not authenticated';
      }

      final response = await _supabase
          .from('evacuation_centers')
          .select()
          .eq('id', centerId)
          .maybeSingle();

      if (response == null) {
        return null;
      }

      return _parseEvacuationCenter(response);
    } catch (e) {
      debugPrint('Error fetching evacuation center $centerId: $e');
      return null;
    }
  }

  /// Get evacuation centers nearby to a specific location
  /// 
  /// Note: This is a simple in-memory filter. For production with large
  /// datasets, consider using PostGIS on the backend for spatial queries.
  /// 
  /// Parameters:
  ///   - latitude: Search center latitude
  ///   - longitude: Search center longitude
  ///   - radiusKm: Search radius in kilometers (default: 5km)
  /// 
  /// Returns: List of nearby EvacuationCenter objects, sorted by distance
  /// Throws: Exception if fetch fails
  Future<List<EvacuationCenter>> getNearbyEvacuationCenters({
    required double latitude,
    required double longitude,
    double radiusKm = 5.0,
  }) async {
    try {
      final allCenters = await getEvacuationCenters();
      
      // Calculate distance and filter
      final nearby = <({EvacuationCenter center, double distance})>[];
      
      for (final center in allCenters) {
        final distance = _calculateDistance(
          latitude,
          longitude,
          center.latitude,
          center.longitude,
        );
        
        if (distance <= radiusKm) {
          nearby.add((center: center, distance: distance));
        }
      }
      
      // Sort by distance (closest first)
      nearby.sort((a, b) => a.distance.compareTo(b.distance));
      
      return nearby.map((item) => item.center).toList();
    } catch (e) {
      debugPrint('Error finding nearby evacuation centers: $e');
      rethrow;
    }
  }

  /// Clear the evacuation center cache
  void clearCache() {
    _cachedCenters = null;
    _cacheTime = null;
    debugPrint('Evacuation center cache cleared');
  }

  /// Parse a Supabase response row into an EvacuationCenter object
  /// 
  /// Handles the mapping from database column names to model fields.
  /// Database columns:
  ///   - id (UUID)
  ///   - center_name (TEXT)
  ///   - latitude (DECIMAL)
  ///   - longitude (DECIMAL)
  EvacuationCenter _parseEvacuationCenter(Map<String, dynamic> data) {
    return EvacuationCenter(
      id: data['id'] as String,
      name: data['center_name'] as String,
      label: _generateLabel(data['center_name'] as String),
      latitude: (data['latitude'] as num).toDouble(),
      longitude: (data['longitude'] as num).toDouble(),
      description: 'Designated evacuation center',
      capacity: 'Unknown',
      facilities: ["First Aid", "Water", "Food"],
      isActive: true,
      createdAt: DateTime.now(),
    );
  }

  /// Generate a short label from center name for map display
  /// 
  /// Example: "VSU Main Gymnasium" → "Evacuation Center A"
  /// Uses a simple scheme based on the center's position in the list.
  String _generateLabel(String centerName) {
    // For now, generate a generic label
    // In a real app, this could be based on the center's ID or a separate database field
    final char = String.fromCharCode(65 + ((centerName.hashCode.abs()) % 26));
    return 'Evacuation Center $char';
  }

  /// Calculate distance between two geographic points in kilometers
  /// 
  /// Uses the Haversine formula for approximate distance without external dependencies.
  /// 
  /// Parameters:
  ///   - lat1, lon1: First point (latitude, longitude)
  ///   - lat2, lon2: Second point (latitude, longitude)
  /// 
  /// Returns: Distance in kilometers
  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadiusKm = 6371.0;
    
    final dLat = _toRad(lat2 - lat1);
    final dLon = _toRad(lon2 - lon1);
    
    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) *
            math.cos(_toRad(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    
    return earthRadiusKm * c;
  }

  /// Convert degrees to radians
  double _toRad(double degrees) {
    return degrees * (3.14159265359 / 180.0);
  }
}