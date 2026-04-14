# Solution: Stash Across Branches

## Step 1 -- Open lazygit

```bash
lazygit -p sandbox/03-stash-across-branches
```

Lazygit opens with the **Files** panel focused. You should see three files with unstaged modifications: `services/api/src/routes.py`, `services/api/src/config.py`, and `libs/common/src/common.py`. The branch indicator at the top shows `main`.

## Step 2 -- Stash the changes

1. In the **Files** panel (`2`), press `s` to stash all changes.
2. A prompt appears asking for a stash message. Type `cache layer WIP` (or any description).
3. Press `<enter>`.

The Files panel is now empty -- your working tree is clean. The changes are safely stored in the stash.

> **Git context:** This runs `git stash push -m "cache layer WIP"`. The stash records your modifications against the current HEAD on `main`.

## Step 3 -- Create the feature branch

1. Press `3` to go to the **Branches** panel.
2. Press `n` to create a new branch.
3. Type `feature/cache-layer`.
4. Press `<enter>`.

Lazygit creates the branch and checks it out automatically. The branch indicator at the top now shows `feature/cache-layer`.

> **Git context:** This runs `git checkout -b feature/cache-layer`. The new branch points at the same commit as `main`, which means the stash will apply cleanly.

## Step 4 -- Pop the stash

1. Press `5` to go to the **Stash** panel.
2. You should see one entry: `stash@{0}: cache layer WIP`.
3. With the entry selected, press `g` to pop it.

The changes are restored to your working tree and the stash entry is removed. If you press `2` to go back to the Files panel, you will see the three modified files again.

> **Git context:** This runs `git stash pop`, which applies the stashed changes and drops the stash entry. Since the branch was created from the same commit the stash was made on, there are no conflicts.

## Step 5 -- Stage and commit

1. Press `2` to go to the **Files** panel.
2. Stage all files. You can select each file and press `<space>`, or press `a` to toggle stage all.
3. Press `c` to open the commit dialog.
4. Type a commit message, e.g., `feat(api): add cache layer`.
5. Press `<enter>` to create the commit.

The Files panel is now empty again -- working tree is clean.

> **Git context:** This runs `git add -A && git commit -m "feat(api): add cache layer"`. The `feature/cache-layer` branch is now exactly 1 commit ahead of `main`.

## Step 6 -- Verify

Exit lazygit by pressing `q`, then verify your work:

```bash
./train.sh verify 6/3
```

All five checks should pass:
1. Branch `feature/cache-layer` exists.
2. HEAD is on `feature/cache-layer`.
3. Working tree is clean.
4. Stash is empty.
5. Exactly 1 commit ahead of `main`.
