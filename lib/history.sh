#!/usr/bin/env bash
# lib/history.sh -- Functions to generate realistic commit histories
#
# Usage: source this file after sourcing lib/common.sh

# Pool of realistic conventional-commit messages
_COMMIT_MESSAGES=(
    "feat(api): add rate limiting middleware"
    "fix(auth): resolve token expiration edge case"
    "feat(worker): add retry logic for failed jobs"
    "docs: update API endpoint documentation"
    "fix(api): handle null response from upstream"
    "feat(libs/common): add structured logging helper"
    "chore: bump dependency versions"
    "fix(worker): prevent duplicate message processing"
    "feat(api): add pagination to list endpoints"
    "refactor(auth): extract token validation logic"
    "test(api): add integration tests for rate limiter"
    "feat(infra): add horizontal pod autoscaler config"
    "fix(api): correct CORS headers for preflight"
    "feat(worker): add dead letter queue support"
    "chore(ci): parallelize test stages"
    "fix(libs/common): handle timezone edge case in date utils"
    "feat(api): implement request validation middleware"
    "refactor(worker): simplify job scheduling logic"
    "docs: add architecture decision records"
    "feat(api): add bulk import endpoint"
    "fix(auth): refresh token rotation not thread-safe"
    "feat(infra): add Redis cluster terraform module"
    "test(worker): add unit tests for retry logic"
    "fix(api): memory leak in connection pool"
    "feat(libs/common): add circuit breaker pattern"
    "chore: update CI pipeline for monorepo builds"
    "fix(worker): graceful shutdown not draining queue"
    "feat(api): add OpenAPI spec generation"
    "refactor(infra): consolidate helm value files"
    "feat(auth): add SAML SSO support"
)

# Files to touch for each commit (creates realistic-looking changes)
_TOUCHABLE_FILES=(
    "services/api/src/main.py"
    "services/api/src/routes.py"
    "services/api/src/config.py"
    "services/api/tests/test_routes.py"
    "services/worker/src/main.py"
    "services/worker/src/config.py"
    "services/auth/src/main.py"
    "services/auth/src/routes.py"
    "libs/common/src/common.py"
    "libs/common/tests/test_common.py"
    "infra/terraform/main.tf"
    "infra/terraform/variables.tf"
    "infra/helm/values.yaml"
    "docs/README.md"
    "Makefile"
)

# Create N commits with realistic messages touching various files
# Usage: make_commits /path/to/repo 10
make_commits() {
    local repo_path="$1"
    local count="$2"
    local msg_count=${#_COMMIT_MESSAGES[@]}

    for ((i = 0; i < count; i++)); do
        local msg="${_COMMIT_MESSAGES[$((i % msg_count))]}"

        # Pick a file to modify based on the commit message
        local file_idx=$(( (i * 3 + 1) % ${#_TOUCHABLE_FILES[@]} ))
        local file="${_TOUCHABLE_FILES[$file_idx]}"
        local full_path="${repo_path}/${file}"

        # Only touch files that exist
        if [[ -f "$full_path" ]]; then
            echo "# Change $((i + 1)) -- $(date -u +%Y-%m-%dT%H:%M:%S)" >> "$full_path"
            git -C "$repo_path" add "$file"
        else
            # Create a dummy file to ensure we have something to commit
            local dummy="${repo_path}/.changes/change-${i}.txt"
            mkdir -p "$(dirname "$dummy")"
            echo "Change $((i + 1))" > "$dummy"
            git -C "$repo_path" add .changes/
        fi

        git -C "$repo_path" commit --quiet -m "$msg"
    done
}

# Create a branch with N commits
# Usage: make_branch_with_commits /path/to/repo feature-branch 5
make_branch_with_commits() {
    local repo_path="$1"
    local branch="$2"
    local count="$3"

    git -C "$repo_path" checkout --quiet -b "$branch"
    make_commits "$repo_path" "$count"
}

# Create two branches that diverge from the current commit
# Usage: make_diverged_branches /path/to/repo branch-a branch-b 3 4
make_diverged_branches() {
    local repo_path="$1"
    local branch1="$2"
    local branch2="$3"
    local count1="$4"
    local count2="$5"

    # Save the current branch/ref as the divergence point
    local base_ref
    base_ref=$(git -C "$repo_path" rev-parse HEAD)

    # Create first branch
    git -C "$repo_path" checkout --quiet -b "$branch1"
    make_commits "$repo_path" "$count1"

    # Go back to divergence point and create second branch
    git -C "$repo_path" checkout --quiet "$base_ref"
    git -C "$repo_path" checkout --quiet -b "$branch2"
    make_commits "$repo_path" "$count2"
}

# Create conflicting changes in the same file on two branches
# Usage: make_conflict /path/to/repo branch-a branch-b path/to/file
make_conflict() {
    local repo_path="$1"
    local branch1="$2"
    local branch2="$3"
    local file="$4"

    # Save current branch
    local original_branch
    original_branch=$(git -C "$repo_path" symbolic-ref --short HEAD 2>/dev/null || git -C "$repo_path" rev-parse HEAD)

    # Modify the file on branch1
    git -C "$repo_path" checkout --quiet "$branch1"
    cat >> "${repo_path}/${file}" << 'EOF'

# Changes from branch1
def branch1_feature():
    """This function was added in branch1."""
    return "branch1"
EOF
    git -C "$repo_path" add "$file"
    git -C "$repo_path" commit --quiet -m "feat: add feature from ${branch1}"

    # Modify the same file on branch2 (conflicting change)
    git -C "$repo_path" checkout --quiet "$branch2"
    cat >> "${repo_path}/${file}" << 'EOF'

# Changes from branch2
def branch2_feature():
    """This function was added in branch2."""
    return "branch2"
EOF
    git -C "$repo_path" add "$file"
    git -C "$repo_path" commit --quiet -m "feat: add feature from ${branch2}"

    # Return to original branch
    git -C "$repo_path" checkout --quiet "$original_branch"
}

# Append a realistic modification to an existing file
# Usage: append_modification /path/to/file "description"
append_modification() {
    local file="$1"
    local description="${2:-modification}"

    if [[ -f "$file" ]]; then
        echo "" >> "$file"
        echo "# ${description}" >> "$file"
        echo "# Modified at $(date -u +%Y-%m-%dT%H:%M:%S)" >> "$file"
    fi
}

# Create a series of "work in progress" commits (messy history for rebase lessons)
# Usage: make_wip_commits /path/to/repo 5
make_wip_commits() {
    local repo_path="$1"
    local count="$2"

    local wip_messages=(
        "WIP: starting feature"
        "WIP"
        "fix typo"
        "wip: more progress"
        "oops, forgot this file"
        "WIP: almost done"
        "cleanup"
        "WIP: debugging"
        "fixed the thing"
        "add missing import"
    )

    for ((i = 0; i < count; i++)); do
        local msg="${wip_messages[$((i % ${#wip_messages[@]}))]}"
        local dummy="${repo_path}/.changes/wip-${i}.txt"
        mkdir -p "$(dirname "$dummy")"
        echo "WIP change $((i + 1))" > "$dummy"
        git -C "$repo_path" add .changes/
        git -C "$repo_path" commit --quiet -m "$msg"
    done
}
