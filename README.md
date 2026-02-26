# ResQ Mobile - Disaster Response System (Student App)

A Flutter mobile application for students to report their safety status during disaster situations.

## 🎯 Purpose

ResQ Mobile is the **student-facing mobile application** for a disaster response system. It enables students to:
- Report their status (SAFE, NEEDS_ASSISTANCE, CRITICAL, EVACUATED)
- Share GPS location when disaster mode is active
- Work offline and sync when connection is restored
- Use SMS fallback when internet is unavailable

## 🏗️ Architecture

### Components
- **Mobile App (this repo):** Flutter application for Android/iOS
- **Backend:** Supabase (PostgreSQL + Edge Functions)
- **Admin Dashboard:** Separate web application (Next.js/React)
- **SMS Gateway:** Android app for SMS processing

### Tech Stack
- **Frontend:** Flutter 3.41.2 / Dart 3.11.0
- **Backend:** Supabase (PostgreSQL, Row-Level Security, Real-time)
- **Authentication:** Supabase Auth with student ID
- **State Management:** TBD (Provider/Riverpod/Bloc)
- **Offline Storage:** SQLite/Hive for offline-first sync

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.41.2 or higher
- Dart 3.11.0 or higher
- Android Studio / Xcode (for mobile development)
- Supabase account

### Installation

1. **Clone the repository**
```bash
git clone <repository-url>
cd resq-mobile
```

2. **Install Flutter dependencies**
```bash
flutter pub get
```

3. **Set up Supabase backend**
   - See [docs/BACKEND_SETUP.md](docs/BACKEND_SETUP.md) for detailed instructions
   - Run database migrations from `supabase/migrations/`

4. **Configure Supabase credentials**
   - Create `lib/config/supabase_config.dart`
   - Add your Supabase URL and anon key

5. **Run the app**
```bash
flutter run
```

## 📱 Features

### Core Features
- ✅ Simple login with student ID
- ⏳ One-tap status selection (SAFE, NEEDS_ASSISTANCE, CRITICAL, EVACUATED)
- ⏳ Confirmation dialog for CRITICAL status
- ⏳ GPS location tracking (activated by admin disaster mode)
- ⏳ Battery-efficient location polling (100m threshold)
- ⏳ Offline-first architecture with auto-sync
- ⏳ SMS fallback instructions when offline
- ⏳ Real-time disaster mode updates from admin
- ⏳ Display current status and last update time
- ⏳ Internet connectivity indicator

### Security
- Row-Level Security (RLS) policies
- Students can only access their own data
- Location data encrypted in transit
- Offline data stored securely on device

## 📚 Documentation

- [Database Schema](docs/DATABASE_SCHEMA.md) - Table structures and relationships
- [RLS Policies](docs/RLS_POLICIES.md) - Security policies explained
- [API Reference](docs/API_REFERENCE.md) - Supabase functions and queries
- [Backend Setup](docs/BACKEND_SETUP.md) - Supabase configuration guide
- [Deployment](docs/DEPLOYMENT.md) - Production deployment steps

## 🗄️ Database

The app uses Supabase PostgreSQL with these main tables:
- **students** - User directory and current status
- **status_logs** - Audit trail of all status updates
- **evacuation_centers** - Location data for shelters
- **system_settings** - Disaster mode toggle
- **admins** - Admin user access control

See [docs/DATABASE_SCHEMA.md](docs/DATABASE_SCHEMA.md) for details.

## 🔒 Privacy & Security

- **Location Privacy:** GPS only active during disaster mode
- **Data Minimization:** Only essential data collected
- **Access Control:** RLS ensures students see only their data
- **Offline Security:** Local data encrypted at rest
- **No Tracking:** Location not stored unless disaster mode active

## 🛠️ Development

### Project Structure
```
lib/
├── main.dart              # App entry point
├── config/                # Configuration files
├── models/                # Data models
├── services/              # Supabase, GPS, offline sync
├── screens/               # UI screens
├── widgets/               # Reusable components
└── utils/                 # Helper functions
```

### Running Tests
```bash
flutter test
```

### Code Style
This project follows the [Flutter style guide](https://flutter.dev/docs/development/packages-and-plugins/developing-packages#code-organization).

## 🤝 Contributing

This is a hackathon project. For major changes, please discuss with the team first.

## 📄 License

[To be determined]

## 🆘 Support

For issues or questions:
- Check [docs/BACKEND_SETUP.md](docs/BACKEND_SETUP.md) for setup help
- Review [docs/API_REFERENCE.md](docs/API_REFERENCE.md) for API usage
- Contact the development team

## 🎯 Roadmap

- [x] Project setup and structure
- [x] Database schema design
- [x] RLS policies implementation
- [ ] Supabase integration
- [ ] Authentication flow
- [ ] Status update UI
- [ ] GPS tracking implementation
- [ ] Offline sync functionality
- [ ] SMS fallback system
- [ ] Testing and optimization
- [ ] Production deployment

---

**Note:** This is the student-facing mobile app. The admin dashboard is a separate web application.
