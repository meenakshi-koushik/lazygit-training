# Solution: Monorepo-Specific Config

## Step 1 -- Open the config file

Open `sandbox/02-monorepo-specific-config/lazygit.yml` in your text editor:

```bash
$EDITOR sandbox/02-monorepo-specific-config/lazygit.yml
```

You will see a minimal starter config with basic GUI and git settings.

## Step 2 -- Enable file tree view and line stats

Under the `gui:` section, add:

```yaml
gui:
  showBottomLine: true
  nerdFontsVersion: ""
  showFileTree: true
  showNumstatInFilesView: true
```

> **Why it matters:** In a monorepo with dozens of changed files across multiple services, the tree view groups files by directory (`services/api/`, `libs/common/`, etc.) so you can instantly see which components are affected. The numstat shows `+N -M` line counts next to each file, helping you spot unexpectedly large changes.

## Step 3 -- Configure main branches and diff context

Under the `git:` section, add `mainBranches`, and `diffContextSize`:

```yaml
git:
  paging:
    colorArg: always
  commit:
    signOff: false
  mainBranches:
    - main
    - develop
  diffContextSize: 5
```

> **Why it matters:** If your team uses `develop` as a long-lived integration branch, adding it to `mainBranches` ensures lazygit correctly shows your feature branch's divergence. Increasing `diffContextSize` from the default 3 to 5 gives you more surrounding code context during reviews, which is especially useful in large files.

## Step 4 -- Add commit message prefix

Still under `git:`, add a `commitPrefix` entry:

```yaml
git:
  commitPrefix:
    - pattern: "^\\w+/(\\w+-\\d+).*"
      replace: "[$1] "
```

> **Why it matters:** If your team uses branch names like `feature/PROJ-42-add-rate-limiting`, this config automatically pre-fills the commit message with `[PROJ-42] ` when you press `c` to commit. The regex `^\w+/(\w+-\d+).*` captures the ticket ID after the first `/`. This saves typing and ensures every commit references the right ticket.

## Step 5 -- Add a service-aware custom command

At the end of the file, add a `customCommands` section with a command that uses the `{{.SelectedFile.Name}}` template variable:

```yaml
customCommands:
  - key: "t"
    context: "files"
    command: "echo Running tests for {{.SelectedFile.Name}}"
    description: "Run tests for selected file"
    subprocess: true
```

> **Why it matters:** In a real workflow you would replace the `echo` with something like `pytest $(dirname {{.SelectedFile.Name}})` or `cd $(echo {{.SelectedFile.Name}} | cut -d/ -f1-2) && make test` to run tests only for the service containing the selected file. The `subprocess: true` setting gives the command full terminal access so you can see output and interact if needed.

## Complete config file

Here is the complete `lazygit.yml` after all changes:

```yaml
gui:
  showBottomLine: true
  nerdFontsVersion: ""
  showFileTree: true
  showNumstatInFilesView: true

git:
  paging:
    colorArg: always
  commit:
    signOff: false
  mainBranches:
    - main
    - develop
  diffContextSize: 5
  commitPrefix:
    - pattern: "^\\w+/(\\w+-\\d+).*"
      replace: "[$1] "

os:
  editPreset: ""

customCommands:
  - key: "t"
    context: "files"
    command: "echo Running tests for {{.SelectedFile.Name}}"
    description: "Run tests for selected file"
    subprocess: true
```

## Step 6 -- Test in lazygit (optional)

Launch lazygit with the custom config:

```bash
lazygit -ucf sandbox/02-monorepo-specific-config/lazygit.yml -p sandbox/02-monorepo-specific-config/repo
```

Things to try:
1. Press `2` to go to the **Files** panel -- files should appear as a tree.
2. Press `` ` `` to toggle between tree and flat view.
3. Check out the feature branch (`3` → select `feature/PROJ-42-add-rate-limiting` → `<space>`), then press `c` to start a commit -- the message should be pre-filled with `[PROJ-42] `.
4. Press `<esc>` to cancel the commit, then select a file and press `t` to run the custom test command.

## Step 7 -- Verify your work

```bash
./train.sh verify 11/2
```

All 11 checks should pass.
