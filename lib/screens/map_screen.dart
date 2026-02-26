import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../models/evacuation_center.dart';
import '../services/location_service.dart';
import '../providers/app_state_provider.dart';

/// Interactive map screen showing user location and evacuation centers
/// 
/// Features:
/// - Displays user's current location with marker
/// - Shows nearby evacuation centers with themed markers
/// - Interactive zoom, pan, and marker tap controls
/// - Theme-aware UI with dark mode and cyan accents
/// - Reusable widget for integration into main screen
/// - Mock evacuation center data for VSU campus
class MapScreen extends StatefulWidget {
  /// Optional callback when a user navigates back
  final VoidCallback? onBackPressed;
  
  /// Whether to show the evacuation centers (default: true)
  final bool showEvacuationCenters;
  
  /// Whether to show user's current location (default: true)
  final bool showCurrentLocation;

  const MapScreen({
    super.key,
    this.onBackPressed,
    this.showEvacuationCenters = true,
    this.showCurrentLocation = true,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late MapController mapController;
  EvacuationCenter? selectedCenter;
  bool isLoading = true;
  String? userLocationError;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _initializeMap();
  }

  /// Initialize map with user location and evacuation centers
  Future<void> _initializeMap() async {
    try {
      final appState = context.read<AppStateNotifier>();
      
      // Get current location if not already available
      if (appState.state.currentLocation == null && widget.showCurrentLocation) {
        final location = await LocationService.getCurrentLocation();
        if (location != null && mounted) {
          appState.setCurrentLocation(location);
        } else if (mounted) {
          setState(() => userLocationError = 'Unable to get current location');
        }
      }

      // Fetch evacuation centers if showing them
      if (widget.showEvacuationCenters) {
        try {
          await appState.fetchEvacuationCenters();
        } catch (e) {
          debugPrint('Error loading evacuation centers: $e');
          // Continue without evacuation centers rather than stopping the map
        }
      }

      if (mounted) {
        setState(() => isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          userLocationError = 'Error initializing map: $e';
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    mapController.dispose();
    super.dispose();
  }

  /// Build marker for user's current location
  Marker? _buildUserLocationMarker(LocationData? location) {
    if (location == null || !widget.showCurrentLocation) {
      return null;
    }

    return Marker(
      point: LatLng(location.latitude, location.longitude),
      width: 60,
      height: 60,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () {
          _showUserLocationInfo(location);
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Animated pulsing circle around user location
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTheme.buttonGradientStart,
                  width: 2,
                ),
              ),
            ),
            // Center dot - positioned on top of circle
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.buttonGradientStart,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build markers for evacuation centers
  /// 
  /// Creates visual markers for all evacuation centers provided.
  /// Accepts the list of evacuation centers from app state.
  List<Marker> _buildEvacuationCenterMarkers(List<EvacuationCenter> centers) {
    if (!widget.showEvacuationCenters || centers.isEmpty) {
      return [];
    }

    return centers.map((center) {
      final isSelected = selectedCenter?.id == center.id;

      return Marker(
        point: center.position,
        width: 60,
        height: 60,
        alignment: Alignment.center,
        child: GestureDetector(
          onTap: () {
            setState(() => selectedCenter = center);
            _showEvacuationCenterInfo(center);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Marker pin icon
              Container(
                width: isSelected ? 50 : 40,
                height: isSelected ? 50 : 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.statusCritical,
                  border: Border.all(
                    color: isSelected ? AppTheme.accentCyan : Colors.white,
                    width: isSelected ? 3 : 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.statusCritical.withValues(alpha: 0.4),
                      blurRadius: 8,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Icons.location_on,
                    color: Colors.white,
                    size: isSelected ? 24 : 18,
                  ),
                ),
              ),
              // Label below marker
              Container(
                margin: const EdgeInsets.only(top: 4),
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isSelected
                        ? AppTheme.accentCyan
                        : AppTheme.border,
                  ),
                ),
                child: Text(
                  center.label,
                  style: TextStyle(
                    color: isSelected
                        ? AppTheme.accentCyan
                        : AppTheme.textSecondary,
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  /// Show information about user's location
  void _showUserLocationInfo(LocationData location) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: AppTheme.buttonGradientStart.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: Icon(
                    Icons.my_location,
                    color: AppTheme.buttonGradientStart,
                    size: 24,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your Location',
                        style: const TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing16),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing12),
              decoration: BoxDecoration(
                color: AppTheme.backgroundDark,
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Coordinates',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SelectableText(
                    location.displayString,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Courier',
                    ),
                  ),
                  if (location.accuracy != null) ...[
                    const SizedBox(height: 12),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Accuracy',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '±${location.accuracy!.toStringAsFixed(1)}m',
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: AppTheme.spacing16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Show information about selected evacuation center
  void _showEvacuationCenterInfo(EvacuationCenter center) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusLarge),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppTheme.spacing20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing8),
                    decoration: BoxDecoration(
                      color: AppTheme.statusCritical.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    ),
                    child: Icon(
                      Icons.location_on,
                      color: AppTheme.statusCritical,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          center.label,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          center.name,
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacing16),
              
              // Description
              Text(
                center.description,
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Capacity
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.group,
                      color: AppTheme.statusSafe,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Capacity',
                          style: const TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          center.capacity,
                          style: const TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Facilities
              Text(
                'Available Facilities',
                style: const TextStyle(
                  color: AppTheme.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Wrap(
                spacing: AppTheme.spacing8,
                runSpacing: AppTheme.spacing8,
                children: center.facilities.map((facility) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacing10,
                      vertical: AppTheme.spacing4,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      facility,
                      style: const TextStyle(
                        color: AppTheme.accentCyan,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Coordinates
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Coordinates',
                      style: const TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SelectableText(
                      '${center.latitude}, ${center.longitude}',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.spacing16),

              // Action buttons
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppTheme.backgroundDark,
        leading: widget.onBackPressed != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: widget.onBackPressed,
              )
            : null,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Emergency Map',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Evacuation Centers & Your Location',
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Map
          isLoading
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.accentCyan,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing16),
                      Text(
                        'Loading map...',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                )
              : Consumer<AppStateNotifier>(
                  builder: (context, appStateNotifier, _) {
                    final location = appStateNotifier.state.currentLocation;

                    return FlutterMap(
                      mapController: mapController,
                      options: MapOptions(
                        initialCenter: location != null
                            ? LatLng(location.latitude, location.longitude)
                            : const LatLng(10.2968, 124.2089), // Default to VSU center
                        initialZoom: 15.0,
                        minZoom: 12.0,
                        maxZoom: 18.0,
                        interactionOptions: const InteractionOptions(
                          flags: InteractiveFlag.all,
                        ),
                      ),
                      children: [
                        // OpenStreetMap tiles
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.resq_mobile',
                          tileProvider: NetworkTileProvider(),
                        ),
                        // Markers layer
                        MarkerLayer(
                          markers: [
                            // User location marker
                            if (_buildUserLocationMarker(location) != null)
                              _buildUserLocationMarker(location)!,
                            // Evacuation center markers
                            ..._buildEvacuationCenterMarkers(appStateNotifier.state.evacuationCenters),
                          ],
                        ),
                      ],
                    );
                  },
                ),
          
          // Error message if location unavailable
          if (userLocationError != null && !isLoading)
            Positioned(
              top: 16,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacing12),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundError,
                  border: Border.all(color: AppTheme.errorRed),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_amber,
                      color: AppTheme.errorRed,
                      size: 20,
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    Expanded(
                      child: Text(
                        userLocationError!,
                        style: const TextStyle(
                          color: AppTheme.errorRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // Map controls (bottom right)
          Positioned(
            bottom: 24,
            right: 16,
            child: Column(
              children: [
                // Zoom in button
                FloatingActionButton(
                  mini: true,
                  backgroundColor: AppTheme.surface,
                  onPressed: () {
                    mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom + 1,
                    );
                  },
                  child: const Icon(
                    Icons.add,
                    color: AppTheme.accentCyan,
                  ),
                ),
                const SizedBox(height: 8),
                // Zoom out button
                FloatingActionButton(
                  mini: true,
                  backgroundColor: AppTheme.surface,
                  onPressed: () {
                    mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom - 1,
                    );
                  },
                  child: const Icon(
                    Icons.remove,
                    color: AppTheme.accentCyan,
                  ),
                ),
                const SizedBox(height: 8),
                // Center on user location button
                if (widget.showCurrentLocation)
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: AppTheme.surface,
                    onPressed: () async {
                      final location =
                          context.read<AppStateNotifier>().state.currentLocation;
                      if (location != null) {
                        mapController.move(
                          LatLng(location.latitude, location.longitude),
                          15.0,
                        );
                      }
                    },
                    child: const Icon(
                      Icons.my_location,
                      color: AppTheme.buttonGradientStart,
                    ),
                  ),
              ],
            ),
          ),

          // Legend (top left)
          if (widget.showEvacuationCenters || widget.showCurrentLocation)
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(AppTheme.spacing12),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  border: Border.all(color: AppTheme.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Legend',
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacing8),
                    if (widget.showCurrentLocation)
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.buttonGradientStart,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Your Location',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    if (widget.showEvacuationCenters) ...[
                      if (widget.showCurrentLocation)
                        const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppTheme.statusCritical,
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Evacuation Centers',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
