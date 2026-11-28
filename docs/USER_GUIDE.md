# AgroVision — Farmer User Guide

Welcome to **AgroVision**, a mobile assistant built for nightshade crop farmers in Sri Lanka (**Tomato**, **Potato**, **Chilli**, and **Eggplant**). You can scan sick leaves in the field **even without mobile internet**, track your farm history, get rain-smart watering plans, and receive early warnings when diseases appear nearby.

> **Note on Screenshots:** Drop the final phone screenshots from the `v1.0` release device build into `docs/demo/screenshots/` using the filenames listed below so every image renders in Markdown viewers and the final PDF export.

---

## 1. Create Your Account & Set Up Your Farm

1. Open **AgroVision** and tap **Register** (or **Create Account**).
2. On **Step 1 of 2: Account Info**, enter your **Full Name**, **Email**, and a strong **Password**, tick the terms checkbox, and tap **Continue**.
3. On **Step 2 of 2: Farm Details**:
   - Tap **Use Current Location** (or pick your **District** from the dropdown).
   - Tap your farm's **Soil Type** (`Clay`, `Loam`, `Sandy`, or `Silt`).
   - Enter your **Total Cultivated Area** (`Acres` or `Hectares`).
   - Tap the nightshade crops you grow (**Tomato**, **Potato**, **Chilli**, **Eggplant**).
   - Tap **Finish Setup**.

![Create Account and Farm Setup](demo/screenshots/01_register_farm.png)
*Screenshot placeholder: `docs/demo/screenshots/01_register_farm.png` — Step 2 Farm Details screen.*

> **Need internet?** Registration and signing in require an active internet connection. Once you are signed in, you can scan leaves offline anytime.

---

## 2. Your Home Dashboard

After signing in, you land on the **Home** screen:
- **Weather Card:** Shows today's temperature, humidity, and rain chance for your district (or the last saved forecast if you are offline).
- **Outbreak Banner:** Warns you if nearby farmers have reported a crop disease. Tap **View Steps** to see how to protect your plants.
- **My Crops:** Swipe through your active crop plots, or tap **Manage** to add or edit plots.
- **Quick Actions:** Jump straight to **Scan**, **Advisor**, **Planner**, or **History**.

![Home Dashboard](demo/screenshots/02_home_dashboard.png)
*Screenshot placeholder: `docs/demo/screenshots/02_home_dashboard.png` — Home screen with weather, crops, and quick actions.*

---

## 3. Scan a Leaf & Check the Result (Works Offline)

You can scan a leaf **in the field with no signal or in Airplane Mode**:

1. Tap the green **Camera button** in the middle of the bottom bar.
2. Select the crop you are checking (**Tomato**, **Potato**, **Chilli**, or **Eggplant**).
3. Hold your phone steady **15–20 cm** above a single diseased leaf in good daylight so it fits inside the frame, then tap the **Shutter button** (or tap the **Gallery icon** on the left to pick an existing leaf photo).
4. Wait 1–2 seconds while AgroVision analyses the leaf directly on your phone.

![Leaf Capture Screen](demo/screenshots/03_capture_offline.png)
*Screenshot placeholder: `docs/demo/screenshots/03_capture_offline.png` — Camera preview with crop chips.*

### Reading the Diagnosis Result

On **Diagnosis Result**, you will see:
- **Sync Banner:** Shows `Diagnosis synchronized to cloud` when online, or `Saved on this phone, will sync when online` when offline.
- **Detected Condition & Confidence Ring:** For example, *Early Blight* with confidence percentage.
  - *If confidence is below 70%*, you will see a **Low Confidence Detection** warning asking you to tap **Retake photo** in brighter daylight.
- **Recommended Action Steps & Prevention Tips:** Practical steps from Sri Lankan Department of Agriculture (DOA) guidelines (pruning, recommended sprays, spacing, and irrigation tips).
- Tap **Save to history** to store the scan. If you are offline, it is saved on your phone and uploaded automatically as soon as your signal returns.

![Diagnosis Result Screen](demo/screenshots/04_diagnosis_result.png)
*Screenshot placeholder: `docs/demo/screenshots/04_diagnosis_result.png` — Diagnosis Result with confidence ring and DOA action steps.*

---

## 4. Check Your History & Farm Decisions

Tap **History** in the bottom bar to view **History & Analytics**:
- Use the filter bar at the top to filter by **Season** (`All`, `Yala`, `Maha`), **Crop**, or **Sort** (`Newest`, `Confidence`, `Severity`).
- **Diagnoses Tab:**
  - Summary cards showing total scans, healthy percentage, and top issue.
  - **8-Week Scan Chart** and **Disease Breakdown Donut** to spot trends on your farm.
  - List of past scans — each record shows a **`Synced`** or **`Pending`** chip. Tap any record to reopen its full advice.
