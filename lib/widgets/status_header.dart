import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../utils/time_formatter.dart';

/// Compact profile/status card showing:
/// - Student ID as secondary text
/// - Connectivity indicator with subtle color dot
/// - Current status with clear state
/// - "Last updated" in small muted typography
/// Following Material 3 design with soft elevation and minimal visual noise
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
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 16,
      ),
      decoration: BoxDecoration(
        // Flat background, no gradient
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        // Soft elevation shadow instead of glowing effect
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top row: Student ID and Connectivity
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side: Student ID information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Small label text (12-13pt regular)
                    Text(
                      'Student ID',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Primary ID text (16-18pt medium)
                    Text(
                      studentId.isEmpty ? 'Not Set' : studentId,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Right side: Connectivity indicator
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  // Small label text
                  Text(
                    'Connection',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Connectivity indicator: subtle color dot + text
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Subtle color dot (green = connected, gray = offline)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isConnected
                              ? AppTheme.successGreen
                              : AppTheme.textMuted,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isConnected ? 'Online' : 'Offline',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: isConnected
                              ? AppTheme.successGreen
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

          const SizedBox(height: 16),

          // Divider: subtle and minimal
          Container(
            height: 1,
            color: AppTheme.dividerColor,
          ),

          const SizedBox(height: 16),

          // Current Status Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              Text(
                'Current Status',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
              const SizedBox(height: 8),
              // Status value: larger, clear typography
              Text(
                currentStatus ?? 'No status submitted',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: currentStatus == null
                      ? AppTheme.textSecondary
                      : AppTheme.textPrimary,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Last Updated Metadata: small muted typography
          Row(
            children: [
              Icon(
                lastUpdated != null
                    ? Icons.schedule_rounded
                    : Icons.info_outline_rounded,
                size: 14,
                color: AppTheme.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                lastUpdated != null
                    ? 'Last updated: $timeAgo'
                    : 'No status submitted yet',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: AppTheme.textMuted,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
