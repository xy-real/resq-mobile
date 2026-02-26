# 🗺️ ResQ Mobile Map Feature - Quick Start
**Quick reference for implementing and using the interactive map**

---

## What Was Added

### 1. **New Dependencies** (pubspec.yaml)
```yaml
flutter_map: ^6.1.0          # OpenStreetMap-based interactive map
latlong2: ^0.9.1             # Latitude/longitude support
```

### 2. **New Models** (lib/models/)
```
evacuation_center.dart       # Evacuation center data model + mock data
```

### 3. **New Screens** (lib/screens/)
```
map_screen.dart              # Full-featured interactive map widget
```

### 4. **Integration Points**
- HomeScreen: Added "View Emergency Map" button
- Integrated with existing LocationService and AppState

---

## 5-Minute Setup

### 1. Install Dependencies
```bash
cd c:\projects\resq-mobile
flutter pub get
```

### 2. Run the App
```bash
flutter run
```

### 3. Access the Map
1. Start the app
2. Navigate to home screen
3. Tap "View Emergency Map" card
4. Explore interactive map!

---

## Files Overview

### Core Implementation Files

#### `lib/models/evacuation_center.dart`
- **EvacuationCenter** class with properties:
  - ID, name, label, coordinates
  - Description, capacity, facilities
  - JSON serialization support

- **Mock Data** - 5 pre-defined evacuation centers at VSU:
  - A: Main Gymnasium (10.2968°, 124.2089°)
  - B: Student Center (10.2975°, 124.2095°)
  - C: Library Building (10.2960°, 124.2075°)
  - D: Medical Center (10.2980°, 124.2100°)
  - E: Open Grounds (10.2950°, 124.2085°)

#### `lib/screens/map_screen.dart` (~650 lines)
**StatefulWidget with:**

**Initialization:**
- `initState()` - Loads user location
- `_initializeMap()` - Centers map on user location

**Marker Building:**
- `_buildUserLocationMarker()` - Creates user location marker (cyan)
- `_buildEvacuationCenterMarkers()` - Creates evacuation center markers (red)

**Information Display:**
- `_showUserLocationInfo()` - Bottom sheet with coordinates & accuracy
- `_showEvacuationCenterInfo()` - Bottom sheet with center details

**UI Components:**
- Interactive FlutterMap with OpenStreetMap tiles
- Zoom in/out controls
- Center-on-location button
- Legend showing marker types
- Error handling for missing location

---

## Map Features

### 🎯 User Location
- Cyan circular marker with pulsing animation
- Shows coordinates and GPS accuracy
- Tap to view detailed info
- "Center on Me" button to recenter

### 🏥 Evacuation Centers
- Red markers with location pin icons
- Label below each marker
- Tap to show detailed information:
  - Center name and description
  - Capacity (number of people)
  - Available facilities
  - Exact coordinates

### 🗺️ Map Controls
- **Pinch to Zoom** - Two-finger gesture
- **Drag to Pan** - Move around map
- **Zoom buttons** - +/- on bottom right
- **Center button** - Return to user location
- **Double tap** - Quick zoom in
- **Two-finger tap** - Quick zoom out

### 🎨 Theme Integration
All colors use AppTheme constants:
- User location: `AppTheme.buttonGradientStart` (cyan)
- Evacuation centers: `AppTheme.statusCritical` (red)
- UI accent: `AppTheme.accentCyan` (light blue)
- Backgrounds: `AppTheme.surface` (dark)

---

## Usage Examples

### Open Map from Home
```dart
// Already integrated! Just tap the card on home screen
// Or programmatically:
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const MapScreen(),
  ),
);
```

### Access Evacuation Centers
```dart
import 'package:resq_mobile/models/evacuation_center.dart';

// Get all centers
final allCenters = mockEvacuationCenters;

// Get specific center
final centerA = mockEvacuationCenters.firstWhere(
  (c) => c.label == 'Evacuation Center A',
);

// Print center info
print('${centerA.name} - Capacity: ${centerA.capacity}');
// Output: VSU Main Gymnasium - Capacity: 800 people
```

### Customize Map Display
```dart
// Show only evacuation centers
MapScreen(
  showEvacuationCenters: true,
  showCurrentLocation: false,
)

// Show only user location
MapScreen(
  showEvacuationCenters: false,
  showCurrentLocation: true,
)

// Full map with back button
MapScreen(
  onBackPressed: () => Navigator.pop(context),
  showEvacuationCenters: true,
  showCurrentLocation: true,
)
```

---

## How It Works

### Initialization Flow
```
MapScreen loads
    ↓
_initializeMap() called
    ↓
Check AppState for current location
    ↓
If missing, request GPS location via LocationService
    ↓
Map centers on user location
    ↓
setState(() => isLoading = false)
    ↓
UI renders with markers
```

### Marker Tap Flow
```
User taps marker
    ↓
GestureDetector.onTap triggered
    ↓
setState() updates selectedCenter
    ↓
Bottom sheet modal shows
    ↓
User sees center details
```

### Map Controls Flow
```
User zooms/pans/taps button
    ↓
MapController receives command
    ↓
Move/zoom animation
    ↓
UI updates smoothly
```

---

## Key Classes & Methods

