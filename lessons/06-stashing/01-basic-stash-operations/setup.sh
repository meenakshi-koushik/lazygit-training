#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="01-basic-stash-operations"

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

# Build up a realistic main branch history
make_commits "$REPO" 8

# --- Create the feature branch with some committed work ---

git -C "$REPO" checkout --quiet -b "feature/user-profiles"

# Add a couple of committed changes on the feature branch so it has history
cat > "$REPO/services/api/src/profiles.py" << 'EOF'
"""User profile management."""

from flask import jsonify, request


def register_profile_routes(app):
    """Register user profile API routes."""

    @app.route("/api/v1/profiles", methods=["GET"])
    def list_profiles():
        return jsonify({"profiles": [], "total": 0})
EOF
git -C "$REPO" add services/api/src/profiles.py
git -C "$REPO" commit --quiet -m "feat(api): add user profiles module skeleton"

echo 'profiles-service==0.1.0' >> "$REPO/services/api/requirements.txt"
git -C "$REPO" add services/api/requirements.txt
git -C "$REPO" commit --quiet -m "chore(api): add profiles dependency"

# --- Create uncommitted work-in-progress (the changes to stash) ---

# 1. Modified config -- adding profile-related settings
cat >> "$REPO/services/api/config/settings.yaml" << 'EOF'

profiles:
  max_avatar_size_mb: 5
  default_visibility: public
  cache_ttl: 600
EOF

# 2. Modified route handler -- adding profile endpoints
cat >> "$REPO/services/api/src/profiles.py" << 'EOF'

    @app.route("/api/v1/profiles/<user_id>", methods=["GET"])
    def get_profile(user_id):
        """Get a single user profile by ID."""
        return jsonify({"user_id": user_id, "name": "TODO", "status": "active"})

    @app.route("/api/v1/profiles", methods=["POST"])
    def create_profile():
        """Create a new user profile."""
        data = request.get_json()
        return jsonify({"created": True, "profile": data}), 201
EOF

# 3. Modified tests -- adding profile test stubs
cat >> "$REPO/services/api/tests/test_routes.py" << 'EOF'


def test_list_profiles(client):
    response = client.get("/api/v1/profiles")
    assert response.status_code == 200
    assert "profiles" in response.json


def test_get_profile(client):
    response = client.get("/api/v1/profiles/user-123")
    assert response.status_code == 200
    assert response.json["user_id"] == "user-123"
EOF

# --- Ensure learner starts on the feature branch with unstaged changes ---
# (All 3 files are modified but NOT staged)

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "You are on branch 'feature/user-profiles' with 3 modified files."
info "Open lazygit with:"
echo ""
echo "  lazygit -p ${REPO}"
echo ""
