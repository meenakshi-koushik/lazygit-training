# Navigating Panels

```bash
lazygit -p sandbox/01-navigating-panels
```

## Scenario

You've just joined a team working on a platform monorepo. A colleague suggested you try lazygit to manage your git workflow, so you installed it and are opening it for the first time. The repo has an active history with several branches and some uncommitted work in progress. Your task is to get comfortable moving around the lazygit interface before you start using it for real work.

## Objectives

1. Open lazygit in the sandbox repository and explore all five main panels: **Status**, **Files**, **Branches**, **Commits**, and **Stash**.
2. Create a new branch called `explore-panels` using the Branches panel.
3. Stage at least one file using the Files panel.
4. Make a commit with a message containing the word "explore" (e.g., "explore: test commit from lazygit").

## Key Concepts

Lazygit organizes the git workflow into five side panels on the left, and a large preview pane on the right:

| # | Panel      | What it shows                        | Git equivalent                |
|---|------------|--------------------------------------|-------------------------------|
| 1 | Status     | Current branch, repo name            | `git status` (summary)        |
| 2 | Files      | Modified, staged, and untracked files| `git status`, `git diff`      |
| 3 | Branches   | Local branches (and remotes/tags)    | `git branch -a`               |
| 4 | Commits    | Commit log for the current branch    | `git log --oneline`           |
| 5 | Stash      | Stash entries                        | `git stash list`              |

You switch between panels with:
- **`<tab>`** / **`<shift+tab>`** -- cycle forward / backward through panels
- **`1`**-**`5`** -- jump directly to a panel by number

Inside any panel:
- **`j`** / **`k`** (or arrow keys) -- move the selection up / down
- The **preview pane** on the right updates automatically to show details for the selected item (file diff, commit details, branch info, etc.)

## Prerequisites

None -- this is the first lesson.

## Verify

```bash
./train.sh verify 1/1
```
