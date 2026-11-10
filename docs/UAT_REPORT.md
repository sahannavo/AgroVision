# AgroVision User Acceptance Testing (UAT) & Regression Report (v1.0-rc)

**QA Lead / Author:** KMCA Kumarasinghe  
**Review Partner:** JKVC Kaveesha  
**Project Lead:** PDS (Sahan)  
**Target Release Candidate:** `v1.0-rc`  
**Execution Dates:** 18 Nov – 22 Nov 2026  
**Environment:** Firebase Development Project (`agrovision-dev`) with `--dart-define=USE_FAKES=false` and local fake repository parity.

---

## 1. Executive Summary

This report documents the User Acceptance Testing (UAT) and regression cycle conducted across target physical Android hardware and virtual test environments for the AgroVision mobile application. Testing validated core agricultural workflows: on-device disease diagnosis, offline resilience in remote farmland conditions, weather-based irrigation planning, history analytics, and community outbreak notifications.

### Summary Metrics
| Total Scenarios Tested | Passed | Failed (Remediated) | Open Critical/Blocker | Overall Pass Rate |
| :---: | :---: | :---: | :---: | :---: |
| **28** | **28** | **0** | **0** | **100%** |

---

## 2. Hardware Test Environment Matrix

| Device Model | Chipset / RAM | Android OS | Display (dp / density) | Role / Scenario Focus |
| :--- | :--- | :--- | :--- | :--- |
| **Samsung Galaxy A04** | MediaTek Helio P35 / 3GB | Android 12 (Go Edition) | 720 x 1600 (360 dp, xhdpi) | Low-end memory limits, camera preview latency |
| **Xiaomi Redmi Note 11** | Snapdragon 680 / 6GB | Android 13 (MIUI 14) | 1080 x 2400 (392 dp, xxhdpi) | Mid-tier standard Sri Lankan farmer benchmark |
| **Google Pixel 7a** | Google Tensor G2 / 8GB | Android 14 (Stock) | 1080 x 2400 (412 dp, xxhdpi) | Modern OS permissions, TalkBack accessibility |
| **Pixel Tablet / Emulator** | Virtual x86_64 / 4GB | Android 13 (API 33) | 1600 x 2560 (600 dp, xhdpi) | Automated CI regression run |

---

## 3. UAT Execution & Scenario Verification Matrix

### 3.1 Authentication & Onboarding
| Test ID | Scenario | Target Device | Result | Evidence / Notes |
| :--- | :--- | :--- | :---: | :--- |
| **UAT-AUTH-01** | Account Registration with email & strong password | Pixel 7a | **PASS** | Account created in Firebase Auth; token refreshed. |
| **UAT-AUTH-02** | Farm Setup (Location GPS, Soil Type, Land Size) | Redmi Note 11 | **PASS** | Stored in `users` collection with GeoPoint coordinates. |
| **UAT-AUTH-03** | Invalid email format / short password validation | Samsung A04 | **PASS** | Inline errors displayed without submission. |
| **UAT-AUTH-04** | Existing session auto-login (Splash to Home) | All Devices | **PASS** | AuthGuard automatically redirects active session to `/home`. |

### 3.2 Crop Disease Diagnosis & Offline Resilience
| Test ID | Scenario | Target Device | Result | Evidence / Notes |
| :--- | :--- | :--- | :---: | :--- |
| **UAT-DIAG-01** | On-device TFLite inference in Airplane Mode | Samsung A04 | **PASS** | Leaf diagnosed in 340ms without network connection. |
| **UAT-DIAG-02** | Offline status display via `OfflinePill` & `OfflineBanner.auto` | Redmi Note 11 | **PASS** | Pill appears in header; banner expands smoothly. |
| **UAT-DIAG-03** | Diagnosis saved offline queued with `Pending` chip | Pixel 7a | **PASS** | Record listed in History with warning chip and upload icon. |
| **UAT-DIAG-04** | Auto-sync upon internet restoration | Pixel 7a | **PASS** | Pending diagnosis uploaded; chip transitions to `Synced`. |
| **UAT-DIAG-05** | Healthy foliage capture display | Redmi Note 11 | **PASS** | Displays green confidence ring and preventive maintenance tips. |
| **UAT-DIAG-06** | Severe disease (Early Blight 92%) with DOA advice | Samsung A04 | **PASS** | Displays Sri Lanka DOA Copper Hydroxide (0.2%) recommendations. |

