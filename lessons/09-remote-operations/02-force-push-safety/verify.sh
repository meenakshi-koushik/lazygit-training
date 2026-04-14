#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="02-force-push-safety"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 9/2"
    exit 1
fi

info "Verifying lesson: Force-Push Safety"
separator

set +e

# 1. Must be on feature/billing
assert_on_branch "feature/billing" "$REPO"

# 2. The local branch should have the squashed commit (not the WIP commits)
head_msg=$(git -C "$REPO" log -1 --format="%s" HEAD 2>/dev/null || echo "")
if [[ "$head_msg" == *"feat(billing)"* || "$head_msg" == *"billing service"* ]]; then
    _pass "HEAD commit is the squashed billing commit"
else
    _fail "HEAD commit message doesn't look right: '${head_msg}'"
fi

# 3. The force-push must have succeeded -- origin/feature/billing should match local
local_billing=$(git -C "$REPO" rev-parse refs/heads/feature/billing 2>/dev/null || echo "none")
origin_billing=$(git -C "$REPO" rev-parse refs/remotes/origin/feature/billing 2>/dev/null || echo "unknown")

if [[ "$origin_billing" == "unknown" ]]; then
    _fail "origin/feature/billing not found -- something went wrong"
elif [[ "$local_billing" == "$origin_billing" ]]; then
    _pass "origin/feature/billing matches local (force-push succeeded)"
else
    _fail "origin/feature/billing does not match local -- have you force-pushed? (press 'P', then confirm force-push)"
fi

# 4. origin/feature/billing should NOT have the old WIP commits
# Check that the remote only has 1 commit ahead of main (the squashed one)
origin_ahead=$(git -C "$REPO" rev-list --count "refs/remotes/origin/main..refs/remotes/origin/feature/billing" 2>/dev/null || echo "0")
if [[ "$origin_ahead" -eq 1 ]]; then
    _pass "Origin has 1 commit ahead of main (WIP history replaced)"
else
    _fail "Expected 1 commit ahead of main on origin but found ${origin_ahead} -- the old WIP commits may still be there"
fi

# 5. Working tree should be clean
assert_clean_working_tree "$REPO"

verify_summary
