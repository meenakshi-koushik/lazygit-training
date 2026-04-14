# Basic Merge Conflicts

```bash
lazygit -p sandbox/01-basic-merge-conflicts
```

## Scenario

You are working on a feature branch `feature/api-health-check` in the platform monorepo. You added health check configuration and a health checker class to the API service. Meanwhile, a teammate pushed changes to `main` that modified the same `Settings` class in `services/api/src/config.py` -- they added connection pool and timeout settings.

You ran `git merge main` to bring your branch up to date, and now you have a merge conflict in `config.py`. Both branches added new settings and a new method to the same class, so git cannot automatically combine them.

Lazygit is waiting for you to resolve the conflict and complete the merge.

## Objectives

1. Open the conflicted file `services/api/src/config.py` in lazygit's merge conflict panel.
2. Resolve the conflict by keeping changes from **both** sides -- you want all the settings and both methods.
3. Stage the resolved file.
4. Complete the merge commit.
5. End with a clean working tree on the `feature/api-health-check` branch.

## Key Concepts

When git encounters conflicting changes during a merge, it marks the file with conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`) and pauses. Lazygit provides a dedicated conflict resolution view that lets you pick between sections without manually editing markers.

In the **Files** panel, conflicted files are marked with `UU`. Select the file and press `<enter>` to open the merge conflict panel. Lazygit highlights each conflicting section and lets you:

- Press `<space>` on a highlighted section to pick that side (green = selected, red = rejected).
- Use arrow keys (`<up>`/`<down>`) to navigate between conflict sections.
- In this exercise both sides have valuable code, so you may need to select both sides. Use `b` to pick both.

After resolving all conflicts in a file, press `<esc>` to return to the Files panel, then stage the file with `<space>`. Once all conflicted files are staged, continue the merge by pressing `<space>` at the merge status prompt or creating a commit.

Under the hood, this is the same as editing the conflict markers out of the file, running `git add <file>`, and then `git commit` (or `git merge --continue`).

## Prerequisites

- Module 2 (Precision Staging) -- comfortable staging files in lazygit.
- Module 4, Lesson 1 (Amending Commits) -- familiar with the Commits panel.

## Verify

```bash
./train.sh verify 5/1
```
