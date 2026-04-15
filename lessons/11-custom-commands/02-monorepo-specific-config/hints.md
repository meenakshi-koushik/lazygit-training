## Hint 1

Start by adding the GUI settings. Under the existing `gui:` section, add `showFileTree: true` and `showNumstatInFilesView: true`. These are simple boolean settings.

## Hint 2

For `git.mainBranches`, add a YAML list under the `git:` section:

```yaml
git:
  mainBranches:
    - main
    - develop
```

For `diffContextSize`, add it under `git:` as well:

```yaml
git:
  diffContextSize: 5
```

## Hint 3

For `commitPrefix`, you need a regex pattern and a replacement string. The pattern should capture the ticket ID from branch names like `feature/PROJ-42-description`:

```yaml
git:
  commitPrefix:
    - pattern: "^\\w+/(\\w+-\\d+).*"
      replace: "[$1] "
```

## Hint 4

For the custom command, use `{{.SelectedFile.Name}}` to reference the currently selected file. Here is a complete example:

```yaml
customCommands:
  - key: "t"
    context: "files"
    command: "echo Running tests for {{.SelectedFile.Name}}"
    description: "Run tests for selected file"
    output: terminal
```

Combine all settings into the config file and run `./train.sh verify 11/2`.
