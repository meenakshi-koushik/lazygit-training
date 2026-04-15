# Solution: Bisecting Regressions

## Step 1 -- Open lazygit

```bash
lazygit -p sandbox/02-bisecting-regressions
```

Lazygit opens on the `main` branch. The Files panel is empty (clean working tree).

## Step 2 -- Examine the regression

Before starting bisect, confirm the bug exists. Press `4` to go to the **Commits** panel. You should see about 14 commits. HEAD is the most recent commit. The `last-known-good` tag is visible several commits down the list.

You can verify the current state by opening a terminal and checking:
```
cat sandbox/02-bisecting-regressions/services/api/src/routes.py
```
The health endpoint currently returns `"unhealthy"` -- this is the regression.

## Step 3 -- Start the bisect session

1. Press `4` to go to the **Commits** panel (if not already there).
2. Navigate down to the commit tagged `last-known-good` using `j`/`k`. You will see the tag displayed next to the commit message.
3. Press `b` to open the bisect options menu.
4. Select **"mark current commit as good"** (or **"bisect start"** followed by marking as good, depending on your lazygit version). This tells git that this commit is known to be working.

> **Git context:** This runs `git bisect start` (if not already started) and `git bisect good <commit>`.

## Step 4 -- Mark HEAD as bad

After marking the good boundary, lazygit needs to know the bad boundary:

1. Navigate to the top of the commit list (the most recent commit / HEAD). Press `g` then `g` to jump to the top, or use `k` to move up.
2. Press `b` to open the bisect options menu.
3. Select **"mark current commit as bad"**.

> **Git context:** This runs `git bisect bad HEAD`. Git now knows the regression was introduced somewhere between the good and bad commits. It checks out the midpoint commit for you to test.

## Step 5 -- Test the midpoint and continue bisecting

Lazygit has now checked out a commit in the middle of the range. You need to determine if this commit is good or bad:

1. Open a terminal (or use lazygit's file browser) to check the content of `services/api/src/routes.py`. You can press `` ` `` to open a shell within lazygit, then run:
   ```
   grep "status" services/api/src/routes.py
   ```
   - If it shows `"healthy"` -- this commit is **good**.
   - If it shows `"unhealthy"` -- this commit is **bad**.
2. Return to lazygit (type `exit` if you opened a shell).
3. Press `4` to go back to the Commits panel.
4. Press `b` and select either **"mark current commit as good"** or **"mark current commit as bad"** based on what you found.

Git will check out the next midpoint. Repeat this process: check the file, mark good or bad, check the next midpoint.

You will need approximately 3-4 iterations. Each time:
- Check `services/api/src/routes.py` for `"healthy"` vs `"unhealthy"`.
- Mark the commit accordingly with `b` in the Commits panel.

The typical bisect path for this exercise:
1. First midpoint lands in the middle of the range -- the file shows `"healthy"` -- mark **good**.
2. The range narrows to the upper half. Next midpoint -- still `"healthy"` -- mark **good**.
3. Range narrows again. Next midpoint -- the file shows `"unhealthy"` -- mark **bad**.
4. One final midpoint and git identifies the first bad commit.

## Step 6 -- Bisect completes

After enough iterations, git bisect will identify the first bad commit. Lazygit will display a message indicating which commit introduced the regression. The culprit is the commit with message:

```
refactor(api): update health endpoint response format
```

This is the commit that changed the health endpoint from `"healthy"` to `"unhealthy"`.

## Step 7 -- Tag the culprit commit

1. In the **Commits** panel (`4`), navigate to the identified bad commit (the one with message "refactor(api): update health endpoint response format").
2. Press `T` to create a new tag.
3. Type `bisect-found` and press `<enter>`.

> **Git context:** This runs `git tag bisect-found <commit-hash>`.

## Step 8 -- Reset the bisect session

1. Press `b` in the Commits panel to open the bisect options menu.
2. Select **"reset bisect"**.

This ends the bisect session and returns you to the `main` branch at the original HEAD.

> **Git context:** This runs `git bisect reset`, which checks out the branch you were on before bisect started.

## Step 9 -- Verify

Exit lazygit by pressing `q`, then verify your work:

```bash
./train.sh verify 7/2
```

All checks should pass:
1. On branch `main`.
2. Working tree is clean.
3. No active bisect session.
4. Tag `bisect-found` exists.
5. Tag `bisect-found` points to the correct culprit commit.
