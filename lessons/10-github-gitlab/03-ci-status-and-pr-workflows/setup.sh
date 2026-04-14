#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="03-ci-status-and-pr-workflows"

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

# 1. Build seed repo
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

make_commits "$TEMP_SEED" 6

# Save the branch point
BRANCH_POINT=$(git -C "$TEMP_SEED" rev-parse HEAD)

# Create feature/logging branch with 2 commits
git -C "$TEMP_SEED" checkout --quiet -b "feature/logging"

cat > "$TEMP_SEED/services/api/src/logging_config.py" << 'PYEOF'
"""Structured logging configuration for the API service."""

import logging
import json
import sys


class JSONFormatter(logging.Formatter):
    """Format log records as JSON for structured log aggregation."""

    def format(self, record):
        log_entry = {
            "timestamp": self.formatTime(record),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "module": record.module,
            "function": record.funcName,
            "line": record.lineno,
        }
        if record.exc_info:
            log_entry["exception"] = self.formatException(record.exc_info)
        return json.dumps(log_entry)


def configure_logging(level="INFO", json_output=True):
    """Configure application-wide structured logging."""
    root = logging.getLogger()
    root.setLevel(getattr(logging, level.upper()))

    handler = logging.StreamHandler(sys.stdout)
    if json_output:
        handler.setFormatter(JSONFormatter())
    else:
        handler.setFormatter(logging.Formatter(
            "%(asctime)s [%(levelname)s] %(name)s: %(message)s"
        ))
    root.addHandler(handler)
    return root
PYEOF

git -C "$TEMP_SEED" add services/api/src/logging_config.py
git -C "$TEMP_SEED" commit --quiet -m "feat(api): add structured JSON logging configuration"

cat > "$TEMP_SEED/services/api/tests/test_logging.py" << 'PYEOF'
"""Tests for structured logging configuration."""

import json
import logging
import pytest
from src.logging_config import JSONFormatter, configure_logging


def test_json_formatter():
    formatter = JSONFormatter()
    record = logging.LogRecord(
        name="test", level=logging.INFO, pathname="test.py",
        lineno=1, msg="test message", args=(), exc_info=None,
    )
    output = formatter.format(record)
    parsed = json.loads(output)
    assert parsed["message"] == "test message"
    assert parsed["level"] == "INFO"


def test_configure_logging():
    logger = configure_logging(level="DEBUG", json_output=False)
    assert logger.level == logging.DEBUG
PYEOF

git -C "$TEMP_SEED" add services/api/tests/test_logging.py
git -C "$TEMP_SEED" commit --quiet -m "test(api): add structured logging tests"

# Go back to main and record
git -C "$TEMP_SEED" checkout --quiet main

# Create bare repo from seed
git clone --bare --quiet "$TEMP_SEED" "$BARE_REPO"

# Clone for learner
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"
git clone --quiet "$BARE_REPO" "$REPO"
configure_git_user "$REPO"

# Check out feature/logging and push it (so it exists on origin)
git -C "$REPO" checkout --quiet "feature/logging"
git -C "$REPO" push --quiet -u origin "feature/logging" 2>/dev/null

# Now simulate: main on origin moves ahead (teammate pushes)
TEMP_TEAMMATE="${SANDBOX_DIR}/${EXERCISE_NAME}-teammate"
if [[ -d "$TEMP_TEAMMATE" ]]; then
    rm -rf "$TEMP_TEAMMATE"
fi

git clone --quiet "$BARE_REPO" "$TEMP_TEAMMATE"
configure_git_user "$TEMP_TEAMMATE"

# Teammate commit 1: update worker config
cat >> "$TEMP_TEAMMATE/services/worker/src/config.py" << 'PYEOF'

# Health check configuration
HEALTH_CHECK_INTERVAL = 30
HEALTH_CHECK_TIMEOUT = 5
PYEOF

git -C "$TEMP_TEAMMATE" add services/worker/src/config.py
git -C "$TEMP_TEAMMATE" commit --quiet -m "feat(worker): add health check configuration"

# Teammate commit 2: update Makefile
cat >> "$TEMP_TEAMMATE/Makefile" << 'MKEOF'

health-check:
	@echo "Running health checks..."
	@curl -sf http://localhost:8080/health || echo "API unhealthy"
MKEOF

git -C "$TEMP_TEAMMATE" add Makefile
git -C "$TEMP_TEAMMATE" commit --quiet -m "chore: add health-check target to Makefile"

# Teammate commit 3: update common library
cat >> "$TEMP_TEAMMATE/libs/common/src/common.py" << 'PYEOF'


def retry_with_backoff(func, max_retries=3, base_delay=1.0):
    """Retry a function with exponential backoff."""
    import time
    for attempt in range(max_retries):
        try:
            return func()
        except Exception:
            if attempt == max_retries - 1:
                raise
            time.sleep(base_delay * (2 ** attempt))
PYEOF

git -C "$TEMP_TEAMMATE" add libs/common/src/common.py
git -C "$TEMP_TEAMMATE" commit --quiet -m "feat(libs/common): add retry with exponential backoff utility"

# Push teammate changes
git -C "$TEMP_TEAMMATE" push --quiet origin main

# Clean up temp repos
rm -rf "$TEMP_SEED" "$TEMP_TEAMMATE"

# At this point:
# - Learner is on feature/logging (pushed to origin)
# - origin/main is 3 commits ahead of where feature/logging branched from
# - Learner needs to: fetch, fast-forward main, rebase, force-push

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "You are on 'feature/logging'. It was pushed to origin earlier."
info "But main has moved ahead on origin -- your branch is out of date."
info "Rebase onto the latest main and force-push to update the PR."
info "Open lazygit with:"
echo ""
echo "  lazygit -p ${REPO}"
echo ""
