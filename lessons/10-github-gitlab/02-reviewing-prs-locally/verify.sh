#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="02-reviewing-prs-locally"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 10/2"
    exit 1
fi

info "Verifying lesson: Reviewing PRs Locally"
separator

set +e

# 1. Must be back on main after review
assert_on_branch "main" "$REPO"

# 2. feature/metrics must exist locally (was checked out from remote)
assert_branch_exists "feature/metrics" "$REPO"

# 3. feature/metrics must track origin/feature/metrics
metrics_upstream=$(git -C "$REPO" for-each-ref --format='%(upstream:short)' refs/heads/feature/metrics 2>/dev/null || echo "")
if [[ "$metrics_upstream" == "origin/feature/metrics" ]]; then
    _pass "feature/metrics tracks origin/feature/metrics"
else
    _fail "feature/metrics does not track origin/feature/metrics (upstream: '${metrics_upstream}')"
fi

# 4. feature/metrics should have the expected metrics code
metrics_log=$(git -C "$REPO" log --oneline refs/heads/feature/metrics 2>/dev/null || echo "")
if echo "$metrics_log" | grep -q "metrics"; then
    _pass "feature/metrics has metrics-related commits"
else
    _fail "feature/metrics does not appear to have the expected commits"
fi

# 5. Working tree should be clean
assert_clean_working_tree "$REPO"

verify_summary
