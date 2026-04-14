# Solution: Basic Merge Conflicts

## Step 1 -- Open lazygit

```bash
lazygit -p sandbox/01-basic-merge-conflicts
```

Lazygit opens with the **Files** panel focused. You should see:
- `services/api/src/config.py` marked with `UU` (merge conflict)
- A status indicator showing you are mid-merge

## Step 2 -- Open the conflict resolution view

1. Select `services/api/src/config.py` (it may already be selected).
2. Press `<enter>` to open the merge conflict panel.

Lazygit shows the file with conflict sections highlighted. You will see blocks like:

```
<<<<<<< HEAD (current -- your feature branch)
        self.health_check_interval = ...
        self.health_check_path = ...
=======
        self.max_connections = ...
        self.request_timeout = ...
>>>>>>> main (incoming -- from main)
```

## Step 3 -- Resolve the conflict by picking both sides

Since you want to keep code from **both** branches:

1. With the first conflict section highlighted, press `b` to pick **both** sides of the conflict.
2. If there are additional conflict sections (e.g., the methods), navigate to them with `<down>` and press `b` again to pick both.

After resolving all conflict sections, the conflict markers disappear and the file contains both sets of changes.

> **Git context:** Picking "both" is equivalent to manually editing the file to remove the `<<<<<<<`, `=======`, and `>>>>>>>` markers and keeping all the code from both sides. The resulting file will have both `health_check_interval`/`health_check_path` settings and `max_connections`/`request_timeout` settings, plus both the `get_health_config()` and `is_production()` methods.

## Step 4 -- Stage the resolved file

1. Press `<esc>` to return to the **Files** panel.
2. The file should now show as modified (not `UU` anymore).
3. Press `<space>` to stage the resolved file.

## Step 5 -- Complete the merge commit

With the resolved file staged, complete the merge:

1. Lazygit should show an option to continue the merge. You can press `c` to open the commit dialog.
2. A merge commit message is pre-filled (something like "Merge branch 'main' into feature/api-health-check"). Accept it by pressing `<enter>`.

The merge is complete. The Files panel should be empty (clean working tree).

> **Git context:** This is equivalent to running `git add services/api/src/config.py` followed by `git merge --continue` (or `git commit`). Git creates a merge commit with two parents -- one pointing to your feature branch's previous HEAD and one pointing to main's HEAD.

## Step 6 -- Verify

Exit lazygit with `q`, then verify:

```bash
./train.sh verify 5/1
```

All checks should pass:
1. HEAD is on branch `feature/api-health-check`.
2. No unresolved merge conflicts.
3. Working tree is clean.
4. HEAD is a merge commit (2 parents).
5. `config.py` contains health check settings (from your branch).
6. `config.py` contains connection pool settings (from main).
7. `config.py` has no conflict markers.
