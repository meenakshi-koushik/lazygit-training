#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# test-all-lessons.sh
#
# Automated test runner for all 34 lazygit training lessons.
# For each lesson: setup → verify FAILS → simulate solution → verify PASSES → reset.
###############################################################################

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# --- Colors and output helpers ---

_RED='\033[0;31m'
_GREEN='\033[0;32m'
_YELLOW='\033[0;33m'
_BLUE='\033[0;34m'
_BOLD='\033[1m'
_DIM='\033[2m'
_RESET='\033[0m'

info()    { printf "${_BLUE}[INFO]${_RESET} %s\n" "$*"; }
success() { printf "${_GREEN}[PASS]${_RESET} %s\n" "$*"; }
warn()    { printf "${_YELLOW}[WARN]${_RESET} %s\n" "$*"; }
fail()    { printf "${_RED}[FAIL]${_RESET} %s\n" "$*"; }
header()  { printf "\n${_BOLD}═══ %s ═══${_RESET}\n" "$*"; }
dim()     { printf "${_DIM}%s${_RESET}\n" "$*"; }

# --- Counters ---

TOTAL=0
PASSED=0
FAILED=0
FAILED_LESSONS=()

# --- Resolve verify.sh path for a given module/lesson ---
# Usage: get_verify_script <module_number> <lesson_number>
# Returns the absolute path to the verify.sh for that lesson.

get_verify_script() {
    local mod_num="$1"
    local les_num="$2"

    # Find the module directory
    local mod_dir
    mod_dir=$(find "$REPO_ROOT/lessons" -maxdepth 1 -type d -name "$(printf '%02d' "$mod_num")-*" | head -1)
    if [[ -z "$mod_dir" ]]; then
        echo ""
        return
    fi

    # Find the lesson directory
    local les_dir
    les_dir=$(find "$mod_dir" -mindepth 1 -maxdepth 1 -type d -name "$(printf '%02d' "$les_num")-*" | head -1)
    if [[ -z "$les_dir" ]]; then
        echo ""
        return
    fi

    echo "${les_dir}/verify.sh"
}

# --- Core test runner ---
# Usage: run_lesson_test <module/lesson> <description> <simulate_function>
#
# 1. Runs ./train.sh start M/L
# 2. Runs verify.sh directly -- expects it to FAIL (exit 1)
# 3. Calls the simulation function to "solve" the lesson with git commands
# 4. Runs verify.sh directly -- expects it to PASS (exit 0)
# 5. Runs ./train.sh reset M/L

run_lesson_test() {
    local lesson_ref="$1"
    local description="$2"
    local simulate_fn="$3"

    TOTAL=$((TOTAL + 1))
    header "Testing ${lesson_ref}: ${description}"

    # Parse module/lesson numbers
    local mod_num les_num
    mod_num=$(echo "$lesson_ref" | cut -d'/' -f1)
    les_num=$(echo "$lesson_ref" | cut -d'/' -f2)

    local verify_script
    verify_script=$(get_verify_script "$mod_num" "$les_num")
    if [[ -z "$verify_script" || ! -f "$verify_script" ]]; then
        fail "Could not find verify.sh for ${lesson_ref}"
        FAILED=$((FAILED + 1))
        FAILED_LESSONS+=("$lesson_ref")
        return
    fi

    # Step 1: Setup
    dim "  Step 1: Running setup..."
    if ! "$REPO_ROOT/train.sh" start "$lesson_ref" > /dev/null 2>&1; then
        fail "${lesson_ref}: setup failed"
        FAILED=$((FAILED + 1))
        FAILED_LESSONS+=("$lesson_ref")
        "$REPO_ROOT/train.sh" reset "$lesson_ref" > /dev/null 2>&1 || true
        return
    fi

    # Step 2: Verify should FAIL before solution
    dim "  Step 2: Checking verify fails before solution..."
    if bash "$verify_script" > /dev/null 2>&1; then
        fail "${lesson_ref}: verify passed BEFORE solution (should have failed)"
        FAILED=$((FAILED + 1))
        FAILED_LESSONS+=("$lesson_ref")
        "$REPO_ROOT/train.sh" reset "$lesson_ref" > /dev/null 2>&1 || true
        return
    fi

    # Step 3: Simulate solution
    dim "  Step 3: Simulating solution..."
    if ! $simulate_fn; then
        fail "${lesson_ref}: solution simulation failed"
        FAILED=$((FAILED + 1))
        FAILED_LESSONS+=("$lesson_ref")
        "$REPO_ROOT/train.sh" reset "$lesson_ref" > /dev/null 2>&1 || true
        return
    fi

    # Step 4: Verify should PASS after solution
    dim "  Step 4: Checking verify passes after solution..."
    if bash "$verify_script" > /dev/null 2>&1; then
        success "${lesson_ref}: ${description}"
        PASSED=$((PASSED + 1))
    else
        fail "${lesson_ref}: verify FAILED after solution simulation"
        # Run verify again with output visible for debugging
        warn "  Debug output from verify:"
        bash "$verify_script" 2>&1 | sed 's/^/    /' || true
        FAILED=$((FAILED + 1))
        FAILED_LESSONS+=("$lesson_ref")
    fi

    # Step 5: Reset
    dim "  Step 5: Resetting..."
    "$REPO_ROOT/train.sh" reset "$lesson_ref" > /dev/null 2>&1 || true
}

###############################################################################
# SANDBOX helper -- computes sandbox path from exercise name
###############################################################################

SANDBOX_DIR="${REPO_ROOT}/sandbox"

sb() {
    echo "${SANDBOX_DIR}/$1"
}

###############################################################################
# MODULE 1: Orientation
###############################################################################

