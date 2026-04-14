#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="02-comparing-branches"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 3/2"
    exit 1
fi

info "Verifying lesson: Comparing Branches"
separator

# Disable errexit for assertion blocks -- the lib's arithmetic increments
# can return a falsy exit code on the first call, which conflicts with set -e.
set +e

# 1. HEAD is on branch feature/api-refactor
assert_on_branch "feature/api-refactor" "$REPO"

# 2. The branch has been rebased onto main (main is an ancestor of feature/api-refactor)
if git -C "$REPO" merge-base --is-ancestor main feature/api-refactor; then
    _pass "Branch 'feature/api-refactor' has been rebased onto 'main'"
else
    _fail "Branch 'feature/api-refactor' has NOT been rebased onto 'main' -- 'main' is not an ancestor"
fi

# 3. No merge conflicts remain
assert_no_conflicts "$REPO"

# 4. Working tree is clean
assert_clean_working_tree "$REPO"

verify_summary
