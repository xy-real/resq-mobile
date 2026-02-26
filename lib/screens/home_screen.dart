import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/disaster_mode_banner.dart';
import '../widgets/status_header.dart';
import '../widgets/status_button.dart';
import '../widgets/sms_fallback_card.dart';
import '../providers/app_state_provider.dart';
import '../utils/time_formatter.dart';

/// Main home/status screen for the RESQ Mobile app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Connectivity _connectivity;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _devDisasterMode = false;
  bool _isLoadingStatus = false;
  PermissionStatus _locationPermissionStatus = PermissionStatus.denied;
  DateTime? _lastLocationUpdate;

  @override
  void initState() {
    super.initState();
    _initializeConnectivity();
    _checkLocationPermission();
  }

  void _initializeConnectivity() {
    _connectivity = Connectivity();

    // Check initial connectivity
    _connectivity.checkConnectivity().then((result) {
      if (mounted) {
        final isConnected = result != ConnectivityResult.none;
        appStateProvider.setConnectivityStatus(isConnected);
      }
    });

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (result) {
        if (mounted) {
          final isConnected = result != ConnectivityResult.none;
          appStateProvider.setConnectivityStatus(isConnected);
        }
      },
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    try {
      final status = await Permission.location.status;
      if (mounted) {
        setState(() {
          _locationPermissionStatus = status;
          if (status.isGranted) {
            appStateProvider.setLocationEnabled(true);
            _lastLocationUpdate = DateTime.now();
            appStateProvider.setLastLocationUpdate(_lastLocationUpdate!);
          }
        });
      }
    } catch (e) {
      debugPrint('Error checking location permission: $e');
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      final status = await Permission.location.request();
      if (mounted) {
        setState(() {
          _locationPermissionStatus = status;
          if (status.isGranted) {
            appStateProvider.setLocationEnabled(true);
            _lastLocationUpdate = DateTime.now();
            appStateProvider.setLastLocationUpdate(_lastLocationUpdate!);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error requesting permission: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  Future<void> _updateStatus(String status) async {
    if (status == 'CRITICAL') {
      final confirmed = await _showCriticalConfirmationDialog();
      if (!confirmed) return;
    }

    setState(() => _isLoadingStatus = true);

    try {
      await appStateProvider.updateStatus(status);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Status updated to: $status'),
            backgroundColor: AppTheme.successGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating status: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoadingStatus = false);
      }
    }
  }

  Future<bool> _showCriticalConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surfaceBlue,
        title: const Text(
          'Confirm Critical Status',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You are marking yourself as CRITICAL. This is a serious emergency indicator.',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.errorRed),
              ),
              child: const Text(
                'Emergency responders will be alerted immediately.',
                style: TextStyle(
                  color: AppTheme.errorRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Yes, I Need Help',
              style: TextStyle(
                color: AppTheme.errorRed,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );

    return confirmed ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AppStateNotifier>(
      builder: (context, appStateNotifier, child) {
        final state = appStateNotifier.state;

        return Scaffold(
          appBar: AppBar(
            title: const Text('RESQ Status'),
            elevation: 0,
            actions: [
              // Dev mode toggle
              Tooltip(
                message: 'Toggle disaster mode (dev only)',
                child: IconButton(
                  onPressed: () {
                    setState(() => _devDisasterMode = !_devDisasterMode);
                    appStateNotifier.setDisasterMode(_devDisasterMode);
                  },
                  icon: Icon(
                    _devDisasterMode ? Icons.warning : Icons.warning_outlined,
                    color: _devDisasterMode ? AppTheme.errorRed : AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                children: [
                  // Disaster Mode Banner
                  DisasterModeBanner(
                    isVisible: _devDisasterMode,
                    onTap: () {
                      setState(() => _devDisasterMode = !_devDisasterMode);
                      appStateNotifier.setDisasterMode(_devDisasterMode);
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing16),

                  // Status Header
                  StatusHeader(
                    studentId: state.studentId,
                    currentStatus: state.currentStatus,
                    lastUpdated: state.lastUpdated,
                    isConnected: state.isConnected,
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // Status Buttons Section - Clean, minimal layout
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header: clear visual hierarchy
                      Text(
                        'Select Your Status',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Descriptive subtitle with smaller font
                      Text(
                        'Choose the option that best describes your current situation',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing20),

                      // Four equal full-width status buttons arranged vertically
                      StatusButton(
                        status: StatusOption.safe,
                        isActive: state.currentStatus == StatusOption.safe.backendValue,
                        isLoading: _isLoadingStatus && state.currentStatus == StatusOption.safe.backendValue,
                        onPressed: () => _updateStatus(StatusOption.safe.backendValue),
                      ),
                      const SizedBox(height: 12),
                      StatusButton(
                        status: StatusOption.needsAssistance,
                        isActive: state.currentStatus == StatusOption.needsAssistance.backendValue,
                        isLoading: _isLoadingStatus && state.currentStatus == StatusOption.needsAssistance.backendValue,
                        onPressed: () => _updateStatus(StatusOption.needsAssistance.backendValue),
                      ),
                      const SizedBox(height: 12),
                      StatusButton(
                        status: StatusOption.critical,
                        isActive: state.currentStatus == StatusOption.critical.backendValue,
                        isLoading: _isLoadingStatus && state.currentStatus == StatusOption.critical.backendValue,
                        onPressed: () => _updateStatus(StatusOption.critical.backendValue),
                      ),
                      const SizedBox(height: 12),
                      StatusButton(
                        status: StatusOption.evacuated,
                        isActive: state.currentStatus == StatusOption.evacuated.backendValue,
                        isLoading: _isLoadingStatus && state.currentStatus == StatusOption.evacuated.backendValue,
                        onPressed: () => _updateStatus(StatusOption.evacuated.backendValue),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing20),

                  // Location Section
                  Container(
                    padding: const EdgeInsets.all(AppTheme.spacing16),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceBlue,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppTheme.spacing8),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryBlue.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: AppTheme.primaryBlue,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing8),
                            const Text(
                              'Location Sharing',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing12),
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacing12),
                          decoration: BoxDecoration(
                            color: AppTheme.backgroundDark,
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            border: Border.all(color: AppTheme.dividerColor),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    state.locationEnabled ? 'ON' : 'OFF',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                      color: state.locationEnabled
                                          ? AppTheme.successGreen
                                          : AppTheme.textSecondary,
                                    ),
                                  ),
                                  if (_lastLocationUpdate != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: AppTheme.spacing4),
                                      child: Text(
                                        'Updated ${TimeFormatter.formatTimeAgo(_lastLocationUpdate)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (!state.locationEnabled)
                                SizedBox(
                                  width: 110,
                                  child: ElevatedButton.icon(
                                    onPressed: _requestLocationPermission,
                                    icon: const Icon(Icons.check),
                                    label: const Text('Enable'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.successGreen,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: AppTheme.spacing8,
                                        vertical: AppTheme.spacing8,
                                      ),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing12),
                        if (_locationPermissionStatus.isDenied)
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacing10),
                            decoration: BoxDecoration(
                              color: AppTheme.backgroundWarning,
                              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                              border: Border.all(color: AppTheme.warningOrange),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppTheme.warningOrange,
                                  size: 16,
                                ),
                                const SizedBox(width: AppTheme.spacing8),
                                const Expanded(
                                  child: Text(
                                    'Location permission required to share your location with responders',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.warningOrange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),

                  // SMS Fallback Card (only show when offline)
                  SmsFallbackCard(
                    isVisible: !state.isConnected,
                    studentId: state.studentId,
                    currentStatus: state.currentStatus,
                  ),
                  const SizedBox(height: AppTheme.spacing16),

                  // Additional info when offline
                  if (!state.isConnected)
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spacing12),
                      decoration: BoxDecoration(
                        color: AppTheme.backgroundError,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(color: AppTheme.errorRed),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cloud_off,
                            color: AppTheme.errorRed,
                            size: 18,
                          ),
                          const SizedBox(width: AppTheme.spacing8),
                          const Expanded(
                            child: Text(
                              'No internet connection. Your status will sync when connection is restored.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.errorRed,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                  const SizedBox(height: AppTheme.spacing8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
