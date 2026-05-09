# Supabase Setup

1. Go to https://supabase.com and create a new project
2. In SQL Editor, run `migrations/001_initial_schema.sql`
3. In SQL Editor, run `migrations/002_rls_policies.sql`
4. Go to Storage → New bucket → Name: `profile-photos` → Private
5. Go to Settings → API → Copy Project URL and anon key
6. Run the app with:
   ```
   flutter run --dart-define=SUPABASE_URL=YOUR_URL --dart-define=SUPABASE_ANON_KEY=YOUR_KEY
   ```
7. For Edge Functions, install Supabase CLI:
   ```
   npm install -g supabase
   supabase login
   supabase link --project-ref YOUR_PROJECT_REF
   supabase functions deploy validate-identity
   supabase functions deploy transfer-credits
   supabase functions deploy match-runner
   supabase functions deploy auto-confirm
   ```
8. Set Edge Function secrets in Supabase Dashboard → Settings → Edge Functions:
   - FCM_SERVER_KEY: your Firebase Cloud Messaging server key
