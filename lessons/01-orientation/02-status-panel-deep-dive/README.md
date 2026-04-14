# Status Panel Deep Dive

## Scenario

You are working on a monorepo with several active feature branches. Your team has been busy -- there are branches for authentication, notifications, a database migration, and infrastructure changes all in flight. You need to get oriented: understand what branch you are on, see what other branches have been active recently, switch to a specific branch, and create a new branch from there.

In lazygit, the **Status panel** (the top-left panel, panel 1) is your starting point for this kind of orientation. It shows the current repository name, the branch you are on, upstream tracking status (ahead/behind counts relative to origin), and gives you quick access to recent branches.

## Objectives

1. Open lazygit in the sandbox repo and navigate to the Status panel.
2. Observe the current branch name and upstream tracking information displayed in the Status panel.
3. Use the Status panel's recent branches feature to switch to the `feature/auth-service` branch.
4. Create a new branch called `status-explored` from `feature/auth-service`.

## Key Concepts

- The Status panel is always the first panel (press `1` or navigate with `h`/`l`). It shows the repo name, the current branch, and how many commits you are ahead/behind the remote tracking branch.
- Pressing `<enter>` on the Status panel opens a **recent repos** menu. But for switching branches, the **Branches panel** (panel 3) or the Status panel's keybinding to switch branches is what you need.
- In lazygit, you create a new branch by pressing `n` while in the Branches panel with a branch selected, then typing the new branch name.
- Under the hood, switching branches is `git checkout <branch>` (or `git switch <branch>`), and creating a branch is `git checkout -b <new-branch>`.

## Prerequisites

- [01-orientation/01-navigating-panels](../01-navigating-panels/) -- you should be comfortable moving between lazygit panels.
