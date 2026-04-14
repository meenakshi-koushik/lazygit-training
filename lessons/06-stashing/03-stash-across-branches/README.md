# Stash Across Branches

```bash
lazygit -p sandbox/03-stash-across-branches
```

## Scenario

You are working in a platform monorepo and just realized you have been coding on `main` instead of a feature branch. You have unstaged modifications to three files -- `services/api/src/routes.py`, `services/api/src/config.py`, and `libs/common/src/common.py` -- that add a cache layer to the API service. These changes should not be committed directly to `main`. You need to move them onto a new feature branch without losing any work.

## Objectives

1. Stash all your unstaged changes on `main`.
2. Create a new branch called `feature/cache-layer` from `main`.
3. Pop the stash on the new branch to restore your changes.
4. Stage all the restored files and commit them on `feature/cache-layer`.
5. End on `feature/cache-layer` with a clean working tree, exactly 1 commit ahead of `main`, and an empty stash.

## Key Concepts

Stashing lets you temporarily shelve changes so you can switch context. In lazygit:

- **Stash all changes**: In the Files panel (`2`), press `s` to stash everything. Lazygit prompts for a stash message -- this is equivalent to `git stash push -m "<message>"`.
- **View stash entries**: Press `5` to go to the Stash panel. Each stash entry is listed with its index and message.
- **Pop a stash**: In the Stash panel, select the entry and press `g` to pop it. This applies the changes and removes the stash entry (`git stash pop`).
- **Apply without removing**: Press `<space>` to apply the stash but keep the entry (`git stash apply`).

The stash-then-branch workflow is one of the most common recovery patterns in day-to-day git work. It works because `git stash` saves your changes against the current HEAD, and since you create the new branch from the same commit, popping the stash applies cleanly.

## Prerequisites

- Module 1 (01-orientation) -- panel navigation, staging, and committing.
- Module 3 (03-branch-operations) -- creating and switching branches.
- Module 6, Lessons 1-2 -- basic stash operations.

## Verify

```bash
./train.sh verify 6/3
```
