#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="03-multi-file-conflicts"

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

# --- Feature branch: cross-cutting logging refactor ---

git -C "$REPO" checkout --quiet -b "feature/structured-logging"

# Change 1: update common library logging
cat > "$REPO/libs/common/src/common.py" << 'PYEOF'
"""common -- shared library."""

import json
import logging
import sys


class CommonClient:
    """Client for common operations."""

    def __init__(self, config=None):
        self.config = config or {}
        self._initialized = False

    def initialize(self):
        """Set up the client connection."""
        self._initialized = True
        return self

    def is_ready(self):
        return self._initialized


def setup_logging(service_name, level="INFO"):
    """Configure structured JSON logging for a service."""
    handler = logging.StreamHandler(sys.stdout)
    handler.setFormatter(JsonFormatter(service_name))
    root = logging.getLogger()
    root.addHandler(handler)
    root.setLevel(getattr(logging, level))


class JsonFormatter(logging.Formatter):
    """Format log records as JSON."""

    def __init__(self, service_name):
        super().__init__()
        self.service_name = service_name

    def format(self, record):
        return json.dumps({
            "timestamp": self.formatTime(record),
            "service": self.service_name,
            "level": record.levelname,
            "message": record.getMessage(),
        })
PYEOF
git -C "$REPO" add libs/common/src/common.py
git -C "$REPO" commit --quiet -m "feat(libs/common): add structured JSON logging"

# Change 2: update api service to use structured logging
cat > "$REPO/services/api/src/main.py" << 'PYEOF'
"""api service entry point."""

import logging
from .config import Settings
from .routes import create_app
from libs.common.src.common import setup_logging

logger = logging.getLogger(__name__)


def main():
    settings = Settings()
    setup_logging("api", settings.log_level)
    app = create_app(settings)
    logger.info("Starting api service on port %d", settings.port)
    app.run(host="0.0.0.0", port=settings.port)


if __name__ == "__main__":
    main()
PYEOF
git -C "$REPO" add services/api/src/main.py
git -C "$REPO" commit --quiet -m "feat(api): integrate structured logging"

# Change 3: update worker service to use structured logging
cat > "$REPO/services/worker/src/main.py" << 'PYEOF'
"""worker service entry point."""

import logging
from .config import Settings
from libs.common.src.common import setup_logging

logger = logging.getLogger(__name__)


def main():
    settings = Settings()
    setup_logging("worker", settings.log_level)
    logger.info("Starting worker service on port %d", settings.port)


if __name__ == "__main__":
    main()
PYEOF
git -C "$REPO" add services/worker/src/main.py
git -C "$REPO" commit --quiet -m "feat(worker): integrate structured logging"

# Change 4: update helm values with logging config
cat > "$REPO/infra/helm/values.yaml" << 'PYEOF'
replicaCount: 2

image:
  repository: platform/service
  tag: latest
  pullPolicy: IfNotPresent

resources:
  requests:
    cpu: 100m
    memory: 128Mi
  limits:
    cpu: 500m
    memory: 512Mi

ingress:
  enabled: true
  className: nginx

logging:
  format: json
  level: INFO
  output: stdout
PYEOF
git -C "$REPO" add infra/helm/values.yaml
git -C "$REPO" commit --quiet -m "feat(infra): add logging configuration to helm values"

# --- Meanwhile, main gets conflicting changes ---

git -C "$REPO" checkout --quiet main

# Main change 1: teammate updates common library differently
cat > "$REPO/libs/common/src/common.py" << 'PYEOF'
"""common -- shared library."""

import logging
import os


class CommonClient:
    """Client for common operations."""

    def __init__(self, config=None):
        self.config = config or {}
        self._initialized = False

    def initialize(self):
        """Set up the client connection."""
        self._initialized = True
        return self

    def is_ready(self):
        return self._initialized


def get_service_version():
    """Return the current service version from environment."""
    return os.environ.get("SERVICE_VERSION", "0.0.0")


def configure_monitoring(service_name):
    """Set up basic monitoring for a service."""
    logger = logging.getLogger(service_name)
    logger.info("Monitoring configured for %s v%s", service_name, get_service_version())
    return {"service": service_name, "version": get_service_version()}
PYEOF
git -C "$REPO" add libs/common/src/common.py
git -C "$REPO" commit --quiet -m "feat(libs/common): add service versioning and monitoring"

# Main change 2: teammate updates api service differently
cat > "$REPO/services/api/src/main.py" << 'PYEOF'
"""api service entry point."""

import logging
from .config import Settings
from .routes import create_app
from libs.common.src.common import configure_monitoring

logger = logging.getLogger(__name__)


def main():
    settings = Settings()
    configure_monitoring("api")
    app = create_app(settings)
    logger.info("Starting api service on port %d", settings.port)
    logger.info("Debug mode: %s", settings.debug)
    app.run(host="0.0.0.0", port=settings.port)


if __name__ == "__main__":
    main()
PYEOF
git -C "$REPO" add services/api/src/main.py
git -C "$REPO" commit --quiet -m "feat(api): add monitoring integration"

# Main change 3: teammate updates worker differently
cat > "$REPO/services/worker/src/main.py" << 'PYEOF'
"""worker service entry point."""

import logging
from .config import Settings
from libs.common.src.common import configure_monitoring

logger = logging.getLogger(__name__)


def main():
    settings = Settings()
    configure_monitoring("worker")
    logger.info("Starting worker service on port %d", settings.port)
    logger.info("Debug mode: %s", settings.debug)


if __name__ == "__main__":
    main()
PYEOF
git -C "$REPO" add services/worker/src/main.py
git -C "$REPO" commit --quiet -m "feat(worker): add monitoring integration"

# Main change 4: teammate updates helm values differently
cat > "$REPO/infra/helm/values.yaml" << 'PYEOF'
replicaCount: 3

image:
  repository: platform/service
  tag: latest
  pullPolicy: IfNotPresent

resources:
  requests:
    cpu: 200m
    memory: 256Mi
  limits:
    cpu: 1000m
    memory: 1Gi

ingress:
  enabled: true
  className: nginx

monitoring:
  enabled: true
  port: 9090
  path: /metrics
PYEOF
git -C "$REPO" add infra/helm/values.yaml
git -C "$REPO" commit --quiet -m "feat(infra): add monitoring and scale up resources"

# --- Switch back to feature branch and start the merge ---

git -C "$REPO" checkout --quiet "feature/structured-logging"

# Initiate the merge so the learner sees all conflicts at once
git -C "$REPO" merge main --no-edit 2>/dev/null || true

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "Multiple files have merge conflicts -- resolve them all!"
info "Open lazygit in the sandbox:"
echo ""
echo "  lazygit -p ${REPO}"
echo ""
