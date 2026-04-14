# Monorepo-Specific Config

```bash
lazygit -ucf sandbox/02-monorepo-specific-config/lazygit.yml -p sandbox/02-monorepo-specific-config/repo
```

## Scenario

Your team works in a large monorepo with multiple services (`api`, `worker`, `frontend`), shared libraries (`common`, `auth`), and infrastructure code. The default lazygit config works, but it does not take advantage of features that make monorepo development faster and less error-prone.

You will configure lazygit to:
- Show files as a navigable tree (so you can see which service each change belongs to)
- Display line-count stats to quickly gauge change size
- Recognize your team's branching model (both `main` and `develop` are long-lived branches)
- Show more diff context for safer code review
- Auto-prefix commit messages with the ticket ID from the branch name
- Add a custom command that uses lazygit template variables to run tests for the service you are currently looking at

## Objectives

1. **Enable file tree view**: set `gui.showFileTree` to `true` and `gui.showNumstatInFilesView` to `true`.
2. **Configure main branches**: set `git.mainBranches` to a list containing both `main` and `develop`.
3. **Increase diff context**: set `git.diffContextSize` to `5`.
4. **Add commit message prefix**: add a `git.commitPrefix` entry with a `pattern` that captures a ticket ID from branch names like `feature/PROJ-42-description`, and a `replace` string that uses the captured group (e.g., `[$1] `).
5. **Add a service-aware custom command**: add a `customCommands` entry that uses the `{{.SelectedFile.Name}}` template variable. The command should be bound to key `t` in the `files` context, with `subprocess: true`.

## Key Concepts

### File Tree View

In a monorepo, a flat file list is hard to scan. With `gui.showFileTree: true`, lazygit groups files by directory, so you instantly see which service or library each change belongs to. Combined with `gui.showNumstatInFilesView: true`, you also see line counts (`+5 -2`) next to each file, making it easy to spot unexpectedly large changes.

### Main Branches

Lazygit uses `git.mainBranches` to decide which branches to show commits relative to. If your team uses both `main` and `develop` as long-lived branches, adding `develop` here ensures lazygit correctly shows how far your feature branch has diverged.

### Diff Context Size

The default `git.diffContextSize` of 3 lines is fine for small files, but in a monorepo with large files, bumping it to 5 gives you more surrounding code for context during review. You can still adjust it on the fly in lazygit with `{` and `}`.

### Commit Message Prefix

The `git.commitPrefix` config lets you auto-populate commit messages with a prefix extracted from the branch name using a regex. For example, if your branch is `feature/PROJ-42-add-rate-limiting`, a pattern like `^\w+/(\w+-\d+).*` with replace `[$1] ` will pre-fill the commit message with `[PROJ-42] `.

### Template Variables in Custom Commands

Custom commands can reference the current lazygit context using Go template variables:

| Variable | Description |
|----------|-------------|
| `{{.SelectedFile.Name}}` | Path of the currently selected file |
| `{{.CheckedOutBranch.Name}}` | Current branch name |
| `{{.SelectedLocalCommit.Hash}}` | Selected commit hash |
| `{{.SelectedLocalBranch.Name}}` | Selected branch name |

This lets you build commands that adapt to what you are looking at. For example, a test runner that targets the service directory of the selected file.

## Prerequisites

- Module 11, Lesson 1 -- custom keybindings basics.

## Verify

```bash
./train.sh verify 11/2
```
