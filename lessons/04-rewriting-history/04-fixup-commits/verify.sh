#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="04-fixup-commits"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 4/4"
    exit 1
fi

info "Verifying lesson: Fixup Commits"
separator

# Disable errexit for assertion blocks -- the lib's arithmetic increments
# can return a falsy exit code on the first call, which conflicts with set -e.
set +e

# 1. HEAD is on branch feature/auth-middleware
assert_on_branch "feature/auth-middleware" "$REPO"

# 2. Exactly 3 commits ahead of exercise-start (fixup was squashed in, total unchanged)
assert_commits_ahead "exercise-start" 3 "$REPO"

# 3. Working tree is clean (the fix was committed)
assert_clean_working_tree "$REPO"

# 4. The fix content is in the second commit (HEAD~1), not HEAD
#    Check that token.py at HEAD~1 contains the sanitization guard
SECOND_COMMIT_CONTENT=$(git -C "$REPO" show HEAD~1:services/api/src/token.py 2>/dev/null || echo "")
if echo "$SECOND_COMMIT_CONTENT" | grep -qF "invalid input"; then
    _pass "Fix content ('invalid input' guard) is present in the second commit (HEAD~1)"
else
    _fail "Fix content ('invalid input' guard) is NOT in the second commit (HEAD~1) -- the fixup was not squashed into the correct commit"
fi

# 5. No commit message contains "fixup!" (auto-squash completed)
FIXUP_COMMITS=$(git -C "$REPO" log exercise-start..HEAD --format="%s" | grep -c "fixup!" || true)
if [[ "$FIXUP_COMMITS" -eq 0 ]]; then
    _pass "No commit messages contain 'fixup!' (auto-squash completed)"
else
    _fail "Found ${FIXUP_COMMITS} commit(s) still containing 'fixup!' -- run auto-squash to fold them in"
fi

verify_summary
