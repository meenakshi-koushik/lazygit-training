#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="02-rebase-conflicts"

info "Setting up exercise: ${EXERCISE_NAME}"

# Create the sandbox repo (idempotent)
REPO=$(init_exercise_repo "$EXERCISE_NAME")

# --- Build the monorepo structure ---

create_monorepo "$REPO"
add_service "$REPO" "api"
add_service "$REPO" "worker"
add_library "$REPO" "common"
add_infra "$REPO"

# Initial commit
git -C "$REPO" add -A
git -C "$REPO" commit --quiet -m "chore: initial monorepo scaffolding"

# Build baseline history on main
make_commits "$REPO" 5

# Save divergence point
git -C "$REPO" tag "divergence-point"

# --- Feature branch: 3 commits that will each conflict ---

git -C "$REPO" checkout --quiet -b "feature/worker-retry"

# Feature commit 1: change worker config
cat > "$REPO/services/worker/src/config.py" << 'PYEOF'
"""Configuration for worker service."""

import os


class Settings:
    def __init__(self):
        self.port = int(os.environ.get("PORT", 8080))
        self.debug = os.environ.get("DEBUG", "false").lower() == "true"
        self.db_url = os.environ.get("DATABASE_URL", "postgresql://localhost/worker")
        self.log_level = os.environ.get("LOG_LEVEL", "INFO")
        self.retry_count = int(os.environ.get("RETRY_COUNT", 3))
        self.retry_delay = int(os.environ.get("RETRY_DELAY", 5))
PYEOF
git -C "$REPO" add services/worker/src/config.py
git -C "$REPO" commit --quiet -m "feat(worker): add retry configuration"

# Feature commit 2: change worker main.py
cat > "$REPO/services/worker/src/main.py" << 'PYEOF'
"""worker service entry point."""

import logging
import time
from .config import Settings

logger = logging.getLogger(__name__)


def process_job(job, settings):
    """Process a job with retry logic."""
    for attempt in range(settings.retry_count):
        try:
            logger.info("Processing job %s (attempt %d)", job["id"], attempt + 1)
            # Simulate job processing
            return {"status": "completed", "job_id": job["id"]}
        except Exception as e:
            logger.warning("Attempt %d failed: %s", attempt + 1, str(e))
            if attempt < settings.retry_count - 1:
                time.sleep(settings.retry_delay)
    return {"status": "failed", "job_id": job["id"]}


def main():
    settings = Settings()
    logger.info("Starting worker service on port %d", settings.port)


if __name__ == "__main__":
    main()
PYEOF
git -C "$REPO" add services/worker/src/main.py
git -C "$REPO" commit --quiet -m "feat(worker): implement retry logic in job processor"

# Feature commit 3: add tests
cat > "$REPO/services/worker/tests/test_routes.py" << 'PYEOF'
"""Tests for worker service retry logic."""

import pytest
from src.main import process_job
from src.config import Settings


@pytest.fixture
def settings():
    s = Settings()
    s.retry_count = 2
    s.retry_delay = 0
    return s


def test_successful_job(settings):
    job = {"id": "test-001", "payload": "data"}
    result = process_job(job, settings)
    assert result["status"] == "completed"
    assert result["job_id"] == "test-001"
PYEOF
git -C "$REPO" add services/worker/tests/test_routes.py
git -C "$REPO" commit --quiet -m "test(worker): add retry logic unit tests"

# --- Meanwhile, main gets commits that conflict with the feature branch ---

git -C "$REPO" checkout --quiet main

# Main commit 1: teammate changes worker config differently
cat > "$REPO/services/worker/src/config.py" << 'PYEOF'
"""Configuration for worker service."""

import os


class Settings:
    def __init__(self):
        self.port = int(os.environ.get("PORT", 8080))
        self.debug = os.environ.get("DEBUG", "false").lower() == "true"
        self.db_url = os.environ.get("DATABASE_URL", "postgresql://localhost/worker")
        self.log_level = os.environ.get("LOG_LEVEL", "INFO")
        self.batch_size = int(os.environ.get("BATCH_SIZE", 50))
        self.queue_name = os.environ.get("QUEUE_NAME", "default")
PYEOF
git -C "$REPO" add services/worker/src/config.py
git -C "$REPO" commit --quiet -m "feat(worker): add batch processing configuration"

# Main commit 2: teammate changes worker main.py differently
cat > "$REPO/services/worker/src/main.py" << 'PYEOF'
"""worker service entry point."""

import logging
from .config import Settings

logger = logging.getLogger(__name__)


def process_batch(jobs, settings):
    """Process a batch of jobs."""
    results = []
    for job in jobs[:settings.batch_size]:
        logger.info("Processing job %s", job["id"])
        results.append({"status": "completed", "job_id": job["id"]})
    return results


def main():
    settings = Settings()
    logger.info("Starting worker service on port %d", settings.port)
    logger.info("Batch size: %d, Queue: %s", settings.batch_size, settings.queue_name)


if __name__ == "__main__":
    main()
PYEOF
git -C "$REPO" add services/worker/src/main.py
git -C "$REPO" commit --quiet -m "feat(worker): implement batch job processing"

# Main commit 3: unrelated change to keep things moving
make_commits "$REPO" 2

# --- Switch back to feature branch and leave it for the learner to rebase ---

git -C "$REPO" checkout --quiet "feature/worker-retry"

# Tag the state for verification
git -C "$REPO" tag "pre-rebase" HEAD

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "Your task: rebase feature/worker-retry onto main, resolving conflicts commit by commit"
info "Open lazygit in the sandbox:"
echo ""
echo "  lazygit -p ${REPO}"
echo ""
