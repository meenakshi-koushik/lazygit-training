# Hints

## Hint 1

Start by selecting `services/api/src/config.py` in the Files panel. Look at the diff on the right side -- you will see the added feature lines and the debug print statements all mixed together in one hunk. Since they are in a single hunk, pressing `<space>` on the file or hunk would stage everything. You need a finer tool.

## Hint 2

With the file selected and the diff visible, press `<tab>` to switch from hunk-selection mode to **line-selection mode**. The selection highlight should change from covering the whole hunk to just a single line. Now you can navigate with `j`/`k` through individual lines in the diff.

## Hint 3

In line-selection mode, move to each green `+` line that is part of the feature (the `cache_ttl`, `cache_backend`, and `cache_url` lines). Press `<space>` on each feature line to stage it. **Skip** the lines that contain `print("DEBUG: ...")` -- do not press `<space>` on those. When you are done, the staged changes panel should show the feature lines and the unstaged panel should show only the debug prints.
