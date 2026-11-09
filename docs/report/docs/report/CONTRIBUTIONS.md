# Contributions

One section per member. Facts (tasks, branches, pull requests) come from Git history; the **Challenges** and **Lessons learned** are for each member to write in their own words. Do not edit another member's section.

## How to fill the facts from Git

```bash
# Commits by one person on their branch (replace the email and branch)
git log dev --author="their@email" --pretty="%h %ad %s" --date=short

# Merged pull requests by one person (needs the GitHub CLI)
gh pr list --state merged --author "<github-user>" --json number,title,headRefName,mergedAt

# Files a person changed
git log dev --author="their@email" --name-only --pretty=format: | sort -u
```

Commit counts and dates should show regular work across the sprint, not one large commit.

## Members and review partners

| Initials | Role in the sprint | Review partner |
|----------|--------------------|----------------|
| PDS | Team lead, deploys to `agrovision-prod` | SDL |
| SDL | *TODO* | PDS |
| UGDS | *TODO* | MASN |
| MASN | *TODO* | UGDS |
| RMO | *TODO* | AHMS |
| AHMS | *TODO* | RMO |
| KMCA | *TODO* (Kumarasighe) | JKVC |
| JKVC | Repo and CI, Alerts, Profile, report diagrams, submission pack (Kaveesha) | KMCA |

---

## JKVC (Kaveesha)

| Task | Branch | Dates | Pull request | Review partner |
|------|--------|-------|--------------|----------------|
| 1. Repository, CI and Git rules | `feature/repo/setup` | Mon 26 Oct | *#TODO* | merged by self after lead (PDS) read it |
| 2. Outbreak Alerts screen | `feature/ui/alerts` | Wed 28 – Fri 30 Oct | *#TODO* | KMCA |
| 3. Profile and Add Crop Plot sheet | `feature/ui/profile` | Wed 28 – Fri 30 Oct | *#TODO* | KMCA |
| 4. Report diagrams and skeleton | `feature/docs/report` | Sat 31 Oct – Tue 10 Nov | *#TODO* | KMCA |
| 5. Demo and submission pack | `feature/docs/submission` | Wed 18 – Sat 28 Nov | *#TODO* | KMCA |

**Deliverables:** *TODO list the files you own, e.g. `lib/features/alerts/presentation/**`, `lib/features/profile/presentation/**`, `lib/features/crop_plots/presentation/**`, `docs/report/**`, `docs/demo/**`.*

**Challenges:** *TODO – your words.*

**Lessons learned:** *TODO – your words.*

---

## KMCA (Kumarasighe)

| Task | Branch | Dates | Pull request | Review partner |
|------|--------|-------|--------------|----------------|
| *TODO* | *TODO* | *TODO* | *#TODO* | JKVC |

**Deliverables:** *TODO*

**Challenges:** *TODO – your words.*

**Lessons learned:** *TODO – your words.*

---

## PDS

| Task | Branch | Dates | Pull request | Review partner |
|------|--------|-------|--------------|----------------|
| *TODO* | *TODO* | *TODO* | *#TODO* | SDL |

**Deliverables:** *TODO*

**Challenges:** *TODO – your words.*

**Lessons learned:** *TODO – your words.*

---

## SDL

| Task | Branch | Dates | Pull request | Review partner |
|------|--------|-------|--------------|----------------|
| *TODO* | *TODO* | *TODO* | *#TODO* | PDS |

**Deliverables:** *TODO*

**Challenges:** *TODO – your words.*

**Lessons learned:** *TODO – your words.*

---

## UGDS

| Task | Branch | Dates | Pull request | Review partner |
|------|--------|-------|--------------|----------------|
| *TODO* | *TODO* | *TODO* | *#TODO* | MASN |

**Deliverables:** *TODO*

**Challenges:** *TODO – your words.*

**Lessons learned:** *TODO – your words.*

---

## MASN

| Task | Branch | Dates | Pull request | Review partner |
|------|--------|-------|--------------|----------------|
| *TODO* | *TODO* | *TODO* | *#TODO* | UGDS |

**Deliverables:** *TODO*

**Challenges:** *TODO – your words.*

**Lessons learned:** *TODO – your words.*

---

## RMO

| Task | Branch | Dates | Pull request | Review partner |
|------|--------|-------|--------------|----------------|
| *TODO* | *TODO* | *TODO* | *#TODO* | AHMS |

**Deliverables:** *TODO*

**Challenges:** *TODO – your words.*

**Lessons learned:** *TODO – your words.*

---

## AHMS

| Task | Branch | Dates | Pull request | Review partner |
|------|--------|-------|--------------|----------------|
| *TODO* | *TODO* | *TODO* | *#TODO* | RMO |

**Deliverables:** *TODO*

**Challenges:** *TODO – your words.*

**Lessons learned:** *TODO – your words.*
