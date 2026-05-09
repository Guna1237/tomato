# Tomato Pilot Launch — Implementation Design

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development or superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Complete the two-sided marketplace and release a signed APK for a 20-50 student pilot at Mahindra University this week.

**Distribution:** APK sideload via Google Drive link.
**Admin setup:** Role-based (`profiles.role = 'admin'`), set via one-time SQL.
**Notifications:** Skipped for pilot — runners check the app manually.

---

## What is already built

- OTP auth restricted to `@mahindrauniversity.edu.in`
- Face photo verification via ML Kit + Supabase Storage
- Requester flow: request delivery → matching screen (waiting) → tracking
- Credit economy: deduct on request, pay runner via `transfer-credits` edge function
- Admin dashboard (visible only to `role = 'admin'` users in Settings)
- Real-time delivery tracking via Supabase Realtime streams

## What needs to be built

### 1. Runner toggle (Profile screen)

**File:** `lib/features/profile/profile_screen.dart`

Add a "Runner mode" toggle row below the reliability stats section. It shows only when the user is signed in. The toggle calls `ProfileRepository.setRunnerMode(bool active)`.

When toggled ON for the first time: sets `is_runner = true, runner_active = true`.
When toggled OFF: sets `runner_active = false` (keeps `is_runner = true` so history is preserved).

**New file:** `lib/data/repositories/profile_repository.dart`

```dart
static Future<void> setRunnerMode(String userId, bool active) async {
  await supabase.from('profiles').update({
    'is_runner': true,
    'runner_active': active,
  }).eq('id', userId);
}
```

---

### 2. Runner card on Home screen

**File:** `lib/features/home/home_screen.dart`

When `profile.isRunner == true && profile.runnerActive == true`, show a `RunnerActiveCard` widget above the quick actions grid. It displays the count of open jobs (from `openDeliveriesProvider`) and navigates to `/runner` on tap.

When `profile.isRunner == true && profile.runnerActive == false`, show a smaller "Runner mode off — tap to go online" chip that navigates to `/profile`.

**New file:** `lib/features/home/widgets/runner_active_card.dart`

A `TomatoCard` with a green left border, bolt icon, text "X jobs available near you", and a chevron.

---

### 3. Runner screen (`/runner`)

**New file:** `lib/features/runner/runner_screen.dart`

Full-screen route (not a tab). Shows a `ListView` of open deliveries from `openDeliveriesProvider`. Each item is a `RunnerJobCard`.

**New file:** `lib/features/runner/widgets/runner_job_card.dart`

Each card shows:
- Pickup location → Dropoff location (with arrow icon between)
- Item size badge (S / M / L)
- Credit reward (`+T{credit_cost}` in leaf500 green)
- "Accept" button (TomatoButton primary)

Tapping Accept calls `DeliveryRepository.acceptDelivery(deliveryId)`.

**Empty state:** Center-aligned icon + "No open jobs right now. Check back soon."

**Loading state:** `CircularProgressIndicator` centered.

---

### 4. Accept delivery — data layer

**SQL migration** (`supabase/migrations/003_accept_delivery_rpc.sql`):

The existing UPDATE RLS policy (`requester_id = auth.uid() OR runner_id = auth.uid()`) blocks a runner from accepting an unassigned delivery because `runner_id IS NULL`. The RPC uses `SECURITY DEFINER` to bypass RLS and do the update atomically — this is intentional and safe because the WHERE clause enforces the business rule.

The existing SELECT policy ("Runners can view open deliveries" in 002) already covers `openDeliveriesProvider`. No new SELECT policy needed.

```sql
-- RPC for atomic accept (prevents two runners grabbing the same job)
CREATE OR REPLACE FUNCTION accept_delivery(p_delivery_id uuid, p_runner_id uuid)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  UPDATE public.deliveries
  SET runner_id = p_runner_id,
      status = 'accepted',
      accepted_at = now()
  WHERE id = p_delivery_id
    AND status = 'matching'
    AND runner_id IS NULL;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'Delivery already accepted or not available';
  END IF;
END;
$$;
```

