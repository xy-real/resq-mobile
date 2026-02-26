import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Helper class for monitoring network connectivity
class ConnectivityHelper {
  final Connectivity _connectivity = Connectivity();
  final _connectivityController = StreamController<bool>.broadcast();
  StreamSubscription<ConnectivityResult>? _subscription;
  bool _isConnected = true;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity status
    _isConnected = await checkConnection();
    
    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      (ConnectivityResult result) {
        _handleConnectivityChange(result);
      },
    );
  }

  /// Handle connectivity state changes
  void _handleConnectivityChange(ConnectivityResult result) {
    final wasConnected = _isConnected;
    _isConnected = _hasConnection(result);

    // Only emit if connection state actually changed
    if (wasConnected != _isConnected) {
      _connectivityController.add(_isConnected);
    }
  }

  /// Check if result indicates a connection
  bool _hasConnection(ConnectivityResult result) {
    return result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet;
  }

  /// Check current connection status
  Future<bool> checkConnection() async {
    try {
      final result = await _connectivity.checkConnectivity();
      return _hasConnection(result);
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
      final result = await _connectivity.checkConnectivity();
      
      if (result == ConnectivityResult.wifi) {
        return 'WiFi';
      } else if (result == ConnectivityResult.mobile) {
        return 'Mobile Data';
      } else if (result == ConnectivityResult.ethernet) {
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
