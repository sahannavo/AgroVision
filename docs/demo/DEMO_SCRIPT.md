# AgroVision — Demo Script (5–7 Minutes)

**Module:** SE205.3  
**Target Duration:** 6 minutes 15 seconds (strictly within the 5–7 minute limit)  
**Target Build:** Release APK (`--dart-define=USE_FAKES=false --dart-define=USE_EMULATORS=false`) connected to `agrovision-dev`  
**Recording Rule:** Record on a real physical Android phone **after** the Mon 23 Nov code freeze. Keep the exported video file (`.mp4`) **outside Git** (link/upload it in the submission folder per `docs/SUBMISSION_CHECKLIST.md`).

---

## 1. Speakers & Roles

| Role | Member | Responsibility During Demo |
|------|--------|----------------------------|
| **Driver / Phone Operator** | JKVC Kaveesha (or PDS Sandawaruni) | Operates the physical test phone smoothly, toggles Airplane Mode, taps through every screen in order |
| **Narrator 1 (App & Offline Flow)** | JKVC Kaveesha | Introduces the problem, walks through Registration, Offline Scan, Result, Save, and History |
| **Narrator 2 (Agronomy, Backend & Alerts)** | RMOP Purwa / AHMS Maneesha | Explains Weather Cache, Rain-aware Planner, Planting Advisor, Cloud Functions outbreak trigger, and FCM privacy |

*(If recording as a single-narrator video, one speaker reads both Narrator 1 and Narrator 2 lines while a second team member handles the second phone for the outbreak trigger.)*

---

## 2. Pre-Demo Setup Checklist (10 Minutes Before Recording)

- [ ] **Two physical Android phones** running the signed release APK (`USE_FAKES=false`):
  - **Phone A (Main Demo Phone):** Freshly installed / signed out, sitting on `/login` or `/register`, screen recording enabled (1080p, notifications visible, font scale normal, Do Not Disturb **OFF** so the FCM notification banner appears).
  - **Phone B (Helper Phone):** Signed in as a second test farmer within 5 km of Kurunegala (`7.4863, 80.3623`), ready to submit a 3rd `Early Blight` scan if needed to fire `onDiagnosisCreated` -> `onOutbreakAlertCreated` -> FCM.
- [ ] **Pre-seeded `agrovision-dev` state:**
  - Two recent `earlyBlight` diagnoses (confidence $\ge 0.70$, within the cluster radius and time window) already exist near Kurunegala so that **Phone A's saved scan** (or Phone B's scan) is the **3rd report** (`OUTBREAK_MIN_REPORTS=3`) that triggers a fresh `outbreakAlerts` document and FCM push.
  - Weather cache populated in `weatherCache` for Kurunegala, including a forecasted rain day (`rainChance >= 60%` or `> 15 mm`) so the Planner clearly shows `Watering Skipped`.
  - Pre-seeded `cropProfiles` (`Tomato · Plot A-4`) and `decisionLogs` on the demo account or ready on Phone B for instant Planner / History showcase.
- [ ] **Leaf samples ready:** One real or printed/display tomato leaf showing Early Blight spots (`ml/testdata/leaf_sample_01.png` loaded in Gallery as backup if lighting is poor).
- [ ] **Backup Phone C:** Pre-built `USE_FAKES=true` APK installed and charged in case of complete mobile data / Wi-Fi outage.

---

## 3. Timing & Feature Order Overview

| Time | Segment | Feature Covered | Route / Screen |
|------|---------|-----------------|----------------|
| `0:00 – 0:45` | **1. Intro & Register** | Account & farm registration (GPS, soil, area, crops) | `/register` -> `/register/farm` -> `/home` |
| `0:45 – 1:45` | **2. Scan Offline** | Airplane Mode ON, camera capture, on-device TFLite inference | `/diagnose/capture` |
| `1:45 – 2:30` | **3. Result & Advice** | Disease class, confidence ring, DOA action steps, offline banner | `/diagnose/result` |
| `2:30 – 3:05` | **4. Save & Auto-Sync** | `Save to history` offline queue -> Airplane Mode OFF -> sync | `/diagnose/result` |
| `3:05 – 3:55` | **5. History & Decisions** | `Diagnoses` tab (bar chart, donut chart, filters, `Synced` chip) & `Decisions` tab | `/history` |
| `3:55 – 4:45` | **6. Planner with Rain** | Growth stage stepper, 7-day weather strip, rain-triggered `Watering Skipped` | `/planner` |
| `4:45 – 5:25` | **7. Planting Advisor** | Soil/season/location input, cached weather badge, ranked crop matches | `/advisor` |
| `5:25 – 6:15` | **8. Outbreak Alert & FCM** | Push notification arrives -> `Disease Alerts` List & Map zone view, privacy note | Notification -> `/alerts` |

---

## 4. Step-by-Step Script

### Segment 1: Introduction & Registration (`0:00 – 0:45`)
**Speaker:** Narrator 1

