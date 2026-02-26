import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Banner displayed when disaster mode is active
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
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: AppTheme.errorRed,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: AppTheme.errorRed.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 1,
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
              children: const [
                Icon(
                  Icons.warning_rounded,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'DISASTER MODE ACTIVE',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Emergency response protocols enabled',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.white,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
