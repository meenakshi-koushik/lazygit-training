# Solution: Multi-File Conflicts

## Step 1 -- Open lazygit

```bash
lazygit -p sandbox/03-multi-file-conflicts
```

The **Files** panel shows four files with `UU` status (merge conflicts):
- `infra/helm/values.yaml`
- `libs/common/src/common.py`
- `services/api/src/main.py`
- `services/worker/src/main.py`

## Step 2 -- Resolve `libs/common/src/common.py`

Start with the shared library since other files depend on it.

1. Select `libs/common/src/common.py` and press `<enter>`.
2. For each conflict section, press `b` to keep both sides. There may be multiple conflict sections -- navigate between them with `<up>`/`<down>`.
3. Press `<esc>` to return to the Files panel.
4. Press `<space>` to stage the resolved file.

The resolved file should contain both the `JsonFormatter`/`setup_logging` code (yours) and the `get_service_version`/`configure_monitoring` code (teammate's).

## Step 3 -- Resolve `services/api/src/main.py`

1. Select the file and press `<enter>`.
2. Press `b` on each conflict section to keep both.
3. `<esc>` back, `<space>` to stage.

The resolved file should import and call both `setup_logging` and `configure_monitoring`.

## Step 4 -- Resolve `services/worker/src/main.py`

1. Select the file and press `<enter>`.
2. Press `b` on each conflict section.
3. `<esc>` back, `<space>` to stage.

Same pattern as the API service.

## Step 5 -- Resolve `infra/helm/values.yaml`

1. Select the file and press `<enter>`.
2. Press `b` on each conflict section.
3. `<esc>` back, `<space>` to stage.

The resolved file should contain both `logging:` and `monitoring:` sections, and the updated resource limits.

## Step 6 -- Complete the merge

With all four files resolved and staged:

1. Press `c` to open the commit dialog (or lazygit may prompt you to continue the merge).
2. Accept the default merge commit message and press `<enter>`.

The Files panel should be empty (clean working tree).

> **Git context:** This is equivalent to running `git add` on each resolved file, then `git merge --continue`. The merge commit has two parents -- your feature branch and main.

## Step 7 -- Verify

Exit lazygit with `q`, then:

```bash
./train.sh verify 5/3
```

All checks should pass:
1. On branch `feature/structured-logging`.
2. No unresolved conflicts.
3. Working tree is clean.
4. HEAD is a merge commit.
5-6. `common.py` contains both JSON logging and monitoring code.
7-8. `api/main.py` contains both `setup_logging` and `configure_monitoring`.
9-10. `worker/main.py` contains both `setup_logging` and `configure_monitoring`.
11-12. Helm values contain both `logging:` and `monitoring:` sections.
13. No conflict markers remain.
