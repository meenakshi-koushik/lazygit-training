# Solution: Creating Worktrees

## Step 1 -- Open lazygit

```bash
lazygit -p sandbox/01-creating-worktrees
```

Lazygit opens with the **Files** panel focused. You should see two modified files (`services/api/src/auth.py` and `services/api/src/routes.py`) -- these are your work-in-progress changes on `feature/auth`. Do not stage or commit them.

## Step 2 -- Open the worktree view

1. Press `w` to open the worktree options/view.

You will see the current worktree listed (the main one, pointing at the sandbox directory). This is where you manage all worktrees for this repository.

> **Git context:** This is equivalent to running `git worktree list` to see all active worktrees.

## Step 3 -- Create a new worktree

1. Press `n` to create a new worktree.
2. Lazygit prompts for a **path**. Type `../01-creating-worktrees-dashboard` and press `<enter>`. This creates the worktree as a sibling directory next to the current sandbox repo (i.e., at `sandbox/01-creating-worktrees-dashboard`).
3. Lazygit prompts for a **branch**. Select `feature/dashboard` from the list and press `<enter>`.

Lazygit creates the worktree. You should now see two entries in the worktree view: the original (on `feature/auth`) and the new one (on `feature/dashboard`).

> **Git context:** This runs `git worktree add ../01-creating-worktrees-dashboard feature/dashboard`. Git checks out `feature/dashboard` into the new directory while keeping `feature/auth` checked out in the original. Both directories share the same `.git` object store, so branches, tags, and commit history are shared. The key constraint: a branch can only be checked out in one worktree at a time.

## Step 4 -- Verify your work

1. Press `<esc>` to return to the main lazygit view (if needed).
2. Check the branch indicator at the top -- it should still show `feature/auth`.
3. Press `2` to go to the **Files** panel -- your two modified WIP files should still be there.

Your uncommitted changes are untouched. The `feature/dashboard` branch is checked out in a completely separate directory. You could open a second terminal and run `lazygit -p sandbox/01-creating-worktrees-dashboard` to browse the dashboard code for review.

Exit lazygit by pressing `q`, then verify your work:

```bash
./train.sh verify 8/1
```

All checks should pass:
1. On branch `feature/auth` in the main worktree.
2. Working tree has uncommitted changes (WIP preserved).
3. WIP content is still present in the modified files.
4. `git worktree list` shows 2 worktrees.
5. The dashboard worktree directory exists.
6. The dashboard worktree is on branch `feature/dashboard`.
