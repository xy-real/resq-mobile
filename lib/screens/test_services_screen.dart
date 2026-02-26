import 'package:flutter/material.dart';
import '../services/evacuation_center_service.dart';
import '../services/location_service.dart';
import '../services/disaster_mode_service.dart';
import '../services/auth_service.dart';
import '../utils/connectivity_helper.dart';
import '../widgets/evacuation_center_map.dart';

/// Test screen to verify all services work
class TestServicesScreen extends StatefulWidget {
  const TestServicesScreen({super.key});

  @override
  State<TestServicesScreen> createState() => _TestServicesScreenState();
}

class _TestServicesScreenState extends State<TestServicesScreen> {
  final _authService = AuthService();
  final _centerService = EvacuationCenterService();
  final _locationService = LocationService();
  final _disasterService = DisasterModeService();
  final _connectivityHelper = ConnectivityHelper();
  
  String _status = 'Ready to test';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _connectivityHelper.initialize();
    _disasterService.initialize();
  }

  @override
  void dispose() {
    _connectivityHelper.dispose();
    _disasterService.dispose();
    _locationService.dispose();
    super.dispose();
  }

  Future<void> _testConnectivity() async {
    setState(() => _isLoading = true);
    try {
      final isConnected = await _connectivityHelper.checkConnection();
      final type = await _connectivityHelper.getConnectionType();
      setState(() {
        _status = 'Connected: $isConnected\nType: $type';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testLocation() async {
    setState(() => _isLoading = true);
    try {
      final hasPermission = await _locationService.requestLocationPermission();
      if (!hasPermission) {
        setState(() {
          _status = 'Location permission denied';
          _isLoading = false;
        });
        return;
      }

      final position = await _locationService.getCurrentLocation();
      setState(() {
        _status = 'Location: ${position?.latitude.toStringAsFixed(6)}, '
            '${position?.longitude.toStringAsFixed(6)}\n'
            'Accuracy: ${position?.accuracy.toStringAsFixed(2)}m';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Location Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testDisasterMode() async {
    setState(() => _isLoading = true);
    try {
      final settings = await _disasterService.fetchDisasterModeStatus();
      setState(() {
        _status = 'Disaster Mode: ${settings.isDisasterModeActive}\n'
            'Activated: ${settings.modeActivatedAt?.toString() ?? 'N/A'}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Disaster Mode Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _testEvacuationCenters() async {
    setState(() => _isLoading = true);
    try {
      final centers = await _centerService.getEvacuationCenters();
      setState(() {
        _status = 'Found ${centers.length} evacuation centers\n'
            '${centers.map((c) => c.centerName).join('\n')}';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _status = 'Evacuation Centers Error: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _showMap() async {
    try {
      final centers = await _centerService.getEvacuationCenters();
      final position = await _locationService.getCurrentLocation();
      
      if (!mounted) return;
      
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Scaffold(
            appBar: AppBar(title: const Text('Evacuation Centers Map')),
            body: EvacuationCenterMapWidget(
              centers: centers,
              userLocation: position,
              onCenterTapped: (center) {
                showModalBottomSheet(
                  context: context,
                  builder: (_) => EvacuationCenterDetailsSheet(
                    center: center,
                    userLocation: position,
                  ),
                );
              },
            ),
          ),
        ),
      );
    } catch (e) {
      setState(() => _status = 'Map Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Services'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  _status,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else ...[
              ElevatedButton.icon(
                onPressed: _testConnectivity,
                icon: const Icon(Icons.wifi),
                label: const Text('Test Connectivity'),
              ),
              const SizedBox(height: 10),
              
              ElevatedButton.icon(
                onPressed: _testLocation,
                icon: const Icon(Icons.location_on),
                label: const Text('Test Location'),
              ),
              const SizedBox(height: 10),
              
              ElevatedButton.icon(
                onPressed: _testDisasterMode,
                icon: const Icon(Icons.warning),
                label: const Text('Test Disaster Mode'),
              ),
              const SizedBox(height: 10),
              
              ElevatedButton.icon(
                onPressed: _testEvacuationCenters,
                icon: const Icon(Icons.home),
                label: const Text('Test Evacuation Centers'),
              ),
              const SizedBox(height: 10),
              
              ElevatedButton.icon(
                onPressed: _showMap,
                icon: const Icon(Icons.map),
                label: const Text('Show Map'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
