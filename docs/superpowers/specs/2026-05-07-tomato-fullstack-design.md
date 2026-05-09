# Tomato — Full-Stack Design Spec
**Date:** 2026-05-07  
**Status:** Approved  
**Scope:** Full production app — real Supabase backend, tomato credits economy, hybrid matching, ML face verification, UI polish

---

## 1. Architecture

```
Flutter App (Dart)
├── supabase_flutter          — auth, db, storage, realtime
├── google_mlkit_face_detection — on-device face check (free, private)
├── firebase_messaging        — background push notifications (FCM)
└── flutter_riverpod          — all state management

Supabase (free tier)
├── Auth                      — email OTP, magic link disabled
├── PostgreSQL                — users, deliveries, credit_ledger, notifications
├── Storage                   — profile photos (private bucket, signed URLs)
├── Realtime                  — delivery status live updates, matching events
└── Edge Functions (Deno)
    ├── validate-identity     — roll number format + faculty registry check
    ├── match-runner          — scoring cascade + FCM trigger
    ├── transfer-credits      — atomic debit/credit in one DB transaction
    └── auto-confirm          — cron: confirm delivery after 10min inactivity

External
└── Firebase Cloud Messaging  — push to backgrounded app (free)
```

**Key constraint:** No real money ever. Tomato credits only. No payment gateway needed.

---

## 2. Database Schema

### `profiles` (extends `auth.users`)
```sql
id              uuid PK (FK auth.users.id)
email           text UNIQUE NOT NULL
role            text CHECK (role IN ('student','faculty','admin'))
display_name    text NOT NULL
roll_number     text UNIQUE  -- students only, extracted from email prefix
employee_id     text UNIQUE  -- faculty only, entered manually
photo_url       text         -- signed URL from Storage
face_status     text CHECK (face_status IN ('pending','approved','rejected','flagged'))
face_confidence float        -- ML Kit score at upload time
tomato_credits  integer DEFAULT 50 NOT NULL
streak_days     integer DEFAULT 0
reliability     float DEFAULT 1.0
is_runner       boolean DEFAULT false
runner_active   boolean DEFAULT false  -- currently available for matching
created_at      timestamptz DEFAULT now()
```

### `deliveries`
```sql
id              uuid PK DEFAULT gen_random_uuid()
requester_id    uuid FK profiles.id
runner_id       uuid FK profiles.id NULLABLE
pickup_location text NOT NULL
dropoff_location text NOT NULL
item_size       text CHECK (item_size IN ('S','M','L'))
urgency         float DEFAULT 1.0  -- 1.0–1.5 multiplier
credit_cost     integer NOT NULL   -- pre-computed at request time
status          text CHECK (status IN ('pending','matching','accepted','picked_up','en_route','delivered','cancelled'))
match_attempt   integer DEFAULT 0  -- how many runners tried
created_at      timestamptz DEFAULT now()
accepted_at     timestamptz
picked_up_at    timestamptz
delivered_at    timestamptz
confirmed_at    timestamptz        -- requester confirm or auto-confirm
notes           text
```

### `credit_transactions`
```sql
id              uuid PK DEFAULT gen_random_uuid()
from_user_id    uuid NULLABLE FK profiles.id  -- NULL = system
to_user_id      uuid FK profiles.id
amount          integer NOT NULL
type            text CHECK (type IN ('earn','spend','bonus','refund','admin_adjustment','signup'))
reference_id    uuid NULLABLE  -- delivery id or NULL
created_at      timestamptz DEFAULT now()
```

### `faculty_registry`
```sql
id              uuid PK
email           text UNIQUE NOT NULL
employee_id     text UNIQUE NOT NULL
display_name    text
department      text
```

### `notifications`
```sql
id              uuid PK DEFAULT gen_random_uuid()
user_id         uuid FK profiles.id
title           text NOT NULL
body            text NOT NULL
type            text  -- delivery/credit/system/match
read_at         timestamptz NULLABLE
created_at      timestamptz DEFAULT now()
```

