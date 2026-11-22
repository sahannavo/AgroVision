# Contributing to AgroVision

Welcome to the AgroVision development repository (SE205.3). AgroVision is an offline-first Flutter and Firebase mobile application with on-device machine learning for nightshade crop farmers in Sri Lanka.

To maintain code quality, avoid merge conflicts, and ensure a smooth review process, all contributors must strictly adhere to the following workflow rules.

---

## 1. Branching Strategy & Daily Routine

1. **Work Exclusively on Your Personal Branch**:
   - Each contributor works solely on their designated personal branch (e.g., `kaveesha`, `sahan(Leader)`, `kmcakumarasinghe`, `subodha`, etc.).
   - Never commit directly to `dev` or `main`.
   - Never merge another team member's personal branch directly into yours.

2. **Daily Routine (Every Morning)**:
   Always sync the latest shared work from `dev` before beginning:
   ```bash
   git checkout <your-personal-branch>
   git fetch origin
   git merge origin/dev
   ```
   If conflicts occur, resolve them, keeping the official version for files you do not own.

3. **Strict File Ownership**:
   - Only edit files assigned to you in the sprint plan.
   - If you need a new dependency, model schema field, or shared interface, document it under **NOTES** in your PR rather than modifying files owned by another member.

---

## 2. Commit Format & Areas

Commit frequently in small, logical increments using the standard team format (maximum 50 characters for the summary):

```text
[Area] Short description
```

### Recognized Area Tags:
* **`[UI]`**: User interface widgets, screens, theme changes, presentation state.
* **`[Data]`**: Repositories, models, data sources, Firestore/Auth adapters.
* **`[Func]`**: Cloud Functions (TypeScript), triggers, backend integrations.
* **`[ML]`**: Machine learning models, training scripts, TFLite conversion, evaluation.
* **`[Test]`**: Unit tests, widget tests, integration tests, emulator tests.
* **`[Docs]`**: Documentation, diagrams, guides, reports, checklists.
* **`[Repo]`**: Repository hygiene, `.gitignore`, `.mailmap`, CI workflows.

---

## 3. Pull Request Guidelines

1. **Target Branch**:
   - All pull requests must target **`dev`** (`base: dev` <- `compare: <your-branch>`).
2. **One Task, One Pull Request**:
   - Complete one task fully with passing tests before opening a PR. Do not combine multiple tasks into a single PR.
3. **Review Partner Requirement**:
   - Assign your assigned review partner:
     - **JKVC** reviews **KMCA** and vice versa.
     - **PDS** reviews **SDL** and vice versa.
     - **UGDS** reviews **MASN** and vice versa.
     - **RMO** reviews **AHMS** and vice versa.
4. **Merge Method**:
   - Merge using **"Create a merge commit"** or **"Rebase and merge"**.
   - **Never Squash**: The complete commit history is evaluated for individual contributions.
   - **No Force-Pushes** (`--force`) on branches that have open pull requests or shared history.
