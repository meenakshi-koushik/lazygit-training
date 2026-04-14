#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="03-upstream-tracking"

info "Setting up exercise: ${EXERCISE_NAME}"

# --- Create a bare repo to act as "origin" ---

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

# 1. Build a seed repo with monorepo structure
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

# Create feature/search branch (will be pushed to origin by "teammate")
git -C "$TEMP_SEED" checkout --quiet -b "feature/search"

mkdir -p "$TEMP_SEED/services/search/src"
cat > "$TEMP_SEED/services/search/src/main.py" << 'PYEOF'
"""Search service entry point."""

import logging
from .config import Settings
from .indexer import SearchIndexer

logger = logging.getLogger(__name__)


def main():
    settings = Settings()
    indexer = SearchIndexer(settings)
    logger.info("Starting search service on port %d", settings.port)
    indexer.start()


if __name__ == "__main__":
    main()
PYEOF

cat > "$TEMP_SEED/services/search/src/__init__.py" << 'PYEOF'
PYEOF

cat > "$TEMP_SEED/services/search/src/config.py" << 'PYEOF'
"""Configuration for search service."""

import os


class Settings:
    def __init__(self):
        self.port = int(os.environ.get("PORT", 8086))
        self.elasticsearch_url = os.environ.get("ELASTICSEARCH_URL", "http://localhost:9200")
        self.index_prefix = os.environ.get("INDEX_PREFIX", "platform")
PYEOF

cat > "$TEMP_SEED/services/search/src/indexer.py" << 'PYEOF'
"""Search indexer -- manages Elasticsearch indices."""

import logging

logger = logging.getLogger(__name__)


class SearchIndexer:
    """Manages search indices and document indexing."""

    def __init__(self, settings):
        self.settings = settings
        self._indices = {}

    def create_index(self, name, mapping):
        self._indices[name] = mapping
        logger.info("Created index: %s", name)

    def index_document(self, index_name, doc_id, document):
        logger.info("Indexed document %s in %s", doc_id, index_name)

    def search(self, index_name, query):
        logger.info("Searching %s for: %s", index_name, query)
        return []

    def start(self):
        logger.info("Search indexer started")
PYEOF

git -C "$TEMP_SEED" add services/search/
git -C "$TEMP_SEED" commit --quiet -m "feat(search): add search service with Elasticsearch indexer"

mkdir -p "$TEMP_SEED/services/search/tests"
cat > "$TEMP_SEED/services/search/tests/test_indexer.py" << 'PYEOF'
"""Tests for search indexer."""

import pytest
from src.indexer import SearchIndexer
from src.config import Settings


@pytest.fixture
def indexer():
    settings = Settings()
    return SearchIndexer(settings)


def test_create_index(indexer):
    indexer.create_index("test-index", {"mappings": {}})
    assert "test-index" in indexer._indices


def test_search_empty(indexer):
    results = indexer.search("test-index", "query")
    assert results == []
PYEOF

git -C "$TEMP_SEED" add services/search/tests/
git -C "$TEMP_SEED" commit --quiet -m "test(search): add indexer unit tests"

# Go back to main
git -C "$TEMP_SEED" checkout --quiet main

# 2. Create bare repo from seed (includes feature/search)
git clone --bare --quiet "$TEMP_SEED" "$BARE_REPO"

# 3. Clone for the learner (this gets main + origin/feature/search)
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"
git clone --quiet "$BARE_REPO" "$REPO"
configure_git_user "$REPO"

# 4. Create a local-only branch (feature/caching) with no upstream
# We do this by creating it from main -- it won't exist on origin
git -C "$REPO" checkout --quiet -b "feature/caching"

mkdir -p "$REPO/services/api/src"
cat > "$REPO/services/api/src/cache.py" << 'PYEOF'
"""Caching middleware for API service."""

import time
import logging

logger = logging.getLogger(__name__)


class CacheManager:
    """In-memory cache with TTL support."""

    def __init__(self, default_ttl=300):
        self.default_ttl = default_ttl
        self._store = {}

    def get(self, key):
        entry = self._store.get(key)
        if entry is None:
            return None
        if time.time() > entry["expires_at"]:
            del self._store[key]
            return None
        return entry["value"]

    def set(self, key, value, ttl=None):
        ttl = ttl or self.default_ttl
        self._store[key] = {
            "value": value,
            "expires_at": time.time() + ttl,
        }
        logger.debug("Cached key: %s (TTL: %ds)", key, ttl)

    def invalidate(self, key):
        self._store.pop(key, None)

    def clear(self):
        self._store.clear()
PYEOF

git -C "$REPO" add services/api/src/cache.py
git -C "$REPO" commit --quiet -m "feat(api): add caching middleware with TTL support"

cat > "$REPO/services/api/tests/test_cache.py" << 'PYEOF'
"""Tests for caching middleware."""

import pytest
from src.cache import CacheManager


def test_cache_set_get():
    cache = CacheManager()
    cache.set("key1", "value1")
    assert cache.get("key1") == "value1"


def test_cache_miss():
    cache = CacheManager()
    assert cache.get("nonexistent") is None


def test_cache_invalidate():
    cache = CacheManager()
    cache.set("key1", "value1")
    cache.invalidate("key1")
    assert cache.get("key1") is None


def test_cache_clear():
    cache = CacheManager()
    cache.set("key1", "value1")
    cache.set("key2", "value2")
    cache.clear()
    assert cache.get("key1") is None
    assert cache.get("key2") is None
PYEOF

git -C "$REPO" add services/api/tests/test_cache.py
git -C "$REPO" commit --quiet -m "test(api): add cache middleware tests"

# Ensure feature/caching has no upstream set
# (it shouldn't since we created it locally, not from a remote tracking branch)

# Go back to main so the learner starts there
git -C "$REPO" checkout --quiet main

# Clean up temp repos
rm -rf "$TEMP_SEED"

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "You are on 'main'. Two branches need attention:"
info "  - feature/search: exists on origin but not locally (check it out)"
info "  - feature/caching: exists locally but has no upstream (push and set upstream)"
info "Open lazygit with:"
echo ""
echo "  lazygit -p ${REPO}"
echo ""