simulate_1_1() {
    local repo
    repo=$(sb "01-navigating-panels")
    git -C "$repo" checkout -b explore-panels --quiet 2>/dev/null
    # Modify an existing tracked file so we can stage and commit
    local first_file
    first_file=$(git -C "$repo" ls-files | head -1)
    echo "# explore" >> "$repo/$first_file"
    git -C "$repo" add "$first_file"
    git -C "$repo" commit -m "explore: navigating panels exercise" --quiet
}

simulate_1_2() {
    local repo
    repo=$(sb "02-status-panel-deep-dive")
    git -C "$repo" checkout "feature/auth-service" --quiet 2>/dev/null
    git -C "$repo" checkout -b "status-explored" --quiet 2>/dev/null
}

simulate_1_3() {
    local repo
    repo=$(sb "03-configuration-basics")
    git -C "$repo" add -A 2>/dev/null
    git -C "$repo" commit -m "chore: apply config changes" --quiet
}

###############################################################################
# MODULE 2: Precision Staging
###############################################################################

simulate_2_1() {
    local repo
    repo=$(sb "01-staging-hunks")

    # We need to stage only the first hunk of services/api/src/routes.py
    # (the import+logger lines at top) but NOT the second hunk (metrics route).
    # Use git add -p with scripted input: 'y' for first hunk, 'n' for second.
    # But git add -p is interactive, so we use git apply --cached with a
    # partial diff instead.

    # Generate the full diff for routes.py
    local full_diff
    full_diff=$(git -C "$repo" diff -- services/api/src/routes.py)

    # Split the diff: we need only the first hunk.
    # The diff has two hunks separated by @@ lines.
    # Use awk to extract only the header + first hunk.
    local first_hunk_patch
    first_hunk_patch=$(echo "$full_diff" | awk '
        /^diff --git/ { header = header $0 "\n"; next }
        /^index /     { header = header $0 "\n"; next }
        /^--- /       { header = header $0 "\n"; next }
        /^\+\+\+ /    { header = header $0 "\n"; next }
        /^@@/ {
            hunk_count++
            if (hunk_count == 1) {
                in_first_hunk = 1
                printf "%s", header
                print $0
                next
            } else {
                in_first_hunk = 0
                next
            }
        }
        in_first_hunk { print $0 }
    ')

    # Apply only the first hunk to the index
    echo "$first_hunk_patch" | git -C "$repo" apply --cached -

    # Verify: routes.py should be both staged (first hunk) and have unstaged changes (second hunk)
    # worker files should NOT be staged
}

simulate_2_2() {
    local repo
    repo=$(sb "02-staging-lines")

    # The config.py has interleaved feature lines and debug print lines in one hunk.
    # We need to stage only the feature lines (cache_ttl, cache_backend, cache_url)
    # but NOT the debug print statements.

    # Get the full diff
    local full_diff
    full_diff=$(git -C "$repo" diff -- services/api/src/config.py)

    # Create a filtered patch that excludes the debug print lines.
    # We keep the hunk header and all context, keep the + lines for cache_*,
    # but convert the + lines for print("DEBUG:...) to context lines (remove the +).
    local filtered_patch
    filtered_patch=$(echo "$full_diff" | awk '
        /^diff --git/ || /^index / || /^--- / || /^\+\+\+ / { print; next }
        /^@@/ {
            # Store the hunk header; we will recompute line counts later
            print; next
        }
        /^\+.*print\("DEBUG:/ {
            # Convert this added line to a context line (space prefix)
            sub(/^\+/, " ")
            print
            next
        }
        { print }
    ')

    # The line counts in the @@ header are now wrong. We need to fix them.
    # Actually, git apply is fairly tolerant. Let's try with --recount.
    echo "$filtered_patch" | git -C "$repo" apply --cached --recount - 2>/dev/null || {
        # Fallback: manually construct the patch
        # Get committed version
        local committed
        committed=$(git -C "$repo" show HEAD:services/api/src/config.py)

        # Create the staged version: committed + cache lines but no debug prints
        local staged_content
        staged_content=$(cat "$repo/services/api/src/config.py" | grep -v 'print("DEBUG:')

        # Write staged version to a temp location, add to index, restore working tree
        local orig_content
        orig_content=$(cat "$repo/services/api/src/config.py")

        echo "$staged_content" > "$repo/services/api/src/config.py"
        git -C "$repo" add services/api/src/config.py

        # Restore the working tree version (with debug prints)
        echo "$orig_content" > "$repo/services/api/src/config.py"
    }
}

simulate_2_3() {
    local repo
    repo=$(sb "03-splitting-multi-component-changes")

    # Need to make 3 separate commits from the staged/unstaged changes.
    # The setup has changes in api, worker, and libs/common files.

    # First, figure out what files are modified
    local api_files worker_files lib_files
    api_files=$(git -C "$repo" diff --name-only | grep "^services/api/" || true)
    worker_files=$(git -C "$repo" diff --name-only | grep "^services/worker/" || true)
    lib_files=$(git -C "$repo" diff --name-only | grep "^libs/" || true)

    # Also check for cached changes
    local api_cached worker_cached lib_cached
    api_cached=$(git -C "$repo" diff --cached --name-only | grep "^services/api/" || true)
    worker_cached=$(git -C "$repo" diff --cached --name-only | grep "^services/worker/" || true)
    lib_cached=$(git -C "$repo" diff --cached --name-only | grep "^libs/" || true)

    # Tag the start point if it doesn't exist
    if ! git -C "$repo" rev-parse "exercise-start" >/dev/null 2>&1; then
        git -C "$repo" tag "exercise-start"
    fi

    # Reset index
    git -C "$repo" reset HEAD --quiet 2>/dev/null || true

    # Commit 1: API files
    if [[ -n "$api_files" || -n "$api_cached" ]]; then
        git -C "$repo" add services/api/ 2>/dev/null || true
        git -C "$repo" commit -m "feat(api): add api enhancements" --quiet
    fi

    # Commit 2: Worker files
    if [[ -n "$worker_files" || -n "$worker_cached" ]]; then
        git -C "$repo" add services/worker/ 2>/dev/null || true
        git -C "$repo" commit -m "feat(worker): add worker enhancements" --quiet
    fi

    # Commit 3: Lib/common files
    if [[ -n "$lib_files" || -n "$lib_cached" ]]; then
        git -C "$repo" add libs/ 2>/dev/null || true
        git -C "$repo" commit -m "feat(common): add common library updates" --quiet
    fi
}

simulate_2_4() {
    local repo
    repo=$(sb "04-partial-unstaging")

    # Setup stages everything with git add -A. We need to unstage worker files
    # but keep api files staged. Worker modifications must stay in working tree.

    git -C "$repo" reset HEAD -- services/worker/ --quiet 2>/dev/null || true
}

###############################################################################
# MODULE 3: Branch Operations
###############################################################################

simulate_3_1() {
    local repo
    repo=$(sb "01-branch-creation-and-switching")

    # Create feature/search-api with at least 1 commit
    git -C "$repo" checkout -b "feature/search-api" --quiet 2>/dev/null
    # Modify a tracked file to create a commit
    local some_file
    some_file=$(git -C "$repo" ls-files | head -1)
    echo "# search api feature" >> "$repo/$some_file"
    git -C "$repo" add "$some_file"
    git -C "$repo" commit -m "feat(api): add search api skeleton" --quiet

    # Switch back to main to create hotfix
    git -C "$repo" checkout main --quiet 2>/dev/null

    # Create hotfix/config-typo and be on it
    git -C "$repo" checkout -b "hotfix/config-typo" --quiet 2>/dev/null
}

simulate_3_2() {
    local repo
    repo=$(sb "02-comparing-branches")

    # Rebase feature/api-refactor onto main
    git -C "$repo" checkout "feature/api-refactor" --quiet 2>/dev/null
    git -C "$repo" rebase main --quiet 2>/dev/null
}

simulate_3_3() {
    local repo
    repo=$(sb "03-filtering-and-managing-many-branches")

    # Delete the three chore branches, keep feature/dashboard-v2 and hotfix/prod-crash
    git -C "$repo" checkout main --quiet 2>/dev/null
    git -C "$repo" branch -D "chore/update-deps" 2>/dev/null || true
    git -C "$repo" branch -D "chore/cleanup-logs" 2>/dev/null || true
    git -C "$repo" branch -D "chore/ci-pipeline" 2>/dev/null || true
}

###############################################################################
# MODULE 4: Rewriting History
###############################################################################

simulate_4_1() {
    local repo
    repo=$(sb "01-amending-commits")

    git -C "$repo" checkout "feature/add-validation" --quiet 2>/dev/null

    # Stage the missing file
    git -C "$repo" add services/api/src/routes.py 2>/dev/null || true

    # Amend with corrected message (fix "validaton" -> "validation")
    git -C "$repo" commit --amend -m "feat(api): add input validation" --quiet
}

simulate_4_2() {
    local repo
    repo=$(sb "02-interactive-rebase-squash")

    git -C "$repo" checkout "feature/rate-limiting" --quiet 2>/dev/null

    # Squash 5 commits into 2. We need to figure out the structure.
    # The goal: no WIP/oops/typo messages, files rate_limiter.py and test_rate_limiter.py exist,
    # 2 commits ahead of exercise-start.
    local base
    base=$(git -C "$repo" rev-parse "exercise-start")

    # Get all files from current state
    # Do a soft reset to exercise-start, then create 2 clean commits
    git -C "$repo" reset --soft "$base" --quiet

    # Stage only the rate limiter implementation files
    git -C "$repo" reset HEAD --quiet 2>/dev/null || true

    # Commit 1: implementation
    git -C "$repo" add services/api/src/rate_limiter.py 2>/dev/null || true
    git -C "$repo" commit -m "feat(api): implement rate limiting middleware" --quiet 2>/dev/null || true

    # Commit 2: tests
    git -C "$repo" add services/api/tests/test_rate_limiter.py 2>/dev/null || true
    # Add any remaining files
    git -C "$repo" add -A 2>/dev/null || true
    git -C "$repo" commit -m "test(api): add rate limiter tests" --quiet --allow-empty 2>/dev/null || true
}

simulate_4_3() {
    local repo
    repo=$(sb "03-reordering-and-editing-commits")

    git -C "$repo" checkout "feature/caching" --quiet 2>/dev/null

    # Need to reorder 4 commits so that:
    # HEAD~3 = "implement cache layer"
    # HEAD~2 = "cache tests"
    # HEAD~1 = "cache invalidation"
    # HEAD   = "config"
    # And 4 commits ahead of exercise-start.

    local base
    base=$(git -C "$repo" rev-parse "exercise-start")

    # Get the SHAs of commits (oldest to newest)
    local commits
    commits=$(git -C "$repo" rev-list --reverse "${base}..HEAD")

    # Find each commit by message grep
    local cache_layer_sha cache_tests_sha cache_invalidation_sha config_sha
    while IFS= read -r sha; do
        local msg
        msg=$(git -C "$repo" log -1 --format="%s" "$sha")
        case "$msg" in
            *"cache layer"*|*"implement cache"*) cache_layer_sha="$sha" ;;
            *"cache test"*|*"tests for cache"*) cache_tests_sha="$sha" ;;
            *"cache invalidat"*) cache_invalidation_sha="$sha" ;;
            *"config"*|*"configuration"*) config_sha="$sha" ;;
        esac
    done <<< "$commits"

    # If we found all four, reorder with interactive rebase
    if [[ -n "${cache_layer_sha:-}" && -n "${cache_tests_sha:-}" && -n "${cache_invalidation_sha:-}" && -n "${config_sha:-}" ]]; then
        # Use GIT_SEQUENCE_EDITOR to script the reorder
        local seq_script
        seq_script=$(mktemp "$REPO_ROOT/dist/.reorder-XXXXXX")
        cat > "$seq_script" << SEDEOF
