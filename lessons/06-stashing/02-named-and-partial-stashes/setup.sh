#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="02-named-and-partial-stashes"

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
make_commits "$REPO" 5

# --- Create the feature branch with some prior work ---

git -C "$REPO" checkout --quiet -b "feature/notifications"

# A couple of commits on the feature branch to establish context
cat > "$REPO/services/api/src/routes.py" << 'PYEOF'
"""HTTP routes for api service."""

from flask import Flask, jsonify


def create_app(settings):
    app = Flask(__name__)

    @app.route("/health")
    def health():
        return jsonify({"status": "healthy", "service": "api"})

    @app.route("/api/v1/api")
    def index():
        return jsonify({"message": "Welcome to api"})

    @app.route("/api/v1/notifications/settings")
    def notification_settings():
        return jsonify({"email": True, "sms": False, "push": True})

    return app
PYEOF

git -C "$REPO" add services/api/src/routes.py
git -C "$REPO" commit --quiet -m "feat(api): add notification settings endpoint"

cat > "$REPO/services/worker/src/main.py" << 'PYEOF'
"""worker service entry point."""

import logging
from .config import Settings
from .routes import create_app

logger = logging.getLogger(__name__)


def main():
    settings = Settings()
    app = create_app(settings)
    logger.info("Starting worker service on port %d", settings.port)
    logger.info("Notification queue polling enabled")
    app.run(host="0.0.0.0", port=settings.port)


if __name__ == "__main__":
    main()
PYEOF

git -C "$REPO" add services/worker/src/main.py
git -C "$REPO" commit --quiet -m "feat(worker): enable notification queue polling"

# --- Commit placeholder versions of the 4 files we want to show as modified ---
# We commit minimal stubs so the working-tree changes appear as "modified" not "untracked".

# API notifications.py -- stub
cat > "$REPO/services/api/src/notifications.py" << 'PYEOF'
"""Notification dispatch -- placeholder."""
PYEOF

# Worker queue.py -- stub
cat > "$REPO/services/worker/src/queue.py" << 'PYEOF'
"""Notification queue -- placeholder."""
PYEOF

git -C "$REPO" add services/api/src/notifications.py services/worker/src/queue.py
git -C "$REPO" commit --quiet -m "feat: add notification module placeholders"

# --- Now overwrite all 4 files with the real content to create unstaged modifications ---

# API service file 1: notification dispatcher (full implementation)
cat > "$REPO/services/api/src/notifications.py" << 'PYEOF'
"""Notification dispatch logic for the API service."""

import logging

logger = logging.getLogger(__name__)


class NotificationDispatcher:
    """Dispatches notifications to the appropriate channel."""

    def __init__(self, config):
        self.config = config
        self.channels = ["email", "sms", "push"]

    def dispatch(self, user_id, message, channel="email"):
        """Send a notification to a user on the given channel."""
        if channel not in self.channels:
            raise ValueError(f"Unknown channel: {channel}")
        logger.info("Dispatching %s notification to user %s", channel, user_id)
        return {"status": "sent", "channel": channel, "user_id": user_id}

    def dispatch_all(self, user_id, message):
        """Send a notification on all enabled channels."""
        results = []
        for channel in self.channels:
            results.append(self.dispatch(user_id, message, channel))
        return results
PYEOF

# API service file 2: config with notification settings
cat > "$REPO/services/api/src/config.py" << 'PYEOF'
"""Configuration for api service."""

import os


class Settings:
    def __init__(self):
        self.port = int(os.environ.get("PORT", 8080))
        self.debug = os.environ.get("DEBUG", "false").lower() == "true"
        self.db_url = os.environ.get("DATABASE_URL", "postgresql://localhost/api")
        self.log_level = os.environ.get("LOG_LEVEL", "INFO")
        self.notification_email_enabled = os.environ.get("NOTIFY_EMAIL", "true").lower() == "true"
        self.notification_sms_enabled = os.environ.get("NOTIFY_SMS", "false").lower() == "true"
        self.notification_push_enabled = os.environ.get("NOTIFY_PUSH", "true").lower() == "true"
        self.notification_rate_limit = int(os.environ.get("NOTIFY_RATE_LIMIT", 100))
PYEOF

# Worker service file 1: notification queue processor (full implementation)
cat > "$REPO/services/worker/src/queue.py" << 'PYEOF'
"""Notification queue processor for the worker service."""

import logging
import time

logger = logging.getLogger(__name__)


class NotificationQueue:
    """Processes notifications from the message queue."""

    def __init__(self, config):
        self.config = config
        self.poll_interval = config.get("poll_interval", 5)
        self._running = False

    def start(self):
        """Begin processing notifications from the queue."""
        self._running = True
        logger.info("Notification queue processor started (poll every %ds)", self.poll_interval)
        while self._running:
            messages = self._poll()
            for msg in messages:
                self._process(msg)
            time.sleep(self.poll_interval)

    def stop(self):
        """Stop the queue processor gracefully."""
        self._running = False
        logger.info("Notification queue processor stopping")

    def _poll(self):
        """Poll the queue for new messages."""
        return []

    def _process(self, message):
        """Process a single notification message."""
        logger.info("Processing notification: %s", message.get("id", "unknown"))
PYEOF

# Worker service file 2: config with queue settings
cat > "$REPO/services/worker/src/config.py" << 'PYEOF'
"""Configuration for worker service."""

import os


class Settings:
    def __init__(self):
        self.port = int(os.environ.get("PORT", 8080))
        self.debug = os.environ.get("DEBUG", "false").lower() == "true"
        self.db_url = os.environ.get("DATABASE_URL", "postgresql://localhost/worker")
        self.log_level = os.environ.get("LOG_LEVEL", "INFO")
        self.queue_url = os.environ.get("QUEUE_URL", "amqp://localhost:5672")
        self.queue_poll_interval = int(os.environ.get("QUEUE_POLL_INTERVAL", 5))
        self.queue_max_retries = int(os.environ.get("QUEUE_MAX_RETRIES", 3))
        self.queue_dead_letter_enabled = os.environ.get("QUEUE_DLQ", "true").lower() == "true"
PYEOF

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "You have 4 unstaged modified files across services/api/ and services/worker/"
info "Open lazygit in the sandbox:"
echo ""
echo "  lazygit -p ${REPO}"
echo ""
