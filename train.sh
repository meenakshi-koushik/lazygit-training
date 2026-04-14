#!/usr/bin/env bash
set -euo pipefail

# train.sh -- CLI runner for lazygit training lessons
#
# Usage:
#   ./train.sh list                         List all modules and lessons
#   ./train.sh start <module/lesson>        Set up and start a lesson
#   ./train.sh verify <module/lesson>       Check if objectives are met
#   ./train.sh hint <module/lesson>         Show the next progressive hint
#   ./train.sh reset <module/lesson>        Tear down a lesson's sandbox
#   ./train.sh solution <module/lesson>     Show the full solution walkthrough

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

STATE_DIR="${REPO_ROOT}/.lazygit-training-state"

usage() {
    cat << 'EOF'
Usage: ./train.sh <command> [arguments]

Commands:
  list                     List all modules and lessons
  start <module/lesson>    Set up and start a lesson
  verify <module/lesson>   Check if lesson objectives are met
  hint <module/lesson>     Show the next progressive hint
  reset <module/lesson>    Tear down a lesson's sandbox
  solution <module/lesson> Show the full solution walkthrough

Examples:
  ./train.sh list
  ./train.sh start 01-orientation/01-navigating-panels
  ./train.sh verify 01-orientation/01-navigating-panels
  ./train.sh hint 01-orientation/01-navigating-panels
  ./train.sh reset 01-orientation/01-navigating-panels
  ./train.sh solution 01-orientation/01-navigating-panels
EOF
}

# Resolve a lesson path argument to the lesson directory
resolve_lesson() {
    local arg="$1"
    local lesson_dir="${LESSONS_DIR}/${arg}"

    if [[ ! -d "$lesson_dir" ]]; then
        error "Lesson not found: ${arg}"
        echo "  Expected directory: ${lesson_dir}"
        echo ""
        echo "Run './train.sh list' to see available lessons."
        exit 1
    fi

    echo "$lesson_dir"
}

# Extract the sandbox name from a lesson path (last component)
sandbox_name() {
    local lesson_path="$1"
    basename "$lesson_path"
}

# --- Commands ---

cmd_list() {
    echo ""
    color_echo bold "Lazygit Training -- Lessons"
    separator

    local module_count=0
    local lesson_count=0

    for module_dir in "$LESSONS_DIR"/*/; do
        [[ -d "$module_dir" ]] || continue
        module_count=$((module_count + 1))

        local module_name
        module_name=$(basename "$module_dir")
        echo ""
        color_echo bold "  ${module_name}"

        for lesson_dir in "$module_dir"*/; do
            [[ -d "$lesson_dir" ]] || continue
            lesson_count=$((lesson_count + 1))

            local lesson_name
            lesson_name=$(basename "$lesson_dir")

            local sandbox_path="${SANDBOX_DIR}/${lesson_name}"
            local status_marker="  "

            if [[ -f "${STATE_DIR}/${lesson_name}.done" ]]; then
                status_marker=$(printf "${_GREEN}✓ ${_RESET}")
            elif [[ -d "$sandbox_path" ]]; then
                status_marker=$(printf "${_YELLOW}▶ ${_RESET}")
            fi

            printf "    %b %s/%s" "$status_marker" "$module_name" "$lesson_name"

            # Show lesson title from README if available
            if [[ -f "${lesson_dir}/README.md" ]]; then
                local title
                title=$(head -1 "${lesson_dir}/README.md" | sed 's/^#\+ //')
                printf "  ${_BLUE}-- %s${_RESET}" "$title"
            fi
            echo ""
        done
    done

    echo ""
    separator
    info "${lesson_count} lessons across ${module_count} modules"
    echo ""
    echo "Legend:  ✓ = completed   ▶ = in progress   (blank) = not started"
    echo ""
}

cmd_start() {
    local lesson_dir
    lesson_dir=$(resolve_lesson "$1")
    local name
    name=$(sandbox_name "$lesson_dir")

    separator
    color_echo bold "Starting lesson: $1"
    separator
    echo ""

    # Run setup
    local setup_script="${lesson_dir}/setup.sh"
    if [[ ! -x "$setup_script" ]]; then
        error "setup.sh not found or not executable: ${setup_script}"
        exit 1
    fi

    info "Setting up exercise environment..."
    bash "$setup_script"
    echo ""

    # Print the lesson README
    separator
    if [[ -f "${lesson_dir}/README.md" ]]; then
        cat "${lesson_dir}/README.md"
    fi
    echo ""
    separator

    local sandbox_path="${SANDBOX_DIR}/${name}"
    echo ""
    info "Sandbox ready at: ${sandbox_path}"
    echo ""
    echo "  Next steps:"
    echo "    1. cd ${sandbox_path}"
    echo "    2. lazygit"
    echo "    3. Complete the objectives above"
    echo "    4. Run: ./train.sh verify $1"
    echo ""
    echo "  Stuck? Run: ./train.sh hint $1"
    echo ""
}

