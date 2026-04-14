## Hint 1

You need to save your work temporarily before switching branches. Look at the Files panel -- there is a keybinding for stashing changes directly from there.

## Hint 2

In the Files panel (`2`), press `s` to stash all changes. After stashing, the Files panel should be empty (clean working tree). Now you can safely switch branches using the Branches panel (`3`).

## Hint 3

After switching to `main` and back to `feature/user-profiles`, you need to restore your stashed changes. Navigate to the Stash panel by pressing `5`. You should see one stash entry. Select it and press `g` to pop it (this applies the changes and removes the stash entry). Do not use `<space>` -- that applies without removing the entry from the stash list.

## Hint 4

To switch branches: go to the Branches panel (`3`), highlight the target branch, and press `<space>` to check it out. Do this twice -- once for `main`, once to come back to `feature/user-profiles`. Then go to the Stash panel (`5`) and pop with `g`.
