# Creating PRs from Lazygit

```bash
lazygit -p sandbox/01-creating-prs-from-lazygit
```

## Scenario

You have been working on `feature/rate-limiter` in the platform monorepo, adding rate limiting middleware to the API service. Your branch has 4 messy WIP commits that need to be cleaned up before you submit a pull request. The PR should have a single, well-described commit.

Your goal is to prepare the branch for a pull request: squash the commits, write a descriptive commit message, and push the branch to origin. In a real workflow, you would then press `o` in the Branches panel to open the PR creation page in your browser -- but since this is a local exercise, we will verify that the branch is properly prepared and pushed.

## Objectives

1. Squash all 4 WIP commits on `feature/rate-limiter` into a single commit.
2. Reword the squashed commit to have a clean, descriptive message starting with `feat(api):`.
3. Push the cleaned-up branch to `origin`.

## Key Concepts

Before creating a pull request, you should prepare your branch:

1. **Clean commit history** -- Squash WIP commits into logical, well-described commits. Reviewers should see intent, not process.
2. **Descriptive commit messages** -- Use conventional commit format (`feat:`, `fix:`, `refactor:`). The commit message often becomes the PR description.
3. **Push to remote** -- The branch must exist on the remote before a PR can be created.

Lazygit's PR creation keybindings (for reference -- these require a real GitHub/GitLab remote):

| Key | Panel | Action |
|-----|-------|--------|
| `o` | Local Branches | Create pull request (opens browser) |
| `O` | Local Branches | View PR creation options |
| `G` | Local Branches / Commits | Open existing PR in browser |
| `<c-y>` | Local Branches | Copy PR URL to clipboard |

Under the hood, lazygit constructs a URL like `https://github.com/<user>/<repo>/compare/<branch>?expand=1` and opens it in your default browser. It detects the hosting platform from the remote URL.

## Prerequisites

- Module 4, Lesson 2 -- interactive rebase (squashing).
- Module 9, Lesson 1 -- push patterns.

## Verify

```bash
./train.sh verify 10/1
```
