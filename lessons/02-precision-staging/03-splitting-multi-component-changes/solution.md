# Solution: Splitting Multi-Component Changes

## Step 1: Open lazygit and review the modified files

Open lazygit in the sandbox repo:

```
cd sandbox/03-splitting-multi-component-changes && lazygit
```

You land on the **Files panel** (panel 2). You should see 5 modified files, all unstaged:

```
services/api/src/routes.py
services/api/src/config.py
services/worker/src/main.py
services/worker/src/config.py
libs/common/src/common.py
```

## Step 2: Stage and commit the API service changes

Use `j`/`k` to navigate to `services/api/src/routes.py` and press `<space>` to stage it. The file moves to the "staged changes" section.

Navigate to `services/api/src/config.py` and press `<space>` to stage it as well.

Now press `c` to open the commit message editor. Type:

```
feat(api): add rate limiting configuration and middleware
```

Press `<enter>` to create the commit.

The two api files disappear from the Files panel. The remaining 3 files are still unstaged.

> **Git context**: This is equivalent to `git add services/api/src/routes.py services/api/src/config.py && git commit -m "feat(api): add rate limiting configuration and middleware"`.

## Step 3: Stage and commit the Worker service changes

Navigate to `services/worker/src/main.py` and press `<space>` to stage it.

Navigate to `services/worker/src/config.py` and press `<space>` to stage it.

Press `c` to open the commit message editor. Type:

```
feat(worker): add rate limiting for job processing
```

Press `<enter>` to create the commit.

> **Git context**: Same as before -- `git add` the two worker files, then `git commit`.

## Step 4: Stage and commit the shared library changes

Only one file remains: `libs/common/src/common.py`. Navigate to it and press `<space>` to stage it.

Press `c` to open the commit message editor. Type:

```
feat(libs/common): add shared RateLimiter class
```

Press `<enter>` to create the commit.

The Files panel should now be empty -- all changes have been committed.

> **Git context**: The final `git add libs/common/src/common.py && git commit` completes the split.

## Step 5: Verify

Press `q` to exit lazygit, then run:

```
./train.sh verify 02-precision-staging/03-splitting-multi-component-changes
```

All checks should pass: working tree is clean, exactly 3 new commits exist, and each commit message references the correct component.
