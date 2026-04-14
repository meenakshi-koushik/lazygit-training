## Hint 1

You need to combine 4 WIP commits into one clean commit. You learned how to do this in Module 4 (Interactive Rebase: Squashing). Press `4` to go to the Commits panel and start an interactive rebase.

## Hint 2

In the **Commits** panel, select the oldest WIP commit ("WIP: start rate limiter") and press `e` to edit from that commit, or press `i` to start an interactive rebase. Then squash the commits above it by selecting each one and pressing `s` (squash). After squashing, you will be prompted to edit the commit message.

## Hint 3

After squashing, reword the commit message to start with `feat(api):` -- something like `feat(api): add rate limiting middleware with token bucket algorithm`. Make sure no "WIP" or "wip" text remains. Then press `P` to push the branch to origin. If prompted to set an upstream, confirm.

## Hint 4

If you have trouble with the interactive rebase approach, an alternative: navigate to the first commit in the series (the oldest WIP commit), press `s` on each of the commits above it one at a time to squash them down. Then press `r` on the remaining commit to reword it.
