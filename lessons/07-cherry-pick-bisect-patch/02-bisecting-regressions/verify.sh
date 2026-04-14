#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="02-bisecting-regressions"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 7/2"
    exit 1
fi

info "Verifying lesson: Bisecting Regressions"
separator

# Disable errexit for assertion blocks -- the lib's arithmetic increments
# can return a falsy exit code on the first call, which conflicts with set -e.
set +e

# 1. Must be on branch main
assert_on_branch "main" "$REPO"

# 2. Working tree must be clean
assert_clean_working_tree "$REPO"

# 3. No active bisect session
bisect_output=$(git -C "$REPO" bisect log 2>&1) || true
if echo "$bisect_output" | grep -q "status: waiting for"; then
    _fail "Bisect session is still active -- reset it with 'b' > 'reset bisect' in the Commits panel"
elif echo "$bisect_output" | grep -q "We are not bisecting"; then
    _pass "No active bisect session"
elif echo "$bisect_output" | grep -q "not bisecting"; then
    _pass "No active bisect session"
else
    # If bisect log succeeds without error, a bisect may be in progress.
    # Check for the BISECT_LOG file as a fallback.
    if [[ -f "$REPO/.git/BISECT_LOG" ]]; then
        _fail "Bisect session is still active -- reset it with 'b' > 'reset bisect' in the Commits panel"
    else
        _pass "No active bisect session"
    fi
fi

# 4. Tag 'bisect-found' must exist
tag_exists=$(git -C "$REPO" tag -l "bisect-found" 2>/dev/null)
if [[ -n "$tag_exists" ]]; then
    _pass "Tag 'bisect-found' exists"
else
    _fail "Tag 'bisect-found' not found -- after bisect identifies the culprit, tag it with 'T' and name it 'bisect-found'"
fi

# 5. 'bisect-found' must point to the same commit as 'the-bad-commit'
found_hash=$(git -C "$REPO" rev-parse "bisect-found^{commit}" 2>/dev/null) || true
expected_hash=$(git -C "$REPO" rev-parse "the-bad-commit^{commit}" 2>/dev/null) || true

if [[ -z "$found_hash" || -z "$expected_hash" ]]; then
    _fail "Could not resolve tag hashes for comparison"
elif [[ "$found_hash" == "$expected_hash" ]]; then
    _pass "Tag 'bisect-found' points to the correct culprit commit"
else
    short_found=$(git -C "$REPO" rev-parse --short "$found_hash" 2>/dev/null)
    short_expected=$(git -C "$REPO" rev-parse --short "$expected_hash" 2>/dev/null)
    _fail "Tag 'bisect-found' points to ${short_found} but the actual bad commit is ${short_expected}"
fi

verify_summary
