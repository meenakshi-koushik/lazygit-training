#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../../../lib/common.sh"
source "$(dirname "$0")/../../../lib/verify.sh"

EXERCISE_NAME="03-configuration-basics"
REPO_PATH="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO_PATH" ]]; then
    error "Sandbox repo not found at ${REPO_PATH}. Run setup first."
    exit 1
fi

separator
info "Verifying: Configuration Basics"
separator

# Check 1: A commit exists with "config" in the message
if git -C "$REPO_PATH" log --all --oneline --grep="config" | grep -qi "config"; then
    _pass "Found a commit with 'config' in the message"
else
    _fail "No commit found with 'config' in the message -- make a commit with 'config' in the message after exploring"
fi

# Check 2: Working tree is clean
assert_clean_working_tree "$REPO_PATH"

verify_summary
