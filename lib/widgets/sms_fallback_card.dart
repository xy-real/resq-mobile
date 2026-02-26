import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../utils/time_formatter.dart';

/// Card displayed when offline with SMS fallback instructions
class SmsFallbackCard extends StatefulWidget {
  final bool isVisible;
  final String studentId;
  final String? currentStatus;

  const SmsFallbackCard({
    super.key,
    this.isVisible = false,
    required this.studentId,
    this.currentStatus,
  });

  @override
  State<SmsFallbackCard> createState() => _SmsFallbackCardState();
}

class _SmsFallbackCardState extends State<SmsFallbackCard> {
  String _generateSmsBody() {
    final status = widget.currentStatus ?? 'SAFE';
    return TimeFormatter.generateSmsFormat(widget.studentId, status);
  }

  void _copyToClipboard() {
    final smsBody = _generateSmsBody();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied: $smsBody'),
        backgroundColor: AppTheme.successGreen,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _openSmsApp() async {
    final smsBody = _generateSmsBody();
    final smsUri = Uri(
      scheme: 'sms',
      queryParameters: {'body': smsBody},
    );

    try {
      if (await canLaunchUrl(smsUri)) {
        await launchUrl(smsUri);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open SMS application'),
              backgroundColor: AppTheme.errorRed,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening SMS: ${e.toString()}'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) {
      return const SizedBox.shrink();
    }

    final smsBody = _generateSmsBody();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.backgroundWarning,
            AppTheme.backgroundWarning.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(
          color: AppTheme.warningOrange,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: [
          BoxShadow(
            color: AppTheme.warningOrange.withValues(alpha: 0.3),
            blurRadius: 16,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTheme.spacing12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.warningOrange,
                      AppTheme.warningOrange.withValues(alpha: 0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.warningOrange.withValues(alpha: 0.5),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.signal_cellular_off,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppTheme.spacing16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Offline Mode Active',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.25,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    Text(
                      'Send status via SMS',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing20),

          // SMS Format Container
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDark,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: AppTheme.dividerColor,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing8,
                    vertical: AppTheme.spacing4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warningOrange.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    border: Border.all(
                      color: AppTheme.warningOrange.withValues(alpha: 0.3),
                    ),
                  ),
                  child: const Text(
                    'SMS FORMAT',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.warningOrange,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),
                const SizedBox(height: AppTheme.spacing12),
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing12),
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceBlue.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                    border: Border.all(
                      color: AppTheme.lightBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: SelectableText(
                    smsBody,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.lightBlue,
                      fontFamily: 'monospace',
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing20),

          // Action Buttons
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Primary SMS button
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.warningOrange.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _openSmsApp,
                  icon: const Icon(Icons.sms_outlined, size: 20),
                  label: const Text('Open SMS App'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.warningOrange,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppTheme.spacing16,
                      horizontal: AppTheme.spacing20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    ),
                    textStyle: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing12),

              // Secondary copy button
              OutlinedButton.icon(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.content_copy_outlined, size: 18),
                label: const Text('Copy Format'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.warningOrange,
                  side: const BorderSide(
                    color: AppTheme.warningOrange,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacing12,
                    horizontal: AppTheme.spacing20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.25,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),

          // Help Information
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: AppTheme.surfaceElevated.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: AppTheme.dividerColor.withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.spacing8),
                const Expanded(
                  child: Text(
                    'Send the SMS message above to activate your status when offline. The message will be processed once you regain connectivity.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textSecondary,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
