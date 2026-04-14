# Cherry-picking Hotfixes

```bash
lazygit -p sandbox/01-cherry-picking-hotfixes
```

## Scenario

You are working on `feature/payments` in the platform monorepo, building out payment processing logic. Your branch diverged from `main` several commits ago and you have three feature commits of your own. Meanwhile, a teammate landed a critical bug fix on `main` that patches a null pointer crash in the shared cache lookup code (`libs/common/src/common.py`). The fix has the commit message "fix(common): patch null pointer in cache lookup".

You need this fix on your feature branch now -- your payment service depends on the same cache library. A full merge of `main` would pull in a dozen unrelated changes and clutter your branch history. A rebase would rewrite all your commits. Cherry-pick is the right tool: grab exactly the one commit you need and apply it to your branch.

## Objectives

1. Find the bug fix commit on `main` (its message contains "fix(common): patch null pointer in cache lookup").
2. Cherry-pick that single commit onto `feature/payments`.
3. End on `feature/payments` with a clean working tree and the cherry-picked commit in your branch history.

## Key Concepts

Cherry-pick copies a single commit from one branch and replays it on top of your current branch. Unlike merge or rebase, it does not bring along any other commits -- just the one you select. The result is a new commit on your branch with the same diff and message as the original, but a different SHA (because it has a different parent).

In lazygit, cherry-picking is a two-step copy-paste workflow:

- **Copy**: Navigate to the commit you want and press `C`. The commit is highlighted in cyan to show it has been marked for cherry-pick. You can mark multiple commits if needed.
- **Paste**: Switch to the target branch and its Commits panel, then press `V` to paste the copied commit(s) onto the current branch.
- **Cancel**: Press `<c-r>` if you change your mind before pasting.

To browse commits on another branch without checking it out, go to the **Branches** panel (`3`), select the branch, and press `<enter>` to view its commit log.

Under the hood, `C` + `V` runs `git cherry-pick <sha>`. If the commit applies cleanly, you get a new commit immediately. If it conflicts, lazygit drops you into the merge conflict view just like during a rebase or merge.

## Prerequisites

- Module 1 (01-orientation) -- navigating panels, basic staging and committing.
- Module 3, Lesson 1 -- branch creation and switching.
- Module 4 -- understanding commit history and commit references.

## Verify

```bash
./train.sh verify 7/1
```
