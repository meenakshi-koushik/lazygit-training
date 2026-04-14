## Hint 1

There are two things to fix: a missing file in the last commit and a typo in its message. You can tackle them in either order, but it is easiest to add the missing file first.

## Hint 2

In the **Files** panel, you should see `services/api/src/routes.py` with unstaged changes (red `M`). Stage it by selecting it and pressing `<space>`. Then press `A` (shift+a) to amend the last commit -- lazygit will ask you to confirm. This adds the newly staged file into the existing commit.

## Hint 3

Now fix the typo. Switch to the **Commits** panel (press `4` or use `]`/`[` to cycle panels). Select the top commit (the one that says "feat(api): add input validaton"). Press `r` to reword the message. Correct "validaton" to "validation" and press `<enter>`.

## Hint 4

After both operations, the Files panel should be empty (clean working tree) and the top commit in the Commits panel should read "feat(api): add input validation". Verify with `./train.sh verify 4/1`.
