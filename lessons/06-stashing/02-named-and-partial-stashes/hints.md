## Hint 1

You need to stash the API and worker changes separately -- not all at once. Think about how you can stash only specific files. Lazygit has a command prompt (`:`) that lets you run git commands directly.

## Hint 2

To stash only certain files, press `:` in lazygit to open the command prompt and run: `git stash push -m "api notification changes" -- services/api/src/notifications.py services/api/src/config.py`. This stashes only those two files with a descriptive name.

## Hint 3

After stashing the API files, only the two worker files remain. Press `S` (shift+s) in the **Files** panel and choose **stash all changes**. Enter `worker notification changes` as the message. Now check the **Stash** panel (`5`) -- you should see both named entries.

## Hint 4

To restore only the worker changes, go to the **Stash** panel (`5`). The worker stash should be at `stash@{0}` (most recent). Select it and press `g` to **pop** it -- this applies the changes and removes the stash entry. The API stash should remain in the list.
