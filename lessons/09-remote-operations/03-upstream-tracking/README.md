# Upstream Tracking

```bash
lazygit -p sandbox/03-upstream-tracking
```

## Scenario

You are working in a monorepo that has several branches in different tracking states. Your teammate created a remote branch `feature/search` for a new search service, but you have not checked it out locally yet. You also have a local branch `feature/caching` that you created locally but never pushed or set an upstream for -- right now it has no tracking relationship.

You need to sort out the tracking for both branches:

1. Check out the remote `feature/search` branch locally (which automatically sets up tracking).
2. Set an upstream for your existing `feature/caching` branch so that future `push`/`pull` commands know where to go.

## Objectives

1. Check out `feature/search` from the remote so you have a local tracking branch.
2. Push `feature/caching` to `origin` and set up upstream tracking in the process.

## Key Concepts

**Upstream tracking** is the link between a local branch and its corresponding remote branch. When a branch has an upstream configured:

- `git push` knows where to push without specifying the remote and branch.
- `git pull` knows what to merge/rebase from.
- Lazygit shows the ahead/behind count relative to the upstream.

In lazygit, upstream operations are accessed from the **Local Branches** panel (`3`):

- Press `u` on a branch to view **upstream options**: set upstream, unset upstream, or reset to upstream.
- When you check out a remote branch (via the Remotes tab, `]` to navigate tabs), lazygit automatically creates a local tracking branch.
- When you push a branch for the first time with `P`, lazygit prompts to set the upstream.

Under the hood:
- `git branch --set-upstream-to=origin/<branch> <branch>` links a local branch to a remote tracking branch.
- `git push -u origin <branch>` pushes and sets upstream in one step.
- `git checkout <remote-branch>` (or `git switch <remote-branch>`) creates a local tracking branch from the remote.

## Prerequisites

- Module 1 (01-orientation) -- navigating panels.
- Module 3, Lesson 1 -- branch creation and switching.
- Module 9, Lesson 1 -- basic fetch, pull, push patterns.

## Verify

```bash
./train.sh verify 9/3
```
