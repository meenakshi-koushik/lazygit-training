# Solution: Conflict Resolution Strategies

## Step 1 -- Open lazygit

```bash
lazygit -p sandbox/04-conflict-resolution-strategies
```

The **Files** panel shows three files with `UU` status:
- `Makefile`
- `services/auth/src/config.py`
- `services/auth/src/routes.py`

## Step 2 -- Resolve `services/auth/src/config.py` (keep ours)

1. Select `services/auth/src/config.py` and press `<enter>`.
2. In the conflict view, you see your OAuth settings (top/HEAD section) vs. their SAML settings (bottom/incoming section).
3. Select the **top section** (your OAuth code) and press `<space>` to keep it. The SAML code is discarded.
4. If there are multiple conflict sections, navigate with `<up>`/`<down>` and pick the top section for each.
5. Press `<esc>` to return to Files, then `<space>` to stage.

> **Git context:** Picking "ours" for every conflict section is equivalent to resolving the file to match your branch's version. In some cases you could also use `git checkout --ours <file>`, but lazygit's conflict view gives you more control when only some sections should use "ours".

## Step 3 -- Resolve `services/auth/src/routes.py` (keep ours)

1. Select the file and press `<enter>`.
2. Pick the top section (your OAuth routes) for each conflict.
3. `<esc>` back, `<space>` to stage.

## Step 4 -- Resolve `Makefile` (keep ours)

1. Select `Makefile` and press `<enter>`.
2. Pick the top section (your Makefile with `auth-test` and `ruff`) for each conflict.
3. `<esc>` back, `<space>` to stage.

## Step 5 -- Complete the merge

1. With all files resolved and staged, press `c` to create the merge commit.
2. Accept the default merge message and press `<enter>`.

The Files panel should be empty.

> **Git context:** Even though you picked "ours" for every conflict, the merge commit still records both parents. The teammate's non-conflicting changes (if any) are still included. The "ours" strategy only applies to the conflicting sections -- it does not discard the entire merge.

## Step 6 -- Verify

Exit lazygit with `q`, then:

```bash
./train.sh verify 5/4
```

All checks should pass:
1. On branch `feature/oauth-upgrade`.
2. No unresolved conflicts.
3. Working tree is clean.
4. HEAD is a merge commit.
5. `config.py` contains OAuth settings (ours).
6. `config.py` does NOT contain SAML settings (theirs).
7. `routes.py` contains OAuth routes (ours).
8. `routes.py` does NOT contain SAML routes (theirs).
9. `Makefile` contains `auth-test` (ours).
10. `Makefile` does NOT contain `security-scan` (theirs).
11. No conflict markers remain.
