#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/verify.sh"

EXERCISE_NAME="01-custom-keybindings"
EXERCISE_DIR="${SANDBOX_DIR}/${EXERCISE_NAME}"
CONFIG_FILE="${EXERCISE_DIR}/lazygit.yml"

if [[ ! -d "$EXERCISE_DIR" ]]; then
    error "Sandbox not found at ${EXERCISE_DIR}. Run setup first: ./train.sh start 11/1"
    exit 1
fi

info "Verifying lesson: Custom Keybindings"
separator

set +e

# Strip YAML comments for all checks (so comments don't falsely pass)
config_no_comments=$(grep -v '^\s*#' "$CONFIG_FILE" 2>/dev/null || true)

# 1. Config file must exist
if [[ -f "$CONFIG_FILE" ]]; then
    _pass "lazygit.yml config file exists"
else
    _fail "lazygit.yml not found at ${CONFIG_FILE}"
fi

# 2. Config must have customCommands section (not in a comment)
if echo "$config_no_comments" | grep -q "customCommands"; then
    _pass "Config contains 'customCommands' section"
else
    _fail "Config does not contain 'customCommands' section -- add it to lazygit.yml"
fi

# 3. Must have a command with key "T"
if echo "$config_no_comments" | grep -qE 'key:\s*"?T"?\s*$|key:\s*'"'"'T'"'"''; then
    _pass "Custom command bound to key 'T'"
else
    _fail "No custom command bound to key 'T' found"
fi

# 4. Must have context "files"
if echo "$config_no_comments" | grep -qE 'context:\s*"?files"?'; then
    _pass "Custom command uses 'files' context"
else
    _fail "Custom command should use 'files' context"
fi

# 5. Must have a command that includes echo "TESTS PASSED"
if echo "$config_no_comments" | grep -q 'TESTS PASSED'; then
    _pass "Custom command includes 'TESTS PASSED' output"
else
    _fail "Custom command should run: echo \"TESTS PASSED\""
fi

# 6. Description must contain "Run tests"
if echo "$config_no_comments" | grep -qi 'Run tests'; then
    _pass "Custom command description contains 'Run tests'"
else
    _fail "Custom command description should contain 'Run tests'"
fi

# 7. subprocess should be true
if echo "$config_no_comments" | grep -q 'subprocess:.*true'; then
    _pass "subprocess is set to true"
else
    _fail "subprocess should be set to true (shows command output in terminal)"
fi

verify_summary
