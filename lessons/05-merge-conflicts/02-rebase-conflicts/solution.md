# Solution: Rebase Conflicts

## Step 1 -- Open lazygit

```bash
lazygit -p sandbox/02-rebase-conflicts
```

Lazygit opens on the `feature/worker-retry` branch. In the **Commits** panel you see your 3 feature commits on top of the shared history. The **Branches** panel shows both `feature/worker-retry` (current) and `main`.

## Step 2 -- Start the rebase

1. Switch to the **Branches** panel (press `3` or cycle with `]`).
2. Select `main`.
3. Press `r` to rebase the current branch onto main.
4. Lazygit asks for confirmation -- select **rebase**.

Git starts replaying your first commit ("feat(worker): add retry configuration") on top of main and hits a conflict in `services/worker/src/config.py`.

## Step 3 -- Resolve the first conflict (config.py)

1. Switch to the **Files** panel (press `2`). You see `services/worker/src/config.py` marked `UU`.
2. Select the file and press `<enter>` to open the merge conflict view.
3. The conflict shows your retry settings vs. the teammate's batch settings. Press `b` to keep both sides.
4. If there are multiple conflict sections, navigate with `<up>`/`<down>` and resolve each one with `b`.
5. Press `<esc>` to return to the Files panel.
6. Stage the resolved file with `<space>`.
7. Continue the rebase -- lazygit should show a "continue rebase" option. Select it or look for the rebase status indicator and press the continue action.

> **Git context:** This is equivalent to editing the file, running `git add services/worker/src/config.py`, then `git rebase --continue`.

## Step 4 -- Resolve the second conflict (main.py)

Git replays your second commit ("feat(worker): implement retry logic in job processor") and conflicts in `services/worker/src/main.py`.

1. In the **Files** panel, select the conflicted file and press `<enter>`.
2. The conflict shows your `process_job` function vs. the teammate's `process_batch` function. Press `b` to keep both.
3. Resolve any additional conflict sections the same way.
4. Press `<esc>`, stage with `<space>`, and continue the rebase.

## Step 5 -- Third commit replays cleanly (or resolve if needed)

Your third commit ("test(worker): add retry logic unit tests") only modifies test files and may replay without conflicts. If it does conflict, resolve the same way.

After all three commits are replayed, the rebase is complete.

## Step 6 -- Verify the result

In the **Commits** panel, you should see your 3 feature commits now sitting on top of main's commits. The history is linear -- no merge commits.

Exit lazygit with `q`, then verify:

```bash
./train.sh verify 5/2
```

All checks should pass:
1. HEAD is on branch `feature/worker-retry`.
2. No unresolved conflicts.
3. Working tree is clean.
4. No rebase in progress.
5. History is linear (no merge commits).
6. Feature branch is rebased on top of main.
7. All three feature commits are present.
8. `config.py` contains both retry and batch settings.
9. No conflict markers in any tracked files.
