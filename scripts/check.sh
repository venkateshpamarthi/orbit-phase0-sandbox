#!/usr/bin/env bash
# Phase 0 CI check: fails if a file named FAIL exists in the repo root.
set -euo pipefail
if [ -f FAIL ]; then
  echo "FAIL file present: failing on purpose"
  exit 1
fi
echo "check passed"
