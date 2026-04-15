#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="02-bisecting-regressions"

info "Setting up exercise: ${EXERCISE_NAME}"

# Create the sandbox repo (idempotent -- cleans up first if it exists)
REPO=$(init_exercise_repo "$EXERCISE_NAME")

# --- Build the monorepo structure ---

create_monorepo "$REPO"
add_service "$REPO" "api"
add_service "$REPO" "worker"
add_library "$REPO" "common"
add_infra "$REPO"

# --- Commit 1: initial scaffolding ---

git -C "$REPO" add -A
git -C "$REPO" commit --quiet -m "chore: initial monorepo scaffolding"

# --- Commit 2: feat(worker): add retry configuration ---

cat >> "$REPO/services/worker/src/config.py" << 'PYEOF'

# Retry configuration
RETRY_MAX_ATTEMPTS = 5
RETRY_BACKOFF_SECONDS = 2
PYEOF
git -C "$REPO" add services/worker/src/config.py
git -C "$REPO" commit --quiet -m "feat(worker): add retry configuration"

# --- Commit 3: docs: update API documentation ---

cat >> "$REPO/docs/README.md" << 'EOF'

## API Endpoints

- `GET /health` -- service health check
- `GET /api/v1/api` -- main API entry point
- `POST /api/v1/api/import` -- bulk data import
EOF
git -C "$REPO" add docs/README.md
git -C "$REPO" commit --quiet -m "docs: update API endpoint documentation"

# --- Commit 4: feat(libs/common): add logging utilities ---

cat >> "$REPO/libs/common/src/common.py" << 'PYEOF'


def setup_logging(service_name, level="INFO"):
    """Configure structured logging for a service."""
    import logging
    logger = logging.getLogger(service_name)
    logger.setLevel(getattr(logging, level))
    handler = logging.StreamHandler()
    handler.setFormatter(logging.Formatter(
        f"%(asctime)s [{service_name}] %(levelname)s: %(message)s"
    ))
    logger.addHandler(handler)
    return logger
PYEOF
git -C "$REPO" add libs/common/src/common.py
git -C "$REPO" commit --quiet -m "feat(libs/common): add structured logging helper"

# --- Commit 5: chore: update CI pipeline --- TAG: last-known-good ---

cat >> "$REPO/infra/ci/.gitlab-ci.yml" << 'EOF'

lint:
  stage: test
  script:
    - make lint
  allow_failure: true
EOF
git -C "$REPO" add infra/ci/.gitlab-ci.yml
git -C "$REPO" commit --quiet -m "chore(ci): add lint stage to pipeline"

# Tag this commit as the last known good state
git -C "$REPO" tag "last-known-good"

# --- Commit 6: feat(api): add pagination helpers ---

cat > "$REPO/services/api/src/pagination.py" << 'PYEOF'
"""Pagination utilities for API responses."""


def paginate(items, page=1, per_page=20):
    """Return a paginated slice of items with metadata."""
    start = (page - 1) * per_page
    end = start + per_page
    return {
        "items": items[start:end],
        "page": page,
        "per_page": per_page,
        "total": len(items),
    }
PYEOF
git -C "$REPO" add services/api/src/pagination.py
git -C "$REPO" commit --quiet -m "feat(api): add pagination utility module"

# --- Commit 7: fix(worker): handle empty queue gracefully ---

cat >> "$REPO/services/worker/src/main.py" << 'PYEOF'


def process_queue(queue):
    """Process items from the job queue."""
    if not queue:
        logger.info("Queue is empty, waiting for new jobs...")
        return 0
    processed = 0
    for job in queue:
        try:
            job.execute()
            processed += 1
        except Exception as e:
            logger.error("Job %s failed: %s", job.id, e)
    return processed
PYEOF
git -C "$REPO" add services/worker/src/main.py
git -C "$REPO" commit --quiet -m "fix(worker): handle empty queue gracefully"

# --- Commit 8: feat(infra): update terraform variables ---

cat >> "$REPO/infra/terraform/variables.tf" << 'EOF'

variable "enable_monitoring" {
  description = "Enable CloudWatch monitoring"
  type        = bool
  default     = true
}

variable "instance_type" {
  description = "EC2 instance type for worker nodes"
  type        = string
  default     = "t3.medium"
}
EOF
git -C "$REPO" add infra/terraform/variables.tf
git -C "$REPO" commit --quiet -m "feat(infra): add monitoring and instance type variables"

# --- Commit 9: feat(worker): add metrics collection ---

cat > "$REPO/services/worker/src/metrics.py" << 'PYEOF'
"""Metrics collection for worker service."""

import time