**Accept button error handling in `runner_screen.dart`:**
Wrap the call in try/catch. On success → navigate to `/tracking?delivery_id=$id`. On failure (exception from RPC) → show SnackBar "Job was just taken — try another one" and call `ref.invalidate(openDeliveriesProvider)` to refresh the list.

**Dart method** (`lib/data/models/delivery.dart` — add to `DeliveryRepository`):

```dart
static Future<void> acceptDelivery(String deliveryId) async {
  final runnerId = supabase.auth.currentUser!.id;
  await supabase.rpc('accept_delivery', params: {
    'p_delivery_id': deliveryId,
    'p_runner_id': runnerId,
  });
}
```

---

### 5. Matching screen auto-advance (requester side)

**File:** `lib/features/matching/matching_screen.dart`

The matching screen already watches `deliveryByIdProvider`. Add a `ref.listen` that fires when delivery status changes from `matching` to `accepted`, then navigates to `/tracking?delivery_id=$id`.

```dart
ref.listen(deliveryByIdProvider(deliveryId), (prev, next) {
  final delivery = next.valueOrNull;
  if (delivery?.status == DeliveryStatus.accepted) {
    context.go('/tracking?delivery_id=${delivery!.id}');
  }
});
```

---

### 6. Router: add `/runner` route

**File:** `lib/core/router/app_router.dart`

Add to the top-level routes (outside ShellRoute, slide-right transition):

```dart
GoRoute(
  path: '/runner',
  pageBuilder: (_, state) => CustomTransitionPage(
    key: state.pageKey,
    child: const RunnerScreen(),
    transitionsBuilder: _slideRight,
  ),
),
```

Import `RunnerScreen`.

---

### 7. Release APK signing

**Step 1 — Generate keystore** (run once, save the file):
```bash
keytool -genkey -v -keystore tomato-release.jks \
  -keyalg RSA -keysize 2048 -validity 10000 \
  -alias tomato
```
Store `tomato-release.jks` in `android/app/` (add to `.gitignore`).

**Step 2 — `android/key.properties`** (add to `.gitignore`):
```
storePassword=<your-password>
keyPassword=<your-password>
keyAlias=tomato
storeFile=tomato-release.jks
```

**Step 3 — `android/app/build.gradle.kts`** — add signing config:
```kotlin
val keystoreProperties = Properties()
val keystorePropertiesFile = rootProject.file("key.properties")
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

android {
    // ... existing config ...
    signingConfigs {
        create("release") {
            keyAlias = keystoreProperties["keyAlias"] as String
            keyPassword = keystoreProperties["keyPassword"] as String
            storeFile = file(keystoreProperties["storeFile"] as String)
            storePassword = keystoreProperties["storePassword"] as String
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
        }
    }
}
```

**Step 4 — Build:**
```bash
flutter build apk --release
```
Output: `build/app/outputs/flutter-apk/app-release.apk`

---

### 8. Admin bootstrap

Run once in Supabase Dashboard → SQL Editor after you create your account through the normal OTP flow:

```sql
UPDATE public.profiles
SET role = 'admin'
WHERE email = 'your-email@mahindrauniversity.edu.in';
```

The admin dashboard link appears automatically in Settings after this.

---

## Implementation order

1. SQL migration 003 (RPC + RLS policy) — run in Supabase dashboard
2. `profile_repository.dart` (runner toggle data layer)
3. Runner toggle in Profile screen
4. `runner_screen.dart` + `runner_job_card.dart` (new files)
5. `runner_active_card.dart` + wire into Home screen
6. `DeliveryRepository.acceptDelivery()` in delivery.dart
7. Matching screen `ref.listen` auto-advance
8. Router: add `/runner` route
9. APK signing config + release build
10. Admin bootstrap SQL (run after first account created)

## Definition of done

- A student can sign up via OTP, upload face photo, and request a delivery
- A different student can toggle runner mode ON, see the open job, and accept it
- The requester's matching screen auto-advances to tracking when accepted
- Both parties see the delivery in tracking with real-time status
- A signed `app-release.apk` can be installed on Android without Play Store
- One account has `role = 'admin'` and sees the admin dashboard in Settings
