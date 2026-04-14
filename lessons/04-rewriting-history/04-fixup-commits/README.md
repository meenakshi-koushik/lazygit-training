# Fixup Commits

```bash
lazygit -p sandbox/04-fixup-commits
```

## Scenario

You are working on a feature branch `feature/auth-middleware` in your team's platform monorepo. You have three clean, well-structured commits that add authentication middleware to the API service:

1. The auth middleware skeleton
2. Token validation logic
3. Tests for the auth middleware

After a code review, a teammate points out that you forgot to add input sanitization to the token validation logic (commit 2). The fix is small -- just a few lines in `services/api/src/token.py` -- but it logically belongs in the second commit, not tacked on as a fourth commit at the tip of your branch.

You could do a manual interactive rebase and edit the second commit, but lazygit has a much faster workflow: create a **fixup commit** that targets the second commit, then auto-squash it in.

The fix is already waiting for you as an unstaged modification in `services/api/src/token.py`.

## Objectives

1. Stage the unstaged changes in `services/api/src/token.py`.
2. Create a **fixup commit** targeting the second commit ("feat(api): implement token validation").
3. **Squash** all fixup commits above into their targets (auto-squash rebase).
4. End with a clean branch that still has exactly 3 commits -- the fix folded into the second commit.

## Key Concepts

When you need to retroactively fix an older commit without disrupting your branch history, lazygit's fixup workflow is the fastest path:

1. **Stage your fix** -- in the Files panel, stage the changes that belong in the older commit.
2. **Create a fixup commit** -- switch to the Commits panel, select the commit the fix belongs to, and press `F` (shift+f). Lazygit creates a commit with the message `fixup! <original message>`, automatically associating it with the target.
3. **Auto-squash** -- with the fixup commit visible in the Commits panel, press `S` (shift+s) to squash all fixup commits above. Lazygit runs an interactive rebase with `--autosquash`, folding each fixup commit into its target.

Under the hood, this is equivalent to:

```bash
git commit --fixup=<sha-of-target-commit>
git rebase -i --autosquash <base>
```

The result is a clean history where the fix appears as if it was always part of the original commit. This is essential for keeping feature branches tidy before merging into main.

## Prerequisites

- Lesson 4/2 (Interactive Rebase: Squashing Commits) -- you should understand how interactive rebasing works in lazygit.

## Verify

```bash
./train.sh verify 4/4
```
