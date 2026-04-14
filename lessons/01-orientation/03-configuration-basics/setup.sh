#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../../../lib/common.sh"
source "$(dirname "$0")/../../../lib/monorepo.sh"
source "$(dirname "$0")/../../../lib/history.sh"

# --- Create the exercise repo ---

EXERCISE_NAME="03-configuration-basics"
REPO_PATH=$(init_exercise_repo "$EXERCISE_NAME")

info "Setting up configuration basics exercise..."

# Create a monorepo structure with 2 services
create_monorepo "$REPO_PATH"
add_service "$REPO_PATH" "api"
add_service "$REPO_PATH" "worker"

# Initial commit with the full monorepo structure
git -C "$REPO_PATH" add -A
git -C "$REPO_PATH" commit --quiet -m "feat: initialize platform monorepo"

# Create ~8 commits of history
make_commits "$REPO_PATH" 8

# Leave a couple of modified files so there's something to interact with
append_modification "$REPO_PATH/services/api/src/config.py" "TODO: add cache configuration"
append_modification "$REPO_PATH/services/worker/src/main.py" "TODO: add graceful shutdown handler"

separator
success "Exercise ready: $REPO_PATH"
info "Open lazygit in the sandbox repo:"
echo ""
echo "  cd $REPO_PATH && lazygit"
echo ""
info "You should see 2 modified files in the Files panel."
