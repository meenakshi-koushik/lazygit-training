# Staging Individual Lines

```bash
lazygit -p sandbox/02-staging-lines
```

## Scenario

You are working on the `api` service in a platform monorepo. You just finished adding a new `cache_ttl` configuration option to `services/api/src/config.py`. During development, you also sprinkled in some `print("DEBUG: ...")` statements to troubleshoot a config-loading issue. The bug is fixed now, but you forgot to remove the debug prints before preparing your commit.

All of your changes -- both the legitimate feature code and the debug statements -- are in one continuous hunk, so you cannot use hunk-level staging to separate them. You need to use lazygit's **line-level staging** to stage only the feature lines while leaving the debug prints unstaged in your working tree.

## Objectives

1. Open lazygit in the sandbox repo and view the diff for `services/api/src/config.py`.
2. Use line-level staging to stage **only** the feature lines (the `cache_ttl` configuration).
3. Leave the `print("DEBUG: ...")` lines unstaged in the working tree.

After completing the objectives, the staged (index) version of the file should contain the `cache_ttl` feature code but no `DEBUG` lines. The working tree should still have the `DEBUG` lines present as unstaged changes.

## Key Concepts

- When a hunk contains a mix of changes you want and changes you don't, hunk-level staging is too coarse. Lazygit lets you drop into **line-staging mode** to select individual lines.
- In the diff view for a file, press `<tab>` to switch between the "hunk" selection mode and "line" selection mode. In line mode, you can use `j`/`k` (or arrow keys) to move through individual diff lines and press `<space>` to toggle staging on each line.
- Under the hood, this is equivalent to `git add -p` followed by manually editing the hunk (the `e` option in interactive staging), but lazygit makes it visual and immediate.

## Prerequisites

- [02-precision-staging/01-staging-hunks](../01-staging-hunks/) -- you should be comfortable with hunk-level staging in lazygit before moving to line-level staging.

## Verify

```bash
./train.sh verify 2/2
```
