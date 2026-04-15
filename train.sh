#!/usr/bin/env bash
set -euo pipefail

# train.sh -- CLI runner for lazygit training lessons
#
# Usage:
#   ./train.sh list                     List all modules and lessons
#   ./train.sh start <module/lesson>    Set up and start a lesson
#   ./train.sh solve [module/lesson]    Start (if needed) and open lazygit
#   ./train.sh verify [module/lesson]   Check if objectives are met
#   ./train.sh hint [module/lesson]     Show the next progressive hint
#   ./train.sh reset <module/lesson>    Tear down a lesson's sandbox
#   ./train.sh reset-all                Remove all sandboxes and state
#   ./train.sh solution [module/lesson] Show the full solution walkthrough
#   ./train.sh completions [bash|zsh]   Output shell completions for eval
#
# Lesson references accept numeric shorthand (e.g., 1/1) or full names
# (e.g., 01-orientation/01-navigating-panels).
#
# solve, verify, hint, and solution default to the last started lesson when
# no argument is given.

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

STATE_DIR="${REPO_ROOT}/.lazygit-training-state"

# Render markdown through glow when available, fall back to cat.
render_markdown() {
    if command -v glow &>/dev/null; then
        glow --width 0 "$@"
    else
        cat "$@"
    fi
}

usage() {
    cat << 'EOF'
Usage: ./train.sh <command> [arguments]

Commands:
  list                     List all modules and lessons
  start <module/lesson>    Set up and start a lesson
  solve [module/lesson]    Start (if needed) and open lazygit in the sandbox
  verify [module/lesson]   Check if lesson objectives are met
  hint [module/lesson]     Show the next progressive hint
  reset <module/lesson>    Tear down a lesson's sandbox
  reset-all                Remove all sandboxes and training state
  solution [module/lesson] Show the full solution walkthrough
  completions [bash|zsh]   Output shell completions for eval

solve, verify, hint, and solution default to the last started lesson when
no argument is given.

Shell completions: eval "$(./train.sh completions)"

Lessons can be referenced by number (e.g., 1/1) or full name
(e.g., 01-orientation/01-navigating-panels).

Examples:
  ./train.sh list
  ./train.sh start 1/1
  ./train.sh solve 1/1
  ./train.sh verify
  ./train.sh hint
  ./train.sh reset 2/3
  ./train.sh solution
EOF
}

# Resolve a lesson path argument to the lesson directory.
# Accepts either:
#   - Numeric shorthand: "1/1", "2/3"
#   - Full path: "01-orientation/01-navigating-panels"
resolve_lesson() {
    local arg="$1"
    local lesson_dir

    if [[ "$arg" =~ ^([0-9]+)/([0-9]+)$ ]]; then
        # Numeric shorthand -- find the Nth module and Mth lesson
        local mod_num="${BASH_REMATCH[1]}"
        local les_num="${BASH_REMATCH[2]}"
        local mod_prefix
        mod_prefix=$(printf "%02d-" "$mod_num")
        local les_prefix
        les_prefix=$(printf "%02d-" "$les_num")

        # Find matching module directory
        local mod_dir=""
        for d in "$LESSONS_DIR"/${mod_prefix}*/; do
            if [[ -d "$d" ]]; then
                mod_dir="$d"
                break
            fi
        done
        if [[ -z "$mod_dir" ]]; then
            error "Module ${mod_num} not found (no directory matching ${mod_prefix}* in lessons/)" >&2
            echo "Run './train.sh list' to see available lessons." >&2
            exit 1
        fi

        # Find matching lesson directory within the module
        local les_dir=""
        for d in "${mod_dir}"${les_prefix}*/; do
            if [[ -d "$d" ]]; then
                les_dir="$d"
                break
            fi
        done
        if [[ -z "$les_dir" ]]; then
            error "Lesson ${les_num} not found in module ${mod_num} (no directory matching ${les_prefix}* in $(basename "$mod_dir"))" >&2
            echo "Run './train.sh list' to see available lessons." >&2
            exit 1
        fi

        # Remove trailing slash
        lesson_dir="${les_dir%/}"
    else
        # Full path
        lesson_dir="${LESSONS_DIR}/${arg}"
    fi

    if [[ ! -d "$lesson_dir" ]]; then
        error "Lesson not found: ${arg}" >&2
        echo "  Expected directory: ${lesson_dir}" >&2
        echo "" >&2
        echo "Run './train.sh list' to see available lessons." >&2
        exit 1
    fi

    echo "$lesson_dir"
}

# Extract the sandbox name from a lesson path (last component)
sandbox_name() {
    local lesson_path="$1"
    basename "$lesson_path"
}

