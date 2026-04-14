#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="03-ci-status-and-pr-workflows"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 10/3"
    exit 1
fi

info "Verifying lesson: CI Status and PR Workflows"
separator

set +e

# 1. Must be on feature/logging
assert_on_branch "feature/logging" "$REPO"

# 2. Fetch must have happened -- origin/main should have the teammate commits
origin_main_msg=$(git -C "$REPO" log -1 --format="%s" refs/remotes/origin/main 2>/dev/null || echo "")
if [[ "$origin_main_msg" == *"retry"* || "$origin_main_msg" == *"backoff"* ]]; then
    _pass "Fetch completed -- origin/main has the latest commits"
else
    _fail "origin/main does not have the latest commits -- did you fetch? (press 'f' in Files panel)"
fi

# 3. Local main must match origin/main (fast-forwarded)
local_main=$(git -C "$REPO" rev-parse refs/heads/main 2>/dev/null || echo "none")
origin_main=$(git -C "$REPO" rev-parse refs/remotes/origin/main 2>/dev/null || echo "unknown")

if [[ "$local_main" == "$origin_main" ]]; then
    _pass "Local main is up-to-date with origin/main"
else
    _fail "Local main does not match origin/main -- fast-forward it (select main, press 'f')"
fi

# 4. feature/logging must be rebased on top of the latest main
# The logging commits should be on top of (i.e., descendants of) the latest main
latest_main=$(git -C "$REPO" rev-parse refs/heads/main 2>/dev/null || echo "none")
merge_base=$(git -C "$REPO" merge-base refs/heads/feature/logging refs/heads/main 2>/dev/null || echo "unknown")

if [[ "$merge_base" == "$latest_main" ]]; then
    _pass "feature/logging is rebased on top of the latest main"
else
    _fail "feature/logging is not rebased on the latest main -- rebase it (in Branches panel, select main, press 'r')"
fi

# 5. Should still have 2 logging commits ahead of main
commits_ahead=$(git -C "$REPO" rev-list --count "main..feature/logging" 2>/dev/null || echo "0")
if [[ "$commits_ahead" -eq 2 ]]; then
    _pass "2 commits ahead of main (logging commits preserved)"
else
    _fail "Expected 2 commits ahead of main but found ${commits_ahead}"
fi

# 6. Force-push must have succeeded
local_logging=$(git -C "$REPO" rev-parse refs/heads/feature/logging 2>/dev/null || echo "none")
origin_logging=$(git -C "$REPO" rev-parse refs/remotes/origin/feature/logging 2>/dev/null || echo "unknown")

if [[ "$local_logging" == "$origin_logging" ]]; then
    _pass "origin/feature/logging matches local (force-push succeeded)"
else
    _fail "origin/feature/logging does not match local -- force-push needed (press 'P', confirm force-push)"
fi

# 7. Working tree should be clean
assert_clean_working_tree "$REPO"

verify_summary
