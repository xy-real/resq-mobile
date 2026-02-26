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
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacing8,
        horizontal: AppTheme.spacing12,
      ),
      decoration: BoxDecoration(
        color: isConnected
            ? AppTheme.backgroundSuccess
            : AppTheme.backgroundError,
        border: Border.all(
          color: isConnected ? AppTheme.successGreen : AppTheme.errorRed,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: [
          BoxShadow(
            color: (isConnected ? AppTheme.successGreen : AppTheme.errorRed)
                .withValues(alpha: 0.15),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
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
              boxShadow: [
                BoxShadow(
                  color: (isConnected ? AppTheme.successGreen : AppTheme.errorRed)
                      .withValues(alpha: 0.5),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppTheme.spacing8),
          Text(
            isConnected ? 'Connected' : 'Offline',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
              color: isConnected ? AppTheme.successGreen : AppTheme.errorRed,
            ),
          ),
        ],
      ),
    );
  }
}
