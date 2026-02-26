import 'package:flutter/material.dart';
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/status_header.dart';
import '../widgets/status_button.dart';
import '../widgets/sms_fallback_card.dart';
import '../widgets/logout_dialog.dart';
import '../providers/app_state_provider.dart';
import '../providers/auth_provider.dart';
import '../services/location_service.dart';
import '../utils/time_formatter.dart';
import './map_screen.dart';

/// Main home/status screen for the RESQ Mobile app
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Connectivity _connectivity;
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;
  bool _isLoadingStatus = false;

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

  /// Handle logout action
  /// 
  /// Shows a confirmation dialog and performs logout if confirmed.
  /// Logout includes:
  /// - Signing out from Supabase and Google Sign-In
  /// - Clearing all cached profile data
  /// - Clearing local session flags
  /// - Resetting auth state
  /// 
  /// After logout completes, the auth state change will be detected by
  /// AuthWrapper and navigation to login screen will happen automatically.
  Future<void> _handleLogout() async {
    if (!mounted) return;

    final confirmed = await LogoutDialog.show(
      context,
      onLogoutConfirmed: () async {
        final authNotifier = context.read<AuthNotifier>();
        await authNotifier.signOut();
      },
    );

    if (confirmed && mounted) {
      // Navigation will happen automatically when auth state changes
      // via the AuthWrapper stream
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logged out successfully'),
          backgroundColor: AppTheme.statusSafe,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  Future<void> _checkLocationPermission() async {
    try {
      final permission = await LocationService.getPermissionStatus();
      if (mounted) {
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          // Permission already granted, enable location and fetch
          appStateProvider.setLocationEnabled(true);
          await _fetchCurrentLocation();
        }
      }
    } catch (e) {
      debugPrint('Error checking location permission: $e');
    }
  }

  /// Fetch current GPS location from device
  Future<void> _fetchCurrentLocation() async {
    try {
      final location = await LocationService.getCurrentLocation();
      if (location != null && mounted) {
        appStateProvider.setCurrentLocation(location);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Location updated: ${location.displayString}'),
              backgroundColor: AppTheme.statusSafe,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to get location. Check permissions.'),
            backgroundColor: AppTheme.statusCritical,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error fetching location: $e'),
            backgroundColor: AppTheme.statusCritical,
          ),
        );
      }
    }
  }

  Future<void> _requestLocationPermission() async {
    try {
      // First check if location services are enabled on device
      final serviceEnabled = await LocationService.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Location services are disabled. Please enable them in device settings.',
              ),
              backgroundColor: AppTheme.statusCritical,
              duration: Duration(seconds: 3),
            ),
          );
        }
        return;
      }

      // Request permission using geolocator
      final permission = await LocationService.requestPermission();
      
      if (mounted) {
        if (permission == LocationPermission.whileInUse ||
            permission == LocationPermission.always) {
          // Permission granted - enable location sharing and fetch location
          appStateProvider.setLocationEnabled(true);
          await _fetchCurrentLocation();
        } else if (permission == LocationPermission.denied) {
          // Permission denied by user
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Location permission is required to enable location sharing. Please try again.',
                ),
                backgroundColor: AppTheme.statusNeedsHelp,
                duration: Duration(seconds: 3),
              ),
            );
          }
        } else if (permission == LocationPermission.deniedForever) {
          // Permission permanently denied - open app settings
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Location permission permanently denied. Opening app settings...',
                ),
                backgroundColor: AppTheme.statusCritical,
                duration: Duration(seconds: 2),
              ),
            );
          }
          await LocationService.openAppSettings();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error requesting permission: $e'),
            backgroundColor: AppTheme.statusCritical,
            duration: const Duration(seconds: 2),
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
                // Logout button - placed in the AppBar for easy access
                Tooltip(
                  message: 'Log out',
                  child: IconButton(
                    icon: const Icon(
                      Icons.logout,
                      color: AppTheme.textSecondary,
                    ),
                    onPressed: _handleLogout,
                    splashRadius: 24,
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
                          width: double.infinity,
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
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Status row
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
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
                                  if (state.locationEnabled)
                                    Tooltip(
                                      message: 'Refresh location',
                                      child: IconButton(
                                        onPressed: _fetchCurrentLocation,
                                        icon: const Icon(
                                          Icons.refresh,
                                          size: 18,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 32,
                                          minHeight: 32,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              if (state.currentLocation != null) ...[
                                const SizedBox(height: AppTheme.spacing12),
                                // GPS Coordinates display
                                Container(
                                  width: double.infinity,
                                  padding: const EdgeInsets.all(
                                      AppTheme.spacing12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.backgroundDark,
                                    borderRadius: BorderRadius.circular(
                                        AppTheme.radiusSmall),
                                    border: Border.all(
                                      color: AppTheme.primary
                                          .withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Coordinates',
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w600,
                                          color: AppTheme.textSecondary,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      SelectableText(
                                        state.currentLocation!.displayString,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.primary,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                      if (state
                                              .currentLocation!.accuracy !=
                                          null)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: AppTheme.spacing8),
                                          child: Text(
                                            'Accuracy: ${state.currentLocation!.accuracy!.toStringAsFixed(1)}m',
                                            style: const TextStyle(
                                              fontSize: 10,
                                              color: AppTheme.textMuted,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                              if (state.currentLocation != null)
                                Padding(
                                  padding: const EdgeInsets.only(
                                      top: AppTheme.spacing8),
                                  child: Text(
                                    'Updated ${TimeFormatter.formatTimeAgo(state.currentLocation!.timestamp)}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                      color: AppTheme.textMuted,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacing16),
                        // Action buttons
                        if (!state.locationEnabled)
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _requestLocationPermission,
                              icon: const Icon(Icons.location_on, size: 18),
                              label: const Text('Enable Location Sharing'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.statusSafe,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacing16,
                                  vertical: AppTheme.spacing12,
                                ),
                              ),
                            ),
                          )
                        else
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _fetchCurrentLocation,
                              icon: const Icon(Icons.my_location, size: 18),
                              label: const Text('Update Location'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppTheme.spacing16,
                                  vertical: AppTheme.spacing12,
                                ),
                              ),
                            ),
                          ),
                        // Permission feedback is shown via SnackBar in _requestLocationPermission
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacing16),

                  // Emergency Map Card
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppTheme.primary.withValues(alpha: 0.2),
                          AppTheme.accentCyan.withValues(alpha: 0.1),
                        ],
                      ),
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(
                        color: AppTheme.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapScreen(
                                onBackPressed: () =>
                                    Navigator.pop(context),
                              ),
                            ),
                          );
                        },
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusLarge),
                        child: Padding(
                          padding: const EdgeInsets.all(
                              AppTheme.spacing16),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(
                                        AppTheme.spacing8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primary
                                          .withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.radiusSmall),
                                    ),
                                    child: const Icon(
                                      Icons.map,
                                      color: AppTheme.accentCyan,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'View Emergency Map',
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight:
                                                FontWeight.w700,
                                            color:
                                                AppTheme.textPrimary,
                                          ),
                                        ),
                                        const Text(
                                          'See evacuation centers near you',
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight:
                                                FontWeight.w400,
                                            color: AppTheme
                                                .textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Icon(
                                    Icons.arrow_forward_ios,
                                    color: AppTheme.accentCyan
                                        .withValues(alpha: 0.6),
                                    size: 16,
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
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
