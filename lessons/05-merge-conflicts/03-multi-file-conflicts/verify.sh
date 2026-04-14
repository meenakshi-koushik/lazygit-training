#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="03-multi-file-conflicts"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 5/3"
    exit 1
fi

info "Verifying lesson: Multi-File Conflicts"
separator

set +e

# 1. HEAD is on the feature branch
assert_on_branch "feature/structured-logging" "$REPO"

# 2. No unresolved merge conflicts
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

# 5. common.py has structured logging (from feature)
assert_file_contains "$REPO/libs/common/src/common.py" "JsonFormatter"

# 6. common.py has monitoring (from main)
assert_file_contains "$REPO/libs/common/src/common.py" "configure_monitoring"

# 7. api/main.py has setup_logging (from feature)
assert_file_contains "$REPO/services/api/src/main.py" "setup_logging"

# 8. api/main.py has configure_monitoring (from main)
assert_file_contains "$REPO/services/api/src/main.py" "configure_monitoring"

# 9. worker/main.py has setup_logging (from feature)
assert_file_contains "$REPO/services/worker/src/main.py" "setup_logging"

# 10. worker/main.py has configure_monitoring (from main)
assert_file_contains "$REPO/services/worker/src/main.py" "configure_monitoring"

# 11. helm values has logging config (from feature)
assert_file_contains "$REPO/infra/helm/values.yaml" "logging:"

# 12. helm values has monitoring config (from main)
assert_file_contains "$REPO/infra/helm/values.yaml" "monitoring:"

# 13. No conflict markers in any tracked file
conflict_files=$(git -C "$REPO" grep -rl "^<<<<<<< " -- '*.py' '*.tf' '*.yaml' '*.yml' '*.md' 2>/dev/null || true)
if [[ -z "$conflict_files" ]]; then
    _pass "No conflict markers in tracked files"
else
    _fail "Conflict markers found in: ${conflict_files}"
fi

verify_summary
