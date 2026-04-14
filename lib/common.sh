#!/usr/bin/env bash
# lib/common.sh -- Shared utilities for lazygit training scripts
#
# Source this at the top of every setup.sh and verify.sh:
#   source "$(dirname "$0")/../../lib/common.sh"

# --- Paths ---

# Resolve the root of the training repo regardless of where scripts are called from
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SANDBOX_DIR="${REPO_ROOT}/sandbox"
LESSONS_DIR="${REPO_ROOT}/lessons"

# --- Colors ---

_RED='\033[0;31m'
_GREEN='\033[0;32m'
_YELLOW='\033[0;33m'
_BLUE='\033[0;34m'
_BOLD='\033[1m'
_RESET='\033[0m'

color_echo() {
    local color="$1"
    shift
    case "$color" in
        red)    printf "${_RED}%s${_RESET}\n" "$*" ;;
        green)  printf "${_GREEN}%s${_RESET}\n" "$*" ;;
        yellow) printf "${_YELLOW}%s${_RESET}\n" "$*" ;;
        blue)   printf "${_BLUE}%s${_RESET}\n" "$*" ;;
        bold)   printf "${_BOLD}%s${_RESET}\n" "$*" ;;
        *)      printf "%s\n" "$*" ;;
    esac
}

info()    { color_echo blue    "[INFO] $*"; }
success() { color_echo green   "[OK]   $*"; }
warn()    { color_echo yellow  "[WARN] $*"; }
error()   { color_echo red     "[FAIL] $*"; }

# --- Sandbox helpers ---

ensure_sandbox() {
    mkdir -p "$SANDBOX_DIR"
}

clean_sandbox() {
    local name="$1"
    local target="${SANDBOX_DIR}/${name}"
    if [[ -d "$target" ]]; then
        rm -rf "$target"
    fi
}

# --- Git helpers ---

# Configure git user inside a sandbox repo so commits work without global config
configure_git_user() {
    local repo_path="$1"
    git -C "$repo_path" config user.name "Training User"
    git -C "$repo_path" config user.email "learner@lazygit.training"
}

# Initialize a new git repo for an exercise
init_exercise_repo() {
    local name="$1"
    local repo_path="${SANDBOX_DIR}/${name}"

    ensure_sandbox
    clean_sandbox "$name"
    mkdir -p "$repo_path"

    git -C "$repo_path" init --quiet
    configure_git_user "$repo_path"

    echo "$repo_path"
}

# --- Misc ---

# Print a separator line
separator() {
    printf '%*s\n' 60 '' | tr ' ' '─'
}
