import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Supabase configuration for ResQ Mobile App
/// 
/// Credentials are loaded from .env file (not committed to git)
/// Copy .env.example to .env and add your actual Supabase credentials
class SupabaseConfig {
  /// Your Supabase project URL
  /// Format: https://xxxxxxxxxxxxx.supabase.co
  static String get supabaseUrl => dotenv.env['SUPABASE_URL']!;

  /// Your Supabase anonymous key (safe for client-side use)
  /// This key is protected by Row Level Security (RLS) policies
  static String get supabaseAnonKey => dotenv.env['SUPABASE_ANON_KEY']!;

  /// GPS polling interval when disaster mode is active (in seconds)
  static const int locationUpdateInterval = 300; // 5 minutes

  /// Minimum distance threshold for location updates (in meters)
  static const double locationDistanceThreshold = 100.0;

  /// Maximum number of offline status updates to queue
  static const int maxOfflineQueueSize = 50;

  /// Retry interval for offline sync (in seconds)
  static const int offlineSyncRetryInterval = 30;
}
