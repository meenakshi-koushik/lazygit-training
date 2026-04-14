# Solution: Patch Operations

## Step 1 -- Open lazygit

```bash
lazygit -p sandbox/03-patch-operations
```

Lazygit opens with the **Files** panel focused. The working tree is clean. The branch indicator at the top shows `feature/logging`.

## Step 2 -- Navigate to the big refactor commit

1. Press `3` to go to the **Branches** panel.
2. Navigate to `feature/refactor` using `j`/`k`.
3. Press `<enter>` to view the commits on `feature/refactor`.
4. Find the commit with the message "refactor: cross-service logging and config restructure" (it is tagged `big-refactor`). Navigate to it with `j`/`k`.
5. Press `<enter>` to view the files changed in this commit.

You should see five files listed:

- `libs/common/src/common.py`
- `services/api/src/config.py`
- `services/api/src/routes.py`
- `services/api/tests/test_routes.py`
- `services/worker/src/main.py`

## Step 3 -- Build the custom patch

You want only the logging-related files. Select these three files and skip the other two:

1. Navigate to `services/api/src/routes.py` and press `<space>` to add it to the custom patch. The file gets highlighted to indicate it is selected.
2. Navigate to `services/worker/src/main.py` and press `<space>` to add it.
3. Navigate to `libs/common/src/common.py` and press `<space>` to add it.

Do **not** select `services/api/src/config.py` or `services/api/tests/test_routes.py`.

You should now have three files selected (highlighted) in the patch.

> **Git context:** You are building a custom patch -- lazygit is keeping track of which files (or lines) from this commit you want to extract. No git commands have been run yet.

## Step 4 -- Apply the custom patch

1. Press `<esc>` to go back from the file list.
2. Press `<c-p>` (Ctrl+P) to open the **custom patch options** menu.
3. Select **"apply patch"** from the menu.

Lazygit applies the selected changes to your working tree. If you switch to the Files panel (`2`), you should see three modified files.

> **Git context:** Under the hood, lazygit constructs a diff containing only the selected files from the commit and runs `git apply` to apply those changes to your working tree. This is equivalent to:
> ```
> git diff big-refactor^..big-refactor -- services/api/src/routes.py services/worker/src/main.py libs/common/src/common.py | git apply
> ```

## Step 5 -- Stage and commit the changes

1. Press `2` to go to the **Files** panel.
2. Press `a` to stage all modified files.
3. Press `c` to open the commit message editor.
4. Type a descriptive message, for example: `feat: add structured logging across services`
5. Press `<enter>` to confirm the commit.

The Files panel is now empty -- your working tree is clean. You have one new commit on `feature/logging`.

> **Git context:** This runs `git add -A && git commit -m "feat: add structured logging across services"`. The commit contains only the three logging-related file changes from the original refactor, without any of the config restructuring.

## Step 6 -- Verify

Exit lazygit by pressing `q`, then verify your work:

```bash
./train.sh verify 7/3
```

All checks should pass:
1. On branch `feature/logging`.
2. Working tree is clean.
3. `routes.py`, `main.py`, and `common.py` contain logging changes.
4. `config.py` does not contain the unwanted config restructuring.
5. `test_routes.py` does not contain the unwanted test changes.
6. Exactly 1 commit ahead of the starting point.
