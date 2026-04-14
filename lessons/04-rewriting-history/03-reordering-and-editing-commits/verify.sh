#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="03-reordering-and-editing-commits"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 4/3"
    exit 1
fi

info "Verifying lesson: Reordering and Editing Commits"
separator

# Disable errexit for assertion blocks -- the lib's arithmetic increments
# can return a falsy exit code on the first call, which conflicts with set -e.
set +e

# 1. Must be on the feature/caching branch
assert_on_branch "feature/caching" "$REPO"

# 2. Exactly 4 commits ahead of exercise-start
assert_commits_ahead "exercise-start" 4 "$REPO"

# 3. Oldest commit (4th from HEAD) should be the implementation commit
assert_commit_message_contains "HEAD~3" "implement cache layer" "$REPO"

# 4. 3rd from HEAD should be the test commit
assert_commit_message_contains "HEAD~2" "cache tests" "$REPO"

# 5. 2nd from HEAD should be cache invalidation
assert_commit_message_contains "HEAD~1" "cache invalidation" "$REPO"

# 6. HEAD (newest) should be the config commit
assert_commit_message_contains "HEAD" "config" "$REPO"

# 7. Working tree is clean
assert_clean_working_tree "$REPO"

verify_summary
