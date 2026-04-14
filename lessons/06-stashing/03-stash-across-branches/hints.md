## Hint 1

Start by shelving your in-progress work before doing anything with branches. Look at the Files panel -- there is a keybinding that stashes everything at once.

## Hint 2

In the Files panel (`2`), press `s` to stash all changes. Lazygit will prompt you for a stash message -- type something descriptive like `cache layer WIP` and press `<enter>`. Your working tree should be clean afterwards.

## Hint 3

Now create the feature branch. Go to the Branches panel (`3`) and press `n` to create a new branch. Name it `feature/cache-layer` and press `<enter>`. Lazygit checks it out automatically.

To get your changes back, go to the Stash panel (`5`), select your stash entry, and press `g` to pop it. The files reappear as unstaged modifications.

## Hint 4

After popping the stash, go to the Files panel (`2`). Stage all three files by selecting each and pressing `<space>` (or press `a` to stage all). Then press `c` to commit. Write a message like `feat(api): add cache layer` and press `<enter>`. Your working tree should now be clean, with one commit ahead of `main` and no stash entries left.
