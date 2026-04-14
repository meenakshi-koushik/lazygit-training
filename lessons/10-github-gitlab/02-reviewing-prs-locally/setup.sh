#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="02-reviewing-prs-locally"

info "Setting up exercise: ${EXERCISE_NAME}"

BARE_REPO="${SANDBOX_DIR}/${EXERCISE_NAME}-origin.git"
if [[ -d "$BARE_REPO" ]]; then
    rm -rf "$BARE_REPO"
fi

TEMP_SEED="${SANDBOX_DIR}/${EXERCISE_NAME}-seed"
if [[ -d "$TEMP_SEED" ]]; then
    rm -rf "$TEMP_SEED"
fi

ensure_sandbox
clean_sandbox "$EXERCISE_NAME"

# 1. Build seed repo
mkdir -p "$TEMP_SEED"
git -C "$TEMP_SEED" init --quiet
configure_git_user "$TEMP_SEED"

create_monorepo "$TEMP_SEED"
add_service "$TEMP_SEED" "api"
add_service "$TEMP_SEED" "worker"
add_library "$TEMP_SEED" "common"
add_infra "$TEMP_SEED"

git -C "$TEMP_SEED" add -A
git -C "$TEMP_SEED" commit --quiet -m "chore: initial monorepo scaffolding"

make_commits "$TEMP_SEED" 8

# Create feature/metrics branch (teammate's PR)
git -C "$TEMP_SEED" checkout --quiet -b "feature/metrics"

# Commit 1: add metrics collector
mkdir -p "$TEMP_SEED/services/api/src"
cat > "$TEMP_SEED/services/api/src/metrics.py" << 'PYEOF'
"""Metrics collection for the API service."""

import time
import logging
from collections import defaultdict

logger = logging.getLogger(__name__)


class MetricsCollector:
    """Collects and exposes application metrics."""

    def __init__(self):
        self._counters = defaultdict(int)
        self._histograms = defaultdict(list)
        self._gauges = {}
        self._start_time = time.time()

    def increment(self, name, value=1, labels=None):
        key = self._make_key(name, labels)
        self._counters[key] += value

    def observe(self, name, value, labels=None):
        key = self._make_key(name, labels)
        self._histograms[key].append(value)

    def set_gauge(self, name, value, labels=None):
        key = self._make_key(name, labels)
        self._gauges[key] = value

    def get_metrics(self):
        return {
            "counters": dict(self._counters),
            "histograms": {k: self._summarize(v) for k, v in self._histograms.items()},
            "gauges": dict(self._gauges),
            "uptime_seconds": time.time() - self._start_time,
        }

    def _make_key(self, name, labels):
        if labels:
            label_str = ",".join(f"{k}={v}" for k, v in sorted(labels.items()))
            return f"{name}{{{label_str}}}"
        return name

    def _summarize(self, values):
        if not values:
            return {}
        sorted_vals = sorted(values)
        return {
            "count": len(values),
            "sum": sum(values),
            "min": sorted_vals[0],
            "max": sorted_vals[-1],
            "avg": sum(values) / len(values),
        }


# Global metrics instance
metrics = MetricsCollector()
PYEOF

git -C "$TEMP_SEED" add services/api/src/metrics.py
git -C "$TEMP_SEED" commit --quiet -m "feat(api): add metrics collector with counters, histograms, and gauges"

# Commit 2: add metrics endpoint
cat >> "$TEMP_SEED/services/api/src/routes.py" << 'PYEOF'


# --- Metrics endpoint ---
from .metrics import metrics

@app.route("/metrics")
def get_metrics():
    return jsonify(metrics.get_metrics())
PYEOF

git -C "$TEMP_SEED" add services/api/src/routes.py
git -C "$TEMP_SEED" commit --quiet -m "feat(api): expose /metrics endpoint"

# Commit 3: add request timing middleware
cat > "$TEMP_SEED/services/api/src/timing.py" << 'PYEOF'
"""Request timing middleware."""

import time
import functools
from flask import request
from .metrics import metrics


def timed_route(f):
    """Decorator to track request duration in metrics."""

    @functools.wraps(f)
    def decorated(*args, **kwargs):
        start = time.time()
        response = f(*args, **kwargs)
        duration = time.time() - start
        metrics.observe(
            "http_request_duration_seconds",
            duration,
            labels={"method": request.method, "path": request.path},
        )
        metrics.increment(
            "http_requests_total",
            labels={"method": request.method, "path": request.path, "status": response.status_code if hasattr(response, 'status_code') else 200},
        )
        return response

    return decorated
PYEOF

git -C "$TEMP_SEED" add services/api/src/timing.py
git -C "$TEMP_SEED" commit --quiet -m "feat(api): add request timing middleware with metrics integration"

# Commit 4: add metrics tests
mkdir -p "$TEMP_SEED/services/api/tests"
cat > "$TEMP_SEED/services/api/tests/test_metrics.py" << 'PYEOF'
"""Tests for metrics collection."""

import pytest
from src.metrics import MetricsCollector


@pytest.fixture
def collector():
    return MetricsCollector()


def test_increment_counter(collector):
    collector.increment("requests_total")
    collector.increment("requests_total")
    metrics = collector.get_metrics()
    assert metrics["counters"]["requests_total"] == 2


def test_observe_histogram(collector):
    collector.observe("response_time", 0.1)
    collector.observe("response_time", 0.2)
    collector.observe("response_time", 0.3)
    metrics = collector.get_metrics()
    summary = metrics["histograms"]["response_time"]
    assert summary["count"] == 3
    assert summary["min"] == 0.1
    assert summary["max"] == 0.3


def test_set_gauge(collector):
    collector.set_gauge("active_connections", 42)
    metrics = collector.get_metrics()
    assert metrics["gauges"]["active_connections"] == 42


def test_labels(collector):
    collector.increment("requests", labels={"method": "GET"})
    collector.increment("requests", labels={"method": "POST"})
    metrics = collector.get_metrics()
    assert metrics["counters"]["requests{method=GET}"] == 1
    assert metrics["counters"]["requests{method=POST}"] == 1
PYEOF

git -C "$TEMP_SEED" add services/api/tests/test_metrics.py
git -C "$TEMP_SEED" commit --quiet -m "test(api): add comprehensive metrics collector tests"

# Go back to main
git -C "$TEMP_SEED" checkout --quiet main

# 2. Create bare repo
git clone --bare --quiet "$TEMP_SEED" "$BARE_REPO"

# 3. Clone for learner (starts on main, feature/metrics exists on origin)
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"
git clone --quiet "$BARE_REPO" "$REPO"
configure_git_user "$REPO"

# Clean up
rm -rf "$TEMP_SEED"

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "You are on 'main'. Your teammate's branch 'feature/metrics' is on origin."
info "Fetch, check it out, review the changes, and return to main."
info "Open lazygit with:"
echo ""
echo "  lazygit -p ${REPO}"
echo ""
