#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="01-fetch-pull-push-patterns"

info "Setting up exercise: ${EXERCISE_NAME}"

# --- Create a bare repo to act as "origin" ---

BARE_REPO="${SANDBOX_DIR}/${EXERCISE_NAME}-origin.git"
if [[ -d "$BARE_REPO" ]]; then
    rm -rf "$BARE_REPO"
fi

# We need a temporary repo to seed the bare origin
TEMP_SEED="${SANDBOX_DIR}/${EXERCISE_NAME}-seed"
if [[ -d "$TEMP_SEED" ]]; then
    rm -rf "$TEMP_SEED"
fi

# Create the sandbox repo first (will be replaced by clone later)
ensure_sandbox
clean_sandbox "$EXERCISE_NAME"

# 1. Build a seed repo with a monorepo structure and history
mkdir -p "$TEMP_SEED"
git -C "$TEMP_SEED" init --quiet
configure_git_user "$TEMP_SEED"

create_monorepo "$TEMP_SEED"
add_service "$TEMP_SEED" "api"
add_service "$TEMP_SEED" "worker"
add_service "$TEMP_SEED" "auth"
add_library "$TEMP_SEED" "common"
add_infra "$TEMP_SEED"

git -C "$TEMP_SEED" add -A
git -C "$TEMP_SEED" commit --quiet -m "chore: initial monorepo scaffolding"

# Build up main branch history (10 commits)
make_commits "$TEMP_SEED" 10

# Create the feature/notifications branch with 3 commits
git -C "$TEMP_SEED" checkout --quiet -b "feature/notifications"

# Commit 1: add notification service skeleton
mkdir -p "$TEMP_SEED/services/notifications/src"
cat > "$TEMP_SEED/services/notifications/src/main.py" << 'PYEOF'
"""Notification service entry point."""

import logging
from .config import Settings
from .dispatcher import NotificationDispatcher

logger = logging.getLogger(__name__)


def main():
    settings = Settings()
    dispatcher = NotificationDispatcher(settings)
    logger.info("Starting notification service on port %d", settings.port)
    dispatcher.start()


if __name__ == "__main__":
    main()
PYEOF

cat > "$TEMP_SEED/services/notifications/src/config.py" << 'PYEOF'
"""Configuration for notification service."""

import os


class Settings:
    def __init__(self):
        self.port = int(os.environ.get("PORT", 8084))
        self.debug = os.environ.get("DEBUG", "false").lower() == "true"
        self.smtp_host = os.environ.get("SMTP_HOST", "localhost")
        self.smtp_port = int(os.environ.get("SMTP_PORT", 587))
        self.redis_url = os.environ.get("REDIS_URL", "redis://localhost:6379/0")
PYEOF

cat > "$TEMP_SEED/services/notifications/src/dispatcher.py" << 'PYEOF'
"""Notification dispatcher -- routes notifications to channels."""

import logging

logger = logging.getLogger(__name__)


class NotificationDispatcher:
    """Dispatches notifications to email, Slack, and webhook channels."""

    def __init__(self, settings):
        self.settings = settings
        self._channels = {}

    def register_channel(self, name, handler):
        self._channels[name] = handler
        logger.info("Registered notification channel: %s", name)

    def dispatch(self, notification):
        channel = notification.get("channel", "email")
        handler = self._channels.get(channel)
        if handler:
            handler(notification)
        else:
            logger.warning("No handler for channel: %s", channel)

    def start(self):
        logger.info("Notification dispatcher started")
PYEOF

cat > "$TEMP_SEED/services/notifications/src/__init__.py" << 'PYEOF'
PYEOF

git -C "$TEMP_SEED" add services/notifications/
git -C "$TEMP_SEED" commit --quiet -m "feat(notifications): add notification service skeleton"

# Commit 2: add notification templates
mkdir -p "$TEMP_SEED/services/notifications/templates"
cat > "$TEMP_SEED/services/notifications/templates/welcome.html" << 'HTMLEOF'
<!DOCTYPE html>
<html>
<body>
    <h1>Welcome to the Platform</h1>
    <p>Hello {{ user.name }}, your account has been created.</p>
</body>
</html>
HTMLEOF

cat > "$TEMP_SEED/services/notifications/templates/alert.html" << 'HTMLEOF'
<!DOCTYPE html>
<html>
<body>
    <h1>Alert: {{ alert.title }}</h1>
    <p>Severity: {{ alert.severity }}</p>
    <p>{{ alert.message }}</p>
</body>
</html>
HTMLEOF

git -C "$TEMP_SEED" add services/notifications/templates/
git -C "$TEMP_SEED" commit --quiet -m "feat(notifications): add email templates for welcome and alert"

