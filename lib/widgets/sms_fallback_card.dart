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
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        // Clean, minimal card design (no gradients)
        color: AppTheme.surfaceElevated,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.border.withValues(alpha: 0.3),
          width: 1,
        ),
        // Soft elevation only
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
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
                padding: const EdgeInsets.all(AppTheme.spacing10),
                decoration: BoxDecoration(
                  color: AppTheme.statusNeedsHelp.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
                ),
                child: const Icon(
                  Icons.signal_cellular_off,
                  color: AppTheme.statusNeedsHelp,
                  size: 18,
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
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: AppTheme.spacing4),
                    Text(
                      'Send your status via SMS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing20),

          // SMS Message Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
              border: Border.all(
                color: AppTheme.border.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'SMS Message:',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing12),
                SelectableText(
                  smsBody,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.primary,
                    fontFamily: 'monospace',
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing20),

          // Action Buttons - Primary and secondary
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ElevatedButton.icon(
                onPressed: _openSmsApp,
                icon: const Icon(Icons.sms_outlined, size: 18),
                label: const Text('Open SMS App'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.statusNeedsHelp,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppTheme.spacing12,
                    horizontal: AppTheme.spacing20,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.spacing12),
              OutlinedButton.icon(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.content_copy_outlined, size: 16),
                label: const Text('Copy Message'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.primary,
                  side: const BorderSide(
                    color: AppTheme.border,
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
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacing16),

          // Help text
          Container(
            padding: const EdgeInsets.all(AppTheme.spacing12),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 15,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.spacing8),
                const Expanded(
                  child: Text(
                    'Your status will sync once you reconnect to the internet.',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w400,
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
