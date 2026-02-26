import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../main.dart';
import '../models/system_settings.dart';

/// Service for monitoring disaster mode status via real-time subscription
class DisasterModeService {
  SystemSettings? _currentSettings;
  RealtimeChannel? _subscription;
  final _settingsController = StreamController<SystemSettings>.broadcast();

  /// Get current disaster mode status
  SystemSettings? get currentSettings => _currentSettings;

  /// Stream of disaster mode changes
  Stream<SystemSettings> get settingsStream => _settingsController.stream;

  /// Check if disaster mode is currently active
  bool get isDisasterModeActive => _currentSettings?.isDisasterModeActive ?? false;

  /// Initialize and fetch current disaster mode status
  Future<void> initialize() async {
    await fetchDisasterModeStatus();
    _subscribeToDisasterMode();
  }

  /// Fetch current disaster mode status from database
  Future<SystemSettings> fetchDisasterModeStatus() async {
    try {
      final response = await supabase
          .from('system_settings')
          .select()
          .eq('id', 1)
          .single();

      _currentSettings = SystemSettings.fromJson(response);
      _settingsController.add(_currentSettings!);
      
      return _currentSettings!;
    } catch (e) {
      throw Exception('Failed to fetch disaster mode status: ${e.toString()}');
    }
  }

  /// Subscribe to real-time disaster mode changes
  void _subscribeToDisasterMode() {
    _subscription = supabase
        .channel('system_settings_changes')
        .onPostgresChanges(
          event: PostgresChangeEvent.update,
          schema: 'public',
          table: 'system_settings',
          callback: (payload) {
            final newData = payload.newRecord;
            if (newData != null) {
              _currentSettings = SystemSettings.fromJson(newData);
              _settingsController.add(_currentSettings!);
            }
          },
        )
        .subscribe();
  }

  /// Get time since disaster mode was activated
  Duration? getTimeSinceActivation() {
    if (_currentSettings == null || 
        !_currentSettings!.isDisasterModeActive ||
        _currentSettings!.modeActivatedAt == null) {
      return null;
    }

    return DateTime.now().difference(_currentSettings!.modeActivatedAt!);
  }

  /// Check if it's been more than 6 hours since last update
  /// (for determining if student should be marked as UNKNOWN)
  bool shouldMarkAsUnknown(DateTime? lastUpdateTimestamp) {
    if (!isDisasterModeActive) return false;
    if (lastUpdateTimestamp == null) return true;

    final hoursSinceUpdate = DateTime.now().difference(lastUpdateTimestamp).inHours;
    return hoursSinceUpdate >= 6;
  }

  /// Get formatted disaster mode status message
  String getStatusMessage() {
    if (!isDisasterModeActive) {
      return 'Normal Mode - Location tracking is disabled';
    }

    final timeSince = getTimeSinceActivation();
    if (timeSince == null) {
      return 'Disaster Mode Active';
    }

    final hours = timeSince.inHours;
    final minutes = timeSince.inMinutes % 60;
    
    if (hours > 0) {
      return 'Disaster Mode Active - ${hours}h ${minutes}m ago';
    } else {
      return 'Disaster Mode Active - ${minutes}m ago';
    }
  }

  /// Check if location tracking should be enabled
  bool shouldEnableLocationTracking() {
    return isDisasterModeActive;
  }

  /// Dispose resources and close subscriptions
  void dispose() {
    _subscription?.unsubscribe();
    _settingsController.close();
  }
}
