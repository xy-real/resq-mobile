import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Status options for emergency with semantic color meanings
/// Updated to use single primary brand color with status indicators via label, icon, and optional accent bar
enum StatusOption {
  safe('Safe', 'SAFE', Icons.verified, AppTheme.statusSafe),
  needsAssistance('Needs Assistance', 'NEEDS ASSISTANCE', Icons.error_outline, AppTheme.statusNeedsHelp),
  critical('Critical', 'CRITICAL', Icons.priority_high, AppTheme.statusCritical),
  evacuated('Evacuated', 'EVACUATED', Icons.directions_walk, AppTheme.statusEvacuated);

  final String label; // User-friendly display label
  final String backendValue; // Value for backend/storage
  final IconData icon; // Icon for status
  final Color indicatorColor; // Subtle indicator color

  const StatusOption(this.label, this.backendValue, this.icon, this.indicatorColor);
}

/// Redesigned status card with minimal, clean appearance
/// - Soft elevation with subtle shadow
/// - Status indicated via label, icon, and optional left accent bar when selected
/// - Single primary color used, with semantic indicator colors for visual distinction
/// - 16-20px padding, 16px border radius (soft, modern)
/// - Accessible touch targets and clear visual hierarchy
class StatusButton extends StatefulWidget {
  final StatusOption status;
  final bool isActive;
  final VoidCallback onPressed;
  final bool isLoading;

  const StatusButton({
    super.key,
    required this.status,
    required this.isActive,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  State<StatusButton> createState() => _StatusButtonState();
}

class _StatusButtonState extends State<StatusButton> {
  late DateTime _lastPressed;
  static const Duration _debounceTime = Duration(seconds: 2);

  @override
  void initState() {
    super.initState();
    _lastPressed = DateTime.now();
  }

  void _handlePress() {
    final now = DateTime.now();
    final timeSinceLastPress = now.difference(_lastPressed);

    // Prevent double submissions
    if (timeSinceLastPress < _debounceTime) {
      return;
    }

    _lastPressed = now;
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final isInteractive = !widget.isLoading;

    return GestureDetector(
      onTap: isInteractive ? _handlePress : null,
      child: AnimatedOpacity(
        opacity: isInteractive ? 1.0 : 0.7,
        duration: const Duration(milliseconds: 200),
        child: Container(
          // Minimum 48px height for accessibility
          constraints: const BoxConstraints(minHeight: 56),
          decoration: BoxDecoration(
            // Subtle soft elevation background
            color: widget.isActive
                ? AppTheme.primary.withValues(alpha: 0.12) // Soft primary tint
                : AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge), // 16px corner radius
            // Soft elevation shadow (no glowing effects)
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
            // Left accent bar for selected state
            border: Border(
              left: BorderSide(
                color: widget.isActive
                    ? widget.status.indicatorColor
                    : Colors.transparent,
                width: 4,
              ),
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isInteractive ? _handlePress : null,
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              splashColor: AppTheme.primary.withValues(alpha: 0.1),
              highlightColor: AppTheme.primary.withValues(alpha: 0.05),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16, // 16px vertical padding
                  horizontal: 20, // 20px horizontal padding
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Left side: Icon and status label
                    Expanded(
                      child: Row(
                        children: [
                          // Status icon with subtle background
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: widget.status.indicatorColor
                                  .withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusSmall),
                            ),
                            child: Icon(
                              widget.status.icon,
                              color: widget.status.indicatorColor,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: AppTheme.spacing12),
                          // Status label with clear hierarchy
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  widget.status.label,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.textPrimary,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                                if (widget.isActive)
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(top: 4.0),
                                    child: Text(
                                      'Selected',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                        color: widget.status.indicatorColor,
                                        letterSpacing: 0.15,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    // Right side: Loading spinner or check icon
                    if (widget.isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppTheme.primary,
                          ),
                        ),
                      )
                    else if (widget.isActive)
                      Icon(
                        Icons.check_circle_rounded,
                        color: widget.status.indicatorColor,
                        size: 24,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
