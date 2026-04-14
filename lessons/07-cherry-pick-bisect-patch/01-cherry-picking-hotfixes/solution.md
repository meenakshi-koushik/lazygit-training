# Solution: Cherry-picking Hotfixes

## Step 1 -- Open lazygit

```bash
lazygit -p sandbox/01-cherry-picking-hotfixes
```

Lazygit opens with the **Files** panel focused. The working tree is clean. The branch indicator at the top shows `feature/payments`.

## Step 2 -- Browse commits on main

1. Press `3` to go to the **Branches** panel.
2. Navigate to `main` using `j`/`k`.
3. Press `<enter>` to view the commits on `main` (this opens the sub-commits view).

You now see the full commit history of `main`. Scroll down through the list with `j` until you find the commit with the message "fix(common): patch null pointer in cache lookup". It should be a few commits from the top (there are 1-2 commits after it on `main`).

> **Git context:** This is equivalent to running `git log main` to inspect another branch's history without checking it out.

## Step 3 -- Copy the bug fix commit

1. With the bug fix commit highlighted, press `C` (capital C) to copy it for cherry-picking.

The commit line turns cyan, indicating it has been marked for cherry-pick. You can mark multiple commits if needed, but here we only need one.

> **Git context:** Nothing happens in git yet -- this is lazygit's internal clipboard. The actual `git cherry-pick` runs when you paste.

## Step 4 -- Paste the commit onto your feature branch

1. Press `<esc>` to leave the sub-commits view and return to the Branches panel.
2. Press `4` to switch to the **Commits** panel. You should see your `feature/payments` commits (the three payment-related commits on top).
3. Press `V` (capital V) to paste the cherry-picked commit.

The commit "fix(common): patch null pointer in cache lookup" now appears at the top of your commit list on `feature/payments`. The cyan highlight disappears, confirming the cherry-pick is complete.

> **Git context:** This runs `git cherry-pick <sha>`, where `<sha>` is the original commit from `main`. Git creates a new commit on `feature/payments` with the same changes (diff) and message, but a new SHA because its parent commit is different. The original commit on `main` is untouched.

## Step 5 -- Verify the result

You can confirm the cherry-pick worked by checking:

- The **Commits** panel (`4`) should show the fix commit at the top of `feature/payments`, followed by your three payment feature commits.
- Press `2` to check the **Files** panel -- it should be clean (no uncommitted changes).

Exit lazygit by pressing `q`, then verify your work:

```bash
./train.sh verify 7/1
```

All checks should pass:
1. On branch `feature/payments`.
2. Working tree is clean.
3. The cherry-picked commit message is in the branch history.
4. The file `libs/common/src/common.py` contains the null pointer fix.
5. The cherry-picked commit has a new SHA (confirming it was cherry-picked, not merged).
6. Original feature branch commits are intact.
