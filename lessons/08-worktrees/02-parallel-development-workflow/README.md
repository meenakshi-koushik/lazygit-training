# Parallel Development Workflow

```bash
lazygit -p sandbox/02-parallel-development-workflow
```

## Scenario

You are working on `feature/api-refactor` in the platform monorepo, refactoring the API service's request handling. You have uncommitted changes -- work in progress on the routes module. A colleague pings you: "My PR on `feature/review-target` is ready for review, but I think I left a TODO in the validation code that needs fixing before merge. Can you take a look?"

The setup has already created a worktree for `feature/review-target` at `sandbox/02-parallel-development-workflow-review` (you learned how to create worktrees in Lesson 8/1). Your job now is to **switch** to that worktree in lazygit, find and fix the TODO, commit the fix, and switch back to your original worktree -- all without disrupting your WIP.

The file `services/api/src/validation.py` in the review worktree contains a line `# TODO: add input length check` where actual validation code should be. You need to replace that TODO with a real length check.

## Objectives

1. Switch to the `02-parallel-development-workflow-review` worktree using lazygit's worktree panel.
2. Find the TODO in `services/api/src/validation.py`.
3. Fix the validation code: replace the `# TODO: add input length check` line with an actual length check (e.g., `if len(value) > MAX_LENGTH: raise ValueError("Input too long")`).
4. Stage the fix and commit it with a message containing "fix" and "validation".
5. Switch back to the main worktree (`feature/api-refactor`).
6. Your WIP on `feature/api-refactor` should still be intact (uncommitted changes present).

## Key Concepts

The real power of worktrees is not just creating them -- it is the **workflow** of switching between them fluidly. In a typical day you might be deep in a feature branch, get asked to review or hotfix something, do the work in a separate worktree, and come back to your feature without ever stashing or losing context.

In lazygit, pressing `w` (from the Branches, Commits, or Stash panels) opens the **Worktrees** view. From there:

- Press `<space>` on a worktree to **switch** to it. Lazygit reloads with that worktree's files, branch, and state.
- After making changes in the second worktree, switch back the same way: `w`, select the original worktree, `<space>`.

Because worktrees share the same `.git` object database, any commits you make in one worktree are immediately visible in the other. The branches, refs, and tags are all shared. Only the working tree and checked-out branch are independent.

This is the worktree equivalent of having two terminal tabs open in two different checkouts -- except it uses far less disk space since the object database is shared.

## Prerequisites

- Module 1 (01-orientation) -- navigating panels, basic staging and committing.
- Module 8, Lesson 1 -- creating worktrees (concepts and terminology).

## Verify

```bash
./train.sh verify 8/2
```
