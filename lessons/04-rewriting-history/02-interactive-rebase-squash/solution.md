# Solution: Interactive Rebase -- Squashing Commits

## Step 1 -- Open lazygit

```bash
lazygit -p sandbox/02-interactive-rebase-squash
```

Lazygit opens with the **Files** panel focused. Press `3` or navigate to the **Commits** panel. You should see 5 commits on `feature/rate-limiting` above the main branch history:

```
cleanup
oops forgot file
fix typo
wip more stuff
WIP: starting rate limiter
```

The goal is to squash these into 2 clean commits. A logical split: the first commit covers the rate limiter implementation (commits 1-3: the initial code, the methods, and the typo fix), and the second covers the test file and final polish (commits 4-5).

## Step 2 -- Squash the top commits down

We will work from top to bottom, using fixup (`f`) to absorb commits into their parents without editing messages (we will reword at the end).

1. Select the **"cleanup"** commit (the topmost one in the list).
2. Press `f` to fixup -- this absorbs "cleanup" into "oops forgot file" below it, discarding the "cleanup" message.

You now see 4 commits:

```
oops forgot file
fix typo
wip more stuff
WIP: starting rate limiter
```

3. Select **"oops forgot file"** (now at the top).
4. Press `f` -- this absorbs it into "fix typo".

You now see 3 commits:

```
fix typo
wip more stuff
WIP: starting rate limiter
```

5. Select **"fix typo"** (at the top).
6. Press `f` -- this absorbs it into "wip more stuff".

You now see 2 commits:

```
wip more stuff
WIP: starting rate limiter
```

> **Git context:** Each fixup operation triggers a `git rebase -i` under the hood. Lazygit marks the selected commit with the `fixup` command in the rebase TODO, which combines its changes into the parent commit while discarding its message.

## Step 3 -- Reword the commits

Both remaining commits still have messy messages. Select each one and press `r` to reword:

1. Select **"wip more stuff"** (top commit -- this contains the test file, cleanup, and polish changes).
2. Press `r` -- an editor opens with the commit message. Replace it with something clean, e.g.:

   ```
   test(api): add rate limiter tests and polish implementation
   ```

3. Save and close the editor (in the lazygit inline editor, just type the new message and press `<enter>`).

4. Select **"WIP: starting rate limiter"** (bottom commit -- the core rate limiter code).
5. Press `r` and replace the message with:

   ```
   feat(api): add rate limiting middleware
   ```

6. Save and close.

Your Commits panel should now show:

```
test(api): add rate limiter tests and polish implementation
feat(api): add rate limiting middleware
```

> **Git context:** Rewording uses `git rebase -i` with the `reword` command. It changes only the commit message, not the commit's content.

## Step 4 -- Verify

Exit lazygit by pressing `q`, then verify:

```bash
./train.sh verify 4/2
```

All checks should pass:
1. You are on branch `feature/rate-limiting`.
2. HEAD is exactly 2 commits ahead of `exercise-start`.
3. No commit messages contain "WIP", "wip", "oops", or "typo".
4. Both `rate_limiter.py` and `test_rate_limiter.py` still exist.
5. Working tree is clean.
