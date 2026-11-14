# ADR-0001: Use Bash for Test Framework with No Additional CI Dependencies

**Status:** Accepted

**Date:** 2026-11-14

**Issue:** [VEN-15: Add AGENTS.md, ADR-0001, and a tested branch-name helper](https://linear.app/venkateshpamarthi/issue/VEN-15/add-agentsmd-adr-0001-and-a-tested-branch-name-helper)

**Pull Request:** [#7: Add AGENTS.md, ADR-0001, and a tested branch-name helper](https://github.com/venkateshpamarthi/orbit-phase0-sandbox/pull/7)

## Context

The orbit-phase0-sandbox repository needed a branch name helper (`scripts/branch_name.sh`) with a test suite to establish testing conventions for Phase 2 development. The existing CI workflow runs on `ubuntu-latest` and currently only executes `./scripts/check.sh` with no additional package installations.

Key considerations:
- The repository is a personal Phase 0/2 sandbox with minimal dependencies
- CI already runs bash scripts without installing test frameworks
- The Phase 0 FAIL-file hook in `scripts/check.sh` should be preserved
- Workflow and job names must remain "ci" (required by branch protection)

## Decision

Implement the branch name helper and its test suite in bash with no additional CI dependencies.

Specifically:
- `scripts/branch_name.sh`: Pure bash implementation with no external dependencies
- `tests/branch_name_test.sh`: Bash test runner with simple assertion helpers
- `scripts/check.sh`: Updated to run the test suite while keeping the Phase 0 FAIL-file hook
- `.github/workflows/ci.yml`: No changes needed; continues to run `./scripts/check.sh`
- Workflow and job names remain "ci"

## Consequences

### Positive
- **Zero CI dependencies:** Tests run immediately on `ubuntu-latest` without package installation overhead
- **Simplicity:** Bash is already the lingua franca of the CI environment
- **Fast feedback:** No framework installation time added to CI runs
- **Consistency:** Aligns with existing `scripts/check.sh` pattern
- **Preservation:** Phase 0 FAIL-file hook remains intact as a documented feature

### Negative
- **Limited assertions:** Bash test assertions are simpler than specialized frameworks (e.g., bats, pytest, jest)
- **Verbosity:** Test output formatting is manual rather than framework-provided
- **Scalability:** May need a proper test framework when the test suite grows significantly

### Neutral
- This decision applies to the current minimal test suite; future test needs (e.g., integration tests, UI tests) may warrant additional tools
- The bash approach is revisable if testing requirements evolve beyond simple script validation

## Alternatives Considered

1. **bats (Bash Automated Testing System):**
   - Would require `npm install -g bats` or similar in CI
   - Adds dependency installation time and complexity
   - Rejected: overhead not justified for a simple helper script

2. **Python + pytest:**
   - Would require Python setup and `pip install pytest` in CI
   - Could shell out to bash script or reimplement in Python
   - Rejected: unnecessary runtime dependency

3. **Node.js + Jest:**
   - Would require Node.js setup and `npm install` in CI
   - Could shell out to bash script or reimplement in JavaScript
   - Rejected: unnecessary runtime dependency

## Notes

The test suite covers:
- Normal title formatting with spaces and case
- Invalid input rejection (missing issue ID, empty title)
- The exact branch name for VEN-15
- Six additional documented edge cases: punctuation, numbers, consecutive special characters, leading/trailing characters, special-character-only titles, and very long titles

The FAIL-file hook is preserved and documented in `scripts/check.sh` as a Phase 0 feature.
