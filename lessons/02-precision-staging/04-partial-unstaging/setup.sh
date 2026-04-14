#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="04-partial-unstaging"

info "Setting up exercise: ${EXERCISE_NAME}"

# Create the sandbox repo (idempotent -- cleans up first if it exists)
REPO=$(init_exercise_repo "$EXERCISE_NAME")

# --- Build the monorepo structure ---

create_monorepo "$REPO"
add_service "$REPO" "api"
add_service "$REPO" "worker"
add_library "$REPO" "common"

# Initial commit with the full monorepo
git -C "$REPO" add -A
git -C "$REPO" commit --quiet -m "chore: initial monorepo scaffolding"

# Build a short history so the repo feels realistic
make_commits "$REPO" 8

# --- Make changes to both services (simulating real in-progress work) ---

# API changes: add rate limiting middleware
cat >> "$REPO/services/api/src/routes.py" << 'PYEOF'


# Rate limiting configuration
RATE_LIMIT_WINDOW = 60  # seconds
RATE_LIMIT_MAX_REQUESTS = 100

def rate_limit(func):
    """Apply rate limiting to an endpoint."""
    def wrapper(*args, **kwargs):
        # Check rate limit before processing
        client_ip = request.remote_addr
        if _is_rate_limited(client_ip):
            return jsonify({"error": "rate limit exceeded"}), 429
        return func(*args, **kwargs)
    return wrapper

def _is_rate_limited(client_ip):
    """Check if a client has exceeded the rate limit."""
    # TODO: implement with Redis backend
    return False
PYEOF

cat >> "$REPO/services/api/src/config.py" << 'PYEOF'

        # Rate limiting
        self.rate_limit_enabled = os.environ.get("RATE_LIMIT_ENABLED", "true").lower() == "true"
        self.rate_limit_window = int(os.environ.get("RATE_LIMIT_WINDOW", 60))
        self.rate_limit_max_requests = int(os.environ.get("RATE_LIMIT_MAX", 100))
PYEOF

cat >> "$REPO/services/api/tests/test_routes.py" << 'PYEOF'


def test_rate_limit_returns_429(client):
    """Test that rate limiting returns 429 when exceeded."""
    # TODO: implement once Redis mock is available
    pass


def test_rate_limit_allows_normal_traffic(client):
    """Test that normal traffic is not rate limited."""
    response = client.get("/health")
    assert response.status_code == 200
PYEOF

# Worker changes: improve retry logic
cat >> "$REPO/services/worker/src/main.py" << 'PYEOF'


# Retry configuration
MAX_RETRIES = 5
RETRY_BACKOFF_BASE = 2  # exponential backoff base in seconds

def process_with_retry(job, retries=0):
    """Process a job with exponential backoff retry."""
    try:
        return process_job(job)
    except Exception as e:
        if retries >= MAX_RETRIES:
            logger.error("Job %s failed after %d retries: %s", job.id, retries, e)
            send_to_dead_letter_queue(job)
            return False
        wait_time = RETRY_BACKOFF_BASE ** retries
        logger.warning("Job %s failed, retrying in %ds (attempt %d/%d)", job.id, wait_time, retries + 1, MAX_RETRIES)
        time.sleep(wait_time)
        return process_with_retry(job, retries + 1)
PYEOF

cat >> "$REPO/services/worker/src/config.py" << 'PYEOF'

        # Retry settings
        self.max_retries = int(os.environ.get("MAX_RETRIES", 5))
        self.retry_backoff_base = int(os.environ.get("RETRY_BACKOFF_BASE", 2))
        self.dead_letter_queue = os.environ.get("DEAD_LETTER_QUEUE", "dlq")
PYEOF

# --- Stage EVERYTHING (simulating the accidental "stage all" mistake) ---
git -C "$REPO" add -A

# Tag the current state so we can reference it
git -C "$REPO" tag exercise-start

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "All changes are staged (the accidental 'stage all' has happened)."
info "Open lazygit in that directory:"
echo ""
echo "  cd ${REPO} && lazygit"
echo ""