cmd_verify() {
    local lesson_dir
    lesson_dir=$(resolve_lesson "$1")
    local name
    name=$(sandbox_name "$lesson_dir")
    local sandbox_path="${SANDBOX_DIR}/${name}"

    separator
    color_echo bold "Verifying lesson: $1"
    separator
    echo ""

    if [[ ! -d "$sandbox_path" ]]; then
        error "Sandbox not found. Run './train.sh start $1' first."
        exit 1
    fi

    local verify_script="${lesson_dir}/verify.sh"
    if [[ ! -x "$verify_script" ]]; then
        error "verify.sh not found or not executable: ${verify_script}"
        exit 1
    fi

    if bash "$verify_script"; then
        # Mark as done
        mkdir -p "$STATE_DIR"
        touch "${STATE_DIR}/${name}.done"
    fi
}

cmd_hint() {
    local lesson_dir
    lesson_dir=$(resolve_lesson "$1")
    local name
    name=$(sandbox_name "$lesson_dir")

    local hints_file="${lesson_dir}/hints.md"
    if [[ ! -f "$hints_file" ]]; then
        error "No hints file found for this lesson."
        exit 1
    fi

    # Track which hint we're on
    mkdir -p "$STATE_DIR"
    local hint_state="${STATE_DIR}/${name}.hint"
    local current_hint=1
    if [[ -f "$hint_state" ]]; then
        current_hint=$(cat "$hint_state")
    fi

    # Parse hints from the markdown file (split on ## Hint N headers)
    local total_hints
    total_hints=$(grep -c '^## Hint' "$hints_file" || true)

    if [[ "$total_hints" -eq 0 ]]; then
        error "No hints found in hints.md"
        exit 1
    fi

    if [[ "$current_hint" -gt "$total_hints" ]]; then
        warn "You've seen all ${total_hints} hints for this lesson."
        echo "  Run './train.sh solution $1' for the full walkthrough."
        return
    fi

    separator
    color_echo bold "Hint ${current_hint} of ${total_hints}"
    separator
    echo ""

    # Extract the Nth hint block
    local in_target=false
    local target_header="## Hint ${current_hint}"
    while IFS= read -r line; do
        if [[ "$line" == "## Hint "* ]]; then
            if [[ "$line" == "$target_header" ]]; then
                in_target=true
                continue
            elif $in_target; then
                break
            fi
        fi
        if $in_target; then
            echo "$line"
        fi
    done < "$hints_file"

    echo ""

    # Advance hint counter
    echo $((current_hint + 1)) > "$hint_state"

    if [[ "$current_hint" -lt "$total_hints" ]]; then
        info "Run './train.sh hint $1' again for the next hint."
    else
        info "That was the last hint. Run './train.sh solution $1' for the full walkthrough."
    fi
    echo ""
}

cmd_reset() {
    local lesson_dir
    lesson_dir=$(resolve_lesson "$1")
    local name
    name=$(sandbox_name "$lesson_dir")

    info "Resetting lesson: $1"
    clean_sandbox "$name"

    # Clean hint state too
    rm -f "${STATE_DIR}/${name}.hint"
    # Keep .done state -- reset doesn't uncomplete a lesson

    success "Sandbox removed for '${name}'"
    echo ""
}

cmd_solution() {
    local lesson_dir
    lesson_dir=$(resolve_lesson "$1")

    local solution_file="${lesson_dir}/solution.md"
    if [[ ! -f "$solution_file" ]]; then
        error "No solution file found for this lesson."
        exit 1
    fi

    separator
    color_echo bold "Solution: $1"
    separator
    echo ""
    cat "$solution_file"
    echo ""
}

# --- Main ---

if [[ $# -lt 1 ]]; then
    usage
    exit 1
fi

command="$1"
shift

case "$command" in
    list)     cmd_list ;;
    start)    [[ $# -ge 1 ]] || { error "Usage: ./train.sh start <module/lesson>"; exit 1; }; cmd_start "$1" ;;
    verify)   [[ $# -ge 1 ]] || { error "Usage: ./train.sh verify <module/lesson>"; exit 1; }; cmd_verify "$1" ;;
    hint)     [[ $# -ge 1 ]] || { error "Usage: ./train.sh hint <module/lesson>"; exit 1; }; cmd_hint "$1" ;;
    reset)    [[ $# -ge 1 ]] || { error "Usage: ./train.sh reset <module/lesson>"; exit 1; }; cmd_reset "$1" ;;
    solution) [[ $# -ge 1 ]] || { error "Usage: ./train.sh solution <module/lesson>"; exit 1; }; cmd_solution "$1" ;;
    help|-h|--help) usage ;;
    *)        error "Unknown command: ${command}"; usage; exit 1 ;;
esac
