#!/usr/bin/env bash
# Print, per author, the merged branches/PRs and commits found in Git history of dev.
# Use the output to fill CONTRIBUTIONS.md. Run from the repository root after: git fetch --all
# Usage: bash docs/report/tools/list_contributions.sh [branch]   (default: origin/dev)
set -euo pipefail
ref="${1:-origin/dev}"
git shortlog -sne "$ref" | while read -r count rest; do
  email="$(sed -n 's/.*<\(.*\)>.*/\1/p' <<<"$rest")"
  echo "## $rest  ($count commits)"
  echo
  echo "Merged pull requests / branches (first-parent merges authored by this person):"
  git log "$ref" --first-parent --merges --author="$email" --format='- %ad  %s' --date=short || true
  echo
  echo "Commits:"
  git log "$ref" --no-merges --author="$email" --format='- %ad  %h  %s' --date=short
  echo
done
