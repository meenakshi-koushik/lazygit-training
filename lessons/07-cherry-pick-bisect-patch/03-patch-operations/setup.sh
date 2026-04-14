#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="03-patch-operations"

info "Setting up exercise: ${EXERCISE_NAME}"

# Create the sandbox repo (idempotent -- cleans up first if it exists)
REPO=$(init_exercise_repo "$EXERCISE_NAME")

# --- Build the monorepo structure ---

create_monorepo "$REPO"
add_service "$REPO" "api"
add_service "$REPO" "worker"
add_library "$REPO" "common"
add_infra "$REPO"

# --- Override key files so the BASE versions do NOT have logging ---
# (add_service puts logging in main.py by default; we remove it so the
#  refactor commit can add it cleanly)

cat > "$REPO/services/api/src/routes.py" << 'PYEOF'
"""HTTP routes for api service."""

from flask import Flask, jsonify


def create_app(settings):
    app = Flask(__name__)

    @app.route("/health")
    def health():
        return jsonify({"status": "healthy", "service": "api"})

    @app.route("/api/v1/items")
    def list_items():
        return jsonify({"items": [], "total": 0})

    @app.route("/api/v1/items/<item_id>")
    def get_item(item_id):
        return jsonify({"item_id": item_id, "name": "placeholder"})

    return app
PYEOF

cat > "$REPO/services/api/src/config.py" << 'PYEOF'
"""Configuration for api service."""

import os


class Settings:
    def __init__(self):
        self.port = int(os.environ.get("PORT", 8080))
        self.debug = os.environ.get("DEBUG", "false").lower() == "true"
        self.db_url = os.environ.get("DATABASE_URL", "postgresql://localhost/api")
        self.log_level = os.environ.get("LOG_LEVEL", "INFO")
PYEOF

cat > "$REPO/services/api/tests/test_routes.py" << 'PYEOF'
"""Tests for api service routes."""

import pytest
from src.routes import create_app
from src.config import Settings


@pytest.fixture
def client():
    settings = Settings()
    app = create_app(settings)
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json["status"] == "healthy"


def test_list_items(client):
    response = client.get("/api/v1/items")
    assert response.status_code == 200
    assert "items" in response.json
PYEOF

cat > "$REPO/services/worker/src/main.py" << 'PYEOF'
"""Worker service entry point."""

from .config import Settings


def process_job(job):
    """Process a single job from the queue."""
    job_type = job.get("type", "unknown")
    payload = job.get("payload", {})
    # Process based on job type
    if job_type == "email":
        send_email(payload)
    elif job_type == "report":
        generate_report(payload)
    return {"status": "completed", "job_type": job_type}


def send_email(payload):
    """Send an email notification."""
    recipient = payload.get("to", "")
    subject = payload.get("subject", "No subject")
    # Email sending logic here
    return True


def generate_report(payload):
    """Generate a report."""
    report_type = payload.get("type", "summary")
    # Report generation logic here
    return {"report_type": report_type}


def main():
    settings = Settings()
    print(f"Starting worker service on port {settings.port}")


if __name__ == "__main__":
    main()
PYEOF

cat > "$REPO/libs/common/src/common.py" << 'PYEOF'
"""common -- shared library."""


class CommonClient:
    """Client for common operations."""

    def __init__(self, config=None):
        self.config = config or {}
        self._initialized = False

    def initialize(self):
        """Set up the client connection."""
        self._initialized = True
        return self

    def is_ready(self):
        return self._initialized


def format_error(error_code, message):
    """Format a standard error response."""
    return {
        "error": {
            "code": error_code,
            "message": message,
        }
    }


def validate_payload(payload, required_fields):
    """Validate that a payload contains all required fields."""
    missing = [f for f in required_fields if f not in payload]
    if missing:
        raise ValueError(f"Missing required fields: {', '.join(missing)}")
    return True
PYEOF

# --- Initial commit ---

git -C "$REPO" add -A
git -C "$REPO" commit --quiet -m "chore: initial monorepo scaffolding"

# --- Build realistic main branch history (8 commits) ---

make_commits "$REPO" 8

# --- Create feature/refactor branch from main ---

git -C "$REPO" checkout --quiet -b "feature/refactor"

