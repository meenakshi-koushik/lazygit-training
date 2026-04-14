## Hint 1

You need to get the unstaged change into the right commit -- not the latest one. Look at the changes first: the modification in `services/api/src/token.py` adds input sanitization to `validate_token`. That logic was introduced in the second commit. Lazygit has a dedicated workflow for fixing older commits without manual interactive rebase.

## Hint 2

First, stage the fix. In the **Files** panel, select `services/api/src/token.py` and press `<space>` to stage it. Now switch to the **Commits** panel (press `4` or navigate with `]`/`[`). You need to select the commit this fix belongs to -- "feat(api): implement token validation" (the second one from the top).

## Hint 3

With the target commit selected in the Commits panel, press `F` (shift+f) to create a **fixup commit**. You should see a new commit appear at the top with the message `fixup! feat(api): implement token validation`. Now press `S` (shift+s) to squash all fixup commits above into their targets. Lazygit will run an auto-squash rebase and fold the fixup into the original commit.

## Hint 4

If the auto-squash prompt asks you to confirm, select the option to squash. After the rebase completes, you should be back to exactly 3 commits on your branch, with the fix folded into the "implement token validation" commit. Verify with `./train.sh verify 4/4`.
