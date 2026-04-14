#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="02-force-push-safety"

info "Setting up exercise: ${EXERCISE_NAME}"

# --- Create a bare repo to act as "origin" ---

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

# 1. Build a seed repo with monorepo structure
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

# Create the feature/billing branch with 4 WIP commits (pre-squash state)
git -C "$TEMP_SEED" checkout --quiet -b "feature/billing"

# WIP commit 1
mkdir -p "$TEMP_SEED/services/billing/src"
cat > "$TEMP_SEED/services/billing/src/main.py" << 'PYEOF'
"""Billing service entry point."""

import logging
from .config import Settings

logger = logging.getLogger(__name__)


def main():
    settings = Settings()
    logger.info("Starting billing service on port %d", settings.port)

if __name__ == "__main__":
    main()
PYEOF

cat > "$TEMP_SEED/services/billing/src/__init__.py" << 'PYEOF'
PYEOF

cat > "$TEMP_SEED/services/billing/src/config.py" << 'PYEOF'
"""Configuration for billing service."""

import os


class Settings:
    def __init__(self):
        self.port = int(os.environ.get("PORT", 8085))
        self.stripe_key = os.environ.get("STRIPE_API_KEY", "")
        self.db_url = os.environ.get("DATABASE_URL", "postgresql://localhost/billing")
PYEOF

git -C "$TEMP_SEED" add services/billing/
git -C "$TEMP_SEED" commit --quiet -m "WIP: start billing service"

# WIP commit 2
cat > "$TEMP_SEED/services/billing/src/invoices.py" << 'PYEOF'
"""Invoice management for billing service."""


class InvoiceManager:
    def __init__(self, db_url):
        self.db_url = db_url

    def create_invoice(self, customer_id, items):
        # TODO: implement
        pass

    def get_invoice(self, invoice_id):
        # TODO: implement
        pass
PYEOF

git -C "$TEMP_SEED" add services/billing/src/invoices.py
git -C "$TEMP_SEED" commit --quiet -m "WIP: add invoice manager skeleton"

# WIP commit 3
cat > "$TEMP_SEED/services/billing/src/payments.py" << 'PYEOF'
"""Payment processing for billing service."""


class PaymentProcessor:
    def __init__(self, stripe_key):
        self.stripe_key = stripe_key

    def charge(self, customer_id, amount_cents, currency="usd"):
        """Charge a customer."""
        # TODO: integrate with Stripe API
        return {"status": "pending", "amount": amount_cents, "currency": currency}

    def refund(self, charge_id):
        """Refund a charge."""
        # TODO: implement
        return {"status": "refunded", "charge_id": charge_id}
PYEOF

git -C "$TEMP_SEED" add services/billing/src/payments.py
git -C "$TEMP_SEED" commit --quiet -m "WIP: add payment processor"

# WIP commit 4
mkdir -p "$TEMP_SEED/services/billing/tests"
cat > "$TEMP_SEED/services/billing/tests/test_payments.py" << 'PYEOF'
"""Tests for payment processor."""

import pytest
from src.payments import PaymentProcessor


def test_charge():
    processor = PaymentProcessor("test_key")
    result = processor.charge("cust_123", 5000)
    assert result["status"] == "pending"
    assert result["amount"] == 5000


def test_refund():
    processor = PaymentProcessor("test_key")
    result = processor.refund("ch_123")
    assert result["status"] == "refunded"
PYEOF

git -C "$TEMP_SEED" add services/billing/tests/
git -C "$TEMP_SEED" commit --quiet -m "wip: add payment tests"

# Go back to main
git -C "$TEMP_SEED" checkout --quiet main

# 2. Create bare repo from seed
git clone --bare --quiet "$TEMP_SEED" "$BARE_REPO"

# 3. Clone for the learner
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"
git clone --quiet "$BARE_REPO" "$REPO"
configure_git_user "$REPO"

# 4. Check out feature/billing
git -C "$REPO" checkout --quiet "feature/billing"

# 5. Now simulate: learner rebased locally (squashed the 4 WIP commits into 1)
# We do this by resetting to the point where the branch diverged from main,
# then creating a single clean commit with all the billing code.

# Record the current tree (all the billing code is in the working tree)
# Save the commit that has all billing changes
billing_tree=$(git -C "$REPO" rev-parse HEAD^{tree})

# Reset to the base (main)
git -C "$REPO" reset --quiet --soft main

# Create one clean squashed commit
git -C "$REPO" commit --quiet -m "feat(billing): add billing service with invoices, payments, and tests

- Add billing service skeleton with configuration
- Add InvoiceManager for invoice CRUD operations
- Add PaymentProcessor with Stripe integration stubs
- Add payment processor unit tests"

# At this point:
# - Local feature/billing has 1 commit (the squashed one) ahead of main
# - origin/feature/billing still has 4 WIP commits
# - These have diverged -- regular push will fail

# Clean up temp repos
rm -rf "$TEMP_SEED"

success "Exercise '${EXERCISE_NAME}' is ready at: ${REPO}"
info "You are on 'feature/billing'. You rebased and squashed 4 WIP commits into 1 clean commit."
info "Your local branch has diverged from origin -- a regular push will be rejected."
info "You need to force-push safely."
info "Open lazygit with:"
echo ""
echo "  lazygit -p ${REPO}"
echo ""
