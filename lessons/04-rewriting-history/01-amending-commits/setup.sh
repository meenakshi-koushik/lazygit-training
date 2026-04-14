#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="01-amending-commits"

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

# Build realistic history on main (~8 commits)
make_commits "$REPO" 8

# --- Create the feature branch ---

git -C "$REPO" checkout --quiet -b "feature/add-validation"

# Add a validation module -- this file WILL be committed
cat > "$REPO/services/api/src/validation.py" << 'PYEOF'
"""Input validation for api service."""

import re


def validate_email(email: str) -> bool:
    """Validate an email address format."""
    pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
    return bool(re.match(pattern, email))


def validate_username(username: str) -> bool:
    """Validate a username (3-32 alphanumeric characters)."""
    pattern = r'^[a-zA-Z0-9_]{3,32}$'
    return bool(re.match(pattern, username))


def validate_payload(data: dict, required_fields: list) -> list:
    """Check that all required fields are present in the payload."""
    missing = [f for f in required_fields if f not in data]
    return missing
PYEOF

# Also modify routes.py to wire up validation -- but we will NOT stage this
# file. It will remain as the "forgotten" unstaged change.
cat > "$REPO/services/api/src/routes.py" << 'PYEOF'
"""HTTP routes for api service."""

from flask import Flask, jsonify, request
from .validation import validate_email, validate_username, validate_payload


def create_app(settings):
    app = Flask(__name__)

    @app.route("/health")
    def health():
        return jsonify({"status": "healthy", "service": "api"})

    @app.route("/api/v1/api")
    def index():
        return jsonify({"message": "Welcome to api"})

    @app.route("/api/v1/users", methods=["POST"])
    def create_user():
        """Create a new user with input validation."""
        data = request.get_json()
        missing = validate_payload(data, ["email", "username"])
        if missing:
            return jsonify({"error": f"Missing fields: {missing}"}), 400
        if not validate_email(data["email"]):
            return jsonify({"error": "Invalid email format"}), 400
        if not validate_username(data["username"]):
            return jsonify({"error": "Invalid username format"}), 400
        return jsonify({"message": "User created", "username": data["username"]}), 201

    return app
PYEOF

# Stage ONLY the validation module, NOT routes.py
git -C "$REPO" add "services/api/src/validation.py"

# Commit with a typo in the message: "validaton" instead of "validation"
git -C "$REPO" commit --quiet -m "feat(api): add input validaton"

# Now routes.py has unstaged modifications -- this is the "forgotten" file.
# The working tree is dirty with just this one file.

# Tag this state so verify.sh can check commit count relative to it
git -C "$REPO" tag "exercise-start" HEAD~1

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "Open lazygit in that directory:"
echo ""
echo "  cd ${REPO} && lazygit"
echo ""
