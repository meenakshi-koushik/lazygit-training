#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="01-navigating-panels"

info "Setting up exercise: ${EXERCISE_NAME}"

# Create the sandbox repo (idempotent -- cleans up first if it exists)
REPO=$(init_exercise_repo "$EXERCISE_NAME")

# --- Build the monorepo structure ---

create_monorepo "$REPO"
add_service "$REPO" "api"
add_service "$REPO" "worker"
add_service "$REPO" "auth"
add_library "$REPO" "common"
add_library "$REPO" "logging"
add_infra "$REPO"

# Initial commit with the full monorepo
git -C "$REPO" add -A
git -C "$REPO" commit --quiet -m "chore: initial monorepo scaffolding"

# --- Build commit history on main (~15 commits) ---

make_commits "$REPO" 15

# --- Create a couple of branches so Branches panel is populated ---

# Feature branch diverging from main
make_branch_with_commits "$REPO" "feature/add-metrics" 3

# Go back to main and create another branch
git -C "$REPO" checkout --quiet main
make_branch_with_commits "$REPO" "fix/auth-timeout" 2

# Return to main
git -C "$REPO" checkout --quiet main

# --- Leave some dirty working tree state for the Files panel ---

# Modified (unstaged) files
cat >> "$REPO/services/api/src/routes.py" << 'PYEOF'

# TODO: add metrics endpoint
def metrics():
    """Return service metrics."""
    return {"requests": 0, "errors": 0}
PYEOF

cat >> "$REPO/services/worker/src/config.py" << 'PYEOF'

# TODO: add queue configuration
QUEUE_MAX_RETRIES = 5
QUEUE_BACKOFF_SECONDS = 30
PYEOF

cat >> "$REPO/infra/terraform/variables.tf" << 'TFEOF'

variable "monitoring_enabled" {
  description = "Enable monitoring stack"
  type        = bool
  default     = true
}
TFEOF

# Untracked files
cat > "$REPO/docs/onboarding.md" << 'EOF'
# Onboarding Guide

Welcome to the platform team! Here's how to get started...

## Local Development Setup

1. Clone the monorepo
2. Install dependencies
3. Run `make build` to verify everything compiles
EOF

cat > "$REPO/services/api/src/middleware.py" << 'EOF'
"""Request middleware for the API service."""


def request_logger(request):
    """Log incoming requests."""
    print(f"[{request.method}] {request.path}")
    return request
EOF

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "Open lazygit in that directory:"
echo ""
echo "  cd ${REPO} && lazygit"
echo ""
