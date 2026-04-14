# Solution: Amending Commits

## Step 1 -- Open lazygit

```bash
cd sandbox/01-amending-commits
lazygit
```

Lazygit opens with the **Files** panel focused. You should see one modified file:
- `services/api/src/routes.py` (red `M` -- unstaged)

In the **Commits** panel on the right, the top commit reads:
```
feat(api): add input validaton
```

Note the typo: "validaton" instead of "validation".

## Step 2 -- Stage the forgotten file

1. In the **Files** panel, `services/api/src/routes.py` should already be selected.
2. Press `<space>` to stage it. The file moves to the staged section (green `M`).

## Step 3 -- Amend the last commit

1. With the file staged, press `A` (shift+a) to amend the last commit.
2. Lazygit shows a confirmation prompt asking if you want to amend the last commit. Select **yes** / press `<enter>`.

The staged file is now folded into the last commit. The Files panel should be empty -- no more modified files.

> **Git context:** This is equivalent to running `git commit --amend --no-edit`. Git creates a new commit containing all the changes from the original commit plus the newly staged `routes.py`, then moves the branch pointer to the new commit.

## Step 4 -- Reword the commit message

1. Switch to the **Commits** panel by pressing `2` (or cycle with `]`).
2. The top commit should be selected (HEAD). It still reads "feat(api): add input validaton".
3. Press `r` to reword the commit message.
4. An inline editor appears with the current message. Fix the typo: change `validaton` to `validation`.
5. Press `<enter>` to confirm.

The commit message now reads:
```
feat(api): add input validation
```

> **Git context:** Rewording runs `git commit --amend -m "new message"`. Again, this replaces the commit object. Since we already amended once in Step 3, this second amend replaces that intermediate commit. The end result is a single new commit containing both the added file and the corrected message.

## Step 5 -- Verify

Exit lazygit by pressing `q`, then verify your work:

```bash
cd ../..
./train.sh verify 4/1
```

All six checks should pass:
1. HEAD is on branch `feature/add-validation`.
2. The commit message contains "validation" (correct spelling).
3. The commit message does not contain the typo "validaton".
4. `services/api/src/routes.py` is included in the latest commit.
5. Working tree is clean.
6. Exactly 1 commit ahead of `exercise-start` (amended, not a new commit).
