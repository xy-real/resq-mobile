# Deployment Guide

## Pre-Deployment Checklist

- [ ] Supabase project created
- [ ] Database migrations tested locally
- [ ] RLS policies verified
- [ ] Environment variables documented
- [ ] Admin accounts created
- [ ] Real-time enabled on required tables
- [ ] Backup strategy in place

---

## 1. Supabase Setup

### Create Project

1. Go to [supabase.com](https://supabase.com)
2. Click "New Project"
3. Choose organization and region (closest to users)
4. Set database password (save securely!)
5. Wait for project to initialize (~2 minutes)

### Save Credentials

From Project Settings → API:
- **Project URL:** `https://xxxxx.supabase.co`
- **Anon Key:** Public key for client apps
- **Service Role Key:** Admin key (keep secret!)

---

## 2. Database Migration

### Option A: Using Supabase Dashboard

1. Go to SQL Editor
2. Copy contents of each migration file
3. Execute in order:
   - `001_create_tables.sql`
   - `002_enable_rls.sql`
   - `003_create_indexes.sql`
   - `004_create_functions.sql`

### Option B: Using Supabase CLI

```bash
# Install CLI
npm install -g supabase

# Login
supabase login

# Link project
supabase link --project-ref YOUR_PROJECT_REF

# Push migrations
supabase db push
```

### Verify Migration

```sql
-- Check tables exist
SELECT table_name FROM information_schema.tables 
WHERE table_schema = 'public';

-- Check RLS is enabled
SELECT tablename, rowsecurity FROM pg_tables 
WHERE schemaname = 'public';

-- Verify functions
SELECT routine_name FROM information_schema.routines 
WHERE routine_schema = 'public';
```

---

## 3. Enable Real-time

In Supabase Dashboard:

1. Go to **Database → Replication**
2. Enable replication for:
   - ✅ `students`
   - ✅ `status_logs`
   - ✅ `system_settings`
   - ✅ `evacuation_centers`
3. Click "Save"

---

## 4. Create Admin Accounts

```sql
-- Insert first super admin
INSERT INTO admins (email, role)
VALUES ('admin@university.edu', 'SUPER_ADMIN');

-- Insert viewer accounts
INSERT INTO admins (email, role)
VALUES 
  ('viewer1@university.edu', 'VIEWER'),
  ('viewer2@university.edu', 'VIEWER');
```

---

## 5. Seed Test Data (Optional)

```sql
-- Insert sample students
INSERT INTO students (student_id, name, contact_number, home_lat, home_lng)
VALUES 
  ('2021-00001', 'Juan Dela Cruz', '+639123456789', 14.5995, 120.9842),
  ('2021-00002', 'Maria Santos', '+639987654321', 14.6005, 120.9852);

-- Insert sample evacuation center
INSERT INTO evacuation_centers (center_name, latitude, longitude)
VALUES ('Main Campus Gym', 14.6000, 120.9850);
```

---

## 6. Configure Cron Job (Auto-Triage)

### Using Supabase Edge Functions + Cron

Create Edge Function:
```bash
supabase functions new auto-triage-cron
```

**File:** `supabase/functions/auto-triage-cron/index.ts`
```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )

  const { data, error } = await supabase.rpc('auto_triage_students')
  
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), { status: 500 })
  }

  return new Response(
    JSON.stringify({ 
      success: true, 
      affected: data[0].affected_count 
    }),
    { headers: { "Content-Type": "application/json" } }
  )
})
```

Deploy:
```bash
supabase functions deploy auto-triage-cron
```

### Using External Cron (e.g., cron-job.org)

1. Go to [cron-job.org](https://cron-job.org)
2. Create new job
3. **URL:** `https://YOUR_PROJECT.supabase.co/functions/v1/auto-triage-cron`
4. **Schedule:** Every hour
5. **Headers:**
   ```
   Authorization: Bearer YOUR_SERVICE_ROLE_KEY
   ```

---

## 7. Mobile App Configuration

Update Flutter app's Supabase config:

**File:** `lib/config/supabase_config.dart`
```dart
class SupabaseConfig {
  static const String url = 'https://xxxxx.supabase.co';
  static const String anonKey = 'your-anon-key';
}
```

---

## 8. Admin Dashboard Deployment

### Environment Variables

Create `.env.local`:
```env
NEXT_PUBLIC_SUPABASE_URL=https://xxxxx.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key
```

### Deploy to Vercel

```bash
# Install Vercel CLI
npm i -g vercel

# Deploy
vercel --prod
```

Add environment variables in Vercel dashboard.

---

## 9. SMS Gateway Setup

### Android App Configuration

1. Deploy SMS gateway app to Android device
2. Set webhook URL: `https://YOUR_PROJECT.supabase.co/functions/v1/sms-webhook`
3. Add authorization header with service role key
4. Test with sample SMS: `VSU 2021-00001 SAFE`

### Create SMS Webhook Function

**File:** `supabase/functions/sms-webhook/index.ts`
```typescript
import { serve } from "https://deno.land/std@0.168.0/http/server.ts"
import { createClient } from 'https://esm.sh/@supabase/supabase-js@2'

serve(async (req) => {
  const { from, message } = await req.json()
  
  // Parse: "VSU <StudentID> <STATUS>"
  const pattern = /^VSU\s+(\S+)\s+(SAFE|NEEDS_ASSISTANCE|CRITICAL|EVACUATED)$/i
  const match = message.trim().match(pattern)
  
  const supabase = createClient(
    Deno.env.get('SUPABASE_URL') ?? '',
    Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') ?? ''
  )
  
  if (match) {
    const [_, studentId, status] = match
    
    await supabase.rpc('update_student_status', {
      p_student_id: studentId,
      p_status: status.toUpperCase(),
      p_source: 'SMS',
      p_validation_flag: true
    })
    
    return new Response(JSON.stringify({ success: true }))
  } else {
    // Log invalid SMS
    await supabase.from('status_logs').insert({
      student_id: 'INVALID',
      status: 'UNKNOWN',
      source: 'SMS',
      validation_flag: false
    })
    
    return new Response(JSON.stringify({ 
      success: false, 
      error: 'Invalid format' 
    }))
  }
})
```

---

## 10. Security Hardening

### RLS Verification

Test policies with different user roles:
```sql
-- Test as student
SET LOCAL request.jwt.claims = '{"sub": "2021-00001"}';
SELECT * FROM students; -- Should see only own record

-- Test as admin
SET LOCAL request.jwt.claims = '{"email": "admin@university.edu"}';
SELECT * FROM students; -- Should see all records
```

### API Rate Limiting

Configure in Supabase Dashboard → Settings → API:
- Set reasonable rate limits per IP
- Enable CORS for your domains only

### Environment Security

- ❌ Never commit `.env` files
- ✅ Use Supabase service role key only in server-side code
- ✅ Use anon key in mobile/web apps
- ✅ Rotate keys if compromised

---

## 11. Monitoring & Alerts

### Set Up Alerts

1. Go to Supabase Dashboard → Settings → Alerts
2. Configure:
   - Database size warnings
   - High error rates
   - Slow queries

### Log Monitoring

Check Edge Function logs:
```bash
supabase functions logs auto-triage-cron
supabase functions logs sms-webhook
```

---

## 12. Backup Strategy

### Automated Backups

Supabase provides daily backups (paid plan).

### Manual Backup

```bash
# Export database
supabase db dump -f backup_$(date +%Y%m%d).sql

# Backup to S3 (optional)
aws s3 cp backup_*.sql s3://your-bucket/backups/
```

---

## Post-Deployment Testing

- [ ] Test student login and status update
- [ ] Verify real-time updates on dashboard
- [ ] Send test SMS and confirm parsing
- [ ] Toggle disaster mode and verify mobile app response
- [ ] Test auto-triage function manually
- [ ] Verify RLS policies with different user roles
- [ ] Test offline queue sync on mobile

---

## Rollback Plan

If migration fails:
```sql
-- Drop tables in reverse order
DROP TABLE IF EXISTS status_logs CASCADE;
DROP TABLE IF EXISTS students CASCADE;
DROP TABLE IF EXISTS evacuation_centers CASCADE;
DROP TABLE IF EXISTS system_settings CASCADE;
DROP TABLE IF EXISTS admins CASCADE;

-- Re-run migrations
```

---

## Support

- **Supabase Docs:** https://supabase.com/docs
- **Status Page:** https://status.supabase.com
- **Community:** https://discord.supabase.com
