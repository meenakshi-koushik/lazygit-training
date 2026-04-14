#!/usr/bin/env bash
# lib/verify.sh -- Shared verification/assertion helpers for lesson verify scripts
#
# Usage: source this file after sourcing lib/common.sh
#
# All assertion functions:
#   - Print a pass/fail message
#   - Return 0 on pass, exit 1 on fail (halts the verify script)

_CHECKS_PASSED=0
_CHECKS_TOTAL=0

# Run at the end of a verify script to print a summary
verify_summary() {
    separator
    if [[ $_CHECKS_PASSED -eq $_CHECKS_TOTAL ]]; then
        success "All checks passed (${_CHECKS_PASSED}/${_CHECKS_TOTAL})!"
        echo ""
        color_echo green "Congratulations -- lesson complete!"
    else
        error "Some checks failed (${_CHECKS_PASSED}/${_CHECKS_TOTAL} passed)"
    fi
}

_pass() {
    _CHECKS_TOTAL=$((_CHECKS_TOTAL + 1))
    _CHECKS_PASSED=$((_CHECKS_PASSED + 1))
    success "$1"
}

_fail() {
    _CHECKS_TOTAL=$((_CHECKS_TOTAL + 1))
    error "$1"
    exit 1
}

# --- Assertions ---

# Check that a branch exists
assert_branch_exists() {
    local branch="$1"
    local repo="${2:-.}"
    if git -C "$repo" rev-parse --verify "refs/heads/${branch}" &>/dev/null; then
        _pass "Branch '${branch}' exists"
    else
        _fail "Branch '${branch}' does not exist"
    fi
}

# Check that HEAD is on a specific branch
assert_on_branch() {
    local expected="$1"
    local repo="${2:-.}"
    local actual
    actual=$(git -C "$repo" symbolic-ref --short HEAD 2>/dev/null)
    if [[ "$actual" == "$expected" ]]; then
        _pass "On branch '${expected}'"
    else
        _fail "Expected to be on branch '${expected}' but on '${actual}'"
    fi
}

# Check there are no uncommitted changes
assert_clean_working_tree() {
    local repo="${1:-.}"
    if git -C "$repo" diff --quiet && git -C "$repo" diff --cached --quiet; then
        _pass "Working tree is clean"
    else
        _fail "Working tree has uncommitted changes"
    fi
}

# Check the total number of commits (on the current branch)
assert_commit_count() {
    local expected="$1"
    local repo="${2:-.}"
    local actual
    actual=$(git -C "$repo" rev-list --count HEAD)
    if [[ "$actual" -eq "$expected" ]]; then
        _pass "Commit count is ${expected}"
    else
        _fail "Expected ${expected} commits but found ${actual}"
    fi
}

# Check the number of commits ahead of a base ref
assert_commits_ahead() {
    local base="$1"
    local expected="$2"
    local repo="${3:-.}"
    local actual
    actual=$(git -C "$repo" rev-list --count "${base}..HEAD")
    if [[ "$actual" -eq "$expected" ]]; then
        _pass "HEAD is ${expected} commits ahead of '${base}'"
    else
        _fail "Expected ${expected} commits ahead of '${base}' but found ${actual}"
    fi
}

# Check that a commit message contains a substring
assert_commit_message_contains() {
    local ref="$1"
    local substring="$2"
    local repo="${3:-.}"
    local msg
    msg=$(git -C "$repo" log -1 --format="%s" "$ref")
    if [[ "$msg" == *"$substring"* ]]; then
        _pass "Commit '${ref}' message contains '${substring}'"
    else
        _fail "Commit '${ref}' message '${msg}' does not contain '${substring}'"
    fi
}

# Check that a file contains specific content
assert_file_contains() {
    local file="$1"
    local content="$2"
    if [[ ! -f "$file" ]]; then
        _fail "File '${file}' does not exist"
    elif grep -qF "$content" "$file"; then
        _pass "File '${file}' contains expected content"
    else
        _fail "File '${file}' does not contain '${content}'"
    fi
}

# Check that a file does NOT contain specific content
assert_file_not_contains() {
    local file="$1"
    local content="$2"
    if [[ ! -f "$file" ]]; then
        _pass "File '${file}' does not exist (OK)"
    elif grep -qF "$content" "$file"; then
        _fail "File '${file}' should not contain '${content}'"
    else
        _pass "File '${file}' does not contain '${content}'"
    fi
}

# Check that no merge conflicts are active
assert_no_conflicts() {
    local repo="${1:-.}"
    if git -C "$repo" diff --name-only --diff-filter=U | grep -q .; then
        _fail "There are unresolved merge conflicts"
    else
        _pass "No merge conflicts"
    fi
}

# Check that a file is staged (in the index)
assert_file_staged() {
    local file="$1"
    local repo="${2:-.}"
    if git -C "$repo" diff --cached --name-only | grep -qF "$file"; then
        _pass "File '${file}' is staged"
    else
        _fail "File '${file}' is not staged"
    fi
}

# Check that a file is NOT staged
assert_file_not_staged() {
    local file="$1"
    local repo="${2:-.}"
    if git -C "$repo" diff --cached --name-only | grep -qF "$file"; then
        _fail "File '${file}' should not be staged"
    else
        _pass "File '${file}' is not staged"
    fi
}

# Check that staging area has exactly N files
assert_staged_file_count() {
    local expected="$1"
    local repo="${2:-.}"
    local actual
    actual=$(git -C "$repo" diff --cached --name-only | wc -l)
    if [[ "$actual" -eq "$expected" ]]; then
        _pass "Staged file count is ${expected}"
    else
        _fail "Expected ${expected} staged files but found ${actual}"
    fi
}

# Check that a file exists
assert_file_exists() {
    local file="$1"
    if [[ -f "$file" ]]; then
        _pass "File '${file}' exists"
    else
        _fail "File '${file}' does not exist"
    fi
}

# Check that the working tree has modifications (unstaged changes)
assert_has_unstaged_changes() {
    local repo="${1:-.}"
    if ! git -C "$repo" diff --quiet; then
        _pass "Working tree has unstaged changes"
    else
        _fail "Working tree has no unstaged changes (expected some)"
    fi
}

# Check that the working tree has NO unstaged changes
assert_no_unstaged_changes() {
    local repo="${1:-.}"
    if git -C "$repo" diff --quiet; then
        _pass "No unstaged changes"
    else
        _fail "Working tree has unstaged changes (expected none)"
    fi
}

# Check that a specific number of stash entries exist
assert_stash_count() {
    local expected="$1"
    local repo="${2:-.}"
    local actual
    actual=$(git -C "$repo" stash list 2>/dev/null | wc -l)
    if [[ "$actual" -eq "$expected" ]]; then
        _pass "Stash count is ${expected}"
    else
        _fail "Expected ${expected} stash entries but found ${actual}"
    fi
}
