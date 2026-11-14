#!/usr/bin/env bash
# CI check script: runs test suite and Phase 0 FAIL-file hook
set -euo pipefail

# Phase 0 hook: fail if a file named FAIL exists in the repo root
if [ -f FAIL ]; then
  echo "FAIL file present: failing on purpose"
  exit 1
fi

# Run test suite
echo "Running test suite..."
./tests/branch_name_test.sh
./tests/runner_exit_test.sh

echo
echo "All checks passed!"
