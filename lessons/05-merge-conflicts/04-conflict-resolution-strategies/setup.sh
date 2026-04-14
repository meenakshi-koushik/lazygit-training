#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="04-conflict-resolution-strategies"

info "Setting up exercise: ${EXERCISE_NAME}"

# Create the sandbox repo (idempotent)
REPO=$(init_exercise_repo "$EXERCISE_NAME")

# --- Build the monorepo structure ---

create_monorepo "$REPO"
add_service "$REPO" "api"
add_service "$REPO" "worker"
add_service "$REPO" "auth"
add_library "$REPO" "common"
add_infra "$REPO"

# Initial commit
git -C "$REPO" add -A
git -C "$REPO" commit --quiet -m "chore: initial monorepo scaffolding"

# Build baseline history
make_commits "$REPO" 5

# Save divergence point
git -C "$REPO" tag "divergence-point"

# --- Feature branch: you are updating the auth service ---

git -C "$REPO" checkout --quiet -b "feature/oauth-upgrade"

# Your change to auth config: complete rewrite for OAuth 2.0
cat > "$REPO/services/auth/src/config.py" << 'PYEOF'
"""Configuration for auth service -- OAuth 2.0."""

import os


class Settings:
    def __init__(self):
        self.port = int(os.environ.get("PORT", 8080))
        self.debug = os.environ.get("DEBUG", "false").lower() == "true"
        self.db_url = os.environ.get("DATABASE_URL", "postgresql://localhost/auth")
        self.log_level = os.environ.get("LOG_LEVEL", "INFO")

        # OAuth 2.0 settings
        self.oauth_provider = os.environ.get("OAUTH_PROVIDER", "https://accounts.google.com")
        self.oauth_client_id = os.environ.get("OAUTH_CLIENT_ID", "")
        self.oauth_client_secret = os.environ.get("OAUTH_CLIENT_SECRET", "")
        self.oauth_redirect_uri = os.environ.get("OAUTH_REDIRECT_URI", "http://localhost:8080/callback")
        self.oauth_scopes = os.environ.get("OAUTH_SCOPES", "openid profile email").split()
        self.token_expiry = int(os.environ.get("TOKEN_EXPIRY", 3600))
PYEOF
git -C "$REPO" add services/auth/src/config.py
git -C "$REPO" commit --quiet -m "feat(auth): add OAuth 2.0 configuration"

# Your change to auth routes: complete rewrite
cat > "$REPO/services/auth/src/routes.py" << 'PYEOF'
"""HTTP routes for auth service -- OAuth 2.0 flow."""

from flask import Flask, jsonify, redirect, request


def create_app(settings):
    app = Flask(__name__)

    @app.route("/health")
    def health():
        return jsonify({"status": "healthy", "service": "auth"})

    @app.route("/auth/login")
    def login():
        """Redirect to OAuth provider."""
        auth_url = f"{settings.oauth_provider}/authorize"
        params = {
            "client_id": settings.oauth_client_id,
            "redirect_uri": settings.oauth_redirect_uri,
            "scope": " ".join(settings.oauth_scopes),
            "response_type": "code",
        }
        query = "&".join(f"{k}={v}" for k, v in params.items())
        return redirect(f"{auth_url}?{query}")

    @app.route("/auth/callback")
    def callback():
        """Handle OAuth callback."""
        code = request.args.get("code")
        if not code:
            return jsonify({"error": "Missing authorization code"}), 400
        return jsonify({"message": "Authentication successful", "code": code})

    @app.route("/auth/logout")
    def logout():
        """Clear the session."""
        return jsonify({"message": "Logged out"})

    return app
PYEOF
git -C "$REPO" add services/auth/src/routes.py
git -C "$REPO" commit --quiet -m "feat(auth): implement OAuth 2.0 login flow"

# Your change to the Makefile: you want YOUR version entirely
cat > "$REPO/Makefile" << 'EOF'
.PHONY: build test lint deploy auth-test

build:
	@echo "Building all services..."
	@for dir in services/*/; do \
		echo "  Building $${dir}..."; \
	done

test:
	@echo "Running all tests..."
	@for dir in services/*/; do \
		echo "  Testing $${dir}..."; \
	done

lint:
	@echo "Linting..."
	@ruff check services/ libs/

