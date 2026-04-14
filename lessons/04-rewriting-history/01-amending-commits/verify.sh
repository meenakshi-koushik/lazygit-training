#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="01-amending-commits"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 4/1"
    exit 1
fi

info "Verifying lesson: Amending Commits"
separator

# Disable errexit for assertion blocks -- the lib's arithmetic increments
# can return a falsy exit code on the first call, which conflicts with set -e.
set +e

# 1. HEAD is on the feature branch
assert_on_branch "feature/add-validation" "$REPO"

# 2. The latest commit message contains "validation" (correct spelling)
assert_commit_message_contains "HEAD" "validation" "$REPO"

# 3. The latest commit message does NOT contain the typo "validaton"
msg=$(git -C "$REPO" log -1 --format="%s" HEAD)
if [[ "$msg" == *"validaton"* ]]; then
    _fail "Commit message still contains the typo 'validaton' -- reword the commit to fix it"
else
    _pass "Commit message does not contain the typo 'validaton'"
fi

# 4. services/api/src/routes.py is included in the latest commit (not left unstaged)
if git -C "$REPO" diff-tree --no-commit-id --name-only -r HEAD | grep -qF "services/api/src/routes.py"; then
    _pass "File 'services/api/src/routes.py' is included in the latest commit"
else
    _fail "File 'services/api/src/routes.py' is not in the latest commit -- amend the commit to include it"
fi

# 5. Working tree is clean
assert_clean_working_tree "$REPO"

# 6. Exactly 1 commit ahead of exercise-start (amended, not a new commit)
assert_commits_ahead "exercise-start" 1 "$REPO"

verify_summary
