#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="04-fixup-commits"

info "Setting up exercise: ${EXERCISE_NAME}"

# Create the sandbox repo (idempotent -- cleans up first if it exists)
REPO=$(init_exercise_repo "$EXERCISE_NAME")

# --- Build the monorepo structure ---

create_monorepo "$REPO"
add_service "$REPO" "api"
add_library "$REPO" "common"
add_infra "$REPO"

# Initial commit with full monorepo
git -C "$REPO" add -A
git -C "$REPO" commit --quiet -m "chore: initial monorepo scaffolding"

# Add some history on main for realism
make_commits "$REPO" 5

# --- Create feature branch ---

git -C "$REPO" checkout --quiet -b "feature/auth-middleware"

# Tag the divergence point so verify.sh can count commits ahead
git -C "$REPO" tag "exercise-start"

# --- Commit 1: auth middleware skeleton ---

cat > "$REPO/services/api/src/auth.py" << 'PYEOF'
"""Authentication middleware for the API service."""

import logging
from functools import wraps
from flask import request, jsonify

logger = logging.getLogger(__name__)


def require_auth(f):
    """Decorator that enforces authentication on a route."""
    @wraps(f)
    def decorated(*args, **kwargs):
        token = request.headers.get("Authorization")
        if not token:
            logger.warning("Request missing Authorization header")
            return jsonify({"error": "missing token"}), 401
        if not token.startswith("Bearer "):
            return jsonify({"error": "invalid token format"}), 401
        return f(*args, **kwargs)
    return decorated
PYEOF

git -C "$REPO" add services/api/src/auth.py
git -C "$REPO" commit --quiet -m "feat(api): add auth middleware skeleton"

# --- Commit 2: token validation ---

cat > "$REPO/services/api/src/token.py" << 'PYEOF'
"""Token validation utilities."""

import hashlib
import hmac
import time

SECRET_KEY = "change-me-in-production"
TOKEN_TTL = 3600  # seconds


def validate_token(token):
    """Validate a bearer token and return the payload if valid."""
    parts = token.split(".")
    if len(parts) != 3:
        return None, "malformed token"

    header, payload, signature = parts

    expected_sig = hmac.new(
        SECRET_KEY.encode(),
        f"{header}.{payload}".encode(),
        hashlib.sha256,
    ).hexdigest()

    if not hmac.compare_digest(signature, expected_sig):
        return None, "invalid signature"

    return payload, None


def is_token_expired(issued_at):
    """Check whether a token has exceeded its TTL."""
    return (time.time() - issued_at) > TOKEN_TTL
PYEOF

git -C "$REPO" add services/api/src/token.py
git -C "$REPO" commit --quiet -m "feat(api): implement token validation"

# --- Commit 3: auth middleware tests ---

mkdir -p "$REPO/services/api/tests"

cat > "$REPO/services/api/tests/test_auth.py" << 'PYEOF'
"""Tests for authentication middleware."""

import pytest
from unittest.mock import patch, MagicMock
from src.auth import require_auth
from src.token import validate_token, is_token_expired


class TestRequireAuth:
    """Tests for the require_auth decorator."""

    def test_missing_token_returns_401(self, client):
        response = client.get("/protected")
        assert response.status_code == 401

    def test_invalid_format_returns_401(self, client):
        response = client.get(
            "/protected",
            headers={"Authorization": "NotBearer token"},
        )
        assert response.status_code == 401

    def test_valid_token_passes_through(self, client):
        response = client.get(
            "/protected",
            headers={"Authorization": "Bearer valid.token.here"},
        )
        assert response.status_code == 200


class TestValidateToken:
    """Tests for the validate_token function."""

    def test_malformed_token(self):
        payload, err = validate_token("not-a-real-token")
        assert payload is None
        assert err == "malformed token"

    def test_invalid_signature(self):
        payload, err = validate_token("header.payload.badsig")
        assert payload is None
        assert err == "invalid signature"


class TestTokenExpiry:
    """Tests for token expiration checks."""

    def test_fresh_token_not_expired(self):
        import time
        assert not is_token_expired(time.time() - 10)

    def test_old_token_expired(self):
        import time
        assert is_token_expired(time.time() - 7200)
PYEOF

git -C "$REPO" add services/api/tests/test_auth.py
git -C "$REPO" commit --quiet -m "test(api): add auth middleware tests"

# --- Leave an unstaged fix that belongs in commit 2 (token validation) ---
# The review fix: add input sanitization to validate_token

cat > "$REPO/services/api/src/token.py" << 'PYEOF'
"""Token validation utilities."""

import hashlib
import hmac
import time

SECRET_KEY = "change-me-in-production"
TOKEN_TTL = 3600  # seconds


def validate_token(token):
    """Validate a bearer token and return the payload if valid."""
    if not isinstance(token, str) or len(token) > 4096:
        return None, "invalid input"

    token = token.strip()

    parts = token.split(".")
    if len(parts) != 3:
        return None, "malformed token"

    header, payload, signature = parts

    expected_sig = hmac.new(
        SECRET_KEY.encode(),
        f"{header}.{payload}".encode(),
        hashlib.sha256,
    ).hexdigest()

    if not hmac.compare_digest(signature, expected_sig):
        return None, "invalid signature"

    return payload, None


def is_token_expired(issued_at):
    """Check whether a token has exceeded its TTL."""
    return (time.time() - issued_at) > TOKEN_TTL
PYEOF

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "Open lazygit in that directory:"
echo ""
echo "  lazygit -p ${REPO}"
echo ""