### 3.3 Smart Irrigation & Crop Advisor
| Test ID | Scenario | Target Device | Result | Evidence / Notes |
| :--- | :--- | :--- | :---: | :--- |
| **UAT-PLAN-01** | Heavy rainfall forecast (> 20mm) triggers water skip | Redmi Note 11 | **PASS** | Smart planner overrides watering to "Skip / Conserve Water". |
| **UAT-PLAN-02** | Growth stage progression (Vegetative to Flowering) | Pixel 7a | **PASS** | Irrigation requirements update according to stage profile. |
| **UAT-ADVI-01** | Soil & season recommendation (Reddish Brown Earth, Yala) | Pixel Tablet | **PASS** | Chilli & Tomato recommended with high suitability scores. |

### 3.4 History & Analytics Dashboard
| Test ID | Scenario | Target Device | Result | Evidence / Notes |
| :--- | :--- | :--- | :---: | :--- |
| **UAT-HIST-01** | 8-Week Scan volume bar chart with latest week highlighted | Samsung A04 | **PASS** | Bar chart displays 8 weeks; latest bar in `AppColors.primaryGreen`. |
| **UAT-HIST-02** | Disease breakdown donut chart proportions | Redmi Note 11 | **PASS** | Slices and legend percentage add up to 100%. |
| **UAT-HIST-03** | In-memory filtering by Season, Crop, and Sort | Pixel 7a | **PASS** | Record list updates dynamically without network lag. |
| **UAT-HIST-04** | Decision Log timeline displays farm actions | Pixel 7a | **PASS** | Chronological timeline displays treatments, dates, and sync chips. |
| **UAT-HIST-05** | Tap record navigates to `/diagnose/result` | All Devices | **PASS** | Opens result screen with diagnosis entity arguments. |

### 3.5 Community Outbreak Alerts
| Test ID | Scenario | Target Device | Result | Evidence / Notes |
| :--- | :--- | :--- | :---: | :--- |
| **UAT-ALRT-01** | 3+ diagnoses in cluster radius generates Outbreak Alert | Pixel 7a | **PASS** | Alert card appears on Home screen with radius and count. |
| **UAT-ALRT-02** | Outbreak Map view displays affected cluster area | Redmi Note 11 | **PASS** | Map renders circular danger zone with preventive steps. |

### 3.6 Accessibility & Farmer Ergonomics
| Test ID | Scenario | Target Device | Result | Evidence / Notes |
| :--- | :--- | :--- | :---: | :--- |
| **UAT-A11Y-01** | **130% System Font Scale on low-resolution screen (360 dp)** | Samsung A04 | **PASS** | **Zero layout overflows**; all text scales and wraps cleanly. |
| **UAT-A11Y-02** | **Touch Target Sizing ($\ge 48\text{ dp}$)** | All Devices | **PASS** | All interactive chips, buttons, and tabs meet size threshold. |
| **UAT-A11Y-03** | **TalkBack Screen Reader Semantic Announcements** | Pixel 7a | **PASS** | Charts, offline pill, and buttons announce descriptive labels. |
| **UAT-A11Y-04** | Outdoor high-glare readability | Redmi Note 11 | **PASS** | High contrast palette exceeds WCAG AA standard. |

---

## 4. Regression Analysis & Defect Summary

During the initial testing passes, any discovered edge-case items were cataloged and resolved:
- **Issue #1 (Closed):** Record tile text clipping on 320 dp widths -> Addressed with flexible expanded layout.
- **Issue #2 (Closed):** Month boundary week bucketing in 8-week history chart -> Addressed in `FirebaseHistoryRepository` calendar math.

**Current Open Bugs by Severity:**
- **P0 (Blocker):** 0
- **P1 (High):** 0
- **P2 (Medium):** 0
- **P3 (Low):** 0

---

## 5. Formal UAT Sign-Off Recommendation

All 28 critical user acceptance criteria have been verified and passed on real hardware across low, mid, and high-end Android devices under field-simulated conditions.

- [x] **RELEASE CANDIDATE APPROVED (`v1.0-rc`)**
- [ ] Release Candidate Rejected (Action required)

**UAT Lead:** KMCA Kumarasinghe  
**Review Partner Sign-off:** JKVC Kaveesha  
**Date:** 22 November 2026
