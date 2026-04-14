## Hint 1

The bisect workflow is driven entirely from the Commits panel. Press `4` to get there, then look for the `b` keybinding. You need to find the commit tagged `last-known-good` and start the process from there.

## Hint 2

Navigate to the commit tagged `last-known-good` in the Commits panel and press `b`. Select the option to mark it as good (this also starts the bisect session). Then navigate to HEAD and press `b` to mark it as bad. Lazygit will check out a commit in the middle for you to test.

## Hint 3

To test each commit during bisect, check the content of `services/api/src/routes.py`. You can view files by pressing `<enter>` on a commit in the Commits panel to see its changes, or press `2` to go to the Files panel and look at the current state. If the file contains `"healthy"`, the commit is good. If it contains `"unhealthy"`, the commit is bad. Press `b` in the Commits panel and mark accordingly.

## Hint 4

After bisect identifies the culprit commit, you need to tag it. In the Commits panel (`4`), navigate to the identified bad commit and press `T` to create a tag. Enter `bisect-found` as the tag name. Then press `b` and select "reset bisect" to end the session. This returns you to `main` at the original HEAD.
