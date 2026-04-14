## Hint 1

You need to combine 5 commits into 2. Look at the **Commits** panel in lazygit -- it lists all commits on your branch. Think about which commits logically belong together and should be merged into a single commit.

## Hint 2

In the **Commits** panel, select a commit and press `s` to **squash** it into the commit below it (its parent). This combines the two commits, merging their changes. You can also press `f` for **fixup**, which is like squash but discards the message of the squashed commit entirely.

## Hint 3

One approach: work from the top of the commit list downward. Select the "cleanup" commit and press `s` or `f` to squash it into "oops forgot file". Keep squashing until you have the two groups you want. After squashing, select each resulting commit and press `r` to **reword** it with a clean message like `feat(api): add rate limiting middleware` and `test(api): add rate limiter tests`.

## Hint 4

Here is one concrete path: in the Commits panel, select the topmost commit ("cleanup"). Press `f` to fixup into "oops forgot file". Now select what is now the top commit ("oops forgot file" with the cleanup changes absorbed). Press `f` again to fixup into "fix typo". You now have 3 commits. Fixup "fix typo" (now containing the test file and cleanup) into "wip more stuff". You now have 2 commits. Press `r` on each to reword them with clean messages. Make sure neither message contains "WIP", "wip", "oops", or "typo".
