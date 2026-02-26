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
          appBar: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: AppBar(
              elevation: 0,
              backgroundColor: AppTheme.backgroundDark,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ResQ branding: Bold, modern, with letter spacing
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'RESQ',
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textPrimary,
                            letterSpacing: 2.0, // Prominent letter spacing
                          ),
                        ),
                        Text(
                          'Emergency Status',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                // Dev mode toggle (maintains existing functionality)
                Tooltip(
                  message: 'Toggle disaster mode (dev only)',
                  child: IconButton(
                    onPressed: () {
                      setState(() => _devDisasterMode = !_devDisasterMode);
                      appStateNotifier.setDisasterMode(_devDisasterMode);
                    },
                    icon: Icon(
                      _devDisasterMode ? Icons.warning : Icons.warning_outlined,
                      color: _devDisasterMode
                          ? AppTheme.statusCritical
                          : AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppTheme.spacing16),
              child: Column(
                children: [
                  // Disaster Mode Banner (simplified)
                  DisasterModeBanner(
                    isVisible: _devDisasterMode,
                    onTap: () {
                      setState(() => _devDisasterMode = !_devDisasterMode);
                      appStateNotifier.setDisasterMode(_devDisasterMode);
                    },
                  ),
                  const SizedBox(height: AppTheme.spacing16),

                  // Status Header Card
                  StatusHeader(
                    studentId: state.studentId,
                    currentStatus: state.currentStatus,
                    lastUpdated: state.lastUpdated,
                    isConnected: state.isConnected,
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // Status Selection Section - Modern, minimal layout
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section header with clear typography
                      Text(
                        'Select Your Status',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Descriptive subtitle
                      Text(
                        'Choose the option that best describes your current situation',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          color: AppTheme.textSecondary,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacing20),

                      // Status buttons arranged vertically with even spacing
                      StatusButton(
                        status: StatusOption.safe,
                        isActive: state.currentStatus ==
                            StatusOption.safe.backendValue,
                        isLoading: _isLoadingStatus &&
                            state.currentStatus ==
                                StatusOption.safe.backendValue,
                        onPressed: () =>
                            _updateStatus(StatusOption.safe.backendValue),
                      ),
                      const SizedBox(height: AppTheme.spacing12),
                      StatusButton(
                        status: StatusOption.needsAssistance,
                        isActive: state.currentStatus ==
                            StatusOption.needsAssistance.backendValue,
                        isLoading: _isLoadingStatus &&
                            state.currentStatus ==
                                StatusOption.needsAssistance.backendValue,
                        onPressed: () => _updateStatus(
                            StatusOption.needsAssistance.backendValue),
                      ),
                      const SizedBox(height: AppTheme.spacing12),
                      StatusButton(
                        status: StatusOption.critical,
                        isActive: state.currentStatus ==
                            StatusOption.critical.backendValue,
                        isLoading: _isLoadingStatus &&
                            state.currentStatus ==
                                StatusOption.critical.backendValue,
                        onPressed: () =>
                            _updateStatus(StatusOption.critical.backendValue),
                      ),
                      const SizedBox(height: AppTheme.spacing12),
                      StatusButton(
                        status: StatusOption.evacuated,
                        isActive: state.currentStatus ==
                            StatusOption.evacuated.backendValue,
                        isLoading: _isLoadingStatus &&
                            state.currentStatus ==
                                StatusOption.evacuated.backendValue,
                        onPressed: () =>
                            _updateStatus(StatusOption.evacuated.backendValue),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacing24),

                  // Location Sharing Card - Clean, minimal design
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppTheme.spacing20),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.06),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with icon
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(AppTheme.spacing8),
                              decoration: BoxDecoration(
                                color: AppTheme.primary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(
                                    AppTheme.radiusSmall),
                              ),
                              child: const Icon(
                                Icons.location_on,
                                color: AppTheme.primary,
                                size: 18,
                              ),
                            ),
                            const SizedBox(width: AppTheme.spacing12),
                            const Text(
                              'Location Sharing',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        // Location status display
                        Container(
                          padding: const EdgeInsets.all(AppTheme.spacing16),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMedium),
                            border: Border.all(
                              color: AppTheme.border.withValues(alpha: 0.3),
                              width: 1,
                            ),
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
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      color: state.locationEnabled
                                          ? AppTheme.statusSafe
                                          : AppTheme.textSecondary,
                                    ),
                                  ),
                                  if (_lastLocationUpdate != null)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          top: AppTheme.spacing4),
                                      child: Text(
                                        'Updated ${TimeFormatter.formatTimeAgo(_lastLocationUpdate)}',
                                        style: const TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textMuted,
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
                                    icon: const Icon(Icons.check, size: 16),
                                    label: const Text('Enable'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.statusSafe,
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
                        // Permission warning only if needed
                        if (_locationPermissionStatus.isDenied) ...[
                          const SizedBox(height: AppTheme.spacing12),
                          Container(
                            padding: const EdgeInsets.all(AppTheme.spacing12),
                            decoration: BoxDecoration(
                              color: AppTheme.statusNeedsHelp.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(
                                  AppTheme.radiusSmall),
                              border: Border.all(
                                color: AppTheme.statusNeedsHelp
                                    .withValues(alpha: 0.3),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: AppTheme.statusNeedsHelp,
                                  size: 16,
                                ),
                                const SizedBox(width: AppTheme.spacing8),
                                const Expanded(
                                  child: Text(
                                    'Enable location to share your position with responders',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),

                  // SMS Fallback Card
                  SmsFallbackCard(
                    isVisible: !state.isConnected,
                    studentId: state.studentId,
                    currentStatus: state.currentStatus,
                  ),
                  const SizedBox(height: AppTheme.spacing16),

                  // Offline indicator
                  if (!state.isConnected)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppTheme.spacing12),
                      decoration: BoxDecoration(
                        color: AppTheme.statusCritical.withValues(alpha: 0.12),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(
                          color: AppTheme.statusCritical.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.cloud_off,
                            color: AppTheme.statusCritical,
                            size: 16,
                          ),
                          const SizedBox(width: AppTheme.spacing8),
                          const Expanded(
                            child: Text(
                              'No internet connection. Status will sync when restored.',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.textPrimary,
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
