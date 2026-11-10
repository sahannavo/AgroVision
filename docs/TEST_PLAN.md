# AgroVision Master Test Plan (SE205.3)

**Author:** KMCA Kumarasinghe (QA & Integration Lead)  
**Project:** AgroVision — Smart Agricultural Management & Disease Diagnosis for Nightshade Crops  
**Review Partner:** JKVC Kaveesha  
**Repository Branch:** `feature/test/integration` / `Charuka-(frontend)`

---

## 1. Scope & Objectives

The primary objective of this Test Plan is to validate functional correctness, on-device AI performance, offline resilience, and agricultural decision accuracy of the AgroVision application. Testing covers nightshade crops commonly grown in Sri Lanka (Tomato, Potato, Chilli, and Eggplant) under varied environmental and network conditions.

### In Scope
- **Authentication & Onboarding:** Email/Password registration, user profiles, farm registration (location, soil type, land size).
- **On-Device Plant Disease Diagnosis:** Offline TFLite inference, confidence scoring, visual symptoms match, DOA advice display.
- **Offline First & Synchronization:** Background diagnosis queueing, network state detection via `connectivityProvider`, and Firestore synchronisation upon reconnect.
- **Smart Irrigation & Crop Advisory:** Rainfall compensation, daily watering schedule, planting advice based on soil type and season (Yala/Maha).
- **History & Analytics:** 8-week diagnostic volume trends, disease proportion donut charts, and chronological farm decision logs.
- **Community Outbreak Alerts:** Geo-clustered disease detection (3+ cases in cluster radius) creating localized outbreak warnings and alerts.

### Out of Scope
- Phone SMS/OTP verification and physical SIM card binding.
- Hardware sensor Bluetooth/LoRa connectivity (simulated through cloud weather API and local data contracts).
- Multilingual Sinhala/Tamil localisation (deferred to subsequent releases as per project baseline).

---

## 2. Test Levels & Strategy

```
+-------------------------------------------------------+
|                 Manual Field & UAT                   |  -> Real Android devices, field lighting,
|                 (docs/QA_CHECKLIST.md)                |     airplane mode, accessibility (130% font)
+-------------------------------------------------------+
|               End-to-End Integration Tests            |  -> Flutter Driver / integration_test
|             (app/integration_test/*_test.dart)        |     Deterministic user journeys with fakes
+-------------------------------------------------------+
|                  Feature Widget Tests                 |  -> UI component verification, theme tokens,
|             (app/test/**/presentation/*_test.dart)    |     responsive layout (360-430 dp)
+-------------------------------------------------------+
|                    Unit Tests                         |  -> Repositories, math engines, week bucketing,
|          (app/test/**/data/*, domain/*_test.dart)     |     data serialization, and validators
+-------------------------------------------------------+
```

### Level Definitions
1. **Unit Tests:** Pure Dart tests validating business logic, date calculations, weekly bucketing across month boundaries, and repository mock contracts.
2. **Widget Tests:** Verification of UI components in isolation (`AppTheme.light`), semantic labels, overflow checks across screen widths (360 dp to 430 dp), and touch target minimums ($\ge 48\text{ dp}$).
3. **Integration Tests:** Automated flows executing against fake repositories simulating real user journeys from launch to screen navigation and data persistence.
4. **Manual UAT:** Physical hardware testing on low-to-mid range Android devices simulating real field conditions (low sunlight, offline airplane mode, camera permissions).

---

## 3. Test Devices & Target Environments

| Device Type | Model / Specs | OS Version | Display Density | Purpose |
| :--- | :--- | :--- | :--- | :--- |
| Low-End Physical | Samsung Galaxy A04 / 3GB RAM | Android 12 (Go Edition) | 720 x 1600 (360 dp) | Memory constraint & camera capture latency |
| Mid-Tier Physical | Xiaomi Redmi Note 11 / 6GB RAM | Android 13 | 1080 x 2400 (392 dp) | Standard farmer device benchmark |
| High-End Physical | Google Pixel 7a / 8GB RAM | Android 14 | 1080 x 2400 (412 dp) | Modern OS permissions & notification triggers |
| CI Virtual Device | Android Emulator x86_64 | Android 13 (API 33) | 1080 x 1920 (420 dp) | Headless GitHub Actions automated runner |

---

## 4. Entry, Suspension, and Exit Criteria

