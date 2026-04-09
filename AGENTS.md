# AGENTS.md

Instructions for AI agents and human contributors working on this repository.

## Project Overview

This is an interactive lazygit training repository targeting intermediate git users who work in large monorepos as part of large teams. The training consists of hands-on lessons where learners solve realistic git scenarios using lazygit.

Each lesson creates an isolated, disposable git repository inside `sandbox/` with a specific pre-built scenario. Learners open lazygit in that sandbox repo, complete the objectives, and verify their work. The training repo itself is never modified during exercises.

## Critical Rule: Keep Documentation Up-to-Date

**All documentation must be kept accurate and current at all times.** Whenever you add, modify, rename, reorder, or remove a lesson or module:

1. Update `README.md` -- the module tables, lesson counts, and repository structure diagram must reflect reality.
2. Update the parent module's lesson list if one exists.
3. Update `train.sh` if it contains any hardcoded lesson references.
4. Ensure lesson-level `README.md` files reference correct paths and prerequisites.
5. Verify cross-references between lessons (e.g., "you learned this in Module 2, Lesson 3") still point to the right place.

Do not defer documentation updates. Do not batch them. Update docs in the same change that modifies the structure.

## Repository Structure

```
lazygit-training/
├── README.md              # Public-facing overview, module index, quick start
├── AGENTS.md              # This file
├── train.sh               # CLI runner (list/start/reset/verify/hint)
├── .gitignore             # Ignores sandbox/, *.state files
├── config/
│   └── lazygit.yml        # Recommended lazygit configuration for training
├── lib/
│   ├── common.sh          # Shared shell utilities
│   ├── monorepo.sh        # Monorepo scaffolding functions
│   ├── history.sh         # Commit history generation functions
│   └── verify.sh          # Shared verification helpers
├── sandbox/               # (gitignored) Disposable exercise repos
└── lessons/
    └── NN-module-name/
        └── NN-lesson-name/
            ├── README.md
            ├── setup.sh
            ├── hints.md
            ├── verify.sh
            └── solution.md
```

## Lesson File Conventions

Every lesson is a directory under `lessons/<module>/<lesson>/` containing exactly five files:

### README.md

The lesson description shown to the learner. Must contain:

- **Title** -- brief, action-oriented (e.g., "Staging Individual Hunks")
- **Scenario** -- what situation the learner is dropped into, written in second person ("You are working on...")
- **Objectives** -- numbered list of specific things to accomplish
- **Key Concepts** -- brief git context explaining what's happening under the hood (lazygit-first, but with enough git explanation to build understanding)
- **Prerequisites** -- which prior lessons are assumed, if any

### setup.sh

Creates the exercise scenario. Requirements:

- Must be executable (`chmod +x`).
- Must source `lib/common.sh` for shared utilities.
- Must use functions from `lib/monorepo.sh` and `lib/history.sh` rather than hand-rolling repo construction.
- Must be **idempotent** -- running it twice should produce the same result (tear down first if the sandbox already exists).
- Must create the exercise repo inside `sandbox/<lesson-name>/`.
- Must print a success message with the sandbox path when done.
- Must `set -euo pipefail` at the top.
- Must not require network access.

### hints.md

Progressive hints for learners who are stuck. Structure:

```markdown
## Hint 1
<gentle nudge in the right direction>

## Hint 2
<more specific guidance>

## Hint 3
<nearly the answer, specific keybindings mentioned>
```

Provide 2-4 hints per lesson, from vague to specific. Never give the full solution in hints -- that goes in `solution.md`.

### verify.sh

Automated checks that confirm the learner completed the objectives. Requirements:

- Must be executable.
- Must source `lib/common.sh` and `lib/verify.sh`.
- Must operate on the sandbox repo at `sandbox/<lesson-name>/`.
- Must exit `0` on success (all objectives met) with a congratulatory message.
- Must exit `1` on failure with a message explaining which objective was not met.
- Must `set -euo pipefail` at the top.
- Each objective should be a separate check with a clear pass/fail message.

### solution.md

Full walkthrough for the lesson. Must contain:

- Step-by-step instructions with exact lazygit keystrokes (e.g., "press `<space>` to stage the file").
- Use a consistent format for keystrokes: backtick-wrapped, with special keys in angle brackets (`<enter>`, `<space>`, `<tab>`, `<esc>`).
- Screenshots are not required -- describe what the learner should see at each step.
- Include the git context: what each lazygit action translates to in git commands.

## Naming Conventions

- **Module directories**: `NN-kebab-case-name` (e.g., `01-orientation`, `02-precision-staging`)
- **Lesson directories**: `NN-kebab-case-name` (e.g., `01-navigating-panels`, `02-staging-lines`)
- **Numbering**: Two-digit, zero-padded. Modules and lessons are numbered independently.
- **Sandbox directories**: Named after the lesson directory (e.g., `sandbox/01-navigating-panels/`), not the full module/lesson path.

