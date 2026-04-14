# Solution: Staging Individual Lines

## Step 1: Open lazygit and view the diff

Open lazygit in the sandbox repo:

```
cd sandbox/02-staging-lines && lazygit
```

You land on the **Files** panel. You should see `services/api/src/config.py` listed with modifications (marked with `M`). Select it with `j`/`k` if it is not already highlighted.

On the right side, the diff pane shows all the changes in one hunk. You will see a mix of added lines (`+` prefix, usually green):

- `print("DEBUG: loading config values from environment")` -- debug, do NOT stage
- `self.cache_ttl = int(os.environ.get("CACHE_TTL", 300))` -- feature, stage this
- `print("DEBUG: cache_ttl =", self.cache_ttl)` -- debug, do NOT stage
- `self.cache_backend = os.environ.get("CACHE_BACKEND", "redis")` -- feature, stage this
- `self.cache_url = os.environ.get("CACHE_URL", "redis://localhost:6379/0")` -- feature, stage this
- `print("DEBUG: finished loading all config")` -- debug, do NOT stage

## Step 2: Switch to line-staging mode

With the diff visible, press `a`. This switches from hunk selection to **line selection**. You should see the highlight narrow to a single line in the diff instead of the entire hunk.

## Step 3: Stage only the feature lines

Use `j`/`k` to navigate through the added lines in the diff. For each line:

- **`self.cache_ttl = ...`**: press `<space>` to stage it.
- **`self.cache_backend = ...`**: press `<space>` to stage it.
- **`self.cache_url = ...`**: press `<space>` to stage it.
- **Any `print("DEBUG: ...")`**: skip it -- do not press `<space>`.

After staging the three feature lines, the file should appear in both the "Staged changes" section (with the feature lines) and the "Unstaged changes" section (with the debug lines).

> **Git context**: Under the hood, lazygit is doing the equivalent of `git add -p` with manual hunk editing (`e` option). It splits the hunk and constructs a patch that stages only the selected lines. The index (staging area) receives the feature lines, while the working tree retains all lines including the debug prints.

## Step 4: Verify your work

You can confirm in lazygit by switching between the staged and unstaged views:

- Select the file in the staged changes section -- the diff should show only the `cache_ttl`, `cache_backend`, and `cache_url` lines.
- Select the file in the unstaged changes section -- the diff should show only the `print("DEBUG: ...")` lines.

Press `q` to exit lazygit, then run:

```
./train.sh verify 02-precision-staging/02-staging-lines
```

All checks should pass: the file is staged, the staged version has no `DEBUG` lines, and the working tree still contains them.