# Intermediate commits on feature/refactor MUST NOT touch the same files
# as the big refactor commit, so the patch context will match feature/logging.

# First commit: add a new middleware file (does not affect the 5 refactored files)
cat > "$REPO/services/api/src/middleware.py" << 'PYEOF'
"""Middleware for api service."""


def rate_limit_middleware(app, max_requests=100):
    """Add rate limiting to the application."""
    request_counts = {}

    def check_rate_limit(request):
        client_ip = request.remote_addr
        count = request_counts.get(client_ip, 0)
        if count >= max_requests:
            return False
        request_counts[client_ip] = count + 1
        return True

    return check_rate_limit
PYEOF
git -C "$REPO" add services/api/src/middleware.py
git -C "$REPO" commit --quiet -m "feat(api): add rate limiting middleware"

# Second commit: add a new scheduler file (does not affect the 5 refactored files)
cat > "$REPO/services/worker/src/scheduler.py" << 'PYEOF'
"""Job scheduler for worker service."""


class JobScheduler:
    """Schedule and manage recurring jobs."""

    def __init__(self, interval=60):
        self.interval = interval
        self.jobs = []

    def add_job(self, func, name=None):
        self.jobs.append({"func": func, "name": name or func.__name__})

    def run_pending(self):
        for job in self.jobs:
            job["func"]()
PYEOF
git -C "$REPO" add services/worker/src/scheduler.py
git -C "$REPO" commit --quiet -m "feat(worker): add job scheduler module"

# --- Third commit: the BIG REFACTOR (touches 5 files) ---

# 1. routes.py -- ADD LOGGING (learner WANTS this)
cat > "$REPO/services/api/src/routes.py" << 'PYEOF'
"""HTTP routes for api service."""

import logging
from flask import Flask, jsonify

logger = logging.getLogger(__name__)


def create_app(settings):
    app = Flask(__name__)

    @app.route("/health")
    def health():
        logger.debug("Health check requested")
        return jsonify({"status": "healthy", "service": "api"})

    @app.route("/api/v1/items")
    def list_items():
        logger.info("Listing all items")
        return jsonify({"items": [], "total": 0})

    @app.route("/api/v1/items/<item_id>")
    def get_item(item_id):
        logger.info("Fetching item %s", item_id)
        return jsonify({"item_id": item_id, "name": "placeholder"})

    return app
PYEOF

# 2. config.py -- CHANGE CONFIG PATTERN (learner does NOT want this)
cat > "$REPO/services/api/src/config.py" << 'PYEOF'
"""Configuration for api service."""

import os

# REFACTORED_CONFIG_V2: centralized config loading
_DEFAULTS = {
    "PORT": "8080",
    "DEBUG": "false",
    "DATABASE_URL": "postgresql://localhost/api",
    "LOG_LEVEL": "INFO",
    "MAX_CONNECTIONS": "100",
    "REQUEST_TIMEOUT": "30",
}


class Settings:
    @classmethod
    def from_env(cls):
        """Load settings from environment with defaults."""
        instance = cls()
        for key, default in _DEFAULTS.items():
            setattr(instance, key.lower(), os.environ.get(key, default))
        instance.port = int(instance.port)
        instance.debug = instance.debug.lower() == "true"
        instance.max_connections = int(instance.max_connections)
        instance.request_timeout = int(instance.request_timeout)
        return instance

    def __init__(self):
        self.port = int(os.environ.get("PORT", 8080))
        self.debug = os.environ.get("DEBUG", "false").lower() == "true"
        self.db_url = os.environ.get("DATABASE_URL", "postgresql://localhost/api")
        self.log_level = os.environ.get("LOG_LEVEL", "INFO")
        self.max_connections = int(os.environ.get("MAX_CONNECTIONS", 100))
        self.request_timeout = int(os.environ.get("REQUEST_TIMEOUT", 30))
PYEOF

# 3. worker/main.py -- ADD LOGGING (learner WANTS this)
cat > "$REPO/services/worker/src/main.py" << 'PYEOF'
"""Worker service entry point."""

import logging
from .config import Settings

logger = logging.getLogger(__name__)


