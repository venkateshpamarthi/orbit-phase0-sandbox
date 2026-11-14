#!/usr/bin/env bash
# Test suite for scripts/branch_name.sh
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="${BRANCH_NAME_SCRIPT:-$repo_root/scripts/branch_name.sh}"
passed=0
failed=0

# Helper to run a test
test_case() {
  local name="$1"
  local expected="$2"
  shift 2

  local stdout stderr
  stderr="$(mktemp)"
  echo "TEST: $name"
  # The trailing x keeps the helper's trailing newlines visible, so stdout must be exactly one line.
  if stdout="$("$script" "$@" 2>"$stderr"; s=$?; printf x; exit $s)"; then
    if [ -s "$stderr" ]; then
      echo "  ✗ FAIL: unexpected stderr: '$(cat "$stderr")'"
      failed=$((failed + 1))
    elif [ "$stdout" = "${expected}"$'\n'x ]; then
      echo "  ✓ PASS"
      passed=$((passed + 1))
    else
      echo "  ✗ FAIL: expected exactly one stdout line '$expected', got '${stdout%x}'"
      failed=$((failed + 1))
    fi
  else
    echo "  ✗ FAIL: command exited with non-zero status"
    failed=$((failed + 1))
  fi
  rm -f "$stderr"
  echo
}

# Helper to test error cases (expect non-zero exit)
test_error() {
  local name="$1"
  shift

  echo "TEST: $name"
  if output=$("$script" "$@" 2>&1); then
    echo "  ✗ FAIL: expected non-zero exit, but command succeeded with: '$output'"
    failed=$((failed + 1))
  else
    echo "  ✓ PASS (correctly rejected)"
    passed=$((passed + 1))
  fi
  echo
}

echo "================================"
echo "Branch Name Helper Test Suite"
echo "================================"
echo

# Test 1: Normal title with spaces
test_case "Normal title with spaces" \
  "abc-15-add-a-branch-name-helper" \
  ABC-15 Add a branch name helper

# Test 2: Spaces and case handling
test_case "Mixed case and multiple spaces" \
  "xyz-42-fix-the-bug-quickly" \
  XYZ-42 Fix   The   BUG   Quickly

# Test 3: The exact branch name for this issue (VEN-15)
test_case "VEN-15: exact branch name for this issue" \
  "ven-15-add-agents-md-adr-0001-and-a-tested-branch-name-helper" \
  VEN-15 "Add AGENTS.md, ADR-0001, and a tested branch-name helper"

# Test 4: Missing issue ID (error case)
test_error "Missing issue ID (should fail)"

# Test 5: Empty title (error case)
test_error "Empty title (should fail)" ABC-15

# Edge case 1: Title with punctuation and special characters
test_case "Title with punctuation" \
  "bug-123-fix-user-s-login-issue" \
  BUG-123 "Fix user's login!!! issue???"

# Edge case 2: Title with numbers
test_case "Title with numbers" \
  "proj-99-upgrade-to-node-20-lts" \
  PROJ-99 Upgrade to Node 20 LTS

# Edge case 3: Title with consecutive special characters
test_case "Consecutive special characters collapse to single hyphen" \
  "task-5-add-support-for-api-v2" \
  TASK-5 "Add support for API -> v2"

# Edge case 4: Leading/trailing special characters in title
test_case "Leading/trailing special characters stripped" \
  "ven-1-update-readme" \
  VEN-1 "...Update README..."

# Edge case 5: A title of only special characters normalises to nothing and is rejected
test_error "Title with only special characters" ABC-0 "!!!"

# Edge case 6: Very long title
test_case "Very long title" \
  "long-1-this-is-a-very-long-title-with-many-words-that-should-all-be-converted-to-lowercase-and-joined-with-hyphens" \
  LONG-1 This is a very long title with many words that should all be converted to lowercase and joined with hyphens

# No leading or trailing hyphens on the generated branch name
test_error "Empty issue ID is rejected" "" "Add helper"

test_error "Hyphen-only issue ID is rejected" "-" "Add helper"

test_case "Leading hyphen on issue ID is stripped" \
  "ven-15-add-helper" \
  -VEN-15 "Add helper"

test_error "Trailing hyphen on issue ID is stripped when the title slug is empty" ABC- "!!!"

test_error "Empty-string title is rejected" ABC-1 ""

test_error "Whitespace-only title is rejected" ABC-1 " "

test_error "Whitespace-only issue ID is rejected" " " "Add helper"

test_case "Trailing hyphen on issue ID does not produce a double hyphen" \
  "ven-15-add-helper" \
  VEN-15- "Add helper"

test_case "Issue ID '-n' is preserved and has no leading hyphen" \
  "n-add-helper" \
  -n "Add helper"

test_case "Title '-n' is preserved" \
  "ven-15-n" \
  VEN-15 -n

test_case "Newline in the title becomes a hyphen" \
  "abc-15-line1-line2" \
  ABC-15 $'line1\nline2'

test_case "Newline in the issue id becomes a hyphen" \
  "abc-15-add-helper" \
  $'ABC\n15' "Add helper"

test_case "Space in the issue id becomes a hyphen" \
  "abc-15-add-helper" \
  "ABC 15" "Add helper"

test_case "Tilde in the issue id becomes a hyphen" \
  "abc-1-x" \
  ABC~1 x

test_case "Dots in the issue id collapse to one hyphen" \
  "abc-1-x" \
  ABC..1 x

test_case "Slash in the issue id becomes a hyphen" \
  "abc-15-x" \
  ABC/15 x

echo "================================"
echo "Test Results"
echo "================================"
echo "Passed: $passed"
echo "Failed: $failed"
echo

if [ $failed -eq 0 ]; then
  echo "✓ All tests passed!"
  exit 0
else
  echo "✗ Some tests failed"
  exit 1
fi
