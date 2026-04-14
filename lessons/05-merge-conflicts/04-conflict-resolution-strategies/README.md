# Conflict Resolution Strategies

```bash
lazygit -p sandbox/04-conflict-resolution-strategies
```

## Scenario

You are on `feature/oauth-upgrade` where you rewrote the auth service from scratch to support OAuth 2.0. Meanwhile, a teammate pushed SAML SSO support to `main` -- a completely different approach to the same problem. After a team discussion, the decision was made: **your OAuth 2.0 implementation wins**. The SAML code should be discarded entirely.

You merged `main` into your branch and now have conflicts in three files:

1. `services/auth/src/config.py` -- your OAuth config vs. their SAML config. **Keep yours.**
2. `services/auth/src/routes.py` -- your OAuth routes vs. their SAML routes. **Keep yours.**
3. `Makefile` -- your updated targets vs. their security targets. **Keep yours.**

This is different from previous lessons where you kept both sides. Here you need to use the "pick one side" strategy -- specifically, picking your side (ours) for every conflict.

## Objectives

1. Resolve all three conflicts by keeping **only your side** (the current branch / "ours" side).
2. Stage all resolved files.
3. Complete the merge commit.
4. Verify that:
   - `config.py` contains OAuth settings and NOT SAML settings.
   - `routes.py` contains OAuth routes and NOT SAML routes.
   - `Makefile` contains your targets (`auth-test`, `ruff`) and NOT theirs (`security-scan`, `flake8`).
5. End with a clean working tree on the `feature/oauth-upgrade` branch.

## Key Concepts

Not every conflict should be resolved by keeping both sides. Common strategies:

- **Keep both** (`b`): When both changes are complementary and should coexist. Used in previous lessons.
- **Pick ours** (`<space>` on the current/HEAD section): When your changes supersede the other branch's. The incoming changes are discarded.
- **Pick theirs** (`<space>` on the incoming section): When the other branch's changes are correct and yours should be discarded.
- **Edit manually**: When neither side is exactly right and you need a custom resolution. Press `e` on the file in the Files panel to open it in your editor.

In lazygit's merge conflict view:

- The top section (marked `HEAD` or `current`) is **ours** -- the branch you are on.
- The bottom section (marked with the incoming branch name) is **theirs**.
- Press `<space>` on the section you want to keep. The other section is discarded.
- Navigate between conflict sections with `<up>`/`<down>`.

This lesson practices the "pick ours" strategy. In a real team scenario, you would only do this after confirming with the team that your changes should take priority.

## Prerequisites

- Module 5, Lessons 1-3 (merge conflicts, rebase conflicts, multi-file conflicts).

## Verify

```bash
./train.sh verify 5/4
```
