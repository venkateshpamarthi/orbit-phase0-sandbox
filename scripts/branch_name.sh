#!/usr/bin/env bash
# Branch name helper: generates standardized branch names from issue IDs and titles
# Usage: ./scripts/branch_name.sh <issue-id> <title words...>
#
# Behavior:
# - Issue ID is required and appears lowercased at the start
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

# Lowercase with printf so values such as "-n" are data, not echo flags.
# Trim whitespace, then drop leading and trailing hyphens so they cannot
# appear on the final branch name. A blank remainder is a missing issue ID.
issue_id_lower=$(printf '%s\n' "$issue_id" | tr '[:upper:]' '[:lower:]' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//; s/^-*//; s/-*$//')

if [ -z "$issue_id_lower" ]; then
  echo "Error: issue ID is required" >&2
  echo "Usage: $0 <issue-id> <title words...>" >&2
  exit 1
fi

# Lowercase the title and convert to hyphenated slug:
# 1. Convert to lowercase
# 2. Replace non-alphanumeric characters with spaces
# 3. Collapse multiple spaces into single spaces
# 4. Trim leading/trailing spaces
# 5. Replace spaces with hyphens
# 6. Remove leading and trailing hyphens
title_slug=$(printf '%s\n' "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/ /g' | tr -s ' ' | sed 's/^ *//; s/ *$//' | tr ' ' '-' | sed 's/^-*//; s/-*$//')

if [ -z "$title_slug" ]; then
  echo "Error: title is required" >&2
  echo "Usage: $0 <issue-id> <title words...>" >&2
  exit 1
fi
branch="${issue_id_lower}-${title_slug}"

branch=$(printf '%s\n' "$branch" | sed 's/^-*//; s/-*$//')
if [ -z "$branch" ]; then
  echo "Error: issue ID is required" >&2
  echo "Usage: $0 <issue-id> <title words...>" >&2
  exit 1
fi

printf '%s\n' "$branch"