# Commit 3: add notification tests
mkdir -p "$TEMP_SEED/services/notifications/tests"
cat > "$TEMP_SEED/services/notifications/tests/test_dispatcher.py" << 'PYEOF'
"""Tests for notification dispatcher."""

import pytest
from src.dispatcher import NotificationDispatcher
from src.config import Settings


@pytest.fixture
def dispatcher():
    settings = Settings()
    return NotificationDispatcher(settings)


def test_register_channel(dispatcher):
    dispatcher.register_channel("email", lambda n: None)
    assert "email" in dispatcher._channels


def test_dispatch_unknown_channel(dispatcher):
    # Should not raise, just log a warning
    dispatcher.dispatch({"channel": "unknown", "message": "test"})


def test_dispatch_known_channel(dispatcher):
    received = []
    dispatcher.register_channel("email", lambda n: received.append(n))
    dispatcher.dispatch({"channel": "email", "message": "test"})
    assert len(received) == 1
PYEOF

git -C "$TEMP_SEED" add services/notifications/tests/
git -C "$TEMP_SEED" commit --quiet -m "test(notifications): add dispatcher unit tests"

# Now go back to main and record the current state
git -C "$TEMP_SEED" checkout --quiet main

# 2. Create the bare repo from the seed
git clone --bare --quiet "$TEMP_SEED" "$BARE_REPO"

# 3. Clone the bare repo to create the learner's sandbox
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"
git clone --quiet "$BARE_REPO" "$REPO"
configure_git_user "$REPO"

# 4. Check out the feature branch in the learner's repo
git -C "$REPO" checkout --quiet "feature/notifications"

# 5. Now simulate teammate activity: add more commits to main on origin
# We do this by pushing directly to the bare repo via temp clone
TEMP_TEAMMATE="${SANDBOX_DIR}/${EXERCISE_NAME}-teammate"
if [[ -d "$TEMP_TEAMMATE" ]]; then
    rm -rf "$TEMP_TEAMMATE"
fi

git clone --quiet "$BARE_REPO" "$TEMP_TEAMMATE"
configure_git_user "$TEMP_TEAMMATE"

# Teammate commit 1: update API rate limiting
cat >> "$TEMP_TEAMMATE/services/api/src/routes.py" << 'PYEOF'


# Rate limiting configuration
RATE_LIMIT_WINDOW = 60  # seconds
RATE_LIMIT_MAX_REQUESTS = 100
PYEOF

git -C "$TEMP_TEAMMATE" add services/api/src/routes.py
git -C "$TEMP_TEAMMATE" commit --quiet -m "feat(api): add rate limiting configuration"

# Teammate commit 2: update infrastructure
cat >> "$TEMP_TEAMMATE/infra/terraform/main.tf" << 'TFEOF'

module "monitoring" {
  source = "./modules/monitoring"
  cluster_name = module.eks.cluster_name
}
TFEOF

git -C "$TEMP_TEAMMATE" add infra/terraform/main.tf
git -C "$TEMP_TEAMMATE" commit --quiet -m "feat(infra): add monitoring module"

# Teammate commit 3: update common library
cat >> "$TEMP_TEAMMATE/libs/common/src/common.py" << 'PYEOF'


def format_timestamp(ts):
    """Format a Unix timestamp to ISO 8601."""
    from datetime import datetime, timezone
    return datetime.fromtimestamp(ts, tz=timezone.utc).isoformat()
PYEOF

git -C "$TEMP_TEAMMATE" add libs/common/src/common.py
git -C "$TEMP_TEAMMATE" commit --quiet -m "feat(libs/common): add timestamp formatting utility"

# Teammate commit 4: fix worker bug
cat >> "$TEMP_TEAMMATE/services/worker/src/main.py" << 'PYEOF'

# Fix: ensure graceful shutdown on SIGTERM
import signal
signal.signal(signal.SIGTERM, lambda *_: exit(0))
PYEOF

git -C "$TEMP_TEAMMATE" add services/worker/src/main.py
git -C "$TEMP_TEAMMATE" commit --quiet -m "fix(worker): handle SIGTERM for graceful shutdown"

# Push teammate's changes to the bare origin
git -C "$TEMP_TEAMMATE" push --quiet origin main

# Clean up temp repos
rm -rf "$TEMP_SEED" "$TEMP_TEAMMATE"

# At this point:
# - The learner's repo has origin pointing to the bare repo
# - origin/main is 4 commits ahead of the learner's local main
# - But the learner hasn't fetched yet, so they don't see those commits
# - feature/notifications has 3 unpushed commits

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "You are on branch 'feature/notifications' with 3 unpushed commits."
info "Your teammates have pushed 4 new commits to main on origin."
info "Your local main is behind -- you need to fetch, fast-forward, and push."
info "Open lazygit with:"
echo ""
echo "  lazygit -p ${REPO}"
echo ""
