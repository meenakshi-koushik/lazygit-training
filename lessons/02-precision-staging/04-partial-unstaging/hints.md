## Hint 1

Look at the Files panel. All your changes are currently staged (shown with a green "M" or similar indicator). You need to find the worker files and move them out of the staging area. Remember that the same key you use to stage a file can also unstage it.

## Hint 2

In the Files panel, navigate to the files under `services/worker/`. With a staged file highlighted, press `<space>` to unstage it. The file moves from "Staged Changes" back to "Unstaged Changes". Do this for each worker file.

## Hint 3

Navigate to `services/worker/src/main.py` in the Files panel and press `<space>` to unstage it. Then navigate to `services/worker/src/config.py` and press `<space>` to unstage it. After this, only the `services/api/` files should remain staged. You can confirm by checking that the API files show as staged (green) and the worker files show as unstaged (red).
