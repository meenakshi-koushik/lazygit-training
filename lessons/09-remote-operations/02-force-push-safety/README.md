# Force-Push Safety

```bash
lazygit -p sandbox/02-force-push-safety
```

## Scenario

You are working on `feature/billing` in the platform monorepo. You pushed your branch to origin earlier so your teammate could take a look. After reviewing their feedback, you decided to clean up your commit history -- you squashed three WIP commits into one clean commit using interactive rebase.

Now your local `feature/billing` has diverged from `origin/feature/billing`. A regular push will be rejected because the histories no longer match. You need to force-push, but you want to do it safely: using `--force-with-lease`, which prevents overwriting any commits your teammate may have pushed to the branch while you were rebasing.

## Objectives

1. Attempt a regular push and observe that it fails (the branch has diverged).
2. Force-push your `feature/billing` branch to origin using the force-push option in lazygit.
3. Confirm the push succeeded and `origin/feature/billing` matches your local branch.

## Key Concepts

**Force-push** replaces the remote branch with your local version, discarding any commits on the remote that are not in your local history. This is dangerous in shared branches (like `main`) but routine on personal feature branches after a rebase or amend.

Lazygit handles force-push intelligently:

- When you press `P` (push) and a regular push fails because the remote has diverged, lazygit will prompt you with the option to force-push.
- By default, lazygit uses `--force-with-lease`, which is safer than `--force`. It only succeeds if the remote branch is where you last saw it (i.e., nobody else has pushed to it since your last fetch).

The `--force-with-lease` flag protects against this scenario:
1. You rebase `feature/billing`.
2. A teammate pushes a hotfix commit to `feature/billing` while you are rebasing.
3. You force-push -- but `--force-with-lease` detects the teammate's commit and rejects the push, preventing data loss.

With plain `--force`, the teammate's commit would be silently overwritten.

Under the hood:
- Regular push: `git push origin feature/billing`
- Force-push with lease: `git push --force-with-lease origin feature/billing`

## Prerequisites

- Module 1 (01-orientation) -- navigating panels, basic operations.
- Module 4, Lesson 2 -- interactive rebase (squashing), which is why the branch diverged.
- Module 9, Lesson 1 -- basic fetch, pull, push patterns.

## Verify

```bash
./train.sh verify 9/2
```
