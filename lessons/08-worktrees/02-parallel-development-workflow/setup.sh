#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="02-parallel-development-workflow"
WORKTREE_DIR="${SANDBOX_DIR}/02-parallel-development-workflow-review"

info "Setting up exercise: ${EXERCISE_NAME}"

# --- Clean up any leftover worktree directory from a previous run ---
# init_exercise_repo removes the main repo (and its .git), so git worktree
# remove will not work. Just delete the directory directly.
if [[ -d "$WORKTREE_DIR" ]]; then
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

# --- Create feature/review-target from main with 3 commits ---

git -C "$REPO" checkout --quiet -b "feature/review-target"

# Commit 1: add validation module skeleton
mkdir -p "$REPO/services/api/src"
cat > "$REPO/services/api/src/validation.py" << 'PYEOF'
"""Input validation utilities for the API service."""

MAX_LENGTH = 1024


def validate_request(data):
    """Validate an incoming API request payload."""
    if not isinstance(data, dict):
        raise TypeError("Request payload must be a dictionary")

    required_fields = ["name", "email", "action"]
    for field in required_fields:
        if field not in data:
            raise ValueError(f"Missing required field: {field}")

    return True
PYEOF
git -C "$REPO" add services/api/src/validation.py
git -C "$REPO" commit --quiet -m "feat(api): add request validation module"

# Commit 2: add email validation
cat > "$REPO/services/api/src/validation.py" << 'PYEOF'
"""Input validation utilities for the API service."""

import re

MAX_LENGTH = 1024
EMAIL_PATTERN = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')


def validate_email(email):
    """Validate an email address format."""
    if not EMAIL_PATTERN.match(email):
        raise ValueError(f"Invalid email format: {email}")
    return True


def validate_input(value, field_name="input"):
    """Validate a single input string value."""
    if not isinstance(value, str):
        raise TypeError(f"{field_name} must be a string")
    # TODO: add input length check
    return value.strip()


def validate_request(data):
    """Validate an incoming API request payload."""
    if not isinstance(data, dict):
        raise TypeError("Request payload must be a dictionary")

    required_fields = ["name", "email", "action"]
    for field in required_fields:
        if field not in data:
            raise ValueError(f"Missing required field: {field}")

    validate_email(data["email"])
    validate_input(data["name"], "name")
    validate_input(data["action"], "action")

    return True
PYEOF
git -C "$REPO" add services/api/src/validation.py
git -C "$REPO" commit --quiet -m "feat(api): add email and input validation helpers"

# Commit 3: add validation tests (the TODO is still in validation.py)
cat > "$REPO/services/api/tests/test_validation.py" << 'PYEOF'
"""Tests for input validation utilities."""

import pytest
from src.validation import validate_email, validate_input, validate_request


def test_validate_email_valid():
    assert validate_email("user@example.com") is True


def test_validate_email_invalid():
    with pytest.raises(ValueError):
        validate_email("not-an-email")


def test_validate_input_strips_whitespace():
    assert validate_input("  hello  ") == "hello"


def test_validate_input_non_string():
    with pytest.raises(TypeError):
        validate_input(123)


def test_validate_request_missing_field():
    with pytest.raises(ValueError):
        validate_request({"name": "Alice"})


def test_validate_request_valid():
    data = {"name": "Alice", "email": "alice@example.com", "action": "create"}
    assert validate_request(data) is True
PYEOF
git -C "$REPO" add services/api/tests/test_validation.py
git -C "$REPO" commit --quiet -m "test(api): add validation test suite"

# Tag the review branch HEAD so verify.sh can count new commits
git -C "$REPO" tag review-target-setup HEAD

# --- Create feature/api-refactor from main with 2 commits ---

git -C "$REPO" checkout --quiet main
git -C "$REPO" checkout --quiet -b "feature/api-refactor"

# Commit 1: refactor routes module
cat > "$REPO/services/api/src/routes.py" << 'PYEOF'
"""HTTP routes for api service -- refactored."""

from flask import Flask, jsonify, request


def create_app(settings):
    app = Flask(__name__)

    @app.route("/health")
    def health():
        return jsonify({"status": "healthy", "service": "api", "version": "2.0"})

    @app.route("/api/v2/resources", methods=["GET"])
    def list_resources():
        """List all resources with pagination support."""
        page = request.args.get("page", 1, type=int)
        per_page = request.args.get("per_page", 20, type=int)
        return jsonify({
            "resources": [],
            "page": page,
            "per_page": per_page,
            "total": 0,
        })

    @app.route("/api/v2/resources/<resource_id>", methods=["GET"])
    def get_resource(resource_id):
        return jsonify({"id": resource_id, "status": "active"})

    return app
PYEOF
git -C "$REPO" add services/api/src/routes.py
git -C "$REPO" commit --quiet -m "refactor(api): migrate routes to v2 API structure"

# Commit 2: update config for refactored service
cat > "$REPO/services/api/src/config.py" << 'PYEOF'
"""Configuration for api service -- refactored."""

import os


class Settings:
    def __init__(self):
        self.port = int(os.environ.get("PORT", 8080))
        self.debug = os.environ.get("DEBUG", "false").lower() == "true"
        self.db_url = os.environ.get("DATABASE_URL", "postgresql://localhost/api")
        self.log_level = os.environ.get("LOG_LEVEL", "INFO")
        self.api_version = "v2"
        self.max_page_size = 100
        self.default_page_size = 20
PYEOF
git -C "$REPO" add services/api/src/config.py
git -C "$REPO" commit --quiet -m "refactor(api): add pagination settings to config"

# --- Add uncommitted WIP changes on feature/api-refactor ---

cat >> "$REPO/services/api/src/routes.py" << 'PYEOF'

    @app.route("/api/v2/resources", methods=["POST"])
    def create_resource():
        """Create a new resource."""
        data = request.get_json()
        # WIP: need to add validation here
        return jsonify({"created": True, "resource": data}), 201
PYEOF

cat >> "$REPO/services/api/src/config.py" << 'PYEOF'
        self.rate_limit_enabled = os.environ.get("RATE_LIMIT", "true").lower() == "true"
        self.rate_limit_per_minute = int(os.environ.get("RATE_LIMIT_RPM", 60))
PYEOF

# --- Create the worktree for feature/review-target ---
# The learner learned how to create worktrees in 8/1. This lesson focuses
# on the workflow of switching between worktrees, so we create it for them.

git -C "$REPO" worktree add "$WORKTREE_DIR" "feature/review-target" --quiet

# --- Learner starts on feature/api-refactor in the main worktree ---

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "You are on branch 'feature/api-refactor' with work in progress."
info "A worktree for 'feature/review-target' has been created at:"
info "  ${WORKTREE_DIR}"
info "Your task: switch to the review worktree, fix the TODO, commit, switch back."
info "Open lazygit with:"
echo ""
echo "  lazygit -p ${REPO}"
echo ""
