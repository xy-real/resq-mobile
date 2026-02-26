import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Status options for emergency
enum StatusOption {
  safe('SAFE', Color(0xFF10b981)),
  needsAssistance('NEEDS ASSISTANCE', Color(0xFff97316)),
  critical('CRITICAL', Color(0xFFef4444)),
  evacuated('EVACUATED', Color(0xFF3b82f6));

  final String label;
  final Color color;

  const StatusOption(this.label, this.color);
}

/// Large button for selecting emergency status
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
  bool _isDebouncing = false;

  @override
  void initState() {
    super.initState();
    _lastPressed = DateTime.now();
  }

  void _handlePress() {
    final now = DateTime.now();
    final timeSinceLastPress = now.difference(_lastPressed);

    if (timeSinceLastPress < _debounceTime) {
      setState(() => _isDebouncing = true);
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          setState(() => _isDebouncing = false);
        }
      });
      return;
    }

    _lastPressed = now;
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.isLoading ? null : _handlePress,
      child: AnimatedScale(
        scale: _isDebouncing ? 0.95 : 1.0,
        duration: const Duration(milliseconds: 150),
        child: Container(
          decoration: BoxDecoration(
            color: widget.isActive ? widget.status.color : AppTheme.surfaceBlue,
            border: Border.all(
              color: widget.isActive ? widget.status.color : AppTheme.dividerColor,
              width: widget.isActive ? 3 : 2,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: widget.status.color.withValues(alpha: 0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: widget.isLoading ? null : _handlePress,
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isLoading)
                      SizedBox(
                        width: 32,
                        height: 32,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(
                            widget.isActive
                                ? Colors.white
                                : AppTheme.textPrimary,
                          ),
                          strokeWidth: 3,
                        ),
                      )
                    else
                      Text(
                        widget.status.label,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: widget.isActive
                              ? Colors.white
                              : AppTheme.textPrimary,
                        ),
                      ),
                    if (widget.isActive)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            const Text(
                              'Active',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
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
