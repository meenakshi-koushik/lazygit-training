## Hint 1

The commits panel in lazygit shows your branch history. You need to physically rearrange the commits so they appear in a different order. Look for keybindings that let you move a commit up or down.

## Hint 2

Select a commit in the **Commits** panel and press `<ctrl+j>` to move it down (earlier in history) or `<ctrl+k>` to move it up (later in history). Each move triggers a small rebase behind the scenes. Start by moving the "implement cache layer" commit to the bottom of the branch (the oldest position).

## Hint 3

In the Commits panel, the most recent commit is at the top and the oldest is at the bottom. The current (wrong) order from top to bottom is:

1. `feat(api): add cache invalidation` (top / newest)
2. `chore: update config for cache`
3. `feat(api): implement cache layer`
4. `test(api): add cache tests` (bottom / oldest)

You need to reach this order (top to bottom):

1. `chore: update config for cache` (top / newest)
2. `feat(api): add cache invalidation`
3. `test(api): add cache tests`
4. `feat(api): implement cache layer` (bottom / oldest)

Select the "implement cache layer" commit and press `<ctrl+j>` once to move it below "add cache tests". Then select "chore: update config for cache" and press `<ctrl+k>` twice to move it to the top.
