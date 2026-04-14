# Solution: Upstream Tracking

## Step 1 -- Open lazygit

```bash
lazygit -p sandbox/03-upstream-tracking
```

Lazygit opens on the `main` branch. You need to work with two branches:
- `feature/search` (exists on origin, not locally)
- `feature/caching` (exists locally, not on origin)

## Step 2 -- Check out feature/search from remote

1. Press `3` to go to the **Local Branches** panel.
2. Press `]` to switch to the **Remotes** tab.
3. Select `origin` and press `<enter>` to expand it and see remote branches.
4. Navigate to `feature/search` and press `<space>` to check it out.
5. Lazygit creates a local `feature/search` branch that tracks `origin/feature/search`.

> **Git context:** This runs `git checkout feature/search`, which Git resolves via `--guess` mode: it finds `origin/feature/search` and creates a local branch tracking it. Equivalent to `git checkout -b feature/search --track origin/feature/search`.

## Step 3 -- Switch to feature/caching

1. Press `3` to go back to the **Local Branches** panel (press `[` if you need to get back to the Local Branches tab).
2. Navigate to `feature/caching` and press `<space>` to check it out.

You are now on `feature/caching`. Notice there is no upstream indicator -- this branch is purely local.

## Step 4 -- Push feature/caching with upstream tracking

1. Press `P` (uppercase) to push.
2. Lazygit detects that there is no upstream configured and prompts you to set one. It will suggest pushing to `origin/feature/caching`.
3. Confirm by pressing `<enter>`.

Lazygit pushes your branch and sets up tracking in one step.

> **Git context:** This runs `git push -u origin feature/caching`. The `-u` (or `--set-upstream-to`) flag tells git to record `origin/feature/caching` as the upstream for the local `feature/caching` branch. From now on, `git push` and `git pull` on this branch know where to sync.

## Step 5 -- Verify your work

Exit lazygit by pressing `q`, then verify:

```bash
./train.sh verify 9/3
```

All checks should pass:
1. `feature/search` exists locally.
2. `feature/search` tracks `origin/feature/search`.
3. `feature/search` has the search service commits.
4. `feature/caching` is pushed to origin.
5. `feature/caching` tracks `origin/feature/caching`.
6. `feature/caching` on origin matches local.
