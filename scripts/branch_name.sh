#!/usr/bin/env bash
# Branch name helper: generates standardized branch names from issue IDs and titles
# Usage: ./scripts/branch_name.sh <issue-id> <title words...>
#
# Behavior:
# - Issue ID is required and is turned into a slug the same way as the title
# - Title is lowercased; non-alphanumeric runs become single hyphens
# - No leading or trailing hyphens
# - Exits non-zero if issue ID is missing or title is empty
# - A blank issue ID, or one that is only hyphens, counts as missing
# - A title which normalises to nothing counts as empty
#
# Examples:
#   ./scripts/branch_name.sh ABC-15 Add a branch name helper
#   # Output: abc-15-add-a-branch-name-helper
#
#   ./scripts/branch_name.sh VEN-15 Add AGENTS.md, ADR-0001, and a tested branch-name helper
#   # Output: ven-15-add-agents-md-adr-0001-and-a-tested-branch-name-helper

set -euo pipefail

# Check for issue ID
if [ $# -lt 1 ]; then
  echo "Error: issue ID is required" >&2
  echo "Usage: $0 <issue-id> <title words...>" >&2
  exit 1
fi

issue_id="$1"
shift

# Check for title
if [ $# -lt 1 ]; then
  echo "Error: title is required" >&2
  echo "Usage: $0 <issue-id> <title words...>" >&2
  exit 1
fi

title="$*"

# Flatten newlines before sed, which only sees one line at a time.
slugify() {
  printf '%s' "$1" | tr '\n\r\t' '   ' | tr '[:upper:]' '[:lower:]' \
    | LC_ALL=C sed 's/[^a-z0-9]\{1,\}/-/g; s/^-*//; s/-*$//'
}
issue_id_lower=$(slugify "$issue_id")
title_slug=$(slugify "$title")

if [ -z "$issue_id_lower" ]; then
  echo "Error: issue ID is required" >&2
  echo "Usage: $0 <issue-id> <title words...>" >&2
  exit 1
fi

if [ -z "$title_slug" ]; then
  echo "Error: title is required" >&2
  echo "Usage: $0 <issue-id> <title words...>" >&2
  exit 1
fi

printf '%s\n' "${issue_id_lower}-${title_slug}"
