#!/usr/bin/env bash
set -uo pipefail
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
suite="$repo_root/tests/branch_name_test.sh"
helper="$repo_root/scripts/branch_name.sh"
tmp="$(mktemp -d)"; trap 'rm -rf "$tmp"' EXIT
rc=0

# expect_fail <description> <stub>: the suite must exit non-zero against the stub.
expect_fail() {
  local out s
  out=$(BRANCH_NAME_SCRIPT="$2" "$suite" 2>&1); s=$?
  if [ $s -eq 0 ]; then
    echo "FAIL: suite exited 0 with $1"
    printf '%s\n' "$out" | tail -5; rc=1
  fi
}

# 1. Real helper: suite must exit 0.
if ! "$suite" >/dev/null 2>&1; then
  echo "FAIL: suite exits non-zero against the real helper"; rc=1
fi

# 2. Mixed, failing through the non-zero-exit branch (/bin/false passes only the rejection cases).
expect_fail "a mix of passes and failures (non-zero exit)" /bin/false

# 3. Mixed, failing through the wrong-output branch: real helper's exit status, wrong text.
printf '#!/usr/bin/env bash\nout=$("%s" "$@") || exit $?\nprintf "%%s-x\\n" "$out"\n' "$helper" > "$tmp/wrong_output"; chmod +x "$tmp/wrong_output"
expect_fail "a mix of passes and failures (wrong output, exit 0)" "$tmp/wrong_output"

# 4. Correct text written to stderr instead of stdout.
printf '#!/usr/bin/env bash\n"%s" "$@" >&2\n' "$helper" > "$tmp/stderr_only"; chmod +x "$tmp/stderr_only"
expect_fail "the branch name on stderr instead of stdout" "$tmp/stderr_only"

[ $rc -eq 0 ] && echo "PASS: runner exit status is correct for all-pass and mixed results"
exit $rc
