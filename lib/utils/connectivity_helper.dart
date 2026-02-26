import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Helper class for monitoring network connectivity
class ConnectivityHelper {
  final Connectivity _connectivity = Connectivity();
  final _connectivityController = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isConnected = true;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity status
    _isConnected = await checkConnection();
    
    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _handleConnectivityChange(results);
      },
    );
  }

  /// Handle connectivity state changes
  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    _isConnected = _hasConnection(results);

    // Only emit if connection state actually changed
    if (wasConnected != _isConnected) {
      _connectivityController.add(_isConnected);
    }
  }

  /// Check if any of the results indicates a connection
  bool _hasConnection(List<ConnectivityResult> results) {
    return results.any((result) => 
      result == ConnectivityResult.mobile ||
      result == ConnectivityResult.wifi ||
      result == ConnectivityResult.ethernet
    );
  }

  /// Check current connection status
  Future<bool> checkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _hasConnection(results);
    } catch (e) {
      return false;
    }
  }

  /// Stream of connectivity changes
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Get current connection status
  bool isConnected() => _isConnected;

  /// Get connection type
  Future<String> getConnectionType() async {
    try {
      final results = await _connectivity.checkConnectivity();
      
      if (results.contains(ConnectivityResult.wifi)) {
        return 'WiFi';
      } else if (results.contains(ConnectivityResult.mobile)) {
        return 'Mobile Data';
      } else if (results.contains(ConnectivityResult.ethernet)) {
        return 'Ethernet';
      } else {
        return 'Offline';
      }
    } catch (e) {
      return 'Unknown';
    }
  }

  /// Get user-friendly connectivity status
  Future<ConnectivityStatus> getConnectivityStatus() async {
    final connected = await checkConnection();
    final type = await getConnectionType();

    return ConnectivityStatus(
      isConnected: connected,
      connectionType: type,
      statusMessage: connected 
          ? 'Connected via $type'
          : 'No internet connection',
    );
  }

  /// Wait for connection with timeout
  Future<bool> waitForConnection({Duration timeout = const Duration(seconds: 10)}) async {
    if (_isConnected) return true;

    try {
      await _connectivityController.stream
          .firstWhere((connected) => connected)
          .timeout(timeout);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}

/// Connectivity status information
class ConnectivityStatus {
  final bool isConnected;
  final String connectionType;
  final String statusMessage;

  ConnectivityStatus({
    required this.isConnected,
    required this.connectionType,
    required this.statusMessage,
  });

  @override
  String toString() => statusMessage;
}
