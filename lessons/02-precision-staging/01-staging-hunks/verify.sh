#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="01-staging-hunks"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 02-precision-staging/01-staging-hunks"
    exit 1
fi

info "Verifying lesson: Staging Individual Hunks"
separator

# Disable errexit for assertion blocks -- the lib's arithmetic increments
# can return a falsy exit code on the first call, which conflicts with set -e.
set +e

# 1. Check that services/api/src/routes.py has staged changes (is in the index)
assert_file_staged "services/api/src/routes.py" "$REPO"

# 2. Check that services/api/src/routes.py ALSO has unstaged changes
#    (the second hunk should still be in the working tree)
if git -C "$REPO" diff --name-only | grep -qF "services/api/src/routes.py"; then
    _pass "File 'services/api/src/routes.py' still has unstaged changes (second hunk)"
else
    _fail "File 'services/api/src/routes.py' has no unstaged changes -- you need to stage only ONE hunk, not the entire file"
fi

# 3. Check that services/worker/src/main.py is NOT staged
assert_file_not_staged "services/worker/src/main.py" "$REPO"

verify_summary
