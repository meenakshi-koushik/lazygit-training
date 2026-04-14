## Hint 1

You need to find a specific commit on `main` and bring it to your current branch. You do not need to merge or rebase -- there is a way to copy just one commit. Look at the Branches panel to explore commits on other branches.

## Hint 2

Go to the **Branches** panel (`3`) and navigate to `main`. Press `<enter>` to view the commits on `main`. Scroll through the commit list to find the one with "fix(common): patch null pointer in cache lookup" in its message. Once you find it, there is a keybinding to mark it for cherry-picking.

## Hint 3

With the bug fix commit highlighted in main's commit list, press `C` (capital C) to copy it for cherry-picking. The commit will be highlighted in cyan. Now press `<esc>` to leave the sub-commits view, then press `4` to switch to your own branch's **Commits** panel. Press `V` (capital V) to paste the cherry-picked commit onto `feature/payments`.

## Hint 4

Full sequence: `3` (Branches panel) -> navigate to `main` -> `<enter>` (view commits) -> find the fix commit -> `C` (copy) -> `<esc>` (back to branches) -> `4` (Commits panel) -> `V` (paste). The commit is now on your feature branch.
