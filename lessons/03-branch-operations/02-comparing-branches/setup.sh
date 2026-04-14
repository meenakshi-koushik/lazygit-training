#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="02-comparing-branches"

info "Setting up exercise: ${EXERCISE_NAME}"

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

# --- Build shared history on main (8 commits) ---

make_commits "$REPO" 8

# --- Create feature branch with 3 commits ---

git -C "$REPO" checkout --quiet -b "feature/api-refactor"

# Feature commit 1: refactor API routes
cat > "$REPO/services/api/src/routes.py" << 'PYEOF'
"""HTTP routes for api service -- refactored."""

import logging
from flask import Flask, jsonify, request

logger = logging.getLogger(__name__)


def create_app(settings):
    app = Flask(__name__)

    @app.route("/health")
    def health():
        logger.info("Health check requested")
        return jsonify({"status": "healthy", "service": "api", "version": "2.0"})

    @app.route("/api/v2/items")
    def list_items():
        """Refactored list endpoint with filtering."""
        status_filter = request.args.get("status", None)
        items = _get_items(status_filter)
        return jsonify({"items": items, "count": len(items)})

    def _get_items(status_filter=None):
        items = [
            {"id": 1, "name": "widget", "status": "active"},
            {"id": 2, "name": "gadget", "status": "active"},
            {"id": 3, "name": "doohickey", "status": "inactive"},
        ]
        if status_filter:
            items = [i for i in items if i["status"] == status_filter]
        return items

    return app
PYEOF
git -C "$REPO" add services/api/src/routes.py
git -C "$REPO" commit --quiet -m "refactor(api): restructure routes with v2 endpoints"

# Feature commit 2: update API config
cat >> "$REPO/services/api/src/config.py" << 'PYEOF'

    # v2 configuration
    API_VERSION = "2.0"
    ENABLE_FILTERING = True
PYEOF
git -C "$REPO" add services/api/src/config.py
git -C "$REPO" commit --quiet -m "feat(api): add v2 configuration options"

# Feature commit 3: add API tests for new endpoints
cat >> "$REPO/services/api/tests/test_routes.py" << 'PYEOF'


def test_list_items_v2(client):
    response = client.get("/api/v2/items")
    assert response.status_code == 200
    assert "items" in response.json


def test_list_items_v2_filtered(client):
    response = client.get("/api/v2/items?status=active")
    assert response.status_code == 200
PYEOF
git -C "$REPO" add services/api/tests/test_routes.py
git -C "$REPO" commit --quiet -m "test(api): add tests for v2 list endpoint"

# --- Go back to main and add 4 more commits (divergence) ---

git -C "$REPO" checkout --quiet main

# Main commit 1: update worker
cat >> "$REPO/services/worker/src/main.py" << 'PYEOF'


def handle_shutdown(signum, frame):
    """Graceful shutdown handler."""
    logger.info("Received signal %d, shutting down...", signum)
PYEOF
git -C "$REPO" add services/worker/src/main.py
git -C "$REPO" commit --quiet -m "feat(worker): add graceful shutdown handler"

# Main commit 2: update infra
cat >> "$REPO/infra/terraform/variables.tf" << 'HCLEOF'

variable "worker_replicas" {
  description = "Number of worker replicas"
  type        = number
  default     = 3
}
HCLEOF
git -C "$REPO" add infra/terraform/variables.tf
git -C "$REPO" commit --quiet -m "feat(infra): add worker replica count variable"

# Main commit 3: update common library
cat >> "$REPO/libs/common/src/common.py" << 'PYEOF'

    def health_check(self):
        """Return health status."""
        return {"initialized": self._initialized}
PYEOF
git -C "$REPO" add libs/common/src/common.py
git -C "$REPO" commit --quiet -m "feat(libs/common): add health check method"

# Main commit 4: update docs
cat >> "$REPO/README.md" << 'EOF'

## Recent Changes

- Added graceful shutdown to worker service
- Added worker replica configuration
- Added health check to common library
EOF
git -C "$REPO" add README.md
git -C "$REPO" commit --quiet -m "docs: update README with recent changes"

# --- Switch back to feature branch so learner starts there ---

git -C "$REPO" checkout --quiet "feature/api-refactor"

# Tag the initial state
git -C "$REPO" tag "exercise-start"

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "Open lazygit in that directory:"
echo ""
echo "  cd ${REPO} && lazygit"
echo ""
