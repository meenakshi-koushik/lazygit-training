#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../../../lib/common.sh"
source "$(dirname "$0")/../../../lib/verify.sh"

EXERCISE_NAME="02-staging-lines"
REPO_PATH="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO_PATH" ]]; then
    error "Sandbox repo not found at ${REPO_PATH}"
    error "Run './train.sh start 02-precision-staging/02-staging-lines' first."
    exit 1
fi

info "Verifying lesson: Staging Individual Lines"
separator

# Disable errexit for assertion functions (arithmetic increments return 1 when
# the previous value is 0, which is fine -- verify.sh handles its own exit flow).
set +e

CONFIG_FILE="services/api/src/config.py"

# Objective 1: config.py has staged changes
assert_file_staged "$CONFIG_FILE" "$REPO_PATH"

# Objective 2: The staged version does NOT contain debug print statements
STAGED_CONTENT=$(git -C "$REPO_PATH" show ":${CONFIG_FILE}")
if echo "$STAGED_CONTENT" | grep -q 'print("DEBUG:'; then
    _fail "Staged version of '${CONFIG_FILE}' still contains debug print statements (they should not be staged)"
else
    _pass "Staged version of '${CONFIG_FILE}' does not contain debug print statements"
fi

# Objective 3: The working tree version still contains the debug print statements
if grep -q 'print("DEBUG:' "${REPO_PATH}/${CONFIG_FILE}"; then
    _pass "Working tree version of '${CONFIG_FILE}' still contains debug print statements (unstaged)"
else
    _fail "Working tree version of '${CONFIG_FILE}' does not contain debug print statements (they should remain as unstaged changes)"
fi

verify_summary
