# Solution: Branch Creation and Switching

## Step 1 -- Open lazygit

```bash
cd sandbox/01-branch-creation-and-switching
lazygit
```

Lazygit opens with the **Files** panel focused. The working tree is clean. You should see you are on the `main` branch (shown at the top of the window).

## Step 2 -- Navigate to the Branches panel

Press `3` (or use `]` to cycle right) to switch to the **Branches** panel. You should see three branches listed:

- `main` (checked out -- marked with `*`)
- `bugfix/login-timeout`
- `feature/notifications`

## Step 3 -- Create the feature/search-api branch

1. Press `n` to create a new branch.
2. A prompt appears asking for the branch name. Type `feature/search-api`.
3. Press `<enter>`.

Lazygit creates the branch and checks it out automatically. The branch indicator at the top now shows `feature/search-api`.

> **Git context:** This runs `git checkout -b feature/search-api`, which creates the branch at the current HEAD (the tip of `main`) and switches to it.

## Step 4 -- Make a commit on the new branch

You need at least one commit on `feature/search-api` so it is ahead of `main`.

1. Press `2` to go to the **Files** panel.
2. Open a file for editing. You can press `e` on any file to open it in your editor, or use the terminal. A simple approach: press `e` on `services/api/src/routes.py`, add a comment line (e.g., `# TODO: add search endpoint`), save, and close the editor.
3. Back in the Files panel, the modified file appears. Select it and press `<space>` to stage it.
4. Press `c` to open the commit dialog. Type a message like `feat(api): scaffold search endpoint` and press `<enter>`.

> **Git context:** This stages the file (`git add`) and creates a commit (`git commit`). The `feature/search-api` branch now has one commit that `main` does not.

## Step 5 -- Switch back to main

1. Press `3` to go to the **Branches** panel.
2. Navigate to `main` using `j`/`k`.
3. Press `<space>` to check out `main`.

The branch indicator at the top changes back to `main`.

> **Git context:** This runs `git checkout main`.

## Step 6 -- Create the hotfix/config-typo branch

1. While still in the Branches panel (and on `main`), press `n`.
2. Type `hotfix/config-typo`.
3. Press `<enter>`.

Lazygit creates and checks out `hotfix/config-typo`. You should now be on this branch.

> **Git context:** This runs `git checkout -b hotfix/config-typo` from the tip of `main`.

## Step 7 -- Verify

Exit lazygit by pressing `q`, then verify your work:

```bash
cd ../..
./train.sh verify 3/1
```

All four checks should pass:
1. Branch `feature/search-api` exists.
2. Branch `hotfix/config-typo` exists.
3. `feature/search-api` has at least 1 commit ahead of `main`.
4. HEAD is on `hotfix/config-typo`.
