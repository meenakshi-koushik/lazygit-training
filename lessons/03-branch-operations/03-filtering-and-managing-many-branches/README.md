# Filtering and Managing Many Branches

```bash
lazygit -p sandbox/03-filtering-and-managing-many-branches
```

## Scenario

You have just joined a platform team that works in a large monorepo. Over time the repository has accumulated over 15 branches from multiple team members -- feature branches, bugfixes, hotfixes, release branches, and assorted chore branches. Many of these branches are stale and no longer needed, but a few are still active.

Your tech lead has asked you to clean up the branch clutter. Specifically, you need to delete all three `chore/` branches (`chore/update-deps`, `chore/cleanup-logs`, and `chore/ci-pipeline`) because that work has already been merged or abandoned. You must leave everything else untouched -- the feature, bugfix, hotfix, and release branches are still in use.

With 15+ branches in the list, scrolling through them one by one is tedious. Lazygit's branch filtering makes it fast: search for the branches you need, delete them, and move on.

## Objectives

1. Use lazygit's branch filter/search to locate the `chore/` branches.
2. Delete `chore/update-deps`.
3. Delete `chore/cleanup-logs`.
4. Delete `chore/ci-pipeline`.
5. Do **not** delete any other branches (`feature/*`, `bugfix/*`, `hotfix/*`, `release/*`).
6. End on the `main` branch.

## Key Concepts

- In the **Branches** panel, press `/` to open the filter/search bar. Type a substring (e.g., `chore`) and the branch list narrows to only matching branches. This is essential when a repo has dozens or hundreds of branches.
- Press `d` on a highlighted branch to delete it. Lazygit asks for confirmation -- press `<enter>` to confirm. Under the hood this runs `git branch -D <branch>`.
- Press `<esc>` to clear the filter and return to the full branch list.
- Branch cleanup is a routine hygiene task in monorepos. Stale branches create noise, slow down tab-completion, and make it harder to find the branch you actually need.

## Prerequisites

- [03-branch-operations/01-branch-creation-and-switching](../01-branch-creation-and-switching/) -- you should be comfortable navigating the Branches panel and switching between branches.

## Verify

```bash
./train.sh verify 3/3
```
