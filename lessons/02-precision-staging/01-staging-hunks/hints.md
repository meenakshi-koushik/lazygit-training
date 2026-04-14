## Hint 1

Don't stage the entire file -- you need to go *inside* the file's diff to work with individual hunks. Look for a way to open the diff view for a file in the Files panel.

## Hint 2

In the **Files** panel, pressing `<space>` stages the whole file. Instead, press `<enter>` on `services/api/src/routes.py` to open its diff view. You should see two separate hunks (blocks of changes), each starting with an `@@` header line.

## Hint 3

With the diff view open, your cursor should be on the first hunk (the `import logging` / `logger` changes near the top). Press `<space>` to stage just that hunk. The first hunk turns green (staged) while the second hunk (the new `/metrics` route) stays red (unstaged). Press `<esc>` to go back to the file list.

## Hint 4

Make sure you did NOT accidentally stage `services/worker/src/main.py`. If it shows as staged (green), select it in the Files panel and press `<space>` to unstage it.