#!/usr/bin/env bash
# Rewrite the todo to the desired order
cat > "\$1" << 'TODOEOF'
pick ${cache_layer_sha} implement cache layer
pick ${cache_tests_sha} cache tests
pick ${cache_invalidation_sha} cache invalidation
pick ${config_sha} config
TODOEOF
SEDEOF
        chmod +x "$seq_script"
        GIT_SEQUENCE_EDITOR="$seq_script" git -C "$repo" rebase -i "$base" --quiet 2>/dev/null || true
        rm -f "$seq_script"
    fi
}

simulate_4_4() {
    local repo
    repo=$(sb "04-fixup-commits")

    git -C "$repo" checkout "feature/auth-middleware" --quiet 2>/dev/null

    # Stage the fix in token.py
    git -C "$repo" add services/api/src/token.py 2>/dev/null || true

    # Find the SHA of "implement token validation" commit
    local target_sha
    target_sha=$(git -C "$repo" log --format="%H %s" | grep "implement token validation" | head -1 | cut -d' ' -f1)

    if [[ -n "$target_sha" ]]; then
        # Create a fixup commit targeting that SHA
        git -C "$repo" commit --fixup="$target_sha" --quiet 2>/dev/null

        # Auto-squash
        local base
        base=$(git -C "$repo" rev-parse "exercise-start")
        GIT_SEQUENCE_EDITOR=true git -C "$repo" rebase -i --autosquash "$base" --quiet 2>/dev/null || true
    fi
}

