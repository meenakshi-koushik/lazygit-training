#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="01-creating-prs-from-lazygit"

info "Setting up exercise: ${EXERCISE_NAME}"

BARE_REPO="${SANDBOX_DIR}/${EXERCISE_NAME}-origin.git"
if [[ -d "$BARE_REPO" ]]; then
    rm -rf "$BARE_REPO"
fi

TEMP_SEED="${SANDBOX_DIR}/${EXERCISE_NAME}-seed"
if [[ -d "$TEMP_SEED" ]]; then
    rm -rf "$TEMP_SEED"
fi

ensure_sandbox
clean_sandbox "$EXERCISE_NAME"

# 1. Build a seed repo
mkdir -p "$TEMP_SEED"
git -C "$TEMP_SEED" init --quiet
configure_git_user "$TEMP_SEED"

create_monorepo "$TEMP_SEED"
add_service "$TEMP_SEED" "api"
add_service "$TEMP_SEED" "worker"
add_library "$TEMP_SEED" "common"
add_infra "$TEMP_SEED"

git -C "$TEMP_SEED" add -A
git -C "$TEMP_SEED" commit --quiet -m "chore: initial monorepo scaffolding"

make_commits "$TEMP_SEED" 8

# Create bare repo from seed (main only)
git clone --bare --quiet "$TEMP_SEED" "$BARE_REPO"

# Clone for the learner
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"
git clone --quiet "$BARE_REPO" "$REPO"
configure_git_user "$REPO"

# Create feature/rate-limiter with messy WIP commits
git -C "$REPO" checkout --quiet -b "feature/rate-limiter"

# WIP commit 1: start rate limiter
mkdir -p "$REPO/services/api/src"
cat > "$REPO/services/api/src/rate_limiter.py" << 'PYEOF'
"""Rate limiting middleware for API service."""

import time


class RateLimiter:
    """Token bucket rate limiter."""

    def __init__(self, max_requests=100, window_seconds=60):
        self.max_requests = max_requests
        self.window_seconds = window_seconds
        self._buckets = {}
PYEOF

git -C "$REPO" add services/api/src/rate_limiter.py
git -C "$REPO" commit --quiet -m "WIP: start rate limiter"

# WIP commit 2: add methods
cat >> "$REPO/services/api/src/rate_limiter.py" << 'PYEOF'

    def _get_bucket(self, client_id):
        now = time.time()
        if client_id not in self._buckets:
            self._buckets[client_id] = {"tokens": self.max_requests, "last_refill": now}
        bucket = self._buckets[client_id]
        elapsed = now - bucket["last_refill"]
        refill = int(elapsed / self.window_seconds * self.max_requests)
        if refill > 0:
            bucket["tokens"] = min(self.max_requests, bucket["tokens"] + refill)
            bucket["last_refill"] = now
        return bucket

    def is_allowed(self, client_id):
        bucket = self._get_bucket(client_id)
        if bucket["tokens"] > 0:
            bucket["tokens"] -= 1
            return True
        return False
PYEOF

git -C "$REPO" add services/api/src/rate_limiter.py
git -C "$REPO" commit --quiet -m "wip: add rate limiter methods"

# WIP commit 3: add middleware wrapper
cat >> "$REPO/services/api/src/rate_limiter.py" << 'PYEOF'

    def middleware(self, f):
        """Flask middleware decorator for rate limiting."""
        import functools
        from flask import request, jsonify

        @functools.wraps(f)
        def decorated(*args, **kwargs):
            client_id = request.remote_addr
            if not self.is_allowed(client_id):
                return jsonify({"error": "Rate limit exceeded"}), 429
            return f(*args, **kwargs)
        return decorated
PYEOF

git -C "$REPO" add services/api/src/rate_limiter.py
git -C "$REPO" commit --quiet -m "wip: add flask middleware wrapper"

# WIP commit 4: add tests
mkdir -p "$REPO/services/api/tests"
cat > "$REPO/services/api/tests/test_rate_limiter.py" << 'PYEOF'
"""Tests for rate limiting middleware."""

import pytest
from src.rate_limiter import RateLimiter


def test_allows_within_limit():
    limiter = RateLimiter(max_requests=5, window_seconds=60)
    for _ in range(5):
        assert limiter.is_allowed("client1") is True


def test_blocks_over_limit():
    limiter = RateLimiter(max_requests=2, window_seconds=60)
    assert limiter.is_allowed("client1") is True
    assert limiter.is_allowed("client1") is True
    assert limiter.is_allowed("client1") is False


def test_separate_clients():
    limiter = RateLimiter(max_requests=1, window_seconds=60)
    assert limiter.is_allowed("client1") is True
    assert limiter.is_allowed("client2") is True
    assert limiter.is_allowed("client1") is False
PYEOF

git -C "$REPO" add services/api/tests/test_rate_limiter.py
git -C "$REPO" commit --quiet -m "add tests for rate limiter"

# Clean up temp repos
rm -rf "$TEMP_SEED"

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "You are on 'feature/rate-limiter' with 4 messy WIP commits."
info "Clean up the history for a PR: squash into 1 commit, reword, and push."
info "Open lazygit with:"
echo ""
echo "  lazygit -p ${REPO}"
echo ""
