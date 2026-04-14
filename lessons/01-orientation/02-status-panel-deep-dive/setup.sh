#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../../../lib/common.sh"
source "$(dirname "$0")/../../../lib/monorepo.sh"
source "$(dirname "$0")/../../../lib/history.sh"

EXERCISE_NAME="02-status-panel-deep-dive"

# --- Create exercise repo ---

REPO_PATH=$(init_exercise_repo "$EXERCISE_NAME")

# --- Build monorepo structure ---

create_monorepo "$REPO_PATH"
add_service "$REPO_PATH" "api"
add_service "$REPO_PATH" "worker"
add_service "$REPO_PATH" "auth"
add_library "$REPO_PATH" "common"
add_infra "$REPO_PATH"

# Ensure docs/README.md exists (referenced in _TOUCHABLE_FILES)
cat > "$REPO_PATH/docs/README.md" << 'EOF'
# Platform Documentation

Architecture guides, runbooks, and API references for all platform services.
EOF

# Initial commit
git -C "$REPO_PATH" add -A
git -C "$REPO_PATH" commit --quiet -m "chore: initial monorepo scaffold"

# --- Build commit history on main (~10 commits) ---

make_commits "$REPO_PATH" 10

# --- Create feature branches with varying commit counts ---

# Branch 1: feature/auth-service (3 commits, branched from main)
make_branch_with_commits "$REPO_PATH" "feature/auth-service" 3

# Back to main for the next branches
git -C "$REPO_PATH" checkout --quiet main

# Branch 2: feature/notifications (5 commits)
make_branch_with_commits "$REPO_PATH" "feature/notifications" 5

git -C "$REPO_PATH" checkout --quiet main

# Branch 3: feature/db-migration (2 commits)
make_branch_with_commits "$REPO_PATH" "feature/db-migration" 2

git -C "$REPO_PATH" checkout --quiet main

# Branch 4: infra/helm-upgrade (4 commits)
make_branch_with_commits "$REPO_PATH" "infra/helm-upgrade" 4

# --- Set up a simulated remote for upstream tracking info ---

git -C "$REPO_PATH" checkout --quiet main

REMOTE_PATH="${SANDBOX_DIR}/${EXERCISE_NAME}-remote.git"
rm -rf "$REMOTE_PATH"

# Create a bare clone to act as origin
git clone --bare --quiet "$REPO_PATH" "$REMOTE_PATH"

# Point the repo's origin to the bare clone
git -C "$REPO_PATH" remote remove origin 2>/dev/null || true
git -C "$REPO_PATH" remote add origin "$REMOTE_PATH"

# Set up tracking for all branches
for branch in main feature/auth-service feature/notifications feature/db-migration infra/helm-upgrade; do
    git -C "$REPO_PATH" push --quiet origin "$branch"
    git -C "$REPO_PATH" checkout --quiet "$branch"
    git -C "$REPO_PATH" branch --quiet --set-upstream-to="origin/${branch}" "$branch"
done

# Add 2 more commits to main so it is ahead of origin/main
git -C "$REPO_PATH" checkout --quiet main
make_commits "$REPO_PATH" 2

# --- Leave the learner on main ---

info "Exercise repo created at: ${REPO_PATH}"
info "Remote (bare) at: ${REMOTE_PATH}"
success "Setup complete for '${EXERCISE_NAME}'"
echo ""
info "Open lazygit in the sandbox repo:"
echo "  cd ${REPO_PATH} && lazygit"
