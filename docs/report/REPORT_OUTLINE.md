# AgroVision - Report outline (SE205.3)

Owner: JKVC Kaveesha (skeleton and diagrams). Section authors are named per section; each author writes their own text.
Status key: `[ ]` to write, `[~]` drafted, `[x]` done and reviewed.

> The assessment criteria used below are the five headings given in the task: prototype quality, architecture and
> design patterns, architectural decisions and reasons, testing, individual contribution. If the module handout
> weights or words them differently, rename the headings here to match it exactly.

## Diagrams (sources in `docs/report/diagrams/`)

| # | Diagram | Source | PNG | Used in section |
|---|---------|--------|-----|-----------------|
| 1 | Use case (farmer, gardener; cooperative outside the boundary as future work) | `01_use_case.puml` | `01_use_case.png` | 2.1 |
| 2 | Data model (Firestore collections and references) | `02_data_model.mmd` | `02_data_model.png` | 3.3 |
| 3 | Class diagram (repository pattern, providers, fakes) | `03_class_diagram.mmd` | `03_class_diagram.png` | 3.2 |
| 4 | Deployment and system architecture | `04_deployment_architecture.puml` | `04_deployment_architecture.png` | 3.1 |
| 5 | Sequence: scan, diagnose, save, outbreak alert | `05_sequence_scan_to_alert.mmd` | `05_sequence_scan_to_alert.png` | 3.6 |

Re-render after any change: `bash docs/report/tools/render_diagrams.sh`, then commit sources and PNGs together.

---

## 0. Front matter
- [ ] Title page: AgroVision, SE205.3, team members with registration numbers, supervisor, submission date (Mon 30 Nov).
- [ ] Abstract (150 words): problem, solution, result.
- [ ] Contents, list of figures, list of abbreviations.

## 1. Introduction
- [ ] 1.1 Problem: nightshade crop diseases (tomato, potato, chilli, eggplant) and late detection for Sri Lankan farmers.
- [ ] 1.2 Aim and objectives: offline on-device diagnosis, farm-aware planning and advice, community outbreak alerts.
- [ ] 1.3 Scope. In scope: the 11 screens plus the add-crop-plot sheet. Out of scope (from the designs): phone OTP login, PIN,
  Sinhala and Tamil language buttons, field tools, harvest advisory cards. Cooperative integration is future work.
- [ ] 1.4 Team, roles and process: eight members, one branch per screen or task, review-partner pairs, sprint calendar
  (7 phases, tags v0.1-ui to v1.0), merge commit or rebase and merge, freeze on Mon 23 Nov.

## 2. Requirements and analysis
- [ ] 2.1 Users and use cases (Diagram 1). Explain Farmer, Gardener and the Cooperative as future work.
- [ ] 2.2 Functional requirements: auth, crop plots, scan and diagnose, history and decisions, planner, advisor, alerts, profile.
- [ ] 2.3 Non-functional requirements: works offline for diagnosis, privacy of alerts, 360-430 dp layouts, text scale 130 percent,
  48 dp tap targets, Semantics labels.
- [ ] 2.4 Constraints: Firebase free tier, emulator-only development, light theme only, on-device model size.

## 3. Architecture and design patterns  *(criterion: architecture and design patterns)*
- [ ] 3.1 System architecture (Diagram 4): Flutter app, TFLite on device, Firebase Auth, Firestore, Storage, Cloud Functions
  (`getWeatherForecast`, `refreshWeatherCache`, `onDiagnosisCreated`, `onOutbreakAlertCreated`), FCM, OpenWeatherMap.
  Two Firebase projects: agrovision-dev for everyone, agrovision-prod deployed only by PDS.
