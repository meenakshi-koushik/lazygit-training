# Solution: Status Panel Deep Dive

## Step 1: Open lazygit and explore the Status panel

Open lazygit in the sandbox repo:

```
cd sandbox/02-status-panel-deep-dive && lazygit
```

When lazygit opens, you land on the **Files** panel by default. Look at the top-left panel -- this is the **Status panel**. It shows:

- The repository name (`02-status-panel-deep-dive`)
- The current branch (`main`)
- The upstream tracking status (e.g., `+2` indicating you are 2 commits ahead of `origin/main`)

Press `1` to focus the Status panel, or use `h`/`l` to navigate to it. Notice the branch name and ahead/behind information. The `+2` (or similar) tells you that `main` has 2 commits that have not been pushed to the remote.

> **Git context**: The ahead/behind count comes from `git rev-list --left-right --count origin/main...main`.

## Step 2: Navigate to the Branches panel

Press `3` to jump directly to the **Branches** panel (or press `l` a couple of times from the Status panel to navigate there).

You should see the local branches listed:

- `main` (with a `*` or highlighted indicating it is the current branch)
- `feature/auth-service`
- `feature/db-migration`
- `feature/notifications`
- `infra/helm-upgrade`

Use `j`/`k` to scroll through the branch list. Notice that each branch shows its tracking info relative to origin.

## Step 3: Check out `feature/auth-service`

Use `j`/`k` to highlight `feature/auth-service` in the Branches panel.

Press `<space>` to check out the branch.

lazygit will switch to `feature/auth-service`. Look at the Status panel again -- it now shows `feature/auth-service` as the current branch, and the ahead/behind count reflects this branch's relationship with `origin/feature/auth-service`.

> **Git context**: This runs `git checkout feature/auth-service` under the hood.

## Step 4: Create the `status-explored` branch

While still in the Branches panel with `feature/auth-service` checked out, press `n` to create a new branch.

A prompt will appear asking for the new branch name. Type:

```
status-explored
```

Press `<enter>` to confirm.

lazygit creates the new branch and switches to it. The Status panel now shows `status-explored` as the current branch. Since this branch has no remote tracking branch yet, you will not see ahead/behind info for it.

> **Git context**: This runs `git checkout -b status-explored`, creating a new branch from the current HEAD (which is `feature/auth-service`).

## Verification

Press `q` to exit lazygit, then run:

```
./train.sh verify 01-orientation/02-status-panel-deep-dive
```

All checks should pass: `status-explored` exists, you are on it, and it is based on `feature/auth-service`.
