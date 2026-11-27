# AgroVision - Individual contributions

Each member completes their own section **in their own words** (first person). Do not edit anyone else's section.

## How to fill this in
1. Run `bash docs/report/tools/list_contributions.sh` from the repository root (after `git fetch --all`). It prints, per author,
   the merged branches and every commit. Use it for the tables below.
2. Pull request numbers and reviewers come from GitHub (Pull requests, filter `is:pr author:<you>`).
3. Keep the branch names exactly as in Git. The lecturer checks this file against the repository history.
4. Write challenges and lessons yourself. Aim for 400-600 words per member for the report, and short notes here are fine to start.

Review partners: PDS with SDL, UGDS with MASN, RMOP with AHMS, KMCA with JKVC.

---

## PDS Sandawaruni (team lead)
**GitHub:** @subodha  **Email:** pdssandawaruni@students.nsbm.ac.lk  **Review partner:** SDL

| Task | Branch | PR # | Date | Summary |
|------|--------|------|------|---------|
| Data contracts and fake repos | subodha | #8, #73 | Oct 27-29, Nov 16 | Auth, weather, diagnosis, crop plots, planner, advisor, history, alerts domain and fakes |
| Auth screens UI | feature/ui/auth | #45 | Nov 05 | Login, Register account, Register farm screens with go_router |
| Firebase Auth and Firestore | feature/data/firebase-auth | #65 | Nov 15 | FirebaseAuthRepository, FirebaseCropPlotRepository, emulator tests |
| Firebase project and bootstrap | sahan(Leader) | #80, #81 | Nov 19-20 | firebase_bootstrap, firebase.json, .firebaserc, security rules, Firebase setup guide |

**Commits (54 on dev):** `[Data] Add auth domain and fake repository`, `[Data] Add FirebaseAuthRepository with Firestore profile write`, `[Test] Add Firebase Auth+Firestore emulator integration tests`, `[Core] Wire firebaseBootstrap into main (guarded by kUseFakes)`, `[Test] Add widget tests for auth screens (14 cases)`.

**Files, folders and tests I wrote:**
- `lib/features/*/domain/` (all 9 domain interfaces and entities)
- `lib/features/*/data/fake_*_repository.dart` (all 9 fakes)
- `lib/features/*/data/providers.dart` (all provider wiring)
- `lib/features/auth/presentation/**` (login, register screens and widgets)
- `lib/features/auth/data/firebase_auth_repository.dart`, `lib/features/crop_plots/data/firebase_crop_plot_repository.dart`
- `lib/core/firebase/firebase_bootstrap.dart`, `lib/core/constants/firestore_paths.dart`
- Tests: fake repo tests, Firebase Auth emulator tests, auth screen widget tests

**Challenges and how I solved them:**

**Lessons learned:**

**What I reviewed for my partner and what changed:**

---

## SDL Weerasinghe
**GitHub:** @sobani  **Email:** sobani.darshi@gmail.com  **Review partner:** PDS

| Task | Branch | PR # | Date | Summary |
|------|--------|------|------|---------|
| Frontend theme and app setup | sobani(frontend) | #2, #3 | Oct 27 | App theme, go_router, bottom nav shell |
| Home dashboard | feature/ui/home | #53 | Nov 09-10 | Home screen with weather card, quick actions, crop progress, outbreak banner |
| Integration UI fixes | sobani | #86, #88 | Nov 16-22 | Remove duplicate widgets, fix integration, update pubspec |
| ML classifier wiring | sobani | #88 | Nov 21-22 | TFLite classifier, disease catalog lookup, USE_FAKES switch, parity tests |

**Commits (23 on dev):** `feat(router): implement GoRouter, StatefulShellRoute and AppBottomNav shell`, `[UI] Build home dashboard`, `[ML] Add TFLite classifier and preprocessing`, `[ML] Wire classifier provider to USE_FAKES`, `[Test] Add classifier parity and error tests`.

**Files, folders and tests I wrote:**
- `lib/core/router/**` (app_router, auth_guard, route_names)
- `lib/core/widgets/app_bottom_nav.dart`, `main_shell.dart`
- `lib/features/home/presentation/**` (home_screen, all home widgets)
- `lib/features/diagnosis/data/tflite_classifier.dart`, `diagnosis/domain/disease_class.dart`
- Tests: router widget tests, home screen test, classifier parity tests

