## Hint 1

All branch operations happen in the **Branches** panel. Make sure you navigate there first -- you can press `3` or use `]`/`[` to cycle panels.

## Hint 2

To create a new branch, press `n` while in the Branches panel. Type the branch name (e.g., `feature/search-api`) and press `<enter>`. Lazygit will create the branch and check it out automatically.

## Hint 3

You need to make a commit on `feature/search-api` before switching away. Go to the Files panel (`1`), edit any file (or use the terminal), stage changes with `<space>`, and commit with `c`. Even a one-line change is enough.

To switch back to `main`, go to the Branches panel (`3`), select `main`, and press `<space>`.

## Hint 4

After switching to `main`, press `n` again to create `hotfix/config-typo`. You should end up on `hotfix/config-typo` when you are done -- lazygit checks out new branches automatically, so creating it is enough.
