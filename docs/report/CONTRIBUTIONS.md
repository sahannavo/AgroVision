# AgroVision - Individual contributions

Each member completes their own section **in their own words** (first person). Do not edit anyone else's section.

## How to fill this in
1. Run `bash docs/report/tools/list_contributions.sh` from the repository root (after `git fetch --all`). It prints, per author,
   the merged branches and every commit. Use it for the tables below.
2. Pull request numbers and reviewers come from GitHub (Pull requests, filter `is:pr author:<you>`).
3. Keep the branch names exactly as in Git. The lecturer checks this file against the repository history.
4. Write challenges and lessons yourself. Aim for 400-600 words per member for the report, and short notes here are fine to start.

Review partners: PDS with SDL, UGDS with MASN, RMO with AHMS, KMCA with JKVC.

Names and GitHub handles below are placeholders to complete.

---

## PDS (team lead)
**GitHub:** @___  **Review partner:** SDL

| Task | Branch | PR # | Merged | Reviewer |
|------|--------|------|--------|----------|
| _from Git history_ | | | | |

Known responsibilities from the plan: reads and approves the repository setup pull request, receives every NOTES item, deploys to `agrovision-prod`.

**Files, folders and tests I wrote:**

**Commits (count and examples):**

**Challenges and how I solved them:**

**Lessons learned:**

**What I reviewed for my partner and what changed:**

---

## SDL
**GitHub:** @___  **Review partner:** PDS

| Task | Branch | PR # | Merged | Reviewer |
|------|--------|------|--------|----------|
| _from Git history_ | | | | |

**Files, folders and tests I wrote:**

**Commits (count and examples):**

**Challenges and how I solved them:**

**Lessons learned:**

**What I reviewed for my partner and what changed:**

---

## UGDS
**GitHub:** @___  **Review partner:** MASN

| Task | Branch | PR # | Merged | Reviewer |
|------|--------|------|--------|----------|
| _from Git history_ | | | | |

**Files, folders and tests I wrote:**

**Commits (count and examples):**

**Challenges and how I solved them:**

**Lessons learned:**

**What I reviewed for my partner and what changed:**

---

## MASN
**GitHub:** @___  **Review partner:** UGDS

| Task | Branch | PR # | Merged | Reviewer |
|------|--------|------|--------|----------|
| _from Git history_ | | | | |

**Files, folders and tests I wrote:**

**Commits (count and examples):**

**Challenges and how I solved them:**

**Lessons learned:**

**What I reviewed for my partner and what changed:**

---

## RMO
**GitHub:** @___  **Review partner:** AHMS

| Task | Branch | PR # | Merged | Reviewer |
|------|--------|------|--------|----------|
| _from Git history_ | | | | |

**Files, folders and tests I wrote:**

**Commits (count and examples):**

**Challenges and how I solved them:**

**Lessons learned:**

**What I reviewed for my partner and what changed:**

---

## AHMS
**GitHub:** @___  **Review partner:** RMO

| Task | Branch | PR # | Merged | Reviewer |
|------|--------|------|--------|----------|
| _from Git history_ | | | | |

**Files, folders and tests I wrote:**

**Commits (count and examples):**

**Challenges and how I solved them:**

**Lessons learned:**

**What I reviewed for my partner and what changed:**

---

## KMCA Kumarasighe
**GitHub:** @___  **Review partner:** JKVC

| Task | Branch | PR # | Merged | Reviewer |
|------|--------|------|--------|----------|
| _from Git history_ | | | | |

**Files, folders and tests I wrote:**

**Commits (count and examples):**

**Challenges and how I solved them:**

**Lessons learned:**

**What I reviewed for my partner and what changed:**

---

## JKVC Kaveesha
**GitHub:** @___  **Review partner:** KMCA

Tasks and branches are taken from the team plan. PR numbers, dates and reviewers are to be filled from GitHub.

| Task | Branch | Due | PR # | Merged | Reviewer |
|------|--------|-----|------|--------|----------|
| 1. Repository, CI and Git rules | `feature/repo/setup` | Mon 26 Oct (midday) | | | PDS (lead reads, merged by me) |
| 2. Outbreak Alerts screen | `feature/ui/alerts` | Fri 30 Oct | | | KMCA |
| 3. Profile and Add Crop Plot sheet | `feature/ui/profile` | Fri 30 Oct | | | KMCA |
| 4. Report diagrams and skeleton | `feature/docs/report` | Tue 10 Nov | | | KMCA |
| 5. Demo and submission pack | `feature/docs/submission` | Sat 28 Nov | | | KMCA |

**Files, folders and tests I wrote:**
- Task 1: `.github/**` (PR template, CODEOWNERS, `ci.yml`), `README.md`, `CONTRIBUTING.md`, `.gitignore`, `docs/ISSUES.md`, `docs/SCHEDULE.md`
- Task 2: `lib/features/alerts/presentation/**` (alert_card, preventive_steps_panel, outbreak_map_view, zone_bottom_sheet) and its widget test
- Task 3: `lib/features/profile/presentation/**` (profile_header, farm_info_card, crop_plot_tile, settings_section), `lib/features/crop_plots/presentation/**` (add crop plot sheet) and widget tests
- Task 4: `docs/report/**` (five diagrams as source and PNG, `REPORT_OUTLINE.md`, this file, render and Git-history scripts)
- Task 5: `docs/demo/**`, `docs/USER_GUIDE.md`, `docs/SUBMISSION_CHECKLIST.md`

**Commits (count and examples):** _run `list_contributions.sh`_

**Challenges and how I solved them:**

**Lessons learned:**

**What I reviewed for my partner and what changed:**
