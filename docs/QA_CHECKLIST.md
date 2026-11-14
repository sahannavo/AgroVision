# AgroVision Manual Hardware & Field QA Checklist

This checklist is used for manual Quality Assurance on physical Android devices under real agricultural conditions before signing off on release candidates.

**Tester:** _______________________  
**Device Model:** _______________________  
**Android OS Version:** _________________  
**App Build Version / Commit:** _________  
**Date of Execution:** __________________  

---

## 1. Network & Offline Resilience (Field Simulation)

| # | Test Item | Verification Steps | Expected Result | Status (Pass/Fail) | Notes |
| :-: | :--- | :--- | :--- | :-: | :--- |
| **1.1** | **Airplane Mode Diagnosis** | 1. Enable Airplane Mode.<br>2. Launch AgroVision.<br>3. Open Leaf Diagnosis and snap a photo.<br>4. Tap "Analyze Leaf". | Model diagnoses on-device without internet. Result screen displays diagnosis, confidence score, and offline indicator. | [ ] | |
| **1.2** | **Offline Queueing & Sync** | 1. Diagnose a leaf while offline.<br>2. Save the diagnosis.<br>3. Check History screen.<br>4. Reconnect to Wi-Fi/4G. | History displays the record with a `Pending` sync chip. Upon reconnection, chip automatically updates to `Synced`. | [ ] | |
| **1.3** | **Offline Pill & Banner** | 1. Toggle mobile data / Wi-Fi off.<br>2. Navigate to Home or History. | `OfflinePill` appears in top app bar. `OfflineBanner.auto` expands smoothly showing cached data notice. | [ ] | |
| **1.4** | **Degraded 2G/3G Network** | 1. Throttle connection to 150 kbps (or use Developer Options network throttle).<br>2. Fetch weather forecast or history. | Shimmer loading states display properly. No ANR or crash; handles slow responses gracefully. | [ ] | |

---

## 2. Camera, Image Capture & Lighting Conditions

| # | Test Item | Verification Steps | Expected Result | Status (Pass/Fail) | Notes |
| :-: | :--- | :--- | :--- | :-: | :--- |
| **2.1** | **Camera Permission Denied** | 1. Clear app permissions.<br>2. Tap "Diagnose Crop".<br>3. Deny camera permission. | Explanatory banner appears explaining why camera access is required with a direct button to "Open App Settings". | [ ] | |
| **2.2** | **Bright Direct Sunlight** | 1. Take a leaf photo outdoors under direct afternoon sunlight.<br>2. Run analysis. | Camera preview maintains contrast. Model detects leaf features accurately without glare crash. | [ ] | |
| **2.3** | **Low-Light / Overcast Foliage** | 1. Capture infected leaf under dusk or deep shade.<br>2. Inspect capture screen. | Camera auto-exposure adjusts or flash option is available. Flash toggles cleanly without freezing preview. | [ ] | |
| **2.4** | **Blurry / Out-of-Focus Image** | 1. Shake phone slightly during leaf capture.<br>2. Run analysis. | App displays capture guidance tips ("Hold phone steady 15-20cm from affected leaf") if confidence score is low. | [ ] | |

---

## 3. Location & GPS Edge Cases

| # | Test Item | Verification Steps | Expected Result | Status (Pass/Fail) | Notes |
| :-: | :--- | :--- | :--- | :-: | :--- |
| **3.1** | **Location Permission Denied** | 1. Deny fine location permission during Farm Setup or Diagnosis.<br>2. Proceed with flow. | App gracefully falls back to default Sri Lankan agricultural district coordinates (e.g. Kurunegala / Matale). | [ ] | |
| **3.2** | **GPS Disabled (Location Off)** | 1. Turn off device Location toggle in Quick Settings.<br>2. Save new diagnosis. | App catches disabled provider, prompts user to enable GPS, or tags diagnosis with last known coordinates. | [ ] | |

---

## 4. Accessibility & Visual Standards (Farmers' Ergonomics)

| # | Test Item | Verification Steps | Expected Result | Status (Pass/Fail) | Notes |
| :-: | :--- | :--- | :--- | :-: | :--- |
| **4.1** | **130% System Font Scaling** | 1. Go to Android Settings > Display > Font Size.<br>2. Set to Maximum (130%+).<br>3. Open every screen in AgroVision. | **Zero layout overflow errors** (no yellow/black striped boxes). Text wraps cleanly; cards expand dynamically. | [ ] | |
| **4.2** | **Touch Target Sizing** | 1. Inspect all primary action buttons, tabs, chips, and icons with a layout bounds inspector. | All interactive touch targets measure **at least 48 x 48 dp** for easy tapping in field conditions. | [ ] | |
| **4.3** | **Screen Reader (TalkBack)** | 1. Enable Android TalkBack.<br>2. Navigate Home, Diagnosis Result, History, and Charts. | All icons have descriptive semantic labels (e.g. "Offline status: Offline", "Back to Home"). Charts announce summaries. | [ ] | |
| **4.4** | **Outdoor Color Contrast** | 1. View application in outdoor sunlight. | All body text meets WCAG AA contrast ratio ($\ge 4.5:1$) against `AppColors.background` and `AppColors.surface`. | [ ] | |

---

## 5. Agronomy & Business Logic Validation

| # | Test Item | Verification Steps | Expected Result | Status (Pass/Fail) | Notes |
| :-: | :--- | :--- | :--- | :-: | :--- |
| **5.1** | **Rainfall Irrigation Override** | 1. View Smart Planner during a rainy forecast day (> 20mm). | Daily irrigation schedule updates to "Skip Irrigation / Conserve Water". | [ ] | |
| **5.2** | **Disease DOA Recommendations** | 1. Diagnose Early Blight on Tomato.<br>2. View Result Action Plan. | Displays official Sri Lankan DOA recommended chemical (e.g. Copper Hydroxide 0.2%) and cultural practices. | [ ] | |
| **5.3** | **History 8-Week Trend** | 1. Open History tab.<br>2. Inspect weekly bar chart. | 8 weekly bars display chronologically. Current week bar is prominently highlighted with `AppColors.primaryGreen`. | [ ] | |
| **5.4** | **Disease Breakdown Donut** | 1. Inspect Donut Chart in History. | Sum of breakdown counts and percentages equals 100% of recorded scans. | [ ] | |
| **5.5** | **Decision Log Recording** | 1. Record an action (e.g., fungicide application).<br>2. Check Decision Log timeline. | Action appears in chronological timeline with categorical icon, date, result badge, and sync status. | [ ] | |

---

## 6. Sign-off & Release Recommendation

- [ ] **PASS:** Application satisfies all field resilience, offline sync, and accessibility criteria without critical defects.
- [ ] **FAIL:** Application exhibits blockers/regressions requiring remediation before production release.

**QA Sign-off Signature:** ___________________________ **Date:** _______________
