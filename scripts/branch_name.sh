#!/usr/bin/env bash
# Branch name helper: generates standardized branch names from issue IDs and titles
# Usage: ./scripts/branch_name.sh <issue-id> <title words...>
#
# Behavior:
# - Issue ID is required and appears lowercased at the start
# - Title is lowercased; non-alphanumeric runs become single hyphens
# - No leading or trailing hyphens
# - Exits non-zero if issue ID is missing or title is empty
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

# Lowercase the issue ID
issue_id_lower=$(echo "$issue_id" | tr '[:upper:]' '[:lower:]')

# Lowercase the title and convert to hyphenated slug:
# 1. Convert to lowercase
# 2. Replace non-alphanumeric characters with spaces
# 3. Collapse multiple spaces into single spaces
# 4. Trim leading/trailing spaces
# 5. Replace spaces with hyphens
# 6. Remove trailing hyphens
title_slug=$(echo "$title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/ /g' | tr -s ' ' | sed 's/^ *//; s/ *$//' | tr ' ' '-' | sed 's/-*$//')

# Combine issue ID and title slug, handling empty title_slug
if [ -z "$title_slug" ]; then
  echo "${issue_id_lower}"
else
  echo "${issue_id_lower}-${title_slug}"
fi
