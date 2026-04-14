# Rebase Conflicts

```bash
lazygit -p sandbox/02-rebase-conflicts
```

## Scenario

You are on the `feature/worker-retry` branch with three commits that add retry logic to the worker service. While you were working, a teammate pushed batch processing changes to `main` that touch the same files: `services/worker/src/config.py` and `services/worker/src/main.py`.

Your team prefers rebasing feature branches onto main to keep a linear history. You need to rebase your branch onto the current `main`, which means git will replay each of your three commits on top of main's new HEAD -- and at least two of them will conflict.

Unlike a merge (one conflict resolution for the whole operation), a rebase makes you resolve conflicts **commit by commit**. After resolving each commit's conflicts, you continue the rebase until all commits are replayed.

## Objectives

1. Start a rebase of `feature/worker-retry` onto `main`.
2. Resolve the conflict in the first commit (config changes) by keeping both sets of settings.
3. Continue the rebase and resolve the conflict in the second commit (main.py changes) by keeping both functions.
4. Continue the rebase until all commits are replayed.
5. End with a clean working tree on `feature/worker-retry`, with a linear history on top of main.

## Key Concepts

Rebasing replays your commits one at a time on top of a new base. If any commit conflicts with the new base, git pauses and asks you to resolve before continuing. This is different from merge, where all conflicts are bundled into one resolution.

In lazygit, to rebase onto another branch:

1. In the **Branches** panel, select the branch you want to rebase onto (e.g., `main`).
2. Press `r` to rebase the current branch onto the selected one.
3. Lazygit will show you if there are conflicts. Resolve them in the **Files** panel the same way as merge conflicts (select the file, press `<enter>`, pick sides with `<space>` or `b`).
4. After resolving all conflicts for that commit, stage the files and press `<space>` on the "continue rebase" option (or look for the rebase status indicator).
5. Repeat until all commits are replayed.

Under the hood, this runs `git rebase main`. When a conflict occurs, git pauses and you resolve it, then run `git rebase --continue`. Lazygit wraps this workflow into its conflict resolution UI.

## Prerequisites

- Module 5, Lesson 1 (Basic Merge Conflicts) -- you should know how to resolve conflicts in lazygit.
- Module 4 (Rewriting History) -- familiar with rebase concepts.

## Verify

```bash
./train.sh verify 5/2
```
