# ![ResQ Logo](assets/images/logo.svg) ResQ Mobile

A Flutter disaster response app where students report their emergency status and see evacuation centers on an interactive map.

![Flutter](https://img.shields.io/badge/Flutter-3.8.0+-blue?logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.4.0+-blue?logo=dart)
![License](https://img.shields.io/badge/License-MIT-orange)

---

## What is ResQ?

ResQ Mobile helps during emergencies by letting students quickly report if they're safe, need help, are in critical condition, or have been evacuated. Their location is captured automatically, and they can see designated evacuation centers on a map.

**For Students**: Report your status with one tap  
**For Admins**: Monitor all student locations and statuses in real-time  
**For Emergency Teams**: Coordinate response and resource allocation

---

## Key Features

✅ **Quick Status Updates** - Safe, Needs Assistance, Critical, Evacuated  
✅ **GPS Location Tracking** - Automatic location capture with status  
✅ **Interactive Map** - View your location and evacuation centers  
✅ **Secure Login** - Google OAuth and email/password authentication  
✅ **Complete History** - Every status update is logged and timestamped  
✅ **Dark Mode Design** - Easy on the eyes, accessible UI  
✅ **Offline Support** - App works even without internet  

---

## Tech Stack

- **Frontend**: Flutter + Dart
- **Maps**: flutter_map with OpenStreetMap
- **Location**: geolocator for GPS
- **Backend**: Supabase (PostgreSQL + Auth)
- **State Management**: Provider

---

## Getting Started

### Prerequisites

- Flutter 3.8.0+ ([Install](https://flutter.dev/docs/get-started/install))
- Dart 3.4.0+ (included with Flutter)
- Android SDK or Xcode
- Git

### Installation

```bash
# Clone the project
git clone https://github.com/yourusername/resq-mobile.git
cd resq-mobile

# Install dependencies
flutter pub get

# Run the app
flutter run
```

### Setup Supabase

1. Create a project at [supabase.com](https://supabase.com)
2. Copy your project URL and API key
3. Create a `.env` file in the root directory:

```env
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_anon_key_here
GOOGLE_OAUTH_IOS_CLIENT_ID=your_ios_client_id
GOOGLE_OAUTH_WEB_CLIENT_ID=your_web_client_id
```

4. Run SQL migrations to create tables (see `ERD.txt` for schema)

---

## How to Use

### For Students

1. **Sign In** → Use Google or email/password
2. **Complete Profile** → Add your student ID and contact info (first time only)
3. **Update Status** → Tap a status button on the home screen
4. **View Map** → Tap "View Emergency Map" to see evacuation centers

### For Admins

- Access the admin dashboard (coming soon) to monitor all student statuses and locations

---

## Project Structure

```
lib/
├── models/              # Data models (Status, EvacuationCenter, UserProfile)
├── services/            # Backend logic (Auth, Status, Location, EvacuationCenter)
├── providers/           # State management (AppState, Auth)
├── screens/             # Full-page views (Home, Map)
├── pages/               # Forms and UI pages (Sign In, Sign Up)
├── widgets/             # Reusable components (StatusButton, LogoutDialog)
├── theme/               # Design system (colors, typography)
├── constants/           # App constants
└── utils/               # Helper functions

docs/                    # Detailed documentation
```

---

## Database

ResQ uses PostgreSQL with Supabase. Main tables:

| Table | Purpose |
|-------|---------|
| `students` | User profiles with status and location |
| `status_logs` | History of all status updates |
| `evacuation_centers` | Safe zone locations |
| `system_settings` | Disaster mode configuration |
| `admins` | Admin accounts |

See `ERD.txt` for the complete schema with Row-Level Security policies.

---

## What's Implemented

✅ User authentication (Google OAuth + email/password)  
✅ Student profiles and data persistence  
✅ Status update system with database sync  
✅ Location services with GPS  
✅ Evacuation center fetching and caching  
✅ Interactive map with markers  
✅ Dark theme design  
✅ Logout functionality  

🚧 Coming Soon:
- Admin dashboard
- Push notifications
- SMS fallback for status updates
- Photo upload with status
- Auto-triage (mark students UNKNOWN after 6 hours of no updates)

---

## Security

- **Passwords** are securely hashed by Supabase Auth
- **Row-Level Security** ensures students only see their own data
- **Admins** can view all student data for emergency coordination
- **Sessions** have automatic token refresh
- **Location data** is private to each student

---

## Testing

```bash
# Check code quality
flutter analyze

# Run tests
flutter test

# Build for release
flutter build apk       # Android
flutter build ios       # iOS
```

---

## Documentation

For detailed guides, see the `docs/` folder:

- **[docs/AUTHENTICATION.md](docs/AUTHENTICATION.md)** - Sign-in/sign-up details
- **[docs/STATUS_UPDATE_IMPLEMENTATION.md](docs/STATUS_UPDATE_IMPLEMENTATION.md)** - Status system
- **[docs/MAP_FEATURE_GUIDE.md](docs/MAP_FEATURE_GUIDE.md)** - Map and evacuation centers
- **[docs/QUICK_REFERENCE.md](docs/QUICK_REFERENCE.md)** - Code snippets and quick lookup
- **[docs/DESIGN_SYSTEM_GUIDE.md](docs/DESIGN_SYSTEM_GUIDE.md)** - UI/UX and colors

---

## Contributing

1. Create a feature branch: `git checkout -b feature/your-feature`
2. Make your changes
3. Run `flutter analyze` to check code quality
4. Commit: `git commit -m "feat: describe what you added"`
5. Push and create a Pull Request

---

## License

MIT License - See LICENSE file for details.

---

## Questions?

- Check the `docs/` folder for detailed guides
- Read `ERD.txt` for database information
- Open an issue on GitHub
- Contact: resq-support@example.com

---

**Status**: Active Development  
**Last Updated**: February 27, 2026  
**Version**: 1.0.0

*ResQ Mobile - Save Lives, Coordinate Better* 🚨