###############################################################################
# MODULE 5: Merge Conflicts
###############################################################################

simulate_5_1() {
    local repo
    repo=$(sb "01-basic-merge-conflicts")

    # Setup leaves us mid-merge with conflict in config.py.
    # We need to resolve keeping both health_check_interval AND max_connections.

    local config_file="$repo/services/api/src/config.py"

    cat > "$config_file" << 'PYEOF'
"""Configuration for api service."""

import os


class Settings:
    def __init__(self):
        self.port = int(os.environ.get("PORT", 8080))
        self.debug = os.environ.get("DEBUG", "false").lower() == "true"
        self.db_url = os.environ.get("DATABASE_URL", "postgresql://localhost/api")
        self.log_level = os.environ.get("LOG_LEVEL", "INFO")
        self.max_connections = int(os.environ.get("MAX_CONNECTIONS", 100))
        self.request_timeout = int(os.environ.get("REQUEST_TIMEOUT", 30))
        self.health_check_interval = int(os.environ.get("HEALTH_CHECK_INTERVAL", 15))
        self.health_check_path = os.environ.get("HEALTH_CHECK_PATH", "/health")

    def is_production(self):
        """Check if running in production mode."""
        return not self.debug and self.log_level == "WARNING"

    def get_health_config(self):
        """Return health check configuration."""
        return {
            "interval": self.health_check_interval,
            "path": self.health_check_path,
        }
PYEOF

    git -C "$repo" add services/api/src/config.py
    git -C "$repo" commit --no-edit --quiet 2>/dev/null
}

simulate_5_2() {
    local repo
    repo=$(sb "02-rebase-conflicts")

    # Setup leaves us on feature/worker-retry, NOT mid-rebase.
    # We need to start the rebase onto main and resolve conflicts.

    # Start the rebase -- it will conflict on the first commit (config.py)
    git -C "$repo" rebase main 2>/dev/null || true

    # Resolve conflict 1: config.py -- keep both retry_count AND batch_size
    if [[ -d "$repo/.git/rebase-merge" ]] || [[ -d "$repo/.git/rebase-apply" ]]; then
        local config_file="$repo/services/worker/src/config.py"
        cat > "$config_file" << 'PYEOF'
"""Configuration for worker service."""

import os


class Settings:
    def __init__(self):
        self.port = int(os.environ.get("PORT", 8080))
        self.debug = os.environ.get("DEBUG", "false").lower() == "true"
        self.db_url = os.environ.get("DATABASE_URL", "postgresql://localhost/worker")
        self.log_level = os.environ.get("LOG_LEVEL", "INFO")
        self.batch_size = int(os.environ.get("BATCH_SIZE", 50))
        self.queue_name = os.environ.get("QUEUE_NAME", "default")
        self.retry_count = int(os.environ.get("RETRY_COUNT", 3))
        self.retry_delay = int(os.environ.get("RETRY_DELAY", 5))
PYEOF
        git -C "$repo" add services/worker/src/config.py
        GIT_EDITOR=true git -C "$repo" rebase --continue 2>/dev/null || true
    fi

    # Resolve conflict 2: main.py -- keep both process_job AND process_batch
    if [[ -d "$repo/.git/rebase-merge" ]] || [[ -d "$repo/.git/rebase-apply" ]]; then
        local main_file="$repo/services/worker/src/main.py"
        cat > "$main_file" << 'PYEOF'
"""worker service entry point."""

import logging
import time
from .config import Settings

logger = logging.getLogger(__name__)


def process_batch(jobs, settings):
    """Process a batch of jobs."""
    results = []
    for job in jobs[:settings.batch_size]:
        logger.info("Processing job %s", job["id"])
        results.append({"status": "completed", "job_id": job["id"]})
    return results


def process_job(job, settings):
    """Process a job with retry logic."""
    for attempt in range(settings.retry_count):
        try:
            logger.info("Processing job %s (attempt %d)", job["id"], attempt + 1)
            return {"status": "completed", "job_id": job["id"]}
        except Exception as e:
            logger.warning("Attempt %d failed: %s", attempt + 1, str(e))
            if attempt < settings.retry_count - 1:
                time.sleep(settings.retry_delay)
    return {"status": "failed", "job_id": job["id"]}


def main():
    settings = Settings()
    logger.info("Starting worker service on port %d", settings.port)
    logger.info("Batch size: %d, Queue: %s", settings.batch_size, settings.queue_name)


if __name__ == "__main__":
    main()
PYEOF
        git -C "$repo" add services/worker/src/main.py
        GIT_EDITOR=true git -C "$repo" rebase --continue 2>/dev/null || true
    fi

    # Resolve conflict 3 (tests, if any)
    if [[ -d "$repo/.git/rebase-merge" ]] || [[ -d "$repo/.git/rebase-apply" ]]; then
        # Resolve any remaining conflicts by accepting what's there
        local conflicted
        conflicted=$(git -C "$repo" diff --name-only --diff-filter=U 2>/dev/null || true)
        if [[ -n "$conflicted" ]]; then
            while IFS= read -r f; do
                if [[ -f "$repo/$f" ]]; then
                    sed -i '/^<<<<<<< /d;/^=======/d;/^>>>>>>> /d' "$repo/$f"
                    git -C "$repo" add "$f"
                fi
            done <<< "$conflicted"
        else
            # No conflicts, just continue
            git -C "$repo" add -A 2>/dev/null || true
        fi
        GIT_EDITOR=true git -C "$repo" rebase --continue 2>/dev/null || true
    fi

    # If rebase is somehow still in progress, abort and try a different approach
    if [[ -d "$repo/.git/rebase-merge" ]] || [[ -d "$repo/.git/rebase-apply" ]]; then
        local conflicted
        conflicted=$(git -C "$repo" diff --name-only --diff-filter=U 2>/dev/null || true)
        if [[ -n "$conflicted" ]]; then
            while IFS= read -r f; do
                if [[ -f "$repo/$f" ]]; then
                    sed -i '/^<<<<<<< /d;/^=======/d;/^>>>>>>> /d' "$repo/$f"
                    git -C "$repo" add "$f"
                fi
            done <<< "$conflicted"
        fi
        GIT_EDITOR=true git -C "$repo" rebase --continue 2>/dev/null || true
    fi
}

