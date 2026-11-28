# AgroVision — Final Submission Checklist (SE205.3)

**Target Submission Date:** Mon 30 Nov  
**Code Freeze Date:** Mon 23 Nov  
**Checklist Owner:** JKVC Kaveesha (verified with PDS Sandawaruni & KMCA Kumarasinghe)

Mark each item `[x]` only after verifying the final artifact in the repository or submission bundle.

---

## 1. Source Code, Git Hygiene & Release Tags

| Item | Requirement / Verification | Owner | Done |
|------|----------------------------|-------|------|
| `dev` branch complete | All task PRs merged into `dev` using **Merge commit** or **Rebase and merge** (never Squash) | PDS & All Members | [ ] |
| `main` branch synced | Frozen `dev` merged cleanly into `main` on/after Mon 23 Nov code freeze | PDS | [ ] |
| Milestone tags present | `v0.1-ui`, `v0.2-backend`, `v0.3-integration`, `v1.0-rc`, and final `v1.0` on frozen `main` (`git tag -l`) | PDS | [ ] |
| `.mailmap` verified | `git shortlog -sne origin/dev` shows one clean university identity per member (no history rewrite) | JKVC | [x] |
| Personal branches kept | All 8 personal branches remain on GitHub for contribution audit; retired shared branches documented in `docs/BRANCH_CLEANUP.md` | JKVC / PDS | [x] |
| No secrets committed | Verify `.env`, service-account keys, `google-services.json`, `GoogleService-Info.plist`, and API keys are absent from Git history/HEAD | JKVC / PDS | [ ] |
| CI & static checks green | `flutter analyze` (0 errors), `flutter test` (100% pass), `functions` `npm run lint` & `npm test` passing on `dev`/`main` | PDS / KMCA | [ ] |

---

## 2. Installable Release APK & Live Backend Verification

| Item | Requirement / Verification | Owner | Done |
|------|----------------------------|-------|------|
| Firebase `agrovision-dev` & `agrovision-prod` live | Rules (`firestore.rules`, `storage.rules`), indexes, and all 4 Cloud Functions deployed; `OPENWEATHER_API_KEY` set in Secret Manager; Blaze budget alert configured | PDS | [ ] |
| Release APK built | Compiled with `flutter build apk --release --dart-define=USE_FAKES=false --dart-define=USE_EMULATORS=false` (`app/build/app/outputs/flutter-apk/app-release.apk`) | PDS | [ ] |
| Release APK packaged for submission | Copy signed `agrovision-v1.0.apk` into the external submission pack (do **not** commit `.apk` binaries to Git) | PDS / JKVC | [ ] |
| Two-phone physical smoke test & UAT | Installed on >= 2 physical Android phones; 28 UAT scenarios signed off in `docs/UAT_REPORT.md` | KMCA / PDS | [ ] |

---

## 3. Technical Report & Diagrams

| Item | Requirement / Verification | Owner | Done |
|------|----------------------------|-------|------|
| Diagram sources & PNGs | All 5 diagrams in `docs/report/diagrams/` (`01_use_case`, `02_data_model`, `03_class_diagram`, `04_deployment_architecture`, `05_sequence_scan_to_alert`) match final code and render cleanly as `.png` | JKVC | [x] |
| Report outline complete | `docs/report/REPORT_OUTLINE.md` aligned with assessment criteria (prototype quality, architecture & patterns, architectural decisions, testing, individual contribution) and includes `decisionLogs` addition | JKVC | [x] |
| Written technical report | Complete Sections 0–8 + Appendices A–E exported as final PDF (`AgroVision_SE205.3_Report.pdf`) | All Members (compiled by JKVC) | [ ] |
| Design vs screenshot comparison | Section 5.1 side-by-side design PNGs vs real app screenshots, plus fidelity differences table (Section 5.2) | All Members / JKVC | [ ] |
| ML model card & metrics | `ml/MODEL_CARD.md`, `ml/reports/evaluation_summary.json`, confusion matrix & on-device parity metrics included in Section 3.5 & 6.5 | MASN / UGDS / SDL | [ ] |

