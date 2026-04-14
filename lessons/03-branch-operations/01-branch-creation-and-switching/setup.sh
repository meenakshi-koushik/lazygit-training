#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="01-branch-creation-and-switching"

info "Setting up exercise: ${EXERCISE_NAME}"

# Create the sandbox repo (idempotent -- cleans up first if it exists)
REPO=$(init_exercise_repo "$EXERCISE_NAME")

# --- Build the monorepo structure ---

create_monorepo "$REPO"
add_service "$REPO" "api"
add_service "$REPO" "worker"
add_library "$REPO" "common"
add_infra "$REPO"

# Initial commit
git -C "$REPO" add -A
git -C "$REPO" commit --quiet -m "chore: initial monorepo scaffolding"

# Build up a realistic main branch history (~12 commits total including initial)
make_commits "$REPO" 11

# --- Create existing branches so the Branches panel is already populated ---

# feature/notifications: 3 commits ahead of main
git -C "$REPO" checkout --quiet -b "feature/notifications"

echo '# notification service config' > "$REPO/services/api/src/notifications.py"
git -C "$REPO" add services/api/src/notifications.py
git -C "$REPO" commit --quiet -m "feat(api): add notification service skeleton"

echo 'NOTIFICATIONS_ENABLED=true' >> "$REPO/services/api/config/settings.yaml"
git -C "$REPO" add services/api/config/settings.yaml
git -C "$REPO" commit --quiet -m "feat(api): enable notifications in config"

echo '# notification templates' > "$REPO/docs/notifications.md"
git -C "$REPO" add docs/notifications.md
git -C "$REPO" commit --quiet -m "docs: add notification system documentation"

# Return to main before creating the next branch
git -C "$REPO" checkout --quiet main

# bugfix/login-timeout: 2 commits ahead of main
git -C "$REPO" checkout --quiet -b "bugfix/login-timeout"

echo '# timeout fix applied' >> "$REPO/services/api/src/config.py"
git -C "$REPO" add services/api/src/config.py
git -C "$REPO" commit --quiet -m "fix(auth): increase login timeout to 30s"

echo '# timeout test' >> "$REPO/services/api/tests/test_routes.py"
git -C "$REPO" add services/api/tests/test_routes.py
git -C "$REPO" commit --quiet -m "test(auth): add timeout boundary tests"

# --- Ensure the learner starts on main ---
git -C "$REPO" checkout --quiet main

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "Open lazygit in that directory:"
echo ""
echo "  cd ${REPO} && lazygit"
echo ""
