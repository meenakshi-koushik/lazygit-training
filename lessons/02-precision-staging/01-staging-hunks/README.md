# Staging Individual Hunks

## Scenario

You are working on the platform monorepo and just finished a coding session where you touched several files across `services/api/` and `services/worker/`. You want to make a focused commit that only includes part of your work -- specifically, a new import and logging setup you added near the top of `services/api/src/routes.py`. The rest of your changes (a new route at the bottom of the same file and changes in the worker service) should stay out of this commit.

The file `services/api/src/routes.py` contains TWO distinct hunks of changes: one near the top and one near the bottom. Your job is to stage only the first hunk, leaving everything else unstaged.

## Objectives

1. Stage **only the first hunk** of changes in `services/api/src/routes.py` (the import/logging changes near the top of the file).
2. Leave the second hunk (the new route near the bottom) unstaged in `services/api/src/routes.py`.
3. Do **not** stage any changes from `services/worker/src/main.py`.

## Key Concepts

When you modify a file in multiple places, git sees each cluster of changes as a separate **hunk**. A hunk is a contiguous block of added, removed, or modified lines surrounded by unchanged context. If your changes are far enough apart in the file, git treats them as independent hunks.

In lazygit, you can stage individual hunks rather than entire files:

1. In the **Files** panel, press `<enter>` on a file to open its diff view.
2. Navigate between hunks -- you will see each hunk separated by `@@` header lines.
3. Press `<space>` on a hunk to stage just that hunk.

This lets you build precise commits that contain only logically related changes, even when a single file has multiple unrelated edits.

Under the hood, lazygit runs `git add --patch` style operations, updating the index with only the selected hunks.

## Prerequisites

- Module 1 (01-orientation) -- you should be comfortable navigating lazygit panels and staging files.
