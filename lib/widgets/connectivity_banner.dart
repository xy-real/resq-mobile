import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Indicator for connectivity status
class ConnectivityBanner extends StatelessWidget {
  final bool isConnected;

  const ConnectivityBanner({
    super.key,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      decoration: BoxDecoration(
        color: isConnected
            ? AppTheme.successGreen.withValues(alpha: 0.1)
            : AppTheme.errorRed.withValues(alpha: 0.1),
        border: Border.all(
          color: isConnected ? AppTheme.successGreen : AppTheme.errorRed,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: isConnected ? AppTheme.successGreen : AppTheme.errorRed,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            isConnected ? 'Connected' : 'Offline',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isConnected ? AppTheme.successGreen : AppTheme.errorRed,
            ),
          ),
        ],
      ),
    );
  }
}
