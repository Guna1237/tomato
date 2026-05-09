# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies (required after any pubspec.yaml change)
flutter pub get

# Run the app (Supabase URL + key are hardcoded in main.dart for dev)
flutter run

# Run on a specific device
flutter run -d <device-id>
flutter devices              # list connected devices

# Analyze
flutter analyze

# Hot reload in running session: r  |  Full restart: Shift+R
```

> After any pubspec.yaml change: `flutter clean && flutter pub get`.
> New asset files always need a full restart, not hot reload.

## Supabase Project

- **URL + anon key** are hardcoded in `lib/main.dart` (Supabase project `omewltjiqmfndkfdzcae`).
- Run SQL migrations in order via Supabase Dashboard → SQL Editor:
  1. `supabase/migrations/001_initial_schema.sql`
  2. `supabase/migrations/002_rls_policies.sql`
- Storage bucket: `profile-photos` (private, created manually in dashboard).
- See `supabase/README.md` for full setup steps.

### Edge Functions

Four functions under `supabase/functions/`:

| Function | Trigger | What it does |
|----------|---------|--------------|
| `validate-identity` | Profile setup submit | Runs ML face check, uploads photo to Storage, inserts profile row |
| `transfer-credits` | Requester confirms delivery | Deducts credits from requester, pays runner, logs transactions |
| `match-runner` | Delivery broadcast | Sends push notifications to nearby active runners |
| `auto-confirm` | Scheduled / cron | Auto-confirms delivered deliveries after 24h |

Deploy all functions:
```bash
supabase link --project-ref omewltjiqmfndkfdzcae
supabase functions deploy validate-identity
supabase functions deploy transfer-credits
supabase functions deploy match-runner
supabase functions deploy auto-confirm
```

### Admin accounts

Admins are regular users (same OTP login) but with `role = 'admin'` in the `profiles` table.
Set via SQL: `UPDATE profiles SET role = 'admin' WHERE email = 'admin@mahindrauniversity.edu.in';`
The admin dashboard (`/admin`) is only shown in Settings if `profile.role == 'admin'`.

## Architecture

This is a **Flutter + Supabase** production app — real auth, real database, real file storage.

### Layer structure

```
lib/
├── main.dart                     # Supabase.initialize → ProviderScope → TomatoApp
├── app.dart                      # MaterialApp.router + theme wiring
├── core/
│   ├── theme/                    # Design tokens (colors, type, spacing, ThemeData)
│   ├── router/app_router.dart    # GoRouter + ShellRoute + profile gate
│   ├── supabase/supabase_client.dart  # Global `supabase` accessor
│   ├── providers/                # All Riverpod providers
│   └── services/                 # face_detection_service (conditional import)
├── data/
│   ├── models/                   # Dart model classes with fromJson/toJson
│   └── mock/                     # Mock data used only where real data isn't wired yet
├── shared/widgets/               # Reusable primitives
└── features/                     # One folder per screen/flow
```

### Database schema (key tables)

| Table | Key columns |
|-------|-------------|
| `profiles` | `id` (FK → auth.users), `role` (student/faculty/admin), `display_name`, `face_status` (pending/approved/rejected/flagged), `tomato_credits`, `streak_days`, `reliability`, `is_runner`, `runner_active` |
| `deliveries` | `requester_id`, `runner_id`, `pickup_location`, `dropoff_location`, `item_size` (S/M/L), `urgency` (1.0–1.5), `credit_cost`, `status` (pending→matching→accepted→picked_up→en_route→delivered/cancelled) |
| `credit_transactions` | `from_user_id`, `to_user_id`, `amount`, `type` (earn/spend/bonus/refund/admin_adjustment/signup) |
| `runner_interests` | `delivery_id`, `runner_id`, `status` (waiting/accepted/rejected) |
| `notifications` | `user_id`, `title`, `body`, `type`, `read` |

### Navigation (GoRouter + ShellRoute)

`app_router.dart` defines all routes. **ShellRoute** wraps `/home`, `/assistant`, `/wallet`, `/profile` with a persistent `AppTabBar`.

**Profile gate in `_MainShell`:** watches `currentUserProvider`; if profile is null (not yet set up), redirects to `/profile-setup` via `addPostFrameCallback`.

- Tab bar: home → assistant → + (request) → wallet → profile
- `/notifications` — pushed from home bell icon, not a tab
- Slide-up: `/request`, `/matching`, `/emergency`
- Slide-right: all other non-shell routes
- Auth redirect: if no session → `/login`; if session + on login page → `/home`

### Providers (Riverpod)

| Provider | Type | Location |
|----------|------|----------|
| `authStateProvider` | `StreamProvider<AuthState>` | auth_provider.dart |
| `isAuthenticatedProvider` | `Provider<bool>` | auth_provider.dart |
| `currentUserProvider` | `FutureProvider<Profile?>` | auth_provider.dart |
| `currentUserIdProvider` | `Provider<String?>` | auth_provider.dart |
| `activeDeliveryProvider` | `StreamProvider<Delivery?>` | delivery_provider.dart |
| `deliveryByIdProvider` | `StreamProvider.family<Delivery?, String>` | delivery_provider.dart |
| `openDeliveriesProvider` | `StreamProvider<List<Delivery>>` | delivery_provider.dart |
| `runnerInterestsProvider` | `StreamProvider.family<List<RunnerInterest>, String>` | delivery_provider.dart |
| `transactionsProvider` | `StreamProvider<List<CreditTransaction>>` | transactions_provider.dart |
| `notificationsProvider` | `StreamProvider<List<AppNotification>>` | notifications_provider.dart |
| `adminStatsProvider` | `FutureProvider<AdminStats>` | admin_provider.dart |
| `adminQueueProvider` | `FutureProvider<List<AdminQueueEntry>>` | admin_provider.dart |
| `themeModeProvider` | `StateNotifierProvider<ThemeModeNotifier, ThemeMode>` | theme_provider.dart |

`activeDeliveryProvider` merges two Supabase Realtime streams (requester-side + runner-side) via `StreamController.broadcast()` because `.stream().eq()` only filters on one column.

### Auth flow

1. `/login` — email field, must end in `@mahindrauniversity.edu.in`
2. `/otp` — 6-digit code (set token length to 6 in Supabase Auth dashboard)
3. `/profile-setup` — display name, roll number (optional), face photo; calls `validate-identity` edge function
4. `_MainShell` gate — if `currentUserProvider` returns null profile, pushes to `/profile-setup`

### Face verification

`lib/core/services/face_detection_service.dart` uses conditional imports:
- `face_detection_service_native.dart` on mobile (uses `google_mlkit_face_detection`)
- `face_detection_service_stub.dart` on other platforms (returns confidence 0.85)

The edge function `validate-identity` receives the photo bytes, display name, roll number, and face confidence from the client. It uploads the photo to the `profile-photos` Storage bucket and inserts the profile row.

### Credit economy

- New user gets 50 credits on signup (inserted by `validate-identity` edge function).
- Delivery cost = base cost × item size multiplier × urgency.
- `transfer-credits` edge function handles atomic deduct + pay + log.

### Design system

All tokens in `core/theme/`. Never hardcode colors or font sizes in widget files.

**Dark mode pattern used everywhere:**
```dart
final isDark = Theme.of(context).brightness == Brightness.dark;
final bg    = isDark ? AppColors.darkCanvas  : AppColors.bgCanvas;
final fg1   = isDark ? AppColors.platinum    : AppColors.spaceIndigo;
final brand = isDark ? const Color(0xFFFF3D52) : AppColors.punchRed;
```

Dark canvas `#0C0D17`, dark surface `#1A1B2C`. Not pure black.

### Shared widgets

| Widget | Key behaviour |
|--------|--------------|
| `TomatoCard` | `isSelected` → 2px animated brand border; `onTap` optional |
| `TomatoButton` | `variant`: primary/secondary/soft/ghost/outline; `isLoading` shows spinner |
| `AppTabBar` | Glassmorphism `BackdropFilter`; always inside a `Positioned` in a `Stack` |
| `StatusChip` | `tone` enum: matching/enroute/delivered/idle/warn/neutral/info |
| `MapBackground` | `CustomPaint` abstract campus map; `height` param for clips |

### Mock data (partial)

`lib/data/mock/` is only used for screens not yet fully wired: `mock_runners.dart` (emergency screen runner picker), `mock_admin.dart` (admin AI summary string). Everything else is live Supabase data.
