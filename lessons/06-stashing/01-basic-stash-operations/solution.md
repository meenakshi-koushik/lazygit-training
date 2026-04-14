# Solution: Basic Stash Operations

## Step 1 -- Open lazygit

```bash
lazygit -p sandbox/01-basic-stash-operations
```

Lazygit opens with the **Files** panel focused. You should see three modified files listed:

- `services/api/config/settings.yaml`
- `services/api/src/profiles.py`
- `services/api/tests/test_routes.py`

The branch indicator at the top shows `feature/user-profiles`.

## Step 2 -- Stash all changes

1. Make sure you are in the **Files** panel (press `2` if not).
2. Press `s` to stash all changes.

The Files panel is now empty -- your working tree is clean. All three modified files have been saved to the stash.

> **Git context:** This runs `git stash push`, which saves your uncommitted changes to the stash stack and resets the working tree to match HEAD.

## Step 3 -- Switch to the main branch

1. Press `3` to go to the **Branches** panel.
2. Navigate to `main` using `j`/`k`.
3. Press `<space>` to check out `main`.

The branch indicator at the top changes to `main`. The Files panel is clean because you stashed your changes before switching.

> **Git context:** This runs `git checkout main`. Without stashing first, git would have either refused to switch (if the changes conflicted) or carried the uncommitted changes over to `main`.

## Step 4 -- Switch back to feature/user-profiles

1. Stay in the **Branches** panel (`3`).
2. Navigate to `feature/user-profiles` using `j`/`k`.
3. Press `<space>` to check it out.

The branch indicator shows `feature/user-profiles` again. The Files panel is still clean because the changes are still in the stash.

> **Git context:** This runs `git checkout feature/user-profiles`.

## Step 5 -- Pop the stash to restore your work

1. Press `5` to go to the **Stash** panel.
2. You should see one stash entry (something like `WIP on feature/user-profiles: ...`).
3. Select it and press `g` to pop the stash.

The Files panel now shows the three modified files again, exactly as they were before you stashed. The Stash panel is empty.

> **Git context:** This runs `git stash pop`, which applies the stashed changes to the working tree and removes the stash entry. If you had pressed `<space>` instead of `g`, it would have run `git stash apply` -- restoring the changes but keeping the stash entry for potential reuse.

## Step 6 -- Verify

Exit lazygit by pressing `q`, then verify your work:

```bash
./train.sh verify 6/1
```

All checks should pass:
1. On branch `feature/user-profiles`.
2. Working tree has unstaged changes.
3. The three files contain the expected WIP content.
4. Stash list is empty.
