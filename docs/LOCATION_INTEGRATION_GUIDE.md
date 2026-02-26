# Location Sharing Integration Guide

## Overview
The ResQ Mobile app now includes full device GPS location integration using the Geolocator package. Users can enable location sharing, fetch their current GPS coordinates, and have them automatically displayed and updated.

## Components

### 1. LocationService (`lib/services/location_service.dart`)
Handles all device location operations:
- **getCurrentLocation()**: Fetches current GPS coordinates with accuracy metadata
- **getPermissionStatus()**: Checks current location permission status
- **requestPermission()**: Requests location permission from user
- **isLocationServiceEnabled()**: Verifies device location services are enabled
- **LocationData**: Model class for structured location data (latitude, longitude, accuracy, altitude, timestamp)

### 2. App State Integration
**AppState** now includes:
- `locationEnabled`: Boolean flag for sharing status
- `currentLocation`: LocationData object with GPS coordinates
- `lastLocationUpdate`: Timestamp of most recent location fetch

**AppStateNotifier** provides:
- `setCurrentLocation(LocationData?)`: Update location in app state
- `setLocationEnabled(bool)`: Toggle location sharing on/off

### 3. Home Screen Updates
**Location Card UI** displays:
- Status indicator (ON/OFF)
- GPS Coordinates (latitude, longitude)
- Accuracy in meters
- Last update timestamp
- Action buttons:
  - "Enable Location Sharing" (when disabled)
  - "Update Location" (when enabled)
  - Inline refresh button (top-right of card)

### 4. Location Workflow

#### Initial Permission Check
When app starts, `_checkLocationPermission()` runs:
1. Checks current permission status
2. If already granted, automatically fetches location
3. Updates UI to show location is enabled

#### User Requests Location
When user taps "Enable Location Sharing":
1. `_requestLocationPermission()` prompts for permission
2. If granted, immediately calls `_fetchCurrentLocation()`
3. If denied but not permanent, shows error message
4. If permanently denied, opens app settings

#### Fetch Location
`_fetchCurrentLocation()`:
1. Calls `LocationService.getCurrentLocation()`
2. Validates all permissions are in place
3. Requests device GPS coordinates
4. Updates app state with location data
5. Shows success/error feedback to user
6. Updates UI with coordinates and accuracy

## Platform Permissions

### Android (`android/app/build.gradle`)
Already configured via geolocator plugin:
- `android.permission.ACCESS_FINE_LOCATION` (precise GPS)
- `android.permission.ACCESS_COARSE_LOCATION` (approximate location)
- `android.permission.INTERNET` (for location services)

### iOS (`ios/Runner/Info.plist`)
Add these keys for location access:
```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>ResQ needs your location to help emergency responders find you</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>ResQ needs your location to help emergency responders find you</string>
```

## Usage Examples

### Enable Location Sharing
```dart
// User taps "Enable Location Sharing" button
await _requestLocationPermission();
// Permission granted → automatically fetches location
```

### Manual Location Update
```dart
// User taps "Update Location" button
await _fetchCurrentLocation();
// Fetches new GPS coordinates and updates UI
```

### Access Current Location in Code
```dart
final location = appStateProvider.state.currentLocation;
if (location != null) {
  print('Lat: ${location.latitude}, Lng: ${location.longitude}');
  print('Accuracy: ${location.accuracy}m');
}
```

## Data Format

### LocationData JSON (for backend transmission)
```json
{
  "latitude": 37.7749,
  "longitude": -122.4194,
  "accuracy": 8.5,
  "altitude": 45.0,
  "timestamp": "2026-02-26T14:30:45.123Z"
}
```

## Error Handling

The app handles these scenarios gracefully:

| Scenario | Handling |
|----------|----------|
| Location services disabled | Shows error, prompts user to enable in settings |
| Permission denied | Shows error message, asks user to enable in app settings |
| Permission permanently denied | Opens app settings automatically |
| GPS timeout/unavailable | Shows error, lets user retry |
| First-time permission request | Shows iOS/Android system prompt, auto-fetches on grant |

## Accessibility Features

- **Refresh Button**: Accessible via tooltip, updates location without full re-enable
- **Coordinates Display**: Selectable text for copy/paste
- **Accuracy Indicator**: Visual feedback on location precision (GPS accuracy in meters)
- **Clear Status**: "ON"/"OFF" indicator with color coding (green when enabled)
- **Feedback Messages**: Toast notifications for all location actions

## Dependencies

- **geolocator: ^9.0.2**: Device GPS and location services
- **permission_handler: ^11.3.1**: Permission management (reused)
- **provider: ^6.1.0**: State management (reused)

## Testing

### Manual Testing Checklist
- [ ] First app launch: Automatically detects and requests location permission
- [ ] Grant permission: Location is fetched and displayed
- [ ] Deny permission: Error shown, can retry with button
- [ ] Tab "Update Location": New coordinates fetched
- [ ] Close and reopen app: Location permission remembered
- [ ] Open app settings: Manually grant location, app detects change
- [ ] Offline mode: Location card still functional (uses last location)
- [ ] Coordinates accuracy: Compare with Google Maps or other GPS app

### Device Requirements
- GPS hardware required
- Location services must be enabled on device
- Android 5.0+ (API 21+)
- iOS 11.0+

## Future Enhancements

Potential improvements for future versions:
- [ ] Location history tracking
- [ ] Background location updates (for emergency mode)
- [ ] Location sharing with specific responders
- [ ] Map integration showing user location
- [ ] Periodic location polling
- [ ] Location accuracy improvement (multi-point averaging)
