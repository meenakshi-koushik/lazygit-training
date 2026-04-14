# Interactive Rebase: Squashing Commits

```bash
lazygit -p sandbox/02-interactive-rebase-squash
```

## Scenario

You have been working on a rate limiting feature for the API service in your team's monorepo. Over the course of development, you made 5 commits on your `feature/rate-limiting` branch -- but the history is messy: "WIP", "fix typo", "oops forgot file", and other throwaway messages. Before opening a pull request, you need to clean this up by squashing those 5 commits down to 2 meaningful ones.

Lazygit makes interactive rebase visual and intuitive. Instead of editing a TODO file in `git rebase -i`, you can squash commits with a single keypress while seeing the full commit list.

## Objectives

1. Squash the 5 messy commits on `feature/rate-limiting` down to exactly **2 clean commits**.
2. Ensure none of the remaining commit messages contain "WIP", "wip", "oops", or "typo" -- reword them into clean, descriptive messages.
3. Preserve all file content -- `services/api/src/rate_limiter.py` and `services/api/tests/test_rate_limiter.py` must still exist with their final content intact.
4. Stay on the `feature/rate-limiting` branch with a clean working tree.

## Key Concepts

Lazygit wraps `git rebase -i` into a visual interface in the **Commits** panel:

- Navigate to the commit you want to squash **into** (the one that should absorb another).
- Press `s` to **squash** the selected commit into its parent -- this combines the two commits, keeping the parent's message (you get a chance to edit the combined message).
- Press `f` for **fixup** -- like squash, but it silently discards the squashed commit's message, keeping only the parent's.
- After squashing, press `r` to **reword** the resulting commit with a clean message.

Under the hood, lazygit constructs and executes a `git rebase -i` with `squash` or `fixup` commands for the commits you selected. The result is the same as manually editing the rebase TODO file, but without leaving your terminal UI.

**Tip:** You can also select multiple commits and squash them in one operation. In the Commits panel, press `v` to enter visual/range select mode, select the commits you want to combine, then press `s` to squash them all into one.

## Prerequisites

- Module 4, Lesson 1 (04-rewriting-history/01-amending-commits) -- you should be comfortable with basic commit rewriting in lazygit.

## Verify

```bash
./train.sh verify 4/2
```
