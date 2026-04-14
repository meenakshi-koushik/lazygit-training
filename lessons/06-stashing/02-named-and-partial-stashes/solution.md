# Solution: Named and Partial Stashes

## Step 1 -- Open lazygit

```bash
lazygit -p sandbox/02-named-and-partial-stashes
```

Lazygit opens with the **Files** panel focused. You should see 4 modified files:

- `services/api/src/config.py`
- `services/api/src/notifications.py`
- `services/worker/src/config.py`
- `services/worker/src/queue.py`

All 4 are listed as unstaged modifications.

## Step 2 -- Stash the API files with a name

You need to stash only the two API files. Use lazygit's shell prompt to run a path-based stash:

1. Press `:` to open the command prompt at the bottom of the screen.
2. Type the following and press `<enter>`:
   ```
   git stash push -m "api notification changes" -- services/api/src/notifications.py services/api/src/config.py
   ```

The two API files disappear from the Files panel. Only the two worker files remain.

> **Git context:** `git stash push -m "message" -- path1 path2` stashes only the specified files. This is the most portable way to create partial stashes, working with git 2.13+.

## Step 3 -- Stash the remaining worker files with a name

1. Press `S` (shift+s) to open the **stash options menu**.
2. Select **stash all changes** (since only the worker files remain, this captures just them).
3. Type `worker notification changes` as the message and press `<enter>`.

The Files panel should now be empty -- all changes are stashed.

> **Git context:** This runs `git stash push -m "worker notification changes"`.

## Step 4 -- Verify both stashes in the Stash panel

1. Press `5` to switch to the **Stash** panel.
2. You should see two entries:
   - `stash@{0}`: `On feature/notifications: worker notification changes`
   - `stash@{1}`: `On feature/notifications: api notification changes`

The most recent stash is always at position 0.

## Step 5 -- Pop the worker stash

1. In the **Stash** panel, select `stash@{0}` (the worker stash -- it should already be selected).
2. Press `g` to **pop** the stash.

This applies the worker changes to your working tree and removes the stash entry. The Stash panel should now show only one entry:
   - `stash@{0}`: `On feature/notifications: api notification changes`

Switch to the **Files** panel (`2`) to confirm the two worker files are back as unstaged modifications.

> **Git context:** This runs `git stash pop stash@{0}`. Pop = apply + drop. The worker changes are restored to the working tree and the stash entry is removed. The API stash remains untouched, shifting from `stash@{1}` to `stash@{0}`.

## Step 6 -- Verify

Exit lazygit with `q`, then verify:

```bash
./train.sh verify 6/2
```

All checks should pass:
1. On branch `feature/notifications`.
2. Exactly 1 stash entry remains.
3. The remaining stash is named with "api notification".
4. Working tree has unstaged changes (worker files restored).
5. `services/worker/src/queue.py` contains the notification queue code.
6. `services/worker/src/config.py` contains queue configuration.
7. API files are not modified (still stashed).
