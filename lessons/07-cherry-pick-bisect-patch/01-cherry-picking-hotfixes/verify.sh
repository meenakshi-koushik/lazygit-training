#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="01-cherry-picking-hotfixes"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 7/1"
    exit 1
fi

info "Verifying lesson: Cherry-picking Hotfixes"
separator

# Disable errexit for assertion blocks -- the lib's arithmetic increments
# can return a falsy exit code on the first call, which conflicts with set -e.
set +e

# 1. Must be on feature/payments
assert_on_branch "feature/payments" "$REPO"

# 2. Working tree must be clean
assert_clean_working_tree "$REPO"

# 3. The cherry-picked commit message must appear in the branch history
# CRITICAL: capture git output in a variable first, then grep -- never pipe
# git directly to grep -q, as SIGPIPE + pipefail causes spurious failures.
log_output=$(git -C "$REPO" log --format="%s" 2>/dev/null)
if echo "$log_output" | grep -q "patch null pointer in cache lookup"; then
    _pass "Cherry-picked commit found in branch history"
else
    _fail "Commit with message 'fix(common): patch null pointer in cache lookup' not found on feature/payments -- did you cherry-pick it?"
fi

# 4. The fix content must be present in the file
assert_file_contains "$REPO/libs/common/src/common.py" "if key is None"

# 5. The cherry-picked commit should be a new commit (different SHA from the
#    original on main), confirming it was cherry-picked, not merged.
original_sha=$(git -C "$REPO" rev-parse bugfix-tag 2>/dev/null)
cherry_log=$(git -C "$REPO" log --format="%H %s" 2>/dev/null)
cherry_sha=$(echo "$cherry_log" | grep "patch null pointer in cache lookup" | head -1 | cut -d' ' -f1)

if [[ -n "$cherry_sha" && "$cherry_sha" != "$original_sha" ]]; then
    _pass "Cherry-picked commit has a new SHA (not a merge)"
else
    _fail "Expected a cherry-picked commit (new SHA), but the commit SHA matches the original on main -- did you merge instead?"
fi

# 6. The original feature branch commits should still be present
feature_log=$(git -C "$REPO" log --format="%s" 2>/dev/null)
if echo "$feature_log" | grep -q "feat(api): add payment routes skeleton"; then
    _pass "Original feature branch commits are intact"
else
    _fail "Original feature branch commits are missing -- something went wrong"
fi

verify_summary
