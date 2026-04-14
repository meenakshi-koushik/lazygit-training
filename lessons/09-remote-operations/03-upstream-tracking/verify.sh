#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="03-upstream-tracking"
REPO="${SANDBOX_DIR}/${EXERCISE_NAME}"

if [[ ! -d "$REPO/.git" ]]; then
    error "Sandbox repo not found at ${REPO}. Run setup first: ./train.sh start 9/3"
    exit 1
fi

info "Verifying lesson: Upstream Tracking"
separator

set +e

# 1. feature/search must exist locally
assert_branch_exists "feature/search" "$REPO"

# 2. feature/search must track origin/feature/search
search_upstream=$(git -C "$REPO" for-each-ref --format='%(upstream:short)' refs/heads/feature/search 2>/dev/null || echo "")
if [[ "$search_upstream" == "origin/feature/search" ]]; then
    _pass "feature/search tracks origin/feature/search"
else
    _fail "feature/search does not track origin/feature/search (upstream: '${search_upstream}')"
fi

# 3. feature/search should have the search service commits
search_log=$(git -C "$REPO" log --oneline refs/heads/feature/search 2>/dev/null || echo "")
if echo "$search_log" | grep -q "search"; then
    _pass "feature/search has the search service commits"
else
    _fail "feature/search does not appear to have the expected search service commits"
fi

# 4. feature/caching must be pushed to origin
origin_caching=$(git -C "$REPO" rev-parse refs/remotes/origin/feature/caching 2>/dev/null || echo "none")
if [[ "$origin_caching" != "none" ]]; then
    _pass "feature/caching is pushed to origin"
else
    _fail "feature/caching has not been pushed to origin -- switch to it and press 'P' to push"
fi

# 5. feature/caching must track origin/feature/caching
caching_upstream=$(git -C "$REPO" for-each-ref --format='%(upstream:short)' refs/heads/feature/caching 2>/dev/null || echo "")
if [[ "$caching_upstream" == "origin/feature/caching" ]]; then
    _pass "feature/caching tracks origin/feature/caching"
else
    _fail "feature/caching does not track origin/feature/caching (upstream: '${caching_upstream}') -- set the upstream when pushing"
fi

# 6. feature/caching on origin should match local
local_caching=$(git -C "$REPO" rev-parse refs/heads/feature/caching 2>/dev/null || echo "unknown")
if [[ "$origin_caching" == "$local_caching" ]]; then
    _pass "feature/caching on origin matches local"
else
    _fail "feature/caching on origin does not match local -- push may have failed"
fi

verify_summary
