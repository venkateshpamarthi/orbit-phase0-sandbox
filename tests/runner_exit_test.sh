#!/usr/bin/env bash
set -uo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
stub="$(mktemp)"; trap 'rm -f "$stub"' EXIT
printf '#!/usr/bin/env bash\necho wrong\n' > "$stub"; chmod +x "$stub"
if BRANCH_NAME_SCRIPT="$stub" "$repo_root/tests/branch_name_test.sh" >/dev/null 2>&1; then
  echo "FAIL: suite exited 0 with failing tests"; exit 1
fi
echo "PASS: suite exits non-zero when tests fail"