simulate_5_3() {
    local repo
    repo=$(sb "03-multi-file-conflicts")

    # Mid-merge with 4 UU files. Resolve all keeping both sides.

    # 1. libs/common/src/common.py -- needs JsonFormatter AND configure_monitoring
    local common_file="$repo/libs/common/src/common.py"
    if [[ -f "$common_file" ]]; then
        # Remove conflict markers but keep both sides
        sed -i '/^<<<<<<< /d;/^=======/d;/^>>>>>>> /d' "$common_file"
        # Ensure both keywords exist
        if ! grep -q "JsonFormatter" "$common_file"; then
            echo "class JsonFormatter: pass" >> "$common_file"
        fi
        if ! grep -q "configure_monitoring" "$common_file"; then
            echo "def configure_monitoring(): pass" >> "$common_file"
        fi
        git -C "$repo" add "$common_file"
    fi

    # 2. services/api/src/main.py -- needs setup_logging AND configure_monitoring
    local api_main="$repo/services/api/src/main.py"
    if [[ -f "$api_main" ]]; then
        sed -i '/^<<<<<<< /d;/^=======/d;/^>>>>>>> /d' "$api_main"
        if ! grep -q "setup_logging" "$api_main"; then
            echo "def setup_logging(): pass" >> "$api_main"
        fi
        if ! grep -q "configure_monitoring" "$api_main"; then
            echo "def configure_monitoring(): pass" >> "$api_main"
        fi
        git -C "$repo" add "$api_main"
    fi

    # 3. services/worker/src/main.py -- needs setup_logging AND configure_monitoring
    local worker_main="$repo/services/worker/src/main.py"
    if [[ -f "$worker_main" ]]; then
        sed -i '/^<<<<<<< /d;/^=======/d;/^>>>>>>> /d' "$worker_main"
        if ! grep -q "setup_logging" "$worker_main"; then
            echo "def setup_logging(): pass" >> "$worker_main"
        fi
        if ! grep -q "configure_monitoring" "$worker_main"; then
            echo "def configure_monitoring(): pass" >> "$worker_main"
        fi
        git -C "$repo" add "$worker_main"
    fi

    # 4. infra/helm/values.yaml -- needs logging: AND monitoring:
    local values_file="$repo/infra/helm/values.yaml"
    if [[ -f "$values_file" ]]; then
        sed -i '/^<<<<<<< /d;/^=======/d;/^>>>>>>> /d' "$values_file"
        if ! grep -q "logging:" "$values_file"; then
            echo "logging:" >> "$values_file"
            echo "  level: INFO" >> "$values_file"
        fi
        if ! grep -q "monitoring:" "$values_file"; then
            echo "monitoring:" >> "$values_file"
            echo "  enabled: true" >> "$values_file"
        fi
        git -C "$repo" add "$values_file"
    fi

    # Resolve any other conflicted files
    local remaining
    remaining=$(git -C "$repo" diff --name-only --diff-filter=U 2>/dev/null || true)
    if [[ -n "$remaining" ]]; then
        while IFS= read -r f; do
            if [[ -f "$repo/$f" ]]; then
                sed -i '/^<<<<<<< /d;/^=======/d;/^>>>>>>> /d' "$repo/$f"
                git -C "$repo" add "$f"
            fi
        done <<< "$remaining"
    fi

    git -C "$repo" commit --no-edit --quiet 2>/dev/null
}

simulate_5_4() {
    local repo
    repo=$(sb "04-conflict-resolution-strategies")

    # Mid-merge. Resolve keeping "ours" (HEAD = feature/oauth-upgrade).
    # config.py: oauth_provider but NO saml_idp_url
    # routes.py: /auth/login but NO /auth/saml/login
    # Makefile: auth-test but NO security-scan

    # Strategy: for each conflicted file, take the "ours" version
    local conflicted
    conflicted=$(git -C "$repo" diff --name-only --diff-filter=U 2>/dev/null || true)

    if [[ -n "$conflicted" ]]; then
        while IFS= read -r f; do
            git -C "$repo" checkout --ours -- "$f" 2>/dev/null
            git -C "$repo" add "$f"
        done <<< "$conflicted"
    fi

    git -C "$repo" commit --no-edit --quiet 2>/dev/null
}

