# Branch Creation and Switching

```bash
lazygit -p sandbox/01-branch-creation-and-switching
```

## Scenario

You are working in a platform monorepo with several active branches. The team has been busy -- there is already a `feature/notifications` branch and a `bugfix/login-timeout` branch in flight. You need to create a new feature branch called `feature/search-api` to prototype a search endpoint, make a quick commit on it, then switch back to `main` to create a `hotfix/config-typo` branch for an urgent config fix. After thinking it over, you realize the search feature is not needed yet, so you leave it for now and stay on the hotfix branch.

## Objectives

1. Create a new branch called `feature/search-api` (from `main`).
2. Make at least one commit on `feature/search-api` (any change will do).
3. Switch back to `main`.
4. Create a new branch called `hotfix/config-typo` (from `main`).
5. End with HEAD on `hotfix/config-typo`.

## Key Concepts

Branches in lazygit are managed from the **Branches** panel (press `3` or navigate to it with `]`/`[`). The key operations are:

- **Create a branch**: Press `n` to create a new branch from the currently checked-out commit. Type the branch name and press `<enter>`. Lazygit checks out the new branch automatically -- this is equivalent to `git checkout -b <name>`.
- **Switch branches**: Select a branch and press `<space>` to check it out. This is equivalent to `git checkout <name>`.
- **Delete a branch**: Select a branch and press `d`, then confirm. This runs `git branch -d <name>` (or `-D` for a force delete).

When working in a monorepo with many branches, quick branch creation and switching is essential. You will often need to jump between feature work, hotfixes, and the main branch multiple times per day.

## Prerequisites

- Module 1 (01-orientation) -- navigating panels, basic staging and committing.

## Verify

```bash
./train.sh verify 3/1
```
