## Hint 1

Start by opening the **Branches** panel (press `3` or cycle with `]`). Select `main` and press `r` to rebase the current branch onto it. Lazygit will begin replaying your commits and stop at the first conflict.

## Hint 2

When the rebase pauses at a conflict, look at the **Files** panel. You will see conflicted files marked with `UU`. Select each file, press `<enter>`, and use `b` to pick both sides (you want retry settings AND batch settings in config.py). After resolving, press `<esc>`, stage the file with `<space>`, then continue the rebase.

## Hint 3

To continue the rebase after resolving conflicts for one commit, look for the rebase status in lazygit's status bar or in the Files panel. There may be a "continue" option. You can also use the menu -- press `m` or look for a rebase continue action. The rebase will replay the next commit and may pause again if it conflicts. Repeat the resolution process for each conflicting commit.

## Hint 4

After resolving all conflicts and continuing through each commit, the rebase completes. Your three commits should now appear on top of main's commits in the **Commits** panel. The history should be linear (no merge commits). Verify with `./train.sh verify 5/2`.
