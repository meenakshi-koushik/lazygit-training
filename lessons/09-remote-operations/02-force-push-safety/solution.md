# Solution: Force-Push Safety

## Step 1 -- Open lazygit

```bash
lazygit -p sandbox/02-force-push-safety
```

Lazygit opens on the `feature/billing` branch. Press `4` to look at the **Commits** panel -- you should see a single clean commit ("feat(billing): add billing service with invoices, payments, and tests") on top of the main branch history. This is the result of squashing 4 WIP commits.

Notice that the branch indicator may show your branch has diverged from origin. The remote still has the old 4-commit history.

## Step 2 -- Attempt a regular push

1. Press `P` (uppercase) to push.
2. The push will be **rejected** because your local history has diverged from the remote. Git cannot fast-forward `origin/feature/billing` to your local `feature/billing`.

Lazygit will detect the failure and prompt you with a question: it will ask if you want to force-push.

> **Git context:** Behind the scenes, `git push origin feature/billing` was rejected with "non-fast-forward" error. This happens whenever you rewrite history (rebase, squash, amend) on a branch that was already pushed.

## Step 3 -- Force-push with lease

1. When lazygit prompts you to force-push, confirm by pressing `<enter>` (or selecting the force-push option).

Lazygit pushes with `--force-with-lease`, which safely replaces the remote branch history. The push succeeds because no one else has pushed to `feature/billing` since your last fetch.

> **Git context:** `git push --force-with-lease origin feature/billing` checks that `origin/feature/billing` is at the commit you last saw it at. If someone else pushed a commit in the meantime, the push would fail, protecting their work. This is much safer than bare `--force`, which overwrites unconditionally.

## Step 4 -- Verify the result

1. Press `3` to look at the **Local Branches** panel. `feature/billing` should no longer show as diverged.
2. In the Commits panel (`4`), the remote indicator should show that `origin/feature/billing` is at the same commit as your local branch.

Exit lazygit by pressing `q`, then verify:

```bash
./train.sh verify 9/2
```

All checks should pass:
1. On branch `feature/billing`.
2. HEAD is the squashed commit.
3. `origin/feature/billing` matches local (force-push succeeded).
4. Origin has 1 commit ahead of main (WIP history replaced).
5. Working tree is clean.
