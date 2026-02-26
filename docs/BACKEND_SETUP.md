# Backend Setup Guide

## Project Context

This repository (`resq-mobile`) is the **Flutter mobile application** for the **Student Role** in the ResQ Disaster Response System. The backend infrastructure uses Supabase (PostgreSQL database + Edge Functions) and is configured within this repository for easy integration with the mobile app.

The mobile app handles:
- Student authentication and status updates
- GPS location tracking (when disaster mode is active)
- Offline-first data sync
- SMS fallback instructions

The backend (Supabase) provides:
- PostgreSQL database with RLS security
- Real-time subscriptions for live updates
- Serverless Edge Functions for SMS processing
- Auto-triage logic via cron jobs

---

## Prerequisites

- Supabase account and project created
- Supabase CLI installed: `npm install -g supabase`
- Flutter SDK installed (already set up in this project)
- Git installed

---

## Setup Steps

### 1. Initialize Supabase Project

```bash
# Link to your Supabase project
supabase link --project-ref YOUR_PROJECT_REF

# Pull existing config (if any)
supabase db pull
```

### 2. Apply Database Migrations

Run migrations in order:

```bash
# Create tables
supabase db push

# Or apply migrations individually
psql -h YOUR_DB_HOST -U postgres -d postgres -f supabase/migrations/001_create_tables.sql
psql -h YOUR_DB_HOST -U postgres -d postgres -f supabase/migrations/002_enable_rls.sql
psql -h YOUR_DB_HOST -U postgres -d postgres -f supabase/migrations/003_create_indexes.sql
```

### 3. Enable Real-time

In Supabase Dashboard:
1. Go to Database → Replication
2. Enable real-time for these tables:
   - `students`
   - `status_logs`
   - `system_settings`

### 4. Set Up Edge Functions (Optional)

```bash
# Deploy SMS validation function
supabase functions deploy sms-webhook

# Deploy auto-triage cron job
supabase functions deploy auto-triage
```

### 5. Configure Authentication

1. Go to Authentication → Providers
2. Enable Email provider (for admins)
3. For students: Custom authentication using student_id
4. Set JWT expiration as needed

### 6. Configure Flutter Mobile App

Update the Supabase configuration in the Flutter project:

**File:** `lib/config/supabase_config.dart` (create this file)

```dart
class SupabaseConfig {
  static const String supabaseUrl = 'https://YOUR_PROJECT_REF.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key-here';
}
```

Add Supabase Flutter package to `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.0.0
```

Then run:
```bash
flutter pub get
```

**Security:** The anon key is safe for mobile apps as RLS policies protect the data.

### 7. Environment Variables (For Admin Dashboard - Separate Project)

When you build the admin dashboard (Next.js/React), create `.env` file:

```env
NEXT_PUBLIC_SUPABASE_URL=your-project-url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

**Security:** Never commit service role key to Git!

---

## Repository Structure

```
resq-mobile/                    # This is the Flutter mobile app
├── lib/                       # Flutter app source code (Student Role)
│   ├── main.dart             # App entry point
│   └── config/               # Configuration files (Supabase, etc.)
├── supabase/                 # Backend configuration
│   ├── migrations/           # SQL schema files
│   │   ├── 001_create_tables.sql
│   │   ├── 002_enable_rls.sql
│   │   ├── 003_create_indexes.sql
│   │   └── 004_create_functions.sql
│   └── functions/            # Edge Functions (to be created)
│       ├── sms-webhook/      # SMS validation endpoint
│       └── auto-triage/      # Cron job for 6-hour rule
└── docs/                     # Documentation
    ├── DATABASE_SCHEMA.md
    ├── RLS_POLICIES.md
    ├── API_REFERENCE.md
    └── BACKEND_SETUP.md      # This file
```

## Backend Components

### Database
- **Location:** `/supabase/migrations/`
- **Purpose:** SQL files for schema creation and updates
- **Applies to:** Both student app and admin dashboard

### Edge Functions
- **Location:** `/supabase/functions/`
- **Purpose:** Serverless functions for:
  - SMS webhook processing
  - Auto-triage cron jobs
  - Location validation
- **Note:** Shared by both mobile app and admin dashboard

### RLS Policies
- **Defined in:** Migration files
- **Purpose:** Fine-grained access control
- **Security:** Students can only access their own data; admins see everything

---

## Testing

### Test Database Setup

```bash
# Start local Supabase
supabase start

# Run migrations on local
supabase db reset

# Test queries
psql postgresql://postgres:postgres@localhost:54322/postgres
```

### Test RLS Policies

```sql
-- Set test user context
SET LOCAL request.jwt.claims = '{"sub": "test-student-id"}';

-- Try to select (should only return own record)
SELECT * FROM students;
```

---

## Maintenance

### Backups

Supabase provides automated backups. To manually backup:

```bash
supabase db dump -f backup.sql
```

### Monitoring
### For Student Mobile App (Current Repository):
1. ✅ Create database tables (migrations ready)
2. ✅ Enable RLS policies (migrations ready)
3. ⏳ Run Supabase migrations
4. ⏳ Add Supabase Flutter package
5. ⏳ Implement authentication (student ID)
6. ⏳ Build status update UI
7. ⏳ Implement GPS tracking
8. ⏳ Add offline sync functionality

### For Admin Dashboard (Separate Project - Future):
1. ⏳ Create Next.js/React project
2. ⏳ Build dashboard UI
3. ⏳ Integrate real-time subscriptions
4. ⏳ Add map visualization
5. ⏳ Implement disaster mode toggle

### For Backend Infrastructure:
1. ⏳ Set up SMS gateway webhook
2. ⏳ Deploy auto-triage cron function
3. ⏳ Test real-time subscriptions
4. ⏳ Monitor and optimize performance

Set up a cron job (via Supabase Cron or external service) to call the auto-triage function every hour while disaster mode is active.

---

## Common Issues

**Issue:** RLS blocking queries
**Solution:** Check if user is properly authenticated and policies match

**Issue:** Real-time not updating
**Solution:** Verify replication is enabled for the table

**Issue:** SMS validation failing
**Solution:** Check Edge Function logs and validate SMS format

---

## Next Steps

1. ✅ Create database tables
2. ✅ Enable RLS policies
3. ⏳ Build admin dashboard
4. ⏳ Integrate mobile app with Supabase
5. ⏳ Set up SMS gateway webhook
6. ⏳ Deploy auto-triage function
