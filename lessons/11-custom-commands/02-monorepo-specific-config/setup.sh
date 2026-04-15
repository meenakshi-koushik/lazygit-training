#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="02-monorepo-specific-config"

info "Setting up exercise: ${EXERCISE_NAME}"

ensure_sandbox
clean_sandbox "$EXERCISE_NAME"

EXERCISE_DIR="${SANDBOX_DIR}/${EXERCISE_NAME}"
mkdir -p "$EXERCISE_DIR"

# Create a repo inside the exercise directory
REPO="${EXERCISE_DIR}/repo"
mkdir -p "$REPO"
git -C "$REPO" init --quiet
configure_git_user "$REPO"

create_monorepo "$REPO"
add_service "$REPO" "api"
add_service "$REPO" "worker"
add_service "$REPO" "frontend"
add_library "$REPO" "common"
add_library "$REPO" "auth"
add_infra "$REPO"

git -C "$REPO" add -A
git -C "$REPO" commit --quiet -m "chore: initial monorepo scaffolding"

make_commits "$REPO" 8

# Create a feature branch with a ticket-style name
git -C "$REPO" checkout -b feature/PROJ-42-add-rate-limiting --quiet
cat > "$REPO/services/api/src/rate_limiter.py" << 'EOF'
"""Rate limiting middleware for the API service."""

import time
from collections import defaultdict

class RateLimiter:
    def __init__(self, max_requests=100, window_seconds=60):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self._requests = defaultdict(list)

    def is_allowed(self, client_id: str) -> bool:
        now = time.time()
        window_start = now - self.window_seconds
        self._requests[client_id] = [
            t for t in self._requests[client_id] if t > window_start
        ]
        if len(self._requests[client_id]) >= self.max_requests:
            return False
        self._requests[client_id].append(now)
        return True
EOF

git -C "$REPO" add -A
git -C "$REPO" commit --quiet -m "feat(api): add rate limiting middleware"

# Go back to main for the learner
git -C "$REPO" checkout main --quiet

# Create a starter lazygit config with minimal settings
cat > "$EXERCISE_DIR/lazygit.yml" << 'YAMLEOF'
# Lazygit configuration for monorepo development
# Customize this config for working in a large monorepo.
#
# Your objectives:
#   1. Enable file tree view and line-count stats
#   2. Configure main branches for your team's workflow
#   3. Increase diff context for better code review
#   4. Set up automatic commit message prefixes from branch names
#   5. Add a service-specific custom command using template variables
#
# See the lesson README for details on each objective.

gui:
  showBottomLine: true
  nerdFontsVersion: ""

git:
  commit:
    signOff: false

os:
  editPreset: ""
YAMLEOF

success "Exercise '${EXERCISE_NAME}' is ready at: ${EXERCISE_DIR}"
info "Edit the lazygit.yml config file to optimize it for monorepo development."
info "The config file is at: ${EXERCISE_DIR}/lazygit.yml"
info ""
info "To test your config in lazygit:"
echo ""
echo "  lazygit -ucf ${EXERCISE_DIR}/lazygit.yml -p ${REPO}"
echo ""
info "Then verify with: ./train.sh verify 11/2"
echo ""
