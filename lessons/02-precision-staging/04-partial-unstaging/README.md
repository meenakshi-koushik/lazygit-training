# Partial Unstaging

## Scenario

You are working on a platform monorepo, making changes across two services: `api` and `worker`. You've been modifying files in both services -- adding rate limiting to the API and improving retry logic in the worker. You intended to commit these as two separate, focused commits, but you accidentally pressed `a` in lazygit's Files panel and staged everything at once.

All your changes are now in the staging area. You need to unstage the worker changes so you can commit only the API changes first, then commit the worker changes separately. Critically, you must not lose any of your modifications -- the worker changes should remain in the working tree as unstaged changes, ready for a follow-up commit.

## Objectives

1. Unstage all files under `services/worker/` so they are no longer in the staging area.
2. Keep all files under `services/api/` staged and ready to commit.
3. Ensure the worker modifications are still present in the working tree (unstaged, not lost).

After completing the objectives, `git diff --cached` should show only API changes, and `git diff` (unstaged) should show the worker changes.

## Key Concepts

- Staging and unstaging are symmetric operations. Just as `<space>` stages a file in the Files panel, `<space>` on a staged file will unstage it. The change moves from the index back to the working tree -- nothing is lost.
- If you need finer control, press `<enter>` on a staged file to view its diff, then unstage individual hunks with `<space>` -- exactly the reverse of hunk staging.
- Under the hood, unstaging a file runs `git reset HEAD <file>`, which removes the file from the index without touching the working tree. Your modifications stay intact.
- This is a common recovery workflow: you staged too much, so you selectively unstage what doesn't belong in this commit.

## Prerequisites

- [02-precision-staging/01-staging-hunks](../01-staging-hunks/) -- you should be comfortable with hunk-level staging and understand the staging area concept.
