#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="01-cherry-picking-hotfixes"

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

# Build up main branch history (10 commits total)
# We call make_commits once with 10 to avoid index collisions on dummy files.
make_commits "$REPO" 10

# --- Save branch point for feature/payments (after commit 6) ---
# Walk back 4 commits from HEAD to get the 6th commit out of 10.
BRANCH_POINT=$(git -C "$REPO" rev-parse HEAD~4)

# --- Add the critical bug fix commit on main ---
# This is the commit the learner needs to cherry-pick.

cat > "$REPO/libs/common/src/common.py" << 'PYEOF'
"""common -- shared library."""


class CommonClient:
    """Client for common operations."""

    def __init__(self, config=None):
        self.config = config or {}
        self._initialized = False
        self._cache = {}

    def initialize(self):
        """Set up the client connection."""
        self._initialized = True
        return self

    def is_ready(self):
        return self._initialized

    def cache_lookup(self, key):
        """Look up a value in the local cache.

        Returns None if the key is not found or if key is None.
        """
        if key is None:
            return None
        return self._cache.get(key)

    def cache_set(self, key, value):
        """Store a value in the local cache."""
        if key is None:
            raise ValueError("Cache key must not be None")
        self._cache[key] = value
PYEOF

git -C "$REPO" add libs/common/src/common.py
git -C "$REPO" commit --quiet -m "fix(common): patch null pointer in cache lookup"

# Tag the bugfix commit for easy reference
git -C "$REPO" tag bugfix-tag HEAD

# Add a couple more commits after the fix on main
echo "# Post-fix infrastructure update" >> "$REPO/infra/terraform/variables.tf"
git -C "$REPO" add infra/terraform/variables.tf
git -C "$REPO" commit --quiet -m "refactor(infra): update terraform variable defaults"

echo "# Post-fix CI improvement" >> "$REPO/infra/ci/.gitlab-ci.yml"
git -C "$REPO" add infra/ci/.gitlab-ci.yml
git -C "$REPO" commit --quiet -m "chore(ci): add caching to build pipeline"

# --- Create the feature/payments branch from the earlier branch point ---

git -C "$REPO" checkout --quiet "$BRANCH_POINT"
git -C "$REPO" checkout --quiet -b "feature/payments"

# Add 3 feature-specific commits on the payments branch

cat > "$REPO/services/api/src/payments.py" << 'PYEOF'
"""Payment processing module."""

from flask import jsonify, request


def register_payment_routes(app):
    """Register payment API routes."""

    @app.route("/api/v1/payments", methods=["GET"])
    def list_payments():
        return jsonify({"payments": [], "total": 0})
PYEOF
git -C "$REPO" add services/api/src/payments.py
git -C "$REPO" commit --quiet -m "feat(api): add payment routes skeleton"

cat >> "$REPO/services/api/src/payments.py" << 'PYEOF'

    @app.route("/api/v1/payments/<payment_id>", methods=["GET"])
    def get_payment(payment_id):
        """Retrieve a single payment by ID."""
        return jsonify({"payment_id": payment_id, "status": "pending", "amount": 0})

    @app.route("/api/v1/payments", methods=["POST"])
    def create_payment():
        """Create a new payment."""
        data = request.get_json()
        return jsonify({"created": True, "payment": data}), 201
PYEOF
git -C "$REPO" add services/api/src/payments.py
git -C "$REPO" commit --quiet -m "feat(api): add payment CRUD endpoints"

cat > "$REPO/services/api/tests/test_payments.py" << 'PYEOF'
"""Tests for payment routes."""

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


def test_list_payments(client):
    response = client.get("/api/v1/payments")
    assert response.status_code == 200
    assert "payments" in response.json


def test_create_payment(client):
    response = client.post("/api/v1/payments", json={"amount": 100})
    assert response.status_code == 201
PYEOF
git -C "$REPO" add services/api/tests/test_payments.py
git -C "$REPO" commit --quiet -m "test(api): add payment endpoint tests"

# --- Learner starts on feature/payments with a clean working tree ---

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "You are on branch 'feature/payments'."
info "A critical bug fix on 'main' needs to be cherry-picked onto your branch."
info "Look for the commit: \"fix(common): patch null pointer in cache lookup\""
info "Open lazygit with:"
echo ""
echo "  lazygit -p ${REPO}"
echo ""