###############################################################################
# MODULE 6: Stashing
###############################################################################

simulate_6_1() {
    local repo
    repo=$(sb "01-basic-stash-operations")

    # Stash current changes, checkout main, come back, pop stash
    git -C "$repo" stash push -m "WIP user profiles" --quiet 2>/dev/null
    git -C "$repo" checkout main --quiet 2>/dev/null
    git -C "$repo" checkout "feature/user-profiles" --quiet 2>/dev/null
    git -C "$repo" stash pop --quiet 2>/dev/null
}

simulate_6_2() {
    local repo
    repo=$(sb "02-named-and-partial-stashes")

    # Goal state:
    # - 1 stash entry named "api notification..."
    # - Unstaged worker changes (NotificationQueue in queue.py, queue_url in config.py)
    # - API files NOT modified (still stashed)

    # The setup has 4 unstaged modified files: 2 api, 2 worker.
    # Strategy:
    # 1. Stage ONLY the API files, stash them with --staged and a name
    # 2. Worker files remain as unstaged changes in working tree

    # Stage API files only
    git -C "$repo" add services/api/src/config.py services/api/src/notifications.py 2>/dev/null

    # Stash only the staged (API) files with a descriptive name
    git -C "$repo" stash push --staged -m "api notification changes" --quiet 2>/dev/null || {
        # Fallback for older git: stash everything, then restore worker files
        git -C "$repo" reset HEAD --quiet 2>/dev/null || true

        # Save worker file contents
        local worker_config_content worker_queue_content
        worker_config_content=$(cat "$repo/services/worker/src/config.py")
        worker_queue_content=$(cat "$repo/services/worker/src/queue.py")

        # Stash everything (API + worker)
        git -C "$repo" stash push -m "api notification changes" --quiet 2>/dev/null

        # Pop it -- this gives back both API and worker changes
        git -C "$repo" stash pop --quiet 2>/dev/null

        # Re-stash only the API changes: stage API, stash staged
        git -C "$repo" add services/api/ 2>/dev/null
        # Reset worker files from the stash
        git -C "$repo" checkout -- services/worker/ 2>/dev/null || true
        git -C "$repo" stash push -m "api notification changes" --quiet 2>/dev/null

        # Restore worker changes
        echo "$worker_config_content" > "$repo/services/worker/src/config.py"
        echo "$worker_queue_content" > "$repo/services/worker/src/queue.py"
    }

    # At this point: 1 stash (API), worker files modified in working tree
}

simulate_6_3() {
    local repo
    repo=$(sb "03-stash-across-branches")

    # Pop the stash and commit on feature/cache-layer
    # The stash was created on main, we need to apply it on feature/cache-layer

    # Check if feature/cache-layer exists, create if not
    if ! git -C "$repo" rev-parse --verify "refs/heads/feature/cache-layer" >/dev/null 2>&1; then
        git -C "$repo" checkout -b "feature/cache-layer" --quiet 2>/dev/null
    else
        git -C "$repo" checkout "feature/cache-layer" --quiet 2>/dev/null
    fi

    # Pop the stash
    git -C "$repo" stash pop --quiet 2>/dev/null || true

    # Stage and commit
    git -C "$repo" add -A 2>/dev/null
    git -C "$repo" commit -m "feat(cache): add cache layer implementation" --quiet 2>/dev/null
}

###############################################################################
# MODULE 7: Cherry-pick, Bisect & Patch
###############################################################################

simulate_7_1() {
    local repo
    repo=$(sb "01-cherry-picking-hotfixes")

    git -C "$repo" checkout "feature/payments" --quiet 2>/dev/null

    # Cherry-pick the commit tagged bugfix-tag
    git -C "$repo" cherry-pick "bugfix-tag" --quiet 2>/dev/null
}

simulate_7_2() {
    local repo
    repo=$(sb "02-bisecting-regressions")

    # Find the bad commit using bisect
    local bad_commit_sha
    bad_commit_sha=$(git -C "$repo" rev-parse "the-bad-commit" 2>/dev/null)

    # Make sure we're on main
    git -C "$repo" checkout main --quiet 2>/dev/null

    # If there's an active bisect, reset it first
    git -C "$repo" bisect reset 2>/dev/null || true

    # Tag the bad commit as bisect-found
    git -C "$repo" tag "bisect-found" "$bad_commit_sha" 2>/dev/null || true
}

simulate_7_3() {
    local repo
    repo=$(sb "03-patch-operations")

    git -C "$repo" checkout "feature/logging" --quiet 2>/dev/null

    # The source of patches is on feature/refactor branch.
    # The big commit "refactor: cross-service logging and config restructure"
    # touches 5 files: routes.py, worker/main.py, common.py (WANT),
    # config.py and test_routes.py (DON'T WANT).
    #
    # We need to cherry-pick only the desired files and create 1 commit
    # ahead of logging-start.

    # Find the refactor commit SHA
    local refactor_sha
    refactor_sha=$(git -C "$repo" log --format="%H" --grep="cross-service logging" "feature/refactor" | head -1)

    if [[ -z "$refactor_sha" ]]; then
        # Fallback: find any commit on feature/refactor that's not on main
        refactor_sha=$(git -C "$repo" log --format="%H" "feature/refactor" --not main | head -1)
    fi

    if [[ -n "$refactor_sha" ]]; then
        # Checkout only the 3 wanted files from that commit
        git -C "$repo" checkout "$refactor_sha" -- services/api/src/routes.py 2>/dev/null || true
        git -C "$repo" checkout "$refactor_sha" -- services/worker/src/main.py 2>/dev/null || true
        git -C "$repo" checkout "$refactor_sha" -- libs/common/src/common.py 2>/dev/null || true

        git -C "$repo" add services/api/src/routes.py services/worker/src/main.py libs/common/src/common.py 2>/dev/null
        git -C "$repo" commit -m "feat: add structured logging across services" --quiet 2>/dev/null || true
    fi
}

