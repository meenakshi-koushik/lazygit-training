## Hint 1

Start by fetching from origin so lazygit knows about the teammate's branch. Then navigate to the remote branches to find `feature/metrics`.

## Hint 2

Press `f` in the Files panel (`2`) to fetch. Then press `3` to go to the Local Branches panel and use `]` to navigate to the **Remotes** tab. Expand `origin`, find `feature/metrics`, and press `<space>` to check it out locally.

## Hint 3

Now you are on `feature/metrics`. To see all changes relative to `main`, press `W` (global diffing options), select "diff against ref", and enter `main`. This shows you the full PR diff. Browse the files in the Files panel to review the changes. When done reviewing, press `W` again to exit diff mode, then switch back to `main` (press `3`, select `main`, press `<space>`).
