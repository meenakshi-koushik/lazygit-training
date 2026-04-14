# Solution: Reordering and Editing Commits

## Step 1 -- Open lazygit

```bash
cd sandbox/03-reordering-and-editing-commits
lazygit
```

Lazygit opens with the **Files** panel focused. There should be nothing in the working tree since all changes are committed.

## Step 2 -- Navigate to the Commits panel

Press `4` (or use `]` to cycle panels) to switch to the **Commits** panel.

You should see the four commits on `feature/caching` listed from newest (top) to oldest (bottom):

```
feat(api): add cache invalidation      <- top (newest / HEAD)
chore: update config for cache
feat(api): implement cache layer
test(api): add cache tests             <- bottom (oldest)
```

The goal is to rearrange them to:

```
chore: update config for cache          <- top (newest / HEAD)
feat(api): add cache invalidation
test(api): add cache tests
feat(api): implement cache layer        <- bottom (oldest)
```

## Step 3 -- Move "implement cache layer" to the bottom

1. Use `j`/`k` to select the `feat(api): implement cache layer` commit (currently 3rd from top).
2. Press `<ctrl+j>` once to move it down (earlier in history).

It swaps with `test(api): add cache tests` and is now the oldest commit on the branch. The order is now:

```
feat(api): add cache invalidation
chore: update config for cache
test(api): add cache tests
feat(api): implement cache layer        <- oldest
```

> **Git context:** Lazygit performed a `git rebase -i` behind the scenes, reordering the pick lines so "implement cache layer" comes first chronologically.

## Step 4 -- Move "chore: update config for cache" to the top

1. Select the `chore: update config for cache` commit (currently 2nd from top).
2. Press `<ctrl+k>` once to move it up (later in history), making it the newest commit at the top.

The order is now:

```
chore: update config for cache          <- newest (HEAD)
feat(api): add cache invalidation
test(api): add cache tests
feat(api): implement cache layer        <- oldest
```

> **Git context:** Another `git rebase -i` was executed, moving the config commit to the end of the rebase sequence (making it the most recent commit).

## Step 5 -- Verify the order

Review the Commits panel from top to bottom. It should read:

1. `chore: update config for cache` (HEAD)
2. `feat(api): add cache invalidation`
3. `test(api): add cache tests`
4. `feat(api): implement cache layer`

This tells a clean story: implement the feature, add tests, extend with invalidation, then configure.

## Step 6 -- Exit and verify

Press `q` to exit lazygit, then verify:

```bash
cd ../..
./train.sh verify 4/3
```

All checks should pass:
1. HEAD is on `feature/caching`.
2. Exactly 4 commits ahead of `exercise-start`.
3. The oldest commit message contains "implement cache layer".
4. The 3rd from HEAD contains "cache tests".
5. The 2nd from HEAD contains "cache invalidation".
6. HEAD commit message contains "config".
7. Working tree is clean.
