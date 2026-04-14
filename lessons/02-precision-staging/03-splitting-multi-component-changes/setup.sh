#!/usr/bin/env bash
set -euo pipefail

source "$(dirname "$0")/../../../lib/common.sh"
source "$(dirname "$0")/../../../lib/monorepo.sh"
source "$(dirname "$0")/../../../lib/history.sh"

EXERCISE_NAME="03-splitting-multi-component-changes"

# --- Create exercise repo ---

REPO_PATH=$(init_exercise_repo "$EXERCISE_NAME")

# --- Build monorepo structure ---

create_monorepo "$REPO_PATH"
add_service "$REPO_PATH" "api"
add_service "$REPO_PATH" "worker"
add_library "$REPO_PATH" "common"

# Ensure docs/README.md exists (referenced in _TOUCHABLE_FILES)
cat > "$REPO_PATH/docs/README.md" << 'EOF'
# Platform Documentation

Architecture guides, runbooks, and API references for all platform services.
EOF

# Initial commit
git -C "$REPO_PATH" add -A
git -C "$REPO_PATH" commit --quiet -m "chore: initial monorepo scaffold"

# --- Build baseline commit history (~10 commits) ---

make_commits "$REPO_PATH" 10

# --- Tag the baseline so verify can count commits ahead of it ---

git -C "$REPO_PATH" tag exercise-start

# --- Make unstaged modifications across 3 components ---

# services/api -- 2 files modified
cat >> "$REPO_PATH/services/api/src/routes.py" << 'PYEOF'


# --- Rate limiting middleware ---

from functools import wraps

_rate_limit_store = {}

def rate_limit(max_requests=100, window_seconds=60):
    """Decorator to apply rate limiting to a route."""
    def decorator(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            # TODO: use Redis-backed store in production
            return f(*args, **kwargs)
        return wrapper
    return decorator
PYEOF

cat >> "$REPO_PATH/services/api/src/config.py" << 'PYEOF'

        # Rate limiting settings
        self.rate_limit_enabled = os.environ.get("RATE_LIMIT_ENABLED", "true").lower() == "true"
        self.rate_limit_max_requests = int(os.environ.get("RATE_LIMIT_MAX_REQUESTS", 100))
        self.rate_limit_window = int(os.environ.get("RATE_LIMIT_WINDOW", 60))
PYEOF

# services/worker -- 2 files modified
cat >> "$REPO_PATH/services/worker/src/main.py" << 'PYEOF'


def apply_rate_limit_config(settings):
    """Configure rate limiting for worker job processing."""
    if settings.rate_limit_enabled:
        logger.info(
            "Rate limiting enabled: max %d requests per %d seconds",
            settings.rate_limit_max_requests,
            settings.rate_limit_window,
        )
PYEOF

cat >> "$REPO_PATH/services/worker/src/config.py" << 'PYEOF'

        # Rate limiting for job processing
        self.rate_limit_enabled = os.environ.get("WORKER_RATE_LIMIT", "true").lower() == "true"
        self.rate_limit_max_requests = int(os.environ.get("WORKER_RATE_LIMIT_MAX", 50))
        self.rate_limit_window = int(os.environ.get("WORKER_RATE_LIMIT_WINDOW", 30))
PYEOF

# libs/common -- 1 file modified
cat >> "$REPO_PATH/libs/common/src/common.py" << 'PYEOF'


class RateLimiter:
    """Shared rate limiter used by api and worker services."""

    def __init__(self, max_requests=100, window_seconds=60):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self._requests = []

    def allow(self):
        """Check whether the current request is within the rate limit."""
        # Simplified in-memory implementation
        return len(self._requests) < self.max_requests

    def record(self):
        """Record a request for rate tracking."""
        self._requests.append(True)
PYEOF

# --- Done ---

info "Exercise repo created at: ${REPO_PATH}"
info "5 files modified across 3 components (all unstaged)"
success "Setup complete for '${EXERCISE_NAME}'"
echo ""
info "Open lazygit in the sandbox repo:"
echo "  cd ${REPO_PATH} && lazygit"
