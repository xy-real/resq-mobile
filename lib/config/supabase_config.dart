/// Supabase configuration for ResQ Mobile App
/// 
/// Replace these values with your actual Supabase project credentials.
/// You can find these in your Supabase Dashboard under Settings → API.
class SupabaseConfig {
  /// Your Supabase project URL
  /// Format: https://xxxxxxxxxxxxx.supabase.co
  static const String supabaseUrl = 'YOUR_SUPABASE_URL';

  /// Your Supabase anonymous key (safe for client-side use)
  /// This key is protected by Row Level Security (RLS) policies
  static const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

  /// GPS polling interval when disaster mode is active (in seconds)
  static const int locationUpdateInterval = 300; // 5 minutes

  /// Minimum distance threshold for location updates (in meters)
  static const double locationDistanceThreshold = 100.0;

  /// Maximum number of offline status updates to queue
  static const int maxOfflineQueueSize = 50;

  /// Retry interval for offline sync (in seconds)
  static const int offlineSyncRetryInterval = 30;
}
