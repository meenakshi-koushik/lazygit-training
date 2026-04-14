#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="02-named-and-partial-stashes"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 6/2"
    exit 1
fi

info "Verifying lesson: Named and Partial Stashes"
separator

set +e

# 1. Must be on the feature/notifications branch
assert_on_branch "feature/notifications" "$REPO"

# 2. Exactly 1 stash entry remains (the API stash; worker was popped)
assert_stash_count 1 "$REPO"

# 3. The remaining stash has the API notification name
stash_msg=$(git -C "$REPO" stash list 2>/dev/null | head -1)
if echo "$stash_msg" | grep -qi "api notification"; then
    _pass "Remaining stash is named 'api notification changes'"
else
    _fail "Remaining stash should contain 'api notification' in its name, found: ${stash_msg}"
fi

# 4. Working tree has unstaged changes (worker files were restored)
assert_has_unstaged_changes "$REPO"

# 5. Worker queue.py has the restored notification queue content
assert_file_contains "$REPO/services/worker/src/queue.py" "NotificationQueue"

# 6. Worker config.py has the restored queue configuration
assert_file_contains "$REPO/services/worker/src/config.py" "queue_url"

# 7. API notifications.py should NOT have changes (still stashed)
# The file should exist but contain only the placeholder content
diff_names=$(git -C "$REPO" diff --name-only 2>/dev/null)
if echo "$diff_names" | grep -q "services/api/src/notifications.py"; then
    _fail "services/api/src/notifications.py should not be modified (API changes are stashed)"
else
    _pass "API notification file is not modified (still stashed)"
fi

# 8. API config.py should NOT have changes (still stashed)
if echo "$diff_names" | grep -q "services/api/src/config.py"; then
    _fail "services/api/src/config.py should not be modified (API changes are stashed)"
else
    _pass "API config file is not modified (still stashed)"
fi

verify_summary
