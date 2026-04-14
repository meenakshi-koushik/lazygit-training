#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="01-creating-prs-from-lazygit"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 10/1"
    exit 1
fi

info "Verifying lesson: Creating PRs from Lazygit"
separator

set +e

# 1. Must be on feature/rate-limiter
assert_on_branch "feature/rate-limiter" "$REPO"

# 2. Should have exactly 1 commit ahead of main (squashed)
commits_ahead=$(git -C "$REPO" rev-list --count "main..feature/rate-limiter" 2>/dev/null || echo "0")
if [[ "$commits_ahead" -eq 1 ]]; then
    _pass "Exactly 1 commit ahead of main (squashed)"
else
    _fail "Expected 1 commit ahead of main but found ${commits_ahead} -- squash all WIP commits into one"
fi

# 3. Commit message should start with feat(api):
head_msg=$(git -C "$REPO" log -1 --format="%s" HEAD 2>/dev/null || echo "")
if [[ "$head_msg" == feat\(api\):* ]]; then
    _pass "Commit message starts with 'feat(api):'"
else
    _fail "Commit message should start with 'feat(api):' but got: '${head_msg}'"
fi

# 4. Commit message should not contain WIP
if [[ "$head_msg" == *"WIP"* || "$head_msg" == *"wip"* ]]; then
    _fail "Commit message still contains 'WIP' -- reword it to a clean description"
else
    _pass "Commit message does not contain 'WIP'"
fi

# 5. The rate limiter code should still be present
assert_file_contains "$REPO/services/api/src/rate_limiter.py" "RateLimiter"
assert_file_contains "$REPO/services/api/src/rate_limiter.py" "is_allowed"

# 6. Tests should still be present
assert_file_contains "$REPO/services/api/tests/test_rate_limiter.py" "test_blocks_over_limit"

# 7. Branch must be pushed to origin
origin_rl=$(git -C "$REPO" rev-parse refs/remotes/origin/feature/rate-limiter 2>/dev/null || echo "none")
local_rl=$(git -C "$REPO" rev-parse refs/heads/feature/rate-limiter 2>/dev/null || echo "unknown")

if [[ "$origin_rl" == "none" ]]; then
    _fail "feature/rate-limiter has not been pushed to origin -- press 'P' to push"
elif [[ "$origin_rl" == "$local_rl" ]]; then
    _pass "feature/rate-limiter is pushed to origin"
else
    _fail "origin/feature/rate-limiter does not match local -- push again after squashing"
fi

# 8. Working tree should be clean
assert_clean_working_tree "$REPO"

verify_summary