def process_job(job):
    """Process a single job from the queue."""
    job_type = job.get("type", "unknown")
    payload = job.get("payload", {})
    logger.info("Processing job type=%s", job_type)
    # Process based on job type
    if job_type == "email":
        send_email(payload)
    elif job_type == "report":
        generate_report(payload)
    logger.info("Job completed type=%s", job_type)
    return {"status": "completed", "job_type": job_type}


def send_email(payload):
    """Send an email notification."""
    recipient = payload.get("to", "")
    subject = payload.get("subject", "No subject")
    logger.info("Sending email to=%s subject=%s", recipient, subject)
    # Email sending logic here
    return True


def generate_report(payload):
    """Generate a report."""
    report_type = payload.get("type", "summary")
    logger.info("Generating report type=%s", report_type)
    # Report generation logic here
    return {"report_type": report_type}


def main():
    settings = Settings()
    logger.info("Starting worker service on port %d", settings.port)


if __name__ == "__main__":
    main()
PYEOF

# 4. common.py -- ADD LOGGING UTILITY (learner WANTS this)
cat > "$REPO/libs/common/src/common.py" << 'PYEOF'
"""common -- shared library."""

import logging


class CommonClient:
    """Client for common operations."""

    def __init__(self, config=None):
        self.config = config or {}
        self._initialized = False

    def initialize(self):
        """Set up the client connection."""
        self._initialized = True
        return self

    def is_ready(self):
        return self._initialized


def format_error(error_code, message):
    """Format a standard error response."""
    return {
        "error": {
            "code": error_code,
            "message": message,
        }
    }


def validate_payload(payload, required_fields):
    """Validate that a payload contains all required fields."""
    missing = [f for f in required_fields if f not in payload]
    if missing:
        raise ValueError(f"Missing required fields: {', '.join(missing)}")
    return True


def get_logger(name, level=logging.INFO):
    """Create a configured logger with standard formatting.

    Usage:
        logger = get_logger(__name__)
        logger.info("Service started")
    """
    logger = logging.getLogger(name)
    if not logger.handlers:
        handler = logging.StreamHandler()
        formatter = logging.Formatter(
            "%(asctime)s [%(levelname)s] %(name)s: %(message)s"
        )
        handler.setFormatter(formatter)
        logger.addHandler(handler)
    logger.setLevel(level)
    return logger
PYEOF

# 5. test_routes.py -- UPDATE TESTS FOR CONFIG (learner does NOT want this)
cat > "$REPO/services/api/tests/test_routes.py" << 'PYEOF'
"""Tests for api service routes."""

import pytest
from src.routes import create_app
from src.config import Settings


@pytest.fixture
def client():
    settings = Settings.from_env()
    app = create_app(settings)
    app.config["TESTING"] = True
    with app.test_client() as client:
        yield client


def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json["status"] == "healthy"


def test_list_items(client):
    response = client.get("/api/v1/items")
    assert response.status_code == 200
    assert "items" in response.json


def test_settings_from_env():
    """Test the refactored config loading."""
    settings = Settings.from_env()
    assert settings.port == 8080
    assert settings.debug is False
    assert settings.max_connections == 100
    assert settings.request_timeout == 30
PYEOF

git -C "$REPO" add -A
git -C "$REPO" commit --quiet -m "refactor: cross-service logging and config restructure"

# Tag the big refactor commit
git -C "$REPO" tag "big-refactor"

# One more commit after the refactor
cat >> "$REPO/docs/README.md" << 'EOF'

## Logging

All services now use Python's `logging` module with structured log formatting
provided by `libs/common`. See `get_logger()` for the standard setup.
EOF
git -C "$REPO" add docs/README.md
git -C "$REPO" commit --quiet -m "docs: add logging section to README"

# --- Create feature/logging branch from main ---

git -C "$REPO" checkout --quiet main
git -C "$REPO" checkout --quiet -b "feature/logging"

# Tag the starting point so verify can count commits ahead
git -C "$REPO" tag "logging-start"

# --- Done ---

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "You are on branch 'feature/logging' with a clean working tree."
info "The big refactor commit is tagged 'big-refactor' on 'feature/refactor'."
info "Open lazygit with:"
echo ""
echo "  lazygit -p ${REPO}"
echo ""
