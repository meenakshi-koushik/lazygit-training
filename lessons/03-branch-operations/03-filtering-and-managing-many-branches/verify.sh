#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="03-filtering-and-managing-many-branches"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 3/3"
    exit 1
fi

info "Verifying lesson: Filtering and Managing Many Branches"
separator

# Disable errexit for assertion blocks -- the lib's arithmetic increments
# can return a falsy exit code on the first call, which conflicts with set -e.
set +e

# 1. Chore branches should be deleted
if git -C "$REPO" rev-parse --verify "refs/heads/chore/update-deps" &>/dev/null; then
    _fail "Branch 'chore/update-deps' still exists -- it should be deleted"
else
    _pass "Branch 'chore/update-deps' has been deleted"
fi

if git -C "$REPO" rev-parse --verify "refs/heads/chore/cleanup-logs" &>/dev/null; then
    _fail "Branch 'chore/cleanup-logs' still exists -- it should be deleted"
else
    _pass "Branch 'chore/cleanup-logs' has been deleted"
fi

if git -C "$REPO" rev-parse --verify "refs/heads/chore/ci-pipeline" &>/dev/null; then
    _fail "Branch 'chore/ci-pipeline' still exists -- it should be deleted"
else
    _pass "Branch 'chore/ci-pipeline' has been deleted"
fi

# 2. Important branches must still exist
assert_branch_exists "feature/dashboard-v2" "$REPO"
assert_branch_exists "hotfix/prod-crash" "$REPO"

# 3. HEAD should be on main
assert_on_branch "main" "$REPO"

verify_summary
