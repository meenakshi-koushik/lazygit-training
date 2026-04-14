# Basic Stash Operations

```bash
lazygit -p sandbox/01-basic-stash-operations
```

## Scenario

You are working on `feature/user-profiles` in the platform monorepo, building out user profile endpoints for the API service. You have uncommitted changes across three files -- updated config, new route handlers, and additional tests. Before you can finish, a teammate reports a critical production bug. You need to stash your in-progress work, switch to `main` to check the state of things, then come back and restore your work to continue where you left off.

## Objectives

1. Stash all current changes (3 modified files should disappear from the Files panel).
2. Switch to the `main` branch.
3. Switch back to `feature/user-profiles`.
4. Pop the stash to restore your work.
5. End with the same modifications restored on `feature/user-profiles` and an empty stash list.

## Key Concepts

Stashing saves your uncommitted changes and reverts the working tree to a clean state. This lets you switch branches without committing half-finished work.

In lazygit, stash operations are split across two panels:

- **Files panel** (`2`): Press `s` to stash all changes. This is equivalent to `git stash push`. For more options (stash with a message, stash staged only, etc.), press `S` to open the stash options menu.
- **Stash panel** (`5`): Lists all stash entries. Select an entry and press `<space>` to apply it (keeps the entry), `g` to pop it (applies and removes the entry), or `d` to drop it (removes without applying).

The difference between apply and pop: **apply** restores the changes but keeps the stash entry so you can apply it again later. **Pop** restores the changes and deletes the stash entry. In most workflows you want pop -- it is the equivalent of "I'm done saving this for later, give it back."

## Prerequisites

- Module 1 (01-orientation) -- navigating panels, basic staging and committing.
- Module 3, Lesson 1 -- branch creation and switching.

## Verify

```bash
./train.sh verify 6/1
```
