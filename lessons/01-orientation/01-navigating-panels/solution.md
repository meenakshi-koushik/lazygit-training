# Solution: Navigating Panels

## Step 1 -- Open lazygit

```bash
cd sandbox/01-navigating-panels
lazygit
```

Lazygit opens with the **Files** panel focused (panel 2). You should see several modified and untracked files listed on the left, and a diff preview on the right.

## Step 2 -- Explore the panels

Cycle through all five panels to understand the layout:

1. Press `1` to jump to the **Status** panel. The preview pane shows repo information.
2. Press `2` to jump to the **Files** panel. You'll see the modified and untracked files. Use `j`/`k` to scroll through them and watch the diff preview update on the right.
3. Press `3` to jump to the **Branches** panel. You'll see `main`, `feature/add-metrics`, and `fix/auth-timeout`. Scroll between them to see branch details in the preview pane.
4. Press `4` to jump to the **Commits** panel. Scroll through the ~16 commits with `j`/`k`. The preview pane shows each commit's diff.
5. Press `5` to jump to the **Stash** panel. It will be empty -- that's expected.

You can also use `<tab>` to cycle forward and `<shift+tab>` to cycle backward through panels.

> **Git context:** These panels map directly to `git status`, `git branch -a`, `git log`, and `git stash list`. Lazygit runs these commands in the background and presents the output in a navigable UI.

## Step 3 -- Create the `explore-panels` branch

1. Press `3` to go to the **Branches** panel.
2. Press `n` to create a new branch.
3. Type `explore-panels` and press `<enter>`.

You should see `explore-panels` appear at the top of the branch list with an asterisk or highlight indicating it's the current branch.

> **Git context:** This runs `git checkout -b explore-panels`.

## Step 4 -- Stage a file

1. Press `2` to go to the **Files** panel.
2. Use `j`/`k` to select any modified or untracked file (e.g., `services/api/src/routes.py`).
3. Press `<space>` to stage the selected file.

The file's indicator changes (from red/unstaged to green/staged). You can stage additional files if you like, but only one is required.

> **Git context:** This runs `git add <file>`.

## Step 5 -- Make a commit

1. While still in the **Files** panel, press `c` to open the commit message editor.
2. Type a message containing the word "explore", for example: `explore: test commit from lazygit`
3. Press `<enter>` to create the commit.

The staged files disappear from the Files panel (they're now committed). If you press `4` to go to the Commits panel, you'll see your new commit at the top of the log.

> **Git context:** This runs `git commit -m "explore: test commit from lazygit"`.

## Step 6 -- Verify

Exit lazygit by pressing `q`, then verify your work:

```bash
cd ../..
./train.sh verify 01-orientation/01-navigating-panels
```

All three checks should pass: branch exists, commit with "explore" found, and the lesson is complete.
