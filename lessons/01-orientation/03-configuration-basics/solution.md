# Solution: Configuration Basics

## Step 1 -- Open lazygit in the sandbox repo

```
cd sandbox/03-configuration-basics && lazygit
```

You should see the Files panel with two modified files:
- `services/api/src/config.py`
- `services/worker/src/main.py`

## Step 2 -- Navigate to the Status panel

Press `1` or use `<tab>` to cycle panels until you reach the **Status panel** in the top-left corner. It shows the repo name and current branch.

> **Git context:** The Status panel is lazygit-specific -- it doesn't correspond to a git command. It provides access to lazygit configuration and repo-wide operations.

## Step 3 -- Open the lazygit configuration file

With the Status panel focused, press `o`. This opens the lazygit config file (`~/.config/lazygit/config.yml`) in your default editor.

Alternatively, press `e` to edit the config file directly inside lazygit.

Take a moment to browse the file. You'll see settings for keybindings, UI preferences, git behavior, and more. Close the editor when you're done.

> **Git context:** This has nothing to do with git -- it's purely lazygit configuration. The config file controls lazygit's behavior, appearance, and custom commands.

## Step 4 -- View the command log panel

Press `@` anywhere in lazygit. The **command log panel** appears at the bottom of the screen, showing recent git commands that lazygit has executed.

Press `@` again to expand the panel, and once more to hide it. The panel cycles through three states:

1. **Hidden** -- no command log visible
2. **Small** -- a compact strip at the bottom showing the last few commands
3. **Expanded** -- a larger panel showing more command history

> **Git context:** Every action you take in lazygit translates to one or more git commands. The command log shows these commands in real time. For example, staging a file runs `git add <file>`, and switching branches runs `git checkout <branch>`.

## Step 5 -- Stage all modified files

Navigate to the **Files panel** by pressing `2` or using `<tab>`. You should see the two modified files.

Press `a` to stage all files at once. Both files should move to the staged state (they will appear green or with a staging indicator).

> **Git context:** This runs `git add -A` to stage all changes.

## Step 6 -- Commit with "config" in the message

Press `c` to open the commit message dialog. Type a message that includes the word "config", for example:

```
chore: explore config and command log
```

Press `<enter>` to create the commit.

> **Git context:** This runs `git commit -m "chore: explore config and command log"`.

## Step 7 -- Confirm a clean working tree

After committing, the Files panel should be empty (no modified, staged, or untracked files). This confirms all changes have been committed and the working tree is clean.

If you have the command log panel visible, you should see the `git commit` command that just ran.

## Verify

Exit lazygit with `q`, then run:

```
./train.sh verify 01-orientation/03-configuration-basics
```

Both checks should pass:
1. A commit with "config" in the message exists.
2. The working tree is clean.
