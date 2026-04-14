#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="01-branch-creation-and-switching"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 3/1"
    exit 1
fi

info "Verifying lesson: Branch Creation and Switching"
separator

# Disable errexit for assertion blocks -- the lib's arithmetic increments
# can return a falsy exit code on the first call, which conflicts with set -e.
set +e

# 1. Branch feature/search-api must exist
assert_branch_exists "feature/search-api" "$REPO"

# 2. Branch hotfix/config-typo must exist
assert_branch_exists "hotfix/config-typo" "$REPO"

# 3. feature/search-api must have at least 1 commit ahead of main
ahead=$(git -C "$REPO" rev-list --count "main..feature/search-api" 2>/dev/null || echo 0)
if [[ "$ahead" -ge 1 ]]; then
    _pass "Branch 'feature/search-api' has ${ahead} commit(s) ahead of main"
else
    _fail "Branch 'feature/search-api' has no commits ahead of main -- you need to make at least one commit on it"
fi

# 4. HEAD must be on hotfix/config-typo
assert_on_branch "hotfix/config-typo" "$REPO"

verify_summary
