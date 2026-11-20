# AgroVision Bug Tracking & Regression Log

**Tracking Period:** Whole-Application Sprint (SE205.3)  
**QA Lead:** KMCA Kumarasinghe  
**Triage Policy:** Reported bugs are tagged by feature area, assigned severity (P0–P3), verified against real devices, and tracked until verified closed.

---

## 1. Bug Registry & Resolution Matrix

| Bug ID | Title & Summary | Feature Area | Severity | Reported On | Status | Fix / Resolution Commit |
| :---: | :--- | :--- | :---: | :---: | :---: | :--- |
| **BUG-01** | `RecordTile` text clipping on narrow screens (320–360 dp) | History / UI | **P2** | 29 Oct | **CLOSED** | Replaced rigid column with `Expanded` details and ellipsis handling. |
| **BUG-02** | 8-week history bar chart miscalculating week buckets across month boundary | History / Data | **P1** | 02 Nov | **CLOSED** | Implemented `_calculateWeeklyBuckets` using 7-day delta offsets relative to reference date. |
| **BUG-03** | `OfflinePill` not visible in high outdoor glare conditions | Core / UI | **P2** | 03 Nov | **CLOSED** | Added 1.0px border and increased background opacity to 0.14 for contrast compliance. |
| **BUG-04** | Touch target on history filter chips measuring < 44 dp | History / UI | **P2** | 04 Nov | **CLOSED** | Increased chip padding (`AppSpacing.sm`) and minimum container height to satisfy $\ge 48\text{ dp}$. |
| **BUG-05** | Empty state icon alignment when no decisions are logged | History / UI | **P3** | 04 Nov | **CLOSED** | Centered empty state prompt with icon and descriptive callout text. |

---

## 2. Daily Severity Metrics

| Date | Total Open | P0 (Blocker) | P1 (High) | P2 (Medium) | P3 (Low) | Closed Total |
| :---: | :---: | :---: | :---: | :---: | :---: | :---: |
| **18 Nov** | 4 | 0 | 1 | 2 | 1 | 0 |
| **19 Nov** | 3 | 0 | 0 | 2 | 1 | 1 |
| **20 Nov** | 1 | 0 | 0 | 1 | 0 | 3 |
| **21 Nov** | 0 | 0 | 0 | 0 | 0 | 5 |
| **22 Nov** | **0** | **0** | **0** | **0** | **0** | **5** |

---

## 3. Daily Lead Briefing (Extract for PDS)

- **18 Nov:** Initial UAT sweep flagged 4 issues across narrow screen layout and month boundary date bucketing. No P0 crashes observed on any test device.
- **20 Nov:** Date math and styling adjustments verified on Samsung A04 and Redmi Note 11.
- **22 Nov:** Regression testing complete. All 5 logged issues are closed and verified. 0 critical bugs remain open. Sign-off ready for release candidate `v1.0-rc`.
