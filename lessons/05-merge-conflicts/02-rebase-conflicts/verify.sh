#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="02-rebase-conflicts"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 5/2"
    exit 1
fi

info "Verifying lesson: Rebase Conflicts"
separator

set +e

# 1. HEAD is on the feature branch
assert_on_branch "feature/worker-retry" "$REPO"

# 2. No unresolved conflicts
assert_no_conflicts "$REPO"

# 3. Working tree is clean
assert_clean_working_tree "$REPO"

# 4. NOT in the middle of a rebase
if [[ -d "$REPO/.git/rebase-merge" ]] || [[ -d "$REPO/.git/rebase-apply" ]]; then
    _fail "A rebase is still in progress -- continue or finish the rebase"
else
    _pass "No rebase in progress"
fi

# 5. History is linear (no merge commits in the feature branch)
merge_count=$(git -C "$REPO" rev-list --merges HEAD --count)
if [[ "$merge_count" -eq 0 ]]; then
    _pass "History is linear (no merge commits)"
else
    _fail "History contains merge commits -- you should have rebased, not merged"
fi

# 6. Feature branch is based on main (main is an ancestor of HEAD)
if git -C "$REPO" merge-base --is-ancestor main HEAD; then
    _pass "Feature branch is rebased on top of main"
else
    _fail "Feature branch is not based on main -- rebase onto main"
fi

# 7. The three feature commits are present
retry_config_commit=$(git -C "$REPO" log --oneline --grep="retry configuration" | head -1)
if [[ -n "$retry_config_commit" ]]; then
    _pass "Commit 'retry configuration' is present"
else
    _fail "Missing commit about retry configuration"
fi

retry_logic_commit=$(git -C "$REPO" log --oneline --grep="retry logic in job" | head -1)
if [[ -n "$retry_logic_commit" ]]; then
    _pass "Commit 'retry logic in job processor' is present"
else
    _fail "Missing commit about retry logic in job processor"
fi

test_commit=$(git -C "$REPO" log --oneline --grep="retry logic unit tests" | head -1)
if [[ -n "$test_commit" ]]; then
    _pass "Commit 'retry logic unit tests' is present"
else
    _fail "Missing commit about retry logic unit tests"
fi

# 8. config.py contains both retry and batch settings
assert_file_contains "$REPO/services/worker/src/config.py" "retry_count"
assert_file_contains "$REPO/services/worker/src/config.py" "batch_size"

# 9. No conflict markers in any tracked file
conflict_files=$(git -C "$REPO" grep -rl "^<<<<<<< " -- '*.py' '*.tf' '*.yaml' '*.yml' '*.md' 2>/dev/null || true)
if [[ -z "$conflict_files" ]]; then
    _pass "No conflict markers in tracked files"
else
    _fail "Conflict markers found in: ${conflict_files}"
fi

verify_summary
