## Hint 1

This exercise combines three operations you have already learned: fetch, rebase, and force-push. Start by getting the latest state from origin.

## Hint 2

Press `f` in the **Files** panel to fetch. Then press `3` to go to the **Local Branches** panel. Select `main` and press `f` to fast-forward it. Now you need to rebase your feature branch onto the updated main.

## Hint 3

With `feature/logging` checked out, select `main` in the **Local Branches** panel and press `r` to rebase onto it. Lazygit replays your 2 commits on top of the latest main. Since the changes don't conflict, this should complete cleanly.

## Hint 4

After the rebase, press `P` to push. Since the rebase changed history, a regular push will fail. Lazygit will prompt you to force-push -- confirm it. This updates `origin/feature/logging` with your rebased branch.