- [ ] 3.2 Patterns (Diagram 3). For each: what it is, where it lives in the code (file path), what it bought us.
  - **Feature-first layering**: `lib/core` (theme, router, constants, services, utils, shared widgets) and
    `lib/features/<feature>/{data,domain,presentation}`. Eight people worked in parallel with almost no file conflicts.
  - **Repository pattern**: entities and interfaces in `domain/`, implementations in `data/`. Screens never import Firebase.
  - **Dependency injection with Riverpod**: one provider per repository (`authRepositoryProvider`, `cropPlotRepositoryProvider`,
    `alertsRepositoryProvider`, ...) plus `diagnosisClassifierProvider`. Overriding providers is how tests inject fakes.
  - **Fakes behind interfaces**: `Fake*Repository` returning realistic sample data; `--dart-define=USE_FAKES=true|false` chooses
    the implementation in each feature's `providers.dart`. The front-end phase ran without Firebase.
  - **Offline-first**: Firestore offline persistence, on-device classifier, last cached weather for planner and advisor,
    explicit offline states for login, alerts and sync.
  - **Declarative routing** with go_router and fixed route names; **design tokens** (`AppColors`, `AppTextStyles`,
    `AppSpacing`, `AppRadius`) as the single source of styling.
- [ ] 3.3 Data model (Diagram 2): the nine collections, reference fields, and the `decisionLogs` collection, which is an
  **addition to the specification** made for the History "Decisions" tab.
- [ ] 3.4 Back end: Cloud Functions responsibilities, thresholds in `functions/.env`
  (`OUTBREAK_RADIUS_KM`, `OUTBREAK_MIN_REPORTS`, `OUTBREAK_WINDOW_HOURS`), weather cache with `expiresAt`.
- [ ] 3.5 Machine-learning component: dataset, model, TFLite conversion, accuracy, confidence threshold, model file location.
  (Author: ML owner.)
- [ ] 3.6 Key flow (Diagram 5): scan, diagnose, save, outbreak alert, with the online and offline paths.
- [ ] 3.7 Privacy by design: `outbreakAlerts` and notifications hold only disease, approximate area (rounded centre) and counts;
  the map shows zones, never one pin per report.

## 4. Architectural decisions and reasons  *(criterion: decisions and their reasons)*
One short record per decision: context, options considered, decision, consequences. Reasons marked *(draft)* are
inferred from the specification and must be confirmed or replaced by the person who made the decision.

| # | Decision | Reason | Trade-off |
|---|----------|--------|-----------|
| D1 | On-device TFLite classification | Diagnosis must work with no network in the field | Model size and update through app release |
| D2 | Firestore with offline persistence | Offline reads and queued writes without custom sync code *(draft)* | Query limits, per-document cost |
| D3 | Riverpod for state and DI | Compile-safe providers, easy overrides in tests *(draft)* | Learning curve for the team |
| D4 | Repository interfaces plus fakes | UI team could build all screens before the back end existed | Two implementations per feature to keep aligned |
| D5 | Feature-first folders | Parallel work by eight people with clear ownership (CODEOWNERS) | Shared code must go through `core/` |
| D6 | OpenWeatherMap behind a Cloud Function | API key never ships in the app; hourly cache cuts calls and enables offline weather | Extra function to deploy and test |
| D7 | Outbreak detection in `onDiagnosisCreated` using a geohash | Server-side, cheap proximity grouping, identity never leaves the diagnosis | Geohash cell edges give approximate radii |
| D8 | Rounded centre point and no userId in alerts | Farmer privacy | Less precise advice |
| D9 | Top-level collections with reference fields | Simple queries and security rules per collection *(draft)* | Joins done in the client or functions |
| D10 | Thresholds in `functions/.env` | Tune without code change; different values for dev and prod | Config must be managed per project |
| D11 | Emulator Suite for all development | Nobody touches production; tests are repeatable | Setup effort for each developer |
| D12 | `USE_FAKES` dart-define | Front-end work continues without Firebase | Fakes can drift from real behaviour |
| D13 | Merge commit or rebase-and-merge, never squash | Lecturer reviews history; every commit stays visible | Noisier history |
| D14 | Added `decisionLogs` | History Decisions tab needs its own record | Deviation from the specification, documented here |
| D15 | Flutter with flutter_map and OpenStreetMap tiles | Free map layer with a circle layer; offline fallback to pale background | Tiles need internet |

- [ ] Add decisions made during integration (Phase 4) and any that were reversed, with the reason.

