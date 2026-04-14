# Solution: Fixup Commits

## Step 1 -- Open lazygit

```bash
lazygit -p sandbox/04-fixup-commits
```

Lazygit opens with the **Files** panel focused. You should see one modified file:

- `services/api/src/token.py` (modified, unstaged)

In the **Commits** panel you can see three commits on `feature/auth-middleware`:

1. `test(api): add auth middleware tests` (HEAD)
2. `feat(api): implement token validation`
3. `feat(api): add auth middleware skeleton`

## Step 2 -- Stage the fix

1. In the **Files** panel, `services/api/src/token.py` should already be selected.
2. Press `<space>` to stage it.

The file moves from the unstaged section to the staged section.

> **Git context:** This is a standard `git add services/api/src/token.py`.

## Step 3 -- Create a fixup commit

1. Switch to the **Commits** panel by pressing `2` (or navigate with `[`/`]`).
2. Use `j`/`k` to select the second commit: `feat(api): implement token validation`.
3. Press `F` (shift+f) to create a fixup commit targeting this commit.

A new commit appears at the top of the commit list with the message:

```
fixup! feat(api): implement token validation
```

Your branch now has 4 commits. The fixup commit is at the tip.

> **Git context:** Lazygit ran `git commit --fixup=<sha>` where `<sha>` is the hash of "feat(api): implement token validation". The `fixup!` prefix tells git's autosquash that this commit should be folded into the target during a rebase.

## Step 4 -- Auto-squash the fixup commit

1. Stay in the **Commits** panel.
2. Press `S` (shift+s) to squash all fixup commits above into their targets.
3. Lazygit may ask you to confirm -- select the option to proceed (squash fixup commits above the selected commit).

Lazygit runs an interactive rebase with `--autosquash`. The fixup commit is automatically reordered to sit right after its target commit and then squashed into it. When the rebase finishes, you are back to 3 commits:

1. `test(api): add auth middleware tests` (HEAD)
2. `feat(api): implement token validation` (now includes the input sanitization fix)
3. `feat(api): add auth middleware skeleton`

> **Git context:** Under the hood, lazygit ran `git rebase -i --autosquash <base>`. Git reordered the `fixup!` commit to immediately follow its target, then squashed them together, discarding the fixup commit message. The result is a clean history that looks like the fix was always part of the original commit.

## Step 5 -- Verify

Exit lazygit by pressing `q`, then verify your work:

```bash
./train.sh verify 4/4
```

All five checks should pass:

1. HEAD is on branch `feature/auth-middleware`.
2. Exactly 3 commits ahead of `exercise-start` (count unchanged).
3. Working tree is clean (fix committed).
4. The fix content is in the second commit, not HEAD.
5. No commit messages contain `fixup!` (auto-squash completed).
