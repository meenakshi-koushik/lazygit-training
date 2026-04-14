#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="03-stash-across-branches"

info "Setting up exercise: ${EXERCISE_NAME}"

# Create the sandbox repo (idempotent -- cleans up first if it exists)
REPO=$(init_exercise_repo "$EXERCISE_NAME")

# --- Build the monorepo structure ---

create_monorepo "$REPO"
add_service "$REPO" "api"
add_service "$REPO" "worker"
add_library "$REPO" "common"

# Initial commit
git -C "$REPO" add -A
git -C "$REPO" commit --quiet -m "chore: initial monorepo scaffolding"

# Build up a realistic main branch history (7 more commits, 8 total)
make_commits "$REPO" 7

# Tag main's HEAD so verify.sh can measure commits ahead
git -C "$REPO" tag main-head

# --- Leave unstaged modifications that look like cache-layer work ---

cat >> "$REPO/services/api/src/routes.py" << 'PYEOF'


# --- Cache layer integration ---

from libs.common.src.cache import CacheClient

_cache = CacheClient(prefix="api")


def cached_response(key, ttl=300):
    """Decorator to cache route responses."""
    def decorator(fn):
        def wrapper(*args, **kwargs):
            cached = _cache.get(key)
            if cached is not None:
                return cached
            result = fn(*args, **kwargs)
            _cache.set(key, result, ttl=ttl)
            return result
        return wrapper
    return decorator
PYEOF

cat >> "$REPO/services/api/src/config.py" << 'PYEOF'


        # Cache settings
        self.cache_host = os.environ.get("CACHE_HOST", "localhost")
        self.cache_port = int(os.environ.get("CACHE_PORT", 6379))
        self.cache_ttl = int(os.environ.get("CACHE_TTL", 300))
        self.cache_prefix = os.environ.get("CACHE_PREFIX", "api")
PYEOF

cat >> "$REPO/libs/common/src/common.py" << 'PYEOF'


class CacheClient:
    """Thin wrapper around Redis for cross-service caching."""

    def __init__(self, host="localhost", port=6379, prefix=""):
        self.host = host
        self.port = port
        self.prefix = prefix
        self._connected = False

    def connect(self):
        self._connected = True
        return self

    def _make_key(self, key):
        return f"{self.prefix}:{key}" if self.prefix else key

    def get(self, key):
        return None  # stub

    def set(self, key, value, ttl=300):
        pass  # stub
PYEOF

# Ensure the learner starts on main with unstaged changes
git -C "$REPO" checkout --quiet main

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "You are on 'main' with unstaged changes that belong on a feature branch."
info "Open lazygit with:"
echo ""
echo "  lazygit -p ${REPO}"
echo ""
