# Solution: Comparing Branches

## Step 1 -- Open lazygit

```bash
cd sandbox/02-comparing-branches
lazygit
```

Lazygit opens with the Files panel focused. The working tree is clean. You are on `feature/api-refactor`.

## Step 2 -- Navigate to the Branches panel

Press `3` (or use `]` to cycle panels) to switch to the **Branches** panel. You should see:

- `feature/api-refactor` (marked as current with a `*`)
- `main`

## Step 3 -- View commits on your feature branch

With `feature/api-refactor` selected in the Branches panel, look at the **Commits** panel on the right. It shows the commit history for your current branch. You should see your 3 feature commits at the top:

- `test(api): add tests for v2 list endpoint`
- `feat(api): add v2 configuration options`
- `refactor(api): restructure routes with v2 endpoints`

Below those are the 8 shared commits from before the branches diverged.

## Step 4 -- View commits on main

Use `j`/`k` to select `main` in the Branches panel and press `<enter>`. The Commits panel now shows `main`'s history. You should see 4 commits at the top that your branch does not have:

- `docs: update README with recent changes`
- `feat(libs/common): add health check method`
- `feat(infra): add worker replica count variable`
- `feat(worker): add graceful shutdown handler`

> **Git context:** This is equivalent to running `git log main` and `git log feature/api-refactor` and comparing them. The divergence point is where the commit histories converge.

Press `<esc>` to return to the Branches panel.

## Step 5 -- View the diff between branches

Select `main` in the Branches panel and press `W`. This opens the diffing menu. Choose the option to diff against the selected branch. The main panel now shows the diff between your current branch (`feature/api-refactor`) and `main`. You can see exactly what files differ and how.

> **Git context:** This is equivalent to `git diff main...feature/api-refactor`, showing the changes your branch introduces relative to `main`.

Press `<esc>` to exit diff mode.

## Step 6 -- Rebase onto main

Now rebase your branch so it sits on top of `main`'s latest commits:

1. In the Branches panel, select `main`.
2. Press `r` to rebase.
3. Lazygit shows a confirmation prompt asking how to rebase. Select **simple rebase** (the default option).

Lazygit runs `git rebase main` under the hood. Since there are no conflicting changes between the two branches, the rebase completes cleanly.

> **Git context:** The rebase takes your 3 feature commits, detaches them from their old base, and replays them one by one on top of `main`'s current HEAD. The commit hashes change (they are rewritten), but the diffs remain the same. After the rebase, `main` is a direct ancestor of `feature/api-refactor`.

## Step 7 -- Confirm the result

Look at the Commits panel. Your branch now shows:

1. Your 3 feature commits at the top (with new hashes).
2. Below them, all of `main`'s commits -- including the 4 that were previously missing.

The branch history is now linear: `main` is a direct ancestor of `feature/api-refactor`.

## Step 8 -- Verify

Exit lazygit by pressing `q`, then verify your work:

```bash
cd ../..
./train.sh verify 3/2
```

All checks should pass:
1. HEAD is on `feature/api-refactor`.
2. `main` is an ancestor of `feature/api-refactor` (rebase succeeded).
3. No merge conflicts.
4. Working tree is clean.
