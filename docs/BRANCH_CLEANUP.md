# Branch Cleanup and Retirement Plan

This document tracks the active personal branches and records the retirement of legacy shared branches as part of the repository restructuring.

---

## 1. Active Personal Branches
Every team member works exclusively on their assigned personal branch and opens pull requests into `dev`:

| Member | Branch Name | University Identifier | Role / Area | Review Partner |
|---|---|---|---|---|
| PDS Sandawaruni | `subodha` / `origin/subodha` | `pdssandawaruni@students.nsbm.ac.lk` | Team Lead, Core & Deployment | SDL |
| JKVC Kaveesha | `kaveesha` / `origin/kaveesha` | `jkvckaveesha@students.nsbm.ac.lk` | Repo Hygiene, Docs, Submission | KMCA |
| KMCA Kumarasinghe | `origin/kmcakumarasinghe` / `origin/amandikumarasinghe` | `kmcakumarasinghe@students.nsbm.ac.lk` | Backend, Rules, Crop Tables | JKVC |
| MASN Weerasingha | `sahan(Leader)` / `origin/sahan(Leader)` | `masnweerasingha@students.nsbm.ac.lk` | Backend Lead, Architecture | UGDS |
| SDL Weerasinghe | `sobani` / `origin/sobani` | `sobani.darshi@gmail.com` | On-device ML Model Integration | PDS |
| UGDS Munasinghe | `origin/ugdsmunasinghe` | `ugdsmunasinghe@students.nsbm.ac.lk` | ML Training, Dataset & Pipeline | MASN |
| RMOP Purwa | `oshadhi` / `origin/oshadhi` | `rmopurwa@students.nsbm.ac.lk` | Cloud Functions, Outbreak Alerts | AHMS |
| AHMS Maneesha | `sasindi` / `origin/sasindi` | `ahmsmaneesha@students.nsbm.ac.lk` | Planner & Weather Repositories | RMO |

> **Rule:** Personal branches must NOT be deleted before final project submission, as they provide evidence of individual git contributions and history for examination.

---

## 2. Retired Branches (Post-Merge into `dev`)
The following shared branches were used during initial sprint bootstrapping. After their contents were merged into `dev`, they are retired from active development:

1. **`frontend`** (`origin/frontend`):
   - Merged into `dev` in Step 0 (`v0.1-ui`).
   - Status: **Retired** (all UI work transitioned to personal branches).
2. **`BackEnd`** (`origin/BackEnd`):
   - Merged into `dev` via PR #82.
   - Status: **Retired** (all backend tasks transitioned to personal branches).
3. **`Dataset-and-Model-training`** (`origin/Dataset-and-Model-training`):
   - Merged into `dev` via model PRs.
   - Status: **Retired** (model training work transitioned to UGDS/MASN/SDL personal branches).

---

## 3. Merge Standards
- Target branch for all PRs: **`dev`**
- Merge strategy: **Create a merge commit** (Squashing is strictly prohibited).
- Tag milestones:
  - `v0.1-ui`: Frontend baseline
  - `v0.2-backend`: Backend feature freeze
  - `v1.0-rc`: Release candidate
  - `v1.0`: Final submission tag on `main`
