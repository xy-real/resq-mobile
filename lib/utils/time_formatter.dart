import 'package:intl/intl.dart';

/// Utility class for formatting time-related information
class TimeFormatter {
  /// Format a DateTime to "X minutes/hours/days ago" format
  /// Returns "Never" if timestamp is null
  static String formatTimeAgo(DateTime? timestamp) {
    if (timestamp == null) {
      return 'Never';
    }

    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      final minutes = difference.inMinutes;
      return '$minutes min${minutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      final hours = difference.inHours;
      return '$hours hour${hours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      final days = difference.inDays;
      return '$days day${days > 1 ? 's' : ''} ago';
    } else {
      // For older dates, show the actual date
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }

  /// Generate SMS format string for disaster status
  /// Format: VSU [studentId] [status]
  static String generateSmsFormat(String studentId, String status) {
    return 'VSU $studentId $status';
  }

  /// Format a DateTime to a readable date string
  /// Example: "Monday, February 26, 2025 at 3:45 PM"
  static String formatDateTime(DateTime dateTime) {
    return DateFormat('EEEE, MMMM d, yyyy \'at\' h:mm a').format(dateTime);
  }

  /// Format a DateTime to time only
  /// Example: "3:45 PM"
  static String formatTime(DateTime dateTime) {
    return DateFormat('h:mm a').format(dateTime);
  }
}
