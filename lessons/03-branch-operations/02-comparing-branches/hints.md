## Hint 1

Start by exploring the **Branches** panel (press `2` or navigate to it with `]`/`[`). You should see both `feature/api-refactor` (your current branch) and `main`. Try selecting each branch to see what information lazygit shows you.

## Hint 2

To see the commits on a specific branch, select it in the Branches panel and press `<enter>`. This switches the Commits panel to show that branch's history. Compare the commit lists for `feature/api-refactor` and `main` to understand what each branch has that the other doesn't.

## Hint 3

To rebase your current branch onto `main`, go to the Branches panel and select `main`. Press `r` to rebase. Lazygit will ask you to confirm -- select "simple rebase". This replays your `feature/api-refactor` commits on top of `main`'s latest state.

## Hint 4

If the rebase completes without conflicts, you are done. Your `feature/api-refactor` branch now contains all of `main`'s commits plus your 3 feature commits on top. Verify with `./train.sh verify 3/2`.
