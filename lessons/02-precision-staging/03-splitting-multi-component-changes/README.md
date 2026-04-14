# Splitting Multi-Component Changes

## Scenario

You have been working on a feature that adds rate limiting across the platform. The changes span three components: the API service, the background worker, and the shared `common` library. You modified 2-3 files in each component and everything is sitting unstaged in your working tree.

Your team's convention is to commit by component -- one commit per component -- so that each commit is self-contained and easy to review. You need to create exactly 3 clean commits from your unstaged changes:

1. One for `services/api/` changes
2. One for `services/worker/` changes
3. One for `libs/common/` changes

This is a bread-and-butter monorepo workflow. You touch multiple components while developing, but you split your work into per-component commits before pushing.

## Objectives

1. Stage only the `services/api/` files and commit them with a message containing "api".
2. Stage only the `services/worker/` files and commit them with a message containing "worker".
3. Stage only the `libs/common/` files and commit them with a message containing "common" or "libs".
4. When done, the working tree should be clean (no unstaged or staged changes remaining).

## Key Concepts

- In lazygit's **Files panel** (panel 2), you see all modified files listed with their paths. You can use `j`/`k` to navigate and `<space>` to toggle staging on individual files.
- After staging the files for one component, press `c` to open the commit message editor, type your message, and press `<enter>` to commit. The staged files are committed; the rest remain unstaged.
- Repeat the stage-and-commit cycle for each component. This is much faster in lazygit than running `git add` and `git commit` repeatedly on the command line.
- Under the hood, `<space>` on a file runs `git add <file>` (or `git reset HEAD <file>` to unstage), and `c` runs `git commit`.

## Prerequisites

- [02-precision-staging/02-staging-lines](../02-staging-lines/) -- you should be comfortable staging in lazygit's Files panel.
