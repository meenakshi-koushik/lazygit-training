#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="01-fetch-pull-push-patterns"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 9/1"
    exit 1
fi

info "Verifying lesson: Fetch, Pull, Push Patterns"
separator

set +e

# 1. Must still be on feature/notifications
assert_on_branch "feature/notifications" "$REPO"

# 2. Check that fetch has happened -- origin/main should have the teammate commits.
# The teammate's last commit message contains "graceful shutdown".
# Before fetching, origin/main still points to the stale clone-time state.
origin_main_msg=$(git -C "$REPO" log -1 --format="%s" refs/remotes/origin/main 2>/dev/null || echo "")
if [[ "$origin_main_msg" == *"worker"* || "$origin_main_msg" == *"SIGTERM"* || "$origin_main_msg" == *"graceful shutdown"* ]]; then
    _pass "Fetch completed -- origin/main has the latest teammate commits"
else
    _fail "origin/main does not have the expected teammate commits -- did you fetch? (press 'f' in Files panel)"
fi

# 3. Local main must be up-to-date with origin/main (fast-forwarded)
# After fetching, origin/main is updated. Local main must be advanced to match.
local_main=$(git -C "$REPO" rev-parse refs/heads/main 2>/dev/null || echo "none")
origin_main=$(git -C "$REPO" rev-parse refs/remotes/origin/main 2>/dev/null || echo "unknown")

if [[ "$origin_main" == "unknown" ]]; then
    _fail "origin/main not found -- have you fetched from origin?"
elif [[ "$local_main" == "$origin_main" ]]; then
    _pass "Local main is up-to-date with origin/main"
else
    _fail "Local main is not at the same commit as origin/main -- fast-forward main (select main in Branches panel, press 'f')"
fi

# 4. feature/notifications must be pushed to origin
origin_notif=$(git -C "$REPO" rev-parse refs/remotes/origin/feature/notifications 2>/dev/null || echo "none")
local_notif=$(git -C "$REPO" rev-parse refs/heads/feature/notifications 2>/dev/null || echo "unknown")

if [[ "$origin_notif" == "none" ]]; then
    _fail "feature/notifications has not been pushed to origin (press 'P' to push)"
elif [[ "$origin_notif" == "$local_notif" ]]; then
    _pass "feature/notifications is pushed to origin and up-to-date"
else
    _fail "feature/notifications on origin doesn't match local -- push may have failed"
fi

# 5. Working tree should be clean
assert_clean_working_tree "$REPO"

verify_summary
