#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../../../lib/common.sh"
source "$(dirname "$0")/../../../lib/monorepo.sh"
source "$(dirname "$0")/../../../lib/history.sh"

EXERCISE_NAME="02-staging-lines"

# --- Create exercise repo ---

REPO_PATH=$(init_exercise_repo "$EXERCISE_NAME")

# --- Build monorepo structure ---

create_monorepo "$REPO_PATH"
add_service "$REPO_PATH" "api"

# Initial commit
git -C "$REPO_PATH" add -A
git -C "$REPO_PATH" commit --quiet -m "chore: initial monorepo scaffold"

# --- Build some commit history ---

make_commits "$REPO_PATH" 5

# --- Modify config.py with a mix of feature code and debug statements ---
# All changes are in one continuous block so they form a single hunk.

cat > "$REPO_PATH/services/api/src/config.py" << 'EOF'
"""Configuration for api service."""

import os


class Settings:
    def __init__(self):
        self.port = int(os.environ.get("PORT", 8080))
        self.debug = os.environ.get("DEBUG", "false").lower() == "true"
        self.db_url = os.environ.get("DATABASE_URL", "postgresql://localhost/api")
        self.log_level = os.environ.get("LOG_LEVEL", "INFO")
        print("DEBUG: loading config values from environment")
        self.cache_ttl = int(os.environ.get("CACHE_TTL", 300))
        print("DEBUG: cache_ttl =", self.cache_ttl)
        self.cache_backend = os.environ.get("CACHE_BACKEND", "redis")
        self.cache_url = os.environ.get("CACHE_URL", "redis://localhost:6379/0")
        print("DEBUG: finished loading all config")
EOF

# --- Done ---

info "Exercise repo created at: ${REPO_PATH}"
success "Setup complete for '${EXERCISE_NAME}'"
echo ""
info "Open lazygit in the sandbox repo:"
echo "  cd ${REPO_PATH} && lazygit"
