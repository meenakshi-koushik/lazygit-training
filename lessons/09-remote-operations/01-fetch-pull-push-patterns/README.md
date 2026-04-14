# Fetch, Pull, Push Patterns

```bash
lazygit -p sandbox/01-fetch-pull-push-patterns
```

## Scenario

You are working on `feature/notifications` in the platform monorepo. While you have been coding, your teammates have been busy: they merged several PRs into `main` on the remote. Your local `main` is now behind `origin/main`. You also have commits on your feature branch that you have not pushed yet.

Your workflow:

1. Fetch the latest state from origin so lazygit shows what changed.
2. Fast-forward your local `main` to catch up with `origin/main` (without checking it out).
3. Push your feature branch to origin so your teammates can see your work.

This is the daily bread-and-butter of working in a team monorepo -- keeping your local state in sync with the remote and sharing your work.

## Objectives

1. Fetch from `origin` so that lazygit reflects the latest remote state.
2. Fast-forward your local `main` branch to match `origin/main` (you should remain on `feature/notifications`).
3. Push your `feature/notifications` branch to `origin`.

## Key Concepts

Lazygit provides three distinct remote sync operations:

- **Fetch** (`f` in the Files panel, or `f` on a remote in the Remotes tab): Downloads new commits and branches from the remote without modifying your local branches. This updates `origin/main`, `origin/feature/...`, etc. It is always safe -- nothing in your working tree changes.
- **Pull** (`p` globally): Fetches and merges (or rebases) the remote tracking branch into your current branch. This modifies your working tree.
- **Push** (`P` globally): Sends your local commits to the remote tracking branch.

In the Local Branches panel, you can also **fast-forward** a branch that is behind its upstream without checking it out. Select the branch and press `f` -- lazygit runs `git fetch origin main:main` (or equivalent) to advance the local ref.

Under the hood:
- `f` in Files panel runs `git fetch --all`
- `f` on a branch in Local Branches runs `git fetch <remote> <branch>:<branch>` (fast-forward update)
- `P` runs `git push`
- `p` runs `git pull` (with your configured pull strategy -- merge or rebase)

## Prerequisites

- Module 1 (01-orientation) -- navigating panels, basic operations.
- Module 3, Lesson 1 -- branch creation and switching.

## Verify

```bash
./train.sh verify 9/1
```
