import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Clean, minimal banner displayed when disaster mode is active
/// - No gradients or heavy glowing effects
/// - Soft elevation with subtle shadow
/// - Clear, calm visual presentation
class DisasterModeBanner extends StatelessWidget {
  final bool isVisible;
  final VoidCallback? onTap;

  const DisasterModeBanner({
    super.key,
    this.isVisible = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        vertical: AppTheme.spacing16,
        horizontal: AppTheme.spacing20,
      ),
      decoration: BoxDecoration(
        // Clean solid background (no gradients)
        color: AppTheme.statusCritical.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(
          color: AppTheme.statusCritical.withValues(alpha: 0.3),
          width: 1.5,
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
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(AppTheme.spacing8),
                  decoration: BoxDecoration(
                    color: AppTheme.statusCritical.withValues(alpha: 0.2),
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusSmall),
                  ),
                  child: const Icon(
                    Icons.warning_rounded,
                    color: AppTheme.statusCritical,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.spacing12),
                const Expanded(
                  child: Text(
                    'Disaster Mode Active',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacing12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacing12,
                vertical: AppTheme.spacing8,
              ),
              decoration: BoxDecoration(
                color: AppTheme.statusCritical.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
              ),
              child: const Text(
                'Emergency response protocols enabled (dev mode)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textSecondary,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
