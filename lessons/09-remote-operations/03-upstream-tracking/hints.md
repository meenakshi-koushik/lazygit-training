## Hint 1

You have two tasks: check out a remote branch locally, and push a local branch with upstream tracking. Both can be done from the Branches panel (`3`). Look for the remote branches tab and the upstream options.

## Hint 2

To check out `feature/search`: press `3` to go to the Local Branches panel, then press `]` to switch to the **Remotes** tab. Expand `origin` with `<enter>`, find `feature/search`, and press `<space>` to check it out. This automatically creates a local tracking branch.

## Hint 3

To push `feature/caching` with upstream tracking: go back to the Local Branches panel (`3`, then `[` to go to the Local Branches tab). Check out `feature/caching` by pressing `<space>` on it. Then press `P` to push. Lazygit will prompt you to set an upstream -- confirm with `<enter>`. This pushes and sets the tracking relationship.

## Hint 4

If you already pushed but the upstream was not set, select `feature/caching` in the Local Branches panel and press `u` to view upstream options. Select "set upstream" and choose `origin/feature/caching`.
