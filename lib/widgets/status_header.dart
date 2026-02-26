import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/time_formatter.dart';
import 'connectivity_banner.dart';

/// Header section showing student ID, current status, and connectivity info
class StatusHeader extends StatelessWidget {
  final String studentId;
  final String? currentStatus;
  final DateTime? lastUpdated;
  final bool isConnected;

  const StatusHeader({
    super.key,
    required this.studentId,
    this.currentStatus,
    this.lastUpdated,
    required this.isConnected,
  });

  @override
  Widget build(BuildContext context) {
    final timeAgo = TimeFormatter.formatTimeAgo(lastUpdated);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceBlue,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Student ID
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Student ID',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    studentId.isEmpty ? 'Not Set' : studentId,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
              ConnectivityBanner(isConnected: isConnected),
            ],
          ),
          const SizedBox(height: 16),

          // Current Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Current Status',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                currentStatus ?? 'No status submitted',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: currentStatus == null
                      ? AppTheme.textSecondary
                      : AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Last Updated
          if (lastUpdated != null)
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 14,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  'Last updated: $timeAgo',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            )
          else
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 14,
                  color: AppTheme.warningOrange,
                ),
                const SizedBox(width: 4),
                const Text(
                  'No status submitted yet',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.warningOrange,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