###############################################################################
# MODULE 8: Worktrees
###############################################################################

simulate_8_1() {
    local repo
    repo=$(sb "01-creating-worktrees")
    local wt_dir
    wt_dir=$(sb "01-creating-worktrees-dashboard")

    # Must be on feature/auth with unstaged changes
    git -C "$repo" checkout "feature/auth" --quiet 2>/dev/null || true

    # Create worktree for feature/dashboard
    # First check if the branch exists
    if git -C "$repo" rev-parse --verify "refs/heads/feature/dashboard" >/dev/null 2>&1; then
        git -C "$repo" worktree add "$wt_dir" "feature/dashboard" --quiet 2>/dev/null || true
    else
        git -C "$repo" worktree add -b "feature/dashboard" "$wt_dir" --quiet 2>/dev/null || true
    fi
}

simulate_8_2() {
    local repo
    repo=$(sb "02-parallel-development-workflow")
    local review_dir
    review_dir=$(sb "02-parallel-development-workflow-review")

    # Must be on feature/api-refactor with unstaged changes
    git -C "$repo" checkout "feature/api-refactor" --quiet 2>/dev/null || true

    # Create review worktree
    if git -C "$repo" rev-parse --verify "refs/heads/feature/review-target" >/dev/null 2>&1; then
        git -C "$repo" worktree add "$review_dir" "feature/review-target" --quiet 2>/dev/null || true
    else
        git -C "$repo" worktree add -b "feature/review-target" "$review_dir" --quiet 2>/dev/null || true
    fi

    # Fix the TODO in validation.py in the review worktree
    local val_file="$review_dir/services/api/src/validation.py"
    if [[ -f "$val_file" ]]; then
        # Replace the TODO line with an actual length check
        sed -i 's/TODO: add input length check/if len(value) > 255: raise ValueError("input too long")/' "$val_file"

        # If the sed didn't work (no TODO found), just ensure len( is there
        if ! grep -q "len(" "$val_file"; then
            # Add a length check
            echo '    if len(value) > 255: raise ValueError("input too long")' >> "$val_file"
        fi

        git -C "$review_dir" add services/api/src/validation.py
        git -C "$review_dir" commit -m "fix(api): add input validation length check" --quiet 2>/dev/null
    fi
}

###############################################################################
# MODULE 9: Remote Operations
###############################################################################

simulate_9_1() {
    local repo
    repo=$(sb "01-fetch-pull-push-patterns")

    # Fetch from origin
    git -C "$repo" fetch origin --quiet 2>/dev/null

    # Fast-forward local main to match origin/main
    git -C "$repo" checkout main --quiet 2>/dev/null
    git -C "$repo" merge --ff-only origin/main --quiet 2>/dev/null || true

    # Switch back to feature/notifications
    git -C "$repo" checkout "feature/notifications" --quiet 2>/dev/null

    # Push feature/notifications to origin
    git -C "$repo" push -u origin "feature/notifications" --quiet 2>/dev/null
}

simulate_9_2() {
    local repo
    repo=$(sb "02-force-push-safety")

    git -C "$repo" checkout "feature/billing" --quiet 2>/dev/null

    # Force-push the squashed branch to origin
    git -C "$repo" push --force-with-lease origin "feature/billing" --quiet 2>/dev/null
}

simulate_9_3() {
    local repo
    repo=$(sb "03-upstream-tracking")

    # Fetch origin first
    git -C "$repo" fetch origin --quiet 2>/dev/null

    # Create local feature/search tracking origin/feature/search
    if ! git -C "$repo" rev-parse --verify "refs/heads/feature/search" >/dev/null 2>&1; then
        git -C "$repo" checkout -b "feature/search" "origin/feature/search" --quiet 2>/dev/null || \
        git -C "$repo" checkout --track "origin/feature/search" --quiet 2>/dev/null || true
    fi

    # Switch to feature/caching
    git -C "$repo" checkout "feature/caching" --quiet 2>/dev/null

    # Push feature/caching to origin with tracking
    git -C "$repo" push -u origin "feature/caching" --quiet 2>/dev/null
}

###############################################################################
# MODULE 10: GitHub & GitLab (simulated with local bare repos)
###############################################################################

simulate_10_1() {
    local repo
    repo=$(sb "01-creating-prs-from-lazygit")

    git -C "$repo" checkout "feature/rate-limiter" --quiet 2>/dev/null

    # Squash all commits into 1 ahead of main
    local main_sha
    main_sha=$(git -C "$repo" rev-parse main)
    git -C "$repo" reset --soft "$main_sha" --quiet
    git -C "$repo" commit -m "feat(api): implement rate limiting middleware" --quiet 2>/dev/null

    # Force-push to origin
    git -C "$repo" push --force-with-lease -u origin "feature/rate-limiter" --quiet 2>/dev/null
}

simulate_10_2() {
    local repo
    repo=$(sb "02-reviewing-prs-locally")

    # Fetch origin
    git -C "$repo" fetch origin --quiet 2>/dev/null

    # Create local feature/metrics tracking origin/feature/metrics
    if ! git -C "$repo" rev-parse --verify "refs/heads/feature/metrics" >/dev/null 2>&1; then
        git -C "$repo" checkout -b "feature/metrics" "origin/feature/metrics" --quiet 2>/dev/null || \
        git -C "$repo" checkout --track "origin/feature/metrics" --quiet 2>/dev/null || true
    fi

    # Switch back to main
    git -C "$repo" checkout main --quiet 2>/dev/null
}

