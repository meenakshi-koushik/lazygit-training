# Comparing Branches

```bash
lazygit -p sandbox/02-comparing-branches
```

## Scenario

You are working on a feature branch `feature/api-refactor` in the platform monorepo. While you have been adding commits to your branch, your teammates have continued merging work into `main`. The two branches have diverged -- `main` has 4 commits that your branch does not have, and your branch has 3 commits that `main` does not have.

Before opening a pull request, you need to understand the divergence: which commits are on your branch but not on `main`, what the overall diff looks like, and whether you can cleanly rebase onto the latest `main` to bring your branch up to date.

## Objectives

1. View the commits on `feature/api-refactor` that are not on `main` (your branch-specific commits).
2. View the diff between `feature/api-refactor` and `main`.
3. Rebase `feature/api-refactor` onto `main` so that `main` is an ancestor of your branch.
4. Remain on the `feature/api-refactor` branch with no merge conflicts.

## Key Concepts

Lazygit's **Branches** panel lets you compare branches and understand divergence without leaving the TUI:

- **Viewing branch commits**: In the Branches panel, select a branch and press `<enter>` to see its commit history. This helps you understand what work exists on each branch.
- **Comparing branches (diffing)**: While viewing your branch, press `<space>` on another branch (e.g., `main`) to see the diff between the two branches. This shows you exactly what has changed between them.
- **Rebasing onto another branch**: Select the target branch (e.g., `main`) in the Branches panel and press `r` to rebase the current branch onto it. This replays your commits on top of the target branch's latest state.

Under the hood, rebasing rewrites your branch's commits so they sit on top of `main`'s HEAD rather than branching off from the old point. After a successful rebase, `main` is a direct ancestor of your branch, meaning a future merge will be a clean fast-forward.

## Prerequisites

- Module 1 (01-orientation) -- comfortable navigating lazygit panels.
- Lesson 3/1 (Branch Creation and Switching) -- familiar with the Branches panel.

## Verify

```bash
./train.sh verify 3/2
```
