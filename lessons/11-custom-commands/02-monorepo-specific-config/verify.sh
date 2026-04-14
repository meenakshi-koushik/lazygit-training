#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="02-monorepo-specific-config"
EXERCISE_DIR="${SANDBOX_DIR}/${EXERCISE_NAME}"
CONFIG_FILE="${EXERCISE_DIR}/lazygit.yml"

if [[ ! -d "$EXERCISE_DIR" ]]; then
    error "Sandbox not found at ${EXERCISE_DIR}. Run setup first: ./train.sh start 11/2"
    exit 1
fi

info "Verifying lesson: Monorepo-Specific Config"
separator

set +e

# Strip YAML comments for all checks
config_no_comments=$(grep -v '^\s*#' "$CONFIG_FILE" 2>/dev/null || true)

# 1. Config file must exist
if [[ -f "$CONFIG_FILE" ]]; then
    _pass "lazygit.yml config file exists"
else
    _fail "lazygit.yml not found at ${CONFIG_FILE}"
fi

# 2. showFileTree is true
if echo "$config_no_comments" | grep -q 'showFileTree:.*true'; then
    _pass "gui.showFileTree is set to true"
else
    _fail "gui.showFileTree should be set to true"
fi

# 3. showNumstatInFilesView is true
if echo "$config_no_comments" | grep -q 'showNumstatInFilesView:.*true'; then
    _pass "gui.showNumstatInFilesView is set to true"
else
    _fail "gui.showNumstatInFilesView should be set to true"
fi

# 4. mainBranches includes 'main'
if echo "$config_no_comments" | grep -qE '^\s*-\s*main\s*$'; then
    _pass "git.mainBranches includes 'main'"
else
    _fail "git.mainBranches should include 'main'"
fi

# 5. mainBranches includes 'develop'
if echo "$config_no_comments" | grep -qE '^\s*-\s*develop\s*$'; then
    _pass "git.mainBranches includes 'develop'"
else
    _fail "git.mainBranches should include 'develop'"
fi

# 6. diffContextSize is 5
if echo "$config_no_comments" | grep -q 'diffContextSize:.*5'; then
    _pass "git.diffContextSize is set to 5"
else
    _fail "git.diffContextSize should be set to 5"
fi

# 7. commitPrefix has a pattern
if echo "$config_no_comments" | grep -q 'commitPrefix'; then
    if echo "$config_no_comments" | grep -q 'pattern:'; then
        _pass "git.commitPrefix has a pattern defined"
    else
        _fail "git.commitPrefix should have a 'pattern:' entry"
    fi
else
    _fail "git.commitPrefix section is missing"
fi

# 8. commitPrefix has a replace string with $1 or \\1
if echo "$config_no_comments" | grep -q 'replace:'; then
    _pass "git.commitPrefix has a replace string"
else
    _fail "git.commitPrefix should have a 'replace:' entry (e.g., '[$1] ')"
fi

# 9. customCommands section exists with SelectedFile template variable
if echo "$config_no_comments" | grep -q 'customCommands'; then
    if echo "$config_no_comments" | grep -q 'SelectedFile'; then
        _pass "customCommands uses SelectedFile template variable"
    else
        _fail "Custom command should use {{.SelectedFile.Name}} template variable"
    fi
else
    _fail "customCommands section is missing"
fi

# 10. Custom command bound to key 't' in 'files' context with subprocess
if echo "$config_no_comments" | grep -qE 'key:\s*"?t"?\s*$|key:\s*'"'"'t'"'"''; then
    _pass "Custom command bound to key 't'"
else
    _fail "Custom command should be bound to key 't'"
fi

if echo "$config_no_comments" | grep -q 'subprocess:.*true'; then
    _pass "Custom command has subprocess: true"
else
    _fail "Custom command should have subprocess: true"
fi

verify_summary
