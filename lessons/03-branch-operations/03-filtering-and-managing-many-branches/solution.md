# Solution: Filtering and Managing Many Branches

## Step 1 -- Open lazygit

```bash
cd sandbox/03-filtering-and-managing-many-branches
lazygit
```

Lazygit opens with the Files panel focused. The repo is clean (no uncommitted changes), so the panel is empty.

## Step 2 -- Switch to the Branches panel

Press `2` (or use the number shown at the top of the Branches panel) to jump directly to the **Branches** panel. You should see a long list of branches: `main` plus 15 topic branches spanning `feature/`, `bugfix/`, `hotfix/`, `release/`, and `chore/` prefixes.

## Step 3 -- Filter for chore branches

Press `/` to open the filter/search bar at the bottom of the Branches panel. Type `chore` and press `<enter>`.

The branch list narrows to show only:

- `chore/ci-pipeline`
- `chore/cleanup-logs`
- `chore/update-deps`

This is the key workflow for managing branches in large repos -- filtering cuts through the noise instantly.

## Step 4 -- Delete each chore branch

1. Navigate to `chore/update-deps` using `j`/`k`.
2. Press `d` to delete the branch. Lazygit prompts for confirmation.
3. Press `<enter>` to confirm. The branch is removed.
4. Navigate to `chore/cleanup-logs` and press `d`, then `<enter>`.
5. Navigate to `chore/ci-pipeline` and press `d`, then `<enter>`.

> **Git context:** Each deletion runs `git branch -D <branch>`, which force-deletes the branch regardless of merge status. The commits on those branches are not immediately lost -- they remain in the reflog for 30 days by default -- but the branch pointer is gone.

## Step 5 -- Clear the filter and verify

Press `<esc>` to clear the filter. The full branch list returns, now without the three chore branches. You should see 13 branches remaining: `main` plus 12 topic branches.

Confirm you are on `main` -- it should be highlighted with an asterisk or marker in the Branches panel. If you are not on `main`, navigate to it and press `<space>` to check it out.

## Step 6 -- Verify

Exit lazygit by pressing `q`, then verify your work:

```bash
cd ../..
./train.sh verify 3/3
```

All checks should pass: the three chore branches are deleted, `feature/dashboard-v2` and `hotfix/prod-crash` still exist, and HEAD is on `main`.
