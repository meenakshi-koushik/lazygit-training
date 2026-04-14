# Hints

## Hint 1

Look at the Files panel (panel 2). You should see 5 modified files spanning three directories: `services/api/`, `services/worker/`, and `libs/common/`. Your goal is to commit them in three separate groups. Start with one component -- pick whichever you like.

## Hint 2

Use `j`/`k` to move through the file list and `<space>` to stage individual files. Stage the two `services/api/` files first. Notice the files move from the "unstaged" section to the "staged" section. Once only the api files are staged, press `c` to commit.

## Hint 3

In the commit message editor, type something like `feat(api): add rate limiting support` (the message must contain "api"). Press `<enter>` to confirm the commit. The api files disappear from the list. Now repeat: stage the two `services/worker/` files with `<space>`, press `c`, write a message containing "worker", and confirm. Finally, do the same for the `libs/common/` file with a message containing "common" or "libs".

## Hint 4

After all three commits, the Files panel should be empty (no modified files). If you accidentally staged the wrong file, you can press `<space>` again on a staged file to unstage it before committing.
