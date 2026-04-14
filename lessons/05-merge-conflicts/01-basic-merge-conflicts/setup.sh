#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="01-basic-merge-conflicts"

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

# Build baseline history on main
make_commits "$REPO" 6

# --- Create the scenario: two branches that edited the same function ---

# Save the divergence point
git -C "$REPO" tag "divergence-point"

# Branch 1: main continues with a teammate's change to the config module
cat > "$REPO/services/api/src/config.py" << 'PYEOF'
"""Configuration for api service."""

import os


class Settings:
    def __init__(self):
        self.port = int(os.environ.get("PORT", 8080))
        self.debug = os.environ.get("DEBUG", "false").lower() == "true"
        self.db_url = os.environ.get("DATABASE_URL", "postgresql://localhost/api")
        self.log_level = os.environ.get("LOG_LEVEL", "INFO")
        self.max_connections = int(os.environ.get("MAX_CONNECTIONS", 100))
        self.request_timeout = int(os.environ.get("REQUEST_TIMEOUT", 30))

    def is_production(self):
        """Check if running in production mode."""
        return not self.debug and self.log_level == "WARNING"
PYEOF

git -C "$REPO" add services/api/src/config.py
git -C "$REPO" commit --quiet -m "feat(api): add connection pool and timeout settings"

# Add another commit on main so it looks realistic
cat >> "$REPO/docs/README.md" << 'EOF'

## Configuration

All services support the following environment variables:
- `PORT` -- service listen port
- `DEBUG` -- enable debug mode
- `LOG_LEVEL` -- logging verbosity (DEBUG, INFO, WARNING, ERROR)
- `MAX_CONNECTIONS` -- maximum database connections
- `REQUEST_TIMEOUT` -- request timeout in seconds
EOF
git -C "$REPO" add docs/README.md
git -C "$REPO" commit --quiet -m "docs: add configuration reference"

# Branch 2: your feature branch diverges from the same point
git -C "$REPO" checkout --quiet "divergence-point"
git -C "$REPO" checkout --quiet -b "feature/api-health-check"

# Your change to the SAME file -- different approach to the same area
cat > "$REPO/services/api/src/config.py" << 'PYEOF'
"""Configuration for api service."""

import os


class Settings:
    def __init__(self):
        self.port = int(os.environ.get("PORT", 8080))
        self.debug = os.environ.get("DEBUG", "false").lower() == "true"
        self.db_url = os.environ.get("DATABASE_URL", "postgresql://localhost/api")
        self.log_level = os.environ.get("LOG_LEVEL", "INFO")
        self.health_check_interval = int(os.environ.get("HEALTH_CHECK_INTERVAL", 15))
        self.health_check_path = os.environ.get("HEALTH_CHECK_PATH", "/health")

    def get_health_config(self):
        """Return health check configuration."""
        return {
            "interval": self.health_check_interval,
            "path": self.health_check_path,
        }
PYEOF

git -C "$REPO" add services/api/src/config.py
git -C "$REPO" commit --quiet -m "feat(api): add health check configuration"

# Add a second commit on the feature branch
cat > "$REPO/services/api/src/health.py" << 'PYEOF'
"""Health check endpoint implementation."""

import time


class HealthChecker:
    """Performs periodic health checks."""

    def __init__(self, config):
        self.interval = config.get("interval", 15)
        self.path = config.get("path", "/health")
        self._last_check = None

    def check(self):
        """Run a health check and return status."""
        self._last_check = time.time()
        return {"status": "healthy", "timestamp": self._last_check}

    def is_due(self):
        """Check if another health check is due."""
        if self._last_check is None:
            return True
        return (time.time() - self._last_check) >= self.interval
PYEOF

git -C "$REPO" add services/api/src/health.py
git -C "$REPO" commit --quiet -m "feat(api): implement health checker class"

# --- Initiate the merge so the learner sees the conflict ---

# Try to merge main into the feature branch -- this WILL conflict
git -C "$REPO" merge main --no-edit 2>/dev/null || true

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "A merge conflict is waiting for you in services/api/src/config.py"
info "Open lazygit in the sandbox:"
echo ""
echo "  lazygit -p ${REPO}"
echo ""
