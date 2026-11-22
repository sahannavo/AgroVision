# AgroVision — Deployment and Release Guide

> **Target Audience**: Team Lead (PDS) and DevOps / Backend team members.  
> **Release Target**: SE205.3 University Project — Nightshade Crop Disease & Farm Management System.  
> **Environments**: Development (`agrovision-dev`), Production (`agrovision-prod`).

---

## Table of Contents

1. [Deployment Overview & Schedule](#1-deployment-overview--schedule)
2. [Prerequisites & Environment Configuration](#2-prerequisites--environment-configuration)
3. [Secrets Management (OpenWeatherMap API Key)](#3-secrets-management-openweathermap-api-key)
4. [Step-by-Step Backend Deployment (`agrovision-dev`)](#4-step-by-step-backend-deployment-agrovision-dev)
5. [Console Verification & Health Checks](#5-console-verification--health-checks)
6. [Building the Release APK](#6-building-the-release-apk)
7. [Real Device Installation & On-Device Testing](#7-real-device-installation--on-device-testing)
8. [Troubleshooting & Common Deployment Issues](#8-troubleshooting--common-deployment-issues)
9. [Production Deployment (`agrovision-prod`)](#9-production-deployment-agrovision-prod)
10. [Git Tagging & Release Management](#10-git-tagging--release-management)

---

## 1. Deployment Overview & Schedule

| Milestone | Date | Responsible | Deliverable / Action |
|-----------|------|-------------|----------------------|
| **Feature Freeze** | Thu 19 Nov | Team Lead (PDS) | Code cutoff for all Phase 3 tasks. Tag `v0.2-backend` on `dev`. |
| **Dev Deployment** | Thu 19 Nov | PDS & DevOps | Deploy Firestore rules, Storage rules, and Functions to `agrovision-dev`. |
| **Release Build** | Fri 20 Nov | PDS | Build release APK (`USE_FAKES=false`). Deploy & verify on 2 real test devices. |
| **Integration Tag** | Fri 20 Nov | PDS | Tag `v0.3-integration` on `dev` after physical device sign-off. |
| **Team Review & Sign-Off** | Sun 22 Nov | All 8 Members | Review dev stability, review error logs, vote on production deploy. |
| **Code Freeze & Prod Deploy** | Mon 23 Nov | PDS | Final code freeze. Deploy verified build to `agrovision-prod`. |

---

## 2. Prerequisites & Environment Configuration

### Required Tooling

- **Flutter SDK**: 3.x stable (Dart 3)
- **Node.js**: v20 LTS (`node -v` $\ge$ 20.0.0)
- **Firebase CLI**: latest (`npm install -g firebase-tools`)
- **Android SDK**: Build tools 34+, Android platform SDK 34
- **Java Development Kit (JDK)**: OpenJDK 17

### Firebase CLI Authentication

Verify you are signed in with your university/authorized developer Google account:

```bash
firebase login
firebase projects:list
```

Confirm that both `agrovision-dev` and `agrovision-prod` appear in your project list.

### Workspace Verification

Ensure `.firebaserc` maps the project aliases:

```json
{
  "projects": {
    "default": "agrovision-dev",
    "production": "agrovision-prod"
  }
}
```

Switch active context to development:

```bash
firebase use default
# Output confirms: Now using project agrovision-dev
```

---

## 3. Secrets Management (OpenWeatherMap API Key)

> **CRITICAL SECURITY RULE**: Never commit API keys, service account credentials, or `.env` files into source control. The OpenWeatherMap key is accessed solely by server-side Cloud Functions or injected securely into Secret Manager.

### Option A: Firebase Cloud Functions Secrets (Recommended)

Google Cloud Secret Manager securely stores the OpenWeatherMap key for Cloud Functions:

```bash
firebase functions:secrets:set OPENWEATHER_API_KEY --project agrovision-dev
```

When prompted, paste your active OpenWeatherMap API key.

### Option B: Functions Runtime Environment (`functions/.env`)

If using environment files on the deployment machine (never committed to git):

1. Navigate to `functions/`:
   ```bash
   cd functions
   cp .env.example .env
   ```
2. Populate `functions/.env`:
   ```env
   OPENWEATHER_API_KEY=your_actual_openweathermap_api_key_here
   OUTBREAK_RADIUS_KM=5
   OUTBREAK_MIN_REPORTS=3
   OUTBREAK_WINDOW_HOURS=24
   ```
3. Verify that `.gitignore` contains `functions/.env` and `*.local`.

---

## 4. Step-by-Step Backend Deployment (`agrovision-dev`)

Execute all commands from the repository root:

### Step 4.1: Deploy Security Rules & Storage

Deploy Firestore security rules and Cloud Storage rules first to ensure permissions are strictly enforced before functions go live:

```bash
firebase deploy --only firestore:rules,storage --project agrovision-dev
```

### Step 4.2: Build & Lint Cloud Functions

Before deploying, verify TypeScript compilation and formatting:

```bash
cd functions
npm run build
cd ..
```

### Step 4.3: Deploy Cloud Functions

Deploy all backend Cloud Functions (`getWeatherForecast`, `refreshWeatherCache`, `onDiagnosisCreated`, `onOutbreakAlertCreated`):

```bash
firebase deploy --only functions --project agrovision-dev
```

*Note: Scheduled functions like `refreshWeatherCache` require the Firebase project to be on the Blaze (pay-as-you-go) plan.*

### Step 4.4: Deploy Composite Indexes

Deploy required query indexes for `cropProfiles` and `diagnoses`:

```bash
firebase deploy --only firestore:indexes --project agrovision-dev
```

### Step 4.5: Full Deployment One-Liner

To deploy all backend services in a single verified command:

```bash
firebase deploy --only firestore:rules,storage,functions,firestore:indexes --project agrovision-dev
```

---

## 5. Console Verification & Health Checks

Once deployment concludes, log into the [Firebase Console](https://console.firebase.google.com/project/agrovision-dev/overview) to conduct sanity checks:

### 1. Cloud Functions Health Check
- Navigate to **Build → Functions**.
- Verify the following 4 functions are active with green checkmarks:
  - `getWeatherForecast` (HTTPS Callable)
  - `refreshWeatherCache` (Pub/Sub Scheduled - hourly)
  - `onDiagnosisCreated` (Firestore Trigger on `diagnoses/{id}`)
  - `onOutbreakAlertCreated` (Firestore Trigger on `outbreakAlerts/{id}`)
- Click **Logs** to inspect runtime initialization.

### 2. Firestore Security Rules Check
- Navigate to **Build → Firestore Database → Rules**.
- Confirm rules match `firestore.rules` in the repository.
- Verify read/write restrictions:
  - `users`: Users can only read and write their own documents (`request.auth.uid == uid`).
  - `cropProfiles`: Only authenticated owners can read and mutate plots; `area > 0` validation enforced.
  - `outbreakAlerts`: Publicly readable by authenticated users; writes restricted to Cloud Functions admin trigger.

### 3. Cloud Storage Verification
- Navigate to **Build → Storage → Rules**.
- Confirm rules match `storage.rules`: diagnosis leaf images uploadable under `diagnoses/{userId}/{fileName}` only by authenticated users.

---

## 6. Building the Release APK

The release APK connects directly to live Firebase services (`USE_FAKES=false`) and points to production Cloud endpoints (`USE_EMULATORS=false`).

### Step 6.1: Clean & Fetch Dependencies

From inside the `app/` directory:

```bash
cd app
flutter clean
flutter pub get
```

### Step 6.2: Static Analysis Audit

Confirm zero lint or static analysis issues exist:

```bash
flutter analyze --no-fatal-infos
```

### Step 6.3: Compile the Release APK

Run the Flutter build command with the production environment definition flags:

```bash
flutter build apk --release \
  --dart-define=USE_FAKES=false \
  --dart-define=USE_EMULATORS=false
```

*For split-per-ABI APKs (reducing download size on older devices):*

```bash
flutter build apk --release --split-per-abi \
  --dart-define=USE_FAKES=false \
  --dart-define=USE_EMULATORS=false
```

### Output Artifact

The resulting signed APK will be located at:
```
app/build/app/outputs/flutter-apk/app-release.apk
```

---

## 7. Real Device Installation & On-Device Testing

Install and test the release build on **two real physical Android smartphones** representing different Android versions and screen densities.

### Step 7.1: Connect Devices & Enable USB Debugging

1. On the test phone, open **Settings → About Phone**.
2. Tap **Build Number** 7 times to enable Developer Options.
3. Open **Developer Options** and enable **USB Debugging**.
4. Connect the phone via USB and authorize the computer.

Check connected devices:

```bash
adb devices
```

### Step 7.2: Install APK via ADB

Install on Device 1:

```bash
adb -s <DEVICE_ID_1> install -r app/build/app/outputs/flutter-apk/app-release.apk
```

Install on Device 2:

```bash
adb -s <DEVICE_ID_2> install -r app/build/app/outputs/flutter-apk/app-release.apk
```

### Step 7.3: Physical Smoke Testing Protocol

Execute the following verification test script on both devices:

| Test Case | Steps | Expected Result | Pass/Fail |
|-----------|-------|-----------------|-----------|
| **1. Splash & Auth Redirect** | Launch app fresh. | Animated splash runs for 2.2s. Redirects to `/login` when unauthenticated. | [ ] |
| **2. Farmer Registration** | Register a new farmer account with name, email, password, region, soil type, and land size. | Auth account created, `users/{uid}` document created in Firestore, redirected to `/home`. | [ ] |
| **3. Crop Plot Addition** | Add a new crop plot (Tomato, 1.5 acres). | Plot appears immediately in the UI. Stored in `cropProfiles` collection. | [ ] |
| **4. Offline Plot Persistence** | Enable Airplane mode. Add a Chilli plot (0.5 acres). Disable Airplane mode. | Plot appears immediately in UI via Firestore offline cache. Syncs to cloud when connectivity returns. | [ ] |
| **5. Leaf Disease Diagnosis** | Capture leaf photo or select from gallery. Run model inference. | On-device TFLite model classifies image in < 1.5s. Confidence and disease card displayed. | [ ] |
| **6. Cloud Sync & History** | Save diagnosis result to cloud. | Image uploads to Cloud Storage (`diagnoses/...`). Firestore document saved. History tab updates. | [ ] |
| **7. Weather Data Fetch** | Open Weather / Planner tab. | Weather forecast loads from OpenWeatherMap cache via Cloud Function. | [ ] |
| **8. Farmer Sign Out** | Open Profile tab. Tap "Log Out". | Session clears. Redirected back to `/login`. Local private data protected. | [ ] |

---

## 8. Troubleshooting & Common Deployment Issues

### 1. `Error: Cloud function failed to deploy / insufficient permissions`
- **Cause**: Firebase CLI user lacks Cloud Functions Admin or Service Account User role.
- **Remedy**: In Google Cloud Console → IAM & Admin, grant the deployment user `Cloud Functions Admin` and `Service Account User` roles.

### 2. `Scheduled function fails: refreshWeatherCache requires Blaze plan`
- **Cause**: Google Cloud Scheduler requires a billing account attached.
- **Remedy**: Upgrade `agrovision-dev` to Blaze plan with a strict \$5 budget alert. If Blaze is unavailable, deploy only rules and storage, and rely on client-side cached weather fallbacks.

### 3. `App crashes on startup with PlatformException(missing_options)`
- **Cause**: `firebase_options.dart` was not properly loaded or generated for the target platform.
- **Remedy**: Re-run `flutterfire configure --project=agrovision-dev` from the `app/` directory and rebuild.

### 4. `Firestore query exception: The query requires an index`
- **Cause**: Queries with compound filters or ordering (e.g. `userId == ... ORDER BY plantedDate DESC`) need an explicit composite index.
- **Remedy**: Click the direct URL link in the logcat output or add the index specification to `firestore.indexes.json` and run `firebase deploy --only firestore:indexes`.

---

## 9. Production Deployment (`agrovision-prod`)

> **RESTRICTION**: Deployment to `agrovision-prod` is performed **strictly by the Team Lead (PDS)** after formal sign-off on Sun 22 Nov.

### Deployment Steps:

1. Switch to production project:
   ```bash
   firebase use production
   ```
2. Verify target project:
   ```bash
   firebase projects:list
   # Active project should be marked (current: agrovision-prod)
   ```
3. Set production OpenWeatherMap key:
   ```bash
   firebase functions:secrets:set OPENWEATHER_API_KEY --project agrovision-prod
   ```
4. Deploy rules, storage, functions, and indexes:
   ```bash
   firebase deploy --only firestore:rules,storage,functions,firestore:indexes --project agrovision-prod
   ```
5. Build production production APK:
   ```bash
   cd app
   flutter build apk --release \
     --dart-define=USE_FAKES=false \
     --dart-define=USE_EMULATORS=false
   ```

---

## 10. Git Tagging & Release Management

Following university project repository guidelines, tags must be created on `dev` to mark project milestones.

### Tag 1: Feature Freeze (`v0.2-backend`)
Create on `dev` once all backend implementations are merged on Thu 19 Nov:

```bash
git checkout dev
git pull origin dev
git tag -a v0.2-backend -m "AgroVision Backend Feature Freeze: Firebase Auth, Firestore repos, Cloud Functions, and Emulator tests"
git push origin v0.2-backend
```

### Tag 2: Integration Release (`v0.3-integration`)
Create on `dev` after the release APK has been built and verified on two physical phones on Fri 20 Nov:

```bash
git checkout dev
git pull origin dev
git tag -a v0.3-integration -m "AgroVision Release Build v0.3: Verified on real devices with real Firebase backend integration"
git push origin v0.3-integration
```

---

*Last revised: November 2026 — SE205.3 AgroVision Engineering Team*
