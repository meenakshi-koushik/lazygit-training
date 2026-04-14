# Solution: Creating PRs from Lazygit

## Step 1 -- Open lazygit

```bash
lazygit -p sandbox/01-creating-prs-from-lazygit
```

Lazygit opens on `feature/rate-limiter`. Press `4` to go to the **Commits** panel. You should see 4 WIP commits on top of the main branch history.

## Step 2 -- Squash the WIP commits

1. In the **Commits** panel, navigate to the second commit from the top ("wip: add flask middleware wrapper").
2. Press `s` to squash it into the commit below ("wip: add rate limiter methods").
3. Navigate to what is now the second commit ("wip: add rate limiter methods" with the squashed content).
4. Press `s` again to squash it into "WIP: start rate limiter".
5. Navigate to the remaining top commit ("add tests for rate limiter").
6. Press `s` to squash it into the combined commit below.

All 4 commits are now squashed into one. Lazygit will show the combined commit message.

> **Git context:** This is equivalent to an interactive rebase (`git rebase -i`) where you mark 3 commits as `squash` and keep one as `pick`.

## Step 3 -- Reword the commit message

1. Select the squashed commit and press `r` to reword it.
2. Replace the entire message with a clean description:
   ```
   feat(api): add rate limiting middleware with token bucket algorithm
   ```
3. Press `<enter>` to save.

Make sure the message starts with `feat(api):` and does not contain "WIP" or "wip".

> **Git context:** `git commit --amend` on the squashed commit to update just the message.

## Step 4 -- Push to origin

1. Press `P` (uppercase) to push the branch.
2. If lazygit prompts you to set an upstream, confirm with `<enter>`.

The branch is now pushed to origin with a clean, single-commit history -- ready for a pull request.

> **Git context:** In a real workflow, you would now press `o` in the **Local Branches** panel to open the PR creation page in your browser. Lazygit constructs the URL from your remote configuration (e.g., `https://github.com/<user>/<repo>/compare/feature/rate-limiter?expand=1`). Since this is a local exercise, we skip that step.

## Step 5 -- Verify your work

Exit lazygit by pressing `q`, then verify:

```bash
./train.sh verify 10/1
```

All checks should pass:
1. On branch `feature/rate-limiter`.
2. Exactly 1 commit ahead of main (squashed).
3. Commit message starts with `feat(api):`.
4. No WIP in the commit message.
5. Rate limiter code is present.
6. Tests are present.
7. Branch is pushed to origin.
8. Working tree is clean.
