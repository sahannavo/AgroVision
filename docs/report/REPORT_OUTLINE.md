# AgroVision (SE205.3) – Report outline

Skeleton that follows the assessment criteria. Each section lists what to write, the evidence to point at, and the diagram to include. Replace the *TODO* items as the code lands. Diagrams live in `docs/report/diagrams/` (Mermaid source plus rendered PNG).

| # | Section | Criterion covered | Suggested length |
|---|---------|-------------------|------------------|
| 1 | Introduction and scope | context | 1 page |
| 2 | Requirements and use cases | prototype quality | 1–2 pages |
| 3 | System architecture | architecture and design patterns | 3–4 pages |
| 4 | Data model | architecture | 1–2 pages |
| 5 | Design patterns | architecture and design patterns | 2–3 pages |
| 6 | Architectural decisions and reasons | architectural decisions | 2 pages |
| 7 | Prototype and implementation | prototype quality | 3–4 pages |
| 8 | Testing | testing | 2 pages |
| 9 | Team process and Git workflow | contribution | 1 page |
| 10 | Individual contribution (one per member) | individual contribution | 1 page each |
| 11 | Limitations and future work | reflection | 1 page |
| 12 | References and appendices | – | – |

---

## 1. Introduction and scope
- Problem: nightshade crop farmers (tomato, potato, chilli, eggplant) in Sri Lanka lose yield to late disease detection and poor irrigation timing.
- Solution in one paragraph: on-device leaf diagnosis, weather-aware planner, advisor, community outbreak alerts.
- In scope / out of scope (phone OTP login, PIN, Sinhala and Tamil buttons, field tools, harvest advisory cards are out; cooperative dashboard is future work).
- Team of eight, supervisor, timeline (7 phases, 26 Oct – 30 Nov, tags v0.1-ui to v1.0).

## 2. Requirements and use cases
- Actors: farmer, gardener; cooperative shown outside the boundary as future work.
- **Figure 1: Use case diagram** → `diagrams/01_use_case.png`
- Functional requirements table (one row per use case, mapped to screen and route).
- Non-functional: offline diagnosis, privacy of outbreak alerts, 360–430 dp layouts, 130 percent text scale, 48 dp tap targets.

## 3. System architecture
- **Figure 2: Deployment and system architecture** → `diagrams/04_architecture_deployment.png`
- Walk through each node: Flutter app, TFLite model on device, Firebase Auth, Firestore (offline persistence), Storage, Cloud Functions (4 functions, one file each), FCM, OpenWeatherMap behind a Cloud Function.
- Environments: `agrovision-dev` for everyone, `agrovision-prod` deployed only by PDS, Firebase Emulator Suite for development and tests.
- Security of secrets: `OPENWEATHER_API_KEY` in `functions/.env`, never in the app, never committed.
- **Figure 3: Sequence – scan, diagnose, save, outbreak alert** → `diagrams/05_sequence_scan_to_alert.png`. Explain the threshold variables `OUTBREAK_RADIUS_KM`, `OUTBREAK_MIN_REPORTS`, `OUTBREAK_WINDOW_HOURS`.

## 4. Data model
- **Figure 4: Class and data model** → `diagrams/02_data_model.png`
- Table of the nine collections with purpose and key fields; relations by reference fields (`userId`, `cropId`, `alertId`).
- Addition to the specification: `decisionLogs` (for the History Decisions tab). State this explicitly.
- Privacy by design: `outbreakAlerts` and `notifications` hold only disease, approximate (rounded) area and counts, never identity or exact position.
- *TODO:* indexes, security rules summary, geohash choice and precision.

## 5. Design patterns
Each subsection: what it is, where it is in the code (file path), what problem it solved, one short code excerpt.
- **Repository pattern** – interface in `domain/`, implementations in `data/`. **Figure 5: Repository pattern** → `diagrams/03_repository_pattern.png`
- **Dependency injection with Riverpod** – `alertsRepositoryProvider` and the other providers; screens read data only through providers; `USE_FAKES` dart-define switches implementations.
- **Feature-first layering** – `lib/core` plus `lib/features/<feature>/{data,domain,presentation}`; rule that presentation never imports Firebase.
- **Fakes behind interfaces** – fake repositories with realistic sample data let the front end finish all 11 screens before the back end existed, and keep tests deterministic.
- **Offline-first** – Firestore persistence, queued writes, cached weather for planner and advisor, offline state in alerts and map (plain background with banner), on-device TFLite for diagnosis.
- *Optional:* observer/stream pattern (`watchNearby` streams), design tokens (`AppColors`, `AppTextStyles`, `AppSpacing`, `AppRadius`).

