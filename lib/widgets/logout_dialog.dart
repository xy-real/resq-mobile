import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Confirmation dialog for logout action
/// 
/// Shows a confirmation dialog with message "Are you sure you want to log out?"
/// and provides Cancel and Logout options. While logout is in progress, shows a loading state.
class LogoutDialog extends StatefulWidget {
  /// Callback when logout is confirmed
  /// Should return a Future that completes when logout is done
  final Future<void> Function() onLogoutConfirmed;

  const LogoutDialog({
    super.key,
    required this.onLogoutConfirmed,
  });

  /// Show the logout confirmation dialog
  static Future<bool> show(
    BuildContext context, {
    required Future<void> Function() onLogoutConfirmed,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => LogoutDialog(
        onLogoutConfirmed: onLogoutConfirmed,
      ),
    );
    return result ?? false;
  }

  @override
  State<LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<LogoutDialog> {
  bool _isLoading = false;
  String? _error;

  Future<void> _handleLogout() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      await widget.onLogoutConfirmed();
      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate successful logout
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to log out: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppTheme.surfaceBlue,
      title: const Text(
        'Log Out',
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
            'Are you sure you want to log out?',
            style: TextStyle(
              color: AppTheme.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'You will need to sign in again to access your emergency status.',
            style: TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.errorRed.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppTheme.errorRed),
              ),
              child: Text(
                _error!,
                style: const TextStyle(
                  color: AppTheme.errorRed,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: _isLoading
              ? null
              : () {
                  Navigator.pop(context, false);
                },
          child: Text(
            'Cancel',
            style: TextStyle(
              color: _isLoading ? AppTheme.textMuted : AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        // Logout button with loading state
        TextButton(
          onPressed: _isLoading ? null : _handleLogout,
          child: _isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.statusCritical.withValues(alpha: 0.8),
                    ),
                    strokeWidth: 2,
                  ),
                )
              : const Text(
                  'Log Out',
                  style: TextStyle(
                    color: AppTheme.statusCritical,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ],
    );
  }
}
