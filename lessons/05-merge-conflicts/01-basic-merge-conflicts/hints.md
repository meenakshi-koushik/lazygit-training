## Hint 1

Look at the **Files** panel. You should see `services/api/src/config.py` marked with `UU` (both modified -- conflict). Select it and press `<enter>` to open the merge conflict view.

## Hint 2

In the merge conflict view, lazygit highlights each conflicting section. Since you want to keep changes from **both** branches (health check settings from yours, connection pool settings from main), press `b` to pick both sides of the conflict.

## Hint 3

After resolving the conflict, press `<esc>` to go back to the **Files** panel. The file should now show as modified (no longer `UU`). Stage it with `<space>`. Then continue the merge -- lazygit may show a merge status indicator or prompt you to create the merge commit. You can press `c` to commit or look for a "continue merge" option.

## Hint 4

If the merge commit editor appears, accept the default merge commit message (or edit it if you prefer) and confirm with `<enter>`. Your working tree should be clean after the merge commit is created. Verify with `./train.sh verify 5/1`.
