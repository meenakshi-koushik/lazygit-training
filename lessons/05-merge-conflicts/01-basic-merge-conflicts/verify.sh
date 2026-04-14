#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="01-basic-merge-conflicts"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 5/1"
    exit 1
fi

info "Verifying lesson: Basic Merge Conflicts"
separator

set +e

# 1. HEAD is on the feature branch
assert_on_branch "feature/api-health-check" "$REPO"

# 2. No unresolved merge conflicts
assert_no_conflicts "$REPO"

# 3. Working tree is clean
assert_clean_working_tree "$REPO"

# 4. The latest commit is a merge commit (has two parents)
parent_count=$(git -C "$REPO" cat-file -p HEAD | grep -c "^parent")
if [[ "$parent_count" -ge 2 ]]; then
    _pass "HEAD is a merge commit (${parent_count} parents)"
else
    _fail "HEAD is not a merge commit -- did you complete the merge?"
fi

# 5. config.py contains health check settings (from feature branch)
assert_file_contains "$REPO/services/api/src/config.py" "health_check_interval"

# 6. config.py contains connection pool settings (from main)
assert_file_contains "$REPO/services/api/src/config.py" "max_connections"

# 7. config.py has no conflict markers left
config_file="$REPO/services/api/src/config.py"
if grep -q "^<<<<<<< " "$config_file" 2>/dev/null || grep -q "^=======$" "$config_file" 2>/dev/null || grep -q "^>>>>>>> " "$config_file" 2>/dev/null; then
    _fail "config.py still contains conflict markers -- resolve the conflict fully"
else
    _pass "config.py has no conflict markers"
fi

verify_summary
