# Configuration Basics

```bash
lazygit -p sandbox/03-configuration-basics
```

## Scenario

You are working in a monorepo with several services. Before diving into more advanced lazygit workflows, you want to understand how lazygit is configured and how to see what git commands it runs behind the scenes. Knowing where the config file lives and how to read the command log will make you a much more effective lazygit user -- you'll be able to customize keybindings, tweak behavior, and debug issues by seeing exactly what git operations happen under the hood.

## Objectives

1. Open lazygit's configuration file from within lazygit (using the status panel).
2. View the **command log panel** to see what git commands lazygit runs.
3. Toggle the command log panel's visibility.
4. Stage the modified files and make a commit with the word "config" in the message (e.g., `chore: explore config and command log`).
5. Ensure the working tree is clean (all changes committed).

## Key Concepts

- Lazygit stores its configuration in `~/.config/lazygit/config.yml` (Linux/macOS) or `%APPDATA%\lazygit\config.yml` (Windows). This file controls keybindings, UI behavior, colors, and custom commands.
- From the **Status panel** (the top-left panel showing the repo name), pressing `o` opens the lazygit config file in your editor. Pressing `,` opens it for direct editing within lazygit.
- The **command log panel** appears at the bottom of the lazygit UI and shows every git command that lazygit executes. This is invaluable for understanding what's happening and for learning git itself.
- You can toggle the command log panel by pressing `` ` `` (backtick). The panel cycles through three states: hidden, small, and expanded.
- The command log is not just a learning tool -- when something goes wrong, it shows you exactly what command failed so you can investigate or report the issue.

## Prerequisites

- [Lesson 01: Navigating Panels](../01-navigating-panels/) -- you should be comfortable switching between lazygit panels.

## Verify

```bash
./train.sh verify 1/3
```
