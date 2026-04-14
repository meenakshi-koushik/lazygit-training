# Solution: Reviewing PRs Locally

## Step 1 -- Open lazygit

```bash
lazygit -p sandbox/02-reviewing-prs-locally
```

Lazygit opens on `main`. The teammate's PR branch `feature/metrics` exists on origin but not locally yet.

## Step 2 -- Fetch from origin

1. Press `2` to go to the **Files** panel.
2. Press `f` to fetch from all remotes.

This updates your knowledge of remote branches. `origin/feature/metrics` is now visible.

> **Git context:** `git fetch --all` downloads the latest refs and objects from the remote.

## Step 3 -- Check out the PR branch

1. Press `3` to go to the **Local Branches** panel.
2. Press `]` to navigate to the **Remotes** tab.
3. Select `origin` and press `<enter>` to expand it.
4. Navigate to `feature/metrics` and press `<space>` to check it out.

Lazygit creates a local `feature/metrics` branch tracking `origin/feature/metrics` and switches to it.

> **Git context:** `git checkout feature/metrics` creates a local tracking branch from the remote ref.

## Step 4 -- Review the changes using diff mode

1. Press `W` to open diffing options.
2. Select "diff against ref" (or similar option).
3. Type `main` and press `<enter>` (or select `main` from the list).

Lazygit now shows all files that differ between `feature/metrics` and `main`. The preview pane shows the full diff for each file. You can:

- Scroll through the file list to see what files were added/modified.
- Press `<enter>` or use the preview pane to read the changes.
- Press `4` to look at individual commits in the **Commits** panel.

Take a moment to review the metrics collector, endpoint, timing middleware, and tests.

> **Git context:** This is equivalent to `git diff main..feature/metrics`. It shows the cumulative effect of all commits in the PR.

## Step 5 -- Exit diff mode and return to main

1. Press `W` again and select the option to exit/reset the diff (or select "diff off").
2. Press `3` to go to the **Local Branches** panel (press `[` if needed to get to the Local Branches tab).
3. Select `main` and press `<space>` to check it out.

You are back on `main`. Your review is complete.

## Step 6 -- Verify your work

Exit lazygit by pressing `q`, then verify:

```bash
./train.sh verify 10/2
```

All checks should pass:
1. Back on `main`.
2. `feature/metrics` exists locally.
3. `feature/metrics` tracks `origin/feature/metrics`.
4. `feature/metrics` has the expected commits.
5. Working tree is clean.