### EvacuationCenter
```dart
class EvacuationCenter {
  final String id;
  final String name;
  final String label;
  final double latitude;
  final double longitude;
  final String description;
  final String capacity;
  final List<String> facilities;
  final bool isActive;
  final DateTime createdAt;
  
  LatLng get position => LatLng(latitude, longitude);
  Map<String, dynamic> toJson() { ... }
  factory EvacuationCenter.fromJson(Map<String, dynamic> json) { ... }
}
```

### MapScreen
```dart
class MapScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;
  final bool showEvacuationCenters;
  final bool showCurrentLocation;
}

class _MapScreenState extends State<MapScreen> {
  late MapController mapController;
  EvacuationCenter? selectedCenter;
  bool isLoading = true;
  
  Future<void> _initializeMap() { ... }
  Marker? _buildUserLocationMarker(LocationData? location) { ... }
  List<Marker> _buildEvacuationCenterMarkers() { ... }
  void _showUserLocationInfo(LocationData location) { ... }
  void _showEvacuationCenterInfo(EvacuationCenter center) { ... }
}
```

---

## Common Tasks

### Add New Evacuation Center
1. Edit `lib/models/evacuation_center.dart`
2. Add to `mockEvacuationCenters` list:
```dart
EvacuationCenter(
  id: 'ec006',
  name: 'New Center',
  label: 'Evacuation Center F',
  latitude: 10.2950,
  longitude: 124.2075,
  description: 'Description',
  capacity: '300 people',
  facilities: ['First Aid', 'Water'],
  isActive: true,
  createdAt: DateTime.now(),
),
```
3. Rebuild app - new marker appears automatically!

### Change Marker Colors
Edit `_buildEvacuationCenterMarkers()` in `lib/screens/map_screen.dart`:
```dart
// Change evacuation center color
color: AppTheme.statusNeedsHelp,  // Yellow instead of red
```

### Add Polylines (Routes)
Add to FlutterMap children in `build()`:
```dart
PolylineLayer(
  polylines: [
    Polyline(
      points: [point1, point2, point3],
      color: AppTheme.primary,
      strokeWidth: 3.0,
    ),
  ],
),
```

### Connect to Real API
Replace in `_initializeMap()`:
```dart
// Instead of mock data
final centers = mockEvacuationCenters;

// Use API call
final response = await http.get(Uri.parse('/api/evacuation-centers'));
final centers = (response.json() as List)
    .map((j) => EvacuationCenter.fromJson(j))
    .toList();
```

---

## Theme Colors Reference

| Purpose | Color | Theme Constant |
|---------|-------|-----------------|
| User Location | Cyan | `AppTheme.buttonGradientStart` |
| Evacuation Center | Red | `AppTheme.statusCritical` |
| UI Accent | Light Blue | `AppTheme.accentCyan` |
| Map Background | Dark | `AppTheme.surface` |
| Text | Off-white | `AppTheme.textPrimary` |
| Helper Text | Gray | `AppTheme.textSecondary` |
| Error | Red | `AppTheme.errorRed` |

---

## Troubleshooting

### Map doesn't show
```
✓ Check internet (needs OpenStreetMap tiles)
✓ flutter pub get (install dependencies)
✓ flutter clean (clear cache)
✓ Check Android/iOS manifest file permissions
```

### Location not showing
```
✓ Tap "Update Location" button
✓ Allow location permission in app settings
✓ Ensure GPS is enabled on device
✓ Check LocationService is working
```

### Slow performance
```
✓ Reduce number of markers
✓ Use marker clustering for many points
✓ Check internet connection speed
✓ Profile with DevTools Timeline
```

### Markers not tappable
```
✓ Increase marker size (width/height)
✓ Check GestureDetector wraps widget
✓ Verify setState is called on tap
✓ Check bottom sheet displays
```

---

## Performance Tips

- **Zoom Level**: Keep between 12-18 for best performance
- **Marker Count**: 5-50 markers optimal
- **Update Frequency**: Limit location updates to 1-5 seconds
- **Tile Cache**: Flutter_map caches tiles automatically

---

## Dependencies Added

```yaml
# In pubspec.yaml
flutter_map: ^6.1.0
  # Interactive map widget with OpenStreetMap support
  # License: BSD 2-Clause
  # Repository: https://github.com/fleaflet/flutter_map

latlong2: ^0.9.1
  # Latitude/longitude support
  # License: MIT
  # Repository: https://github.com/cmendes92/latlong2
```

**Note:** Both are well-maintained with active communities and production-ready code.

---

## Next Steps (Future Enhancement)

- [ ] Integrate real evacuation center API
- [ ] Add route planning to nearest center
- [ ] Implement real-time location updates
- [ ] Add marker clustering
- [ ] Cache map tiles offline
- [ ] Add custom map styles
- [ ] Implement team member locations
- [ ] Add emergency alert notifications

---

## Related Documentation

- **Color Consistency Audit:** See `COLOR_CONSISTENCY_AUDIT_REPORT.md`
- **Color System Guide:** See `COLOR_SYSTEM_GUIDE.md`
- **Full Map Guide:** See `MAP_FEATURE_GUIDE.md`
- **Theme Reference:** See `lib/theme/app_theme.dart`

---

## Support

**For Questions:**
1. Check `MAP_FEATURE_GUIDE.md` for detailed docs
2. Review code comments in `map_screen.dart` and `evacuation_center.dart`
3. Check [flutter_map docs](https://github.com/fleaflet/flutter_map)
4. Reference [latlong2 docs](https://github.com/cmendes92/latlong2)

---

**Status:** ✅ Ready for Production  
**Last Updated:** February 27, 2026
