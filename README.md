# ResQ Mobile

A Flutter-based disaster response system that enables students to report their status during emergencies and helps administrators coordinate evacuation efforts in real-time.

## Overview

ResQ Mobile is a critical communication platform designed for university campus disaster response. Students can quickly update their status (Safe, Needs Assistance, Critical, Evacuated) with their GPS location, while administrators monitor the situation through a real-time dashboard.

## Key Features

- **Status Updates**: Students quickly report their safety status with location data
- **Real-time Map**: View student locations and designated evacuation centers
- **Authentication**: Secure Google OAuth and email/password sign-in via Supabase
- **Location Sharing**: GPS-enabled location tracking with permission management
- **Evacuation Centers**: Map display of designated safe zones with capacity information
- **Audit Trail**: Complete history of all status updates for emergency response planning

## Architecture

### Technology Stack
- **Frontend**: Flutter (Dart)
- **Backend**: Supabase (PostgreSQL + Auth)
- **Maps**: flutter_map with OpenStreetMap
- **Location**: geolocator for GPS tracking
- **State Management**: Provider pattern

### Database Schema
The application uses the following main tables:
- **students**: User profiles with home location and risk assessment
- **status_logs**: Complete audit trail of all status updates
- **evacuation_centers**: Designated safe zones with coordinates
- **admins**: Administrator accounts for dashboard access
- **system_settings**: Global disaster mode configuration

See [ERD.txt](ERD.txt) for complete database schema and RLS policies.

## Project Structure

```
lib/
├── models/              # Data models (Status, EvacuationCenter, UserProfile)
├── services/            # Backend integrations (Auth, Status, Location, EvacuationCenter)
├── providers/           # State management (AppState, Auth)
├── screens/             # Main pages (Home, Map, Auth)
├── pages/               # UI components and forms
├── widgets/             # Reusable UI components
├── theme/               # Design system and colors
├── constants/           # App constants
└── utils/               # Helper functions

docs/                    # Documentation and guides
```

## Setup & Development

### Prerequisites
- Flutter 3.8.0+
- Dart 3.4.0+
- Android SDK or Xcode for testing
- Supabase project

### Installation

```bash
# Clone repository
git clone <repo>
cd resq-mobile

# Install dependencies
flutter pub get

# Configure environment
cp .env.example .env  # Fill in Supabase credentials

# Run development
flutter run
```

### Configuration

Create a `.env` file:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_anon_key
GOOGLE_OAUTH_IOS_CLIENT_ID=your_ios_client_id
GOOGLE_OAUTH_WEB_CLIENT_ID=your_web_client_id
```

## Core Features Implementation

### Status Update System
Students send status updates to the backend with their current location. The system:
1. Validates the status value
2. Updates the STUDENTS table with latest status
3. Creates an audit log entry in STATUS_LOGS
4. Supports offline queuing for SMS fallback

See `lib/services/status_service.dart` for implementation.

### Evacuation Centers
Real-time display of evacuation centers:
1. Fetches from EVACUATION_CENTERS table
2. Caches results for 30 minutes
3. Calculates distance to nearby centers
4. Shows on interactive map with detail info

See `lib/services/evacuation_center_service.dart` for implementation.

### Authentication
Secure authentication via Supabase:
- Google OAuth (automatic email verification)
- Email/Password (manual verification)
- Row-Level Security policies for data isolation
- Session management with refresh tokens

See `lib/services/auth_service.dart` for implementation.

## API Integration

All backend operations go through Supabase client:

```dart
// Example: Update status
final statusService = StatusService();
await statusService.updateStatus(
  status: 'SAFE',
  latitude: location.latitude,
  longitude: location.longitude,
);

// Example: Fetch evacuation centers
final centers = await appState.fetchEvacuationCenters();
```

### Row-Level Security (RLS)

The database enforces security through RLS policies:
- **Students**: Can only view/update their own data
- **Admins**: Can view all data for monitoring
- **Public**: Evacuation centers and system settings are readable by all authenticated users

See [ERD.txt](ERD.txt) for complete RLS policy documentation.

## Testing

```bash
# Run tests
flutter test

# Build for release
flutter build apk   # Android
flutter build ios   # iOS
```

## Documentation

Detailed documentation for each feature:
- [Status Update System](docs/STATUS_UPDATE_IMPLEMENTATION.md)
- [Evacuation Centers](docs/MAP_FEATURE_GUIDE.md)
- [Authentication](docs/AUTHENTICATION.md)
- [Location Integration](docs/LOCATION_INTEGRATION_GUIDE.md)
- [All Documentation](docs/)

## Security

- **Passwords**: Securely hashed and managed by Supabase Auth
- **Data Isolation**: RLS policies enforce per-user and per-role access
- **Location Data**: Only users can see their own coordinates
- **Session Management**: Automatic token refresh and secure logout
- **Admin Access**: Protected by admin RLS policies

## Performance

- **Caching**: Evacuation center data cached for 30 minutes
- **Optimization**: Lazy-loaded maps and location services
- **Offline Support**: Local preferences allow offline status viewing
- **Minimal Dependencies**: Strategic use of lightweight libraries

## Contributing

1. Create a feature branch (`git checkout -b feature/feature-name`)
2. Make changes
3. Test thoroughly
4. Commit with clear messages
5. Push and create a Pull Request

## License

[Add your license here]

## Support

For issues or questions, please:
1. Check [documentation](docs/)
2. Review [ERD.txt](ERD.txt) for database schema
3. Open an issue on the repository

---

**Last Updated**: February 27, 2026  
**Status**: Active Development
