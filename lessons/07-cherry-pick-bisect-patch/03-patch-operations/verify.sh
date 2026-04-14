#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="03-patch-operations"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 7/3"
    exit 1
fi

info "Verifying lesson: Patch Operations"
separator

# Disable errexit for assertion blocks -- the lib's arithmetic increments
# can return a falsy exit code on the first call, which conflicts with set -e.
set +e

# 1. Must be on feature/logging
assert_on_branch "feature/logging" "$REPO"

# 2. Clean working tree
assert_clean_working_tree "$REPO"

# 3. Logging changes should be present in routes.py
routes_content=$(cat "$REPO/services/api/src/routes.py" 2>/dev/null || echo "")
if echo "$routes_content" | grep -q "logger\|logging"; then
    _pass "services/api/src/routes.py contains logging"
else
    _fail "services/api/src/routes.py does not contain logging -- did you apply the patch?"
fi

# 4. Logging changes should be present in worker/main.py
worker_content=$(cat "$REPO/services/worker/src/main.py" 2>/dev/null || echo "")
if echo "$worker_content" | grep -q "logger\|logging"; then
    _pass "services/worker/src/main.py contains logging"
else
    _fail "services/worker/src/main.py does not contain logging -- did you apply the patch?"
fi

# 5. Logging changes should be present in common.py
common_content=$(cat "$REPO/libs/common/src/common.py" 2>/dev/null || echo "")
if echo "$common_content" | grep -q "logger\|logging"; then
    _pass "libs/common/src/common.py contains logging"
else
    _fail "libs/common/src/common.py does not contain logging -- did you apply the patch?"
fi

# 6. Config-only changes should NOT be present
#    The refactored config has a REFACTORED_CONFIG_V2 marker and from_env classmethod
config_content=$(cat "$REPO/services/api/src/config.py" 2>/dev/null || echo "")
if echo "$config_content" | grep -q "REFACTORED_CONFIG_V2"; then
    _fail "services/api/src/config.py contains refactored config -- you included a file you should have skipped"
else
    _pass "services/api/src/config.py does not contain unwanted config changes"
fi

# 7. Test changes should NOT be present
test_content=$(cat "$REPO/services/api/tests/test_routes.py" 2>/dev/null || echo "")
if echo "$test_content" | grep -q "test_settings_from_env\|Settings\.from_env"; then
    _fail "services/api/tests/test_routes.py contains unwanted test changes -- you included a file you should have skipped"
else
    _pass "services/api/tests/test_routes.py does not contain unwanted test changes"
fi

# 8. Exactly 1 commit ahead of the starting point
assert_commits_ahead "logging-start" 1 "$REPO"

verify_summary
