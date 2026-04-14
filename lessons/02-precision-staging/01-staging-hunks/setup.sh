#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="01-staging-hunks"

info "Setting up exercise: ${EXERCISE_NAME}"

# Create the sandbox repo (idempotent -- cleans up first if it exists)
REPO=$(init_exercise_repo "$EXERCISE_NAME")

# --- Build the monorepo structure ---

create_monorepo "$REPO"
add_service "$REPO" "api"
add_service "$REPO" "worker"
add_library "$REPO" "common"
add_infra "$REPO"

# --- Replace routes.py with a longer version so git can detect two separate hunks ---
# We need enough unchanged lines between the two modification sites (at least 7)
# so git treats the edits as separate hunks.

cat > "$REPO/services/api/src/routes.py" << 'PYEOF'
"""HTTP routes for api service."""

from flask import Flask, jsonify


def create_app(settings):
    """Create and configure the Flask application."""
    app = Flask(__name__)

    @app.route("/health")
    def health():
        """Health check endpoint."""
        return jsonify({"status": "healthy", "service": "api"})

    @app.route("/api/v1/items")
    def list_items():
        """List all items."""
        items = [
            {"id": 1, "name": "widget", "status": "active"},
            {"id": 2, "name": "gadget", "status": "active"},
            {"id": 3, "name": "doohickey", "status": "inactive"},
        ]
        return jsonify({"items": items, "count": len(items)})

    @app.route("/api/v1/items/<int:item_id>")
    def get_item(item_id):
        """Get a single item by ID."""
        return jsonify({"id": item_id, "name": "widget", "status": "active"})

    @app.route("/api/v1/status")
    def status():
        """Service status endpoint."""
        return jsonify({
            "service": "api",
            "version": "1.0.0",
            "uptime": "unknown",
        })

    return app
PYEOF

# Initial commit with the full monorepo
git -C "$REPO" add -A
git -C "$REPO" commit --quiet -m "chore: initial monorepo scaffolding"

# Add a few more commits for realistic history
make_commits "$REPO" 5

# --- Now introduce the working-tree changes the learner will see ---

# HUNK 1 (top of file): Add a logging import and logger setup after the existing imports
# HUNK 2 (bottom of file): Add a new route just before `return app`
#
# The two modifications are separated by ~25 unchanged lines, which guarantees
# git sees them as two distinct hunks.

cat > "$REPO/services/api/src/routes.py" << 'PYEOF'
"""HTTP routes for api service."""

import logging
from flask import Flask, jsonify

logger = logging.getLogger(__name__)


def create_app(settings):
    """Create and configure the Flask application."""
    app = Flask(__name__)

    @app.route("/health")
    def health():
        """Health check endpoint."""
        return jsonify({"status": "healthy", "service": "api"})

    @app.route("/api/v1/items")
    def list_items():
        """List all items."""
        items = [
            {"id": 1, "name": "widget", "status": "active"},
            {"id": 2, "name": "gadget", "status": "active"},
            {"id": 3, "name": "doohickey", "status": "inactive"},
        ]
        return jsonify({"items": items, "count": len(items)})

    @app.route("/api/v1/items/<int:item_id>")
    def get_item(item_id):
        """Get a single item by ID."""
        return jsonify({"id": item_id, "name": "widget", "status": "active"})

    @app.route("/api/v1/status")
    def status():
        """Service status endpoint."""
        return jsonify({
            "service": "api",
            "version": "1.0.0",
            "uptime": "unknown",
        })

    @app.route("/api/v1/metrics")
    def metrics():
        """Return service metrics."""
        logger.info("Metrics endpoint called")
        return jsonify({
            "requests_total": 0,
            "errors_total": 0,
            "uptime_seconds": 0,
        })

    return app
PYEOF

# Also modify the worker service (this should NOT be staged by the learner)
cat >> "$REPO/services/worker/src/main.py" << 'PYEOF'

# TODO: add graceful shutdown handler
SHUTDOWN_TIMEOUT = 30
PYEOF

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "Open lazygit in that directory:"
echo ""
echo "  cd ${REPO} && lazygit"
echo ""
