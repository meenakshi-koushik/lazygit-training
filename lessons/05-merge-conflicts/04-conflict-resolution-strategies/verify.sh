#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="04-conflict-resolution-strategies"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 5/4"
    exit 1
fi

info "Verifying lesson: Conflict Resolution Strategies"
separator

set +e

# 1. HEAD is on the feature branch
assert_on_branch "feature/oauth-upgrade" "$REPO"

# 2. No unresolved conflicts
assert_no_conflicts "$REPO"

# 3. Working tree is clean
assert_clean_working_tree "$REPO"

# 4. HEAD is a merge commit
parent_count=$(git -C "$REPO" cat-file -p HEAD | grep -c "^parent")
if [[ "$parent_count" -ge 2 ]]; then
    _pass "HEAD is a merge commit (${parent_count} parents)"
else
    _fail "HEAD is not a merge commit -- did you complete the merge?"
fi

# 5. config.py has OAuth settings (ours)
assert_file_contains "$REPO/services/auth/src/config.py" "oauth_provider"

# 6. config.py does NOT have SAML settings (theirs)
assert_file_not_contains "$REPO/services/auth/src/config.py" "saml_idp_url"

# 7. routes.py has OAuth routes (ours)
assert_file_contains "$REPO/services/auth/src/routes.py" "/auth/login"

# 8. routes.py does NOT have SAML routes (theirs)
assert_file_not_contains "$REPO/services/auth/src/routes.py" "/auth/saml/login"

# 9. Makefile has auth-test (ours)
assert_file_contains "$REPO/Makefile" "auth-test"

# 10. Makefile does NOT have security-scan (theirs)
assert_file_not_contains "$REPO/Makefile" "security-scan"

# 11. No conflict markers
conflict_files=$(git -C "$REPO" grep -rl "^<<<<<<< " -- '*.py' '*.tf' '*.yaml' '*.yml' '*.md' 'Makefile' 2>/dev/null || true)
if [[ -z "$conflict_files" ]]; then
    _pass "No conflict markers in tracked files"
else
    _fail "Conflict markers found in: ${conflict_files}"
fi

verify_summary