If lesson names collide across modules (unlikely given descriptive names), prefix with the module number.

## lib/ Functions

### common.sh

Provides:

- `color_echo <color> <message>` -- colored terminal output (red, green, yellow, blue)
- `info`, `success`, `warn`, `error` -- semantic logging helpers
- `REPO_ROOT` -- absolute path to the training repo root
- `SANDBOX_DIR` -- absolute path to `sandbox/`
- `LESSONS_DIR` -- absolute path to `lessons/`
- `ensure_sandbox` -- creates `sandbox/` if it doesn't exist
- `clean_sandbox <name>` -- removes a specific sandbox repo

### monorepo.sh

Provides functions to create realistic monorepo directory structures:

- `create_monorepo <path>` -- creates a standard monorepo layout with `services/`, `libs/`, `infra/`, `docs/` directories
- `add_service <path> <name>` -- adds a service with realistic source files (e.g., `services/api/src/main.py`, `services/api/Dockerfile`, etc.)
- `add_library <path> <name>` -- adds a shared library under `libs/`
- `add_infra <path>` -- adds infrastructure files (Terraform, Helm charts, CI config)

The generated file content should be plausible but minimal -- enough to look real in diffs without being distracting.

### history.sh

Provides functions to create commit histories:

- `make_commits <path> <count>` -- creates N commits with realistic messages touching various files
- `make_branch_with_commits <path> <branch> <count>` -- creates a branch with N commits
- `make_diverged_branches <path> <branch1> <branch2> <count1> <count2>` -- creates two branches that diverge from a common point
- `make_conflict <path> <branch1> <branch2> <file>` -- creates conflicting changes in the same file on two branches

Commit messages should follow conventional-commit style and reference realistic component names (e.g., "feat(api): add rate limiting middleware").

### verify.sh

Provides assertion functions for verify scripts:

- `assert_branch_exists <branch>` -- check a branch exists
- `assert_on_branch <branch>` -- check HEAD is on a branch
- `assert_clean_working_tree` -- check no uncommitted changes
- `assert_commit_count <count>` -- check number of commits
- `assert_commit_message_contains <ref> <substring>` -- check a commit message
- `assert_file_contains <file> <content>` -- check file contents
- `assert_no_conflicts` -- check no merge conflicts are active

## train.sh CLI

The CLI runner supports these subcommands:

| Command | Description |
|---------|-------------|
| `./train.sh list` | List all modules and lessons with completion status |
| `./train.sh start <module/lesson>` | Run setup.sh, print the lesson README |
| `./train.sh verify <module/lesson>` | Run verify.sh against the sandbox |
| `./train.sh hint <module/lesson>` | Show the next unseen hint |
| `./train.sh reset <module/lesson>` | Tear down the sandbox for a lesson |
| `./train.sh solution <module/lesson>` | Show the full solution walkthrough |

Lesson paths are specified as `<module-dir>/<lesson-dir>` (e.g., `01-orientation/01-navigating-panels`).

## Writing Style Guidelines

- **Lazygit-first**: Always teach through lazygit. Show the lazygit workflow as the primary method.
- **Git context**: After showing the lazygit way, briefly explain what git operations happened underneath. Keep this to 1-2 sentences, not a git tutorial.
- **Second person**: Write lesson READMEs in second person ("You are working on...", "Your objective is to...").
- **Action-oriented**: Objectives should be concrete and verifiable ("Stage only the changes in `services/api/`" not "Learn about staging").
- **Monorepo-grounded**: Scenarios should reflect real monorepo situations (cross-component changes, concurrent team modifications, release branch management).
- **Concise**: Learners are intermediate developers. Don't over-explain. Respect their time.

## Testing a Lesson

Before committing a new lesson, verify the full lifecycle works:

```bash
# 1. Setup creates the scenario without errors
./train.sh start <module/lesson>

# 2. Verify fails before the learner does anything
./train.sh verify <module/lesson>  # should exit 1

# 3. Follow the solution.md steps in lazygit

# 4. Verify passes after completing the solution
./train.sh verify <module/lesson>  # should exit 0

# 5. Reset cleans up properly
./train.sh reset <module/lesson>

# 6. Second setup works (idempotency)
./train.sh start <module/lesson>
```

## Commit Conventions

Use conventional commits when committing to this repo:

- `feat(lessons): add module 3 lesson on branch comparison`
- `fix(lib): handle spaces in sandbox directory names`
- `docs: update README module table with new lessons`
- `chore(train.sh): add completion tracking`

## Module and Lesson Index

The authoritative list of modules and lessons is in `README.md`. If this file and `README.md` disagree on what lessons exist, `README.md` is wrong and must be fixed -- the filesystem under `lessons/` is the source of truth.