## 6. Architectural decisions and their reasons
Use the table below (Decision / Alternatives considered / Reason / Trade-off). Fill the *TODO* cells with the team.

| Decision | Alternatives | Reason | Trade-off |
|----------|-------------|--------|-----------|
| Flutter | native Android, React Native | one codebase, strong offline and TFLite support | larger app size |
| Riverpod | Provider, Bloc, GetIt | compile-safe DI, easy overrides for fakes in tests | learning curve |
| go_router | Navigator 1.0 | declarative named routes agreed by the team (fixed route names) | – |
| Firestore with offline persistence | Realtime DB, SQLite plus own sync | built-in sync and cache, matches offline requirement | query limits, cost per read |
| On-device TFLite | cloud inference | works with no signal in the field, no image upload needed to diagnose | model size, device variance |
| Weather through a Cloud Function and `weatherCache` | call OpenWeatherMap from the app | keeps the API key secret, one hourly refresh serves all users | cache can be up to one hour stale |
| Outbreak detection in Cloud Functions with thresholds in `.env` | detect on the client | privacy (no farmer data sent to other devices), thresholds tunable without a release | function cold starts |
| Feature-first structure | layer-first | eight people work in parallel with few merge conflicts | some duplication |
| flutter_map with OpenStreetMap and `CircleLayer` | Google Maps | no API key, circles show approximate zones rather than exact pins | tiles need internet |
| Branch model: main protected, dev integration, merge commit or rebase, never squash | trunk-based | lecturer can review real history | more merge commits |
| *TODO* | | | |

## 7. Prototype and implementation
- Screen-by-screen walkthrough with screenshots (route, screen class, states shown: loading, empty, error, offline). Compare against `docs/design/*.png` and list known differences.
- Screens: Splash, Login, Register account, Register farm, Home, Capture, Result, Advisor, Planner, History, Alerts (list and map), Profile, Add crop plot sheet.
- Model: dataset, training summary, accuracy, size, labels. *TODO: from the ML task owner.*
- Back end: functions list, trigger flow, emulator evidence.
- Static quality: `flutter analyze` clean, files under about 300 lines, one widget per file.

## 8. Testing
- Strategy table: widget tests (one per screen with fake repositories), repository tests against the emulators, Cloud Function tests against the emulators, golden or emulator comparison with the design, manual UAT, accessibility checks (text scale 130 percent, 48 dp targets, Semantics labels), regression pass in Phase 5.
- CI: GitHub Actions on pull requests to `dev` and `main` (analyze, test, lint).
- Results: test counts, pass rate, coverage if available, bugs found and fixed (table with ID, found by, fixed in PR).
- UAT with real users or supervisor feedback. *TODO.*
- Offline test cases: airplane mode scan, queued save then sync, planner on cached weather, alerts offline state.

## 9. Team process and Git workflow
- Branch model, commit format `[Area] Short description` (max 50 characters), daily rhythm, review-partner pairs, code freeze Mon 23 Nov.
- Evidence: commit history, PR list, review comments. Link to `CONTRIBUTIONS.md`.

## 10. Individual contribution (one write-up per member)
Template for each member, in their own words (about one page). Source of facts: `CONTRIBUTIONS.md`.
1. Tasks owned, branch names, PR numbers.
2. Files and features delivered, with paths.
3. Technical decisions you made and why.
4. Reviews you did for your partner.
5. Challenges and how you solved them.
6. What you would do differently.
7. Be ready to explain every file you submitted (viva).

## 11. Limitations and future work
- Cooperative regional dashboard (outside the system boundary today).
- Sinhala and Tamil language support, phone OTP login, field tools, harvest advisory.
- Model improvements and more crops.
- Known differences from the designs and open bugs.

## 12. References and appendices
- Appendix A: diagram sources (`docs/report/diagrams/*.mmd`).
- Appendix B: Firestore collection reference.
- Appendix C: PR and commit list.
- Appendix D: README and developer setup.
- References: Flutter, Riverpod, Firebase, TensorFlow Lite, OpenWeatherMap, OpenStreetMap documentation.
