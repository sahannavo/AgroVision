# AgroVision — Firebase Setup Guide

> **Who this is for**: the team lead (PDS) and any member who needs to run the
> Firebase Emulator Suite locally. All development and testing is done against
> the emulators; never against production.

---

## 1. Prerequisites

| Tool | Version | Install |
|------|---------|---------|
| Node.js | ≥ 20 LTS | `brew install node` |
| Firebase CLI | latest | `npm install -g firebase-tools` |
| FlutterFire CLI | latest | `dart pub global activate flutterfire_cli` |
| Flutter | 3.x stable | flutter.dev |

---

## 2. Create the Firebase Projects

Two projects are needed: one for development (everyone uses this) and one for
production (only PDS deploys to it).

### 2a. Create agrovision-dev (development)

1. Open [console.firebase.google.com](https://console.firebase.google.com).
2. Click **"Add project"**.
3. Enter project name: `AgroVision Dev`.  
   Firebase auto-suggests the project ID; change it to **`agrovision-dev`** in
   the field below the name.
4. Click **Continue**. Keep **Google Analytics** off for the dev project (saves quota). Click **Create project**.
5. Wait for provisioning, then click **Continue**.

### 2b. Create agrovision-prod (production)

Repeat the same steps. Use:
- Name: `AgroVision Prod`
- Project ID: **`agrovision-prod`**
- Enable Google Analytics (useful for production crash reporting).

---

## 3. Add Team Members as Editors

For **agrovision-dev** (all eight members need access):

1. In the Firebase console, select **agrovision-dev**.
2. Click the ⚙️ **Settings** gear → **Project settings** → **Members and roles** tab.
3. Click **"Add member"**.
4. Enter each team member's Google/Gmail address and set role to **Editor**.
5. Click **Add**.

Repeat for **agrovision-prod** (PDS only, role: **Editor**).

---

## 4. Choose a Firestore Region

> Choose **once**; it cannot be changed later.

Recommended region for Sri Lanka: **`asia-south1` (Mumbai)** — lowest latency
from Sri Lanka, supports all required Firebase services.

Do this **before** creating any Firestore database.

---

## 5. Enable Email/Password Sign-In

1. In **agrovision-dev** console, go to **Build → Authentication**.
2. Click **"Get started"**.
3. Under **Sign-in providers**, click **Email/Password**.
4. Toggle **Enable** to ON. Leave "Email link (passwordless sign-in)" OFF.
5. Click **Save**.

Repeat for **agrovision-prod**.

---

## 6. Create Firestore Database

1. Go to **Build → Firestore Database**.
2. Click **"Create database"**.
3. Choose **Production mode** (we use Security Rules from the repo).
4. Click **Next**, select location **`asia-south1`**, click **Enable**.

Repeat for **agrovision-prod**.

---

## 7. Create Cloud Storage

1. Go to **Build → Storage**.
2. Click **"Get started"**.
3. Choose **Production mode**, click **Next**.
4. Select **`asia-south1`**, click **Done**.

Repeat for **agrovision-prod**.

---

## 8. Run FlutterFire Configure

This generates `lib/firebase_options.dart`. Run once per platform, from inside
the `app/` directory.

```bash
cd app

# For agrovision-dev (Android + iOS)
flutterfire configure \
  --project=agrovision-dev \
  --platforms=android,ios \
  --out=lib/firebase_options.dart
```

When prompted:
- **Android package name**: `lk.nsbm.agrovision`  
  *(check `app/android/app/build.gradle` for the actual `applicationId`)*
- **iOS bundle ID**: `lk.nsbm.agrovision`  
  *(check `app/ios/Runner.xcodeproj/project.pbxproj` for the actual bundle ID)*

> **Important**: `firebase_options.dart` **may** be committed (it contains no
> secrets — only public identifiers). `google-services.json` and
> `GoogleService-Info.plist` are **regenerated** by FlutterFire and should
> **not** be committed (add to `.gitignore`).

---

## 9. Install Firebase Emulator Suite

```bash
# From the repo root
firebase login          # sign in with your Google account
firebase use agrovision-dev

# Install emulators (Auth, Firestore, Storage, Functions)
firebase setup:emulators:firestore
firebase setup:emulators:auth
firebase setup:emulators:storage
firebase setup:emulators:functions
```

---

## 10. Start the Emulators

```bash
# From the repo root (where firebase.json lives)
firebase emulators:start
```

This starts the following emulators (ports match `firebase.json`):

| Emulator | Default port | UI |
|----------|-------------|-----|
| Auth | 9099 | `localhost:4000` |
| Firestore | 8080 | `localhost:4000` |
| Storage | 9199 | `localhost:4000` |
| Functions | 5001 | `localhost:4000` |
| Emulator UI | 4000 | open in browser |

To run the Flutter app against emulators:

```bash
# Android emulator
flutter run --dart-define=USE_EMULATORS=true

# iOS simulator
flutter run -d iPhone --dart-define=USE_EMULATORS=true

# Keep fakes (no Firebase at all)
flutter run --dart-define=USE_FAKES=true
```

To run the real Firebase implementation without emulators:

```bash
flutter run --dart-define=USE_FAKES=false
```

---

## 11. Functions Setup

```bash
cd functions
npm install
```

Create `functions/.env` from the template (never commit this file):

```bash
cp functions/.env.example functions/.env
# Then edit functions/.env:
# OPENWEATHER_API_KEY=<your key>
# OUTBREAK_RADIUS_KM=5
# OUTBREAK_MIN_REPORTS=3
# OUTBREAK_WINDOW_HOURS=24
```

Deploy functions (PDS only, to agrovision-dev first):

```bash
firebase deploy --only functions --project agrovision-dev
```

---

## 12. Cost Note — Blaze Plan

Scheduled Cloud Functions (`refreshWeatherCache`) and outbound HTTP calls
to the OpenWeatherMap API require the **Blaze (pay-as-you-go)** plan.

**Before upgrading, set a budget alert:**

1. In Google Cloud Console → **Billing** → **Budgets & alerts**.
2. Create a budget for the agrovision-dev project: amount **\$5 USD**.
3. Set alert at 50 %, 90 % and 100 % thresholds. This triggers an email before
   any significant charge.

**If Blaze is not possible** (e.g., team cannot provide a credit card):

- Remove `refreshWeatherCache` and `getWeatherForecast` from deployment.
- Add a temporary `WeatherService` class **inside the app** that calls the
  OpenWeatherMap REST API directly using a key stored in a
  `--dart-define=OWM_KEY=...` flag at build time.
- **Never** hard-code the key in source code or commit it.
- Document this deviation in the sprint report and revisit when Blaze becomes
  available.

---

## 13. Security Rules

Firestore and Storage rules live in `firestore.rules` and `storage.rules` in
the repo root. They are deployed with:

```bash
firebase deploy --only firestore:rules,storage:rules
```

The emulators load these rules automatically on `firebase emulators:start`.

---

## 14. .gitignore Additions

Ensure these are in `.gitignore` (repo root and `app/` as appropriate):

```
# Firebase secrets — never commit
google-services.json
GoogleService-Info.plist
functions/.env
.firebaserc          # optional: keep if the team shares the same project IDs
serviceAccountKey.json
*.jks
```

> `firebase_options.dart` is safe to commit — it contains only public app IDs.

---

*Last updated: Nov 2026 — SE205.3 AgroVision Team*
