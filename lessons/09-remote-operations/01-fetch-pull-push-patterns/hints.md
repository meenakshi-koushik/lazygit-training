## Hint 1

You need three operations: fetch, fast-forward, and push. All three are available from within lazygit without running any git commands manually. Start by making sure lazygit knows about the latest remote state.

## Hint 2

Press `f` in the **Files** panel (`2`) to fetch from all remotes. After fetching, switch to the **Local Branches** panel (`3`). You should see that `main` is behind `origin/main`. Select `main` and press `f` to fast-forward it without checking it out.

## Hint 3

Now you need to push your feature branch. Make sure you are on `feature/notifications` (you should already be). Press `P` (uppercase) to push. If lazygit asks you to set an upstream, confirm with `<enter>`. Your 3 commits will be sent to origin.
