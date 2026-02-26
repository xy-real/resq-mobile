import 'dart:async';
import '../config/supabase_config.dart';
import 'status_service.dart';
import '../utils/connectivity_helper.dart';

/// Service for managing offline status updates and auto-sync
class OfflineSyncService {
  final StatusService _statusService;
  final ConnectivityHelper _connectivityHelper;
  Timer? _syncTimer;
  bool _isSyncing = false;

  OfflineSyncService({
    required StatusService statusService,
    required ConnectivityHelper connectivityHelper,
  })  : _statusService = statusService,
        _connectivityHelper = connectivityHelper;

  /// Initialize offline sync service with auto-retry
  void initialize() {
    // Listen to connectivity changes
    _connectivityHelper.connectivityStream.listen((isConnected) {
      if (isConnected && !_isSyncing) {
        // Trigger sync when connection is restored
        syncPendingUpdates();
      }
    });

    // Start periodic sync timer
    _startPeriodicSync();
  }

  /// Start periodic sync attempts
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(
      Duration(seconds: SupabaseConfig.offlineSyncRetryInterval),
      (_) async {
        if (await _connectivityHelper.isConnected() && !_isSyncing) {
          await syncPendingUpdates();
        }
      },
    );
  }

  /// Sync all pending offline updates
  Future<SyncResult> syncPendingUpdates() async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        syncedCount: 0,
        message: 'Sync already in progress',
      );
    }

    _isSyncing = true;

    try {
      // Check if we have internet connection
      if (!await _connectivityHelper.isConnected()) {
        return SyncResult(
          success: false,
          syncedCount: 0,
          message: 'No internet connection',
        );
      }

      // Get pending updates count before sync
      final pendingCount = await _statusService.getPendingUpdateCount();
      
      if (pendingCount == 0) {
        return SyncResult(
          success: true,
          syncedCount: 0,
          message: 'No pending updates',
        );
      }

      // Process offline queue
      final syncedCount = await _statusService.processOfflineQueue();

      return SyncResult(
        success: true,
        syncedCount: syncedCount,
        message: 'Synced $syncedCount of $pendingCount updates',
      );
    } catch (e) {
      return SyncResult(
        success: false,
        syncedCount: 0,
        message: 'Sync failed: ${e.toString()}',
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Get count of pending updates
  Future<int> getPendingCount() async {
    return await _statusService.getPendingUpdateCount();
  }

  /// Check if sync is currently in progress
  bool get isSyncing => _isSyncing;

  /// Force sync now (even if on schedule)
  Future<SyncResult> forceSyncNow() async {
    return await syncPendingUpdates();
  }

  /// Clear all pending updates (use with caution!)
  Future<void> clearPendingUpdates() async {
    await _statusService.clearOfflineQueue();
  }

  /// Get sync status information
  Future<Map<String, dynamic>> getSyncStatus() async {
    final pendingCount = await getPendingCount();
    final isConnected = await _connectivityHelper.isConnected();

    return {
      'pendingUpdates': pendingCount,
      'isConnected': isConnected,
      'isSyncing': _isSyncing,
      'canSync': isConnected && !_isSyncing && pendingCount > 0,
    };
  }

  /// Dispose resources
  void dispose() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }
}

/// Result of a sync operation
class SyncResult {
  final bool success;
  final int syncedCount;
  final String message;

  SyncResult({
    required this.success,
    required this.syncedCount,
    required this.message,
  });

  @override
  String toString() => message;
}