### `runner_interests`
```sql
id              uuid PK DEFAULT gen_random_uuid()
delivery_id     uuid FK deliveries.id
runner_id       uuid FK profiles.id
expressed_at    timestamptz DEFAULT now()
status          text DEFAULT 'waiting' CHECK (status IN ('waiting','selected','dismissed'))
-- 'selected' = requester chose this runner
-- 'dismissed' = requester chose someone else
```

---

## 3. Auth & Identity

### Student flow
1. Enter `rollno@mahindrauniversity.edu.in`
2. Supabase sends email OTP (6 digits, 10-minute expiry)
3. User enters OTP → session created
4. Edge Function `validate-identity` extracts prefix, validates regex:  
   `^[a-z]{2}\d{2}[a-z]{4}\d{3}$` (e.g. `se23ucse001`)
5. If mismatch or invalid → session revoked, error shown
6. Profile setup: name pre-filled from email, roll number shown read-only, photo required

### Faculty flow
1. Enter `firstname.lastname@mahindrauniversity.edu.in`
2. OTP same as above
3. Profile setup: must enter Employee ID
4. Edge Function cross-checks entered ID against `faculty_registry` table
5. If not found → account blocked, contact admin message shown

### Face verification
- Google ML Kit `FaceDetector` runs on-device before any upload
- Single face detected + bounding box > 20% of image area required
- Confidence ≥ 0.85 → `face_status = 'approved'`, photo uploaded
- Confidence 0.60–0.84 → `face_status = 'flagged'`, photo uploaded, admin review queue, user sees "Verification pending" banner, can still use app
- Confidence < 0.60 → rejected locally, user must retake, nothing uploaded
- Admin can approve/reject flagged photos from admin dashboard

---

## 4. Tomato Credit Economy

### Credit table

| Event | Credits |
|-------|---------|
| New account signup | +50 |
| Complete delivery – S | +10 |
| Complete delivery – M | +18 |
| Complete delivery – L | +28 |
| Urgency multiplier (1.0–1.5×) | applied to both sides |
| 7-day streak bonus | +15 |
| Post request – S | -10 |
| Post request – M | -18 |
| Post request – L | -28 |
| Admin adjustment | variable |
| Refund (cancelled delivery) | full requester refund |

### Transfer rules
- Credits debited from requester at request creation time (held in escrow — delivery row tracks `credit_cost`)
- Credits released to runner only after `confirmed_at` is set
- `confirmed_at` set by: requester taps "Confirm delivery" OR auto-confirm Edge Function after 10 minutes of `delivered` status
- Transfer is one Edge Function call → single PostgreSQL transaction → atomic

### Minimum balance
- User cannot post request if `tomato_credits < credit_cost`
- Shown as disabled CTA with "Need X more tomatos" label

---

## 5. Broadcast Matching (Two-Sided Marketplace)

### How it works
1. Requester posts delivery → system broadcasts to **all relevant runners** (filtered: `runner_active = true`, not the requester, same campus)
2. Runners see the request appear live in their "Available requests" feed — they choose to **express interest** (tap "I'll take this")
3. Requester sees incoming runner interest cards in real-time on the matching screen — each card shows runner name, photo, reliability score, streak, and ETA
4. Requester **picks the runner** they want → delivery confirmed, other interested runners are auto-dismissed with a notification
5. Selected runner gets FCM push confirming they were chosen → delivery status → `accepted`

### Why this is better for a campus
- Runners have full agency — they browse available jobs, no surprise pings
- Requesters see who's coming and can trust the person (face-verified profile, real reliability score)
- No cascade timeouts — multiple runners can express interest simultaneously
- Feels like a marketplace, not a taxi dispatch

### Broadcast filter (relevant runners)
```
runner_active = true
AND id != requester_id
AND NOT blocked
AND tomato_credits >= 0  -- no minimum, runners earn credits
```
Sorted in requester's view by: reliability DESC, streak DESC

### Timeout rules
- If no runner expresses interest within **5 minutes** → requester notified, full refund, request cancelled
- Runner who expressed interest but wasn't picked → no penalty, just a "Not selected this time" notification
- Runner can express interest in multiple requests but can only be actively running one delivery at a time

