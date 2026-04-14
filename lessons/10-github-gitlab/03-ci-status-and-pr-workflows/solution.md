# Solution: CI Status and PR Workflows

## Step 1 -- Open lazygit

```bash
lazygit -p sandbox/03-ci-status-and-pr-workflows
```

Lazygit opens on `feature/logging`. Your branch is pushed to origin, but `main` on origin has moved ahead since you branched. You need to update your branch.

## Step 2 -- Fetch from origin

1. Press `2` to go to the **Files** panel.
2. Press `f` to fetch from all remotes.

This updates `origin/main` to include the teammate's 3 new commits.

> **Git context:** `git fetch --all` downloads the new commits without modifying your local branches.

## Step 3 -- Fast-forward local main

1. Press `3` to go to the **Local Branches** panel.
2. Select `main` (navigate with `j`/`k`).
3. Press `f` to fast-forward `main` to match `origin/main`.

Your local `main` now includes the teammate's commits.

> **Git context:** `git fetch origin main:main` advances the local `main` ref.

## Step 4 -- Rebase onto updated main

1. Make sure `feature/logging` is checked out (it should be -- check the branch indicator).
2. In the **Local Branches** panel, select `main`.
3. Press `r` to rebase `feature/logging` onto `main`.

Lazygit replays your 2 logging commits on top of the latest main. Since the changes touch different files, there are no conflicts.

> **Git context:** `git rebase main` takes the 2 commits from `feature/logging` and replays them after the tip of `main`. The commit hashes change because the parent commits are different, but the changes are identical.

## Step 5 -- Force-push the rebased branch

1. Press `P` to push.
2. The push will be rejected (history has changed due to rebase).
3. Lazygit prompts you to force-push -- confirm with `<enter>`.

The remote branch is updated with your rebased history.

> **Git context:** `git push --force-with-lease origin feature/logging` safely replaces the old history on origin. In a real CI/CD workflow, this would trigger a new CI run against the updated branch, which now includes the latest `main` commits.

## Step 6 -- Verify your work

Exit lazygit by pressing `q`, then verify:

```bash
./train.sh verify 10/3
```

All checks should pass:
1. On branch `feature/logging`.
2. Fetch completed (origin/main has latest commits).
3. Local main matches origin/main.
4. `feature/logging` is rebased on top of latest main.
5. 2 commits ahead of main (logging commits preserved).
6. `origin/feature/logging` matches local (force-push succeeded).
7. Working tree is clean.