**Challenges and how I solved them:**

**Lessons learned:**

**What I reviewed for my partner and what changed:**

---

## UGDS Munasinghe
**GitHub:** @ugdsmunasinghe  **Email:** ugdsmunasinghe@students.nsbm.ac.lk  **Review partner:** MASN

| Task | Branch | PR # | Date | Summary |
|------|--------|------|------|---------|
| Core UI widgets | frontend | #21, #25 | Oct 28-29 | PrimaryButton, SecondaryButton, SectionHeader, EmptyState |
| Capture screen | frontend | #25-27 | Oct 29 | CaptureScreen state machine, AnalysingSheet, scanning animation, capture controls |
| CaptureScreen tests | frontend | Various | Oct 29 | Widget tests for capture screen and theme token consolidation |

**Commits (14 on dev):** `[UI] Add PrimaryButton widget`, `[UI] Add SecondaryButton widget`, `[UI] Implement CaptureScreen state machine`, `[UI] Add CaptureScreen tests and complete theme token consolidation for Task 2`.

**Files, folders and tests I wrote:**
- `lib/core/widgets/primary_button.dart`, `secondary_button.dart`, `section_header.dart`, `empty_state.dart`
- `lib/features/diagnosis/presentation/capture_screen.dart`
- `lib/features/diagnosis/presentation/widgets/analysing_sheet.dart`, `capture_controls.dart`, `leaf_frame_overlay.dart`, `capture_tips_card.dart`
- Tests: primary_button_test, secondary_button_test, section_header_test, empty_state_test, capture_screen_test

**Challenges and how I solved them:**

**Lessons learned:**

**What I reviewed for my partner and what changed:**

---

## MASN Weerasinghe
**GitHub:** @sahannavo  **Email:** masnweerasingha@students.nsbm.ac.lk  **Review partner:** UGDS

| Task | Branch | PR # | Date | Summary |
|------|--------|------|------|---------|
| Project initialisation | sahan(Leader-frontend) | #6 | Oct 27 | Flutter project structure, core features, theme, UI components |
| Diagnosis result screen | frontend | Various | Oct 27 | ResultScreen, ConfidenceRing, StatusChip, disease catalog |
| ML model and training pipeline | sahan(Leader) | #80 | Nov 19 | model.tflite, labels_schema, training pipeline, dataset manifest, evaluation metrics |
| Project documentation | sahan(Leader-frontend) | Various | Oct-Nov | Sprint plans, screen mockups, ML documentation |

**Commits (55 on dev):** `feat: initialize AgroVision application with core features, UI components, and theme`, `feat(diagnosis): implement ResultScreen and presentation widgets`, `[ML] Integrate baseline model.tflite, schema, and training pipeline`, `[ML] Complete model card, evaluation metrics, and error analysis reports`.

**Files, folders and tests I wrote:**
- `lib/core/theme/**` (app_colors, app_text_styles, app_spacing, app_radius, app_theme)
- `lib/core/widgets/confidence_ring.dart`, `status_chip.dart`
- `lib/features/diagnosis/presentation/result_screen.dart` and result widgets
- `ml/**` (training pipeline, evaluation, model card)
- `app/assets/data/disease_catalog.json`
- Tests: confidence_ring_test, status_chip_test, result_screen_test

**Challenges and how I solved them:**

**Lessons learned:**

**What I reviewed for my partner and what changed:**

---

## RMOP Purwa
**GitHub:** @oshadhi  **Email:** rmopurwa@students.nsbm.ac.lk  **Review partner:** AHMS

| Task | Branch | PR # | Date | Summary |
|------|--------|------|------|---------|
| Advisor screen and widgets | oshadhi(frontend) | #38, #39, #42 | Nov 02-03 | AdvisorScreen, CropMatchCard, AdvisorInputCard, AdvisorEmptyState |
| Core shared widgets | oshadhi(frontend) | #24 | Oct 29 | AppTextField, CropChipSelector |
| Cloud Functions and weather | oshadhi | #76, #78 | Nov 18 | getWeatherForecast, refreshWeatherCache, onDiagnosisCreated, FirebaseWeatherRepository |
| Firebase diagnosis repository | oshadhi | #93, #95 | Nov 22-23 | FirebaseDiagnosisRepository, PendingUploadQueue |

