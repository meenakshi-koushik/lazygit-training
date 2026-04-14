#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../../../lib/common.sh"
source "${SCRIPT_DIR}/../../../lib/monorepo.sh"
source "${SCRIPT_DIR}/../../../lib/history.sh"

EXERCISE_NAME="01-custom-keybindings"

info "Setting up exercise: ${EXERCISE_NAME}"

ensure_sandbox
clean_sandbox "$EXERCISE_NAME"

EXERCISE_DIR="${SANDBOX_DIR}/${EXERCISE_NAME}"
mkdir -p "$EXERCISE_DIR"

# Create a repo inside the exercise directory
REPO="${EXERCISE_DIR}/repo"
mkdir -p "$REPO"
git -C "$REPO" init --quiet
configure_git_user "$REPO"

create_monorepo "$REPO"
add_service "$REPO" "api"
add_service "$REPO" "worker"
add_library "$REPO" "common"

git -C "$REPO" add -A
git -C "$REPO" commit --quiet -m "chore: initial monorepo scaffolding"

make_commits "$REPO" 5

# Create a starter lazygit config file with some basic settings
# but NO custom commands (the learner needs to add them)
cat > "$EXERCISE_DIR/lazygit.yml" << 'YAMLEOF'
# Lazygit configuration for monorepo development
# See: https://github.com/jesseduffield/lazygit/blob/master/docs/Config.md

gui:
  showIcons: false
  showBottomLine: true
  nerdFontsVersion: ""

git:
  paging:
    colorArg: always
  commit:
    signOff: false

os:
  editPreset: ""

# TODO: Add your custom commands below this line.
# See the lesson README for the required fields and values.
YAMLEOF

success "Exercise '${EXERCISE_NAME}' is ready at: ${EXERCISE_DIR}"
info "Edit the lazygit.yml config file to add a custom command."
info "The config file is at: ${EXERCISE_DIR}/lazygit.yml"
info ""
info "To test your config in lazygit:"
echo ""
echo "  lazygit -ucf ${EXERCISE_DIR}/lazygit.yml -p ${REPO}"
echo ""
info "Then verify with: ./train.sh verify 11/1"
echo ""