### Reliability impact
- Successful delivery → `reliability = min(1.0, reliability + 0.002)`
- Dispute ruled against runner → `reliability -= 0.05`
- No penalty for not picking up requests (runners choose freely)

---

## 6. Real-time Delivery Tracking

### Status machine
```
pending → matching → accepted → picked_up → en_route → delivered → (confirmed)
```

### Implementation
- Supabase Realtime channel: `delivery:{delivery_id}`
- Runner sees action buttons per current status (Accept → Mark Picked Up → Mark En Route → Mark Delivered)
- Requester screen subscribes, AnimatedStepper updates live
- Campus map (`CustomPaint`) shows static route with animated progress dot
- No real GPS needed — campus is small, 4 zones (Main Gate, Academic Block, Hostel, Cafeteria)

---

## 7. UI Fixes & Polish

### Splash screen
- **Remove:** 90%-width breathing `RadialGradient` glow (white 18% alpha, scale 0.8→1.2) — this is the "AI-ish" effect
- **Fix centering:** Replace `SafeArea + Column(Spacer/Spacer)` with `Center` widget wrapping content column; university label pinned with `Align(Alignment.bottomCenter)` in `Stack`
- **Particles:** Reduce from 12 to 8, size 3–5px (was 4–8px), opacity 0.3 (was 0.4)
- **Result:** Clean gradient, centered logo, subtle warmth, premium feel

### Global glow audit
- **Remove:** Home screen AI insight card sparkle gradient border → plain `TomatoCard`
- **Remove:** Any `RadialGradient` with white alpha > 0.15 covering > 40% of screen
- **Keep:** Brand-red `BoxShadow` on wallet hero card (warm, intentional)
- **Keep:** Small positioned radial glows on wallet card (top-right, bottom-left, bounded)
- **Keep:** Pulsing runner dots on campus map (functional, not decorative)

### New screens needed (backend wiring)
- `RequestScreen` → validates credit balance, real form submission to DB
- `MatchingScreen` → real Supabase Realtime, live runner offer countdown
- `TrackingScreen` → real status from DB, runner action buttons
- `WalletScreen` → real `credit_transactions` from DB
- `ProfileScreen` → real `profiles` data, real reliability score
- `NotificationsScreen` → real `notifications` table with read state

### New providers needed
```dart
authStateProvider          // Supabase auth stream
currentUserProvider        // profiles row for current user
activeDeliveryProvider     // single active delivery stream
deliveryStatusProvider     // Realtime status for tracking screen
transactionsProvider       // paginated credit_transactions
notificationsProvider      // unread count + list
runnerOfferProvider        // incoming offer stream (for runner side)
```

---

## 8. Admin Dashboard

- **Access:** `role = 'admin'` in profiles, separate `/admin` route (not in tab bar)
- **KPIs:** Live counts from DB — active deliveries, avg handoff time, runners online, open disputes
- **Face verification queue:** List of `face_status = 'flagged'` profiles with photo, confidence score, approve/reject actions (calls Edge Function to update status + notify user)
- **Credit adjustments:** Admin form → inserts `admin_adjustment` credit_transaction
- **Dispute resolution:** Cancel delivery → trigger refund Edge Function → update runner reliability

---

## 9. New Dependencies

```yaml
supabase_flutter: ^2.5.0
firebase_messaging: ^15.1.0
google_mlkit_face_detection: ^0.11.0
image_picker: ^1.1.2
cached_network_image: ^3.3.1
```

---

## 10. Implementation Order

1. Supabase project setup + schema migration SQL
2. Edge Functions (validate-identity, transfer-credits, match-runner, auto-confirm)
3. New Riverpod providers (auth, user, delivery, realtime)
4. Auth screens wired to Supabase (login, OTP, profile setup with ML face check)
5. Request flow wired to DB
6. Matching screen with Realtime
7. Tracking screen with Realtime + runner action buttons
8. Wallet + Profile + Notifications wired to DB
9. UI fixes (splash, glow audit, polish)
10. Admin dashboard wired to DB
11. FCM push integration
12. End-to-end flow test