**Commits (36 on dev):** `[Core] Setup Cloud Functions and weather services`, `[Repo] Implement FirebaseWeatherRepository`, `[Core] Implement outbreak detection trigger`, `[UI] Implement AdvisorScreen and states`, `[Repo] Implement FirebaseDiagnosisRepository and queue`.

**Files, folders and tests I wrote:**
- `lib/features/advisor/presentation/**` (advisor_screen, crop_match_card, advisor_input_card, soil_season_form, advisor_empty_state)
- `lib/core/widgets/app_text_field.dart`, `crop_chip_selector.dart`
- `functions/src/getWeatherForecast.ts`, `refreshWeatherCache.ts`, `onDiagnosisCreated.ts`
- `lib/features/weather/data/firebase_weather_repository.dart`
- `lib/features/diagnosis/data/firebase_diagnosis_repository.dart`, `pending_upload_queue.dart`
- Tests: advisor_screen_test, app_text_field_test, crop_chip_selector_test, firebase_weather_repository_test

**Challenges and how I solved them:**

**Lessons learned:**

**What I reviewed for my partner and what changed:**

---

## AHMS Maneesha
**GitHub:** @Sasindi0515  **Email:** ahmsmaneesha@students.nsbm.ac.lk  **Review partner:** RMOP

| Task | Branch | PR # | Date | Summary |
|------|--------|------|------|---------|
| Planner UI | sasindi-(frontend) | #12, #30, #50, #51 | Oct 28-Nov 06 | PlannerScreen, day plan cards, growth stage stepper, weather strip, empty state |
| Planner engine and backend | Savindi | #75 | Nov 18 | IrrigationEngine, fertilizer schedule, LocalPlannerRepository |
| Firestore and Storage security rules | sasindi-(frontend) | Various | Nov 06 | Firestore rules, Storage rules, ownership tests |
| Alerts backend and FCM | Savindi / BackEnd | #75-77 | Nov 07-18 | onOutbreakAlertCreated, FirebaseAlertsRepository, NotificationService |
| Data and agronomy tables | sasindi-(frontend) | Various | Nov 06 | crop_requirements.json, irrigation_requirements.json |

**Commits (26 on dev):** `[Planner] Implement full PlannerScreen with empty and active states`, `[Planner Engine] Implement pure weather-driven irrigation calculation engine`, `[Security] Implement Firestore security rules with ownership and data validation`, `[Functions] Implement onOutbreakAlertCreated trigger with geofencing and FCM`, `[Data] Add crop and irrigation requirement tables with agronomy sources`.

**Files, folders and tests I wrote:**
- `lib/features/planner/presentation/**` (planner_screen, day_plan_card, growth_stage_stepper, weather_strip, planner_summary_tiles, planner_empty_state)
- `lib/features/planner/domain/irrigation_engine.dart`, `fertilizer_plan.dart`, `irrigation_day_plan.dart`
- `lib/features/planner/data/local_planner_repository.dart`
- `functions/src/onOutbreakAlertCreated.ts`
- `lib/features/alerts/data/firebase_alerts_repository.dart`
- `lib/core/services/notification_service.dart`
- `firestore.rules`, `storage.rules`
- `app/assets/data/crop_requirements.json`, `irrigation_requirements.json`
- Tests: planner_screen_test, irrigation_engine_test, local_planner_repository_test, firestore.test.ts, storage.test.ts, outbreak_notification_test, firebase_alerts_repository_test

**Challenges and how I solved them:**

**Lessons learned:**

**What I reviewed for my partner and what changed:**

---

## KMCA Kumarasinghe
**GitHub:** @amandikumarasinghe  **Email:** kmcakumarasinghe@students.nsbm.ac.lk  **Review partner:** JKVC

