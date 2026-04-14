#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="03-reordering-and-editing-commits"

info "Setting up exercise: ${EXERCISE_NAME}"

# Create the sandbox repo (idempotent -- cleans up first if it exists)
REPO=$(init_exercise_repo "$EXERCISE_NAME")

# --- Build the monorepo structure ---

create_monorepo "$REPO"
add_service "$REPO" "api"
add_library "$REPO" "common"
add_infra "$REPO"

# Initial commit
git -C "$REPO" add -A
git -C "$REPO" commit --quiet -m "chore: initial monorepo scaffolding"

# Build up a realistic main branch history (~6 commits)
make_commits "$REPO" 6

# --- Tag the divergence point and create the feature branch ---

git -C "$REPO" tag exercise-start

git -C "$REPO" checkout --quiet -b feature/caching

# --- Commit 1 (WRONG order): tests before implementation ---

cat > "$REPO/services/api/tests/test_cache.py" << 'PYEOF'
"""Tests for the API caching layer."""

import pytest


class TestCacheLayer:
    """Tests for CacheLayer."""

    def test_cache_get_returns_none_on_miss(self):
        from src.cache import CacheLayer
        cache = CacheLayer()
        assert cache.get("nonexistent") is None

    def test_cache_set_and_get(self):
        from src.cache import CacheLayer
        cache = CacheLayer()
        cache.set("key1", "value1", ttl=60)
        assert cache.get("key1") == "value1"

    def test_cache_delete(self):
        from src.cache import CacheLayer
        cache = CacheLayer()
        cache.set("key1", "value1", ttl=60)
        cache.delete("key1")
        assert cache.get("key1") is None

    def test_cache_ttl_expiry(self):
        from src.cache import CacheLayer
        cache = CacheLayer()
        cache.set("key1", "value1", ttl=0)
        assert cache.get("key1") is None
PYEOF

git -C "$REPO" add services/api/tests/test_cache.py
git -C "$REPO" commit --quiet -m "test(api): add cache tests"

# --- Commit 2 (WRONG order): implementation after tests ---

cat > "$REPO/services/api/src/cache.py" << 'PYEOF'
"""Caching layer for the API service."""

import time
import logging
from typing import Any, Optional

logger = logging.getLogger(__name__)


class CacheLayer:
    """In-memory cache with TTL support."""

    def __init__(self):
        self._store: dict[str, tuple[Any, float]] = {}
        logger.info("CacheLayer initialized")

    def get(self, key: str) -> Optional[Any]:
        """Retrieve a value by key. Returns None if missing or expired."""
        if key not in self._store:
            return None
        value, expires_at = self._store[key]
        if time.time() > expires_at:
            del self._store[key]
            return None
        return value

    def set(self, key: str, value: Any, ttl: int = 300) -> None:
        """Store a value with a TTL in seconds."""
        expires_at = time.time() + ttl
        self._store[key] = (value, expires_at)
        logger.debug("Cache SET %s (ttl=%d)", key, ttl)

    def delete(self, key: str) -> None:
        """Remove a key from the cache."""
        self._store.pop(key, None)
        logger.debug("Cache DELETE %s", key)
PYEOF

git -C "$REPO" add services/api/src/cache.py
git -C "$REPO" commit --quiet -m "feat(api): implement cache layer"

# --- Commit 3 (WRONG order): config change interrupting code flow ---

cat >> "$REPO/services/api/config/settings.yaml" << 'YAMLEOF'

redis:
  host: localhost
  port: 6379
  db: 0
  password: ""
  key_prefix: "api_cache:"
YAMLEOF

git -C "$REPO" add services/api/config/settings.yaml
git -C "$REPO" commit --quiet -m "chore: update config for cache"

# --- Commit 4: cache invalidation (appends to cache.py) ---

cat >> "$REPO/services/api/src/cache.py" << 'PYEOF'

    def invalidate_pattern(self, pattern: str) -> int:
        """Remove all keys matching a prefix pattern. Returns count of removed keys."""
        to_remove = [k for k in self._store if k.startswith(pattern)]
        for key in to_remove:
            del self._store[key]
        logger.info("Cache INVALIDATE pattern=%s removed=%d", pattern, len(to_remove))
        return len(to_remove)

    def clear(self) -> None:
        """Remove all entries from the cache."""
        count = len(self._store)
        self._store.clear()
        logger.info("Cache CLEAR removed=%d entries", count)
PYEOF

git -C "$REPO" add services/api/src/cache.py
git -C "$REPO" commit --quiet -m "feat(api): add cache invalidation"

# --- Done ---

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "Open lazygit in that directory:"
echo ""
echo "  cd ${REPO} && lazygit"
echo ""
info "Current (wrong) commit order on feature/caching:"
git -C "$REPO" log --oneline exercise-start..HEAD
echo ""
info "Goal: reorder to -- implement, tests, invalidation, config"
