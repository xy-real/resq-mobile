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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.warningOrange.withValues(alpha: 0.1),
        border: Border.all(
          color: AppTheme.warningOrange,
          width: 2,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.warningOrange,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.signal_cellular_off,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
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
                      ),
                    ),
                    Text(
                      'Send status via SMS',
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
          const SizedBox(height: 16),

          // SMS Format Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.backgroundDark,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.dividerColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SMS Format',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                SelectableText(
                  smsBody,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.lightBlue,
                    fontFamily: 'monospace',
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Buttons
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Open SMS button
              ElevatedButton.icon(
                onPressed: _openSmsApp,
                icon: const Icon(Icons.sms),
                label: const Text('Open SMS App'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.warningOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Copy to clipboard button
              OutlinedButton.icon(
                onPressed: _copyToClipboard,
                icon: const Icon(Icons.content_copy),
                label: const Text('Copy Format'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.warningOrange,
                  side: const BorderSide(
                    color: AppTheme.warningOrange,
                    width: 1.5,
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),

          // Help text
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceBlue,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Text(
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
    );
  }
}
