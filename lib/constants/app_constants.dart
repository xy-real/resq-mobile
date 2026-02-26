/// Application-wide constants
class AppConstants {
  // Google OAuth Credentials
  static const String googleWebClientId =
      '594868454705-i8aq2sdbmikdlh40t0r1c81dephflh33.apps.googleusercontent.com';
  static const String googleIosClientId =
      '594868454705-ajffnc43hi4jleoj01mouapoen324gu4.apps.googleusercontent.com';

  // API Timeouts (in seconds)
  static const int connectionTimeout = 30;
  static const int receiveTimeout = 30;

  // Password Requirements
  static const int minPasswordLength = 8;

  // Session Management
  static const Duration sessionTimeout = Duration(hours: 1);

  // Animation Durations
  static const Duration shortDuration = Duration(milliseconds: 200);
  static const Duration mediumDuration = Duration(milliseconds: 400);
  static const Duration longDuration = Duration(milliseconds: 800);

  // App Info
  static const String appName = 'RESQ Mobile';
  static const String appVersion = '1.0.0';
  static const String buildNumber = '1';
}