### Entry Criteria
- Clean build passing `flutter analyze` with 0 errors and 0 warnings.
- Base fake repositories and domain contracts merged into target branch.
- Design token constants (`AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadius`) adhering to specification.

### Suspension Criteria
- Critical application crash upon cold start or navigation to `/home`.
- Memory leaks causing OOM during camera stream or TFLite model inference.
- Firebase Auth / Firestore security rule rejections blocking basic read/write operations.

### Exit / Release Criteria
- **100% pass rate** on all unit and widget tests.
- **All integration test journeys** pass on CI without flake.
- Zero open critical (Blocker/High) severity defects.
- All primary interactive elements provide accessible semantics and meet the $\ge 48\text{ dp}$ touch target threshold.

---

## 5. Requirement Traceability Matrix & Test Scenarios

| Scenario ID | Functional Area | Test Scenario Description | Expected Outcome | Verification Level |
| :--- | :--- | :--- | :--- | :--- |
| **TC-AUTH-01** | Authentication | User registers with valid email, password, and farm metadata. | User record created, navigates to Farm Setup, then smoothly lands on `/home`. | Integration / Unit |
| **TC-AUTH-02** | Authentication | User submits invalid email format or short password (< 6 chars). | Validator prevents submission; displays descriptive inline error text. | Widget / Unit |
| **TC-DIAG-01** | Diagnosis | Farmer captures crop leaf image in Airplane Mode (Offline). | Local TFLite classifier outputs top disease match and advice; record marked as `Pending` sync. | Integration / Manual |
| **TC-DIAG-02** | Diagnosis | Device restores network connectivity after offline diagnosis. | `PendingUploadQueue` syncs diagnosis to Firestore; status changes to `Synced`. | Integration / Unit |
| **TC-DIAG-03** | Diagnosis | Leaf photo captured with healthy crop foliage. | Displays healthy banner, green indicator ring, and preventive maintenance tips. | Widget / Manual |
| **TC-ADVI-01** | Crop Advisor | Farmer inputs Reddish Brown Earth soil type for Yala season. | Crop suitability engine recommends Chilli and Tomato with high suitability score. | Unit / Integration |
| **TC-PLAN-01** | Smart Planner | Rain sensor / weather cache indicates heavy rainfall (> 20mm). | Smart irrigation engine adjusts daily plan to "Skip Watering" avoiding root rot. | Unit / Widget |
| **TC-HIST-01** | History & Analytics | History screen opened with 24 past scan records. | Diagnoses bar chart visualizes 8 weeks; donut chart displays disease distribution summing to 100%. | Widget / Integration |
| **TC-HIST-02** | History & Analytics | Farmer switches to Decisions tab in History. | Chronological timeline displays past spray, watering, and mulching actions with sync status. | Widget / Unit |
| **TC-ALRT-01** | Outbreak Alert | 3+ diagnoses of Late Blight registered within 5km radius within 48h. | Outbreak alert document generated in Firestore; banner appears on farmer's Home screen. | Integration / Unit |
| **TC-EDGE-01** | Edge / Hardware | Farmer denies Camera permission when tapping "Scan Leaf". | Friendly permission prompt appears explaining rationale with link to App Settings. | Manual / Widget |
| **TC-EDGE-02** | Edge / UI | System font scale set to 130% on low-resolution screen (360 dp). | Text scales legibly without layout overflows, text clipping, or broken cards. | Manual / Widget |

---

## 6. Defect Reporting and Escalation Procedure

When a defect is discovered during test execution:
1. File an issue in GitHub Issues using the project bug report template.
2. Include:
   - **Title:** `[Bug] [Feature Area] Concise description`
   - **Environment:** Device model, OS version, app version/commit SHA.
   - **Pre-conditions & Steps to Reproduce.**
   - **Expected vs Actual Behavior.**
   - **Attached Screenshot or Screen Recording.**
   - **Tagged File Owner:** (e.g., Tag KMCA for History/Offline, PDS for Cloud Functions).
3. Severity Classification:
   - **P0 (Blocker):** App crash, data corruption, TFLite inference failure.
   - **P1 (High):** Offline sync failure, incorrect irrigation math, broken navigation.
   - **P2 (Medium):** Layout overflow at 130% text scale, chart styling mismatch.
   - **P3 (Low):** Minor wording discrepancy, non-blocking visual glitch.
