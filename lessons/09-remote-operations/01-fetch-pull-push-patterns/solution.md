# Solution: Fetch, Pull, Push Patterns

## Step 1 -- Open lazygit

```bash
lazygit -p sandbox/01-fetch-pull-push-patterns
```

Lazygit opens on the `feature/notifications` branch. The Files panel should be empty (clean working tree). You have 3 local commits that have not been pushed.

## Step 2 -- Fetch from origin

1. Make sure you are in the **Files** panel (press `2` if needed).
2. Press `f` to fetch from all remotes.

Lazygit runs `git fetch --all` in the background. After a moment, you should see updated information in the Branches panel -- `main` will show it is behind `origin/main`.

> **Git context:** `git fetch --all` downloads all new commits, branches, and tags from the remote without modifying any local branches. Your local `main` still points to the old commit, but `origin/main` now points to the latest commit your teammates pushed.

## Step 3 -- Fast-forward local main

1. Press `3` to switch to the **Local Branches** panel.
2. Navigate to the `main` branch (use `j`/`k` to scroll).
3. With `main` selected, press `f` to fast-forward it.

Lazygit updates your local `main` branch to match `origin/main` -- without checking it out. You remain on `feature/notifications`. The branch indicator for `main` should no longer show it as behind.

> **Git context:** This runs `git fetch origin main:main`, which is a fast-forward update of the local `main` ref. This only works if `main` can be fast-forwarded (no local-only commits on `main`). Since you have not made any commits on `main`, this is safe.

## Step 4 -- Push your feature branch

1. Make sure `feature/notifications` is selected (or just checked out -- either way, `P` pushes the current branch).
2. Press `P` (uppercase) to push.
3. If lazygit prompts you to set an upstream (because this is the first push of this branch), confirm by pressing `<enter>`.

Lazygit pushes your 3 notification service commits to `origin/feature/notifications`.

> **Git context:** This runs `git push -u origin feature/notifications` (the `-u` flag sets up tracking so future pushes don't need the upstream specified). Your commits are now visible on the remote and your teammates can see your branch.

## Step 5 -- Verify your work

Exit lazygit by pressing `q`, then verify:

```bash
./train.sh verify 9/1
```

All checks should pass:
1. Still on branch `feature/notifications`.
2. Local `main` matches `origin/main` (fast-forwarded).
3. Fetch completed (origin/main has teammate commits).
4. `feature/notifications` pushed to origin.
5. Working tree is clean.