# Compute the numeric shorthand (e.g., "1/3") for a resolved lesson directory
lesson_shorthand() {
    local lesson_path="$1"
    local lesson_basename module_basename
    lesson_basename=$(basename "$lesson_path")
    module_basename=$(basename "$(dirname "$lesson_path")")

    local mod_idx=0
    for mod_dir in "$LESSONS_DIR"/*/; do
        [[ -d "$mod_dir" ]] || continue
        mod_idx=$((mod_idx + 1))
        if [[ "$(basename "$mod_dir")" == "$module_basename" ]]; then
            local les_idx=0
            for les_dir in "$mod_dir"*/; do
                [[ -d "$les_dir" ]] || continue
                les_idx=$((les_idx + 1))
                if [[ "$(basename "$les_dir")" == "$lesson_basename" ]]; then
                    echo "${mod_idx}/${les_idx}"
                    return
                fi
            done
        fi
    done
    echo "?/?"
}

# Return the last-started lesson shorthand, or exit with an error.
get_last_lesson() {
    local state_file="${STATE_DIR}/last-lesson"
    if [[ -f "$state_file" ]]; then
        cat "$state_file"
    else
        error "No lesson has been started yet. Run './train.sh start <module/lesson>' first."
        exit 1
    fi
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
        color_echo bold "  Module ${module_count}: ${module_name}"

        local lesson_in_module=0
        for lesson_dir in "$module_dir"*/; do
            [[ -d "$lesson_dir" ]] || continue
            lesson_count=$((lesson_count + 1))
            lesson_in_module=$((lesson_in_module + 1))

            local lesson_name
            lesson_name=$(basename "$lesson_dir")

            local sandbox_path="${SANDBOX_DIR}/${lesson_name}"
            local status_marker="  "

            if [[ -f "${STATE_DIR}/${lesson_name}.done" ]]; then
                status_marker=$(printf "${_GREEN}✓ ${_RESET}")
            elif [[ -d "$sandbox_path" ]]; then
                status_marker=$(printf "${_YELLOW}▶ ${_RESET}")
            fi

            local shorthand="${module_count}/${lesson_in_module}"
            printf "    %b %-6s %s" "$status_marker" "$shorthand" "$lesson_name"

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
    echo "Usage:  ./train.sh start 1/1    (use the shorthand numbers above)"
    echo ""
}

cmd_start() {
    local lesson_dir
    lesson_dir=$(resolve_lesson "$1")
    local name
    name=$(sandbox_name "$lesson_dir")
    local shorthand
    shorthand=$(lesson_shorthand "$lesson_dir")

    separator
    color_echo bold "Starting lesson ${shorthand}: $(basename "$lesson_dir")"
    separator
    echo ""

    # Run setup
    local setup_script="${lesson_dir}/setup.sh"
    if [[ ! -x "$setup_script" ]]; then
        error "setup.sh not found or not executable: ${setup_script}"
        exit 1
    fi

    # Record this as the last-started lesson
    mkdir -p "$STATE_DIR"
    echo "$shorthand" > "${STATE_DIR}/last-lesson"

    info "Setting up exercise environment..."
    bash "$setup_script"
    echo ""

    # Print the lesson README
    separator
    if [[ -f "${lesson_dir}/README.md" ]]; then
        render_markdown "${lesson_dir}/README.md"
    fi
    echo ""
    separator

    local sandbox_path="${SANDBOX_DIR}/${name}"
    echo ""
    info "Sandbox ready at: ${sandbox_path}"
    echo ""
    echo "  Next steps:"
    echo "    1. ./train.sh solve ${shorthand}   (or: lazygit -p ${sandbox_path})"
    echo "    2. Complete the objectives above"
    echo "    3. Run: ./train.sh verify ${shorthand}"
    echo ""
    echo "  Stuck? Run: ./train.sh hint ${shorthand}"
    echo ""
}

cmd_solve() {
    local lesson_dir
    lesson_dir=$(resolve_lesson "$1")
    local name
    name=$(sandbox_name "$lesson_dir")
    local sandbox_path="${SANDBOX_DIR}/${name}"

    # Auto-start if the sandbox doesn't exist yet
    if [[ ! -d "$sandbox_path" ]]; then
        cmd_start "$1"
    fi

    # Verify lazygit is installed
    if ! command -v lazygit &>/dev/null; then
        error "lazygit is not installed or not in PATH."
        echo "  Install it from: https://github.com/jesseduffield/lazygit#installation"
        exit 1
    fi

    # Build the lazygit command, auto-detecting per-lesson options.
    local -a lg_args=()

    # If the sandbox ships a lazygit config, use it.
    if [[ -f "${sandbox_path}/lazygit.yml" ]]; then
        lg_args+=(-ucf "${sandbox_path}/lazygit.yml")
    fi

    # If the actual git repo lives in a repo/ subdirectory, target that.
    local repo_path="$sandbox_path"
    if [[ -d "${sandbox_path}/repo/.git" ]]; then
        repo_path="${sandbox_path}/repo"
    fi
    lg_args+=(-p "$repo_path")

    info "Opening lazygit in ${repo_path}..."
    echo ""
    exec lazygit "${lg_args[@]}"
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
    local hint_text=""
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
            hint_text+="${line}"$'\n'
        fi
    done < "$hints_file"

    echo "$hint_text" | render_markdown

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

    # Clean up any companion directories (e.g., worktree dirs named <name>-*)
    for companion in "${SANDBOX_DIR}/${name}-"*; do
        if [[ -d "$companion" ]]; then
            rm -rf "$companion"
        fi
    done

    # Clean hint state too
    rm -f "${STATE_DIR}/${name}.hint"
    # Keep .done state -- reset doesn't uncomplete a lesson

    success "Sandbox removed for '${name}'"
    echo ""
}

