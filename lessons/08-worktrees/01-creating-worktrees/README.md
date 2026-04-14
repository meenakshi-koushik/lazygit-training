# Creating Worktrees

```bash
lazygit -p sandbox/01-creating-worktrees
```

## Scenario

You are working on `feature/auth` in the platform monorepo, adding authentication middleware to the API service. You have uncommitted changes -- a work-in-progress token validation module and updated routes. A teammate pings you: "Can you review my dashboard branch? I need a second pair of eyes before I merge." You cannot just switch branches because you have unsaved work. You could stash (as you learned in Module 6), but there is a better tool for this: **worktrees**.

A git worktree lets you check out a second branch in a separate directory on disk, so you can have `feature/auth` and `feature/dashboard` both open at the same time -- no stashing, no committing half-finished work. You will create a worktree for `feature/dashboard` while keeping your WIP intact on `feature/auth`.

## Objectives

1. Create a new worktree for the `feature/dashboard` branch at the path `../01-creating-worktrees-dashboard` (relative to the sandbox repo).
2. Confirm the worktree is listed in lazygit (press `w` to see it).
3. Remain on `feature/auth` in the original worktree with your uncommitted changes still intact.
4. The worktree directory should exist as a sibling of the sandbox repo.

## Key Concepts

A **worktree** is a separate working directory linked to the same repository. Each worktree has its own checked-out branch and its own working tree, but they share the same `.git` object database and refs. This means commits made in one worktree are visible in the other.

In lazygit, worktree operations are accessed by pressing `w` (from the Branches, Commits, or Stash panels). This opens the worktree options/view where you can:

- Press `n` to create a new worktree (lazygit prompts for a path and a branch).
- Press `<space>` to switch to a selected worktree (opens a new lazygit instance there).
- Press `d` to remove a worktree.

Under the hood, `git worktree add <path> <branch>` creates the new directory and checks out the branch there. The key constraint is that no two worktrees can have the same branch checked out simultaneously.

Worktrees are superior to stashing when you need to work on two things in parallel for more than a quick branch switch -- for example, running tests in one branch while developing in another, or keeping a review checkout open alongside your feature work.

## Prerequisites

- Module 1 (01-orientation) -- navigating panels, basic operations.
- Module 3, Lesson 1 -- branch creation and switching.
- Module 6, Lesson 1 -- basic stash operations (for context on the alternative approach).

## Verify

```bash
./train.sh verify 8/1
```
