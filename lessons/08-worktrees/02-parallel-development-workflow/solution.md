# Solution: Parallel Development Workflow

## Step 1 -- Open lazygit

```bash
lazygit -p sandbox/02-parallel-development-workflow
```

Lazygit opens with the **Files** panel focused. You should see two modified files (`services/api/src/routes.py` and `services/api/src/config.py`) -- this is your work in progress on `feature/api-refactor`. Do not stage or commit these.

## Step 2 -- Switch to the review worktree

1. Press `3` to go to the **Branches** panel (or any panel that supports `w`).
2. Press `w` to open the **Worktrees** view.
3. You should see two worktrees listed:
   - The main worktree (your current one, on `feature/api-refactor`)
   - The review worktree (`02-parallel-development-workflow-review`, on `feature/review-target`)
4. Navigate to the review worktree with `j`/`k`.
5. Press `<space>` to switch to it.

Lazygit reloads. The branch indicator now shows `feature/review-target`. The Files panel should be empty (clean working tree).

> **Git context:** Lazygit detects the worktree path and re-opens itself pointed at that directory. Under the hood, both worktrees share the same `.git` object database -- they are two views into the same repository.

## Step 3 -- Find and fix the TODO

The file that needs fixing is `services/api/src/validation.py`. Since the working tree is clean, the file will not appear in the Files panel. You need to edit it directly.

**Option A -- Edit from outside lazygit:**

Open a second terminal and edit the file:

```bash
# The file is in the review worktree directory
$EDITOR sandbox/02-parallel-development-workflow-review/services/api/src/validation.py
```

**Option B -- Edit from lazygit:**

1. Press `e` while in the Files panel to open the directory in your editor, or use your terminal to open the file.

In the file, find the `validate_input` function. You will see:

```python
def validate_input(value, field_name="input"):
    """Validate a single input string value."""
    if not isinstance(value, str):
        raise TypeError(f"{field_name} must be a string")
    # TODO: add input length check
    return value.strip()
```

Replace the `# TODO: add input length check` line with an actual check:

```python
def validate_input(value, field_name="input"):
    """Validate a single input string value."""
    if not isinstance(value, str):
        raise TypeError(f"{field_name} must be a string")
    if len(value) > MAX_LENGTH:
        raise ValueError(f"{field_name} exceeds maximum length of {MAX_LENGTH}")
    return value.strip()
```

Save the file.

## Step 4 -- Stage and commit the fix

1. Back in lazygit, press `2` to go to the **Files** panel. You should see `services/api/src/validation.py` listed as modified.
2. Press `<space>` to stage the file.
3. Press `c` to open the commit message editor.
4. Type a commit message that contains "fix" and "validation", for example: `fix(api): resolve validation TODO with input length check`
5. Press `<enter>` to confirm the commit.

The Files panel should now be empty again (clean working tree).

> **Git context:** This runs `git add services/api/src/validation.py` followed by `git commit -m "..."` in the review worktree. The commit is made on `feature/review-target`. Because worktrees share the object database, this commit is immediately visible from the main worktree as well.

## Step 5 -- Switch back to the main worktree

1. Press `w` to open the **Worktrees** view.
2. Select the main worktree (`02-parallel-development-workflow`, on `feature/api-refactor`).
3. Press `<space>` to switch back.

Lazygit reloads. The branch indicator shows `feature/api-refactor` again. The Files panel shows your original WIP modifications (`routes.py` and `config.py`) -- exactly as you left them.

> **Git context:** Your uncommitted changes on `feature/api-refactor` were never touched. Each worktree maintains its own working tree independently. Switching worktrees in lazygit is like switching between two terminal windows -- nothing is stashed, nothing is lost.

## Step 6 -- Verify

Exit lazygit with `q` and run:

```bash
./train.sh verify 8/2
```

All checks should pass:
1. Main worktree is on `feature/api-refactor`.
2. Main worktree has uncommitted changes (WIP intact).
3. Review worktree directory exists.
4. Review worktree is on `feature/review-target`.
5. Review worktree has a clean working tree.
6. The TODO has been removed from `validation.py`.
7. An actual length check (`len(`) exists in `validation.py`.
8. The fix commit message contains "fix" and "validation".
9. The review branch has at least one new commit.
