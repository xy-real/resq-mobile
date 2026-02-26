import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Represents the current state of the application
class AppState {
  final String studentId;
  final String? currentStatus;
  final DateTime? lastUpdated;
  final bool disasterMode;
  final bool isConnected;
  final bool locationEnabled;
  final DateTime? lastLocationUpdate;

  AppState({
    required this.studentId,
    this.currentStatus,
    this.lastUpdated,
    this.disasterMode = false,
    this.isConnected = true,
    this.locationEnabled = false,
    this.lastLocationUpdate,
  });

  /// Create a copy of this state with some fields replaced
  AppState copyWith({
    String? studentId,
    String? currentStatus,
    DateTime? lastUpdated,
    bool? disasterMode,
    bool? isConnected,
    bool? locationEnabled,
    DateTime? lastLocationUpdate,
  }) {
    return AppState(
      studentId: studentId ?? this.studentId,
      currentStatus: currentStatus ?? this.currentStatus,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      disasterMode: disasterMode ?? this.disasterMode,
      isConnected: isConnected ?? this.isConnected,
      locationEnabled: locationEnabled ?? this.locationEnabled,
      lastLocationUpdate: lastLocationUpdate ?? this.lastLocationUpdate,
    );
  }

  @override
  String toString() => 'AppState('
      'studentId: $studentId, '
      'currentStatus: $currentStatus, '
      'lastUpdated: $lastUpdated, '
      'disasterMode: $disasterMode, '
      'isConnected: $isConnected, '
      'locationEnabled: $locationEnabled, '
      'lastLocationUpdate: $lastLocationUpdate)';
}

/// Notifier for managing app state and persistence
class AppStateNotifier extends ChangeNotifier {
  late SharedPreferences _prefs;
  AppState _state = AppState(studentId: '');
  bool _isInitialized = false;

  // Persistence keys
  static const String _studentIdKey = 'student_id';
  static const String _currentStatusKey = 'current_status';
  static const String _lastUpdatedKey = 'last_updated';

  AppState get state => _state;
  bool get isInitialized => _isInitialized;

  /// Initialize the notifier by loading saved preferences
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();

    final studentId = _prefs.getString(_studentIdKey) ?? '';
    final currentStatus = _prefs.getString(_currentStatusKey);
    final lastUpdatedStr = _prefs.getString(_lastUpdatedKey);
    final lastUpdated = lastUpdatedStr != null
        ? DateTime.tryParse(lastUpdatedStr)
        : null;

    _state = AppState(
      studentId: studentId,
      currentStatus: currentStatus,
      lastUpdated: lastUpdated,
    );

    _isInitialized = true;
    notifyListeners();
  }

  /// Set student ID
  Future<void> setStudentId(String studentId) async {
    _state = _state.copyWith(studentId: studentId);
    await _prefs.setString(_studentIdKey, studentId);
    notifyListeners();
  }

  /// Update the current status
  Future<void> updateStatus(String status) async {
    final now = DateTime.now();
    _state = _state.copyWith(
      currentStatus: status,
      lastUpdated: now,
    );

    await Future.wait([
      _prefs.setString(_currentStatusKey, status),
      _prefs.setString(_lastUpdatedKey, now.toIso8601String()),
    ]);

    notifyListeners();
  }

  /// Update connectivity status
  void setConnectivityStatus(bool isConnected) {
    if (_state.isConnected != isConnected) {
      _state = _state.copyWith(isConnected: isConnected);
      notifyListeners();
    }
  }

  /// Update disaster mode status
  void setDisasterMode(bool disasterMode) {
    if (_state.disasterMode != disasterMode) {
      _state = _state.copyWith(disasterMode: disasterMode);
      notifyListeners();
    }
  }

  /// Update location enabled status
  void setLocationEnabled(bool locationEnabled) {
    if (_state.locationEnabled != locationEnabled) {
      _state = _state.copyWith(locationEnabled: locationEnabled);
      notifyListeners();
    }
  }

  /// Update last location update time
  void setLastLocationUpdate(DateTime dateTime) {
    _state = _state.copyWith(lastLocationUpdate: dateTime);
    notifyListeners();
  }

  /// Clear current status
  Future<void> clearStatus() async {
    _state = _state.copyWith(currentStatus: null, lastUpdated: null);
    await _prefs.remove(_currentStatusKey);
    await _prefs.remove(_lastUpdatedKey);
    notifyListeners();
  }
}

/// Provider for app state
late AppStateNotifier appStateProvider;

/// Initialize the global app state provider
Future<void> initializeAppState() async {
  appStateProvider = AppStateNotifier();
  await appStateProvider.initialize();
}