cmd_reset_all() {
    info "Removing all sandboxes and training state..."

    if [[ -d "$SANDBOX_DIR" ]]; then
        rm -rf "$SANDBOX_DIR"
    fi
    if [[ -d "$STATE_DIR" ]]; then
        rm -rf "$STATE_DIR"
    fi

    success "All sandboxes and state have been removed."
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
    render_markdown "$solution_file"
    echo ""
}

# Hidden helper: list all lessons with shorthand, full path, and title.
# Output format: shorthand<TAB>module-dir/lesson-dir<TAB>title
# Used by shell completion functions.
cmd_list_lessons() {
    local mod_idx=0
    for mod_dir in "$LESSONS_DIR"/*/; do
        [[ -d "$mod_dir" ]] || continue
        mod_idx=$((mod_idx + 1))
        local mod_name les_idx
        mod_name=$(basename "$mod_dir")
        les_idx=0
        for les_dir in "$mod_dir"*/; do
            [[ -d "$les_dir" ]] || continue
            les_idx=$((les_idx + 1))
            local les_name title
            les_name=$(basename "$les_dir")
            title=""
            if [[ -f "${les_dir}/README.md" ]]; then
                title=$(head -1 "${les_dir}/README.md" | sed 's/^#\+ //')
            fi
            printf '%s\t%s/%s\t%s\n' "${mod_idx}/${les_idx}" "$mod_name" "$les_name" "$title"
        done
    done
}

cmd_completions() {
    local shell="${1:-}"
    if [[ -z "$shell" ]]; then
        shell="$(basename "${SHELL:-bash}")"
    fi

    local script_path
    script_path="$(cd "$(dirname "$0")" && pwd)/$(basename "$0")"

    case "$shell" in
        bash)
            cat <<BASH
_train_sh() {
    local cur prev commands lesson_commands
    cur="\${COMP_WORDS[COMP_CWORD]}"
    prev="\${COMP_WORDS[COMP_CWORD-1]}"
    commands="list start solve verify hint reset reset-all solution completions help"
    lesson_commands="start solve verify hint reset solution"

    if [[ \$COMP_CWORD -eq 1 ]]; then
        COMPREPLY=(\$(compgen -W "\$commands" -- "\$cur"))
        return
    fi

    if [[ \$COMP_CWORD -eq 2 ]] && [[ " \$lesson_commands " == *" \$prev "* ]]; then
        local words=""
        while IFS=\$'\\t' read -r shorthand fullpath title; do
            words+=" \$shorthand \$fullpath"
        done < <("$script_path" _lessons 2>/dev/null)
        COMPREPLY=(\$(compgen -W "\$words" -- "\$cur"))
        return
    fi
}
complete -F _train_sh train.sh
complete -F _train_sh ./train.sh
BASH
            ;;
        zsh)
            cat <<ZSH
_train_sh() {
    local commands lesson_commands
    commands=(list start solve verify hint reset reset-all solution completions help)
    lesson_commands=(start solve verify hint reset solution)

    if (( CURRENT == 2 )); then
        _describe 'command' commands
        return
    fi

    if (( CURRENT == 3 )) && (( \${lesson_commands[(Ie)\${words[2]}]} )); then
        local -a specs
        while IFS=\$'\\t' read -r shorthand fullpath title; do
            specs+=("\${shorthand}:\${title}" "\${fullpath}:\${title}")
        done < <("$script_path" _lessons 2>/dev/null)
        _describe 'lesson' specs
        return
    fi
}
compdef _train_sh train.sh
compdef _train_sh ./train.sh
ZSH
            ;;
        *)
            echo "Unsupported shell: ${shell}" >&2
            echo "Supported shells: bash, zsh" >&2
            exit 1
            ;;
    esac
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
    solve)    cmd_solve "${1:-$(get_last_lesson)}" ;;
    verify)   cmd_verify "${1:-$(get_last_lesson)}" ;;
    hint)     cmd_hint "${1:-$(get_last_lesson)}" ;;
    reset)    [[ $# -ge 1 ]] || { error "Usage: ./train.sh reset <module/lesson>"; exit 1; }; cmd_reset "$1" ;;
    reset-all) cmd_reset_all ;;
    solution) cmd_solution "${1:-$(get_last_lesson)}" ;;
    completions) cmd_completions "${1:-}" ;;
    _lessons) cmd_list_lessons ;;
    help|-h|--help) usage ;;
    *)        error "Unknown command: ${command}"; usage; exit 1 ;;
esac