1. **Action:** Start on the **Create Account** screen (`/register`).
2. **Say:** *"Hi, we're presenting AgroVision, an offline-first mobile app built for Sri Lankan nightshade farmers growing tomato, potato, chilli, and eggplant. Let's register a new farmer account."*
3. **Action:**
   - Enter Full Name (`Kasun Bandara`), Email, Password, and Confirm Password (point out the password strength meter).
   - Tick the Terms & Conditions checkbox and tap **Continue**.
   - On **Step 2 of 2 · Farm Details** (`/register/farm`):
     - Tap **Use Current Location** (shows GPS coordinates / Kurunegala district).
     - Select Soil Type: **Loam**.
     - Keep **2.5 Acres** as Total Cultivated Area.
     - Select **Tomato** and **Chilli** in the crop grid.
     - Tap **Finish Setup**.
4. **Expected Result:** Firebase Auth creates the user, Firestore writes `users/{uid}` (with `fcmToken`), and the app lands on **Home** (`/home`) showing the weather card, crop cards, and Quick Actions.

---

### Segment 2: Scan Offline (`0:45 – 1:45`)
**Speaker:** Narrator 1

1. **Action:** Pull down Android Quick Settings and turn **Airplane Mode ON**. Show the `Offline` notice pill/banner appear on the Home screen.
2. **Say:** *"Farmers in rural fields often have zero signal. We've turned on Airplane Mode to prove disease diagnosis works 100% offline on the phone."*
3. **Action:**
   - Tap the raised green camera button (**Scan crop disease**) in the bottom navigation bar to open `/diagnose/capture`.
   - Tap the **Tomato** crop chip at the bottom.
   - Frame the Early Blight tomato leaf inside the guide overlay and tap the **Shutter** button (or tap the **Gallery** icon on the left to pick `leaf_sample_01.png` if indoors).
4. **Expected Result:** The `AnalysingSheet` spinner runs on-device TensorFlow Lite inference (`TfliteDiagnosisClassifier`) in under 1 second with no network call and automatically navigates to `/diagnose/result`.

---

### Segment 3: Result (`1:45 – 2:30`)
**Speaker:** Narrator 1

1. **Action:** Pause on the **Diagnosis Result** screen (`/diagnose/result`). Slowly scroll down to show each card.
2. **Say:** *"The on-device TFLite model classified this as Early Blight with high confidence. Notice the top banner confirms it was processed offline on this phone."*
3. **Point out on screen:**
   - Top status banner: **Saved on this phone, will sync when online** (`Offline` badge).
   - Header card: leaf thumbnail, disease name (`Early Blight`), scientific name (`Alternaria solani`), and `ConfidenceRing` percentage.
   - **Recommended Action Steps** & **Prevention Tips** sourced from Sri Lankan Department of Agriculture (DOA) guidelines (e.g., pruning lower leaves, copper hydroxide / mancozeb spray).
   - Top candidate probabilities (`CandidateMatchTile`).

---

### Segment 4: Save & Sync (`2:30 – 3:05`)
**Speaker:** Narrator 1

1. **Action:** While still in Airplane Mode, tap **Save to history** at the bottom of the Result screen.
2. **Say:** *"We tap Save to history while still offline. Firestore offline persistence saves the record immediately, and our PendingUploadQueue queues the leaf photo for upload once signal returns."*
3. **Expected Result:** Button updates to **Saved to history** and snackbar confirms `Saved to history`.
4. **Action:** Pull down Quick Settings and turn **Airplane Mode OFF** (reconnect Wi-Fi/4G). Wait ~3–5 seconds for background sync.

---

### Segment 5: History & Decisions (`3:05 – 3:55`)
**Speaker:** Narrator 1

1. **Action:** Tap **History** in the bottom navigation bar (`/history`).
2. **Say:** *"In History & Analytics, we see the Diagnoses tab with our newly synced scan alongside an 8-week scan bar chart and a disease breakdown donut chart."*
3. **Action:**
   - Point out the `Synced` chip on the newly saved diagnosis record (transitioned from `Pending` after reconnect).
   - Tap the **Crop** or **Season** filter in `HistoryFilterBar` to show instant filtering.
   - Scroll briefly to show the 8-week `DiagnosesBarChart` and `DiseaseDonutChart`.
   - Tap the **Decisions** tab at the top.
4. **Say:** *"The Decisions tab displays a chronological timeline of farm actions — sprays, watering adjustments, and mulching logged in the `decisionLogs` collection."*
5. **Action:** Tap any diagnosis record briefly or move directly to Planner.

---

### Segment 6: Planner with Rain (`3:55 – 4:45`)
**Speaker:** Narrator 2

