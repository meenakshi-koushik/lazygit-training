# Custom Keybindings

```bash
lazygit -ucf sandbox/01-custom-keybindings/lazygit.yml -p sandbox/01-custom-keybindings/repo
```

## Scenario

You are setting up lazygit for your team's monorepo workflow. The team frequently needs to run a test script for the current service they are working on, and they want a one-key shortcut in lazygit to do it. You will edit the lazygit configuration to add a custom command that runs `make test` and bind it to a keybinding.

A starter `lazygit.yml` config file has been provided in the sandbox. Your job is to add a custom command to it.

## Objectives

1. Edit the `lazygit.yml` file in the sandbox to add a custom command that runs `echo "TESTS PASSED"` (simulating a test runner).
2. The custom command should be bound to the key `T` in the `files` context.
3. The command's description should contain the text "Run tests".
4. After saving, verify that the config file is valid by checking with `./train.sh verify 11/1`.

## Key Concepts

Lazygit's `customCommands` config lets you add your own keybindings that run arbitrary shell commands. This is the most powerful customization feature -- it turns lazygit into a command center for your entire development workflow.

A custom command has these fields:

```yaml
customCommands:
  - key: "T"                      # The keybinding
    context: "files"              # Which panel it works in (files, branches, commits, stash, global)
    description: "Run tests"      # Shown in the keybinding menu
    command: "make test"          # The shell command to run
    subprocess: true              # true = show output in terminal; false = run in background
```

Common `context` values:
- `files` -- Files panel
- `localBranches` -- Local Branches panel
- `commits` -- Commits panel
- `stash` -- Stash panel
- `global` -- Available everywhere

Custom commands can also use **template variables** to reference the current context:

| Variable | Description |
|----------|-------------|
| `{{.SelectedFile.Name}}` | Currently selected file name |
| `{{.CheckedOutBranch.Name}}` | Current branch name |
| `{{.SelectedLocalCommit.Hash}}` | Selected commit hash |

For example, to lint only the selected file:
```yaml
- key: "L"
  context: "files"
  command: "eslint {{.SelectedFile.Name}}"
  description: "Lint selected file"
  subprocess: true
```

## Prerequisites

- Module 1, Lesson 3 -- configuration basics.

## Verify

```bash
./train.sh verify 11/1
```
