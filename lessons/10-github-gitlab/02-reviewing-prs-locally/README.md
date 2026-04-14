# Reviewing PRs Locally

```bash
lazygit -p sandbox/02-reviewing-prs-locally
```

## Scenario

Your teammate has pushed a branch `feature/metrics` that adds a metrics collection system to the API service. They have asked you to review it before merging. You are currently on `main`.

Your review workflow:
1. Fetch the latest branches from origin.
2. Check out the PR branch to inspect the code.
3. Use lazygit's diffing features to compare the PR branch against `main` and understand what changed.
4. After reviewing, go back to `main`.

## Objectives

1. Fetch from origin to see the latest remote branches.
2. Check out `feature/metrics` from the remote.
3. Use lazygit's diff mode (`W`) to compare `feature/metrics` against `main` so you can see all the changes in one view.
4. Return to `main` after your review.

## Key Concepts

When reviewing a PR locally, you want to see the full set of changes the PR introduces relative to the base branch (usually `main`). Lazygit makes this easy with its **diffing mode**:

1. Press `W` (global) to open diffing options.
2. Select "diff against ref" and enter `main` (or select it from the branch list).
3. Lazygit now shows all files that differ between your current branch and `main`, with the full diff in the preview pane.

This is more useful than just looking at individual commits because it shows the cumulative effect of all commits in the PR -- exactly what a reviewer needs to see.

Other useful review techniques in lazygit:
- In the **Commits** panel (`4`), scroll through the PR's commits to understand the progression.
- Press `<enter>` on a commit to see which files it changed.
- In the **Local Branches** panel, select `main` and the diff view shows what your current branch added/removed relative to `main`.

Under the hood:
- Diffing mode uses `git diff main..feature/metrics` to show all changes.
- Checking out a remote branch: `git checkout feature/metrics` (creates local tracking branch from `origin/feature/metrics`).

## Prerequisites

- Module 1 (01-orientation) -- panel navigation.
- Module 3, Lesson 2 -- comparing branches.
- Module 9, Lesson 1 -- fetch, pull, push patterns.

## Verify

```bash
./train.sh verify 10/2
```
