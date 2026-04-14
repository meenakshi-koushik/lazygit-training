## Hint 1

You need to switch to the review worktree, not create one -- it already exists. Look at the worktree-related keybindings in lazygit. You can access worktree operations from the Branches panel.

## Hint 2

Press `w` to open the **Worktrees** view. You should see two entries: the main worktree (your current one) and the review worktree. Select the review worktree and press `<space>` to switch to it. Lazygit will reload with the review worktree's context.

## Hint 3

Once in the review worktree, you need to edit `services/api/src/validation.py`. Press `2` to go to the Files panel -- you will not see any changes yet because the working tree is clean. You need to open the file in your editor to fix the TODO. You can find and edit the file by pressing `e` on it, or edit it outside lazygit in another terminal. Replace the `# TODO: add input length check` line with actual validation code like `if len(value) > MAX_LENGTH: raise ValueError("Input too long")`. After editing and saving, the file will appear as modified in lazygit. Stage it with `<space>` and commit with `c`.

## Hint 4

Full sequence: `w` (worktree view) -> select review worktree -> `<space>` (switch). Edit `services/api/src/validation.py` to replace the TODO with a real length check. Back in lazygit: `<space>` (stage the file) -> `c` (commit) -> type a message containing "fix" and "validation" -> `<enter>` (confirm). Then switch back: `w` -> select main worktree -> `<space>`.