| Task | Branch | PR # | Date | Summary |
|------|--------|------|------|---------|
| History screen UI | Charuka-(frontend) | #22, #47, #49 | Oct 29-Nov 05 | HistoryScreen, decision timeline, disease donut chart, diagnoses bar chart, record tile |
| History backend | Charuka | #85 | Nov 20 | FirebaseHistoryRepository, history stats calculation, providers with USE_FAKES |
| QA and testing docs | Charuka | Various | Nov 02-05 | Test plan, QA checklist, UAT report, e2e integration test flows, issues registry |

**Commits (28 on dev):** `[UI] History and Analytics Screen (Task 2)`, `[Data] Implement FirebaseHistoryRepository and stats calculation`, `[Docs] Create comprehensive test plan and scenario matrix`, `[Test] Add automated end-to-end integration test flows`, `[Docs] Create comprehensive UAT and regression test report`.

**Files, folders and tests I wrote:**
- `lib/features/history/presentation/**` (history_screen, decision_timeline, disease_donut, diagnoses_bar_chart, record_tile, filter_bar, summary_tiles)
- `lib/features/history/data/firebase_history_repository.dart`
- `docs/TEST_PLAN.md`, `docs/QA_CHECKLIST.md`, `docs/UAT_REPORT.md`, `docs/ISSUES.md`
- Tests: history_screen_test, fake_history_repository_test, firebase_history_repository_test, diagnosis_to_history_flow_test

**Challenges and how I solved them:**

**Lessons learned:**

**What I reviewed for my partner and what changed:**

---

## JKVC Kaveesha
**GitHub:** @ChathumiKaveesha  **Email:** jkvckaveesha@students.nsbm.ac.lk  **Review partner:** KMCA

Tasks and branches are taken from the team plan. PR numbers, dates and reviewers are to be filled from GitHub.

| Task | Branch | Due | PR # | Merged | Reviewer |
|------|--------|-----|------|--------|----------|
| 1. Repository, CI and Git rules | kaveesha | Mon 16 Nov | #83 | Nov 20 | PDS (lead reads) |
| 2. Outbreak Alerts screen | kaveesha(frontend) | Fri 30 Oct | #15, #31, #56 | Oct 29-Nov 11 | KMCA |
| 3. Profile and Add Crop Plot sheet | kaveesha(frontend) | Fri 30 Oct | #31 | Oct 30 | KMCA |
| 4. Report diagrams and skeleton | kaveesha / feature/docs/report | Tue 10 Nov | #52, #55 | Nov 10 | KMCA |
| 5. Demo and submission pack | kaveesha | Mon 23 Nov | | | KMCA |

**Commits (49 on dev):** `Create 01_use_case.puml`, `Create 02_data_model.mmd`, `Create 03_class_diagram.mmd`, `Create 05_sequence_scan_to_alert.mmd`, `Create REPORT_OUTLINE.md`, `Create CONTRIBUTIONS.md`, `[Repo] Update root gitignore, mailmap identity mapping, and remove redundant gitkeep files`, `[UI] Replace hard-coded name in profile header with neutral fallback`, `Create profile_header.dart`, `Update add_crop_plot_sheet.dart`.

**Files, folders and tests I wrote:**
- Task 1: `.github/**` (PR template, CODEOWNERS, `ci.yml`), `README.md`, `CONTRIBUTING.md`, `.gitignore`, `.mailmap`, `docs/BRANCH_CLEANUP.md`
- Task 2: `lib/features/alerts/presentation/**` (alert_card, preventive_steps_panel, outbreak_map_view, zone_bottom_sheet, alerts_screen) and its widget test
- Task 3: `lib/features/profile/presentation/**` (profile_header, farm_info_card, crop_plot_tile, settings_section), `lib/features/crop_plots/presentation/**` (add_crop_plot_sheet) and widget tests
- Task 4: `docs/report/**` (five diagrams as source and PNG, `REPORT_OUTLINE.md`, this file, render and Git-history scripts)
- Task 5: `docs/demo/**`, `docs/USER_GUIDE.md`, `docs/SUBMISSION_CHECKLIST.md`

**Challenges and how I solved them:**

**Lessons learned:**

**What I reviewed for my partner and what changed:**
