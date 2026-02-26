import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Status options for emergency with semantic color meanings
/// Includes both display label (user-friendly) and backend value (for API/storage)
enum StatusOption {
  safe('Safe', 'SAFE', Color(0xFF10b981)), // Green
  needsAssistance('Needs Assistance', 'NEEDS ASSISTANCE', Color(0xFff97316)), // Amber
  critical('Critical', 'CRITICAL', Color(0xFFef4444)), // Red
  evacuated('Evacuated', 'EVACUATED', Color(0xFF3b82f6)); // Blue

  final String label; // User-friendly display label
  final String backendValue; // Value for backend/storage
  final Color color;

  const StatusOption(this.label, this.backendValue, this.color);
}

/// Modern status button following Material 3 design principles
/// - Flat design with soft elevation
/// - Clear visual hierarchy and states
/// - Accessibility-first approach (WCAG compliant contrast)
/// - 44-48px minimum touch target
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
        opacity: isInteractive ? 1.0 : 0.6,
        duration: const Duration(milliseconds: 200),
        child: Container(
          // Minimum 48px height for accessibility (including padding)
          constraints: const BoxConstraints(minHeight: 48),
          decoration: BoxDecoration(
            // Flat color backgrounds with semantic meaning
            color: widget.isActive ? widget.status.color : AppTheme.surfaceElevated,
            borderRadius: BorderRadius.circular(16), // Modern rounded corners
            // Soft elevation shadow (subtle, not glowing)
            boxShadow: [
              if (widget.isActive)
                BoxShadow(
                  color: widget.status.color.withValues(alpha: 0.12),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                )
              else
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isInteractive ? _handlePress : null,
              borderRadius: BorderRadius.circular(16),
              splashColor: Colors.white.withValues(alpha: 0.1),
              highlightColor: Colors.white.withValues(alpha: 0.05),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16, // 16px vertical padding (8pt system)
                  horizontal: 20, // 20px horizontal padding
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Status label with clear hierarchy
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.status.label,
                            style: TextStyle(
                              // Title: 18-20pt semibold for clear hierarchy
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              // High contrast: white on colored background, dark on light
                              color: widget.isActive
                                  ? Colors.white
                                  : AppTheme.textPrimary,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacing12),
                    // Loading spinner or check icon
                    if (widget.isLoading)
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.isActive
                                ? Colors.white
                                : AppTheme.textPrimary,
                          ),
                        ),
                      )
                    else if (widget.isActive)
                      // Subtle check icon for active state (not large badge)
                      Icon(
                        Icons.check_rounded,
                        color: Colors.white,
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
