# Amending Commits

```bash
lazygit -p sandbox/01-amending-commits
```

## Scenario

You are working on the platform monorepo on a feature branch called `feature/add-validation`. You just committed input validation logic for the API service, but you immediately notice two problems:

1. You **forgot to include** a modified file -- `services/api/src/routes.py` has changes that should have been part of the commit, but you never staged it.
2. There is a **typo in the commit message**: it says "validaton" instead of "validation".

You need to fix both problems by amending the last commit -- adding the missing file and correcting the message -- without creating a new commit.

## Objectives

1. Stage the forgotten file `services/api/src/routes.py`.
2. Amend the last commit so the staged file is included in it.
3. Fix the typo in the commit message: change "validaton" to "validation".
4. End with a clean working tree and exactly one commit ahead of the starting point.

## Key Concepts

Amending is the simplest form of history rewriting. It replaces the most recent commit with a new one that includes any staged changes and/or an updated message. The old commit is discarded (it becomes unreachable).

In lazygit there are two operations involved:

- **Amend staged changes into the last commit:** In the **Files** panel, stage the forgotten file with `<space>`, then press `A` (shift+a) to amend. Lazygit will ask for confirmation -- accept it. This adds the staged changes to the most recent commit without opening an editor.

- **Reword the commit message:** Switch to the **Commits** panel, select the top commit (HEAD), and press `r` to reword. An inline editor opens where you can fix the typo. Press `<enter>` to confirm.

Under the hood, amending runs `git commit --amend`. It creates a brand-new commit object with the combined changes and updated message, then moves the branch pointer to it. The original commit still exists in the object store but is no longer referenced by any branch.

**Important:** Only amend commits that have not been pushed to a shared remote. Amending rewrites history, and force-pushing amended commits can cause problems for teammates who already have the original.

## Prerequisites

- Module 2 (02-precision-staging) -- you should be comfortable staging files and navigating the Files panel.

## Verify

```bash
./train.sh verify 4/1
```
