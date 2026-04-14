#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="01-creating-worktrees"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"
WORKTREE_DIR="${SANDBOX_DIR}/${EXERCISE_NAME}-dashboard"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 8/1"
    exit 1
fi

info "Verifying lesson: Creating Worktrees"
separator

# Disable errexit for assertion blocks -- the lib's arithmetic increments
# can return a falsy exit code on the first call, which conflicts with set -e.
set +e

# 1. Must be on feature/auth in the main worktree
assert_on_branch "feature/auth" "$REPO"

# 2. Working tree must have uncommitted changes (WIP preserved)
assert_has_unstaged_changes "$REPO"

# 3. The WIP content must still be present in the modified files
assert_file_contains "$REPO/services/api/src/auth.py" "refresh_token"
assert_file_contains "$REPO/services/api/src/routes.py" "integrating auth middleware"

# 4. git worktree list must show 2 worktrees
# CRITICAL: capture git output in a variable first, then grep -- never pipe
# git directly to grep -q, as SIGPIPE + pipefail causes spurious failures.
worktree_output=$(git -C "$REPO" worktree list 2>/dev/null)
worktree_count=$(echo "$worktree_output" | wc -l)
if [[ "$worktree_count" -ge 2 ]]; then
    _pass "git worktree list shows ${worktree_count} worktrees"
else
    _fail "Expected at least 2 worktrees but found ${worktree_count} -- did you create a worktree?"
fi

# 5. The dashboard worktree directory must exist
if [[ -d "$WORKTREE_DIR" ]]; then
    _pass "Worktree directory exists at ${WORKTREE_DIR}"
else
    _fail "Worktree directory not found at ${WORKTREE_DIR} -- the path should be ../01-creating-worktrees-dashboard (relative to the sandbox repo)"
fi

# 6. The dashboard worktree must be on branch feature/dashboard
if [[ -d "$WORKTREE_DIR" ]]; then
    wt_branch=$(git -C "$WORKTREE_DIR" symbolic-ref --short HEAD 2>/dev/null)
    if [[ "$wt_branch" == "feature/dashboard" ]]; then
        _pass "Dashboard worktree is on branch 'feature/dashboard'"
    else
        _fail "Dashboard worktree is on branch '${wt_branch}' -- expected 'feature/dashboard'"
    fi
else
    _fail "Cannot check dashboard worktree branch -- directory does not exist"
fi

verify_summary
