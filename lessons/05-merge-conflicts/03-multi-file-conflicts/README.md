# Multi-File Conflicts

```bash
lazygit -p sandbox/03-multi-file-conflicts
```

## Scenario

You are working on a `feature/structured-logging` branch where you refactored logging across the monorepo. You changed four files: the shared library, two services, and the helm values. Meanwhile, a teammate pushed monitoring and scaling changes to `main` that modified the same four files.

You merged `main` into your branch and now you have conflicts in **four files simultaneously**:

1. `libs/common/src/common.py` -- your JSON logging vs. their monitoring utilities
2. `services/api/src/main.py` -- your structured logging vs. their monitoring integration
3. `services/worker/src/main.py` -- same as above, for the worker service
4. `infra/helm/values.yaml` -- your logging config vs. their monitoring config and resource scaling

This is a realistic monorepo scenario: a cross-cutting refactor that touches the same components a teammate is working on. You need to resolve all four conflicts before you can complete the merge.

## Objectives

1. Resolve conflicts in all four files, keeping changes from **both** sides in each.
2. Stage all resolved files.
3. Complete the merge commit.
4. End with a clean working tree on the `feature/structured-logging` branch.

## Key Concepts

Multi-file conflicts are common in monorepos because cross-cutting changes (logging, auth, config) often touch many files that other developers are also modifying. The resolution process is the same as a single-file conflict, but repeated across all conflicted files.

In lazygit, the **Files** panel shows all conflicted files marked `UU`. Work through them one at a time:

1. Select a file, press `<enter>` to open the conflict view.
2. Resolve each conflict section (use `b` to keep both, or `<space>` to pick one side).
3. Press `<esc>` to return to the Files panel.
4. Move to the next conflicted file and repeat.

After all files are resolved, stage everything and complete the merge commit. You do not need to resolve all conflicts before staging -- you can stage files as you go.

A useful workflow tip: start with the lowest-level conflicts first (shared libraries), then work outward to the services that depend on them. This helps you understand what the combined code should look like.

## Prerequisites

- Module 5, Lesson 1 (Basic Merge Conflicts) -- single-file conflict resolution.

## Verify

```bash
./train.sh verify 5/3
```
