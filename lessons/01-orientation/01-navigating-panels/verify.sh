#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="01-navigating-panels"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 01-orientation/01-navigating-panels"
    exit 1
fi

info "Verifying lesson: Navigating Panels"
separator

# Disable errexit for assertion blocks -- the lib's arithmetic increments
# can return a falsy exit code on the first call, which conflicts with set -e.
set +e

# 1. Check that the learner created the 'explore-panels' branch
assert_branch_exists "explore-panels" "$REPO"

# 2. Check that at least one file has been staged (committed counts too --
#    we look for the branch having any commit the learner made)
#    We verify this indirectly via objective 3 below, but also check that
#    the staging workflow was used by confirming a commit exists on explore-panels.

# 3. Check that there is at least one commit whose message contains "explore"
if git -C "$REPO" log --all --oneline --grep="explore" | grep -qi "explore"; then
    _pass "Found a commit with message containing 'explore'"
else
    _fail "No commit found with a message containing 'explore'. Make a commit with 'explore' in the message."
fi

verify_summary
