# CI Status and PR Workflows

```bash
lazygit -p sandbox/03-ci-status-and-pr-workflows
```

## Scenario

You are ready to submit your `feature/logging` branch as a PR, but `main` has moved ahead since you branched off. Before creating the PR, you need to rebase your branch onto the latest `main` to ensure your changes are compatible and CI will pass. This is a common requirement in many teams: PRs must be up-to-date with `main` before merging.

Your workflow mirrors what happens when CI reports "branch is out of date with base":

1. Fetch the latest `main` from origin.
2. Rebase your feature branch onto the updated `main`.
3. Force-push the rebased branch (since the history changed).

## Objectives

1. Fetch from origin to get the latest `main`.
2. Fast-forward your local `main` to match `origin/main`.
3. Rebase `feature/logging` onto the updated `main`.
4. Force-push `feature/logging` to origin.

## Key Concepts

In many CI/CD workflows, a PR must be "up to date" with the base branch before it can be merged. This means:

1. The PR branch must include all commits from `main` (no merge conflicts, CI runs against the combined code).
2. If `main` has moved since you pushed, you need to rebase or merge `main` into your branch.

The lazygit workflow for this is:

1. **Fetch** (`f` in Files panel) -- get latest remote state.
2. **Fast-forward main** (`f` on `main` in Branches panel) -- update your local `main`.
3. **Rebase onto main** -- in the Branches panel, select `main` and press `r` to rebase. Or from your feature branch, press `r` on the `main` entry.
4. **Force-push** (`P`, then confirm force-push) -- update the remote branch.

This combines skills from Modules 4 (rebase), 5 (conflict resolution), and 9 (remote operations) into the real-world PR update workflow.

Under the hood:
- `git fetch --all` updates remote refs.
- `git fetch origin main:main` fast-forwards local main.
- `git rebase main` replays feature commits on top of updated main.
- `git push --force-with-lease` updates the remote branch safely.

## Prerequisites

- Module 4, Lesson 2 -- interactive rebase.
- Module 5, Lesson 2 -- rebase conflicts.
- Module 9, Lessons 1-2 -- fetch, push, force-push.

## Verify

```bash
./train.sh verify 10/3
```
