#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="03-stash-across-branches"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 6/3"
    exit 1
fi

info "Verifying lesson: Stash Across Branches"
separator

# Disable errexit for assertion blocks -- the lib's arithmetic increments
# can return a falsy exit code on the first call, which conflicts with set -e.
set +e

# 1. Branch feature/cache-layer must exist
assert_branch_exists "feature/cache-layer" "$REPO"

# 2. HEAD must be on feature/cache-layer
assert_on_branch "feature/cache-layer" "$REPO"

# 3. Working tree must be clean
assert_clean_working_tree "$REPO"

# 4. Stash must be empty
assert_stash_count 0 "$REPO"

# 5. Exactly 1 commit ahead of main (tagged as main-head during setup)
assert_commits_ahead "main-head" 1 "$REPO"

verify_summary
