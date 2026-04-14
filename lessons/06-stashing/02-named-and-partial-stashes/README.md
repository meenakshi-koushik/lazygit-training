# Named and Partial Stashes

```bash
lazygit -p sandbox/02-named-and-partial-stashes
```

## Scenario

You are working on `feature/notifications` in the platform monorepo. You have been making changes across two services simultaneously -- the API service and the worker service -- to build out a notification system. You have 4 unstaged modified files:

- `services/api/src/notifications.py` -- notification dispatch logic
- `services/api/src/config.py` -- API notification settings
- `services/worker/src/queue.py` -- notification queue processor
- `services/worker/src/config.py` -- worker queue configuration

Your team lead asks you to context-switch and review a PR, but you want to stash your work in an organized way rather than dumping everything into a single unnamed stash. You decide to create two separate named stashes -- one for each service -- so you can restore them independently later.

## Objectives

1. Stash only the two API service files with the message `api notification changes`.
2. Stash the remaining worker service changes with the message `worker notification changes`.
3. Verify both named stashes appear in the Stash panel.
4. Pop the worker stash (`stash@{0}`) to restore only the worker changes to your working tree.
5. End on `feature/notifications` with the worker changes restored and the API stash still saved.

## Key Concepts

By default, `git stash` grabs everything and gives it a generic name like `WIP on feature/notifications`. This is fine for a quick context switch, but when you are juggling multiple concerns, named and partial stashes keep things organized.

Lazygit gives you fine-grained stash control through the **stash options menu** (`S` in the Files panel). This menu lets you choose what to stash:

- **Stash all changes** -- everything (staged + unstaged + untracked)
- **Stash staged changes** -- only what is in the staging area (requires git 2.35+)
- **Stash unstaged changes** -- only modifications not yet staged

Each option prompts for a stash message, so you can label your stashes with descriptive names.

For **path-based partial stashing**, you can use lazygit's command-line integration. Press `:` (or the custom command key) to open a shell prompt and run `git stash push -m "message" -- path1 path2`. This lets you stash specific files regardless of their staged/unstaged state.

In the **Stash** panel (press `5`), you can manage stash entries:

- `<space>` -- apply a stash (keeps the entry)
- `g` -- pop a stash (applies and removes the entry)
- `d` -- drop a stash (removes without applying)
- `r` -- rename a stash entry

## Prerequisites

- Module 6, Lesson 1 (Basic Stash Operations) -- basic stash/pop workflow.

## Verify

```bash
./train.sh verify 6/2
```
