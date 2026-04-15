# Lazygit Training: Mastering Git Workflows in Large Monorepos

Interactive, hands-on training for intermediate git users who work in large monorepos as part of teams making concurrent changes across many components. Each lesson drops you into a realistic git scenario that you solve using lazygit.

## Who This Is For

You should already be comfortable with basic git operations (add, commit, push, pull, branch, merge). This training teaches you to do all of that faster and with more precision through lazygit, with a focus on the workflows that matter most in large-scale monorepo development.

## Prerequisites

| Tool | Minimum Version | Install |
|------|----------------|---------|
| git | 2.30+ | [git-scm.com](https://git-scm.com/) |
| lazygit | 0.40+ | [github.com/jesseduffield/lazygit](https://github.com/jesseduffield/lazygit#installation) |
| bash | 4.0+ | Included on Linux/macOS; WSL on Windows |

## Quick Start

```bash
git clone <this-repo-url>
cd lazygit-training

# List all available lessons
./train.sh list

# Start a specific lesson (use module/lesson numbers)
./train.sh start 1/1

# Open lazygit in the exercise sandbox
lazygit -p sandbox/01-navigating-panels

# Check if you completed the objectives
./train.sh verify 1/1

# Get a hint if stuck
./train.sh hint 1/1

# Reset a lesson to try again
./train.sh reset 1/1
```

## How It Works

Each lesson follows the same lifecycle:

1. **Setup** -- `train.sh start` creates an isolated git repository inside `sandbox/` with a specific scenario (modified files, branches, conflicts, history).
2. **Do** -- You open lazygit in the sandbox repo and complete the objectives described in the lesson README.
3. **Verify** -- `train.sh verify` runs automated checks to confirm you achieved the goal.
4. **Reset** -- `train.sh reset` tears down the sandbox and lets you try again.

The training repo itself is never modified. All exercises happen in disposable repos under `sandbox/`, which is gitignored.

## Modules

### Module 1: Lazygit Orientation

Get fluent with the lazygit interface, panel navigation, and configuration basics.

| # | Lesson | What You Learn |
|---|--------|---------------|
| 01 | Navigating Panels | Panels, focus switching, scrolling, preview pane |
| 02 | Status Panel Deep Dive | Repo status, recent branches, quick actions |
| 03 | Configuration Basics | Config file location, useful settings, keybinding overview |

### Module 2: Precision Staging & Committing

The single biggest productivity gain in lazygit: staging exactly what you want.

| # | Lesson | What You Learn |
|---|--------|---------------|
| 01 | Staging Hunks | Stage/unstage individual hunks from large diffs |
| 02 | Staging Lines | Fine-grained line-level staging |
| 03 | Splitting Multi-Component Changes | Turn a 15-file diff across 3 services into 3 clean commits |
| 04 | Partial Unstaging | Unstage specific parts of already-staged changes |

### Module 3: Branch Operations at Scale

Managing branches efficiently when there are dozens or hundreds of them.

| # | Lesson | What You Learn |
|---|--------|---------------|
| 01 | Branch Creation and Switching | Create, switch, delete branches quickly |
| 02 | Comparing Branches | Diff between branches, view divergence |
| 03 | Filtering and Managing Many Branches | Search, filter, bulk operations on branches |

### Module 4: Rewriting History

Clean up your commits before they reach the team.

| # | Lesson | What You Learn |
|---|--------|---------------|
| 01 | Amending Commits | Fix the last commit (message, content, both) |
| 02 | Interactive Rebase: Squash | Combine multiple WIP commits into one |
| 03 | Reordering and Editing Commits | Move commits around, edit mid-history |
| 04 | Fixup Commits | Create and auto-squash fixup commits |

### Module 5: Merge Conflicts & Resolution

The workflows that matter most when main moves fast.

| # | Lesson | What You Learn |
|---|--------|---------------|
| 01 | Basic Merge Conflicts | Resolve a simple conflict using lazygit's conflict panel |
| 02 | Rebase Conflicts | Handle conflicts that arise during rebase, commit by commit |
| 03 | Multi-File Conflicts | Resolve conflicts across multiple files in one operation |
| 04 | Conflict Resolution Strategies | Ours/theirs shortcuts, editing directly, aborting safely |

### Module 6: Stashing & Context Switching

Stop losing work when you need to switch contexts.

| # | Lesson | What You Learn |
|---|--------|---------------|
| 01 | Basic Stash Operations | Stash, pop, apply, drop |
| 02 | Named and Partial Stashes | Stash with messages, stash specific files |
| 03 | Stash Across Branches | Move stashed work between branches |

### Module 7: Cherry-pick, Bisect & Patch

Surgical operations for targeted changes and debugging.

| # | Lesson | What You Learn |
|---|--------|---------------|
| 01 | Cherry-picking Hotfixes | Apply specific commits to release branches |
| 02 | Bisecting Regressions | Find the commit that introduced a bug |
| 03 | Patch Operations | Create, view, and apply patches between branches |

### Module 8: Worktrees & Parallel Development

Work on multiple branches simultaneously without stashing.

| # | Lesson | What You Learn |
|---|--------|---------------|
| 01 | Creating Worktrees | Add and manage worktrees from lazygit |
| 02 | Parallel Development Workflow | Review a PR while your feature branch stays untouched |

### Module 9: Remote Operations & Team Workflows

Collaborate safely when many people push to the same repo.

| # | Lesson | What You Learn |
|---|--------|---------------|
| 01 | Fetch, Pull, Push Patterns | Efficient remote sync workflows |
| 02 | Force-Push Safety | When and how to force-push without destroying teammates' work |
| 03 | Upstream Tracking | Set up and manage tracking branches |

### Module 10: GitHub & GitLab Integration

Use lazygit to prepare and review code for pull requests.

| # | Lesson | What You Learn |
|---|--------|---------------|
| 01 | Creating PRs from Lazygit | Squash commits, reword with conventional format, push a PR-ready branch |
| 02 | Reviewing PRs Locally | Fetch remote branches, review changes with diff mode |
| 03 | CI Status and PR Workflows | Rebase onto updated main, force-push after rebase |

### Module 11: Custom Commands & Power Configuration

Tailor lazygit to your monorepo workflow.

| # | Lesson | What You Learn |
|---|--------|---------------|
| 01 | Custom Keybindings | Add keybindings for repetitive operations |
| 02 | Monorepo-Specific Config | File tree view, diff context, commit prefixes, service-aware custom commands |

## Repository Structure

```
lazygit-training/
├── README.md              # This file
├── AGENTS.md              # Conventions for AI agents working on this repo
├── train.sh               # CLI runner for lessons
├── .gitignore
├── config/
│   └── lazygit.yml        # Recommended lazygit configuration
├── lib/
│   ├── common.sh          # Shared utilities (colors, logging, paths)
│   ├── monorepo.sh        # Functions to create realistic monorepo structures
│   ├── history.sh         # Functions to generate commit histories
│   └── verify.sh          # Shared verification helpers
├── sandbox/               # (gitignored) Exercise repos created here
└── lessons/
    └── <module>/
        └── <lesson>/
            ├── README.md      # Objectives, context, what to do
            ├── setup.sh       # Creates the exercise scenario
            ├── hints.md       # Progressive hints
            ├── verify.sh      # Automated completion checks
            └── solution.md    # Full walkthrough with keystrokes
```

## Recommended Lazygit Config

A training-optimized lazygit config is provided at `config/lazygit.yml`. To use it:

```bash
# Temporary (current session only)
LG_CONFIG_FILE=config/lazygit.yml lazygit

# Or copy to your lazygit config directory
cp config/lazygit.yml ~/.config/lazygit/config.yml
```

## Contributing

See `AGENTS.md` for repository conventions and lesson authoring guidelines. The key rule: **documentation must be kept up-to-date at all times** when lessons are added, modified, or removed.
