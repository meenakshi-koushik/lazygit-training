#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="03-filtering-and-managing-many-branches"

info "Setting up exercise: ${EXERCISE_NAME}"

# Create the sandbox repo (idempotent -- cleans up first if it exists)
REPO=$(init_exercise_repo "$EXERCISE_NAME")

# --- Build the monorepo structure ---

create_monorepo "$REPO"
add_service "$REPO" "api"
add_service "$REPO" "worker"
add_library "$REPO" "common"
add_infra "$REPO"

# Initial commit with the full monorepo
git -C "$REPO" add -A
git -C "$REPO" commit --quiet -m "chore: initial monorepo scaffolding"

# Build a realistic history on main
make_commits "$REPO" 10

# --- Create many branches to simulate real monorepo clutter ---
#
# We use a global counter so that each commit across all branches
# touches a unique dummy file (avoids "nothing to commit" collisions
# with the .changes/ files already created by make_commits on main).

_BRANCH_COMMIT_COUNTER=100

# Helper: create a branch with optional commits, then return to main
create_topic_branch() {
    local repo="$1"
    local branch="$2"
    local commits="${3:-0}"

    git -C "$repo" checkout --quiet -b "$branch"
    for (( c = 0; c < commits; c++ )); do
        local dummy="${repo}/.changes/branch-change-${_BRANCH_COMMIT_COUNTER}.txt"
        mkdir -p "$(dirname "$dummy")"
        echo "Change on ${branch} #$((c+1))" > "$dummy"
        git -C "$repo" add .changes/
        git -C "$repo" commit --quiet -m "wip(${branch}): change $((c+1))"
        _BRANCH_COMMIT_COUNTER=$((_BRANCH_COMMIT_COUNTER + 1))
    done
    git -C "$repo" checkout --quiet main
}

# Feature branches (active work from various team members)
create_topic_branch "$REPO" "feature/user-profiles" 3
create_topic_branch "$REPO" "feature/search-api" 2
create_topic_branch "$REPO" "feature/dashboard-v2" 3
create_topic_branch "$REPO" "feature/notifications" 1
create_topic_branch "$REPO" "feature/billing-integration" 2

# Bugfix branches
create_topic_branch "$REPO" "bugfix/login-timeout" 1
create_topic_branch "$REPO" "bugfix/rate-limiter" 2
create_topic_branch "$REPO" "bugfix/session-expired" 1

# Hotfix branches (critical -- must not be deleted)
create_topic_branch "$REPO" "hotfix/prod-crash" 1
create_topic_branch "$REPO" "hotfix/memory-leak" 1

# Release branches
create_topic_branch "$REPO" "release/v2.1" 2
create_topic_branch "$REPO" "release/v2.2" 1

# Chore branches (stale -- these are the ones the learner should delete)
create_topic_branch "$REPO" "chore/update-deps" 1
create_topic_branch "$REPO" "chore/ci-pipeline" 0
create_topic_branch "$REPO" "chore/cleanup-logs" 0

# Ensure we end on main
git -C "$REPO" checkout --quiet main

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "The repo has $(git -C "$REPO" branch | wc -l | tr -d ' ') branches. Time to clean up!"
info "Open lazygit in that directory:"
echo ""
echo "  cd ${REPO} && lazygit"
echo ""
