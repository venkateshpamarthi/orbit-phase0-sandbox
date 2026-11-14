#!/usr/bin/env bash
set -uo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
suite="$repo_root/tests/branch_name_test.sh"
rc=0

# 1. Real helper: suite must exit 0.
if ! "$suite" >/dev/null 2>&1; then
  echo "FAIL: suite exits non-zero against the real helper"; rc=1
fi

# 2. Mixed pass/fail (/bin/false passes the rejection cases, fails the rest): must exit non-zero.
out=$(BRANCH_NAME_SCRIPT=/bin/false "$suite" 2>&1); s=$?
if [ $s -eq 0 ]; then
  echo "FAIL: suite exited 0 with a mix of passes and failures"
  printf '%s\n' "$out" | tail -5; rc=1
fi

[ $rc -eq 0 ] && echo "PASS: runner exit status is correct for all-pass and mixed results"
exit $rc
