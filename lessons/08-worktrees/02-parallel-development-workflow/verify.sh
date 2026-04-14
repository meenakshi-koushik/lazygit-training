#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="02-parallel-development-workflow"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"
REVIEW_WORKTREE="${SANDBOX_DIR}/02-parallel-development-workflow-review"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 8/2"
    exit 1
fi

info "Verifying lesson: Parallel Development Workflow"
separator

# Disable errexit for assertion blocks -- the lib's arithmetic increments
# can return a falsy exit code on the first call, which conflicts with set -e.
set +e

# 1. Main worktree must be on feature/api-refactor
assert_on_branch "feature/api-refactor" "$REPO"

# 2. Main worktree must have uncommitted changes (WIP preserved)
assert_has_unstaged_changes "$REPO"

# 3. Review worktree directory must exist
if [[ -d "$REVIEW_WORKTREE" ]]; then
    _pass "Review worktree directory exists"
else
    _fail "Review worktree directory not found at ${REVIEW_WORKTREE}"
fi

# 4. Review worktree must be on feature/review-target
assert_on_branch "feature/review-target" "$REVIEW_WORKTREE"

# 5. Review worktree must have a clean working tree
assert_clean_working_tree "$REVIEW_WORKTREE"

# 6. The TODO must be resolved in the review worktree
assert_file_not_contains \
    "$REVIEW_WORKTREE/services/api/src/validation.py" \
    "TODO: add input length check"

# 7. The fix must include an actual length check
assert_file_contains \
    "$REVIEW_WORKTREE/services/api/src/validation.py" \
    "len("

# 8. The fix commit message must contain "fix" and "validation"
# CRITICAL: capture git output in a variable first, then grep -- never pipe
# git directly to grep -q, as SIGPIPE + pipefail causes spurious failures.
log_output=$(git -C "$REVIEW_WORKTREE" log --format="%s" 2>/dev/null)
fix_found=false
if echo "$log_output" | grep -qi "fix"; then
    if echo "$log_output" | grep -qi "validation"; then
        fix_found=true
    fi
fi
if [[ "$fix_found" == "true" ]]; then
    _pass "Fix commit message contains 'fix' and 'validation'"
else
    _fail "No commit message found containing both 'fix' and 'validation' -- did you commit the fix?"
fi

# 9. Review branch must have at least 1 commit beyond the setup tag
commit_count_ahead=$(git -C "$REVIEW_WORKTREE" rev-list --count "review-target-setup..HEAD" 2>/dev/null)
if [[ "$commit_count_ahead" -ge 1 ]]; then
    _pass "Review branch has ${commit_count_ahead} new commit(s) since setup"
else
    _fail "Review branch has no new commits since setup -- did you commit the fix?"
fi

verify_summary
