#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="01-basic-stash-operations"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 6/1"
    exit 1
fi

info "Verifying lesson: Basic Stash Operations"
separator

# Disable errexit for assertion blocks -- the lib's arithmetic increments
# can return a falsy exit code on the first call, which conflicts with set -e.
set +e

# 1. Must be on feature/user-profiles
assert_on_branch "feature/user-profiles" "$REPO"

# 2. Reflog must show the learner actually checked out main (evidence of the workflow)
reflog_output=$(git -C "$REPO" reflog --format="%gs" 2>/dev/null)
if echo "$reflog_output" | grep -q "checkout: moving from .* to main"; then
    _pass "Reflog shows checkout to 'main' (stash-switch workflow was performed)"
else
    _fail "No evidence of switching to 'main' -- you need to stash, switch to main, switch back, and pop"
fi

# 3. Working tree must have unstaged changes (the restored modifications)
assert_has_unstaged_changes "$REPO"

# 4. The three modified files should contain the WIP content
assert_file_contains "$REPO/services/api/config/settings.yaml" "max_avatar_size_mb"
assert_file_contains "$REPO/services/api/src/profiles.py" "create_profile"
assert_file_contains "$REPO/services/api/tests/test_routes.py" "test_get_profile"

# 5. Stash list must be empty (changes were popped, not just applied)
assert_stash_count 0 "$REPO"

verify_summary
