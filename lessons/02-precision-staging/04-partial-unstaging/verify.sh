#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="04-partial-unstaging"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 02-precision-staging/04-partial-unstaging"
    exit 1
fi

info "Verifying lesson: Partial Unstaging"
separator

# Disable errexit for assertion blocks -- the lib's arithmetic increments
# can return a falsy exit code on the first call, which conflicts with set -e.
set +e

# 1. Check that API files are still staged
assert_file_staged "services/api/src/routes.py" "$REPO"
assert_file_staged "services/api/src/config.py" "$REPO"
assert_file_staged "services/api/tests/test_routes.py" "$REPO"

# 2. Check that worker files are NOT staged
assert_file_not_staged "services/worker/src/main.py" "$REPO"
assert_file_not_staged "services/worker/src/config.py" "$REPO"

# 3. Check that worker files still have modifications in the working tree
#    (changes were unstaged, not discarded)
if git -C "$REPO" diff --name-only | grep -q "services/worker/src/main.py"; then
    _pass "Worker main.py has unstaged modifications (changes preserved)"
else
    _fail "Worker main.py has no unstaged modifications -- changes may have been lost"
fi

if git -C "$REPO" diff --name-only | grep -q "services/worker/src/config.py"; then
    _pass "Worker config.py has unstaged modifications (changes preserved)"
else
    _fail "Worker config.py has no unstaged modifications -- changes may have been lost"
fi

verify_summary
