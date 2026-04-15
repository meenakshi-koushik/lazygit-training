## Hint 1

Open the `lazygit.yml` file in the sandbox with your text editor. Look for the TODO comment at the bottom -- that is where you need to add a `customCommands` YAML section. Check the lesson README for the required fields.

## Hint 2

The `customCommands` is a top-level YAML key that contains a list of command objects. Add this structure to the end of the file (remove the TODO comment):

```yaml
customCommands:
  - key: ...
    context: ...
    command: ...
    description: ...
    output: ...
```

Fill in the values according to the objectives.

## Hint 3

The complete custom command section should look like this:

```yaml
customCommands:
  - key: "T"
    context: "files"
    command: "echo \"TESTS PASSED\""
    description: "Run tests"
    output: terminal
```

Add this to the end of `lazygit.yml`, save, and run `./train.sh verify 11/1`.
