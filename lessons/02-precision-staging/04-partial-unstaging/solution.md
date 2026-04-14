# Solution: Partial Unstaging

## Step 1 -- Open lazygit

```bash
cd sandbox/04-partial-unstaging
lazygit
```

Lazygit opens with the **Files** panel focused. You should see all modified files listed as staged (green indicators). The setup script ran `git add -A`, so everything is in the staging area.

## Step 2 -- Identify the files to unstage

Look through the Files panel. You should see staged changes in:

- `services/api/src/config.py` -- keep staged
- `services/api/src/routes.py` -- keep staged
- `services/api/tests/test_routes.py` -- keep staged
- `services/worker/src/config.py` -- **unstage this**
- `services/worker/src/main.py` -- **unstage this**

## Step 3 -- Unstage the worker files

1. Use `j`/`k` to navigate to `services/worker/src/main.py`.
2. Press `<space>` to unstage it. The file's indicator changes from staged (green) to unstaged (red). The file content is not affected -- only its staging status changes.
3. Navigate to `services/worker/src/config.py`.
4. Press `<space>` to unstage it.

> **Git context:** Each `<space>` press on a staged file runs `git reset HEAD <file>`, which removes the file from the index (staging area) but leaves the working tree copy untouched. Your modifications remain intact.

## Step 4 -- Verify the result in lazygit

After unstaging both worker files, your Files panel should show:

- **Staged changes** (green): `services/api/src/config.py`, `services/api/src/routes.py`, `services/api/tests/test_routes.py`
- **Unstaged changes** (red): `services/worker/src/config.py`, `services/worker/src/main.py`

You can press `<enter>` on any file to inspect its diff and confirm the changes are what you expect.

## Step 5 -- Verify

Exit lazygit by pressing `q`, then verify your work:

```bash
cd ../..
./train.sh verify 02-precision-staging/04-partial-unstaging
```

All checks should pass: API files staged, worker files unstaged, and worker modifications preserved in the working tree.

## Bonus: Unstaging individual hunks

If you had a single file with both API and worker changes mixed together, you could press `<enter>` on the staged file to view its diff, then use `<space>` on individual hunks to selectively unstage them -- exactly the reverse of hunk staging from the earlier lesson.
