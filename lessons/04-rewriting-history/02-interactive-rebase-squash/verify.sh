#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="02-interactive-rebase-squash"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 4/2"
    exit 1
fi

info "Verifying lesson: Interactive Rebase -- Squashing Commits"
separator

# Disable errexit for assertion blocks -- the lib's arithmetic increments
# can return a falsy exit code on the first call, which conflicts with set -e.
set +e

# 1. Must be on the feature branch
assert_on_branch "feature/rate-limiting" "$REPO"

# 2. Exactly 2 commits ahead of the exercise-start tag (squashed from 5 to 2)
assert_commits_ahead "exercise-start" 2 "$REPO"

# 3. No commit message on the branch should contain messy WIP-style text
branch_messages=$(git -C "$REPO" log exercise-start..HEAD --format="%s")

if echo "$branch_messages" | grep -iq "WIP"; then
    _fail "Found a commit message containing 'WIP' -- all messy messages should be reworded"
else
    _pass "No commit messages contain 'WIP'"
fi

if echo "$branch_messages" | grep -iq "oops"; then
    _fail "Found a commit message containing 'oops' -- all messy messages should be reworded"
else
    _pass "No commit messages contain 'oops'"
fi

if echo "$branch_messages" | grep -iq "typo"; then
    _fail "Found a commit message containing 'typo' -- all messy messages should be reworded"
else
    _pass "No commit messages contain 'typo'"
fi

# 4. Content was preserved through the squash
assert_file_exists "$REPO/services/api/src/rate_limiter.py"
assert_file_exists "$REPO/services/api/tests/test_rate_limiter.py"

# 5. Working tree is clean
assert_clean_working_tree "$REPO"

verify_summary