---

## 4. Individual Contribution Write-Ups (400–600 Words Each)

Each member completes their own first-person section in `docs/report/CONTRIBUTIONS.md` (using `bash docs/report/tools/list_contributions.sh` and GitHub PR history) and copies it into Section 9 of the final report.

| Member | Role | `CONTRIBUTIONS.md` Notes | Report Section 9 (400–600 words) | Owner | Done |
|--------|------|--------------------------|----------------------------------|-------|------|
| **PDS Sandawaruni** | Team Lead, Auth, Crop Plots, Deploy | Git data populated | Challenges, lessons, partner review & final prose | PDS | [ ] |
| **SDL Weerasinghe** | Theme, Router, Home, TFLite Wiring | Git data populated | Challenges, lessons, partner review & final prose | SDL | [ ] |
| **UGDS Munasinghe** | Core Widgets, Capture UI, ML Track | Git data populated | Challenges, lessons, partner review & final prose | UGDS | [ ] |
| **MASN Weerasinghe** | Design System, Result UI, ML Pipeline | Git data populated | Challenges, lessons, partner review & final prose | MASN | [ ] |
| **RMOP Purwa** | Weather & Outbreak Functions, Diagnosis Repo, Advisor UI | Git data populated | Challenges, lessons, partner review & final prose | RMOP | [ ] |
| **AHMS Maneesha** | Security Rules, Crop Tables, Planner Engine, FCM Alerts | Git data populated | Challenges, lessons, partner review & final prose | AHMS | [ ] |
| **KMCA Kumarasinghe** | History UI & Repo, Test Plan, QA, UAT | Git data populated | Challenges, lessons, partner review & final prose | KMCA | [ ] |
| **JKVC Kaveesha** | Repo Hygiene, Alerts & Profile UI, Report, Demo & Submission | Git data populated | Challenges, lessons, partner review & final prose | JKVC | [ ] |

---

## 5. Demo Video, Script & User Guide

| Item | Requirement / Verification | Owner | Done |
|------|----------------------------|-------|------|
| Demo script | `docs/demo/DEMO_SCRIPT.md` (5–7 min, all 8 features in order, speakers, steps, offline/network backup plan) | JKVC | [x] |
| Real-phone demo recording | Recorded on physical Android phone **after** Mon 23 Nov freeze; shows register, scan offline, result, save, History, planner with rain, advisor, outbreak alert & FCM push; stored **outside Git** | JKVC / PDS | [ ] |
| Farmer user guide | `docs/USER_GUIDE.md` written in plain farmer-friendly language | JKVC | [x] |
| User guide screenshots | Capture real phone screenshots on `v1.0` APK (`01_register_farm.png` – `09_profile_plots.png`) and place in `docs/demo/screenshots/` | JKVC / KMCA | [ ] |

---

## 6. Supervisor & Module Submission Requirements

| Requirement | Verification | Owner | Done |
|-------------|--------------|-------|------|
| Cover page & member IDs | Title (`AgroVision`), module (`SE205.3`), all 8 full names + NSBM registration numbers, supervisor name, submission date (`Mon 30 Nov`) | JKVC / PDS | [ ] |
| GitHub repository link & branch audit | Public/accessible repository URL (`https://github.com/sahannavo/AgroVision`), `dev` and `main` histories clean, `v1.0` tag visible | PDS | [ ] |
| QA & testing evidence pack | `docs/TEST_PLAN.md`, `docs/QA_CHECKLIST.md`, `docs/UAT_REPORT.md`, `docs/ISSUES.md` up to date and referenced in Section 6 | KMCA | [ ] |
| Viva readiness check | Every team member can walk through and explain every file they authored or modified | All 8 Members | [ ] |
| Submission archive uploaded | Final bundle (Report PDF, Diagrams, APK, Demo Video `.mp4`, Repo link / ZIP if requested) uploaded to LMS before deadline on **Mon 30 Nov** | PDS / JKVC | [ ] |
