# Bisecting Regressions

```bash
lazygit -p sandbox/02-bisecting-regressions
```

## Scenario

You are working on the platform monorepo and the team has discovered that the API service's health endpoint is reporting `"unhealthy"` instead of `"healthy"`. This is a regression -- it was definitely working a few days ago, and the commit tagged `last-known-good` was the last verified-working state. Since then, about a dozen commits have landed on `main` from multiple team members touching various parts of the codebase. You need to identify which commit introduced the regression.

Manually reviewing each commit's diff would work, but it is tedious and error-prone in a busy monorepo. Instead, you will use lazygit's built-in bisect feature to perform a binary search through the commit history and pinpoint the exact commit that broke the health endpoint.

## Objectives

1. Open the Commits panel and start a bisect session by marking the `last-known-good` commit as good.
2. Mark the current HEAD as bad (it has the regression).
3. For each commit that bisect checks out, examine `services/api/src/routes.py` to determine whether it contains `"healthy"` (good) or `"unhealthy"` (bad).
4. Mark each bisect step as good or bad accordingly until bisect identifies the first bad commit.
5. After bisect identifies the culprit, tag that commit as `bisect-found` (press `T` on the commit).
6. Reset the bisect session to return to normal operation.

## Key Concepts

Git bisect performs a binary search through your commit history. You provide two boundaries -- a known-good commit and a known-bad commit -- and git repeatedly checks out the midpoint between them. After you test each midpoint and mark it as good or bad, the search space is halved. This finds the offending commit in O(log n) steps instead of O(n).

In lazygit, bisect is driven from the **Commits** panel (`4`):

- Navigate to a commit and press `b` to open the bisect options menu.
- **Mark as good / Mark as bad** -- tells bisect about the current commit's status.
- **Bisect start** -- begins a new bisect session.
- **Bisect reset** -- ends the bisect session and returns to the original HEAD.

During bisect, lazygit displays visual indicators on commits to show the current search boundaries. Each time you mark a commit, lazygit automatically checks out the next midpoint for you to test.

The underlying git operation is `git bisect`. Lazygit wraps it with visual feedback and a menu-driven interface, but the mechanics are identical to running `git bisect start`, `git bisect good <ref>`, `git bisect bad <ref>`, and `git bisect reset` from the command line.

## Prerequisites

- Module 1 (01-orientation) -- navigating panels, reading commit history.
- Module 4 (04-rewriting-history) -- familiarity with the Commits panel.

## Verify

```bash
./train.sh verify 7/2
```
