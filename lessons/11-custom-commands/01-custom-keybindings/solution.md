# Solution: Custom Keybindings

## Step 1 -- Open the config file

Open `sandbox/01-custom-keybindings/lazygit.yml` in your text editor:

```bash
$EDITOR sandbox/01-custom-keybindings/lazygit.yml
```

You will see a starter config with GUI and git settings, plus a TODO comment at the bottom.

## Step 2 -- Add the custom command

Replace the TODO comment block at the end of the file with:

```yaml
customCommands:
  - key: "T"
    context: "files"
    command: "echo \"TESTS PASSED\""
    description: "Run tests"
    subprocess: true
```

Save the file.

This adds a custom keybinding `T` that is available in the **Files** panel. When pressed, it runs `echo "TESTS PASSED"` in a subprocess (meaning the output is shown in your terminal, and lazygit pauses until you press enter).

> **Config context:** In a real workflow, you would replace `echo "TESTS PASSED"` with your actual test command, e.g., `make test`, `npm test`, or `pytest services/api/`. The `subprocess: true` setting is important for interactive commands -- it gives the command full access to your terminal.

## Step 3 -- Test in lazygit (optional)

You can test the config by launching lazygit with your custom config:

```bash
lazygit -ucf sandbox/01-custom-keybindings/lazygit.yml -p sandbox/01-custom-keybindings/repo
```

The `-ucf` flag tells lazygit to use a specific config file. Once inside:
1. Press `2` to go to the **Files** panel.
2. Press `T` -- you should see "TESTS PASSED" printed in a subprocess window.
3. Press `<enter>` to return to lazygit.

## Step 4 -- Verify your work

```bash
./train.sh verify 11/1
```

All checks should pass:
1. Config file exists.
2. Contains `customCommands` section.
3. Command bound to key `T`.
4. Uses `files` context.
5. Command outputs "TESTS PASSED".
6. Description contains "Run tests".
7. subprocess is true.

## Bonus: More custom command ideas

Here are other useful custom commands for monorepo development:

```yaml
customCommands:
  # Run tests for the selected file's service
  - key: "T"
    context: "files"
    command: "echo \"TESTS PASSED\""
    description: "Run tests"
    subprocess: true

  # Open the selected file in VS Code
  - key: "E"
    context: "files"
    command: "code {{.SelectedFile.Name}}"
    description: "Open in VS Code"
    subprocess: false

  # Create a conventional commit with a type prefix
  - key: "C"
    context: "files"
    command: "git commit -m '{{.Form.Type}}({{.Form.Scope}}): {{.Form.Message}}'"
    description: "Conventional commit"
    prompts:
      - type: "menu"
        key: "Type"
        title: "Commit type"
        options:
          - name: "feat"
            value: "feat"
          - name: "fix"
            value: "fix"
          - name: "refactor"
            value: "refactor"
      - type: "input"
        key: "Scope"
        title: "Scope (e.g., api, worker)"
      - type: "input"
        key: "Message"
        title: "Commit message"
```