1. **Action:** Tap **Planner** in the bottom navigation bar (`/planner`).
2. **Say:** *"Next is the Smart Crop Planner. It combines the farmer's crop growth stage with weather forecasts cached via our Cloud Functions."*
3. **Action:**
   - Point out the plot selector (`Tomato · Plot A-4`) and the `GrowthStageStepper` (`Flowering`, day 48).
   - Point to the 7-day `WeatherStrip` and tap the **rainy day** (e.g., `Wed · 85%` rain icon).
   - Scroll to **This week's plan** and highlight the **Watering Skipped** day card (`Rain expected. Skip watering.` — `0 L/m²`) and the **Top-dress** fertilizer card (`NPK 12-12-17`).
4. **Say:** *"Because heavy rain is forecast on Wednesday, the IrrigationEngine automatically skips watering to prevent waterlogging and saves the farmer water and effort — and it still works using the last cached weather when offline."*

---

### Segment 7: Advisor (`4:45 – 5:25`)
**Speaker:** Narrator 2

1. **Action:** Tap **Home** in the bottom nav, then tap **Advisor** in the Quick Actions grid (`/advisor`).
2. **Say:** *"Before planting a new bed, farmers open the Planting Advisor."*
3. **Action:**
   - Tap **Detect** next to `Field location` (sets `Kurunegala, NW`).
   - Select **Loam** under `Soil type`.
   - Select **Yala (May - Aug)** (or **Maha (Oct - Feb)**) under `Cultivation season`.
   - Point out the cached weather status chip (`Using weather saved ...`).
   - Tap **Get recommendations**.
4. **Expected Result:** Ranked `CropMatchCard` list appears (e.g., Chilli, Tomato, Eggplant) with match score percentages, reason chips, and estimated days to harvest.

---

### Segment 8: Outbreak Alert & Notification (`5:25 – 6:15`)
**Speaker:** Narrator 2

1. **Trigger:** Our saved diagnosis in Segment 4 (or Phone B submitting the 3rd `Early Blight` scan in Kurunegala) triggers the `onDiagnosisCreated` Cloud Function (`reportCount >= OUTBREAK_MIN_REPORTS`), which writes an `outbreakAlerts` document and triggers `onOutbreakAlertCreated` to send an FCM push notification.
2. **Action:**
   - Show the **Android push notification** banner arrive at the top of Phone A: `Disease Alert: Early Blight nearby`.
   - Tap the notification (or tap **Alerts** in the bottom nav to open `/alerts`).
3. **Say:** *"When three or more nearby farms report the same disease, our Cloud Function creates an outbreak zone and pushes an FCM alert to farmers inside the radius. Notice the privacy guarantee at the bottom: alerts never reveal any farmer's name or exact GPS coordinates — coordinates are rounded to ~1 km."*
4. **Action:**
   - On **Disease Alerts** (`/alerts`), expand the top `AlertCard` to show the **Preventive Steps**.
   - Tap the **Map** segment in the **List / Map** toggle to open `OutbreakMapView`.
   - Tap the circular outbreak zone on the map to show `ZoneBottomSheet` with cluster count, radius, and preventive advice.
5. **Closing Line (Narrator 1):** *"That's AgroVision: offline-first diagnosis, weather-smart planning, and privacy-preserving community alerts. Thank you."*

---

## 5. Backup Plan If the Network Fails

| Failure Scenario | Immediate Action During Demo | Recovery / Explanation |
|------------------|------------------------------|------------------------|
| **1. Mobile data / Wi-Fi drops completely** | Switch seamlessly to **Phone C** (pre-loaded `USE_FAKES=true` build) OR continue on **Phone A** for all offline-capable screens (Scan, Result, Save, Planner cached weather, Advisor, Alerts cached view). | Explain: *"Because AgroVision is offline-first, diagnosis, saved history, cached weather planning, and advisor rules continue working without internet; only live cloud sync and new FCM pushes wait for connectivity."* |
| **2. `getWeatherForecast` or OpenWeatherMap API times out** | Open **Planner** and **Advisor** normally — both read from the local Firestore `weatherCache` snapshot and display the `Using weather saved ... · Offline` banner. | Point directly to the cached weather banner as proof of the offline-first architecture (`D6` in the report). |
| **3. FCM push notification is delayed (> 10 s)** | Do **not** wait silently on camera. Open **Alerts** tab (`/alerts`) directly (or pull to refresh) to show the `outbreakAlerts` document in both **List** and **Map** views, and show the pre-captured notification screenshot / Phone B receipt if needed. | Mention: *"Cloud Function `onOutbreakAlertCreated` writes the `notifications` record and dispatches FCM asynchronously; the alert zone is already live in Firestore."* |
| **4. Camera fails to focus indoors** | Tap the **Gallery** icon on `CaptureScreen` and select `ml/testdata/leaf_sample_01.png` (pre-copied to Phone A's gallery). | Run full TFLite inference on the leaf sample image to prove identical on-device classification. |
| **5. Login / Registration fails on live network** | Switch to an already-signed-in account on **Phone B** (or Phone C with `USE_FAKES=true`) for Segments 2–8 so the demo never stalls. | Keep registration under 45 seconds by pre-typing or using Android autofill. |