## 5. Implementation and prototype quality  *(criterion: prototype quality)*
- [ ] 5.1 Screens delivered, one subsection each, with a screenshot beside its design PNG: Splash, Login, Register account,
  Register farm, Home, Capture, Result, Advisor, Planner, History, Alerts (list and map), Profile and Add crop plot sheet.
- [ ] 5.2 Fidelity to the designs: table of visible differences that were not fixed (collect from each member's final summary).
- [ ] 5.3 States: loading, empty, error, offline for every screen.
- [ ] 5.4 Accessibility: scaling to 130 percent, tap targets, Semantics labels, contrast.
- [ ] 5.5 Offline demonstration: airplane-mode scan, cached weather, offline banner on alerts map.
- [ ] 5.6 End-to-end: real repositories on the emulator and on `agrovision-dev`, outbreak alert and push notification.
- [ ] 5.7 Known limitations and bugs left open at v1.0.

## 6. Testing  *(criterion: testing)*
- [ ] 6.1 Strategy and test pyramid: unit, widget, emulator integration, UAT.
- [ ] 6.2 Widget tests: one per screen, pumped with fake repositories through provider overrides.
- [ ] 6.3 Repository and Cloud Function tests against the Firebase Emulator Suite (including threshold edge cases:
  just below and at `OUTBREAK_MIN_REPORTS`, outside radius, outside time window).
- [ ] 6.4 Static analysis and CI: `flutter analyze`, `flutter test`, `npm run lint`, `npm test` on every pull request to dev and main.
- [ ] 6.5 Model evaluation: confusion matrix, per-class precision and recall, on-device versus training accuracy.
- [ ] 6.6 UAT (Phase 5, 18-22 Nov): script, testers, results, bugs found and fixed.
- [ ] 6.7 Accessibility and regression results after the freeze.
- [ ] 6.8 Results table: tests per area, pass rate, coverage if measured.

## 7. Evaluation and discussion
- [ ] 7.1 What worked (parallel branches, fakes, CI), what did not.
- [ ] 7.2 Risks met and how they were handled (model v1 versus final, integration swaps).
- [ ] 7.3 Limitations and future work: cooperative portal, Sinhala and Tamil, OTP login, more crops and diseases, push to cooperative.

## 8. Conclusion
- [ ] Aims against outcomes in half a page.

## 9. Individual contribution  *(criterion: individual contribution)*
One subsection per member, written in the first person, 400-600 words. The structure is fixed so markers can compare them:
1. Tasks owned and the files, folders and tests you wrote.
2. Branches and pull requests (with numbers) and who reviewed them.
3. Your commits: count and one or two examples that show real, regular work.
4. A design or technical decision you made and why.
5. Challenges and how you solved them.
6. Lessons learned.
7. What you reviewed for your partner and what you changed after their review.

The working notes for each member are in `CONTRIBUTIONS.md`; the final text is copied into this section.
- [ ] 9.1 PDS (lead)  [ ] 9.2 SDL  [ ] 9.3 UGDS  [ ] 9.4 MASN  [ ] 9.5 RMO  [ ] 9.6 AHMS  [ ] 9.7 KMCA  [ ] 9.8 JKVC

## References and appendices
- [ ] References (Flutter, Riverpod, Firebase, TensorFlow Lite, OpenWeatherMap, dataset source, OpenStreetMap attribution).
- [ ] Appendix A: Firestore collection field tables (copy from Diagram 2).
- [ ] Appendix B: Cloud Function list with trigger and purpose.
- [ ] Appendix C: Full class diagram for the six repositories not shown in Diagram 3 (Auth, Weather, Advisor, Planner, History, Diagnosis).
- [ ] Appendix D: Git history summary (output of `tools/list_contributions.sh`) and the sprint calendar.
- [ ] Appendix E: User guide link (`docs/USER_GUIDE.md`).

## Diagram maintenance rules
- Edit the source file, never the PNG. Run `tools/render_diagrams.sh`, and commit source and PNG in the same commit with an `[Docs]` message.
- Update the diagrams when a collection, a Cloud Function, a repository interface or a provider changes.
- Checkpoints: after v0.2-backend (Tue 10 Nov), after v0.3-integration (Tue 17 Nov), and before the freeze (Mon 23 Nov).
