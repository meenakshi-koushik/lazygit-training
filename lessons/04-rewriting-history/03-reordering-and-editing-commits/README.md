# Reordering and Editing Commits

```bash
lazygit -p sandbox/03-reordering-and-editing-commits
```

## Scenario

You are working on a `feature/caching` branch in the platform monorepo. You have made four commits to add a caching layer to the API service, but the commits ended up in the wrong logical order -- the test commit landed before the implementation it tests, and a config change is sandwiched between unrelated code changes. Before opening a pull request, you need to reorder the commits so they tell a clean story: implementation first, then tests, then the next feature increment, then config.

The current commit order (oldest to newest) is:

1. `test(api): add cache tests` -- adds tests for a cache module that does not exist yet
2. `feat(api): implement cache layer` -- adds the actual cache module
3. `chore: update config for cache` -- updates settings
4. `feat(api): add cache invalidation` -- extends the cache module

The correct order should be:

1. `feat(api): implement cache layer`
2. `test(api): add cache tests`
3. `feat(api): add cache invalidation`
4. `chore: update config for cache`

## Objectives

1. Reorder the commits on `feature/caching` so they appear in the correct logical order listed above.
2. Keep all four commits intact -- do not squash, drop, or rename any of them.
3. Stay on the `feature/caching` branch.
4. End with a clean working tree.

## Key Concepts

- In the **Commits** panel, you can move a commit up or down in history using `<ctrl+j>` (move down / earlier in history) and `<ctrl+k>` (move up / later in history).
- Each move is an individual rebase operation under the hood. Lazygit performs a `git rebase -i` with the lines reordered for you.
- If two commits touch the same lines of the same file, reordering them may produce a conflict. In this exercise the commits touch different files or only append content, so reordering should be conflict-free.
- This is the lazygit equivalent of opening `git rebase -i` and rearranging the `pick` lines in your editor.

## Prerequisites

- Module 4, Lesson 2 (Interactive Rebase / Squash) -- familiarity with the Commits panel and basic rebase operations.

## Verify

```bash
./train.sh verify 4/3
```
