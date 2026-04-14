# Patch Operations

```bash
lazygit -p sandbox/03-patch-operations
```

## Scenario

You are on the `feature/logging` branch in the platform monorepo, tasked with adding structured logging across several services. A colleague on `feature/refactor` recently landed a large refactor commit that touched five files -- it reorganized config patterns, updated error handling, **and** added logging throughout the codebase. You only want the logging changes, not the config restructuring.

Rather than cherry-picking the entire commit (which would bring unwanted config changes), you need to use lazygit's custom patch feature to extract just the logging-related file changes from that commit and apply them to your branch.

The big refactor commit (tagged `big-refactor`) modified:

| File | Change | You want it? |
|------|--------|:---:|
| `services/api/src/routes.py` | Added logging imports and log statements | Yes |
| `services/api/src/config.py` | Restructured config loading pattern | No |
| `services/worker/src/main.py` | Added logging imports and log statements | Yes |
| `libs/common/src/common.py` | Added a logging utility function | Yes |
| `services/api/tests/test_routes.py` | Updated tests for new config pattern | No |

## Objectives

1. Navigate to the `big-refactor` commit on the `feature/refactor` branch.
2. Build a custom patch containing only the three logging-related files (`routes.py`, `main.py`, `common.py`).
3. Apply the custom patch to your working tree on `feature/logging`.
4. Stage and commit the changes with a descriptive message.
5. End on `feature/logging` with a clean working tree and exactly 1 new commit.

## Key Concepts

Lazygit's **custom patch** feature lets you select specific files (or even specific lines within files) from any commit and apply them as a patch. This is more surgical than cherry-pick, which always takes the entire commit.

The workflow:

1. **Browse to the commit** -- navigate to the branch/commit containing the changes you want.
2. **Enter the commit's file list** -- press `<enter>` on the commit to see which files it changed.
3. **Select files for the patch** -- press `<space>` to toggle individual files into your custom patch. Selected files get highlighted.
4. **Apply the patch** -- press `<c-p>` (Ctrl+P) to open the custom patch options menu, then choose "apply patch" to bring those changes into your working tree.
5. **Commit the result** -- the applied changes appear as unstaged modifications, ready to stage and commit.

Under the hood, lazygit constructs a `git diff` for only the selected files and applies it with `git apply`. This is equivalent to manually running `git diff <commit>^..<commit> -- <file1> <file2> | git apply`, but without the error-prone command construction.

## Prerequisites

- Module 1 (01-orientation) -- navigating panels, staging, and committing.
- Module 3, Lesson 1 -- branch navigation.
- Module 7, Lesson 1 -- cherry-pick basics (understanding why cherry-pick is sometimes too coarse).

## Verify

```bash
./train.sh verify 7/3
```
