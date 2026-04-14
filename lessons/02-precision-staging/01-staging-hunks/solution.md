# Solution: Staging Individual Hunks

## Step 1 -- Open lazygit

```bash
cd sandbox/01-staging-hunks
lazygit
```

Lazygit opens with the **Files** panel focused. You should see two modified files:
- `services/api/src/routes.py` (modified)
- `services/worker/src/main.py` (modified)

Both appear with a red `M` indicator, meaning they have unstaged changes.

## Step 2 -- Open the diff view for routes.py

1. Use `j`/`k` to select `services/api/src/routes.py` in the Files panel.
2. Press `<enter>` to open its diff view.

You should see the full diff in the main pane. There are **two hunks** separated by `@@` header lines:

- **Hunk 1** (near the top): Adds `import logging` and `logger = logging.getLogger(__name__)`.
- **Hunk 2** (near the bottom): Adds a new `/api/v1/metrics` route function.

## Step 3 -- Stage only the first hunk

1. Your cursor should already be on the first hunk (the import/logging changes at the top of the diff).
2. Press `<space>` to stage this hunk.

The first hunk's background changes to green, indicating it is now staged. The second hunk (the metrics route) remains red/unstaged.

> **Git context:** Under the hood, lazygit updates the index with only the selected hunk. This is equivalent to using `git add --patch` and selecting `y` for the first hunk and `n` for the second. The file now appears in both the staged and unstaged sections because part of it is staged and part is not.

## Step 4 -- Return to the file list

Press `<esc>` to go back to the Files panel.

You should now see `services/api/src/routes.py` listed in **both** the staged area (green) and the unstaged area (red). This confirms that only part of the file is staged.

## Step 5 -- Confirm worker is not staged

Check that `services/worker/src/main.py` still shows as unstaged (red `M`). If you accidentally staged it, select it and press `<space>` to unstage it.

## Step 6 -- Verify

Exit lazygit by pressing `q`, then verify your work:

```bash
cd ../..
./train.sh verify 02-precision-staging/01-staging-hunks
```

All three checks should pass:
1. `services/api/src/routes.py` is staged.
2. `services/api/src/routes.py` still has unstaged changes (the second hunk).
3. `services/worker/src/main.py` is not staged.