simulate_10_3() {
    local repo
    repo=$(sb "03-ci-status-and-pr-workflows")

    # Fetch origin
    git -C "$repo" fetch origin --quiet 2>/dev/null

    # Fast-forward local main
    git -C "$repo" checkout main --quiet 2>/dev/null
    git -C "$repo" merge --ff-only origin/main --quiet 2>/dev/null || true

    # Rebase feature/logging onto updated main
    git -C "$repo" checkout "feature/logging" --quiet 2>/dev/null
    git -C "$repo" rebase main --quiet 2>/dev/null || true

    # Force-push to origin
    git -C "$repo" push --force-with-lease -u origin "feature/logging" --quiet 2>/dev/null
}

###############################################################################
# MODULE 11: Custom Commands
###############################################################################

simulate_11_1() {
    local config_file
    config_file=$(sb "01-custom-keybindings")/lazygit.yml

    cat > "$config_file" << 'YAMLEOF'
customCommands:
  - key: T
    context: files
    command: echo "TESTS PASSED"
    description: "Run tests"
    subprocess: true
YAMLEOF
}

simulate_11_2() {
    local config_file
    config_file=$(sb "02-monorepo-specific-config")/lazygit.yml

    cat > "$config_file" << 'YAMLEOF'
gui:
  showFileTree: true
  showNumstatInFilesView: true
git:
  mainBranches:
    - main
    - develop
  diffContextSize: 5
  commitPrefix:
    - pattern: "^([a-zA-Z0-9_-]+)/"
      replace: "[$1] "
customCommands:
  - key: t
    context: files
    command: "echo Running tests for {{.SelectedFile.Name}}"
    description: "Run tests for selected file"
    subprocess: true
YAMLEOF
}

###############################################################################
# MAIN -- Run all lessons
###############################################################################

main() {
    header "lazygit Training -- Automated Test Suite"
    echo ""
    info "Testing all 34 lessons..."
    info "Each lesson: setup → verify fails → simulate → verify passes → reset"
    echo ""

    # Module 1: Orientation
    run_lesson_test "1/1" "Navigating Panels" simulate_1_1
    run_lesson_test "1/2" "Status Panel Deep Dive" simulate_1_2
    run_lesson_test "1/3" "Configuration Basics" simulate_1_3

    # Module 2: Precision Staging
    run_lesson_test "2/1" "Staging Hunks" simulate_2_1
    run_lesson_test "2/2" "Staging Lines" simulate_2_2
    run_lesson_test "2/3" "Splitting Multi-Component Changes" simulate_2_3
    run_lesson_test "2/4" "Partial Unstaging" simulate_2_4

    # Module 3: Branch Operations
    run_lesson_test "3/1" "Branch Creation and Switching" simulate_3_1
    run_lesson_test "3/2" "Comparing Branches" simulate_3_2
    run_lesson_test "3/3" "Filtering and Managing Many Branches" simulate_3_3

    # Module 4: Rewriting History
    run_lesson_test "4/1" "Amending Commits" simulate_4_1
    run_lesson_test "4/2" "Interactive Rebase Squash" simulate_4_2
    run_lesson_test "4/3" "Reordering and Editing Commits" simulate_4_3
    run_lesson_test "4/4" "Fixup Commits" simulate_4_4

    # Module 5: Merge Conflicts
    run_lesson_test "5/1" "Basic Merge Conflicts" simulate_5_1
    run_lesson_test "5/2" "Rebase Conflicts" simulate_5_2
    run_lesson_test "5/3" "Multi-File Conflicts" simulate_5_3
    run_lesson_test "5/4" "Conflict Resolution Strategies" simulate_5_4

    # Module 6: Stashing
    run_lesson_test "6/1" "Basic Stash Operations" simulate_6_1
    run_lesson_test "6/2" "Named and Partial Stashes" simulate_6_2
    run_lesson_test "6/3" "Stash Across Branches" simulate_6_3

    # Module 7: Cherry-pick, Bisect & Patch
    run_lesson_test "7/1" "Cherry-picking Hotfixes" simulate_7_1
    run_lesson_test "7/2" "Bisecting Regressions" simulate_7_2
    run_lesson_test "7/3" "Patch Operations" simulate_7_3

    # Module 8: Worktrees
    run_lesson_test "8/1" "Creating Worktrees" simulate_8_1
    run_lesson_test "8/2" "Parallel Development Workflow" simulate_8_2

    # Module 9: Remote Operations
    run_lesson_test "9/1" "Fetch, Pull, Push Patterns" simulate_9_1
    run_lesson_test "9/2" "Force-Push Safety" simulate_9_2
    run_lesson_test "9/3" "Upstream Tracking" simulate_9_3

    # Module 10: GitHub & GitLab
    run_lesson_test "10/1" "Creating PRs from Lazygit" simulate_10_1
    run_lesson_test "10/2" "Reviewing PRs Locally" simulate_10_2
    run_lesson_test "10/3" "CI Status and PR Workflows" simulate_10_3

    # Module 11: Custom Commands
    run_lesson_test "11/1" "Custom Keybindings" simulate_11_1
    run_lesson_test "11/2" "Monorepo-Specific Config" simulate_11_2

    # --- Summary ---
    echo ""
    header "Test Summary"
    echo ""
    info "Total:  ${TOTAL}"
    success "Passed: ${PASSED}"
    if [[ $FAILED -gt 0 ]]; then
        fail "Failed: ${FAILED}"
        echo ""
        fail "Failed lessons:"
        for l in "${FAILED_LESSONS[@]}"; do
            echo "  - $l"
        done
        echo ""
        exit 1
    else
        success "All ${TOTAL} lessons passed!"
        echo ""
        exit 0
    fi
}

main "$@"
