#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="01-creating-worktrees"

info "Setting up exercise: ${EXERCISE_NAME}"

# Clean up any leftover worktree directory from a previous run.
# init_exercise_repo will remove the main sandbox, but the worktree
# directory is a sibling, so we must handle it separately.
WORKTREE_DIR="${SANDBOX_DIR}/${EXERCISE_NAME}-dashboard"
if [[ -d "$WORKTREE_DIR" ]]; then
    # Try to cleanly remove via git first (if the main repo still exists)
    EXISTING_REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"
    if [[ -d "$EXISTING_REPO/.git" ]]; then
        git -C "$EXISTING_REPO" worktree remove --force "$WORKTREE_DIR" 2>/dev/null || true
    fi
    rm -rf "$WORKTREE_DIR"
fi

# Create the sandbox repo (idempotent -- cleans up first if it exists)
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

# Build up main branch history (8 commits)
make_commits "$REPO" 8

# --- Create feature/dashboard branch from main with 3 commits ---

git -C "$REPO" checkout --quiet -b "feature/dashboard"

# Commit 1: add dashboard service skeleton
mkdir -p "$REPO/services/dashboard/src"
cat > "$REPO/services/dashboard/src/main.py" << 'PYEOF'
"""Dashboard service entry point."""

import logging
from .config import Settings
from .routes import create_app

logger = logging.getLogger(__name__)


def main():
    settings = Settings()
    app = create_app(settings)
    logger.info("Starting dashboard service on port %d", settings.port)
    app.run(host="0.0.0.0", port=settings.port)


if __name__ == "__main__":
    main()
PYEOF

cat > "$REPO/services/dashboard/src/config.py" << 'PYEOF'
"""Configuration for dashboard service."""

import os


class Settings:
    def __init__(self):
        self.port = int(os.environ.get("PORT", 8083))
        self.debug = os.environ.get("DEBUG", "false").lower() == "true"
        self.db_url = os.environ.get("DATABASE_URL", "postgresql://localhost/dashboard")
        self.log_level = os.environ.get("LOG_LEVEL", "INFO")
        self.metrics_enabled = os.environ.get("METRICS_ENABLED", "true").lower() == "true"
PYEOF

cat > "$REPO/services/dashboard/src/__init__.py" << 'PYEOF'
PYEOF

git -C "$REPO" add services/dashboard/
git -C "$REPO" commit --quiet -m "feat(dashboard): add dashboard service skeleton"

# Commit 2: add dashboard routes with widget endpoints
cat > "$REPO/services/dashboard/src/routes.py" << 'PYEOF'
"""HTTP routes for dashboard service."""

from flask import Flask, jsonify, request


def create_app(settings):
    app = Flask(__name__)

    @app.route("/health")
    def health():
        return jsonify({"status": "healthy", "service": "dashboard"})

    @app.route("/api/v1/dashboard/widgets", methods=["GET"])
    def list_widgets():
        """Return available dashboard widgets."""
        widgets = [
            {"id": "active-users", "type": "counter", "label": "Active Users"},
            {"id": "requests-per-min", "type": "gauge", "label": "Requests/min"},
            {"id": "error-rate", "type": "chart", "label": "Error Rate (24h)"},
        ]
        return jsonify({"widgets": widgets})

    @app.route("/api/v1/dashboard/layout", methods=["GET", "POST"])
    def dashboard_layout():
        """Get or update the dashboard layout."""
        if request.method == "POST":
            data = request.get_json()
            return jsonify({"updated": True, "layout": data}), 200
        return jsonify({"layout": {"columns": 3, "widgets": []}})

    return app
PYEOF

git -C "$REPO" add services/dashboard/src/routes.py
git -C "$REPO" commit --quiet -m "feat(dashboard): add widget and layout endpoints"

# Commit 3: add dashboard tests
mkdir -p "$REPO/services/dashboard/tests"
cat > "$REPO/services/dashboard/tests/test_routes.py" << 'PYEOF'
"""Tests for dashboard service routes."""

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


def test_list_widgets(client):
    response = client.get("/api/v1/dashboard/widgets")
    assert response.status_code == 200
    assert len(response.json["widgets"]) == 3


def test_get_layout(client):
    response = client.get("/api/v1/dashboard/layout")
    assert response.status_code == 200
    assert "layout" in response.json
PYEOF

git -C "$REPO" add services/dashboard/tests/
git -C "$REPO" commit --quiet -m "test(dashboard): add route tests for widgets and layout"

# --- Create feature/auth branch from main with 2 commits ---

git -C "$REPO" checkout --quiet main
git -C "$REPO" checkout --quiet -b "feature/auth"

# Commit 1: add auth middleware module
cat > "$REPO/services/api/src/auth.py" << 'PYEOF'
"""Authentication middleware for the API service."""

import functools
from flask import request, jsonify


def require_auth(f):
    """Decorator that enforces authentication on a route."""

    @functools.wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get("Authorization", "")
        if not token.startswith("Bearer "):
            return jsonify({"error": "Missing or invalid token"}), 401
        # TODO: validate token against auth provider
        return f(*args, **kwargs)

    return decorated


def validate_token(token):
    """Validate a JWT token and return the decoded claims."""
    # Placeholder -- will integrate with libs/common JWT utils
    if not token:
        return None
    return {"sub": "user-123", "exp": 9999999999}
PYEOF

git -C "$REPO" add services/api/src/auth.py
git -C "$REPO" commit --quiet -m "feat(api): add authentication middleware"

# Commit 2: add auth tests
cat > "$REPO/services/api/tests/test_auth.py" << 'PYEOF'
"""Tests for authentication middleware."""

import pytest
from src.auth import validate_token


def test_validate_token_empty():
    assert validate_token("") is None
    assert validate_token(None) is None


def test_validate_token_valid():
    result = validate_token("valid-token-string")
    assert result is not None
    assert "sub" in result
PYEOF

git -C "$REPO" add services/api/tests/test_auth.py
git -C "$REPO" commit --quiet -m "test(api): add authentication middleware tests"

# --- Add uncommitted WIP changes on feature/auth ---

# WIP 1: update the auth module with token refresh logic
cat >> "$REPO/services/api/src/auth.py" << 'PYEOF'


def refresh_token(refresh_token_str):
    """Exchange a refresh token for a new access token.

    TODO: implement actual token rotation with the auth provider.
    """
    if not refresh_token_str:
        return None
    # WIP: placeholder for token refresh logic
    return {"access_token": "new-token", "expires_in": 3600}
PYEOF

# WIP 2: update routes to use auth middleware
cat >> "$REPO/services/api/src/routes.py" << 'PYEOF'

# WIP: integrating auth middleware into routes
# from .auth import require_auth
# TODO: apply @require_auth to protected endpoints
PYEOF

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "You are on branch 'feature/auth' with uncommitted changes (WIP)."
info "A teammate needs you to review 'feature/dashboard'."
info "Create a worktree so you can check out that branch without losing your work."
info "Open lazygit with:"
echo ""
echo "  lazygit -p ${REPO}"
echo ""
