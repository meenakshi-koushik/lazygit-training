#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="02-interactive-rebase-squash"

info "Setting up exercise: ${EXERCISE_NAME}"

# Create the sandbox repo (idempotent -- cleans up first if it exists)
REPO=$(init_exercise_repo "$EXERCISE_NAME")

# --- Build the monorepo structure ---

create_monorepo "$REPO"
add_service "$REPO" "api"
add_library "$REPO" "common"
add_infra "$REPO"

# Initial commit with the full monorepo
git -C "$REPO" add -A
git -C "$REPO" commit --quiet -m "chore: initial monorepo scaffolding"

# Add realistic history on main
make_commits "$REPO" 6

# Tag the divergence point and create the feature branch
git -C "$REPO" tag exercise-start
git -C "$REPO" checkout --quiet -b feature/rate-limiting

# --- Commit 1: "WIP: starting rate limiter" -- add a new file ---

cat > "$REPO/services/api/src/rate_limiter.py" << 'PYEOF'
"""Rate limiting middleware for the API service."""

import time
from collections import defaultdict


class RateLimiter:
    """Token bucket rate limiter."""

    def __init__(self, max_requests=100, window_seconds=60):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self._buckets = defaultdict(list)
PYEOF

git -C "$REPO" add services/api/src/rate_limiter.py
git -C "$REPO" commit --quiet -m "WIP: starting rate limiter"

# --- Commit 2: "wip more stuff" -- extend the rate limiter ---

cat > "$REPO/services/api/src/rate_limiter.py" << 'PYEOF'
"""Rate limiting middleware for the API service."""

import time
from collections import defaultdict
from functools import wraps


class RateLimiter:
    """Token bucket rate limiter."""

    def __init__(self, max_requests=100, window_seconds=60):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self._buckets = defaultdict(list)

    def _cleanup_bucket(self, key):
        """Remove expired entries from a bucket."""
        now = time.time()
        cutoff = now - self.window_seconds
        self._buckets[key] = [t for t in self._buckets[key] if t > cutoff]

    def is_allowed(self, key):
        """Check whether a request from the given key is allowed."""
        self._cleanup_bucket(key)
        if len(self._buckets[key]) >= self.max_requests:
            return False
        self._buckets[key].append(time.time())
        return True
PYEOF

git -C "$REPO" add services/api/src/rate_limiter.py
git -C "$REPO" commit --quiet -m "wip more stuff"

# --- Commit 3: "fix typo" -- small correction ---

cat > "$REPO/services/api/src/rate_limiter.py" << 'PYEOF'
"""Rate limiting middleware for the API service."""

import time
from collections import defaultdict
from functools import wraps


class RateLimiter:
    """Token bucket rate limiter."""

    def __init__(self, max_requests=100, window_seconds=60):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self._buckets = defaultdict(list)

    def _cleanup_bucket(self, key):
        """Remove expired entries from a client's bucket."""
        now = time.time()
        cutoff = now - self.window_seconds
        self._buckets[key] = [ts for ts in self._buckets[key] if ts > cutoff]

    def is_allowed(self, client_key):
        """Check whether a request from the given client is allowed."""
        self._cleanup_bucket(client_key)
        if len(self._buckets[client_key]) >= self.max_requests:
            return False
        self._buckets[client_key].append(time.time())
        return True
PYEOF

git -C "$REPO" add services/api/src/rate_limiter.py
git -C "$REPO" commit --quiet -m "fix typo"

# --- Commit 4: "oops forgot file" -- add the test file ---

mkdir -p "$REPO/services/api/tests"
cat > "$REPO/services/api/tests/test_rate_limiter.py" << 'PYEOF'
"""Tests for rate limiting middleware."""

import time
import pytest
from src.rate_limiter import RateLimiter


@pytest.fixture
def limiter():
    return RateLimiter(max_requests=5, window_seconds=10)


def test_allows_under_limit(limiter):
    for _ in range(5):
        assert limiter.is_allowed("client-1")


def test_blocks_over_limit(limiter):
    for _ in range(5):
        limiter.is_allowed("client-1")
    assert not limiter.is_allowed("client-1")


def test_separate_clients(limiter):
    for _ in range(5):
        limiter.is_allowed("client-1")
    # Different client should still be allowed
    assert limiter.is_allowed("client-2")
PYEOF

git -C "$REPO" add services/api/tests/test_rate_limiter.py
git -C "$REPO" commit --quiet -m "oops forgot file"

# --- Commit 5: "cleanup" -- polish both files ---

cat > "$REPO/services/api/src/rate_limiter.py" << 'PYEOF'
"""Rate limiting middleware for the API service."""

import logging
import time
from collections import defaultdict
from functools import wraps

logger = logging.getLogger(__name__)


class RateLimiter:
    """Token bucket rate limiter.

    Tracks requests per client key using a sliding window algorithm.
    """

    def __init__(self, max_requests=100, window_seconds=60):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self._buckets = defaultdict(list)

    def _cleanup_bucket(self, client_key):
        """Remove expired entries from a client's bucket."""
        now = time.time()
        cutoff = now - self.window_seconds
        self._buckets[client_key] = [
            ts for ts in self._buckets[client_key] if ts > cutoff
        ]

    def is_allowed(self, client_key):
        """Check whether a request from the given client is allowed.

        Returns True if the client has not exceeded the rate limit,
        False otherwise.
        """
        self._cleanup_bucket(client_key)
        if len(self._buckets[client_key]) >= self.max_requests:
            logger.warning("Rate limit exceeded for client: %s", client_key)
            return False
        self._buckets[client_key].append(time.time())
        return True
PYEOF

cat > "$REPO/services/api/tests/test_rate_limiter.py" << 'PYEOF'
"""Tests for rate limiting middleware."""

import time
import pytest
from src.rate_limiter import RateLimiter


@pytest.fixture
def limiter():
    """Create a rate limiter with low limits for testing."""
    return RateLimiter(max_requests=5, window_seconds=10)


def test_allows_requests_under_limit(limiter):
    """Requests under the limit should be allowed."""
    for _ in range(5):
        assert limiter.is_allowed("client-1")


def test_blocks_requests_over_limit(limiter):
    """Requests over the limit should be blocked."""
    for _ in range(5):
        limiter.is_allowed("client-1")
    assert not limiter.is_allowed("client-1")


def test_separate_clients_have_independent_limits(limiter):
    """Each client key should have its own rate limit bucket."""
    for _ in range(5):
        limiter.is_allowed("client-1")
    # Different client should still be allowed
    assert limiter.is_allowed("client-2")


def test_bucket_expires_after_window(limiter):
    """Requests should be allowed again after the window expires."""
    for _ in range(5):
        limiter.is_allowed("client-1")
    assert not limiter.is_allowed("client-1")
    # After window passes, requests should be allowed again
    # (In real tests we'd mock time, but this validates the structure)
PYEOF

git -C "$REPO" add -A
git -C "$REPO" commit --quiet -m "cleanup"

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "Open lazygit in that directory:"
echo ""
echo "  lazygit -p ${REPO}"
echo ""