- **Decisions Tab:**
  - Chronological timeline of farm actions you recorded (such as fungicide sprays, watering skips, or mulching).

![History and Analytics](demo/screenshots/05_history_analytics.png)
*Screenshot placeholder: `docs/demo/screenshots/05_history_analytics.png` — History Diagnoses tab with charts and sync chips.*

---

## 5. Watering & Fertilizer Planner

Tap **Planner** in the bottom bar to open **Crop Planner**:
- Choose your crop plot from the top-right dropdown (e.g., `Tomato · Plot A-4`).
- Check the **Growth Stage** bar (`Seedling`, `Vegetative`, `Flowering`, `Fruiting`).
- Review the **7-Day Weather Strip** and daily cards under **This week's plan**:
  - On normal days, AgroVision tells you how much water to apply (`L/m²`) and the best time of day (morning or evening).
  - **Rain-Smart Skip:** When heavy rain is forecast, the day card turns into **Watering Skipped — Rain expected. Skip watering** (`0 L/m²`) to save water and protect roots.
  - **Fertilizer Reminders:** Look for the **Top-dress** tag showing the recommended fertilizer and dosage for your crop's stage.
- *Offline use:* If you have no signal, Planner displays `Using weather saved ... · Offline` and keeps working with your last forecast.

![Crop Planner with Rain Skip](demo/screenshots/06_planner_rain.png)
*Screenshot placeholder: `docs/demo/screenshots/06_planner_rain.png` — Crop Planner showing rainy day Watering Skipped card.*

---

## 6. Planting Advisor

Open **Advisor** from the **Quick Actions** grid on the Home screen before planting a new bed:
1. Tap **Detect** next to **Field location** to fill in your district.
2. Pick your **Soil type** (`Clay`, `Loam`, `Sandy`, or `Silt`).
3. Switch between **Maha (Oct - Feb)** and **Yala (May - Aug)**.
4. Tap **Get recommendations**.

AgroVision ranks the best nightshade crops for your conditions with a **match score %**, **harvest days**, **reason tags**, and any **caution notes** (for example, heavy monsoon disease risk).

![Planting Advisor Results](demo/screenshots/07_planting_advisor.png)
*Screenshot placeholder: `docs/demo/screenshots/07_planting_advisor.png` — Ranked nightshade crop matches.*

---

## 7. Nearby Disease Alerts & Map

Tap **Alerts** in the bottom bar (or tap an incoming notification) to open **Disease Alerts**:
- **List View:** Shows active outbreak clusters near your farm ranked by proximity and severity, with expandable **Preventive Steps**.
- **Map View:** Switch the **List / Map** toggle at the top right to see outbreak circles around your plot. Tap any shaded zone circle to open the bottom sheet with report count, radius, and immediate preventive actions.
- **Your Privacy Is Protected:** Alerts only show the disease name, approximate area (~1 km rounded centre), and report count. **Your name, farm details, and exact GPS location are never shared with other farmers.**

![Disease Alerts List and Map](demo/screenshots/08_alerts_map.png)
*Screenshot placeholder: `docs/demo/screenshots/08_alerts_map.png` — Outbreak Alerts Map view with zone bottom sheet.*

---

## 8. Manage Your Profile & Crop Plots

Tap the **Profile icon** in the top-right corner of **Home** (`/profile`) to:
- View your farm summary (District, Province, Soil Type, Land Size).
- Tap **Add Crop Plot** to add a new Tomato, Potato, Chilli, or Eggplant plot (name, planted date, growth stage, soil type, and area), or tap an existing plot to edit/update its stage.
- Toggle outbreak **Notifications** on or off, or tap **Log out** when switching accounts.

![Profile and Crop Plots](demo/screenshots/09_profile_plots.png)
*Screenshot placeholder: `docs/demo/screenshots/09_profile_plots.png` — Profile screen and Add Crop Plot sheet.*

---

## 9. Quick Troubleshooting

| Problem | What to Do |
|---------|------------|
| **"Low Confidence Detection" warning on a scan** | Move into brighter natural daylight, hold the phone 15–20 cm away, keep **one** leaf centered, and tap **Retake photo**. |
| **Scan shows `Pending` instead of `Synced`** | Your scan is safely stored on your phone. Turn on Wi-Fi or mobile data and open the app briefly — it will sync automatically. |
| **Cannot log in while offline** | Signing in and creating an account require internet access. Once signed in, keep your session active before heading to fields without signal. |
| **Outbreak Map shows a blank background offline** | Map tiles need internet, but outbreak zone circles and preventive steps still display on the pale offline canvas. |
| **Camera does not open** | Tap **Open App Settings** on the permission screen and allow **Camera** access for AgroVision. |