deploy:
	@echo "Deploying..."
	@kubectl apply -k infra/

auth-test:
	@echo "Testing OAuth flow..."
	@cd services/auth && pytest tests/ -v
EOF
git -C "$REPO" add Makefile
git -C "$REPO" commit --quiet -m "chore: update Makefile with linting and auth targets"

# --- Meanwhile, main gets conflicting changes ---

git -C "$REPO" checkout --quiet main

# Teammate's change to auth config: SAML approach (conflicting)
cat > "$REPO/services/auth/src/config.py" << 'PYEOF'
"""Configuration for auth service -- SAML SSO."""

import os


class Settings:
    def __init__(self):
        self.port = int(os.environ.get("PORT", 8080))
        self.debug = os.environ.get("DEBUG", "false").lower() == "true"
        self.db_url = os.environ.get("DATABASE_URL", "postgresql://localhost/auth")
        self.log_level = os.environ.get("LOG_LEVEL", "INFO")

        # SAML SSO settings
        self.saml_idp_url = os.environ.get("SAML_IDP_URL", "https://idp.company.com/saml")
        self.saml_entity_id = os.environ.get("SAML_ENTITY_ID", "platform-app")
        self.saml_cert_path = os.environ.get("SAML_CERT_PATH", "/etc/saml/cert.pem")
        self.session_timeout = int(os.environ.get("SESSION_TIMEOUT", 7200))
PYEOF
git -C "$REPO" add services/auth/src/config.py
git -C "$REPO" commit --quiet -m "feat(auth): add SAML SSO configuration"

# Teammate's change to auth routes: SAML flow (conflicting)
cat > "$REPO/services/auth/src/routes.py" << 'PYEOF'
"""HTTP routes for auth service -- SAML SSO."""

from flask import Flask, jsonify, request


def create_app(settings):
    app = Flask(__name__)

    @app.route("/health")
    def health():
        return jsonify({"status": "healthy", "service": "auth"})

    @app.route("/auth/saml/login")
    def saml_login():
        """Initiate SAML login."""
        return jsonify({
            "message": "Redirecting to IdP",
            "idp_url": settings.saml_idp_url,
        })

    @app.route("/auth/saml/acs", methods=["POST"])
    def saml_acs():
        """Handle SAML Assertion Consumer Service callback."""
        saml_response = request.form.get("SAMLResponse")
        if not saml_response:
            return jsonify({"error": "Missing SAML response"}), 400
        return jsonify({"message": "SAML authentication successful"})

    @app.route("/auth/saml/metadata")
    def saml_metadata():
        """Return SAML service provider metadata."""
        return jsonify({"entity_id": settings.saml_entity_id})

    return app
PYEOF
git -C "$REPO" add services/auth/src/routes.py
git -C "$REPO" commit --quiet -m "feat(auth): implement SAML SSO flow"

# Teammate's change to Makefile: different targets (conflicting)
cat > "$REPO/Makefile" << 'EOF'
.PHONY: build test lint deploy security-scan

build:
	@echo "Building all services..."
	@for dir in services/*/; do \
		echo "  Building $${dir}..."; \
	done

test:
	@echo "Running all tests..."
	@for dir in services/*/; do \
		echo "  Testing $${dir}..."; \
	done

lint:
	@echo "Linting..."
	@flake8 services/ libs/

deploy:
	@echo "Deploying..."

security-scan:
	@echo "Running security scan..."
	@bandit -r services/ -ll
EOF
git -C "$REPO" add Makefile
git -C "$REPO" commit --quiet -m "chore: add security scanning to Makefile"

# One more unrelated commit on main
make_commits "$REPO" 1

# --- Switch back to feature branch and start the merge ---

git -C "$REPO" checkout --quiet "feature/oauth-upgrade"

# Initiate the merge
git -C "$REPO" merge main --no-edit 2>/dev/null || true

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "Three files have conflicts. Each requires a DIFFERENT strategy:"
info "  - config.py: keep OURS (OAuth, not SAML)"
info "  - routes.py: keep OURS (OAuth routes, not SAML)"
info "  - Makefile:  keep OURS (your version replaces theirs)"
info ""
info "Open lazygit in the sandbox:"
echo ""
echo "  lazygit -p ${REPO}"
echo ""
