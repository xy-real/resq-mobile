import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/time_formatter.dart';

/// Clean, minimal status card showing student info and current status
/// - Soft elevation with subtle shadow
/// - Clear information hierarchy using typography
/// - Connectivity indicator with color-coded dot
/// - Last updated timestamp in muted text
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
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing20), // 20px padding
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        // Soft elevation (no glowing effects)
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: Student ID and Connectivity Status
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Student ID section
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Student ID',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      studentId.isEmpty ? 'Not Set' : studentId,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              // Connectivity indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Status',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isConnected
                              ? AppTheme.statusSafe
                              : AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isConnected ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isConnected
                              ? AppTheme.statusSafe
                              : AppTheme.textMuted,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),

          // Divider: subtle and minimal
          Container(
            height: 1,
            color: AppTheme.border.withValues(alpha: 0.3),
          ),
          const SizedBox(height: AppTheme.spacing16),

          // Current Status section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Current Status',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                currentStatus ?? 'No status submitted',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: currentStatus == null
                      ? AppTheme.textSecondary
                      : AppTheme.textPrimary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              // Last updated timestamp in small, muted text
              Row(
                children: [
                  Icon(
                    lastUpdated != null
                        ? Icons.schedule_rounded
                        : Icons.info_outline_rounded,
                    size: 13,
                    color: AppTheme.textMuted,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    lastUpdated != null
                        ? 'Updated $timeAgo'
                        : 'No status submitted yet',
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
                      color: AppTheme.textMuted,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

