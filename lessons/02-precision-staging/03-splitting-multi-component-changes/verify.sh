#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../../../lib/common.sh"
source "$(dirname "$0")/../../../lib/verify.sh"

EXERCISE_NAME="03-splitting-multi-component-changes"
REPO_PATH="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO_PATH" ]]; then
    error "Sandbox repo not found at ${REPO_PATH}"
    error "Run './train.sh start 02-precision-staging/03-splitting-multi-component-changes' first."
    exit 1
fi

info "Verifying lesson: Splitting Multi-Component Changes"
separator

# Disable errexit for assertion functions (arithmetic increments return 1 when
# the previous value is 0, which is fine -- verify.sh handles its own exit flow).
set +e

# 1. Working tree must be clean -- all changes committed
assert_clean_working_tree "$REPO_PATH"

# 2. Exactly 3 new commits since the exercise-start tag
assert_commits_ahead "exercise-start" 3 "$REPO_PATH"

# 3. One commit message must contain "api"
api_match=$(git -C "$REPO_PATH" log exercise-start..HEAD --format="%s" | grep -ci "api" || true)
if [[ "$api_match" -ge 1 ]]; then
    _pass "At least one commit message contains 'api'"
else
    _fail "No commit message contains 'api' -- one commit should cover the api service changes"
fi

# 4. One commit message must contain "worker"
worker_match=$(git -C "$REPO_PATH" log exercise-start..HEAD --format="%s" | grep -ci "worker" || true)
if [[ "$worker_match" -ge 1 ]]; then
    _pass "At least one commit message contains 'worker'"
else
    _fail "No commit message contains 'worker' -- one commit should cover the worker service changes"
fi

# 5. One commit message must contain "common" or "libs"
common_match=$(git -C "$REPO_PATH" log exercise-start..HEAD --format="%s" | grep -ciE "common|libs" || true)
if [[ "$common_match" -ge 1 ]]; then
    _pass "At least one commit message contains 'common' or 'libs'"
else
    _fail "No commit message contains 'common' or 'libs' -- one commit should cover the shared library changes"
fi

verify_summary
