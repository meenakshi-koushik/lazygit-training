#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../../../lib/common.sh"
source "$(dirname "$0")/../../../lib/verify.sh"

EXERCISE_NAME="02-status-panel-deep-dive"
REPO_PATH="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO_PATH" ]]; then
    error "Sandbox repo not found at ${REPO_PATH}"
    error "Run './train.sh start 01-orientation/02-status-panel-deep-dive' first."
    exit 1
fi

info "Verifying lesson: Status Panel Deep Dive"
separator

# Disable errexit for assertion functions (arithmetic increments return 1 when
# the previous value is 0, which is fine -- verify.sh handles its own exit flow).
set +e

# Objective 1: The learner checked out feature/auth-service (it should exist and
# be an ancestor of the current branch if they branched from it)
assert_branch_exists "feature/auth-service" "$REPO_PATH"

# Objective 2: The learner created a new branch called 'status-explored'
assert_branch_exists "status-explored" "$REPO_PATH"

# Objective 3: The learner should currently be on the 'status-explored' branch
assert_on_branch "status-explored" "$REPO_PATH"

# Objective 4: 'status-explored' should be based on 'feature/auth-service'
# (i.e., they share the same commit -- status-explored was created from feature/auth-service)
auth_tip=$(git -C "$REPO_PATH" rev-parse "feature/auth-service")
explored_merge_base=$(git -C "$REPO_PATH" merge-base "feature/auth-service" "status-explored")
if [[ "$auth_tip" == "$explored_merge_base" ]]; then
    _pass "Branch 'status-explored' is based on 'feature/auth-service'"
else
    _fail "Branch 'status-explored' does not appear to be based on 'feature/auth-service'"
fi

verify_summary