class MetricsCollector:
    """Collects and reports processing metrics."""

    def __init__(self):
        self._counters = {}
        self._start_time = time.time()

    def increment(self, name, value=1):
        self._counters[name] = self._counters.get(name, 0) + value

    def get_uptime(self):
        return time.time() - self._start_time

    def report(self):
        return {
            "counters": dict(self._counters),
            "uptime_seconds": self.get_uptime(),
        }
PYEOF
git -C "$REPO" add services/worker/src/metrics.py
git -C "$REPO" commit --quiet -m "feat(worker): add metrics collection module"

# --- Commit 10: docs: add deployment runbook ---

cat > "$REPO/docs/deployment.md" << 'EOF'
# Deployment Runbook

## Pre-deployment checklist

1. Run full test suite: `make test`
2. Verify health endpoints: `curl /health`
3. Check resource limits in Helm values
4. Confirm database migrations are ready

## Rollback procedure

1. Identify the last stable release tag
2. Revert the Helm release: `helm rollback platform <revision>`
3. Verify service health after rollback
EOF
git -C "$REPO" add docs/deployment.md
git -C "$REPO" commit --quiet -m "docs: add deployment runbook"

# --- Commit 11: fix(libs/common): timezone handling ---

cat >> "$REPO/libs/common/src/common.py" << 'PYEOF'


def utc_now():
    """Return the current UTC timestamp as an ISO 8601 string."""
    from datetime import datetime, timezone
    return datetime.now(timezone.utc).isoformat()


def parse_timestamp(ts_string):
    """Parse an ISO 8601 timestamp string."""
    from datetime import datetime
    return datetime.fromisoformat(ts_string)
PYEOF
git -C "$REPO" add libs/common/src/common.py
git -C "$REPO" commit --quiet -m "fix(libs/common): handle timezone edge case in date utils"

# --- Commit 12: THE BAD COMMIT -- changes health endpoint to "unhealthy" ---

cat > "$REPO/services/api/src/routes.py" << 'PYEOF'
"""HTTP routes for api service."""

from flask import Flask, jsonify


def create_app(settings):
    app = Flask(__name__)

    @app.route("/health")
    def health():
        return jsonify({"status": "unhealthy", "service": "api"})

    @app.route("/api/v1/api")
    def index():
        return jsonify({"message": "Welcome to api"})

    return app
PYEOF
git -C "$REPO" add services/api/src/routes.py
git -C "$REPO" commit --quiet -m "refactor(api): update health endpoint response format"

# Tag the bad commit for verification
BAD_COMMIT=$(git -C "$REPO" rev-parse HEAD)
git -C "$REPO" tag "the-bad-commit"

# --- Commit 13: chore: bump dependency versions ---

cat > "$REPO/services/api/requirements.txt" << 'EOF'
flask==3.1.0
gunicorn==21.2.0
pytest==8.0.0
requests==2.31.0
EOF
cat > "$REPO/services/worker/requirements.txt" << 'EOF'
celery==5.3.6
redis==5.0.1
pytest==8.0.0
EOF
git -C "$REPO" add services/api/requirements.txt services/worker/requirements.txt
git -C "$REPO" commit --quiet -m "chore: bump dependency versions"

# --- Commit 14: feat(api): add request validation ---

cat > "$REPO/services/api/src/validation.py" << 'PYEOF'
"""Request validation middleware for the API service."""

from functools import wraps
from flask import request, jsonify


def validate_json(required_fields):
    """Decorator to validate required JSON fields in request body."""
    def decorator(f):
        @wraps(f)
        def wrapper(*args, **kwargs):
            data = request.get_json(silent=True)
            if data is None:
                return jsonify({"error": "Request body must be JSON"}), 400
            missing = [field for field in required_fields if field not in data]
            if missing:
                return jsonify({"error": f"Missing fields: {missing}"}), 400
            return f(*args, **kwargs)
        return wrapper
    return decorator
PYEOF
git -C "$REPO" add services/api/src/validation.py
git -C "$REPO" commit --quiet -m "feat(api): add request validation middleware"

# --- Done ---

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
separator
info "Scenario: The API health endpoint is broken. Somewhere between"
info "the 'last-known-good' tag and HEAD, a commit changed the response"
info "from \"healthy\" to \"unhealthy\"."
echo ""
info "Your job: use lazygit's bisect feature to find the bad commit,"
info "tag it as 'bisect-found', then reset the bisect."
echo ""
info "Known good commit: $(git -C "$REPO" rev-parse --short last-known-good) (tag: last-known-good)"
info "Known bad commit:  $(git -C "$REPO" rev-parse --short HEAD) (HEAD)"
echo ""
info "Open lazygit with:"
echo ""
echo "  lazygit -p ${REPO}"
echo ""
